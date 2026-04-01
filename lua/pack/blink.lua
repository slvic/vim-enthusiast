vim.pack.add {
  { src = 'https://github.com/rafamadriz/friendly-snippets' },
}
vim.pack.add({
  { src = 'https://github.com/saghen/blink.cmp', version = vim.version.range '1.0' },
}, {
  load = true,
  dependencies = { 'https://github.com/milanglacier/minuet-ai.nvim' },
})

require('blink.cmp').setup {
  keymap = {
    preset = 'enter',
    ['<Tab>'] = { 'select_next', 'fallback' },
    ['<S-Tab>'] = { 'select_prev', 'fallback' },
    ['<A-y>'] = require('minuet').make_blink_map(),
  },
  appearance = {
    nerd_font_variant = 'mono',
  },
  completion = {
    documentation = { auto_show = true },
    trigger = { prefetch_on_insert = false },
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'minuet' },
    providers = {
      minuet = {
        name = 'minuet',
        module = 'minuet.blink',
        async = true,
        -- Should match minuet.config.request_timeout * 1000,
        -- since minuet.config.request_timeout is in seconds
        timeout_ms = 3000,
        score_offset = 50, -- Gives minuet higher priority among suggestions
      },
    },
  },
  fuzzy = {
    implementation = 'prefer_rust',
  },
}
