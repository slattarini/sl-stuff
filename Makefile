#-*- Makefile -*-

DISTNAME = bashrc

DESTDIR =
homedir = $(DESTDIR)$(HOME)

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
SHELL = bash

install_data = $(INSTALL) -m 444

help:
	@echo "Type '$(MAKE) install' to install the shell init system."; \
	 echo '**WARNING**:  This will overwrite your ~/.bash_profile and' \
	 	  'other initialization files!'; \
	 echo "Try '$(MAKE) fake-install' to see what would have been" \
	      "removed/installed."; \
	 echo "NOTE: the 'DESTDIR' variable is honoured";
.PHONY: help

install:
	@: --------------------------------------------------------------- ; \
	 set -u; set -e; set -C; \
	 trap 'echo "Makefile bug: UNEXPECTED EXIT" >&2; exit 255;' 0; \
	 : --------------------------------------------------------------- ; \
	 case '$(FAKEINSTALL)' in \
	   1|[yY]*) \
	     run()  { echo " $$@"; }; \
	     vrun() { echo " $$@"; }; \
		 : ;; \
	   *) \
	     run()  { "$$@" || exit $$?; }; \
	     vrun() { echo " $$@"; run "$$@"; }; \
		 : ;; \
	 esac; \
	 : --------------------------------------------------------------- ; \
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
	 if [ -e $(homedir)/.bash_inputrc ] || \
	    [ -h $(homedir)/.bash_inputrc ]; then \
		 vrun $(RM_F) $(homedir)/.bash_inputrc; \
	 fi; \
	 vrun $(LN_S) .inputrc $(homedir)/.bash_inputrc; \
	 : --------------------------------------------------------------- ; \
	 trap - 0; \
	 exit 0; \
	 : --------------------------------------------------------------- ;
.PHONY: install

fakeinstall:
	$(MAKE) $(MAKEFLAGS) 'DESTDIR=$(DESTDIR)' 'FAKEINSTALL=y' install
.PHONY: fakeinstall

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
