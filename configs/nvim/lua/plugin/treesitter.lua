MiniDeps.add({
  source = 'nvim-treesitter/nvim-treesitter',
  checkout = 'main',
  hooks = { post_checkout = function() vim.cmd('TSUpdate') end },
})
local ts = require('nvim-treesitter')
ts.install({ "python", "lua", "bash" }, { summary = false })

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf, args.match)
  end,
})

