return {
  { -- autoformat
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    opts = {
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
    },
  },
  { -- lsp
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      require 'lspconfig'
      vim.lsp.enable 'gopls'

      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local opts = { buffer = args.buf }
          local builtin = require 'telescope.builtin'

          -- Telescope LSP Pickers
          vim.keymap.set('n', 'gd', function()
            builtin.lsp_definitions { initial_mode = 'normal' }
          end, opts)
          vim.keymap.set('n', 'gr', function()
            builtin.lsp_references { initial_mode = 'normal' }
          end, opts)
          vim.keymap.set('n', 'gI', function()
            builtin.lsp_implementations { initial_mode = 'normal' }
          end, opts)
          vim.keymap.set('n', '<leader>ds', builtin.lsp_document_symbols, opts)

          -- Native LSP function (Hover is usually better left native)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
        end,
      })
    end,
  },
}
