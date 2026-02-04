MTREE_SOURCES	+= ssh/rules-first.mtree ssh/rules-main.mtree
SSH_AUTHORIZED_SIGNERS = $(wildcard ssh/authorized_signers.d/*)
GENERATED_FILES += ssh/authorized_signers.gen

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= ssh/config.gen ssh/config.d/crustytoothpaste.gen
MTREE_SOURCES	+= ssh/rules-template.mtree
endif

ssh/rules-main.mtree: ssh/authorized_signers.gen

ssh/authorized_signers.gen: $(SSH_AUTHORIZED_SIGNERS)
	cat $^ > $@
