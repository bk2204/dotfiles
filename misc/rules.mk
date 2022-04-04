INSTALL_PAIRS	+= misc/dircolors	.dircolors
INSTALL_PAIRS	+= misc/libao		.libao
INSTALL_PAIRS	+= misc/mailcap		.mailcap
INSTALL_PAIRS	+= misc/Xsession	.Xsession
INSTALL_PAIRS	+= misc/lawn.yaml	.config/lawn/config.yaml

# If this is missing, Clementine using last.fm won't scrobble.
INSTALL_DIRS	+= .local/share/Last.fm .config/lawn

install: install-misc

install-misc:
	touch $(DESTDIR)/.xmodmap
