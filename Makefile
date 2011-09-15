#-*- Makefile -*-

DISTNAME = bashrc

DESTDIR =
SYSPREFIX = /usr/local
USRPREFIX = $(HOME)
homedir = $(DESTDIR)$(HOME)
prefixdir = $(DESTDIR)$(PREFIX)

FAKEINSTALL =

RM = rm
RM_F = $(RM) -f
RM_RF = $(RM) -rf
MV = mv
MV_F = $(MV) -f
CP = cp
LN = ln
LN_S = $(LN) -s
INSTALL = install -c
MKDIR = mkdir
MKDIR_P = $(MKDIR) -p
GNUTAR = tar

install_data = $(INSTALL) -m 444

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
	@echo "Type '$(MAKE) my-install' to install user's files."
	@echo "Type '$(MAKE) su-install' to install system ones."
	@echo
	@echo "'$(MAKE) my-install' will try to install stuff in \$$HOME by"
	@echo "default; this can be overridden by redefining 'USRPREFIX'."
	@echo
	@echo "'$(MAKE) su-install' will try to install stuff in /usr/local by"
	@echo "default; this can be overridden by redefining 'SYSPREFIX'."
	@echo
	@echo "The 'DESTDIR' variable is honoured."
	@echo
	@echo "Try '$(MAKE) fake-install' to see what would have been" \
	      "removed/installed."
	@echo
	@echo "*** BE CAREFUL! ***"
	@echo "'$(MAKE) my-install' will overwrite your ~/.bash_profile and"
	@echo "other initialization files by default!"
.PHONY: help

my-install:
	@$(shell_setup); \
	 [ -d $(homedir) ] || vrun $(MKDIR_P) $(homedir); \
	 vrun $(install_data) bash_profile.sh $(homedir)/.bash_profile; \
	 vrun $(install_data) bashrc.sh $(homedir)/.bashrc; \
	 vrun $(install_data) bash_completion.sh $(homedir)/.bash_completion; \
	 if [ -d $(homedir)/.bashrc.d ]; then \
	   vrun $(RM_RF) $(homedir)/.bashrc.d; \
	 else \
	   :; \
	 fi; \
	 vrun $(MKDIR) $(homedir)/.bashrc.d; \
	 echo ' $(install_data) bashrc.d/* $(homedir)/.bashrc.d/'; \
	 run $(install_data) bashrc.d/* $(homedir)/.bashrc.d/; \
	 vrun $(install_data) dir_colors $(homedir)/.dir_colors; \
	 vrun $(install_data) inputrc $(homedir)/.inputrc; \
	 if [ -f $(homedir)/.bash_inputrc ] || \
	    [ -h $(homedir)/.bash_inputrc ]; then \
		 vrun $(RM_F) $(homedir)/.bash_inputrc; \
	 fi; \
	 vrun $(LN_S) .inputrc $(homedir)/.bash_inputrc; \
	 $(shell_done)
.PHONY: my-install

su-install:
	@echo 'YET TO BE WRITTEN!'
.PHONY: su-install

fake-install:
	$(MAKE) $(MAKEFLAGS) 'DESTDIR=$(DESTDIR)' 'FAKEINSTALL=y' my-install
	$(MAKE) $(MAKEFLAGS) 'DESTDIR=$(DESTDIR)' 'FAKEINSTALL=y' su-install
.PHONY: fake-install

$(DISTNAME).tar.gz: dist
dist:
	@set -x -u; \
	files="Makefile bash_profile.sh bashrc.sh bash_completion.sh \
	       inputrc dir_colors"; \
	$(RM_RF) dist.tmpdir \
	  && $(MKDIR) dist.tmpdir \
	  && $(GNUTAR) -cf dist.tmpdir/tmp.tar $$files bashrc.d/*.sh \
	  && cd dist.tmpdir \
	  && $(MKDIR) $(DISTNAME) \
	  && cd $(DISTNAME) \
	  && $(GNUTAR) -xf ../tmp.tar \
	  && cd .. \
	  && $(GNUTAR) -czvf ../$(DISTNAME).tar.gz ./$(DISTNAME) \
	  && cd .. \
	  && $(RM_RF) dist.tmpdir
.PHONY: dist

clean:
	$(RM_F) *.tmp *.tmp[0-9] $(DISTNAME).tar.gz
	$(RM_RF) dist.tmpdir
.PHONY: clean

# vim: ft=make sw=4 ts=4 noet
