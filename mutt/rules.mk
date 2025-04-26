install: install-mutt

MUTT_DIRS=.config/mutt .cache/mutt .cache/mutt/header .cache/mutt/message
MUTT_DIRS_FQ=$(patsubst %,$(DESTDIR)/%,$(MUTT_DIRS))

$(MUTT_DIRS_FQ):
	mkdir -p "$@"

install-mutt: $(MUTT_DIRS_FQ)
	touch "$(DESTDIR)/.config/mutt/aliases"

INSTALL_PAIRS	+= mutt/muttrc .config/muttrc
INSTALL_PAIRS	+= mutt/config .config/mutt/config.d
MTREE_SOURCES	+= mutt/rules-first.mtree mutt/rules-main.mtree
