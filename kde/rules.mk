KDE_FILES		+= kde/kwin.yaml
KDE_FILES		+= kde/kglobalshortcuts.yaml

ifneq ($(KWRITECONFIG),)
install-extra: install-extra-kde

install-extra-kde: $(KDE_FILES)
	for i in $(KDE_FILES); \
	do \
		if command -v ruby >/dev/null 2>&1; \
		then \
			snippets/exec/installconfig -f "$$i"; \
		fi \
	done
endif
