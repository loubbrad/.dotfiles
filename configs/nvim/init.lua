vim.opt.termguicolors = true
vim.o.number = true
vim.opt.wrap = false
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.inccommand = "nosplit"
vim.opt.diffopt = "internal,filler,closeoff,vertical,algorithm:histogram,indent-heuristic,linematch:60"
vim.opt.autoread = true
vim.g.mapleader = " "

vim.opt.spell = true
vim.opt.spelllang = "en_us"
vim.opt.spelloptions = "camel"

vim.opt.colorcolumn = "80"
vim.api.nvim_set_hl(0, "ColorColumn", { bg = "#2a2a2a" }) 
vim.api.nvim_set_hl(0, "WinSeparator", { fg = "#444444" })

require('color').setup()
require('statusline').setup()
require('commands').setup()

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

vim.keymap.set('n', '<leader>gq', 'vipgq', { remap = true }) 

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

vim.keymap.set("n", "<leader>md", ":delmarks ")
vim.keymap.set("n", "<leader>mD", "<cmd>delmarks a-zA-Z<cr>")

-- Center after jump
vim.keymap.set('n', '<C-u>', '<C-u>zz')
vim.keymap.set('n', '<C-d>', '<C-d>zz')
vim.keymap.set('n', 'n', 'nzz')
vim.keymap.set('n', 'N', 'Nzz')

-- Quick fix list
vim.keymap.set('n', '<C-j>', '<cmd>cnext<CR>zz')
vim.keymap.set('n', '<C-k>', '<cmd>cprev<CR>zz')
vim.keymap.set('n', '[q', '<cmd>colder<CR>', { desc = 'Older quickfix list' })
vim.keymap.set('n', ']q', '<cmd>cnewer<CR>', { desc = 'Newer quickfix list' })
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

-- Recursive for lsp keymap
vim.keymap.set('n', '<leader>gd', function()
  require('commands').smart_split_action(function() vim.cmd('normal gd') end)
end)

vim.keymap.set('n', '<leader>gf', function()
  require('commands').smart_split_action(function() vim.cmd('normal! gf') end)
end)

vim.keymap.set('n', '<leader>#', function()
  require('commands').smart_split_action(function() vim.cmd('normal! *') end)
end)

-- Plugins
vim.api.nvim_create_autocmd('PackChanged', {
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name ~= 'nvim-treesitter' then
      return
    end

    if kind ~= 'install' and kind ~= 'update' then
      return
    end

    if not ev.data.active then
      vim.cmd.packadd(name)
    end

    vim.schedule(function()
      local ok, err = pcall(vim.cmd, 'TSUpdate')
      if not ok then
        vim.notify('nvim-treesitter changed, but TSUpdate failed: ' .. err, vim.log.levels.WARN)
      end
    end)
  end,
})

require('plugin.git')
require('plugin.treesitter')
require('plugin.oil')
require('plugin.format')
require('plugin.lsp')
require('plugin.fzf')
