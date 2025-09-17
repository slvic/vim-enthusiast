-- struct_implements.lua
-- Annotates Go struct declarations with the interfaces they implement.
--
-- Approach (best-effort):
-- - Uses Treesitter to find struct type declarations in the current buffer.
-- - Queries the LSP (gopls) for workspace interfaces via `workspace/symbol`.
-- - For each interface, calls `textDocument/implementation` at the interface
--   identifier to get concrete types that implement it. Inverts the mapping to
--   map struct -> [interfaces].
-- - Renders a virtual line above the struct name: "implements: io.Reader, ...".
--
-- Notes & limitations:
-- - Requires gopls with workspace support; large workspaces may be slow.
-- - If `workspace/symbol` doesn't return interfaces, results may be empty.
-- - Only runs for `filetype=go`.
-- - This is a proof-of-concept; consider caching/incremental updates later.

local M = {}

local namespace = vim.api.nvim_create_namespace('struct_implements')

-- Cache package names per file URI to avoid repeated IO
local pkg_cache = {}

local function package_for_uri(uri)
  if pkg_cache[uri] ~= nil then
    return pkg_cache[uri] or nil
  end
  local fname = vim.uri_to_fname(uri)
  if not fname or fname == '' then
    pkg_cache[uri] = false
    return nil
  end
  local ok, lines = pcall(vim.fn.readfile, fname)
  if not ok or type(lines) ~= 'table' then
    pkg_cache[uri] = false
    return nil
  end
  for _, line in ipairs(lines) do
    local pkg = line:match('^%s*package%s+([%w_]+)')
    if pkg then
      pkg_cache[uri] = pkg
      return pkg
    end
  end
  pkg_cache[uri] = false
  return nil
end

local function fmt_iface_name(name, uri, container)
  local pkg = container
  if not pkg or pkg == '' then
    pkg = package_for_uri(uri)
  end
  if pkg and pkg ~= '' then
    return string.format('%s.%s', pkg, name)
  end
  return name
end

local function get_gopls_client(bufnr)
  -- Prefer new API; fall back for older Neovim versions
  local get_clients = vim.lsp.get_clients or vim.lsp.get_active_clients
  local clients = get_clients and get_clients({ bufnr = bufnr, name = 'gopls' }) or {}
  if clients and #clients > 0 then
    return clients[1]
  end
  return nil
end

local function is_go_buffer(bufnr)
  return vim.bo[bufnr].filetype == 'go'
end

local function ts_struct_nodes(bufnr)
  local ok, ts = pcall(require, 'vim.treesitter')
  if not ok then
    return {}
  end
  local parser = ts.get_parser(bufnr, 'go')
  if not parser then
    return {}
  end
  local query = ts.query.parse(
    'go',
    [[
      (type_declaration
        (type_spec
          name: (type_identifier) @name
          type: (struct_type) @struct
        ) @spec
      )
    ]]
  )
  local structs = {}
  for _, tree in ipairs(parser:parse()) do
    local root = tree:root()
    for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
      local cap = query.captures[id]
      if cap == 'name' then
        local name_node = node
        local spec_node
        -- query returns in order; we can seek the parent type_spec
        spec_node = name_node:parent()
        if spec_node and spec_node:type() == 'type_spec' then
          local sr, sc, er, ec = name_node:range()
          local name = vim.treesitter.get_node_text(name_node, bufnr)
          table.insert(structs, {
            name = name,
            name_range = { sr, sc, er, ec },
            spec_node = spec_node,
          })
        end
      end
    end
  end
  return structs
end

local function clear(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, namespace, 0, -1)
end

local function place(bufnr, line, text)
  -- virtual line above the struct name line
  vim.api.nvim_buf_set_extmark(bufnr, namespace, math.max(0, line), 0, {
    virt_lines = { { { text, 'Comment' } } },
    virt_lines_above = true,
    hl_mode = 'combine',
  })
end

local function lsp_position_params(uri, pos)
  return {
    textDocument = { uri = uri },
    position = { line = pos.line, character = pos.character },
  }
end

local function uri_for_buf(bufnr)
  local fname = vim.api.nvim_buf_get_name(bufnr)
  return vim.uri_from_fname(fname)
end

local function within(a, b)
  -- a, b: {line, character} ranges. Here we approximate using line numbers only.
  return a.start.line >= b.start.line and a['end'].line <= b['end'].line
end

