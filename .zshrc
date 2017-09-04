# brian m. carlson's zshrc.
# For interactive use.

# Preparatory functions.
silent () {
    "$@" >/dev/null 2>&1
}
has_colors () {
    [[ $TERM != dumb ]]
}

# Set up some aliases.
silent ls --color=auto && has_colors && alias ls='ls --color=auto'
if silent which file-rename
then
    alias rename='file-rename'
elif silent which prename
then
    alias rename='prename'
fi

local vi=$(bmc_editor console)
if [[ $vi != vi ]]
then
    alias vi=$vi
    [[ $vi != vim ]] && alias vim=$vi
fi
unset vi

has_colors && alias grep='grep --color=auto'
alias rless='env -u LESSOPEN -u LESSCLOSE less'
alias loadenv='eval $(cat $HOME/.environment)'
alias tloadenv='eval $(tmux show-environment -s)'
alias sudo='sudo -E '
alias be='bundle exec'
alias en='LC_ALL=en_US.UTF-8 '

# Set prompts.
PROMPT='%n@%m:%~(%?%)%# '

# Set options.
setopt shwordsplit bareglobqual
setopt interactivecomments
setopt promptsubst
setopt rmstarsilent
setopt histignorespace
setopt extendedhistory
setopt incappendhistorytime
setopt extendedglob
unsetopt bgnice notify nomatch banghist

