" Vim syntax file
" Language:		configure.ac script: M4 with sh
" Maintainer:	Stefano Lattarini <stefano.lattarini@gmail.com>
" Last Change:	2000 Aug 21
" Original author: Christian Hammesr <ch@lathspell.westend.com>
" TODO: polish and make more modular (where needed) and readable (where possible)

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if version < 600
  syntax clear
elseif exists("b:current_syntax")
  finish
endif

" define the config syntax
syn match   ConfigDelimiter    "[();,{}]"
syn match   ConfigShVar        "[a-zA-Z][a-zA-Z0-9_]\ze="
syn match   ConfigQuote		   "[[\]]"
syn match   ConfigOperator     "[=|&\*\+\<\>]"
syn region  ConfigComment   start="\(\<dnl\>\|#\)" end="$" keepend contains=ConfigFixme
syn region  ConfigCPreProcDirLine matchgroup=ConfigCPreProcName start="#\s*\(define\|elif\|else\|endif\|error\|if\|ifdef\|ifndef\|include\|line\|undef\|warning\)\>" end="\(\ze\]\|$\)"
syn match   ConfigSugarMacro   "_\?m4_[a-zA-Z0-9_]*\(\ze[^=]\|$\)"
syn match   ConfigMacroCall    "\(^[ 	]*[A-Z_][A-Z0-9_]*\|\<\(gl\|_\?A[CMHUS]\)_[A-Z0-9_]*\)\>\(\ze[^=]\|$\)"
syn match   ConfigMacroArgRef  "$[0-9@*]"
syn match   ConfigShVarSubst   "[$][_A-Za-z][A-Za-z0-9_]*\|[$][$]\|[$]{[_A-Za-z][A-Za-z0-9_]*\([+-=][^}]*\)\?}" contains=ConfigQuote,ConfigShVarSubst,ConfigShCmdSubst,ConfigQuadrigraph,ConfigDoubleString,ConfigSingleString
syn match   ConfigShVarSet     "\<[A-Za-z_][A-Za-z0-9_]*\ze="
syn match   ConfigShSpecial	   "\\[\\\"\'`$()#]"
syn match   ConfigShSubSpecial "\\[\\\"`]" contained
syn match   ConfigNumber       "[-+]\=\<\d\+\(\.\d*\)\=\>"
syn match   ConfigQuadrigraph      "@\(&t\|<:\|:>\|S|\|%:\)@"
syn keyword ConfigKeyword      if then else elif fi case esac test eval for in do done echo : exit export
syn keyword ConfigShCmd        cat rm cp mv grep sed expr
syn keyword ConfigFixme contained TODO FIXME XXX
"syn region  ConfigACMsgCheck matchgroup=ConfigMacroCall start="\s*\<AC_MSG_\(CHECKING\|RESULT\)(" matchgroup=ConfigMacroCall end=")" contains=ConfigQuote,ConfigShVarSubst,ConfigShCmdSubst,ConfigShSubSpecial,ConfigQuadrigraph
syn region  ConfigACMsgErr matchgroup=ConfigMacroCall start="\s*\<AC_MSG_\(ERROR\|WARN\(ING\)\?\|NOTICE\|CHECKING\|CHECKING\)(" matchgroup=ConfigMacroCall end=")" contains=ConfigQuote,ConfigQuadrigraph,ConfigMacroArgRef
syn region  ConfigACDefine matchgroup=ConfigMacroCall start="\s*\<AC_DEFINE(" matchgroup=ConfigMacroCall end=")" contains=ConfigQuote,ConfigQuadrigraph,ConfigMacroArgRef
syn region  ConfigASHelpStr matchgroup=ConfigMacroCall start="\s*\<A[CS]_HELP_STRING(" matchgroup=ConfigMacroCall end=")" contains=ConfigQuote,ConfigQuadrigraph,ConfigMacroArgRef
"XXX: This make more harm or more good?
syn region  EmbeddedCCode start="[[][[]" end="]]"
syn region  ConfigDoubleString start=+"+ skip=+\\\\\|\\"+ end=+"+ contains=ConfigQuote,ConfigMacroCall,ConfigShVarSubst,ConfigShCmdSubst,ConfigShSpecial,ConfigMacroArgRef
syn region  ConfigSingleString start=+'+ end=+'+  contains=ConfigQuote,ConfigMacroCall,ConfigMacroArgRef
syn region  ConfigShCmdSubst   start=+`+ skip=+\\\\\|\\`+ end=+`+ contains=ConfigQuote,ConfigMacroCall,ConfigShVarSubst,ConfigSingleString,ConfigDoubleString,ConfigKeyword,ConfigShSpecial,ConfigShCmd,ConfigMacroArgRef

"***:
"***: Cannibalized from sh.vim (with many simplifications)
"***.
if v:version > 602 || (v:version == 602 && has("patch219"))
  syn region ConfigHereDoc start="\(<<\s*\\\=\z(\S*\)\)\@="				matchgroup=ConfigRedir end="^\z1$"		keepend
  syn region ConfigHereDoc start="\(<<\s*\"\z(\S*\)\"\)\@="				matchgroup=ConfigRedir end="^\z1$""		keepend
  syn region ConfigHereDoc start="\(<<\s*'\z(\S*\)'\)\@="				matchgroup=ConfigRedir end="^\z1$""		keepend
  syn region ConfigHereDoc start="\(<<\s*\\\_$\_s*\z(\S*\)\)\@="		matchgroup=ConfigRedir end="^\z1$""		keepend
  syn region ConfigHereDoc start="\(<<\s*\\\_$\_s*\"\z(\S*\)\"\)\@="	matchgroup=ConfigRedir end="^\z1$""		keepend
  syn region ConfigHereDoc start="\(<<\s*\\\_$\_s*'\z(\S*\)'\)\@="		matchgroup=ConfigRedir end="^\z1$"		keepend
  syn region ConfigHereDoc start="\(<<-\s*\z(\S*\)\)\@="				matchgroup=ConfigRedir end="^\s*\z1$"	keepend
  syn region ConfigHereDoc start="\(<<-\s*\"\z(\S*\)\"\)\@="			matchgroup=ConfigRedir end="^\s*\z1$""	keepend
  syn region ConfigHereDoc start="\(<<-\s*'\z(\S*\)'\)\@="				matchgroup=ConfigRedir end="^\s*\z1$""	keepend
  syn region ConfigHereDoc start="\(<<-\s*\\\_$\_s*'\z(\S*\)'\)\@="		matchgroup=ConfigRedir end="^\s*\z1$"	keepend
  syn region ConfigHereDoc start="\(<<-\s*\\\_$\_s*\z(\S*\)\)\@="		matchgroup=ConfigRedir end="^\s*\z1$"	keepend
  syn region ConfigHereDoc start="\(<<-\s*\\\_$\_s*\"\z(\S*\)\"\)\@="	matchgroup=ConfigRedir end="^\s*\z1$"	keepend
else
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<\s*\\\=\z(\S*\)"				matchgroup=ConfigRedir end="^\z1$"  
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<\s*\"\z(\S*\)\""				matchgroup=ConfigRedir end="^\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<-\s*\z(\S*\)"				matchgroup=ConfigRedir end="^\s*\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<-\s*'\z(\S*\)'"				matchgroup=ConfigRedir end="^\s*\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<\s*'\z(\S*\)'"				matchgroup=ConfigRedir end="^\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<-\s*\"\z(\S*\)\""			matchgroup=ConfigRedir end="^\s*\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<\s*\\\_$\_s*\z(\S*\)"		matchgroup=ConfigRedir end="^\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<-\s*\\\_$\_s*\z(\S*\)"		matchgroup=ConfigRedir end="^\s*\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<-\s*\\\_$\_s*'\z(\S*\)'"		matchgroup=ConfigRedir end="^\s*\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<\s*\\\_$\_s*'\z(\S*\)'"		matchgroup=ConfigRedir end="^\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<\s*\\\_$\_s*\"\z(\S*\)\""	matchgroup=ConfigRedir end="^\z1$"
  syn region ConfigHereDoc matchgroup=ConfigRedir start="<<-\s*\\\_$\_s*\"\z(\S*\)\""	matchgroup=ConfigRedir end="^\s*\z1$"
 endif

" Define the default highlighting.
" For version 5.7 and earlier: only when not done already
" For version 5.8 and later: only when an item doesn't have highlighting yet
if version >= 508 || !exists("did_config_syntax_inits")
  if version < 508
    let did_config_syntax_inits = 1
    command -nargs=+ HiLink hi link <args>
  else
    command -nargs=+ HiLink hi def link <args>
  endif

  HiLink ConfigFixme        Todo
  HiLink ConfigDelimiter    Delimiter
  HiLink ConfigQuote        Delimiter
  HiLink ConfigShVarSubst   Include
  HiLink ConfigShVarSet     Function
  HiLink ConfigShCmdSubst   Delimiter "XXX
  HiLink ConfigOperator     Operator
  HiLink ConfigComment      Comment
  HiLink ConfigCPreProcDirLine None
  HiLink ConfigCPreProcName Include
  HiLink ConfigSugarMacro   Function
  HiLink ConfigMacroCall    Type
  HiLink ConfigMacroArgRef  Delimiter
  HiLink ConfigQuadrigraph  Type
  HiLink EmbeddedCCode      None
  HiLink ConfigNumber       Number
  HiLink ConfigKeyword      Keyword
  HiLink ConfigShCmd        Keyword
  HiLink ConfigShSubSpecial Special
  HiLink ConfigShSpecial	Special
  HiLink ConfigSpecial      Delimiter
  HiLink ConfigDoubleString String
  HiLink ConfigSingleString String
  HiLink ConfigRedir		Operator
  HiLink ConfigBeginHere	Operator
  HiLink ConfigHereDoc		String
  HiLink ConfigACMsgErr     String
  HiLink ConfigACDefine     String
  HiLink ConfigASHelpStr    String
  HiLink ConfigACMsgCheck   String

  delcommand HiLink
endif

let b:current_syntax = "config"

" vim: ts=4
