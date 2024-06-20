INSTALL_DIRS    += .config/zsh

INSTALL_PAIRS	+= zsh/zshenv     .zshenv
INSTALL_PAIRS	+= zsh/zshrc      .zshrc
INSTALL_PAIRS	+= zsh/zlogout    .zlogout
INSTALL_PAIRS	+= zsh/zprofile   .zprofile
INSTALL_PAIRS	+= zsh/functions  .zsh

MTREE_SOURCES	+= zsh/rules-first.mtree zsh/rules-main.mtree

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= zsh/zshenvlocal.gen
INSTALL_PAIRS	+= zsh/zshenvlocal.gen .config/zsh/zshenvlocal

MTREE_SOURCES	+= zsh/rules-template.mtree
endif
