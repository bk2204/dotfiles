MTREE_SOURCES	+= misc/rules-first.mtree misc/rules-main.mtree

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= misc/Xsession.gen
MTREE_SOURCES	+= misc/rules-template.mtree
endif
