MACOS_FILES		+= macos/config.yaml

ifneq ($(DEFAULTSCMD),)
install-extra: install-extra-macos

install-extra-macos: $(MACOS_FILES)
	for i in $(MACOS_FILES); \
	do \
		if command -v ruby >/dev/null 2>&1; \
		then \
			snippets/exec/installconfig -d macos -f "$$i"; \
		fi \
	done
endif
