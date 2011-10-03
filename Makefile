#-*- Makefile -*-

DISTNAME = bashrc

homedir = $(HOME)
sysdir = /usr/local
libdir = $(sysdir)/lib
bashrcdir = $(libdir)/bashrc

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
	@echo "default; this can be overridden by redefining 'homedir'."
	@echo
	@echo "'$(MAKE) su-install' will try to install stuff in /usr/local by"
	@echo "default; this can be overridden by redefining 'sysdir'."
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

bashrc.sh: bashrc.in
	@rm -f $@ $@.tmp
	sed 's|@bashrcdir@|$(bashrcdir)|' $< >$@.tmp
	@if LC_ALL=C grep '@[a-zA-Z0-9_][a-zA-Z0-9_]*@' $@.tmp; then \
      echo "$@ contains unexpanded substitution (see lines above)"; \
      exit 1; \
    fi
	chmod a-w $@.tmp && mv -f $@.tmp $@

my-install: bashrc.sh
	@$(shell_setup); \
	 cooked_homedir='$(DESTDIR)$(homedir)'; \
	 do_link_ () \
	   { \
	     source='$(bashrcdir)'/$$1; : No DESTDIR here, deliberately; \
	     target=$$cooked_homedir/$$2; \
	     if test -f "$$target" || test -h "$$target"; then \
	       vrun rm -f "$$target"; \
	     fi; \
	     vrun $(LN_S) "$$source" "$$target"; \
	   }; \
	 [ -d "$$cooked_homedir" ] || vrun $(MKDIR_P) "$$cooked_homedir"; \
	 vrun rm -rf "$$cooked_homedir/.bashrc.d"; \
	 vrun $(MKDIR_P) "$$cooked_homedir/.bashrc.d"; \
	 for f in usr-bashrc.d/*; do \
	   vrun $(install_data) $$f "$$cooked_homedir/.bashrc.d"; \
	 done; \
	 do_link_ bash_profile.sh .bash_profile; \
	 do_link_ bashrc.sh .bashrc; \
	 do_link_ bash_completion.sh .bash_completion; \
	 do_link_ dir_colors .dir_colors; \
	 do_link_ inputrc .inputrc; \
	 do_link_ inputrc .bash_inputrc; \
	 $(shell_done)
.PHONY: my-install

su-install:
	@$(shell_setup); \
	 sysdir='$(DESTDIR)$(bashrcdir)'; \
	 vrun rm -rf "$$sysdir"; \
	 vrun $(MKDIR_P) "$$sysdir"; \
	 for f in bash_completion.sh bashrc.sh bash_profile.sh \
	          dir_colors inputrc; \
	 do \
	   vrun $(install_data) $$f "$$sysdir"; \
	 done; \
	 vrun $(MKDIR_P) "$$sysdir/bashrc.d"; \
	 for f in sys-bashrc.d/*; do \
	   vrun $(install_data) $$f "$$sysdir/bashrc.d"; \
	 done; \
	 $(shell_done)
.PHONY: su-install

fake-install:
	$(MAKE) FAKEINSTALL=y my-install
	$(MAKE) FAKEINSTALL=y su-install
.PHONY: fake-install

$(DISTNAME).tar.gz: dist
dist:
	@set -x -u; \
	files="Makefile bash_profile.sh sys-bashrc.sh bashrc.sh \
		   bash_completion.sh inputrc dir_colors"; \
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
	$(RM_F) bashrc.sh *.tmp *.tmp[0-9] $(DISTNAME).tar.gz
	$(RM_RF) dist.tmpdir
.PHONY: clean

# vim: ft=make sw=4 ts=4 noet
