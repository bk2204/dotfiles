MTREE_SOURCES	+= ssh/rules-first.mtree

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= ssh/config.gen
MTREE_SOURCES	+= ssh/rules-template.mtree
endif
