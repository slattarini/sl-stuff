set ch=2	     " Make command line two lines high
set mousehide	 " Hide the mouse when typing text

let do_syntax_sel_menu = 1|runtime! synmenu.vim|aunmenu &Syntax.&Show\ filetypes\ in\ menu

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

"set guifont=Courier\ 10\ Pitch\ 14.
set guifont=Bitstream\ Vera\ Sans\ Mono\ 11.
