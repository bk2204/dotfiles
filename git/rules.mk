INSTALL_PAIRS	+= git/gitconfig .gitconfig
INSTALL_DIRS	+= .config/git
MTREE_SOURCES	+= git/rules-first.mtree git/rules-main.mtree

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= git/xdg-git-config.gen
INSTALL_PAIRS	+= git/xdg-git-config.gen .config/git/config
MTREE_SOURCES	+= git/rules-template.mtree
endif
