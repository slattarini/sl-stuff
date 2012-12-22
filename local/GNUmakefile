# -*- makefile -*-

UTILS = \
  P \
  listen-radioclassica \
  record-radio

bindir = $(HOME)/bin

include ../common.mk

ifdef we_are_at_home
install: install-utils
else
install:
	@echo "shouldn't install this stuff on a non-home account" >&2
	@exit 1
endif
