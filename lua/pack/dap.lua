---@diagnostic disable: missing-fields
vim.pack.add({
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/leoluz/nvim-dap-go' },
  { src = 'https://github.com/mfussenegger/nvim-dap-python' },
}, { load = true })

require('dap-go').setup {
  dap_configurations = {
    {
      type = 'go',
      name = 'Debug Package (Argumants)',
      request = 'launch',
      program = '${fileDirname}',
      args = require('dap-go').get_arguments,
      outputMode = 'remote',
    },
  },
}

require('dap-python').setup(vim.fn.expand '~/.local/share/nvim-dap-venv/bin/python')

require('dap').adapters.codelldb = {
  type = 'server',
  port = '${port}',
  executable = {
    command = vim.fn.expand '~/.local/share/nvim-dap-adapters/codelldb/adapter/codelldb',
    args = { '--port', '${port}' },
  },
}
require('dap').configurations.rust = {
  {
    name = 'Debug',
    type = 'codelldb',
    request = 'launch',
    program = function()
      return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/target/debug/', 'file')
    end,
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

local flags = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>ds', ':lua require("dap").continue()<cr>', flags)
vim.api.nvim_set_keymap('', '<leader>dd', ':lua require("dap").toggle_breakpoint()<cr>', flags)
vim.api.nvim_set_keymap('n', '<leader>df', ':lua require("dap").toggle_breakpoint(vim.fn.input("Enter condition: "))<cr>', flags)
vim.api.nvim_set_keymap(
  'n',
  '<leader>dF',
  ':lua require("dap").toggle_breakpoint(vim.fn.input("Enter condition: "), vim.fn.input("Enter hit-condition: "))<cr>',
  flags
)
vim.api.nvim_set_keymap('v', '<leader>de', ':lua require("dapui").eval()<cr>', flags)
vim.api.nvim_set_keymap('n', '<leader>de', ':lua require("dapui").eval()<cr>', flags)
vim.api.nvim_set_keymap('n', '<leader>dt', ':lua require("dapui").toggle()<cr>', flags)
vim.api.nvim_set_keymap('n', '<leader>dT', ':lua require("dap-go").debug_test()<cr>', flags)
vim.api.nvim_set_keymap('n', '<leader>dc', ':lua require("dap").run_to_cursor()<cr>', flags)

-- vim.api.nvim_set_keymap('n', '<S-left>', ':lua require("dap").reverse_continue()<cr>', flags)
-- vim.api.nvim_set_keymap('n', '<left>', ':lua require("dap").step_back()<cr>', flags)
vim.api.nvim_set_keymap('n', '<down>', ':lua require("dap").step_into()<cr>', flags)
vim.api.nvim_set_keymap('n', '<right>', ':lua require("dap").step_over()<cr>', flags)
vim.api.nvim_set_keymap('n', '<up>', ':lua require("dap").step_out()<cr>', flags)
vim.api.nvim_set_keymap('n', '<leader>dS', ':lua require("dap").terminate(nil, nil, killDebuggers)<cr>', flags)

vim.api.nvim_set_hl(0, 'Red', { fg = '#ec7f8e', bold = true })
vim.fn.sign_define('DapBreakpoint', { text = '', texthl = 'Red', linehl = '', numhl = 'Red' })
vim.fn.sign_define('DapBreakpointCondition', { text = '󰔶', texthl = 'Red', linehl = '', numhl = 'Red' })
vim.fn.sign_define('DapBreakpointRejected', { text = '', texthl = 'Red', linehl = '', numhl = 'Red' })
vim.fn.sign_define('DapStopped', { text = '', texthl = '', linehl = 'DapStopped', numhl = 'DapStopped' })

require('dapui').setup {
  icons = { expanded = '', collapsed = '' },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = { '<CR>', '<2-LeftMouse>', 'L' },
    open = 'o',
    remove = 'd',
    edit = 'e',
    repl = 'r',
  },
  layouts = {
    {
      elements = {
        { id = 'repl', size = 1 },
      },
      size = 10, -- Height of the bottom tray
      position = 'bottom',
    },
    {
      elements = {
        { id = 'scopes', size = 0.5 },
        { id = 'stacks', size = 0.5 },
      },
      size = 0.3,
      position = 'left',
    },
    floating = {
      max_height = nil, -- These can be integers or a float between 0 and 1.
      max_width = nil, -- Floats will be treated as percentage of your screen.
      border = 'single', -- Border style. Can be 'single', 'double' or 'rounded'
      mappings = {
        close = { 'q', '<Esc>' },
      },
    },
    windows = { indent = 1 },
  },
}
