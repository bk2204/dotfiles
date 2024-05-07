DESTDIR	?=	$(HOME)

INSTALL_DIRS = .config .cache .local/share .vim/plugin

LINK_PAIRS += .local/share/gems .gem

PERMISSIONS = u=rwX,go-rwx

CONFIG_FILE ?= config.yaml

TEMPLATE ?= $(shell command -v ruby >/dev/null && [ -f $(CONFIG_FILE) ] && echo 1)

all:
	@echo To install, set DESTDIR and run make install.

print:
	@if [ "$(TEMPLATE)" = 1 ]; \
	then \
		echo "Templating enabled."; \
		echo "Using configuration file $(CONFIG_FILE)"; \
	else \
		echo "Templating disabled."; \
	fi

install: install-links install-dirs install-standard

include bin/rules.mk
include git/rules.mk
include gnupg/rules.mk
include misc/rules.mk
include mutt/rules.mk
include screen/rules.mk
include signature/rules.mk
include snippets/rules.mk
include tmux/rules.mk
include vim/rules.mk
include zsh/rules.mk

-include rules-overlay.mk

%.gen: %.erb $(CONFIG_FILE)
	bin/dct-erb -f $(CONFIG_FILE) -o $@ $^

build-standard: $(TEMPLATE_FILES)

install-dirs:
	for i in $(INSTALL_DIRS); \
	do \
		mkdir -m $(PERMISSIONS) -p $(DESTDIR)/$$i; \
	done

install-links: install-dirs
	printf "%s %s\n" $(LINK_PAIRS) | (set -e; while read target link; \
		do \
			rm -f "$(DESTDIR)/$$link"; \
			case "$$target" in \
				/*) ln -sf "$$target" "$(DESTDIR)/$$link";; \
				*) ln -sf "$(DESTDIR)/$$target" "$(DESTDIR)/$$link";; \
			esac; \
		done)

install-standard: build-standard install-dirs
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
