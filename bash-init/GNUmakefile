#-*- makefile -*-

include ../common.mk

.ONESHELL:

home-dir = $(DESTDIR)$(HOME)

FAKE =
ALL =

INSTALL = install -c
MKDIR_P = mkdir -p
GNUTAR = tar

install_data = $(INSTALL) -m 444
inst = vrun $(install_data)

define shell_setup
  set -u;
  set -e;
  (set -C) >/dev/null 2>&1 && set -C
  isTrue () { case $$1 in 1|[yY]*) true;; *) false;; esac; }
  if isTrue '$(FAKE)'; then
    run()  { echo " $$@"; }
    vrun() { echo " $$@"; }
  else
    run()  { "$$@" || exit $$?; }
    vrun() { echo " $$@"; run "$$@"; }
  fi
endef

help:
	@echo "Type '$(MAKE) install' to install common files."
	@echo "Type '$(MAKE) install ALL=yes' to all files" \
	      "(for \"stefano\" persona)."
	@echo "The 'DESTDIR' variable is honoured."
	@echo "Try '$(MAKE) fake-install' to see what would have been" \
	      "removed/installed."
	@echo
	@echo "! This package will overwrite your ~/.bash_profile and"
	@echo "! other initialization files by default!  Override the"
	@echo "! DESTDIR variable or use 'fake-install' target if you"
	@echo "! want to avoid this."
.PHONY: help

all: bashrc.sh
.PHONY: all

install: all
	@$(shell_setup)
	@[ -d '$(home-dir)' ] || vrun $(MKDIR_P) '$(home-dir)'
	@vrun rm -rf '$(home-dir)/.bashrc.d'
	@vrun $(MKDIR_P) '$(home-dir)/.bashrc.d'
	@cd bashrc.d
	@for f in *; do
	@  case $$f in
	@    bash_completion.sh|bashrc.sh|bash_profile.sh) ;;
	@    [0-9][0-9]C-*.sh) ;;
	@    [0-9][0-9]u-*.sh) isTrue '$(ALL)' || continue;;
	@    *) echo "$@: invalid filename '$$f'" >&2; exit 1;;
	@  esac
	@  $(inst) $$f '$(home-dir)/.bashrc.d'
	@done
	@cd ..
	@$(inst) bashrc.sh          '$(home-dir)/.bashrc'
	@$(inst) bash_profile.sh    '$(home-dir)/.bash_profile'
	@$(inst) bash_completion.sh '$(home-dir)/.bash_completion'
.PHONY: install

uninstall:
	@$(shell_setup)
	@vrun cd '$(home-dir)'
	@vrun rm -rf .bashrc.d
	@vrun rm -f .bash_profile .bashrc .bash_completion
.PHONY: uninstall

fake-install:
	$(MAKE) install FAKE=yes
.PHONY: fake-install

clean:
	rm -f *.tmp *.tmp[0-9]
.PHONY: clean

# vim: ft=make sw=4 ts=8 noet
