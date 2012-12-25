" Vim syntax file
" Language: Python
" Original Maintainer: Neil Schemenauer <nas@python.ca>
" Maintainer: Stefano Lattarini
" Updated: 2009-02-07
"
" Options to control Python syntax highlighting:
"
" For highlighted numbers:
"
"    let python_highlight_numbers = 1
"
" For highlighted builtin functions:
"
"    let python_highlight_builtins = 1
"
" For highlighted standard exceptions:
"
"    let python_highlight_exceptions = 1
"
" Highlight erroneous whitespace:
"
"    let python_highlight_space_errors = 1
"
" If you want all possible Python highlighting (the same as setting the
" preceding options):
"
"    let python_highlight_all = 1
"

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif


syn keyword pythonStatement    break continue del except exec finally pass print raise
syn keyword pythonStatement    return try global assert lambda yield
syn keyword pythonStatement    def class nextgroup=pythonFunction skipwhite
syn match   pythonFunction     "[a-zA-Z_][a-zA-Z0-9_]*" contained
syn keyword pythonRepeat       for while if elif else
syn keyword pythonOperator     and in is not or
" AS will be a keyword in Python 3
syn keyword pythonPreCondit     import from as
syn match   pythonComment       "#.*$" contains=pythonTodo
syn keyword pythonTodo          TODO FIXME XXX contained

" Decorators (new in Python 2.4)
syn match   pythonDecorator     "@" display nextgroup=pythonFunction skipwhite

" strings
syn region  pythonString        matchgroup=Normal start=+[uU]\='+ end=+'+ skip=+\\\\\|\\'+ contains=pythonEscape
syn region  pythonString        matchgroup=Normal start=+[uU]\="+ end=+"+ skip=+\\\\\|\\"+ contains=pythonEscape
syn region  pythonString        matchgroup=Normal start=+[uU]\="""+ end=+"""+ contains=pythonEscape
syn region  pythonString        matchgroup=Normal start=+[uU]\='''+ end=+'''+ contains=pythonEscape
syn region  pythonRawString     matchgroup=Normal start=+[uU]\=[rR]'+ end=+'+ skip=+\\\\\|\\'+
syn region  pythonRawString     matchgroup=Normal start=+[uU]\=[rR]"+ end=+"+ skip=+\\\\\|\\"+
syn region  pythonRawString     matchgroup=Normal start=+[uU]\=[rR]"""+ end=+"""+
syn region  pythonRawString     matchgroup=Normal start=+[uU]\=[rR]'''+ end=+'''+
syn match   pythonEscape        +\\[abfnrtv'"\\]+ contained
syn match   pythonEscape        "\\\o\{1,3}" contained
syn match   pythonEscape        "\\x\x\{2}" contained
syn match   pythonEscape        "\(\\u\x\{4}\|\\U\x\{8}\)" contained
syn match   pythonEscape        "\\$"

if exists("python_highlight_all")
  let python_highlight_numbers = 1
  let python_highlight_builtins = 1
  let python_highlight_exceptions = 1
  let python_highlight_space_errors = 1
endif

if exists("python_highlight_numbers")
  " numbers (including longs and complex)
  syn match   pythonNumber      "\<0x\x\+[Ll]\=\>"
  syn match   pythonNumber      "\<\d\+[LljJ]\=\>"
  syn match   pythonNumber      "\.\d\+\([eE][+-]\=\d\+\)\=[jJ]\=\>"
  syn match   pythonNumber      "\<\d\+\.\([eE][+-]\=\d\+\)\=[jJ]\=\>"
  syn match   pythonNumber      "\<\d\+\.\d\+\([eE][+-]\=\d\+\)\=[jJ]\=\>"
endif

if exists("python_highlight_builtins")
  " builtin functions, types and objects, not really part of the syntax
  
  syn keyword pythonConstant    False True None NotImplemented 
  
  syn keyword pythonBuiltin     bool enumerate set frozenset help reversed
  syn keyword pythonBuiltin     Ellipsis __import__ abs sorted apply buffer
  syn keyword pythonBuiltin     callable chr classmethod cmp sum coerce compile
  syn keyword pythonBuiltin     complex delattr dict dir divmod eval execfile
  syn keyword pythonBuiltin     file filter float getattr globals hasattr hash
  syn keyword pythonBuiltin     hex id input int intern isinstance issubclass
  syn keyword pythonBuiltin     iter len list locals long map max min object
  syn keyword pythonBuiltin     oct open ord pow property range raw_input
  syn keyword pythonBuiltin     reduce reload repr round setattr slice str
  syn keyword pythonBuiltin     staticmethod super tuple type unichr vars zip
  syn keyword pythonBuiltin     unicode xrange

endif

if exists("python_highlight_exceptions")
  " builtin exceptions and warnings
  syn keyword pythonException   ArithmeticError AssertionError AttributeError
  syn keyword pythonException   DeprecationWarning EOFError EnvironmentError
  syn keyword pythonException   Exception FloatingPointError IOError
  syn keyword pythonException   ImportError IndentationError IndexError
  syn keyword pythonException   KeyError KeyboardInterrupt LookupError
  syn keyword pythonException   MemoryError NameError NotImplementedError
  syn keyword pythonException   OSError OverflowError OverflowWarning
  syn keyword pythonException   ReferenceError RuntimeError RuntimeWarning
  syn keyword pythonException   StandardError StopIteration SyntaxError
  syn keyword pythonException   SyntaxWarning SystemError SystemExit TabError
  syn keyword pythonException   TypeError UnboundLocalError UnicodeError
  syn keyword pythonException   UnicodeEncodeError UnicodeDecodeError
  syn keyword pythonException   UnicodeTranslateError
  syn keyword pythonException   UserWarning ValueError Warning WindowsError
  syn keyword pythonException   ZeroDivisionError
endif

if exists("python_highlight_space_errors")
  " trailing whitespace
  syn match   pythonSpaceError   display excludenl "\S\s\+$"ms=s+1
  " mixed tabs and spaces
  syn match   pythonSpaceError   display " \+\t"
  syn match   pythonSpaceError   display "\t\+ "
endif

" This is fast but code inside triple quoted strings screws it up. It
" is impossible to fix because the only way to know if you are inside a
" triple quoted string is to start from the beginning of the file. If
" you have a fast machine you can try uncommenting the "sync minlines"
" and commenting out the rest.
syn sync match pythonSync grouphere NONE "):$"
syn sync maxlines=200
"syn sync minlines=2000

if version >= 508 || !exists("did_python_syn_inits")
  if version <= 508
    let did_python_syn_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  " The default methods for highlighting.  Can be overridden later
  HiLink pythonStatement        Statement
  HiLink pythonFunction         Function
  HiLink pythonConditional      Conditional
  HiLink pythonRepeat           Repeat
  HiLink pythonString           String
  HiLink pythonRawString        String
  HiLink pythonEscape           Special
  HiLink pythonOperator         Operator
  HiLink pythonPreCondit        PreCondit
  HiLink pythonComment          Comment
  HiLink pythonTodo             Todo
  HiLink pythonDecorator        Define
  if exists("python_highlight_numbers")
    HiLink pythonNumber         Number
  endif
  if exists("python_highlight_builtins")
    HiLink pythonBuiltin        Type
    HiLink pythonConstant       Macro
  endif
  if exists("python_highlight_exceptions")
    HiLink pythonException      Exception
  endif
  if exists("python_highlight_space_errors")
    HiLink pythonSpaceError     Error
  endif

  delcommand HiLink
endif

let b:current_syntax = "python"

" vim: ft=vim ts=4 sw=4 et
