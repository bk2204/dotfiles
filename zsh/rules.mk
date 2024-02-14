INSTALL_DIRS    += .config/zsh

INSTALL_PAIRS	+= zsh/zshenv     .zshenv
INSTALL_PAIRS	+= zsh/zshrc      .zshrc
INSTALL_PAIRS	+= zsh/zlogout    .zlogout
INSTALL_PAIRS	+= zsh/zprofile   .zprofile
INSTALL_PAIRS	+= zsh/functions  .zsh

ifeq ($(TEMPLATE),1)
TEMPLATE_FILES	+= zsh/zshenvlocal.gen
INSTALL_PAIRS	+= zsh/zshenvlocal.gen .config/zsh/zshenvlocal
endif
