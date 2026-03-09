vim.pack.add { 'https://github.com/NMAC427/guess-indent.nvim' }
vim.pack.add({ 'https://github.com/windwp/nvim-autopairs' }, {
  event = 'InsertEnter',
})
vim.pack.add({ 'https://github.com/catppuccin/nvim' }, {
  name = 'catppuccin',
  priority = 1000,
  opts = {
    flavour = 'frappe',
  },
})
vim.cmd.colorscheme 'catppuccin'
vim.pack.add({ 'https://github.com/folke/todo-comments.nvim' }, {
  event = 'VimEnter',
  dependencies = { 'https://github.com/nvim-lua/plenary.nvim' },
  opts = { signs = false },
})

vim.pack.add({ 'https://github.com/nvim-mini/mini.nvim' }, {
  config = function()
    require('mini.ai').setup { n_lines = 500 }

    local statusline = require 'mini.statusline'
    statusline.setup { use_icons = vim.g.have_nerd_font }

    ---@diagnostic disable-next-line: duplicate-set-field
    statusline.section_location = function()
      return '%2l:%-2v'
    end
  end,
})

vim.pack.add { 'https://github.com/tpope/vim-surround' }
