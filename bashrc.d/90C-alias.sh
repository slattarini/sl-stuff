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

alias x='atool --extract'
alias lx='atool --list'

alias md='mkdir -p'
alias rd=rmdir

alias c+x='chmod a+x'
alias c-x='chmod a-x'
alias  cx='chmod a+x'

alias L=less
alias M=more
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
if $have_gnu_grep; then
    for p in '' @; do
        case $p in @) m=always;; *) m=auto;; esac
        alias  "${p}grep"="$gnu_grep --color=$m"
        alias "${p}egrep"="$gnu_grep -E --color=$m"
        alias "${p}fgrep"="$gnu_grep -F --color=$m"
        alias "${p}rgrep"="$gnu_grep -r --color=$m"
        for c in wcgrep autogrep; do
            if W $c; then
                alias $p$c='"WCGREP_GREP=$gnu_grep" '"$c--color=$m"
            fi
        done
    done
    unset c p m
fi

# ls(1) with colors, bells and whistles.

if $have_gnu_ls; then
    @ls () { $gnu_ls --color=always "$@"; }
elif [[ $SYSTEM_UNAME == freebsd ]]; then
    @ls () { CLICOLOR_FORCE=1 /bin/ls -G "$@"; }
else
    @ls () { ls "$@"; }
fi

el() { @ls -1 "$@"; [ ! -t 1 ] || echo; }

alias ll='el -l'
alias la='el -lA'

lls() { ll | less -r; }
lla() { la | less -r; }

: # Don't return a spurious non-zero status.

#---------------------------------------------------------------------------

# vim: et ts=4 sw=4 ft=sh
