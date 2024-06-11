SIGNATURES		= auricblue personal
INSTALL_PAIRS	+= $(foreach s,$(SIGNATURES),signature/$s .signature-$s)
MTREE_SOURCES	+= signature/rules-main.mtree
