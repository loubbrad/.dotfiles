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
