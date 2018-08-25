install: install-mutt

MUTT_DIRS=.mutt .mutt/header_cache .mutt/message_cache
MUTT_DIRS_FQ=$(patsubst %,$(DESTDIR)/%,$(MUTT_DIRS))

$(MUTT_DIRS_FQ):
	mkdir -p "$@"

install-mutt: $(MUTT_DIRS_FQ)

INSTALL_PAIRS	+= mutt/muttrc .muttrc
INSTALL_PAIRS	+= mutt/config .mutt/config
