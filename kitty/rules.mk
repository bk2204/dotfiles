MTREE_SOURCES	+= kitty/rules-first.mtree kitty/rules-main.mtree

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= kitty/conf.d/fonts.conf.gen
MTREE_SOURCES	+= kitty/rules-template.mtree
endif
