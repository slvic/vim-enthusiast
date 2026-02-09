vim.pack.add({
  { src = 'https://github.com/mfussenegger/nvim-dap' },
  { src = 'https://github.com/nvim-neotest/nvim-nio' },
  { src = 'https://github.com/rcarriga/nvim-dap-ui' },
  { src = 'https://github.com/leoluz/nvim-dap-go' },
}, { load = true })

require('dap-go').setup()
local flags = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>ds', ':lua require("dap").continue()<cr>', flags)
vim.api.nvim_set_keymap('n', '<leader>db', ':lua require("dap").toggle_breakpoint()<cr>', flags)
vim.api.nvim_set_keymap('n', '<leader>dt', ':lua require("dapui").toggle()<cr>', flags)

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
        { id = 'breakpoints', size = 0.30 },
        { id = 'scopes', size = 0.45 },
        { id = 'watches', size = 0.25 },
      },
      size = 0.30,
      position = 'left',
    },
    {
      elements = {
        'repl',
        'stacks',
      },
      size = 0.30,
      position = 'bottom',
    },
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
}
