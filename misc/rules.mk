INSTALL_PAIRS	+= misc/dircolors	.dircolors
INSTALL_PAIRS	+= misc/fbtermrc	.fbtermrc
INSTALL_PAIRS	+= misc/libao		.libao
INSTALL_PAIRS	+= misc/mailcap		.mailcap
INSTALL_PAIRS	+= misc/Xsession	.Xsession

install: install-misc

install-misc:
	touch $(DESTDIR)/.xmodmap
