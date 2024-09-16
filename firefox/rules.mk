FIREFOX_PROFILE		?= $(shell (grep "Default=.*\.default*" "$(DESTDIR)/.mozilla/firefox/profiles.ini" | cut -d"=" -f2) 2>/dev/null)
FIREFOX_PROFILE_DIR	?= .mozilla/firefox/$(FIREFOX_PROFILE)

ifneq ($(FIREFOX_PROFILE),)
INSTALL_PAIRS	+= firefox/user.js $(FIREFOX_PROFILE_DIR)/user.js
MTREE_SOURCES	+= firefox/rules-main.mtree

firefox/rules-main.mtree: $(DESTDIR)/.mozilla/firefox/profiles.ini $(DESTDIR)
	echo "firefox/user.js type=file mode=0600 dest=$(FIREFOX_PROFILE_DIR)/user.js" >$@
endif
