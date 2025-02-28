MTREE_SOURCES	+= zsh/rules-first.mtree zsh/rules-main.mtree

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= zsh/zshenvlocal.gen

MTREE_SOURCES	+= zsh/rules-template.mtree
endif
