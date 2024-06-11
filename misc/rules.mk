INSTALL_PAIRS	+= misc/dircolors	.dircolors
INSTALL_PAIRS	+= misc/libao		.libao
INSTALL_PAIRS	+= misc/mailcap		.mailcap
INSTALL_PAIRS	+= misc/Xsession	.Xsession
INSTALL_PAIRS	+= misc/Xmodmap		.Xmodmap
INSTALL_PAIRS	+= misc/lawn.yaml	.config/lawn/config.yaml
INSTALL_PAIRS	+= misc/alacritty.yml	.config/alacritty/alacritty.yml
INSTALL_PAIRS	+= misc/alacritty.toml	.config/alacritty/alacritty.toml

# If this is missing, Clementine using last.fm won't scrobble.
INSTALL_DIRS	+= .local/share/Last.fm .config/lawn .config/alacritty

MTREE_SOURCES	+=  bin/rules-first.mtree bin/rules-main.mtree

install:
