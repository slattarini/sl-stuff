" Vim extension syntax file
" Language:	   automake Makefile.am
" Maintainer:  Stefano Lattarini
" Last Change: 2010-08-03 12:14:58 CEST

syn region automakeComment1 start="\s#" end="^$" end="[^\\]$" keepend contains=makeTodo,automakeSubst
syn match  automakeComment1 "#$"
syn match automakeComment3 "^ *##.*$" contains=makeTodo

syn region  automakeMakeDString start=+"+  skip=+\\"+  end=+"+  contains=automakeComment3,makeIdent,automakeSubstitution
syn region  automakeMakeSString start=+'+  skip=+\\'+  end=+'+  contains=automakeComment3,makeIdent,automakeSubstitution
syn region  automakeMakeBString start=+`+  skip=+\\`+  end=+`+  contains=automakeComment3,makeIdent,makeSString,makeDString,makeNextLine,automakeSubstitution

syn match automakePrimary "^[A-Za-z0-9_]\+\(_PROGRAMS\|LIBRARIES\|_LIST\|_SCRIPTS\|_DATA\|_HEADERS\|_MANS\|_TEXINFOS\|_JAVA\|_LTLIBRARIES\)\s*+="me=e-2
syn match automakePrimary "^TESTS\s*+="me=e-2
syn match automakeSecondary "^[A-Za-z0-9_]\+\(_SOURCES\|_LDADD\|_LIBADD\|_LDFLAGS\|_DEPENDENCIES\|_C\(PP\)\?FLAGS\)\s*+\?="me=e-2
syn match automakeSecondary "^OMIT_DEPENDENCIES\s*+="me=e-2
syn match automakeExtra "^EXTRA_[A-Za-z0-9_]\+\s*+="me=e-2
syn match automakeOptions "^\(AUTOMAKE_OPTIONS\|ETAGS_ARGS\|TAGS_DEPENDENCIES\)\s*+="me=e-2
syn match automakeClean "^\(MOSTLY\|DIST\|MAINTAINER\)\=CLEANFILES\s*+="me=e-2
syn match automakeSubdirs "^\(DIST_\)\=SUBDIRS\s*+="me=e-2

syn region automakeNoSubst start="^EXTRA_[a-zA-Z0-9_]*\s*+\?=" end="$" contains=ALLBUT,automakeNoSubst transparent
syn region automakeNoSubst start="^DIST_SUBDIRS\s*+\?=" end="$" contains=ALLBUT,automakeNoSubst transparent
syn region automakeNoSubst start="^[a-zA-Z0-9_]*_SOURCES\s*+\?=" end="$" contains=ALLBUT,automakeNoSubst transparent

hi def link automakeComment2 makeNone
hi def link automakeComment3 makeComment

" vim: ts=4 sw=4 sts=4
