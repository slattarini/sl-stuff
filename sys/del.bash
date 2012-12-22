#!bash
# Reversible file deleter: move files and directory in a "trash" directory
# rather than really removing them.

set -u
shopt -s extglob

readonly progname=${0##*/}
readonly VERSION=0.6.1
readonly PROGRAM="Reversible Delete"

declare -ir EXIT_SUCCESS=0
declare -ir EXIT_FAILURE=1
declare -ir E_USAGE=2
declare -ir E_INTERNAL=100

print_usage ()
{
    cat <<-EOT
		Usage: $progname [-aifqD] [--] FILE-1 [FILE-2... FILE-n]
		Try '$progname --help' for more information.
		EOT
}

print_version ()
{
    echo "$PROGRAM, version $VERSION"
}

print_help()
{
    print_version && cat <<'EOT'

Move files and directory in a "trash" directory rather than 
really remove them.

The default trash directory is $HOME/.trash, but the environmental
variale 'TRASH_DIRECTORY' is honoured.

OPTIONS:
  -i:
       Interactive: ask before deleting any file. Answer is read from 
       standard input.
  -V:
       print program version and exit
  -h:
       print this help message and exit
EOT
}

warn ()
{
   echo "$progname: $*" >&2
}

badwarn ()
{
   warn "$*"
   exit_status=$EXIT_FAILURE
}

error ()
{
   warn "error: $*" >&2
   exit $EXIT_FAILURE
}

usage_error ()
{
    [ $# -gt 0 ] && echo "$progname: $*" >&2
    print_usage >&2
    exit $E_USAGE
}

internal_error ()
{
    exec >&2
    printf "INTERNAL ERROR"
    [ -n "${FUNCNAME[1]-}" ] && printf " in subroutine '%s'" ${FUNCNAME[1]}
    [ -n "${BASH_LINENO[0]-}" ] && printf " at line %s" ${BASH_LINENO[0]}
    echo
    exit $E_INTERNAL
}

#--------------------------------------------------------------------------

IsYes()
{
    local bool=
    case "${*-}" in
        true|TRUE|[yY]*) return 0;;
        *) return 1;;
    esac
}

exists ()
{
    [ $# -eq 1 ] || internal_error
    [[ -e "$1" || -h "$1" ]]
}

run_as_del ()
{
    [ $# -gt 0 ] || internal_error
    (exec -a "$progname" "$@")
}

trashname ()
{
    local f=${1%%*(/)}
    echo "${T}/${f##*/}___$(LC_ALL=C date '+%Y-%m-%d_%H:%M:%S')"
}

delete() {
    [ $# -eq 1 ] || internal_error
   
    local file="$1"
    
    if IsYes "$Ask"; then
        local reply
        echo -n "Delete '$file'? (y/n) [N] " >&2
        read reply
        IsYes "$reply" || return 0  # stop
    fi
    
    local destfile=$(trashname "$file")
   
    if exists "$destfile"; then
        sleep 1
        destfile=$(trashname "$file")
        if exists "$destfile"; then
            badwarn "$file: cannot delete: preexisting file in trash dir"
            return 1
        fi
    fi

    if run_as_del mv "$file" "$destfile"; then
        return 0
    else
        exit_status=$EXIT_FAILURE
        return 1
    fi
}


Ask='n'
suffix=''

case ${*-} in 
    --help) set -- '-h';;
    --version)  set -- '-V';;
esac

while getopts ":-hVaifqDrR:X" OPTION: do
    case $OPTION in
        i) Ask='y'                                                  ;;
        h) print_help; exit $?                                      ;;
        V) print_version; exit $?                                   ;;
        -) break                                                    ;;
        \?) usage_error "'-$OPTARG': unrecognized option"           ;;
        \:) usage_error "'-$OPTARG': option requires an argument"   ;;
        *) internal_error                                           ;;
    esac
done

shift $((OPTIND - 1))

unset OPTION OPTARG OPTERR OPTIND
declare -r Ask

[ $# -gt 0 ] || usage_error "missing argument"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

T=${TRASH_DIRECTORY:-"$HOME/.trash"}

[ -d "$T" ] || run_as_del mkdir -p -m 700 "$T" || \
  error "trash directory '$T': is not a directory, and cannot be created"

[[ -r "$T" && -x "$T" && -w "$T" ]] || \
  error "trash directory '$T': bad permissions"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

exit_status=$EXIT_SUCCESS

for file in "$@"; do
  delete "$file"
done

exit $exit_status

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# vim: expandtab tabstop=4 shiftwidth=4 ft=sh
