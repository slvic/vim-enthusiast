vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
}, { load = true })
require('nvim-treesitter').setup()
require('nvim-treesitter').install {
  'go',
  'jsonnet',
  'bash',
  'c',
  'diff',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'vim',
  'vimdoc',
  'php',
  'yaml',
  'ocaml',
  'python',
  'rust',
}
vim.api.nvim_create_autocmd('FileType', {
  pattern = {
    'go',
    'jsonnet',
    'bash',
    'c',
    'diff',
    'html',
    'lua',
    'luadoc',
    'markdown',
    'markdown_inline',
    'query',
    'vim',
    'vimdoc',
    'php',
    'yaml',
    'ocaml',
    'python',
    'rust',
  },
  callback = function()
    vim.treesitter.start()
  end,
})

vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter-context' },
}, {
  dependencies = { 'https://github.com/nvim-treesitter/nvim-treesitter' },
})

require('treesitter-context').setup {
  enable = true,
  max_lines = 0,
  min_window_height = 0,
  line_numbers = true,
  multiline_threshold = 20,
  trim_scope = 'outer',
  mode = 'cursor',
  zindex = 20,
}

vim.keymap.set('n', '<leader>tc', function()
  require('treesitter-context').toggle()
end, { desc = '[T]oggle [c]ontext' })
