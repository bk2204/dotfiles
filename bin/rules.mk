MTREE_SOURCES	+=  bin/rules-first.mtree bin/rules-main.mtree

RUBY_COMPLETION_SOURCES += zsh/completion/_dct-snip
COMPLETION_SOURCES += $(RUBY_COMPLETION_SOURCES)

$(RUBY_COMPLETION_SOURCES): zsh/completion/_%: bin/%
	bin/$(patsubst _%,%,$(@F)) "--*-completion-zsh=$(patsubst _%,%,$(@F))" >$@
