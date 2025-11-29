" Pretty colours
set termguicolors

" Set leader key to space
let mapleader = " "

" Paste without overwriting register
xnoremap <leader>p "_dP

" Yank to system clipboard
nnoremap <leader>y "+y
vnoremap <leader>y "+y
nnoremap <leader>Y "+Y

" Delete to black hole register
nnoremap <leader>d "_d
vnoremap <leader>d "_d

" Center after jump
nnoremap <C-u> <C-u>zz
nnoremap <C-d> <C-d>zz

" Swap search word-direction keys
nnoremap * #
nnoremap # *
nnoremap g* g#
nnoremap g# g*

" Open new window commands
set splitright

nnoremap <leader>gd <cmd>lua
\ local curr_buf = vim.api.nvim_get_current_buf()
\ local curr_pos = vim.api.nvim_win_get_cursor(0)
\ if vim.fn.winnr('$') == 1 then vim.cmd('vsplit') else vim.cmd('normal! <C-w>w') end
\ vim.api.nvim_set_current_buf(curr_buf)
\ vim.api.nvim_win_set_cursor(0, curr_pos)
\ vim.cmd('normal! gd')<CR>

nnoremap <leader># <cmd>lua
\ local curr_buf = vim.api.nvim_get_current_buf()
\ local curr_pos = vim.api.nvim_win_get_cursor(0)
\ if vim.fn.winnr('$') == 1 then vim.cmd('vsplit') else vim.cmd('normal! <C-w>w') end
\ vim.api.nvim_set_current_buf(curr_buf)
\ vim.api.nvim_win_set_cursor(0, curr_pos)
\ vim.cmd('normal! *')<CR>

nnoremap <leader>/ <cmd>lua
\ local curr_buf = vim.api.nvim_get_current_buf()
\ local curr_pos = vim.api.nvim_win_get_cursor(0)
\ if vim.fn.winnr('$') == 1 then vim.cmd('vsplit') else vim.cmd('normal! <C-w>w') end
\ vim.api.nvim_set_current_buf(curr_buf)
\ vim.api.nvim_win_set_cursor(0, curr_pos)
\ vim.api.nvim_feedkeys('/', 'n', false)<CR>

