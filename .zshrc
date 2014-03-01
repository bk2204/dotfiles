# brian m. carlson's zshrc.
# For interactive use.

# Set up some aliases.
if ls --color=auto >/dev/null 2>/dev/null
then
	alias ls='ls --color=auto'
fi
if which prename >/dev/null 2>&1
then
	alias rename='prename'
fi

alias loadenv='eval `cat $HOME/.environment`'

# Set prompts.
PROMPT='%n@%m:%~(%?%)%# '

# Set options.
setopt shwordsplit bareglobqual
setopt interactivecomments
setopt promptsubst
setopt rmstarsilent
unsetopt bgnice notify nomatch banghist

# Set history.
HISTSIZE=10000
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history

# Set key bindings.
bindkey -v
bindkey '^I' complete-word
bindkey '^R' history-incremental-search-backward
bindkey '^S' history-incremental-search-forward
bindkey '\eOF' vi-end-of-line
bindkey '\eOH' vi-beginning-of-line

# Some useful features.
source_if_present ()
{
	fn="$1"
	[[ -f $fn ]] && source "$fn"
}
is_ssh_session ()
{
	[[ -n $SSH_CLIENT ]] || [[ -n $SSH_CONNECTION ]] || [[ -n $SSH_TTY ]]
}
is_sudo_session ()
{
	[[ -n $SUDO_COMMAND ]] || [[ -n $SUDO_USER ]] || [[ -n $SUDO_UID ]]
}
is_kerberos_session ()
{
	whence klist >/dev/null && klist -5s
}
is_pseudo_tty ()
{
	echo $TTY | grep pts >/dev/null
}
set_tty ()
{
	[[ -n $TTY ]] && return 0
	[[ -n $GPG_TTY ]] && TTY=$GPG_TTY && return 0
	[[ -n $SSH_TTY ]] && TTY=$SSH_TTY && return 0
	TTY=`tty` || TTY=""
}
has_term ()
{
	local termname="$1"
	TERM=$termname echotc xo >/dev/null 2>/dev/null
}
set_sane_term ()
{
	# Make sure our terminal definition works right.
	if ! echotc xo >/dev/null 2>/dev/null
	then
		# No column results?  Do we have any working terminal definitions?
		local echotc_works=""
		for i in vt220 ansi xterm linux dumb
		do
			if has_term $i
			then
				# Yes, we do.
				echotc_works=1
				break
			fi
		done
		# Yes, we do, so we just have a bad TERM definition. vt220 is a good
		# fallback.
		if [[ -n $echotc_works ]]
		then
			local -a preferred
			if [[ ${TERM#screen} != ${TERM} ]]
			then
				preferred=(screen vt220)
			elif [[ -z ${TERM:#*256color} ]]
			then
				preferred=(xterm-256color xterm vt220)
			else
				preferred=(vt220)
			fi
			for i in $preferred
			do
				has_term $i && export TERM=$i
				break
			done
		fi
	fi
	is_ssh_session && [[ $SSH_TTY == $TTY ]] && return 0
	# Add the * to the end to catch the potential " (deleted)" that may occur.
	case "$TERM:`readlink /proc/$PPID/exe`" in
		xterm:*xfce4-terminal*)
			has_term xterm-256color && export TERM=xterm-256color;;
		xterm:*gnome-terminal*)
			has_term xterm-256color && export TERM=xterm-256color;;
		xterm:*evilvte*)
			has_term xterm-256color && export TERM=xterm-256color;;
		xterm:*konsole*)
			has_term konsole-256color && export TERM=konsole-256color;;
		screen*:*)
			EDITOR=vim;
			has_term screen-256color && export TERM=screen-256color;;
		rxvt:*mrxvt-full*)
			has_term rxvt-256color && export TERM=rxvt-256color;;
		*) ;;
	esac

	# Turn off flow control.
	stty -ixon -ixoff >/dev/null 2>&1

	if which tabs >/dev/null && which perl >/dev/null && [[ -n $COLUMNS ]]
	then
		# Set up 4-space tabs.
		tabs $(seq 1 4 $COLUMNS | perl -0777pe 's/\n/,/g')
	fi

	# Make sure that other people can't mess with our terminal.
	mesg n >/dev/null 2>&1
}
set_keybindings () {
	# Set up key handling for non-Debian systems.  This is already handled
	# properly in Debian, since this code has been taken from Debian's
	# /etc/zsh/zshrc.
	typeset -A key
	key=(
		BackSpace  "${terminfo[kbs]}"
		Home       "${terminfo[khome]}"
		End        "${terminfo[kend]}"
		Insert     "${terminfo[kich1]}"
		Delete     "${terminfo[kdch1]}"
		Up         "${terminfo[kcuu1]}"
		Down       "${terminfo[kcud1]}"
		Left       "${terminfo[kcub1]}"
		Right      "${terminfo[kcuf1]}"
		PageUp     "${terminfo[kpp]}"
		PageDown   "${terminfo[knp]}"
	)

	function bind2maps () {
		local i sequence widget
		local -a maps

		while [[ "$1" != "--" ]]; do
			maps+=( "$1" )
			shift
		done
		shift

		sequence="${key[$1]}"
		widget="$2"

		[[ -z "$sequence" ]] && return 1

		for i in "${maps[@]}"; do
			bindkey -M "$i" "$sequence" "$widget"
		done
	}

	bind2maps emacs             -- BackSpace   backward-delete-char
	bind2maps       viins       -- BackSpace   vi-backward-delete-char
	bind2maps             vicmd -- BackSpace   vi-backward-char
	bind2maps emacs             -- Home        beginning-of-line
	bind2maps       viins vicmd -- Home        vi-beginning-of-line
	bind2maps emacs             -- End         end-of-line
	bind2maps       viins vicmd -- End         vi-end-of-line
	bind2maps emacs viins       -- Insert      overwrite-mode
	bind2maps             vicmd -- Insert      vi-insert
	bind2maps emacs             -- Delete      delete-char
	bind2maps       viins vicmd -- Delete      vi-delete-char
	bind2maps emacs viins vicmd -- Up          up-line-or-history
	bind2maps emacs viins vicmd -- Down        down-line-or-history
	bind2maps emacs             -- Left        backward-char
	bind2maps       viins vicmd -- Left        vi-backward-char
	bind2maps emacs             -- Right       forward-char
	bind2maps       viins vicmd -- Right       vi-forward-char

	unfunction bind2maps
}

