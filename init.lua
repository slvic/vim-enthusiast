vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Ensure packpath includes the site directory for vim.pack
vim.opt.packpath:prepend(vim.fn.stdpath 'data' .. '/site')

-- deps

--

vim.pack.add { 'https://github.com/NMAC427/guess-indent.nvim' } -- Detect tabstop and shiftwidth automatically
vim.pack.add({ 'https://github.com/windwp/nvim-autopairs' }, {
  event = 'InsertEnter',
})
vim.pack.add({ 'https://github.com/catppuccin/nvim' }, {
  name = 'catppuccin',
  priority = 1000, -- Ensure it loads before other plugins
  opts = {
    flavour = 'frappe',
  },
})
vim.cmd.colorscheme 'catppuccin' -- Load the colorscme immediately
vim.pack.add({ 'https://github.com/folke/todo-comments.nvim' }, {
  event = 'VimEnter',
  dependencies = { 'https://github.com/nvim-lua/plenary.nvim' },
  opts = { signs = false },
})

vim.pack.add( -- Collection of various small independent plugins/modules
  { 'https://github.com/nvim-mini/mini.nvim' },
  {
    config = function()
      require('mini.ai').setup { n_lines = 500 }

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }

      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end
    end,
  }
)

-- Set to true if you have a Nerd Font installed and selected in the terminal
vim.g.have_nerd_font = true

require 'configs.opts'
require 'configs.keymaps'
require 'pack.telescope'()
require 'plugins.neo-tree'()

-- vim.api.nvim_create_autocmd('TextYankPost', {
--   desc = 'Highlight when yanking (copying) text',
--   group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
--   callback = function()
--     vim.hl.on_yank()
--   end,
-- })

-- local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
-- if not (vim.uv or vim.loop).fs_stat(lazypath) then
--   local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
--   local out = vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
--   if vim.v.shell_error ~= 0 then
--     error('Error cloning lazy.nvim:\n' .. out)
--   end
-- end

-- ---@type vim.Option
-- local rtp = vim.opt.rtp
-- rtp:prepend(lazypath)
-- -- NOTE: Here is where you install your plugins.
-- require('lazy').setup({
--   { import = 'plugins' },
-- }, {
--   ui = {
--     icons = vim.g.have_nerd_font and {} or {
--       cmd = '⌘',
--       config = '🛠',
--       event = '📅',
--       ft = '📂',
--       init = '⚙',
--       keys = '🗝',
--       plugin = '🔌',
--       runtime = '💻',
--       require = '🌙',
--       source = '📄',
--       start = '🚀',
--       task = '📌',
--       lazy = '💤 ',
--     },
--   },
--   performance = {
--     reset_packpath = false, -- Don't reset packpath, needed for vim.pack
--     rtp = {
--       reset = false, -- Don't reset runtimepath, needed for vim.pack
--     },
--   },
-- })

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
