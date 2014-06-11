# brian m. carlson's zshenv.

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
manpath=(~/man /usr/share/man /usr/X11R6/man /usr/local/share/man)
path=(~/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin /usr/bin/X11 /usr/games)
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
LESS="-R"
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
local i
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

# Export other variables.
#export LC_ALL
#export _POSIX2_VERSION POSIXLY_PEDANTIC POSIXLY_CORRECT
#export CVS_RSH
#export BK_LICENSE
#export ARCH_BACKEND
#export BZREMAIL BZR_EMAIL
#export GIT_COMMITER_EMAIL GIT_AUTHOR_EMAIL
#export LARCH_PATH LCLIMPORTDIR
#export PERLDOC_PAGER
#export DEBEMAIL DEBFULLNAME
#export HOSTNAME
#export VISUAL EDITOR EMAIL BROWSER
true
