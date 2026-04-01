vim.pack.add({
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
}, { confirm = false })

local ts = require('nvim-treesitter')
ts.install({ "python", "lua", "bash" }, { summary = false })

vim.api.nvim_create_autocmd('FileType', {
  callback = function(args)
    pcall(vim.treesitter.start, args.buf, args.match)
  end,
})

require('nvim-treesitter-textobjects').setup({
  select = { lookahead = true },
})

local select_obj = require('nvim-treesitter-textobjects.select')
local textobjects = {
  ["af"] = "@function.outer",
  ["if"] = "@function.inner",
  ["ac"] = "@class.outer",
  ["ic"] = "@class.inner",
  ["aa"] = "@parameter.outer",
  ["ia"] = "@parameter.inner",
}
for key, query in pairs(textobjects) do
  vim.keymap.set({"x", "o"}, key, function()
    select_obj.select_textobject(query, "textobjects")
  end)
end
