# sl-utils: top level Makefile.
install:
	@echo "You can only issue 'install-sys' or 'install-local'" \
	      "explicitly" >&2
	@exit 1
install-sys install-local: install-%: %
	@$(MAKE) -C $* install
