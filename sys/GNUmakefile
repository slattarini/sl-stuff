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

UTILS = strerror
CLEANFILES = $(UTILS)

all: $(UTILS)

install: all
	$(MKDIR_P) $(DESTDIR)$(bindir)
	$(INSTALL_EXEC) $^ $(DESTDIR)$(bindir)

clean:
	rm -f $(CLEANFILES)

.PHONY: all clean install

# -*-*-

CC ?= gcc
CFLAGS ?= -Wall -Werror

# Compile and link C programs.
%: %.c
	rm -f $@-t $@
	$(CC) $(CPPFLAGS) $(CFLAGS) $< -o$@-t $(LDFLAGS)
	chmod a-w $@-t && mv -f $@-t $@

# TODO: pre-process Bash scripts.
