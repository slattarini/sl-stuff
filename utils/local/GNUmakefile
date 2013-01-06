# -*- makefile -*-

UTILS = \
  P \
  listen-radioclassica \
  record-radioclassica \
  record-radio \
  ssh-add-all

bindir = $(homebindir)

include ../utils-common.mk

ifdef we-are-at-home
install: install-utils
else
install:
	@echo "shouldn't install this stuff on a non-home account" >&2
	@exit 1
endif