# Do this before any sort of importing or prompt setup, so that the prompt can
# take advantage of terminal features such as 256-color support.
set_sane_term
set_keybindings

if is_ssh_session
then
	(
		[[ -n $SSH_AUTH_SOCK ]] && print "SSH_AUTH_SOCK=$SSH_AUTH_SOCK";
		[[ -n $DISPLAY ]] && print "DISPLAY=$DISPLAY";
	) > $HOME/.environment
fi

VISUAL="$EDITOR"

# Autoload some stuff.
for func in $^fpath/*(.:t);
do
	if [[ -n $func ]]; then
		autoload -U $func
	fi
done

for i in promptinit compctl complete complist computil;
do
	autoload -U $i
done
compinit -u 2>/dev/null

choose_prompt () {
	local km=$1
	[[ -n $km ]] || km=$KEYMAP
	case $km in
		vicmd)		psvar[3]="◈◈";;
		viins|main)	psvar[3]=();;
	esac
}

function zle-keymap-select {
	choose_prompt
	zle reset-prompt
}

function zle-line-init () {
	if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
		emulate -L zsh
		printf '%s' ${terminfo[smkx]}
	fi
	choose_prompt "main"
}
function zle-line-finish () {
	if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
		emulate -L zsh
		printf '%s' ${terminfo[rmkx]}
	fi
	choose_prompt "main"
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select

# Set up the prompt.
promptinit
prompt bmc

# This is from grml.  GPLv2.
setup_completion ()
{
	# don't complete backup files as executables
	zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

	# start menu completion only if it could find no unambiguous initial string
	zstyle ':completion:*:correct:*'       insert-unambiguous true
	zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
	zstyle ':completion:*:correct:*'       original true

	# activate color-completion
	zstyle ':completion:*:default'         list-colors ${(s.:.)LS_COLORS}

	# format on completion
	zstyle ':completion:*:descriptions'    format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'

	# complete 'cd -<tab>' with menu
	zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

	# insert all expansions for expand completer
	zstyle ':completion:*:expand:*'        tag-order all-expansions
	zstyle ':completion:*:history-words'   list false

	# activate menu
	zstyle ':completion:*:history-words'   menu yes

	# ignore duplicate entries
	zstyle ':completion:*:history-words'   remove-all-dups yes
	zstyle ':completion:*:history-words'   stop yes

	# match uppercase from lowercase
	zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'

	# separate matches into groups
	zstyle ':completion:*:matches'         group 'yes'
	zstyle ':completion:*'                 group-name ''

	# don't use any menus at all
	setopt no_auto_menu

	zstyle ':completion:*:messages'        format '%d'
	zstyle ':completion:*:options'         auto-description '%d'

	# describe options in full
	zstyle ':completion:*:options'         description 'yes'

	# on processes completion complete all user processes
	zstyle ':completion:*:processes'       command 'ps -au$USER'

	# offer indexes before parameters in subscripts
	zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

	# provide verbose completion information
	zstyle ':completion:*'                 verbose true

	# recent (as of Dec 2007) zsh versions are able to provide descriptions
	# for commands (read: 1st word in the line) that it will list for the user
	# to choose from. The following disables that, because it's not exactly fast.
	zstyle ':completion:*:-command-:*:'    verbose false

	# set format for warnings
	zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'

	# define files to ignore for zcompile
	zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
	zstyle ':completion:correct:'          prompt 'correct to: %e'

	# Ignore completion functions for commands you don't have:
	zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

	# Provide more processes in completion of programs like killall:
	zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

	# complete manual by their section
	zstyle ':completion:*:manuals'    separate-sections true
	zstyle ':completion:*:manuals.*'  insert-sections   true
	zstyle ':completion:*:man:*'      menu yes select

	# Search path for sudo completion
	zstyle ':completion:*:sudo:*' command-path \
		/usr/local/sbin \
		/usr/local/bin  \
		/usr/sbin       \
		/usr/bin        \
		/sbin           \
		/bin			\
		$HOME/bin

	# provide .. as a completion
	zstyle ':completion:*' special-dirs ..

	# run rehash on completion so new installed program are found automatically:
	_force_rehash() {
		(( CURRENT == 1 )) && rehash
		return 1
	}
	zstyle ':completion:*' completer _oldlist _expand _force_rehash _complete _files _ignored
	setopt nocorrect

	# command for process lists, the local web server details and host completion
	zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

	# caching
	[[ -d $ZSHDIR/cache ]] && zstyle ':completion:*' use-cache yes && \
		zstyle ':completion::complete:*' cache-path $ZSHDIR/cache/

	# host completion /* add brackets as vim can't parse zsh's complex cmdlines 8-) {{{ */
	[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
	[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
	hosts=(
	$(hostname)
	"$_ssh_hosts[@]"
	"$_etc_hosts[@]"
	localhost
	)
	zstyle ':completion:*:hosts' hosts $hosts
	#  zstyle '*' hosts $hosts

	# specify your logins:
	# my_accounts=(
	#  {grml,grml1}@foo.invalid
	#  grml-devel@bar.invalid
	# )
	# other_accounts=(
	#  {fred,root}@foo.invalid
	#  vera@bar.invalid
	# )
	# zstyle ':completion:*:my-accounts' users-hosts $my_accounts
	# zstyle ':completion:*:other-accounts' users-hosts $other_accounts

	# specify specific port/service settings:
	#  telnet_users_hosts_ports=(
	#    user1@host1:
	#    user2@host2:
	#    @mail-server:{smtp,pop3}
	#    @news-server:nntp
	#    @proxy-server:8000
	#  )
	# zstyle ':completion:*:*:telnet:*' users-hosts-ports $telnet_users_hosts_ports

	# use generic completion system for programs not yet defined; (_gnu_generic works
	# with commands that provide a --help option with "standard" gnu-like output.)
	for compcom in	cp deborphan df feh fetchipac head hnb ipacsum mv \
		pal stow tail uname ; do
		[[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
	done; unset compcom

	# see upgrade function in this file
	compdef _hosts upgrade

	# Fix extreme slowness in large repositories.
	function __git_files () {
		_wanted files expl 'local files' _files
	}
}

# Set locales.
set_tty

blue="blue"
[[ $(echotc Co) = 256 ]] && blue=33

# Set up termcap colors for less (from grml).
export LESS_TERMCAP_mb=`print -P $(color_fg red yes)`
export LESS_TERMCAP_md=`print -P $(color_fg red yes)`
export LESS_TERMCAP_me=`print -P $(color_reset)`
export LESS_TERMCAP_se=`print -P $(color_reset)`
export LESS_TERMCAP_so=`print -P $(color_fg $blue yes)`
export LESS_TERMCAP_ue=`print -P $(color_reset)`
export LESS_TERMCAP_us=`print -P $(color_fg green yes)`

# Help less handle compressed files better.
whence lesspipe >/dev/null && eval $(lesspipe)

setup_completion

unset i blue

# Succeed.
true
