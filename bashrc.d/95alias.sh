# -*- bash -*-

##--------------------##
##  PERSONAL ALIASES  ##
##--------------------##


# Remove any system-defined undesired aliases.
unalias '..' 'l' >/dev/null 2>&1

# An help to avoid damages.
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias rmf='rm -f'
alias cpf='cp -f'
alias mvf='mv -f'

# More user-friendly and chromed file diffs.
if W colordiff; then
    cdiff() { LC_ALL=C colordiff "$@"; }
else
    cdiff() { LC_ALL=C diff "$@"; }
fi
diff() {
    if test -t 1; then
        cdiff -u "$@" | less -r
    else
        builtin command diff "$@"
    fi
}

# I like to have ceratain programs always running with C locale.
for p in svn svkwset svo psvo gpg ftp ncftp df fdisk; do
    W $p && eval "alias $p='LC_ALL=C $p'"
done
unset p

# To quickly start listening radio classica bresciana.
IsHost bigio && alias H=listen-radioclassica

# Lazyness aliases
alias cmd='command'
alias o='open_url'
alias b='bak'
alias t='touch'
alias L='less'
alias m='more'
W sensible-pager && alias p=sensible-pager || alias p=less
alias wh='which'
alias du='du -s'
W scons && alias scons='scons -Q'
alias v="$VI"
alias vw="$VIEW"
if [ -n "${DISPLAY-}" ]; then
    W kview && alias kv='kview'
    W konqueror && alias k='konqueror'
    W firefox && alias f='firefox'
    IsHost bigio && W kmail && alias km='kmail'
fi

# print exit status of last command, without losing it
ok() { local ok_val=$?; echo $ok_val; return $ok_val; }

# detailed information on all process
if [[ $SYSTEM_UNAME == linux ]]; then
    alias PS='ps -elFwwwww | less'
elif [[ $SYSTEM_UNAME == freebsd ]]; then
    alias PS='ps auxwwwww | less'
fi

# Restart the currently-running bash shell.
alias rebash='clearlang; exec "$BASH"'

if W vim; then
    [ -n "${DISPLAY-}" ] && gopt='-g' || gopt=''
    alias   g="vim $gopt"
    alias  gg="vim $gopt -p"
    alias  gw="vim $gopt -R"
    alias ggw="vim $gopt -R -p"
    unset gopt
else
    alias   g="$VI"
    alias  gg="$VI"
    alias  gw="$VIEW"
    alias ggw="$VIEW"
fi

# Grep with colors.
if [[ $SYSTEM_UNAME == linux ]]; then
    alias grep='grep --color=auto'
    alias egrep='grep -E --color=auto'
    alias fgrep='grep -F --color=auto'
    alias rgrep='grep -r --color=auto'
    W wcgrep && alias wcgrep='wcgrep --color=auto'
    W autogrep && alias autogrep='autogrep --color=auto'
fi

# ANSI colors for the terminal.
for c in green red cyan yellow blue magenta white black; do
   eval alias " $c='set_term_foreground_color $c';"
   eval alias "r$c='set_term_background_color $c';"
   eval alias "b$c='term_bold; set_term_foreground_color $c'; \
               term_unbold;"
done
unset c

#---------------------------------------------------------------------------

# vim: et ts=4 sw=4 ft=sh
