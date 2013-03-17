" filetype.vim: Vim support file to detect file types.  This script
" extends the system support script with the same name (which is
" sourced at the end of this file).

" Listen very carefully, I will say this only once.
if exists("sl__did_load_filetypes")
  finish
endif
let sl__did_load_filetypes = 1

augroup filetypedetect

" The mode declarations in emacs-style, e.g.
"   -*- python -*-
" or:
"   -*- Mode: python; -*-
" must take precedence over everything else.

function s:EmacsStyleModeMatching()
  let line1 = getline(1)
  let line2 = getline(2)
  let name = ""
  " Is a file with a '-*- TYPE -*-' directive (a' la' emacs)?
  if line1 =~ "-\*-.*-\*-"
    let name = substitute(
      \ line1,
      \ '^.*-\*-\s*\([mM]ode\s*:\s*\)\?\(.*\)\s*-\*-.*$', '\2',
      \ '')
  elseif line2 =~ "-\*-.*-\*-"
    let name = substitute(
      \ line2,
      \ '^.*-\*-\s*\([mM]ode\s*:\s*\)\?\(.*\)\s*-\*-.*$', '\2',
      \ '')
  endif

  if name != ""
    " Bourne-like shell scripts: bash ksh ksh93
    if name =~ '^\(bash\d*\|ksh\d*\|shell\)\>'
      call SetFileTypeSH(name) " defined in \"global\" filetype.vim

    " csh scripts
    elseif name =~ '^csh\>'
      if exists("g:filetype_csh")
        call SetFileTypeShell(g:filetype_csh)
      else
        call SetFileTypeShell("csh")
      endif

    " tcsh scripts
    elseif name =~ '^tcsh\>'
      call SetFileTypeShell("tcsh")

    " Z shell scripts
    elseif name =~ '^zsh\>'
      setf zsh

    " Ratfor sources
    elseif name =~ '^rat\(for\|4\)\>'
      setf ratfor

    " TCL scripts
    elseif name =~ '^\(tcl\|wish\)\>'
      setf tcl

    " Expect scripts
    elseif name =~ '^expect\>'
      setf expect

    " Makefiles
    elseif name =~ '\(GNUm\|[mM]\)ake\(file\)\?\>'
      setf make

    " Lua
    elseif name =~ '^lua\>'
      setf lua

    " Perl
    elseif name =~ '^perl\d*\>'
      setf perl

    " PHP
    elseif name =~ '^php\d*\>'
      setf php

    " Python
    elseif name =~ '^python\(\d\|\.\)*\>'
      setf python

    " Ruby
    elseif name =~ '^ruby\(\d\|\.\)*\>'
      setf ruby

    " sed
    elseif name =~ '^sed\>'
      setf sed

    " Awk scripts
    elseif name =~ '^[gnm]\?awk\>'
      setf awk

    " Scheme scripts
    elseif name =~ '^scheme'
      setf scheme

    " Vim scripts
    elseif name =~ '^\(vim\|Vim\|VIM\)\(\d\|\.\)*\>'
      setf vim

    " M4
    elseif name =~ '^\(m4\|[aA]utom4te\)\>'
      setf m4

    " Autoconf input
    elseif name =~ '^\([aA]utoconf\)\>'
      setf config

    " Automake input
    elseif name =~ '^\([aA]utomake\)\>'
      setf automake

    endif

  endif

  unlet name line1 line2

endfunc

" Files that are meant to be preprocessed by configure might have
" unusual shebang lines, e.g.
"   #!@PERL@ -w
" (seen in the automake.in script).
" Account for them.
function s:ConfigureInputModeMatching()
  let line1 = getline(1)
  if line1 =~ "^#!"
    let name = substitute(
      \ line1,
      \ '^#!\s*\(\S*\)\($\|\s.*$\)', '\1',
      \ '')

    if name =~ '^@\(\(CONFIG_\|POSIX_\)\?SHELL\|BIN_SH\|SHELL_PATH\)@$'
      call SetFileTypeShell('shell')
    elseif name =~ '^@BASH@$'
      call SetFileTypeSH('bash') " defined in \"global\" filetype.vim
    elseif name =~ '^@PERL@$'
      setf perl
    elseif name =~ '^@PYTHON@$'
      setf python
    elseif name =~ '^@RUBY@$'
      setf ruby
    endif

    unlet name

  endif

  unlet line1

endfunc

au BufNewFile,BufRead *.am setf automake
" Look to emacs-style modelines in *every* file
au BufNewFile,BufRead * call s:EmacsStyleModeMatching()
au BufNewFile,BufRead * call s:ConfigureInputModeMatching()

augroup END

" And now load the global script 'filetype.vim'.
source $VIMRUNTIME/filetype.vim

" vim: ft=vim ts=2 sw=2 et
