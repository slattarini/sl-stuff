# -*- makefile -*-

UTILS = \
  strerror \
  IPof \
  bak \
  errnoinfo \
  apply \
  cdefn \
  cfundef \
  zap \
  del \
  pf \
  nolocale \
  vis

ifeq ($(shell test `id -u` -eq 0 && echo yes),yes)
  bindir = /usr/local/bin
else
  bindir = $(HOME)/bin
endif

include ../utils-common.mk

install: install-utils
.PHONY: install
