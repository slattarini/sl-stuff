# -*- makefile -*-

UTILS = \
  strerror \
  IPof \
  bak \
  errnoinfo \
  apply

ifeq ($(shell test `id -u` -eq 0 && echo yes),yes)
  bindir = /usr/local/bin
else
  bindir = $(HOME)/bin
endif

include ../common.mk

install: install-utils
.PHONY: install
