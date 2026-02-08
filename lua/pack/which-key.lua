return function()
  vim.pack.add({
    { src = 'https://github.com/folke/which-key.nvim' },
  }, { load = true })

  require('which-key').setup {
    delay = 0,
    icons = {
      keys = {},
    },
  }
end