# Set history.
HISTSIZE=1000000
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
set_tty () {
    [[ -n $TTY ]] && return 0
    [[ -n $GPG_TTY ]] && TTY=$GPG_TTY && return 0
    [[ -n $SSH_TTY ]] && TTY=$SSH_TTY && return 0
    TTY=$(tty) || TTY=""
}
has_term () {
    local termname="$1"
    # Redirection is required because zsh complains about bad TERM.
    TERM=$termname silent echotc xo 2>/dev/null
}
set_if_has_term () {
    local termname="$1"
    has_term "$termname" && export TERM="$termname";
}
set_sane_term () {
    local i
    # Make sure our terminal definition works right.
    if ! silent echotc xo
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
            if [[ -z ${TERM##screen*} ]]
            then
                preferred=(screen-256color screen vt220)
            elif [[ -z ${TERM:#*256color} ]]
            then
                preferred=(xterm-256color xterm vt220)
            else
                preferred=(vt220)
            fi
            for i in $preferred
            do
                set_if_has_term $i
                break
            done
        fi
    fi
    if is_ssh_session && [[ $SSH_TTY == $TTY ]]
    then
        case $TERM in
            screen-256color)
                # This means we're using tmux on the other side.
                export COLORTERM=truecolor;;
            *)
                ;;
        esac
        return 0
    fi
    local parent_exe="$(readlink /proc/$PPID/exe |
        sed -e 's/(deleted)//; s/ //')"
    case "$TERM:$parent_exe" in
        xterm:*vim*)
            [[ $COLORTERM = truecolor ]] && set_if_has_term xterm-256color;;
        xterm:*xfce4-terminal|xterm:*gnome-terminal|xterm:*mate-terminal)
            set_if_has_term xterm-256color;;
        xterm:*konsole)
            set_if_has_term konsole-256color;;
        screen*:*tmux)
            is_ssh_session && EDITOR=$(bmc_editor console)
            set_if_has_term screen-256color;;
        screen*:*)
            EDITOR=$(bmc_editor console)
            set_if_has_term screen-256color;;
        rxvt:*mrxvt-full)
            set_if_has_term rxvt-256color;;
        linux:*)
            # Usually /proc/$PPID/exe will be inaccessible because it's
            # /bin/login and owned by root, so don't try to match on it.
            set_if_has_term linux-16color;;
        *:*fbterm)
            # fbterm supports 256 colors.
            set_if_has_term fbterm;;
        *) ;;
    esac

    # Ensure key bindings are set up appropriately.
    if [[ -n $DISPLAY ]] && silent which xmodmap && [[ -e $HOME/.Xmodmap ]]
    then
        xmodmap $HOME/.Xmodmap
    fi

    # Don't print weird escape characters on dumb terminals (e.g. gvim).
    [[ $TERM = dumb ]] && unset zle_bracketed_paste
}
adjust_term_settings () {
    # Turn off flow control.
    silent stty -ixon -ixoff

    # Make sure that other people can't mess with our terminal.
    silent mesg n
}
set_keybindings () {
    # Set up key handling for non-Debian systems.  This is already handled
    # properly in Debian, since this code has been taken from Debian's
    # /etc/zsh/zshrc.  Modified slightly with changes from grml's zshrc.
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

    bind2maps () {
        local i sequence widget
        local -a maps

        while [[ "$1" != "--" ]]; do
            maps+=( "$1" )
            shift
        done
        shift

        if [[ "$1" == "-s" ]]; then
            shift
            sequence="$1"
        else
            sequence="${key[$1]}"
        fi
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
    bind2maps emacs viins       -- -s '^xi'    insert-unicode-char

    unfunction bind2maps
}
remove_perl_overrides () {
    [ -n "$PERL_LOCAL_LIB_ROOT" ] && path=("${(@)path:#$PERL_LOCAL_LIB_ROOT/bin}")
    unset PERL_MB_OPT PERL_MM_OPT PERL_LOCAL_LIB_ROOT PERL5LIB
}
sless () {
    (
        # Help less handle compressed files better.
        silent whence lesspipe && eval $(lesspipe)
        less "$@"
    )
}
ggrep () {
    grep -r "$@" *
}
dumpenv () {
    (
        [[ -n $SSH_AUTH_SOCK ]] && print "export SSH_AUTH_SOCK=$SSH_AUTH_SOCK";
        [[ -n $DISPLAY ]] && print "export DISPLAY=$DISPLAY";
    ) > $HOME/.environment
    true
}
setup_colors () {
    has_colors || return
    [[ -f $HOME/.dircolors ]] && eval "$(dircolors $HOME/.dircolors 2>/dev/null)"

    # Set up termcap colors for less (from grml).
    local blue="blue"
    [[ $(echotc Co 2>/dev/null) = 256 ]] && blue=33

    export LESS_TERMCAP_mb=$(print -P $(color_fg red yes))
    export LESS_TERMCAP_md=$(print -P $(color_fg red yes))
    export LESS_TERMCAP_me=$(print -P $(color_reset))
    export LESS_TERMCAP_se=$(print -P $(color_reset))
    export LESS_TERMCAP_so=$(print -P $(color_fg $blue yes))
    export LESS_TERMCAP_ue=$(print -P $(color_reset))
    export LESS_TERMCAP_us=$(print -P $(color_fg green yes))
    export GREP_COLORS=fn=$(color_fg_ansi $blue yes)
    export CLICOLOR=1
}
setup_autoload () {
    local func i
    for func in $^fpath/*(.:t);
    do
        if [[ -n $func ]]; then
            autoload -U $func
        fi
    done

    for i in promptinit compctl complete complist computil insert-unicode-char;
    do
        autoload -U $i
    done
    compinit -u 2>/dev/null
}
tmux-title () {
    # Set the title to begin with a ZWSP.  The prompt precmd will not overwrite
    # it in this case.
    printf '\033k\342\200\213%s\033\\' "$@"
}
tmux-clear-title () {
    # Set the title to an empty string so the prompt will override it again.
    printf '\033k%s\033\\' ""
}

# Do this before any sort of importing or prompt setup, so that the prompt can
# take advantage of terminal features such as 256-color support.
set_tty
set_sane_term
adjust_term_settings
set_keybindings
remove_perl_overrides

is_ssh_session && dumpenv

VISUAL="$EDITOR"

# Autoload some stuff.
setup_autoload

choose_prompt () {
    local km=$1
    [[ -n $km ]] || km=$KEYMAP
    case $km in
        vicmd)      psvar[3]="◈◈";;
        viins|main) psvar[3]=();;
    esac
}

zle-keymap-select () {
    choose_prompt
    zle reset-prompt
}

zle-line-init () {
    if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
        emulate -L zsh
        printf '%s' ${terminfo[smkx]}
    fi
    choose_prompt "main"
}
zle-line-finish () {
    if (( ${+terminfo[smkx]} )) && (( ${+terminfo[rmkx]} )); then
        emulate -L zsh
        printf '%s' ${terminfo[rmkx]}
    fi
    choose_prompt "main"
}

zle -N zle-line-init
zle -N zle-line-finish
zle -N zle-keymap-select
zle -N insert-unicode-char

# Set up the prompt.
colors
promptinit
prompt bmc

# This is from grml.  GPLv2.
setup_completion () {
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
        /bin            \
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
    for compcom in  cp deborphan df feh fetchipac head hnb ipacsum mv \
        pal stow tail uname ; do
        [[ -z ${_comps[$compcom]} ]] && compdef _gnu_generic ${compcom}
    done; unset compcom

    # see upgrade function in this file
    compdef _hosts upgrade

    # Fix completion with libpam-tmpdir.
    zstyle ':completion:*' accept-exact-dirs true

    # Fix extreme slowness in large repositories.
    function __git_files () {
        _wanted files expl 'local files' _files
    }
}

silent whence lesspipe && eval $(lesspipe)

setup_completion
setup_colors

# Succeed.
true
