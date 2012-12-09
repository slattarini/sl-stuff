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

# Automatically set just below.  The user can override this, of course.
BASH_SHELL =
ifndef BASH_SHELL
ifeq ($(wildcard /bin/bash),/bin/bash)
BASH_SHELL = /bin/bash
else
BASH_SHELL = /usr/bin/env bash
endif
endif

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
	chmod a-w $@-t && mv -f $@-t $@

# Compile and link C programs.
CC ?= gcc
CFLAGS ?= -Wall -Werror
%: %.c
	rm -f $@-t $@
	$(CC) $(CPPFLAGS) $(CFLAGS) $< -o$@-t $(LDFLAGS)
	chmod a-w $@-t && mv -f $@-t $@

