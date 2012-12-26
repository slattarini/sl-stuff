# -* makefile -*-

include ../common.mk

.DEFAULT_GOAL = all

all-sys all-local: all-%: %
	@$(MAKE) -C $* all
.PHONY: all-sys all-local
all: all-sys all-local

install-sys install-local: install-%: %
	@$(MAKE) -C $* install
install:
	@echo "You can only issue 'install-sys' or 'install-local'" \
	      "explicitly" >&2
	@exit 1
.PHONY: install-sys install-local install

clean-sys clean-local: clean-%: %
	@$(MAKE) -C $* clean
clean: clean-sys clean-local
.PHONY: clean clean-sys clean-local

# vim: ft=make sw=4 ts=8 noet
