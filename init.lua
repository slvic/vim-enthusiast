vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

require 'configs.opts'
require 'configs.keymaps'

require 'pack.misc'
require 'pack.telescope'
require 'pack.lsp'
require 'pack.neo-tree'
require 'pack.gitsigns'
require 'pack.which-key'
require 'pack.treesitter'
require 'pack.dap'

vim.pack.add {
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
}
vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp' },
}, { load = true })

require('blink.cmp').setup {
  keymap = { preset = 'default' },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = false },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  fuzzy = {
    implementation = 'prefer_rust_with_warning',
  },
}
-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
