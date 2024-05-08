INSTALL_PAIRS	+= misc/dircolors	.dircolors
INSTALL_PAIRS	+= misc/libao		.libao
INSTALL_PAIRS	+= misc/mailcap		.mailcap
INSTALL_PAIRS	+= misc/Xsession	.Xsession
INSTALL_PAIRS	+= misc/Xmodmap		.Xmodmap
INSTALL_PAIRS	+= misc/lawn.yaml	.config/lawn/config.yaml
INSTALL_PAIRS	+= misc/alacritty.yml	.config/alacritty/alacritty.yml
INSTALL_PAIRS	+= misc/alacritty.toml	.config/alacritty/alacritty.toml
INSTALL_PAIRS	+= misc/azure-config	.azure/config

# If this is missing, Clementine using last.fm won't scrobble.
INSTALL_DIRS	+= .local/share/Last.fm .config/lawn .config/alacritty .azure

LINK_PAIRS		+= /dev/null .azure/az_survey.json
LINK_PAIRS		+= /dev/null .azure/telemetry
LINK_PAIRS		+= /dev/null .azure/telemetry.txt

MTREE_SOURCES	+= misc/rules-first.mtree misc/rules-main.mtree

install:
