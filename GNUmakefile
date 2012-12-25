#-*- makefile -*-

DISTNAME = bashrc
GIT = git

# Paranoid sanity check.
ifndef HOME
$(error cannot use this makefile with $$HOME unset or empty)
endif

homedir = $(HOME)

FAKEINSTALL =

INSTALL = install -c
MKDIR_P = mkdir -p
GNUTAR = tar

install_data = $(INSTALL) -m 444
inst = vrun $(install_data)

shell_setup = \
  set -u; set -e; (set -C) >/dev/null 2>&1 && set -C; \
  trap 'echo "Makefile bug: UNEXPECTED EXIT" >&2; exit 255;' 0; \
  case '$(FAKEINSTALL)' in \
    1|[yY]*) \
      run()  { echo " $$@"; }; \
      vrun() { echo " $$@"; }; \
      : ;; \
    *) \
      run()  { "$$@" || exit $$?; }; \
      vrun() { echo " $$@"; run "$$@"; }; \
      : ;; \
  esac

shell_done = trap 'exit $$?' 0; exit 0

help:
	@echo "Type '$(MAKE) install' to install common files."
	@echo "Type '$(MAKE) install ALL=yes' to all files" \
	      "(for \"stefano's\" persona)."
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
	@$(shell_setup); \
	 cooked_homedir='$(DESTDIR)$(homedir)'; \
	 [ -d "$$cooked_homedir" ] || vrun $(MKDIR_P) "$$cooked_homedir"; \
	 vrun rm -rf "$$cooked_homedir/.bashrc.d"; \
	 vrun $(MKDIR_P) "$$cooked_homedir/.bashrc.d"; \
	 cd bashrc.d; \
	 for f in *; do \
	   case $$f in \
	     dir_colors|inputrc) ;; \
	     bash_completion.sh|bashrc.sh|bash_profile.sh) ;; \
	     [0-9][0-9]C-*.sh) ;; \
	     [0-9][0-9]u-*.sh) test '$(ALL)' = yes || continue;; \
	     *) echo "$@: invalid filename '$$f'" >&2; exit 1;; \
	   esac; \
	   $(inst) $$f "$$cooked_homedir/.bashrc.d"; \
	 done; \
	 cd ..; \
	 $(inst) bashrc.sh          "$$cooked_homedir"/.bashrc; \
	 $(inst) bash_profile.sh    "$$cooked_homedir"/.bash_profile; \
	 $(inst) bash_completion.sh "$$cooked_homedir"/.bash_completion; \
	 $(inst) dir_colors 		"$$cooked_homedir"/.dir_colors; \
	 $(inst) inputrc            "$$cooked_homedir"/.inputrc; \
	 $(inst) inputrc            "$$cooked_homedir"/.bash_inputrc; \
	 $(shell_done)
.PHONY: install

uninstall:
	cd '$(DESTDIR)$(homedir)' && rm -rf .bashrc.d \
	  && rm -f .bash_profile .bashrc .bash_completion \
	           .dir_colors .inputrc .bash_inputrc
.PHONY: uninstall

fake-install:
	$(MAKE) FAKEINSTALL=y install
.PHONY: fake-install

dist:
	$(GIT) archive --prefix=$(DISTNAME)/ -o $(DISTNAME).tar.gz HEAD
.PHONY: dist

clean:
	rm -f *.tmp *.tmp[0-9] $(DISTNAME).tar.gz
	rm -rf dist.tmpdir
.PHONY: clean

# vim: ft=make sw=4 ts=4 noet
