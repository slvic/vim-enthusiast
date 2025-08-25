return {
  'NeogitOrg/neogit',
  dependencies = {
    'nvim-lua/plenary.nvim', -- Required dependency
    'sindrets/diffview.nvim', -- Optional: for diff integration
    'nvim-telescope/telescope.nvim', -- Optional: for Telescope integration
  },
  opts = {
    auto_close_console = false,
    integrations = {
      telescope = true,
      diffview = true,
    },
  },
  config = function()
    require('neogit').setup {
      mappings = {
        commit_editor = {
          ['<C-p>'] = 'PrevMessage', -- remap to CTRL-p
          ['<C-n>'] = 'NextMessage',
          ['<A-r>'] = 'ResetMessage',
        },
      },
    }
    local neogit = require 'neogit'
    vim.keymap.set('n', '<leader>gs', function()
      neogit.open()
    end, { desc = 'Neogit: Git status' })
    vim.keymap.set('n', '<leader>gc', function()
      neogit.open { 'commit' }
    end, { desc = 'Neogit: Git commit' })
    vim.keymap.set('n', '<leader>gp', function()
      neogit.open { 'pull' }
    end, { desc = 'Neogit: Git Pull' })
    vim.keymap.set('n', '<leader>gP', function()
      neogit.open { 'push' }
    end, { desc = 'Neogit: Git Push' })
  end,
}
