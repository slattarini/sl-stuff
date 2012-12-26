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

ifdef i-am-root
  bindir = /usr/local/bin
else
  bindir = $(HOME)/bin
endif

include ../utils-common.mk

install: install-utils
.PHONY: install
