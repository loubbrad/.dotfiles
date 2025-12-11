MiniDeps.add('nvim-treesitter/nvim-treesitter')
require('nvim-treesitter.configs').setup({
  ensure_installed = { "python", "lua", "bash" },
  highlight = { enable = true },
})

