" Vim syntax file
" Language:        git commit messages following GNU standards
" Author:          Stefano Lattarini <stefano.lattarini@gmail.com>
" Maintainer:      Stefano Lattarini <stefano.lattarini@gmail.com>
" Last Change:     December 28, 2011

syn match gitlogFirstLine  "\%^..*"  nextgroup=gitlogExtraBlank skipnl
syn match gitlogSummary    "^.\{0,50\}" contained containedin=gitlogFirstLine nextgroup=gitlogOverflow
syn match gitlogExtraBlank "^..*" contained

syn region gitlogFiles start="^[+*]\s" end=":" end="^$" contains=gitlogExtraChars,gitlogBullet,gitlogColon,gitlogFuncs keepend
syn region gitlogFiles start="^[([]" end=":" end="^$" keepend contains=gitlogExtraChars
syn match gitlogFuncs  contained "(.\{-})" extend
syn match gitlogFuncs  contained "\[.\{-}]" extend
syn match gitlogColon  contained ":"
syn match gitlogBullet contained "^[+*]\s"

"Flag items beyond column 76
syn match gitlogExtraChars excludenl "^.\{76,}$"lc=76

" Define the default highlighting.
command -nargs=+ HiLink hi def link <args>
HiLink gitlogSummary Keyword
HiLink gitlogBullet     Type
HiLink gitlogColon      Type
HiLink gitlogFiles      Comment
HiLink gitlogFuncs      Comment
HiLink gitlogHeader     Statement
HiLink gitlogExtraBlank Error
HiLink gitlogExtraChars Todo
delcommand HiLink

let b:current_syntax = "vcs-changelog"

" vim: ts=8
