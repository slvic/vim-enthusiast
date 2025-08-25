-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return {
  'nvim-neo-tree/neo-tree.nvim',
  version = '*',
  cmd = { 'Neotree' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    'MunifTanjim/nui.nvim',
  },
  keys = {
    { '\\', ':Neotree reveal<CR>', desc = 'NeoTree reveal', silent = true },
  },
  opts = {
    filesystem = {
      filtered_items = {
        visible = true,
      },
      window = {
        mappings = {
          ['\\'] = 'close_window',
          ['O'] = {
            command = function(state)
              local node = state.tree:get_node()
              local filepath = node.path

              -- open with system default app (nvim 0.10+)
              if vim.ui and vim.ui.open then
                vim.ui.open(filepath)
              else
                -- fallback to OS commands
                local sysname = (vim.uv or vim.loop).os_uname().sysname
                if sysname == 'Darwin' then
                  vim.fn.jobstart({ 'open', filepath }, { detach = true })
                elseif sysname == 'Windows_NT' then
                  vim.fn.jobstart({ 'cmd.exe', '/c', 'start', '', filepath }, { detach = true })
                else
                  vim.fn.jobstart({ 'xdg-open', filepath }, { detach = true })
                end
              end
            end,
            desc = 'open_with_system_defaults',
          },
        },
      },
    },
  },
}
