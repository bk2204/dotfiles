INSTALL_PAIRS	+= git/gitconfig .gitconfig
INSTALL_DIRS	+= .config/git

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= git/xdg-git-config.gen
INSTALL_PAIRS	+= git/xdg-git-config.gen .config/git/config
endif
