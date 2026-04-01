vim.pack.add({
  { src = 'https://github.com/milanglacier/minuet-ai.nvim' },
}, {
  load = true,
  dependencies = { 'https://github.com/nvim-lua/plenary.nvim', 'https://github.com/saghen/blink.cmp' },
})

require('minuet').setup({
  provider = 'openai_fim_compatible',
  provider_options = {
    openai_fim_compatible = {
      model = 'qwen2.5-coder:7b',
      end_point = 'http://localhost:11434/v1/completions',
      api_key = 'TERM',
      name = 'Ollama',
      stream = true,
      optional = {
        max_tokens = 256,
        top_p = 0.9,
        stop = { '<|endoftext|>', '<|fim_prefix|>', '<|fim_middle|>', '<|fim_suffix|>', '<|fim_pad|>' },
      },
    },
  },
  n_completions = 3,
  context_window = 4096,
  request_timeout = 3,
  throttle = 1000,
  debounce = 200,
})
