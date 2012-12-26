# -*- makefile -*-

include ../common.mk

# One shell run all the components of a recipe.
.ONESHELL:

.DEFAUL_GOAL = print-info

home-dir := $(DESTDIR)$(HOME)
sl-config-dir := .sl-config

print-info:
	@echo 'Run "make install" to install; be warned that this will'
	@echo 'override several configuration files in your home directory.'
	@echo 'Note however that DESTDIR is honoured.'

install:
	@set -u -e
	@vrun() { echo " $$@" && "$$@"; }
	@lnk () { rm -f "$$2" && vrun $(LN_S) "$$1" "$$2"; }
	@xlnk () { lnk "$(sl-config-dir)/$$1" "$$2"; }
	@# For DESTDIR installs.
	@[ -d '$(home-dir)' ] || $(MKDIR_P) '$(home-dir)'
	@vrun rm -rf '$(home-dir)/$(sl-config-dir)'
ifdef i-am-root
	@echo ' git-copytree $(CURDIR) $(home-dir)/$(sl-config-dir)'
	@[ -d '$(home-dir)/$(sl-config-dir)' ] \
	  || $(MKDIR_P) '$(home-dir)/$(sl-config-dir)'
	@git -c tar.umask=00222 archive HEAD | \
	  (cd '$(home-dir)/$(sl-config-dir)' \
	    && tar xf - \
	    && rm -f GNUmakefile)
else
	@lnk '$(CURDIR)' '$(home-dir)/$(sl-config-dir)'
endif
	@vrun cd '$(home-dir)'
	@xlnk dircolors .dircolors
	@xlnk inputrc .inputrc
	@xlnk vim .vim
	@lnk .vim/vimrc.vim .vimrc
	@lnk .vim/gvimrc.vim .gvimrc
ifndef i-am-root
	@for f in config ignore; do xlnk git/$$f .git$$f; done
	@xlnk pythonrc.py .pythonrc
endif

# vim: ft=make sw=4 ts=8 noet
