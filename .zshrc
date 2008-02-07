# brian m. carlson's zshrc.
# For interactive use.

# Set up some aliases.
alias ls='ls --color=auto'

# Set prompts.
PROMPT='%n@%m:%~(%?%)%# '

# Set options.
setopt shwordsplit bareglobqual
#setopt promptsubst
unsetopt bgnice notify nomatch

# Set history.
HISTSIZE=400
SAVEHIST=$HISTSIZE
HISTFILE=~/.zsh_history

# Set key bindings.
bindkey -v
bindkey '^I' complete-word
bindkey '\eOF' vi-end-of-line
bindkey '\eOH' vi-beginning-of-line

# Autoload some stuff.
for func in $^fpath/*(.:t);
do
	if [[ -n $func ]]; then
		autoload $func
	fi
done

for i in promptinit compctl complete complist computil;
do
	autoload -U $i
done
compinit 2>/dev/null

# Set up the prompt.
promptinit
prompt bmc

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
	command -v klist >/dev/null && klist -5s
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
set_sane_term ()
{
	is_ssh_session && return 0
	case "$TERM:`readlink /proc/$PPID/exe`" in
		xterm:*gnome-terminal)
			export TERM=gnome-256color;;
		*) ;;
	esac
}
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

	# complete manual by their section
	zstyle ':completion:*:manuals'    separate-sections true
	zstyle ':completion:*:manuals.*'  insert-sections   true
	zstyle ':completion:*:man:*'      menu yes select

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
	compdef _gnu_generic tail head feh cp mv df stow uname ipacsum fetchipac

	# see upgrade function in this file
	compdef _hosts upgrade
}

# Set locales.
set_tty
if is_pseudo_tty; then
	LC_ALL=en_US.UTF-8
	export LC_ALL
fi

# Set up keychain stuff.
if ! is_ssh_session && ! is_sudo_session && ! is_kerberos_session; then
	ssh_keys=(id_rsa id_dsa)
	gpg_keys=`perl -ne 'print "$1\n" if (/^default-key\s+([A-Fa-f0-9]{8})/);' ~/.gnupg/gpg.conf`
	existing_keys=()
	for key in $ssh_keys;
	do
		[[ -f ~/.ssh/$key ]] && existing_keys=($existing_keys $key)
	done
	# 10080 minutes is 1 week.
	which keychain >/dev/null && keychain --timeout 10080 -q $existing_keys $gpg_keys
	source_if_present $HOME/.keychain/$HOSTNAME-sh
	source_if_present $HOME/.keychain/$HOSTNAME-sh-gpg

	# Set up keychain environment variables.
	GPG_TTY=`tty`
	export GPG_TTY
fi

# Set up termcap colors for less (from grml).
export LESS_TERMCAP_mb="$fg_bold[red]"
export LESS_TERMCAP_md="$fg_bold[red]"
export LESS_TERMCAP_me="$reset_color"
export LESS_TERMCAP_se="$reset_color"
export LESS_TERMCAP_so="$bg_bold[blue]$fg_bold[yellow]"
export LESS_TERMCAP_ue="$reset_color"
export LESS_TERMCAP_us="$fg_bold[green]"

set_sane_term
setup_completion

# Succeed.
true
