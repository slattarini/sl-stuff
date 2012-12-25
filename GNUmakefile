# -*- makefile -*-

# No builtin rules or variables.
MAKEFLAGS += -r -R
.SUFFIXES:

.DEFAUL_GOAL = print-info

INSTALLS := # Updated later.
LN_S = ln -s
MKDIR_P = mkdir -p
homedir = $(DESTDIR)$(HOME)

print-info:
	@echo 'Run "make install-all" to install; be warned that this will'
	@echo 'override several configuration files in your home directory'
	@echo 'Note however that DESTDIR is honoured'

install-setup:
	@rm -f $(homedir)/.sl-config
	@$(MKDIR_P) $(homedir) # For DESTDIR installs.
	@$(LN_S) "$$(pwd)" $(homedir)/.sl-config

install-git:
	@cd $(homedir) \
	  && rm -f .gitconfig .gitignore \
	  && for f in config ignore; do \
	       $(LN_S) .sl-config/git/$$f .git$$f; \
	     done
INSTALLS += git

INSTALL_TARGETS := $(patsubst %,install-%,$(INSTALLS))
$(INSTALL_TARGETS): install-setup
.PHONY: install-all install-setup $(INSTALL_TARGETS)
install-all: $(INSTALL_TARGETS)
