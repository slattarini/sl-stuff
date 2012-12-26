#!bash
# zap: an interactive process killer.

## GLOBAL SETTINGS

enable printf kill
IFS=' '$'\t'$'\n'
readonly oIFS=$IFS

# Stick to C locale.
export LANG=C LANGUAGE=C LC_ALL=C LC_COLLATE=CL C_MESSAGES=C

set -u                # don't accept to expand unset variables
set -o noglob         # no file globbing
set -C                # don't clobber existing file with redirections
shopt -u nocasematch  # be case-sensible in case statements and the like
shopt -s extglob      # and use extended globbing there as well

## EXIT STATUSES

readonly SUCCESS=0
readonly FAILURE=1
readonly E_USAGE=2

## CONSTANTS

readonly progname=${0##*/}
readonly version=0.6
readonly usage="[--help|--version] [-afki] [-n|-y] [-s SIGNAL] [PATTERN]"

## SUBROUTINES

xecho () {
    printf '%s\n' "$*"
}

print_usage () {
    xecho "Usage: $progname $usage"
}

print_version () {
    xecho "zap, version $version"
}

print_help () {
    print_version \
     && print_usage \
     && cat <<EOH

$progname is an interactive process killer.

It tries to send signal given with the '-s' option (default SIGTERM) to
the processes whose command line (as give by the ps(1) utility) matches
the given pattern, first asking interactively for user confirmation
(writing questions on standard error and reading answers from standard
input).

If PATTERN is not given or empty, all processes are considered matched.

By default only processes owned by the user running $progname are
considered, but this can be changed with the '-a' option.

The given pattern is considered an extended regular expression (as
supported by bash, version 3 or later).

Options:
  --help:
       Print this help message and exit.
  --version:
       Print program version and exit.
  -s SIGNAL:
       Specify signal to send (any signal can be specified both with its
       signal number or its symbolic name; e.g., SIGNIT can be specified
       equivalently as '-s 2', '-s INT' or '-s SIGNIT').
  -k:
       Force process killing (i.e. try to kill with SIGKILL any process
       which is still alive about one second after it has been signaled
       with the user-given signal).
  -a:
       Consider *all* processes (not just the user's ones, as is the
       default).
  -y:
       Set the default answer to YES.
  -n:
       Set the default answer to NO (if neither '-y' nor '-n' options are
       given, then the default answer is NO).
  --:
       Explicitly end option parsing.
EOH
}

warn () {
    xecho "$progname: $*" >&2
}

error () {
    warn "$@"
    exit $EXIT_FAILURE
}

usage_error () {
    [ $# -gt 0 ] && xecho "$progname: $*" >&2
    print_usage >&2
    exit $E_USAGE
}

# xkill: wrapper around kill builtin to provide better format of error
#        messages from kill builtin
# Usage: xkill [-q] -SINGAL PID
xkill () {
    declare -i quiet=0
    if [[ $1 == "-q" ]]; then
        quiet=1
        shift
    fi
    if ((quiet)); then
        kill "$@" >/dev/null 2>&1
        return $?
    else
        local msg rc
        msg=$(kill "$@" 2>&1)
        rc=$?
        case "$msg" in
            *:*:*) msg=${msg#*:}; msg=${msg#*:};;
            *:*) msg=${msg#*:};;
        esac
        msg=${msg##*( )kill:*( )}
        [[ -n $msg ]] && warn "$msg"
        return $rc
    fi
}

# Usage: prompt_user QUESTION
prompt_user () {
    local question="$*"
    # Find the number of lines and columns of the user terminal.
    local columns=${COLUMNS:-80}
    local lines=${LINES:-50}
    # The prompt depends on the default answer.
    local prompt="  (y/n/q) [$default_answer] ? "
    # Be sure to have enough space on screen to print the prompt and
    # the cursor; if not, go to the next line.
    printf '%s' "$question" >&2
    if ((${#question} % ($columns + 1) + ${#prompt} >= $columns)); then
        printf '\n  ...' >&2
    fi
    printf '%s' "$prompt"
}

# Usage: pick ITEM
pick () {
    local answer= item=$*
    # Loop to repeat the question if an invalid answer was given.
    while true; do
        prompt_user "$item"
        read -e answer
        [ -n "$answer" ] || answer=$default_answer
        case $answer in
            [nN]*) return $FAILURE;; # item selected
            [yY]*) return $SUCCESS;; # item not selected
            q|Q|[qQ]uit) break ;;    # quit immediately
            *);; # signal the user for bad answer, and ask again
        esac
        warn "'$answer': invalid answer"
        warn "type 'y' for yes, 'n' for no, 'q' to quit"
    done
    warn "exit immediately on user's request"
    exit $exit_status # This variable defined by main code.
}

# Usage: try_signal SIGNAL PID
try_signal () {
    local sig=$1 pid=$2
    if ((force_kill)); then
        # First see if we can signal the process, since it's pointless to
        # try to kill it if we can't even signal it.
        xkill -0 $pid || return $FAILURE
        # Try to signal the process, kill it if it remains alive.
        # Don't bother about failures yet.
        xkill -$sig $pid
        if xkill -q -0 $pid; then
            # Process still alive: maybe it needs some time to cleanup,
            # so wait just a second.
            sleep 1
            if xkill -q -0 $pid; then
                # OK, enough: kill it.
                warn "process $pid still alive, killing it"
                xkill -KILL $pid || return $FAILURE
            fi
        fi
    else
        xkill -$signal $pid || return $FAILURE
    fi
    return $SUCCESS
}

## OPTION PARSING

case ${1-} in
    --help) print_help; exit $?;;
    --version) print_version; exit $?;;
