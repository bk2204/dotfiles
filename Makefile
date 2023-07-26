DESTDIR	?=	$(HOME)

INSTALL_DIRS = .config .cache .local/share .vim/plugin .local/run/lawn

LINK_PAIRS += .local/share/gems .gem

PERMISSIONS = u=rwX,go-rwx

CONFIG_FILE ?= config.yaml

MTREE_SOURCES += rules.mtree

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

clean:
	$(RM) $(TEMPLATE_FILES)
	$(RM) manifest.mtree

install-legacy: install-links install-dirs install-standard

include bash/rules.mk
include bin/rules.mk
include firefox/rules.mk
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
	bin/dct-erb -f $(CONFIG_FILE) -o $@ $<

manifest.mtree: $(MTREE_SOURCES) $(DESTDIR)
	cat $(MTREE_SOURCES) > $@

build-standard: $(TEMPLATE_FILES)

install: build-standard manifest.mtree
	cat manifest.mtree | bin/dct-mtree --recurse --install $(DESTDIR)

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
				rsync -a --chmod=$(PERMISSIONS) --exclude '*.mk' --exclude '*.mtree' "$$src/" "$(DESTDIR)/$$dest/"; \
			else \
				cp -pr "$$src" "$(DESTDIR)/$$dest"; \
				chmod $(PERMISSIONS) "$(DESTDIR)/$$dest"; \
			fi; \
		done)
