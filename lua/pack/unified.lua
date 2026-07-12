vim.pack.add({
  { src = 'https://github.com/axkirillov/unified.nvim' },
}, { load = true })
require('unified').setup()

vim.keymap.set('n', ']h', function()
  require('unified.navigation').next_hunk()
end)
vim.keymap.set('n', '[h', function()
  require('unified.navigation').previous_hunk()
end)
