DESTDIR	?=	$(HOME)

INSTALL_DIRS = .config .cache .local/share .vim/plugin

LINK_PAIRS += .local/share/gems .gem

PERMISSIONS = o-rwx

all:
	@echo To install, set DESTDIR and run make install.

install: install-links install-dirs install-standard

include bin/rules.mk
include git/rules.mk
include gnupg/rules.mk
include misc/rules.mk
include mutt/rules.mk
include screen/rules.mk
include signature/rules.mk
include tmux/rules.mk
include vim/rules.mk
include zsh/rules.mk

install-dirs:
	for i in $(INSTALL_DIRS); \
	do \
		mkdir -m $(PERMISSIONS) -p $(DESTDIR)/$$i; \
	done

install-links: install-dirs
	printf "%s %s\n" $(LINK_PAIRS) | (set -e; while read target link; \
		do \
			rm -f "$(DESTDIR)/$$link"; \
			ln -sf "$(DESTDIR)/$$target" "$(DESTDIR)/$$link"; \
		done)

install-standard:
	printf "%s %s\n" $(INSTALL_PAIRS) | (set -e; while read src dest; \
		do \
			if [ -d "$$src" ]; \
			then \
				mkdir -m $(PERMISSIONS) -p "$(DESTDIR)/$$dest"; \
				rsync -a --chmod=$(PERMISSIONS) --exclude '*.mk' "$$src/" "$(DESTDIR)/$$dest/"; \
			else \
				cp -pr "$$src" "$(DESTDIR)/$$dest"; \
				chmod $(PERMISSIONS) "$(DESTDIR)/$$dest"; \
			fi; \
		done)
