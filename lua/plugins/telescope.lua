local getGoModDirs = function()
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

return { -- Fuzzy Finder (files, lsp, etc)
  'nvim-telescope/telescope.nvim',
  cmd = { 'Telescope' },
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },
  },
  config = function()
    require('telescope').setup {
      pickers = {
        live_grep = {
          theme = 'dropdown',
        },
        find_files = { hidden = true, theme = 'dropdown', previewer = false },
        buffers = {
          mappings = {
            n = {
              ['<C-d>'] = require('telescope.actions').delete_buffer,
            },
          },
          sort_mru = true,
          sort_lastused = true,
          initial_mode = 'normal',
          theme = 'ivy',
        },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })
    vim.keymap.set('n', '<leader>gg', builtin.git_status, { desc = 'Find [G]iT Status' })
    vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Find [G]iT [B]ranches' })
    vim.keymap.set('n', '<leader>sG', function()
      builtin.live_grep {
        prompt_title = 'Go Module Files',
        cwd = nil, -- This will be set per entry
        search_dirs = getGoModDirs(),
      }
    end, { desc = '[S]earch in [G]o mod' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
