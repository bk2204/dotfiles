install: install-mutt

MUTT_DIRS=.mutt .mutt/header_cache .mutt/message_cache
MUTT_DIRS_FQ=$(patsubst %,$(DESTDIR)/%,$(MUTT_DIRS))

$(MUTT_DIRS_FQ):
	mkdir -p "$@"

install-mutt: $(MUTT_DIRS_FQ)
	touch "$(DESTDIR)/.mutt/aliases"

INSTALL_PAIRS	+= mutt/muttrc .muttrc
INSTALL_PAIRS	+= mutt/config .mutt/config
MTREE_SOURCES	+= mutt/rules-first.mtree mutt/rules-main.mtree
