MiniDeps.add('nvim-treesitter/nvim-treesitter')
require('nvim-treesitter.configs').setup({
  ensure_installed = { "python", "lua", "bash" },
  highlight = { enable = true },
})

-- This manual install fixes things...
-- rm -rf ~/.local/share/nvim/site/pack/deps/start/nvim-treesitter
-- git clone https://github.com/nvim-treesitter/nvim-treesitter ~/.local/share/nvim/site/pack/deps/start/nvim-treesitter
-- cd ~/.local/share/nvim/site/pack/deps/start/nvim-treesitter
-- git checkout v0.9.2

