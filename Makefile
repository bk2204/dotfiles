DESTDIR	?=	$(HOME)

all:
	@echo To install, set DESTDIR and run make install.

install: install-dirs install-standard

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
	mkdir -p $(DESTDIR)/.config
	mkdir -p $(DESTDIR)/.cache
	mkdir -p $(DESTDIR)/.local/share

install-standard:
	printf "%s %s\n" $(INSTALL_PAIRS) | (set -e; while read src dest; \
		do \
			if [ -d "$$src" ]; \
			then \
				mkdir -p "$(DESTDIR)/$$dest"; \
				rsync -a --exclude '*.mk' "$$src/" "$(DESTDIR)/$$dest/"; \
			else \
				cp -pr "$$src" "$(DESTDIR)/$$dest"; \
			fi; \
		done)
