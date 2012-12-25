" Vim syntax file
" Language: RATFOR (Rational Fortran)
" Maintainer: Patricio Toledo <patoledo@ing.uchile.cl>
" Last Change:dom 08 feb 2004 13:15:15 CLST
" Filenames: *.ratfor, *.r

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
 syntax clear
elseif exists("b:current_syntax")
 finish
endif

" In general, a RATFOR source code can be seen as a normal FORTRAN 77
" source code with some other material
let b:fortran_dialect = "f77"
let b:fortran_fixed_source = 0
let b:fortran_with_cpp = 0
if version < 600
 source <sfile>:p:h/fortran.vim
else
 runtime! syntax/fortran.vim
 unlet b:current_syntax
endif

" Aqui parte lo nuevo
syn case match
syn sync maxlines=200
syn sync minlines=40

let fortran_free_source=1
let fortran_have_tabs=1

syn match fortranComment excludenl "#.*$" contains=@fortranCommentGroup
"syn region ratforComment matchgroup=Comment start="#" end="$" 
syn region ratforMatch matchgroup=Identifier start="(" end=")" contains=ALL fold
syn region ratforMatch matchgroup=Identifier start="{" end="}" contains=ALL fold
syn match ratforColons "[,;:]"
syn match ratforError "[}\])]" 
syn match ratforTab "\t" 

" These are from ratfor official doc
syn match ratforRelation "[~!^]"
syn match ratforRelation "[~!^<>=]="
syn match ratforRelation "[<>]"
syn keyword ratforConditional if else switch
syn keyword ratforLabel case default
syn keyword ratforRepeat do while for repeat until
syn keyword ratforExit break next return
syn keyword ratforPreProc include define

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_ratfor_syntax_inits")
 if version < 508
  let did_ratfor_syntax_inits = 1
  command -nargs=+ HiLink hi link <args>
 else
  command -nargs=+ HiLink hi def link <args>
 endif

 HiLink ratforComment Comment
 HiLink ratforRelation Special
 HiLink ratforColons Special
 HiLink ratforConditional Conditional
 HiLink ratforLabel Label
 HiLink ratforPreProc Identifier
 HiLink ratforKeyword Keyword
 HiLink ratforRepeat Repeat
 HiLink ratforExit Operator
 HiLink ratforError Error

 delcommand HiLink
endif

let b:current_syntax = "ratfor"
