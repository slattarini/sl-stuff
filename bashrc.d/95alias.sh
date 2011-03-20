# -*- bash -*-

##--------------------##
##  PERSONAL ALIASES  ##
##--------------------##


# Remove any system-defined undesired aliases.
unalias .. l >/dev/null 2>&1

# An help to avoid absent-minded errors.
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# More user-friendly and chromed file diffs.
if W colordiff; then
    cdiff() { colordiff "$@"; }
else
    cdiff() { diff "$@"; }
fi
diff() {
    if test -t 1; then
        cdiff -u "$@" | less -r
    else
        builtin command diff "$@"
    fi
}

# To quickly start listening radio classica bresciana.
IsHost bigio && alias H=listen-radioclassica

# Laziness aliases
alias cmd=command
alias t=touch
alias o=open_url
alias L=less
alias m=more
W sensible-pager && alias p=sensible-pager || alias p=less
alias wh=which
W scons && alias scons='scons -Q'
alias v=$VI
alias vw=$VIEW
W kview && alias kv=kview
W konqueror && alias k=konqueror

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
    alias   g=$VI
    alias  gg=$VI
    alias  gw=$VIEW
    alias ggw=$VIEW
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
