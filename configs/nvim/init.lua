vim.opt.termguicolors = true
vim.o.number = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.g.mapleader = " "

vim.cmd('colorscheme torte')
vim.api.nvim_set_hl(0, "StatusLine", { link = "Normal" })
vim.api.nvim_set_hl(0, "StatusLineNC", { link = "Normal" })

vim.opt.colorcolumn = "80"
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2a2a2a" }) 

-- Cache history
local undo_dir = vim.fn.stdpath('cache') .. '/undo'

-- NOTE: 0700 (octal) ~ 448 (decimal)
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p", 448)
end

vim.opt.undodir = undo_dir
vim.opt.undofile = true
vim.opt.undolevels = 100

-- Window qol
vim.opt.fillchars = {vert = " "}
vim.opt.splitright = true
vim.opt.laststatus = 3
vim.keymap.set('n', '<leader>w', '<C-w>', { noremap = true })

-- Paste without overwriting register
vim.keymap.set('x', '<leader>p', '"_dP')

-- Yank to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y')

-- Delete to black hole register
vim.keymap.set({'n', 'v'}, '<leader>d', '"_d')

-- Center after jump
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')


vim.keymap.set('n', '<M-j>', '<cmd>cnext<CR>')
vim.keymap.set('n', '<M-k>', '<cmd>cprev<CR>')

-- Swap search word-direction keys
vim.keymap.set('n', '*', '#')
vim.keymap.set('n', '#', '*')
vim.keymap.set('n', 'g*', 'g#')
vim.keymap.set('n', 'g#', 'g*')

-- Save without opening as sudo
vim.cmd('cmap w!! %!sudo tee > /dev/null %')

-- Send "+ to system clipboard through ssh
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
  },
  paste = {
    ['+'] = function() return {} end,
  },
}

-- Open new window commands
function _G.smart_split_action(callback)
  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_pos = vim.api.nvim_win_get_cursor(0)

  if vim.fn.winnr('$') == 1 then
    vim.cmd('vsplit')
  else
    vim.cmd('wincmd w') 
  end

  vim.api.nvim_set_current_buf(curr_buf)
  vim.api.nvim_win_set_cursor(0, curr_pos)

  callback()
end

vim.keymap.set('n', '<leader>gd', function()
  _G.smart_split_action(function() vim.cmd('normal! gd') end)
end)

vim.keymap.set('n', '<leader>#', function()
  _G.smart_split_action(function() vim.cmd('normal! *') end)
end)

vim.keymap.set('n', '<leader>/', function()
  _G.smart_split_action(function()
    vim.api.nvim_feedkeys('/', 'n', false)
  end)
end)

-- Plugins
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'

if not vim.loop.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  })
  vim.cmd('packadd mini.nvim | helptags ALL')
end

vim.cmd('packadd mini.nvim')

require('mini.deps').setup({ path = { package = path_package } })
require('plug.lsp')
require('plug.fzf')
require('plug.oil')

