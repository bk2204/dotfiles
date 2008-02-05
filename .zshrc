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

autoload -U promptinit

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

# Succeed.
true
