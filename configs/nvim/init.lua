vim.opt.termguicolors = true
vim.o.number = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.g.mapleader = " "

vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"

require('color').setup()
vim.opt.colorcolumn = "80"
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2a2a2a" }) 
vim.api.nvim_set_hl(0, "StatusLine", { link = "Normal" })
vim.api.nvim_set_hl(0, "StatusLineNC", { link = "Normal" })
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#444444" })

-- Cache history
local undo_dir = vim.fn.stdpath('cache') .. '/undo'

-- NOTE: 0700 (octal) ~ 448 (decimal)
if vim.fn.isdirectory(undo_dir) == 0 then
  vim.fn.mkdir(undo_dir, "p", 448)
end

vim.opt.undodir = undo_dir
vim.opt.undofile = true
vim.opt.undolevels = 100

vim.diagnostic.config({ signs = false, virtual_text = false })

vim.keymap.set('n', '<C-/>', 'gcc', { remap = true })
vim.keymap.set('n', '<C-_>', 'gcc', { remap = true }) 
vim.keymap.set('x', '<C-/>', 'gc', { remap = true })
vim.keymap.set('x', '<C-_>', 'gc', { remap = true }) 

-- Window qol
vim.opt.fillchars = { vert = "|" }
vim.opt.splitright = true
vim.opt.laststatus = 3
vim.keymap.set('n', ']b', '<cmd>bnext<CR>')
vim.keymap.set('n', '[b', '<cmd>bprev<CR>')
vim.keymap.set('n', '<leader>w', '<C-w>', { noremap = true })
vim.keymap.set('n', '<leader><leader>', '<cmd>wincmd w<CR>')
vim.keymap.set('n', '<leader><Tab>', function()
    pcall(vim.cmd, 'b#')
end)

-- Paste without overwriting register
vim.keymap.set('x', '<leader>p', '"_dP')

-- Yank to system clipboard
vim.keymap.set({'n', 'v'}, '<leader>y', '"+y')

-- Delete to black hole register
vim.keymap.set({'n', 'v'}, '<leader>d', '"_d')

-- Yank current file path
vim.keymap.set("n", "<leader>fp", function()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end)

-- Center after jump
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- Quick fix list
vim.keymap.set('n', '<C-j>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-k>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '<leader>q', function()
  local qf_open = false
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local info = vim.fn.getwininfo(win)[1]
    if info.quickfix == 1 and info.loclist == 0 then
      qf_open = true
      break
    end
  end
  if qf_open then
    vim.cmd('cclose')
  else
    vim.cmd('copen')
  end
end)
vim.keymap.set('n', '<leader>dq', function()
  vim.diagnostic.setqflist({ open = true, bufnr = 0 })
end)
vim.keymap.set('n', '<C-q>', function()
  local ok = pcall(vim.cmd, 'vimgrep // %')
  if ok then
    vim.cmd('copen')
    vim.cmd('noh')
  else
    vim.notify('No previous search pattern', vim.log.levels.WARN)
  end
end)

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
  local curr_win = vim.api.nvim_get_current_win()
  local curr_buf = vim.api.nvim_get_current_buf()
  local curr_pos = vim.api.nvim_win_get_cursor(0)

  local target_win = nil

  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    if win ~= curr_win and vim.bo[buf].filetype ~= 'oil' then
      target_win = win
      break
    end
  end

  if target_win then
    vim.api.nvim_set_current_win(target_win)
  else
    vim.cmd('vsplit')
  end

  vim.api.nvim_set_current_buf(curr_buf)
  vim.api.nvim_win_set_cursor(0, curr_pos)

  callback()
end

vim.keymap.set('n', '<leader>gd', function()
  _G.smart_split_action(function() vim.cmd('normal! gd') end)
end)

vim.keymap.set('n', '<leader>gf', function()
  _G.smart_split_action(function() vim.cmd('normal! gf') end)
end)

vim.keymap.set('n', '<leader>#', function()
  _G.smart_split_action(function() vim.cmd('normal! *') end)
end)

-- Plugins
local path_package = vim.fn.stdpath('data') .. '/site/'
local mini_path = path_package .. 'pack/deps/start/mini.nvim'

if not vim.uv.fs_stat(mini_path) then
  vim.cmd('echo "Installing `mini.nvim`" | redraw')
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/echasnovski/mini.nvim', mini_path
  })
  vim.cmd('packadd mini.nvim | helptags ALL')
end

vim.cmd('packadd mini.nvim')

require('mini.deps').setup({ path = { package = path_package } })
require('plugin.git')
require('plugin.treesitter')
require('plugin.oil')
require('plugin.format')
require('plugin.lsp')
require('plugin.fzf')
require('agents')

