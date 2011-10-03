# -*- bash -*-
# Some aliases of general utility.

# Remove any undesired system-wide aliases (defined e.g. by /etc/profile).
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

diff()
{
    if test -t 1; then
        cdiff -u "$@" | less -r
    else
        builtin command diff "$@"
    fi
}

# "Laziness" aliases.

alias md='mkdir -p'
alias rd=rmdir
alias t=touch
alias L=less
alias m=more
if W sensible-pager; then
  alias p=sensible-pager
else
  alias p=less
fi

# Print exit status of last command, without losing it.
# Useful e.g. when we have a simple prompt that doesn't report information
# about the exit status of the last executed command.
ok() { local ok_val=$?; echo $ok_val; return $ok_val; }

# Detailed information on all process.  This is more system-independent
# than we'd like.
if [[ $SYSTEM_UNAME == linux ]]; then
    alias PS='ps -elFywwwww | less'
elif [[ $SYSTEM_UNAME == freebsd ]]; then
    alias PS='ps auxwwwww | less'
elif [[ $SYSTEM_UNAME == solaris && -f /usr/ucb/ps ]]; then
    alias PS='/usr/ucb/ps auxwwwww | less'
fi

# Restart the currently-running bash shell.
alias rebash='exec "$BASH"'

# Aliases for vim (if available).  Very tailored to my habits and
# idiosyncrasies.
if W vim; then
    if [ -n "${DISPLAY-}" ]; then
      alias  g="vim -g"
      alias gg="vim -g -p"
    else
      alias  g="vim"
      alias gg="vim -p"
    fi
fi

# Grep with colors.
# FIXME: this should be OK as long as we can find GNU grep ...
if [[ $SYSTEM_UNAME == linux ]]; then
    alias grep='grep --color=auto'
    alias egrep='grep -E --color=auto'
    alias fgrep='grep -F --color=auto'
    alias rgrep='grep -r --color=auto'
    W wcgrep && alias wcgrep='wcgrep --color=auto'
    W autogrep && alias autogrep='autogrep --color=auto'
fi

#---------------------------------------------------------------------------

# vim: et ts=4 sw=4 ft=sh
