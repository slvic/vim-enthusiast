vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.api.nvim_set_hl(0, 'YankHighlight', { fg = '#000000', bg = '#FFC0CB', bold = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank {
      higroup = 'YankHighlight',
      timeout = 50,
    }
  end,
})

require 'configs.opts'
require 'configs.keymaps'

require 'pack.misc'
require 'pack.telescope'
require 'pack.lsp'
require 'pack.neo-tree'
require 'pack.gitsigns'
require 'pack.which-key'
require 'pack.treesitter'

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
