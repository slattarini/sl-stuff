# -*- makefile -*-

# No builtin rules or variables.
MAKEFLAGS += -r -R
.SUFFIXES:

.DEFAUL_GOAL = print-info

LN_S = ln -s
MKDIR_P = mkdir -p
INSTALL =

homedir = $(DESTDIR)$(HOME)

i-am-root := $(shell test `id -u` -eq 0 && echo yes)

INSTALL_TARGETS := # Updated later.

print-info:
	@echo 'Run "make install-all" to install; be warned that this will'
	@echo 'override several configuration files in your home directory'
	@echo 'Note however that DESTDIR is honoured'

install-setup:
ifdef i-am-root
	@rm -rf $(homedir)/.sl-config
	@$(MKDIR_P) $(homedir)/.sl-config
	@git -c tar.umask=02222 archive HEAD | \
	  (cd $(homedir)/.sl-config && tar xf - && rm -f GNUmakefile)
else
	@rm -rf $(homedir)/.sl-config
	@$(MKDIR_P) $(homedir) # For DESTDIR installs.
	@$(LN_S) "$$(pwd)" $(homedir)/.sl-config
endif

install-git:
	@cd $(homedir) \
	  && rm -f .gitconfig .gitignore \
	  && for f in config ignore; do \
	       $(LN_S) .sl-config/git/$$f .git$$f || exit 1; \
	     done
INSTALL_TARGETS += install-git

install-python:
	@cd $(homedir) \
	  && rm -f .pythonrc \
	  && $(LN_S) .sl-config/pythonrc.py .pythonrc
INSTALL_TARGETS += install-python

install-dircolors:
	@cd $(homedir) \
	  && rm -f .dir_colors \
	  && $(LN_S) .sl-config/dir_colors .dir_colors
INSTALL_TARGETS += install-dircolors

install-vim:
	@cd $(homedir) \
	  && rm -rf .vim .vimrc .gvimrc \
	  && $(LN_S) .sl-config/vim .vim \
	  && $(LN_S) .vim/vimrc.vim .vimrc \
	  && $(LN_S) .vim/gvimrc.vim .gvimrc
INSTALL_TARGETS += install-vim

$(INSTALL_TARGETS): install-setup
install-all: $(INSTALL_TARGETS)
