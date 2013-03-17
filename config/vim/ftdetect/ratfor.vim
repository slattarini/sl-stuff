" -*- vim -*-
" Vim extension to detect file types.
"
" This file should be called by $VIMRUNTIME/filetype.vim after he tried to
" (and maybe succeded in) determine the filetype; but it will anyway be
" kind enough to let use override its decision

au BufNewFile,BufRead *.rat,*.rat4 setf ratfor
