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
        printf '%s' "$locale"
        return 0
    fi
    printf "en_US.UTF-8"
}

setup_browser () {
    setopt localoptions shwordsplit
    local i=""
    local chrome="google-chrome-beta chromium-browser chromium google-chrome"
    local firefox="firefox iceweasel"
    for i in $chrome $firefox
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

# Return true if our home directory is owned by someone other than us.
is_privileged ()
{
    zmodload -F zsh/stat b:zstat
    [ "$(zstat -L +uid "$HOME")" -ne "$(id -u)" ]
}

setup_ssh_agent () {
    local i
    is_ssh_session && return
    is_privileged && return
    grep enable-ssh-support ~/.gnupg/gpg-agent.conf 2>/dev/null | \
        grep -qsv '^#' || return
    gpg-connect-agent /bye >/dev/null 2>&1
    for i in "$(gpgconf --list-dirs | grep '^agent-socket:' | cut -d: -f2)" \
        "$HOME/.gnupg/S.gpg-agent" \
        "/run/user/$(id -u)/gnupg/S.gpg-agent"
    do
        [[ -S "$i.ssh" ]] && export SSH_AUTH_SOCK="$i.ssh"
    done
}

setup_temp () {
    local i
    for i in "$TMPDIR" "$TEMPDIR" "$TMP" "$TEMP" "/tmp"
    do
        if [[ -n $i ]]
        then
            # This is the POSIX variable.
            export TMPDIR="$i"
            export TEMPDIR="$i"
            # This is the short, easy-to-type variable.
            export TMP="$i"
            export TEMP="$i"
            return
        fi
    done
}

bmc_editor () {
    if [[ -n $DISPLAY ]] && [[ $1 != console ]]
    then
        printf 'gvim -f'
    elif [[ $TERM = dumb ]]
    then
        printf 'ex'
    elif which vimx >/dev/null 2>&1
    then
        printf 'vimx'
    elif which vim >/dev/null 2>&1
    then
        printf 'vim'
    else
        # Really?
        printf 'vi'
    fi
}

source_if_present ()
{
    local fn="$1"
    [[ -f $fn ]] && source "$fn"
}

# Set up some limits.
unlimit
limit core 0
limit stack 8192

# Set up umask.  If we have private groups, use 002; otherwise, use 022.
if [[ $(id -u -n) = $(id -g -n) ]]; then
    umask 002
else
    umask 022
fi

# Prevent tampering with our config.
unsetopt globalrcs

ANDROID_HOME="$HOME/apps/android-sdk"
export ANDROID_HOME

# Nuke dupes.
typeset -U path cdpath manpath fpath
typeset -UT COREPATH corepath

# Set up miscellaneous paths.
manpath=(~/man /usr/share/man /usr/local/share/man)
path=(~/bin ~/.rvm/bin /usr/local/bin /usr/local/sbin /usr/bin /usr/sbin /bin /sbin /usr/games $ANDROID_HOME/tools $ANDROID_HOME/platform-tools)
corepath=(/usr/bin /usr/sbin /bin /sbin /usr/games)
fpath=($fpath[2,-1] ~/.zsh)

# Export miscellaneous paths.
export MANPATH PATH COREPATH

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
GROFF_TMAC_PATH="$HOME/checkouts/tenorsax-resources/tmac"
GIT_PAGER="less -FRSX"
PAGER="less -R"
PERLDOC_PAGER="$PAGER"
LESS="-fR"
EDITOR=$(bmc_editor)
VISUAL="$EDITOR"
GIT_MERGE_AUTOEDIT=no
XML_CATALOG_FILES="$HOME/.crustytoothpaste/groups/metadata/xml-catalogs/catalog.xml"
# Don't prompt for credentials, just fail.
GIT_ASKPASS="/bin/echo"
MODULE_SIGNATURE_CIPHER=SHA512

if [[ ! -e "$XML_CATALOG_FILES" ]]; then
    unset XML_CATALOG_FILES
fi
if [[ -z $HOSTNAME ]]; then
    HOSTNAME=$(hostname)
fi
if has_locale en_DK.UTF-8; then
    LC_TIME=en_DK.UTF-8
fi

unsetopt allexport
# End exporting variables.

setup_browser
setup_ssh_agent
setup_temp
source_if_present "$HOME/.rvm/scripts/rvm"

unfunction is_privileged
unfunction has_locale
unfunction preferred_locale
unfunction setup_browser
unfunction setup_ssh_agent
unfunction setup_temp

true
