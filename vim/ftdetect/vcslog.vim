" -*- vim -*-
" Vim extension to detect file types.
"
" This file should be called by $VIMRUNTIME/filetype.vim after he tried to
" (and maybe succeded in) determine the filetype; but it will anyway be
" kind enough to let use override its decision

" Files used by me to keep commit messages used by VCS.
au BufNewFile,BufRead  chlog.msg,chlog.msg[0-9]  setf vcs-changelog
au BufNewFile,BufRead  git.msg,git.msg[0-9]      setf vcs-changelog
au BufNewFile,BufRead  hg.msg,hg.msg[0-9]        setf vcs-changelog
au BufNewFile,BufRead  svn.msg,svn.msg[0-9]      setf vcs-changelog
