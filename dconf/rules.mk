DCONF_FILES		+= dconf/org.mate.marco.dconf

ifneq ($(DCONF),)
install-extra: install-extra-dconf

install-extra-dconf: $(DCONF_FILES)
	for i in $(DCONF_FILES); \
	do \
		root="/$$(echo "$$(basename "$$i" .dconf)" | sed -e 's!\.!/!g')/"; \
		$(DCONF) load -f "$$root" < "$$i";\
	done
endif
