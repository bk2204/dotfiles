KDE_FILES		+= kde/kwin.yaml

ifneq ($(KWRITECONFIG),)
install-extra: install-extra-kde

install-extra-kde: $(KDE_FILES)
	for i in $(KDE_FILES); \
	do \
		command -v ruby >/dev/null 2>&1 && \
		dct-snip -r installconfig -f "$$i";\
	done
endif
