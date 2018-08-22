SIGNATURES		= auricblue personal
INSTALL_PAIRS	= $(foreach s,$(SIGNATURES),signature/$s .signature-$s)
