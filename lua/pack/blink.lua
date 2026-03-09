vim.pack.add {
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
}
vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.0' },
}, { load = true })

require('blink.cmp').setup {
  keymap = {
    preset = 'enter',
    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = true },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer' },
  },
  fuzzy = {
    implementation = 'prefer_rust',
  },
}
