vim.opt.termguicolors = true
vim.o.number = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.g.mapleader = " "

vim.cmd('colorscheme habamax')

-- Cache change history
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

-- Write
vim.keymap.set('n', '<leader>w', ':write<CR>')

-- Paste without overwriting register
vim.keymap.set('x', '<leader>p', '"_dP')

-- Yank to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y')
--- vim.keymap.set('n', '<leader>Y', '"+Y')

-- Delete to black hole register
vim.keymap.set({'n', 'v'}, '<leader>d', '"_d')

-- Center after jump
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')

-- Swap search word-direction keys
vim.keymap.set('n', '*', '#')
vim.keymap.set('n', '#', '*')
vim.keymap.set('n', 'g*', 'g#')
vim.keymap.set('n', 'g#', 'g*')

-- Window navigation
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Save without opening as sudo
vim.cmd('cmap w!! %!sudo tee > /dev/null %')

-- System clipboard through ssh (Requires Neovim 0.10+)
-- RECOVERY NOTE: The 'strings' output had 'vim.ui.clipboard', which is likely a typo.
-- I used the version from your cache which uses the standard 'vim.clipboard.osc52'.
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = function() return {} end,
    ['*'] = function() return {} end,
  },
}

-- Open new window commands
local function smart_split_action(callback)
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
  smart_split_action(function() vim.cmd('normal! gd') end)
end)

vim.keymap.set('n', '<leader>#', function()
  smart_split_action(function() vim.cmd('normal! *') end)
end)

vim.keymap.set('n', '<leader>/', function()
  smart_split_action(function()
    vim.api.nvim_feedkeys('/', 'n', false)
  end)
end)
