vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter' },
}, { load = true })

require('nvim-treesitter.config').setup {
  ensure_installed = { 'go', 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'vim', 'vimdoc', 'php', 'yaml' },
  auto_install = true,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = {},
  },
  indent = { enable = true, disable = {} },
}
