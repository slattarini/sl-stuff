# -*- makefile -*-

include ../../common.mk

UTILS = \
  strerror \
  IPof \
  bak \
  errnoinfo \
  editor \
  apply \
  cdefn \
  cfundef \
  zap \
  del \
  pf \
  nolocale \
  xrm \
  vis \
  pkgi

ifdef i-am-root
  bindir = $(sysbindir)
else
  bindir = $(homebindir)
endif

include ../utils-common.mk

install: install-utils
.PHONY: install
