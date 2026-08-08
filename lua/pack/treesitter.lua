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
