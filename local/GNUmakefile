# -*- makefile -*-

# No builtin rules or variables.
MAKEFLAGS += -r -R
.SUFFIXES:

INSTALL = install -c
INSTALL_DATA = $(INSTALL) -m 444
INSTALL_EXEC = $(INSTALL) -m 555
MKDIR_P = mkdir -p

# Automatically set below.  The user can override this, of course.
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
$(error cannot use this makefile with $${HOME} unset or empty)
endif

# Little hack: I identify a "personal account on a personal system"
# by the use of Thunderbird (or Icedove, as it's called on Debian).
we_are_home := $(if $(wildcard $(HOME)/.icedove $(HOME)/.tunderbird),yes)

bindir = $(HOME)/bin

.DEFAULT_GOAL := all

UTILS = P

all: $(UTILS)

CLEANFILES = $(UTILS)

install: all
ifdef we_are_at_home
	$(MKDIR_P) $(DESTDIR)$(bindir)
	$(INSTALL_EXEC) $^ $(DESTDIR)$(bindir)
else
	echo "shouldn't install this stuff on a non-home account" >&2
	exit 1
endif

clean:
	rm -f $(CLEANFILES)

.PHONY: all clean install

# -*-*-

# Pre-process bash
%: %.bash
	rm -f $@ $@-t
	sed '1s|#!.*|#!$(BASH_SHELL)|' $< >$@-t
	chmod a-w $@-t && mv -f $@-t $@

