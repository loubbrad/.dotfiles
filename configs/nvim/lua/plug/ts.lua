MiniDeps.add('nvim-treesitter/nvim-treesitter')

MiniDeps.later(function()
  local ok, ts_configs = pcall(require, 'nvim-treesitter.configs')
  if ok then
    ts_configs.setup({
      ensure_installed = { "python", "lua", "bash" },
      highlight = { enable = true },
    })
    vim.cmd('TSUpdate')
  end
end)

