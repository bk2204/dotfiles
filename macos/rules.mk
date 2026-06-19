MACOS_FILES		+= macos/config.yaml

ifneq ($(DEFAULTSCMD),)
install-extra: install-extra-macos

install-extra-macos: $(MACOS_FILES)
	for i in $(MACOS_FILES); \
	do \
		command -v ruby >/dev/null 2>&1 && \
		snippets/exec/installconfig -d macos -f "$$i";\
	done
endif
