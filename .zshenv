# brian m. carlson's zshenv.

# Useful functions used in this file.  General definitions go in .zshrc.
function has_locale () {
	local locale="$1"

	# On Debian sid, locale always exits successfully, but prints messages to
	# standard error if the locale doesn't exist.  Sanity-check that this is the
	# case for other versions by using the same algorithm for C, which we know
	# exists.  If this assumption is violated, assume the locale does not exist.
	[[ -z "$(LC_ALL=C locale 2>&1 >/dev/null)" ]] && \
		[[ -z "$(LC_ALL="$locale" locale 2>&1 >/dev/null)" ]] && return 0
	return 1
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

# Nuke dupes.
typeset -U path cdpath manpath fpath

# Set up miscellaneous paths.
manpath=(~/man /usr/share/man /usr/local/share/man)
path=(~/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin /usr/games)
fpath=($fpath[2,-1] ~/.zsh)

# Export miscellaneous paths.
export MANPATH PATH

# Set other variables.
setopt allexport

LANG=en_US.UTF-8
LC_ADDRESS=en_US.UTF-8
LC_COLLATE=en_US.UTF-8
LC_CTYPE=en_US.UTF-8
LC_IDENTIFICATION=en_US.UTF-8
LC_MONETARY=en_US.UTF-8
LC_MEASUREMENT=en_US.UTF-8
LC_MESSAGES=en_US.UTF-8
LC_NAME=en_US.UTF-8
LC_NUMERIC=en_US.UTF-8
LC_PAPER=en_US.UTF-8
LC_TIME=POSIX
LC_TELEPHONE=en_US.UTF-8
TZ=UTC

CVS_RSH=ssh
BK_LICENSE=ACCEPTED
ARCH_BACKEND=baz
DEBFULLNAME="brian m. carlson"
EMAIL="sandals@crustytoothpaste.net"
DEBEMAIL="$EMAIL"
BZREMAIL="$EMAIL"
BZR_EMAIL="$EMAIL"
GIT_COMMITTER_EMAIL="$EMAIL"
GIT_AUTHOR_EMAIL="$EMAIL"
GROFF_TMAC_PATH="$HOME/checkouts/tenorsax/tmac"
LARCH_PATH=/usr/share/splint/lib/
LCLIMPORTDIR=/usr/share/splint/imports/
PERLDOC_PAGER="less -R"
GIT_PAGER="less -FRSX"
PAGER="less -R"
LESS="-fR"
EDITOR=vim
GIT_MERGE_AUTOEDIT=no
CLICOLOR=1
FAKE_TAR_LOG="$HOME/fake-tar-log"
XML_CATALOG_FILES="$HOME/.crustytoothpaste/groups/metadata/xml-catalogs/catalog.xml"

if [[ ! -e "$XML_CATALOG_FILES" ]]; then
	unset XML_CATALOG_FILES
fi
if [[ -n $DISPLAY ]]; then
	EDITOR="gvim-f"
fi
if [[ -z $HOSTNAME ]]; then
	HOSTNAME=`hostname`
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

unfunction has_locale

true
