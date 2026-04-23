localgetGoModDirs = function()
  local handle = io.popen 'go list -f "{{ .Dir }}" -m all 2>/dev/null'
  if not handle then
    return
  end

  local result = handle:read '*a'
  handle:close()

  if not result or result == '' then
    return
  end

  local dirs = {}
  local seen = {}
  for dir in result:gmatch '[^\r\n]+' do
    if not seen[dir] then
      table.insert(dirs, dir)
      seen[dir] = true
    end
  end
  return dirs
end

-- Add dependencies
vim.pack.add({
  { src = 'https://github.com/nvim-lua/plenary.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
  { src = 'https://github.com/nvim-telescope/telescope-dap.nvim' },
}, { load = true })
--
vim.pack.add({
  { src = 'https://github.com/nvim-telescope/telescope.nvim' },
}, { load = true })

require('telescope').setup {
  pickers = {
    live_grep = { theme = 'dropdown' },
    find_files = {
      hidden = true,
      theme = 'dropdown',
      previewer = false,
      file_ignore_patterns = { '%.git/' },
    },
    buffers = {
      mappings = {
        n = { ['<C-d>'] = require('telescope.actions').delete_buffer },
      },
      sort_mru = true,
      sort_lastused = true,
      initial_mode = 'normal',
      theme = 'ivy',
    },
  },
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
  },
}

pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
pcall(require('telescope').load_extension, 'dap')

local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>gg', builtin.git_status, { desc = 'Find [G]iT Status' })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Find [G]iT [B]ranches' })
vim.keymap.set('n', '<leader>gi', require('telescope.builtin').lsp_implementations, { desc = 'Go to Implementation (Telescope)' })

-- Dynamically get only the dependency paths for the current project
local function get_project_deps_paths()
  local paths = {}
  -- "go list -m -f {{.Dir}} all" returns absolute paths for all modules in go.mod
  local handle = io.popen 'go list -m -f "{{.Dir}}" all 2>/dev/null'
  if handle then
    for line in handle:lines() do
      -- Filter out empty lines (for modules not downloaded) and the main project root
      if line ~= '' and line ~= vim.fn.getcwd() then
        table.insert(paths, line)
      end
    end
    handle:close()
  end
  return paths
end

-- 1. Find Files ONLY in current project's dependencies
local function find_project_go_deps()
  local deps = get_project_deps_paths()
  if #deps == 0 then
    print 'No dependencies found'
    return
  end

  builtin.find_files {
    prompt_title = 'Find Files (Project Deps)',
    search_dirs = deps,
  }
end

-- 2. Live Grep ONLY in current project's dependencies
local function grep_project_go_deps()
  local deps = get_project_deps_paths()
  if #deps == 0 then
    print 'No dependencies found'
    return
  end

  builtin.live_grep {
    prompt_title = 'Live Grep (Project Deps)',
    search_dirs = deps,
  }
end

-- Suggested Keymaps
vim.keymap.set('n', '<leader>Sf', find_project_go_deps, { desc = '[S]earch [f]ile globally in deps' })
vim.keymap.set('n', '<leader>Sg', grep_project_go_deps, { desc = '[S]earch [g]rep globally in deps' })
