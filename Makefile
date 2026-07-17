DESTDIR	?=	$(HOME)

PERMISSIONS = u=rwX,go-rwx

CONFIG_FILE ?= config.yaml

MTREE_SOURCES += rules.mtree

TEMPLATE ?= $(shell command -v ruby >/dev/null && [ -f $(CONFIG_FILE) ] && echo 1)
DCONF ?= $(shell [ -n "$$DISPLAY" ] && command -v dconf 2>/dev/null)
KWRITECONFIG ?= $(shell [ -n "$$DISPLAY" ] && command -v kwriteconfig6 2>/dev/null)
DEFAULTSCMD ?= $(shell [ "$$(uname -s)" = Darwin ] && command -v defaults 2>/dev/null)
COMPLETION ?= $(shell command -v ruby >/dev/null && echo 1)

# Non-template generated files.
GENERATED_FILES =

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
	@if [ "$(COMPLETION)" = 1 ]; \
	then \
		echo "Completion enabled."; \
	else \
		echo "Completion disabled."; \
	fi

clean:
	$(RM) -r $(TEMPLATE_FILES) $(GENERATED_FILES)
	$(RM) manifest.mtree

include bin/rules.mk
include dconf/rules.mk
include firefox/rules.mk
include git/rules.mk
include gnupg/rules.mk
include kde/rules.mk
include kitty/rules.mk
include macos/rules.mk
include misc/rules.mk
include mutt/rules.mk
include screen/rules.mk
include signature/rules.mk
include snippets/rules.mk
include ssh/rules.mk
include tmux/rules.mk
include tridactyl/rules.mk
include vim/rules.mk
include xkb/rules.mk
include zsh/rules.mk

-include rules-overlay.mk

%.gen: %.erb $(CONFIG_FILE)
	bin/dct-erb -f $(CONFIG_FILE) -o $@ $<

manifest.mtree: $(MTREE_SOURCES) $(DESTDIR)
	cat $(MTREE_SOURCES) > $@

build-standard: $(TEMPLATE_FILES)

ifneq ($(COMPLETION),)
build-standard: completion
endif

install-extra: do-install

do-install: build-standard manifest.mtree
	cat manifest.mtree | bin/dct-mtree --recurse --install $(DESTDIR)

install: do-install install-extra

zsh/completion:
	mkdir -p $@

completion: $(COMPLETION_SOURCES)
$(COMPLETION_SOURCES): zsh/completion
