MACOS_FILES		+= macos/config.yaml

ifneq ($(DEFAULTSCMD),)
install-extra: install-extra-macos

install-extra-macos: $(MACOS_FILES)
	for i in $(MACOS_FILES); \
	do \
		command -v ruby >/dev/null 2>&1 && \
		dct-snip -r installconfig -v -d macos -f "$$i";\
	done
endif
