#-*- makefile -*-

.DEFAULT_GOAL = help

include common.mk

help:
	@echo "Can only build and install from the subdirs"
.PHONY: help

DISTNAME = sl-stuff
dist:
	git archive --prefix=$(DISTNAME)/ -o $(DISTNAME).tar.gz HEAD
.PHONY: dist

clean:
	$(MAKE) -C utils clean
	$(MAKE) -C bash-init clean
	$(MAKE) -C misc-config clean
	rm -f $(DISTNAME).tar.gz
.PHONY: clean

# vim: ft=make sw=4 ts=8 noet
