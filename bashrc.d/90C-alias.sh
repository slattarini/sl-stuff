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
elif [[ $SYSTEM_UNAME == *bsd ]]; then
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
if have_gnu_program grep; then
    for p in '' @; do
        case $p in @) m=always;; *) m=auto;; esac
        alias "${p}grep"="$gnu_grep --color=$m"
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

if have_gnu_program ls; then
    @ls () { $gnu_ls --color=always "$@"; }
elif (CLICOLOR_FORCE=1 /bin/ls -G . | grep '') >/dev/null 2>&1; then
    # FreeBSD systems, usually.
    @ls () { CLICOLOR_FORCE=1 /bin/ls -G "$@"; }
else
    @ls () { ls "$@"; }
fi

el() { @ls -1 "$@"; [ ! -t 1 ] || echo; }

alias ll='el -l'
alias la='el -lA'

lls() { ll "$@" | less -r; }
lla() { la "$@" | less -r; }

# Shell implementation of nice(1) and args(1) (or a subset thereof),
# that we will be usable also with our shell aliases and functions
# (if not always, at least with in most circumstances).

# The "smart" version can only be implemented with bash >= 4.0, and
# if renice(1) is present.
if [[ -n $BASHPID ]] && (test $$ != "$BASHPID") && W renice; then
    @nice ()
    {
        case $#,$1 in
            1,--help|1,--version)
                echo "$(funcname): shell implementation of nice."
                echo "Uses either nice(1) or renice(1)"
                return 0
                ;;
        esac
        local niceness=0
        while :; do
            case $1 in
               -n) niceness=$2; shift;;
              -n*) niceness=${1#-n};;
                *) break;;
            esac
            shift
        done
        local nice_cmd=$1; shift
        local nice_cmd_type=$(type -t "$nice_cmd")
        case $nice_cmd_type in
        "")
            fwarn "$nice_cmd: command not found"
            return 127
            ;;
        file)
            # Extra quoting for nice to avoid triggering the 'nice' alias,
            # which is aliased to the present '@nice' function -- so that
            # its use would cause infinite loop.
            "nice" -n"$niceness" "$nice_cmd" "$@"
            return $?
            ;;
        *)
          ( if [[ $nice_cmd_type == alias ]]; then
                # A dirty trick to force aliases to be expanded.  It should
                # operate recursively, in case the alias references other
                # aliases.
                eval "@nice@helper () { $nice_cmd \"\$@\"; }" || exit 255
                nice_cmd="@nice@helper"
            fi
            renice -n "$niceness" $BASHPID && "$nice_cmd" "$@" )
            ;;
        esac
    }
    alias nice='@nice'
fi

# Our xargs replacement cannot deal with null-separated input fields.
# But this is not a big deal, since 99% of xargs(1) usage don't require
# that either.
@xargs ()
{
    # Delegate the hard work to the real xargs program; act only as a
    # thin layer around it.
    declare -a xargs_opts=()
    while (($# > 0)); do
        case $1 in
            # Make clear we are not the true xargs(1).
            --help|--version)
                echo "$(funcname): shell wrapper around xargs"
                return 0
                ;;
            # We can't handle these.
            -a|--arg-file|-P|--max-procs|-0|--null)
                fwarn "cannot handle option '$1' properly, use xargs program"
                return 1
                ;;
            # Explicitly ends options list.
            --)
                shift; break
                ;;
            # These requires an argument; fetch it.
            -L|-E|-I|\
            -d|--delimeter|\
            -n|--max-args|\
            -s|--max-chars)
                xargs_opts+=( "$1" "$2" )
                shift 2
                ;;
            # Pass all the other options and option clusters through.
            -*)
                xargs_opts+=( "$1" )
                shift
                ;;
            # Non-option argument: stop option parsing.
            *)
                break
                ;;
        esac
    done
    if (($# == 0)); then
        fwarn "missing argument"
        return 2
    else
        xargs_cmd=$1
        shift
    fi

    local xargs_cmd_type=$(type -t "$xargs_cmd")
    case $xargs_cmd_type in
        "")
            fwarn "$xargs_cmd: command not found"
            return 127
            ;;
        file)
            # Use 'command' to avoid triggering the 'xargs' alias, which
            # is defined to point to the present '@xargs' function -- so
            # that its use would cause infinite loop.
            command xargs "${xargs_opts[@]}" -- "$xargs_cmd" "$@"
            return $?
            ;;
        *)
          ( set -o pipefail || exit 255
            if [[ $xargs_cmd_type == alias ]]; then
              # A dirty trick to force aliases to be expanded.  It should
              # operate recursively, in case the alias references other
              # aliases.
              eval "@xargs@helper () { $xargs_cmd \"\$@\"; }" || exit 255
              xargs_cmd="@xargs@helper"
            fi
            # See comments above for why we use 'command' here.
            command xargs "${xargs_opts[@]}" -- echo -E "$@" \
              | ( st=0
                  while read -r -a lst; do
                    "$xargs_cmd" "${lst[@]}" || st=$?
                  done
                  exit $st ) )
             return $?
           ;;
   esac
   return 255 # NOTREACHED
}

alias xargs='@xargs'

: # Don't return a spurious non-zero status.

# vim: et ts=4 sw=4 ft=sh
