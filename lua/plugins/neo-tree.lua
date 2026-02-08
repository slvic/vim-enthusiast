-- Neo-tree is a Neovim plugin to browse the file system
-- https://github.com/nvim-neo-tree/neo-tree.nvim

return function() 

  vim.pack.add( {
    { src = 'https://github.com/nvim-lua/plenary.nvim'},
    { src = 'https://github.com/nvim-tree/nvim-web-devicons'},
    {src = 'https://github.com/MunifTanjim/nui.nvim'}
  })

vim.pack.add({
	{src = 'https://github.com/nvim-neo-tree/neo-tree.nvim'}
  }, {load = true})

  require('neo-tree').setup{
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
          ['Y'] = function(state)
            -- NeoTree is based on [NuiTree](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree)
            -- The node is based on [NuiNode](https://github.com/MunifTanjim/nui.nvim/tree/main/lua/nui/tree#nuitreenode)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local filename = node.name
            local modify = vim.fn.fnamemodify

            local results = {
              filepath,
              modify(filepath, ':.'),
              modify(filepath, ':~'),
              filename,
              modify(filename, ':r'),
              modify(filename, ':e'),
            }

            -- absolute path to clipboard
            local i = vim.fn.inputlist {
              'Choose to copy to clipboard:',
              '1. Absolute path: ' .. results[1],
              '2. Path relative to CWD: ' .. results[2],
              '3. Path relative to HOME: ' .. results[3],
              '4. Filename: ' .. results[4],
              '5. Filename without extension: ' .. results[5],
              '6. Extension of the filename: ' .. results[6],
            }

            if i > 0 then
              local result = results[i]
              if not result then
                return print('Invalid choice: ' .. i)
              end
              vim.fn.setreg('"', result)
              vim.notify('Copied: ' .. result)
            end
          end,
        },
      },
    },
  },
  }
  end
