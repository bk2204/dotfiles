INSTALL_DIRS	+= .config/git
MTREE_SOURCES	+= git/rules-first.mtree git/rules-main.mtree

git/xdg-git-config.gen: git/gitconfig

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= git/xdg-git-config.gen
INSTALL_PAIRS	+= git/xdg-git-config.gen .config/git/config
MTREE_SOURCES	+= git/rules-template.mtree
else
INSTALL_PAIRS	+= git/gitconfig .config/git/config
MTREE_SOURCES	+= git/rules-fallback.mtree
endif
