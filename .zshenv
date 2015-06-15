# brian m. carlson's zshenv.

# Useful functions used in this file.  General definitions go in .zshrc.
function has_locale () {
	local locale="$1"

	[ -x "$(which perl)" ] || return 0
	perl -MPOSIX=locale_h -E 'exit !setlocale(LC_ALL, $ARGV[0]);' "$locale" \
		2>/dev/null
}

function preferred_locale () {
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
function setup_tmp () {
	if [[ -z $TMPDIR ]] || [[ $TMPDIR = /tmp ]]
	then
		local uid=$(id -u)
		local upath="/tmp/user/$uid"
		if [[ -d $upath ]] && [[ -O $upath ]]
		then
			TMPDIR="$upath"
			chmod 700 "$TMPDIR"
		else
			mkdir -p "$upath" && chown $(id -un) "$TMPDIR" && {
				TMPDIR="$upath"
				chmod 700 "$TMPDIR"
			}
		fi
	fi
	[[ -n $TMPDIR ]] && export TMPDIR
	[[ -z $TMP ]] && export TMP=$TMPDIR
	[[ -z $TEMP ]] && export TEMP=$TMPDIR
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
LARCH_PATH=/usr/share/splint/lib/
LCLIMPORTDIR=/usr/share/splint/imports/
PERLDOC_PAGER="less -R"
GIT_PAGER="less -FRSX"
PAGER="less -R"
LESS="-fR"
EDITOR=vim
GIT_MERGE_AUTOEDIT=no
CLICOLOR=1
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
local i=""
for i in chromium-browser chromium google-chrome iceweasel firefox
do
	if command -v "$i" >/dev/null 2>&1
	then
		BROWSER="$i"
		break
	fi
done

VISUAL="$EDITOR"

unsetopt allexport
# End exporting variables.

setup_tmp

unfunction has_locale
unfunction preferred_locale
unfunction setup_tmp

true
