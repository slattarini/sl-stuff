" This is my ~/.vimrc script, valid for -*- vim7 -*- and later
version 7.0
if &cp | set nocp | endif
"let s:cpo_save=&cpo
"set cpo&vim
map! <S-Insert> <MiddleMouse>
map! <xHome> <Home>
map! <xEnd> <End>
map! <S-xF4> <S-F4>
map! <S-xF3> <S-F3>
map! <S-xF2> <S-F2>
map! <S-xF1> <S-F1>
map! <xF4> <F4>
map! <xF3> <F3>
map! <xF2> <F2>
map! <xF1> <F1>
vnoremap p :let current_reg = @"gvdi=current_reg
map <S-Insert> <MiddleMouse>
map <xHome> <Home>
map <xEnd> <End>
map <S-xF4> <S-F4>
map <S-xF3> <S-F3>
map <S-xF2> <S-F2>
map <S-xF1> <S-F1>
map <xF4> <F4>
map <xF3> <F3>
map <xF2> <F2>
map <xF1> <F1>
map <F1> :syntax sync fromstart<CR>
map <F2> u
map <F5> :set tabstop=4<CR>
map <F6> :set tabstop=8<CR>
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . tabpagenr()<CR>
set enc=utf-8 
setlocal spell spelllang=hacking-en
map <F11> :setlocal spell spelllang=hacking-en<CR>
map <F12> :set nospell<CR>
set vb " no beep
set autoindent
set backspace=indent,eol,start
set backupcopy=yes
set helplang=en
set history=50
set hlsearch
set mouse=a
set nofoldenable
set ruler
set showcmd
set showmatch
set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc
set viminfo='20,\"50
set hls is
set number
set tabstop=8
set shiftwidth=4
set shiftround
set expandtab
set modeline
set modelines=6
let is_posix = 1
let highlight_function_name = 1
let python_highlight_numbers = 1
let python_highlight_builtins = 1
let python_highlight_exceptions = 1
if !exists("sl__autocommands_loaded")
  let sl__autocommands_loaded = 1
  au FileType changelog set noet tabstop=8 shiftwidth=8
  au FileType make set noet
  au FileType automake set noet
  au FileType vim set ts=2 sw=2
  au FileType python set ts=4 sw=4
endif
syntax on
" vim: ft=vim ts=2 sw=2 et