esac

all=             # options to be passed to ps(1)
default_answer=N # displayed on screen, do not set to lowercase
signal=SIGTERM
declare -i force_kill=0
declare -i case_insensible=0
while getopts ":nyaiks:" OPTION; do
    case "$OPTION" in
        s) signal=${OPTARG};;
        a) all='-e';;
        y) default_answer=Y;;
        n) default_answer=N;;
        k) force_kill=1;;
        i) case_insensible=1;;
        \?) usage_error "'-$OPTARG': Invalid option";;
        \:) usage_error "'-$OPTARG': Option requires an argument";;
    esac
done
shift $((OPTIND - 1))
unset OPTION OPTERR OPTIND

case $# in
    0) pattern='.';;
    1) pattern=$1;;
    2) usage_error "Too many arguments";;
esac

set --

readonly all default_answer signal case_insensible pattern

## SANITY CHECKS

# check that signal is accepted by the kill builtin

if [[ $(kill "-$signal" 2>&1) == *[iI]nvalid*[sS]ignal* ]]; then
    error "'$signal': Invalid signal"
fi

# Check given pattern for correctness.
[[ x =~ $pattern ]] # should return 2 if pattern is invalid
(($? < 2)) || error "'$pattern': Invalid regular expression"

## MAIN CODE

ps_fmt="pid=PID,ppid=PPID,user=USER,stat=STAT,tty=TTY,args=CMDLINE"

declare -a ps_lines
# Take a SNAPSHOT of the process table.
# NOTE: the unquoted command subst is safe since we disabled file globbing.
IFS=$'\n'
# The 'exit' deal with the weird possibility of a ps(1) failure.
ps_lines=( $(COLUMNS=10000 ps xwww $all -o "$ps_fmt") ) || exit $FAILURE
IFS=$oIFS

declare -a matching_processes=()
for wholeline in "${ps_lines[@]}"; do
    # Remove trailing white spaces, if any.
    wholeline=${wholeline%%*([ $'\t'])}
    # Skip empty lines.
    [ -n "$wholeline" ] || continue
    # First line is the header: register it.
    if [[ ${ps_header+set} != set ]]; then
        ps_header=$wholeline
        continue
    fi
    # Go get PID, PPID and command line of the process.
    set -- $wholeline # safe since we disabled file globbing
    pid=$1 ppid=$2
    shift 5 # pid ppid user stat tty
    cmdline="$*"
    set -- # clear args
    (( pid == $$)) && continue # do not kill ourselves...
    ((ppid == $$)) && continue # ...nor our children
    ((case_insensible)) && shopt -s nocasematch
    # Display only the processes whose command line matches the pattern
    # given by the user.
    # WARNING: do not *absolutely* quote $pattern, else all metachars in
    # it will be taken literally!
    if [[ "$cmdline" =~ $pattern ]]; then
        matching_processes[${#matching_processes[@]}]=$wholeline
    fi
    shopt -u nocasematch
done
unset pip ppid wholeline cmdline

if ((${#matching_processes[@]} == 0)); then
    # No process matched, nothing to do.
    exit $SUCCESS
else
    declare -i exit_status=$SUCCESS
    declare -i i=0
    nicestrip=${ps_header:0:${COLUMNS-80}}
    nicestrip=${nicestrip//?/-}
    for ps_info in "${matching_processes[@]}"; do
        # Reprint the header every 5 lines.
        if ((i++ % 5 == 0)); then
            xecho "$nicestrip" >&2
            xecho "$ps_header" >&2
            xecho "$nicestrip" >&2
        fi
        if pick "$ps_info"; then
            # Safe since we disabled file globbing.
            set -- $ps_info && pid=$1 && set --
            try_signal $signal $pid || exit_status=$FAILURE
         fi
    done
    exit $exit_status
fi

## NOTREACHED
echo "$0: line $LINENO: DEAD CODE REACHED"
exit 255

# vim: ft=sh ts=4 sw=4 et
