# -*- makefile -*-
# Common makefile fragment sourced by all makefiles in the package.

# No builtin rules or variables.
MAKEFLAGS += -r -R
.SUFFIXES:

# Paranoid sanity check.
ifndef HOME
$(error cannot use these makefiles with $${HOME} unset or empty)
endif

homebindir = $(HOME)/bin
sysbindir = /usr/local/bin

INSTALL = install -c
INSTALL_DATA = $(INSTALL) -m 444
INSTALL_EXEC = $(INSTALL) -m 555
MKDIR_P = mkdir -p
LN_S = ln -s

# Little hack: I identify a "personal account on a personal system"
# by the use of Thunderbird (or Icedove, as it's called on Debian).
# The user is of course free to override this (albeit there should
# usually be no reason to).
we-are-at-home := $(if $(wildcard $(HOME)/.icedove $(HOME)/.tunderbird),yes)

# The user is of course free to override this as well.
i-am-root := $(shell test `id -u` -eq 0 && echo yes)

# Allow user configuration.
-include ./cfg.mk

# vim: ft=make sw=4 ts=8 noet
