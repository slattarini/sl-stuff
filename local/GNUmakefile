# -*- makefile -*-

# No builtin rules or variables.
MAKEFLAGS += -r -R
.SUFFIXES:

INSTALL = install -c
INSTALL_DATA = $(INSTALL) -m 444
INSTALL_EXEC = $(INSTALL) -m 555
MKDIR_P = mkdir -p

# Paranoid sanity check.
ifndef HOME
$(error cannot use this makefile with $${HOME} unset or empty)
endif

# Little hack: I identify a "personal account on a personal system"
# by the use of Thunderbird (or Icedove, as it's called on Debian).
we_are_home := $(if $(wildcard $(HOME)/.icedove $(HOME)/.tunderbird),yes)

bindir = $(HOME)/bin

.DEFAULT_GOAL := all

UTILS = XXX

all: $(UTILS)

install: all
ifdef we_are_at_home
	$(MKDIR_P) $(DESTDIR)$(bindir)
	$(INSTALL_EXEC) $^ $(DESTDIR)$(bindir)
else
	echo "shouldn't install this stuff on a non-home account" >&2
	exit 1
endif

.PHONY: install all

# -*-*-

# TODO: compiler C programs.

# TODO: pre-process Bash scripts.
