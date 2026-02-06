UNAME_S := $(shell uname -s)

ifeq ($(UNAME_S),Darwin)
FIREFOX_PROFILE		?= $(shell (grep "Default=.*\.default*" "$(DESTDIR)/Library/Application Support/Firefox/profiles.ini" | cut -d"=" -f2) 2>/dev/null)
FIREFOX_PROFILE_DIR	?= Library/Application Support/Firefox/$(FIREFOX_PROFILE)
else
FIREFOX_PROFILE		?= $(shell (grep "Default=.*\.default*" "$(DESTDIR)/.mozilla/firefox/profiles.ini" | cut -d"=" -f2) 2>/dev/null)
FIREFOX_PROFILE_DIR	?= .mozilla/firefox/$(FIREFOX_PROFILE)
endif

ifneq ($(FIREFOX_PROFILE),)
INSTALL_PAIRS	+= firefox/user.js $(FIREFOX_PROFILE_DIR)/user.js
MTREE_SOURCES	+= firefox/rules-main.mtree

firefox/rules-main.mtree: $(DESTDIR)
	: >$@
	echo ".mozilla type=dir mode=0700" >>$@
	echo ".mozilla/firefox type=dir mode=0700" >>$@
	echo "$$(echo "$(FIREFOX_PROFILE_DIR)" | sed -e 's/ /\\s/g') type=dir mode=0700 src=firefox" >>$@
	echo "$$(echo "$(FIREFOX_PROFILE_DIR)" | sed -e 's/ /\\s/g')/user.js type=file mode=0600 src=firefox/user.js" >>$@

GENERATED_FILES += firefox/rules-main.mtree
endif
