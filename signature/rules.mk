SIGNATURES		= auricblue personal
INSTALL_DIRS	+= .config/signature
INSTALL_PAIRS	+= $(foreach s,$(SIGNATURES),signature/$s .config/signature/$s)
MTREE_SOURCES	+= signature/rules-first.mtree signature/rules-main.mtree
