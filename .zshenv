# brian m. carlson's zshenv.

# Set up some limits.
unlimit
limit core 0
limit stack 8192
limit memoryuse 1048576k

# Set up umask (sanitized for your protection).
umask 022

# Nuke dupes.
typeset -U path cdpath manpath fpath

# Set up miscellaneous paths.
manpath=(~/man /usr/share/man /usr/X11R6/man /usr/local/share/man)
path=(~/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin /usr/bin/X11 /usr/games)
fpath=($fpath[2,-1] ~/.zfunc)

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
LC_TIME=en_US.UTF-8
LC_TELEPHONE=en_US.UTF-8

CVS_RSH=ssh
BK_LICENSE=ACCEPTED
ARCH_BACKEND=baz
_POSIX2_VERSION=200112
POSIXLY_CORRECT=1
POSIXLY_PEDANTIC=1
DEBFULLNAME="brian m. carlson"
EMAIL="sandals@crustytoothpaste.ath.cx"
DEBEMAIL="$EMAIL"
BZREMAIL="$EMAIL"
BZR_EMAIL="$EMAIL"
GIT_COMMITTER_EMAIL="$EMAIL"
GIT_AUTHOR_EMAIL="$EMAIL"
LARCH_PATH=/usr/share/splint/lib/
LCLIMPORTDIR=/usr/share/splint/imports/
PERLDOC_PAGER="less -R"
EDITOR=vim
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
for i in firefox iceweasel
do
	if command -v "$i" >/dev/null 2>&1
	then
		BROWSER="$i"
		break
	fi
done
unset i

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
