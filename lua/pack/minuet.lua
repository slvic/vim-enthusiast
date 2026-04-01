vim.pack.add({
  { src = 'https://github.com/milanglacier/minuet-ai.nvim' },
}, {
  load = true,
  dependencies = { 'https://github.com/nvim-lua/plenary.nvim', 'https://github.com/saghen/blink.cmp' },
})

require 'minuet'
