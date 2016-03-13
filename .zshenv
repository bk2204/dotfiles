# brian m. carlson's zshenv.

# Useful functions used in this file.  General definitions go in .zshrc.
has_locale () {
	local locale="$1"

	[ -x "$(which perl)" ] || return 0
	perl -MPOSIX=locale_h -E 'exit !setlocale(LC_ALL, $ARGV[0]);' "$locale" \
		2>/dev/null
}

preferred_locale () {
	local locale=$(printf "$LANG\n" | sed -e 's/.utf8$/.UTF-8/')
	# If we're using English, prefer US English; otherwise, accept English,
	# Spanish, or French locales.  Otherwise, fall back to US English.
	if [[ -z ${locale##en*.UTF-8} ]] && has_locale 'en_US.UTF-8'; then
		printf "en_US.UTF-8"
		return 0
	elif [[ -z ${locale##(en|es|fr)*.UTF-8} ]]; then
		printf "$locale"
		return 0
	fi
	printf "en_US.UTF-8"
}

setup_browser () {
	local i=""
	for i in firefox iceweasel chromium-browser chromium google-chrome
	do
		if command -v "$i" >/dev/null 2>&1
		then
			export BROWSER="$i"
			break
		fi
	done
}

is_ssh_session ()
{
	[[ -n $SSH_CLIENT ]] || [[ -n $SSH_CONNECTION ]] || [[ -n $SSH_TTY ]]
}

setup_ssh_agent () {
	is_ssh_session && return
	grep enable-ssh-support ~/.gnupg/gpg-agent.conf 2>/dev/null | \
		grep -qsv '^#' || return
	gpg-connect-agent /bye >/dev/null 2>&1
	export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
}

# Set up some limits.
unlimit
limit core 0
limit stack 8192
limit memoryuse 1048576k

# Set up umask.  If we have private groups, use 002; otherwise, use 022.
if [[ $(id -u -n) = $(id -g -n) ]]; then
	umask 002
else
	umask 022
fi

ANDROID_HOME="$HOME/apps/android-sdk"
export ANDROID_HOME

# Nuke dupes.
typeset -U path cdpath manpath fpath

# Set up miscellaneous paths.
manpath=(~/man /usr/share/man /usr/local/share/man)
path=(~/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin /usr/games $ANDROID_HOME/tools $ANDROID_HOME/platform-tools)
fpath=($fpath[2,-1] ~/.zsh)

# Export miscellaneous paths.
export MANPATH PATH

# Set other variables.
setopt allexport

LANG=$(preferred_locale)
LC_ADDRESS=en_US.UTF-8
LC_COLLATE=$(preferred_locale)
LC_CTYPE=$(preferred_locale)
LC_IDENTIFICATION=$(preferred_locale)
LC_MONETARY=en_US.UTF-8
LC_MEASUREMENT=POSIX
LC_MESSAGES=$(preferred_locale)
LC_NAME=$(preferred_locale)
LC_NUMERIC=en_US.UTF-8
LC_PAPER=en_US.UTF-8
LC_TIME=POSIX
LC_TELEPHONE=en_US.UTF-8
TZ=UTC

CVS_RSH=ssh
DEBFULLNAME="brian m. carlson"
EMAIL="sandals@crustytoothpaste.net"
DEBEMAIL="$EMAIL"
GIT_COMMITTER_EMAIL="$EMAIL"
GROFF_TMAC_PATH="$HOME/checkouts/tenorsax-resources/tmac"
GIT_PAGER="less -FRSX"
PAGER="less -R"
PERLDOC_PAGER="$PAGER"
LESS="-fR"
EDITOR=$(which vimx >/dev/null 2>&1 && echo "vimx" || echo "vim")
GIT_MERGE_AUTOEDIT=no
XML_CATALOG_FILES="$HOME/.crustytoothpaste/groups/metadata/xml-catalogs/catalog.xml"
# Don't prompt for credentials, just fail.
GIT_ASKPASS="/bin/echo"
MODULE_SIGNATURE_CIPHER=SHA512

if [[ ! -e "$XML_CATALOG_FILES" ]]; then
	unset XML_CATALOG_FILES
fi
if [[ -n $DISPLAY ]]; then
	EDITOR="gvim-f"
fi
if [[ -z $HOSTNAME ]]; then
	HOSTNAME=$(hostname)
fi
if has_locale en_DK.UTF-8; then
	LC_TIME=en_DK.UTF-8
fi

VISUAL="$EDITOR"

unsetopt allexport
# End exporting variables.

setup_browser
setup_ssh_agent

unfunction has_locale
unfunction preferred_locale
unfunction setup_browser
unfunction setup_ssh_agent

true