-- Main function to refresh annotations in current buffer
function M.refresh(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not is_go_buffer(bufnr) then
    clear(bufnr)
    return
  end

  local client = get_gopls_client(bufnr)
  if not client then
    clear(bufnr)
    return
  end

  local structs = ts_struct_nodes(bufnr)
  if #structs == 0 then
    clear(bufnr)
    return
  end

  clear(bufnr)

  local bufnr_uri = uri_for_buf(bufnr)
  local map_struct_to_ifaces = {}

  local function render_from_map()
    for _, s in ipairs(structs) do
      local line = s.name_range[1]
      local ifaces = map_struct_to_ifaces[s.name]
      if ifaces and #ifaces > 0 then
        table.sort(ifaces)
        place(bufnr, line, ('implements: %s'):format(table.concat(ifaces, ', ')))
      end
    end
  end

  -- First try Type Hierarchy (directly gives interfaces as supertypes)
  local pending = #structs
  local any_hierarchy = false

  local function on_all_structs_done()
    if any_hierarchy then
      render_from_map()
      return
    end

    -- Fallback: old approach via workspace/symbol + implementation
    client.request('workspace/symbol', { query = 'interface' }, function(err, result)
      if err or type(result) ~= 'table' then
        return
      end
      local interfaces = {}
      for _, sym in ipairs(result) do
        if (sym.kind == 11) and sym.location and sym.location.uri and sym.location.range then
          table.insert(interfaces, sym)
        end
      end
      if #interfaces == 0 then
        return
      end
      local ipending = #interfaces
      local function imaybe_finish()
        ipending = ipending - 1
        if ipending > 0 then
          return
        end
        render_from_map()
      end
      for _, iface in ipairs(interfaces) do
        local iface_display = fmt_iface_name(iface.name, iface.location.uri, iface.containerName)
        local params = lsp_position_params(iface.location.uri, iface.location.range.start)
        client.request('textDocument/implementation', params, function(e2, res)
          if not e2 and res then
            local impls = res
            if impls and vim.tbl_islist(impls) then
              for _, loc in ipairs(impls) do
                if loc.uri == bufnr_uri then
                  local l = loc.range.start.line
                  for _, s in ipairs(structs) do
                    local sr = s.name_range[1]
                    if sr == l then
                      local list = map_struct_to_ifaces[s.name] or {}
                      local exists = false
                      for _, n in ipairs(list) do
                        if n == iface_display then
                          exists = true
                          break
                        end
                      end
                      if not exists then
                        table.insert(list, iface_display)
                      end
                      map_struct_to_ifaces[s.name] = list
                      break
                    end
                  end
                end
              end
            end
          end
          imaybe_finish()
        end, bufnr)
      end
    end, bufnr)
  end

  for _, s in ipairs(structs) do
    local sr, sc, er, ec = unpack(s.name_range)
    -- pick a position inside the identifier (avoid boundary issues)
    local midc = math.floor((sc + ec) / 2)
    local params = lsp_position_params(bufnr_uri, { line = sr, character = midc })
    client.request('textDocument/prepareTypeHierarchy', params, function(err, items)
      if not err and items and vim.tbl_islist(items) and #items > 0 then
        local item = items[1]
        client.request('typeHierarchy/supertypes', { item = item }, function(e2, supers)
          if not e2 and supers and vim.tbl_islist(supers) then
            local list = {}
            local seen = {}
            for _, it in ipairs(supers) do
              -- SymbolKind.Interface = 11
              if it.kind == 11 then
                local disp = fmt_iface_name(it.name, it.uri)
                if not seen[disp] then
                  table.insert(list, disp)
                  seen[disp] = true
                end
              end
            end
            if #list > 0 then
              any_hierarchy = true
              map_struct_to_ifaces[s.name] = list
            end
          end
          pending = pending - 1
          if pending == 0 then
            on_all_structs_done()
          end
        end, bufnr)
      else
        -- Could not prepare hierarchy for this struct
        pending = pending - 1
        if pending == 0 then
          on_all_structs_done()
        end
      end
    end, bufnr)
  end
end

function M.setup()
  -- Create user command
  vim.api.nvim_create_user_command('StructImplementsRefresh', function()
    M.refresh(0)
  end, { desc = 'Refresh Go struct implements annotations' })

  -- Auto refresh on LSP attach, BufEnter, and write
  local aug = vim.api.nvim_create_augroup('StructImplements', { clear = true })
  vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost' }, {
    group = aug,
    callback = function(args)
      if is_go_buffer(args.buf) then
        -- defer to allow gopls to warm up
        vim.defer_fn(function()
          M.refresh(args.buf)
        end, 100)
      end
    end,
  })

  vim.api.nvim_create_autocmd('LspAttach', {
    group = aug,
    callback = function(args)
      local bufnr = args.buf
      if is_go_buffer(bufnr) and get_gopls_client(bufnr) then
        vim.defer_fn(function()
          M.refresh(bufnr)
        end, 200)
      end
    end,
  })
end

return M
