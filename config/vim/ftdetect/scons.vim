" -*- vim -*-
" Vim extension to detect file types.
"
" This file should be called by $VIMRUNTIME/filetype.vim after he tried to
" (and maybe succeded in) determine the filetype; but it will anyway be
" kind enough to let use override its decision

" SConstruct and SConscript are like python
au BufNewFile,BufRead SConstruct,SConscript,sconstruct,sconscript
  \ setf python
