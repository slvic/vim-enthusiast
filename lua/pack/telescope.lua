localgetGoModDirs = function()
  local handle = io.popen 'go list -f "{{ .Dir }}" -m all 2>/dev/null'
  if not handle then
    return
  end

  local result = handle:read '*a'
  handle:close()

  if not result or result == '' then
    return
  end

  local dirs = {}
  local seen = {}
  for dir in result:gmatch '[^\r\n]+' do
    if not seen[dir] then
      table.insert(dirs, dir)
      seen[dir] = true
    end
  end
  return dirs
end

return function()
  -- Add dependencies
  vim.pack.add({
    { src = 'https://github.com/nvim-lua/plenary.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope-fzf-native.nvim' },
    { src = 'https://github.com/nvim-telescope/telescope-ui-select.nvim' },
  }, { load = true })
  --
  vim.pack.add({
    { src = 'https://github.com/nvim-telescope/telescope.nvim' },
  }, { load = true })

  require('telescope').setup {
    pickers = {
      live_grep = { theme = 'dropdown' },
      find_files = {
        hidden = true,
        theme = 'dropdown',
        previewer = false,
        file_ignore_patterns = { '%.git/' },
      },
      buffers = {
        mappings = {
          n = { ['<C-d>'] = require('telescope.actions').delete_buffer },
        },
        sort_mru = true,
        sort_lastused = true,
        initial_mode = 'normal',
        theme = 'ivy',
      },
    },
    extensions = {
      ['ui-select'] = { require('telescope.themes').get_dropdown() },
    },
  }

  pcall(require('telescope').load_extension, 'fzf')
  pcall(require('telescope').load_extension, 'ui-select')

  local builtin = require 'telescope.builtin'
  vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
  vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
  vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
  vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
  vim.keymap.set('n', '<leader>gg', builtin.git_status, { desc = 'Find [G]iT Status' })
  vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Find [G]iT [B]ranches' })
end
