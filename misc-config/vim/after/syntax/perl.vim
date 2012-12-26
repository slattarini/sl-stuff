" Vim syntax file (extensions)
" Language:     Perl
" Maintainer:   Stefano Lattarini <stefano.lattarini@gmail.com>
" Last Change:  2009-12-29
"
" Sourced after $VIMRUNTIME/syntax/perl.vim, to enable some enhancements


" Recognize also "m,,", "m|||", "m::", "m%%" and "m()" forms of
" pattern matching

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<[m!],+ end=+,[cgimosx]*+
 \ contains=@perlInterpMatch

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<[m!]:+ end=+:[cgimosx]*+
 \ contains=@perlInterpMatch

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<[m!]%+ end=+%[cgimosx]*+
 \ contains=@perlInterpMatch

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<[m!]|+ end=+|[cgimosx]*+
 \ contains=@perlInterpMatch

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<[m!](+ end=+)[cgimosx]*+
 \ contains=@perlInterpMatch


" Recognize also "s,,,", "s|||", "s:::", "s%%%" and "s()()" forms
" of pattern substitution

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<s,+  end=+,+me=e-1
 \ contains=@perlInterpMatch
 \ nextgroup=perlSubstitutionComma
syn region perlSubstitutionComma
 \ matchgroup=perlMatchStartEnd
 \ start=+,+ end=+,[ecgimosx]*+
 \ contained
 \ contains=@perlInterpDQ

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<s|+  end=+|+me=e-1
 \ contains=@perlInterpMatch
 \ nextgroup=perlSubstitutionPipe
syn region perlSubstitutionPipe
 \ matchgroup=perlMatchStartEnd
 \ start=+|+ end=+|[ecgimosx]*+
 \ contained
 \ contains=@perlInterpDQ

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<s%+  end=+%+me=e-1
 \ contains=@perlInterpMatch
 \ nextgroup=perlSubstitutionPercent
syn region perlSubstitutionPercent
 \ matchgroup=perlMatchStartEnd
 \ start=+%+ end=+%[ecgimosx]*+
 \ contained
 \ contains=@perlInterpDQ

syn region perlMatch
 \ matchgroup=perlMatchStartEnd
 \ start=+\<s(+  end=+)+
 \ contains=@perlInterpMatch
 \ nextgroup=perlSubstitutionParens
syn region perlSubstitutionParens
 \ matchgroup=perlMatchStartEnd
 \ start=+(+ end=+)[ecgimosx]*+
 \ contained
 \ contains=@perlInterpDQ

" '!!' means double-negation, and can be used as a shortand to convert any
" variable to boolean (this is used a lot e.g. in the automake's sources).
syn match slNoMatch "!\s*!"

" Prefer old-style colors when highlighting "include" statements
" (e.g. 'import', 'use', 'require')
highlight! def link perlStatementInclude perlInclude

" vim: ft=vim ts=4 sw=4 et
