MTREE_SOURCES	+= git/rules-first.mtree git/rules-main.mtree

git/xdg-git-config.gen: git/gitconfig

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= git/xdg-git-config.gen
MTREE_SOURCES	+= git/rules-template.mtree
else
MTREE_SOURCES	+= git/rules-fallback.mtree
endif
