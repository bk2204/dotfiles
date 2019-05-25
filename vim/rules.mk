INSTALL_PAIRS	+= vim/vimrc .vimrc
INSTALL_PAIRS	+= vim/after    .vim/after
INSTALL_PAIRS	+= vim/autoload .vim/autoload
INSTALL_PAIRS	+= vim/bundle   .vim/bundle
INSTALL_PAIRS	+= vim/colors   .vim/colors
INSTALL_PAIRS	+= vim/pathogen .vim/pathogen
INSTALL_PAIRS	+= vim/syntax   .vim/syntax

install: install-vim

install-vim: install-dirs
	mkdir -p $(DESTDIR)/.vim
	mkdir -p $(DESTDIR)/.config
	ln -sf ../.vim $(DESTDIR)/.config/nvim
	ln -sf ../.vimrc $(DESTDIR)/.vim/init.vim
