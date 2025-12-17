MiniDeps.add({
  source = 'nvim-treesitter/nvim-treesitter',
  checkout = 'master',  -- Removing this breaks install
  monitor = 'main',
})
require('nvim-treesitter.configs').setup({
  ensure_installed = { "python", "lua", "bash" },
  highlight = { enable = true },
})

