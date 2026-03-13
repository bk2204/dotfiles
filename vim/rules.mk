MTREE_SOURCES	+= vim/rules-main.mtree

HUNSPELL ?= $(shell command -v hunspell 2>/dev/null)
VIMLIKE ?= $(shell command -v nvim 2>/dev/null || command -v vim 2>/dev/null)
LANGUAGES ?= en_CA en_US es_MX es_US fr_CA fr_FR

ifneq ($(HUNSPELL),)
ifneq ($(VIMLIKE),)
vim/spell:
	mkdir -p $@

vim/spell/spell.d: vim/spell
	snippets/exec/build-vim-spell -d vim/spell --extra-target=vim/rules-spell.mtree -o $@ --depend $(LANGUAGES)

vim/rules-spell.mtree: vim/spell/spell.d

-include vim/spell/spell.d

vim/spell/%.utf-8.spl:
	snippets/exec/build-vim-spell -o $@ --restrict --build $(filter $*_%,$(LANGUAGES))

vim/rules-spell.mtree:
	: >$@
	for i in $^; \
	do \
		if [ -f "$$i" ]; \
		then \
			[ -z "$${i##*.spl}" ] || continue; \
			echo ".vim/spell/$$(basename $$i) type=file mode=0640 src=$$i" >>$@; \
		fi; \
	done

MTREE_SOURCES	+= vim/rules-spell.mtree
GENERATED_FILES += vim/rules-spell.mtree vim/spell
endif
endif
