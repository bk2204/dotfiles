INSTALL_DIRS	+= .config/tmux

INSTALL_PAIRS	+= tmux/tmux.conf	.tmux.conf
INSTALL_PAIRS	+= tmux/tmux-overmind.conf	.config/tmux/tmux-overmind.conf
INSTALL_PAIRS	+= tmux/tmuxinator	.config/tmuxinator
MTREE_SOURCES	+= tmux/rules-first.mtree tmux/rules-main.mtree
