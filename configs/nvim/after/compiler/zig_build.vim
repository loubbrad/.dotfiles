" Vim compiler file
" Compiler: Zig Compiler (zig build)

let s:save_cpo = &cpo
set cpo&vim

CompilerSet errorformat=%f:%l:%c:\ %trror:\ %m,%f:%l:%c:\ %tarning:\ %m,%f:%l:%c:\ %m,%-G%.%#

let &cpo = s:save_cpo
unlet s:save_cpo
