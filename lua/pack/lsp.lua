vim.pack.add({
  { src = 'https://github.com/neovim/nvim-lspconfig' },
}, { load = true })

vim.pack.add({
  { src = 'https://github.com/stevearc/conform.nvim' },
}, { load = true })

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local disable_filetypes = { c = true, cpp = true }
    if disable_filetypes[vim.bo[bufnr].filetype] then
      return nil
    else
      return {
        timeout_ms = 500,
        lsp_format = 'fallback',
      }
    end
  end,
  formatters_by_ft = {
    lua = { 'stylua' },
  },
}

require 'lspconfig'
vim.lsp.enable { 'gopls', 'lua_ls', 'jsonnet_ls', 'ts_ls' }
vim.lsp.config('lua_ls', {
  settings = {
    Lua = {
      workspace = {
        library = vim.api.nvim_get_runtime_file('', true),
      },
    },
  },
})
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    local builtin = require 'telescope.builtin'

    vim.keymap.set('n', 'gd', function()
      builtin.lsp_definitions { initial_mode = 'normal' }
    end, opts)
    vim.keymap.set('n', 'gr', function()
      builtin.lsp_references { initial_mode = 'normal' }
    end, opts)
    vim.keymap.set('n', 'gI', function()
      builtin.lsp_implementations { initial_mode = 'normal' }
    end, opts)
    vim.keymap.set('n', '<leader>gs', builtin.lsp_document_symbols, opts)

    vim.keymap.set({ 'n', 'v' }, '<leader>ga', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<leader>gr', vim.lsp.buf.rename, opts)

    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  end,
})
