# -*- makefile -*-

# No builtin rules or variables.
MAKEFLAGS += -r -R
.SUFFIXES:

ifndef UTILS
$(error $${UTILS} should be defined before including this makefile)
endif

ifndef bindir
$(error $${bindir} should be defined before including this makefile)
endif

INSTALL = install -c
INSTALL_DATA = $(INSTALL) -m 444
INSTALL_EXEC = $(INSTALL) -m 555
MKDIR_P = mkdir -p

# A python interpreter invocation.
PYTHON_CMD = /usr/bin/env python

# The Bourne-Again shell.
ifndef BASH_SHELL
ifeq ($(wildcard /bin/bash),/bin/bash)
BASH_SHELL = /bin/bash
else
BASH_SHELL = /usr/bin/env bash
endif
endif

# A POSIX shell.  The /bin/sh shell is not always POSIX-conforming
# (e.g., on Solaris 10).
is_posix = \
  $(shell $1 -c '[ $$(echo x) = x ]' 2>/dev/null && echo yes)
maybe_set_posix_shell = \
  $(if $(POSIX_SHELL),,$(if $(call is_posix,$1),$(eval POSIX_SHELL = $1)))
$(call maybe_set_posix_shell,/bin/dash)
$(call maybe_set_posix_shell,/bin/sh)
$(call maybe_set_posix_shell,/usr/xpg4/bin/sh)
$(call maybe_set_posix_shell,/bin/ksh)
$(call maybe_set_posix_shell,/usr/bin/bash)

# Paranoid sanity check.
ifndef HOME
$(error cannot use these makefiles with $${HOME} unset or empty)
endif

# Little hack: I identify a "personal account on a personal system"
# by the use of Thunderbird (or Icedove, as it's called on Debian).
we_are_at_home := $(if $(wildcard $(HOME)/.icedove $(HOME)/.tunderbird),yes)

.DEFAULT_GOAL := all

all: $(UTILS)

install-utils: $(UTILS)
	$(MKDIR_P) $(DESTDIR)$(bindir)
	$(INSTALL_EXEC) $^ $(DESTDIR)$(bindir)

clean:
	rm -f $(UTILS) $(CLEANFILES)

# The 'install' rule is left under the control of the client makefile.
.PHONY: all clean install install-utils

# Pre-process bash scripts.
%: %.bash
	rm -f $@ $@-t
	sed '1s|#!.*|#!$(BASH_SHELL)|' $< >$@-t
	chmod a-w,a+x $@-t && mv -f $@-t $@

# Pre-process posix shell scripts.
%: %.sh
	rm -f $@ $@-t
	sed '1s|#!.*|#!$(POSIX_SHELL)|' $< >$@-t
	chmod a-w,a+x $@-t && mv -f $@-t $@

# Pre-process python scripts.
%: %.py
	rm -f $@ $@-t
	sed '1s|#!.*|#!$(PYTHON_CMD)|' $< >$@-t
	chmod a-w,a+x $@-t && mv -f $@-t $@

# Compile and link C programs.
CC ?= gcc
CFLAGS ?= -Wall -Werror
%: %.c
	rm -f $@-t $@
	$(CC) $(CPPFLAGS) $(CFLAGS) $< -o$@-t $(LDFLAGS)
	chmod a-w $@-t && mv -f $@-t $@
