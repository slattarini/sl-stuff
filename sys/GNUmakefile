# -*- makefile -*-

# No builtin rules or variables.
MAKEFLAGS += -r -R
.SUFFIXES:

INSTALL = install -c
INSTALL_DATA = $(INSTALL) -m 444
INSTALL_EXEC = $(INSTALL) -m 555
MKDIR_P = mkdir -p

ifeq ($(shell test `id -u` -eq 0 && echo yes),yes)
  bindir = /usr/local/bin
else
  bindir = $(HOME)/bin
endif

# -*-*-

.DEFAULT_GOAL := all

UTILS = XXX

all: $(UTILS)

install: all
	$(MKDIR_P) $(DESTDIR)$(bindir)
	$(INSTALL_EXEC) $^ $(DESTDIR)$(bindir)

# -*-*-

# TODO: compiler C programs.

# TODO: pre-process Bash scripts.
