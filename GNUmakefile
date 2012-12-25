# -*- makefile -*-

# No builtin rules or variables.
MAKEFLAGS += -r -R
.SUFFIXES:

.DEFAUL_GOAL = print-info

LN_S = ln -s
MKDIR_P = mkdir -p

home-dir = $(DESTDIR)$(HOME)
sl-config-dir := .sl-config

i-am-root := $(shell test `id -u` -eq 0 && echo yes)

INSTALL_TARGETS := # Updated later.

print-info:
	@echo 'Run "make install-all" to install; be warned that this will'
	@echo 'override several configuration files in your home directory'
	@echo 'Note however that DESTDIR is honoured'

install-setup:
ifdef i-am-root
	@rm -rf $(home-dir)/$(sl-config-dir)
	@$(MKDIR_P) $(home-dir)/$(sl-config-dir)
	@git -c tar.umask=02222 archive HEAD | \
	  (cd $(home-dir)/$(sl-config-dir) && tar xf - && rm -f GNUmakefile)
else
	@rm -rf $(home-dir)/$(sl-config-dir)
	@$(MKDIR_P) $(home-dir) # For DESTDIR installs.
	@$(LN_S) "$$(pwd)" $(home-dir)/$(sl-config-dir)
endif

install-git:
	@cd $(home-dir) \
	  && rm -f .gitconfig .gitignore \
	  && for f in config ignore; do \
	       $(LN_S) $(sl-config-dir)/git/$$f .git$$f || exit 1; \
	     done
INSTALL_TARGETS += install-git

install-python:
	@cd $(home-dir) \
	  && rm -f .pythonrc \
	  && $(LN_S) $(sl-config-dir)/pythonrc.py .pythonrc
INSTALL_TARGETS += install-python

install-dircolors:
	@cd $(home-dir) \
	  && rm -f .dircolors \
	  && $(LN_S) $(sl-config-dir)/dircolors .dircolors
INSTALL_TARGETS += install-dircolors

install-vim:
	@cd $(home-dir) \
	  && rm -rf .vim .vimrc .gvimrc \
	  && $(LN_S) $(sl-config-dir)/vim .vim \
	  && $(LN_S) .vim/vimrc.vim .vimrc \
	  && $(LN_S) .vim/gvimrc.vim .gvimrc
INSTALL_TARGETS += install-vim

$(INSTALL_TARGETS): install-setup
install-all: $(INSTALL_TARGETS)
