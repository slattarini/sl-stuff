#!bash
# Reversible file deleter: move files and directory in a "trash" directory
# rather than really removing them.

set -u
shopt -s extglob

readonly progname=${0##*/}
readonly VERSION=0.6
readonly PROGRAM="Reversible Delete"

declare -ir EXIT_SUCCESS=0
declare -ir EXIT_FAILURE=1
declare -ir E_USAGE=2
declare -ir E_INTERNAL=100

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#
# Informational subroutines.
#

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
    print_version
    echo
    cat <<EOT
Move files and directory in a "trash" directory rather than 
really remove them.

The default trash directory is \$HOME/.trash, but the environmental
variale 'TRASH_DIRECTORY' is honoured.

OPTIONS:
  -a:
       Delete all files (not only regular files and directories)
  -i:
       Interactive: ask before deleting any file. Answer is read from 
       standard input.
  -f:
       Force: do not ask before delete a file, and do not complain if a
       given file does not exist or hasn't to be moved (for example
       because it is a directory and option '-D' was passed to the 
       script)
  -q:
       silent: do no complaint if a given file does not exist or hasn't
       to be moved (for example because it is a directory and option
       '-D' was passed to the script)
  -D:
       do not delete any directory.
  -r:
       also delete directories (this is the default; this option is 
       provided for for compatibility with the 'rm' usage)
  -R:
       same as '-r'
  -X:
       run in debug mode (do not really delete anything)
  -V:
       print program version and exit
  -h:
       print this help message and exit
EOT
}

#--------------------------------------------------------------------------

warn ()
{
   echo "$progname: $*" >&2
}

badwarn ()
{
   warn "$*"
   e=$EXIT_FAILURE
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

    if IsYes "$Debug"; then
        echo mv "$file" "$destfile"
        return 0
    else
        # Really delete file.
        if run_as_del mv "$file" "$destfile"; then
            return 0
        else
            e=$EXIT_FAILURE
            return 1
        fi
    fi
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ask='n'
Silent='n'
DelDir='y'
DelAll='n'
Debug='n'
suffix=''

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

case "${*-}" in 
    --help|-\?) set -- '-h';;
    --version)  set -- '-V';;
esac

while getopts ":-hVaifqDrR:X" OPTION
do
    case "$OPTION" in
        a) DelAll='y'                                               ;;
        i) Ask='y'                                                  ;;
        f) Ask='n'; Silent='y'                                      ;;
        q) Silent='y'                                               ;;
        D) DelDir='n'                                               ;;
        r|R) DelDir='y'                                             ;;
        X) Debug='y'                                                ;;
        h) print_help; exit $EXIT_SUCCESS                           ;;
        V) print_version; exit $EXIT_SUCCESS                        ;;
        -) break                                                    ;;
        \?) usage_error "'-$OPTARG': unrecognized option"           ;;
        \:) usage_error "'-$OPTARG': option requires an argument"   ;;
        *) internal_error                                           ;;
    esac
done

shift $((OPTIND - 1))

unset OPTION OPTARG OPTERR OPTIND
declare -r Ask Silent DelDir

[ $# -gt 0 ] || usage_error "missing argument"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

T=${TRASH_DIRECTORY:-"$HOME/.trash"}

[ -d "$T" ] || run_as_del mkdir -p -m 700 "$T" || \
  error "trash directory '$T': is not a directory, and cannot be created"

[[ -r "$T" && -x "$T" && -w "$T" ]] || \
  error "trash directory '$T': bad permissions"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

e=$EXIT_SUCCESS
for file in "$@"
do
    if ! [[ -e "$file" || -h "$file" ]]; then
        if ! IsYes "$Silent"; then
            badwarn "$file: No such file or directory"
        fi
        continue
    fi
    if IsYes "$DelAll"; then
        delete "$file"
        continue
    fi
    if [ -d "$file" ]; then
        if IsYes "$DelDir"
        then
            delete "$file"
        else
            IsYes "$Silent" || \
              warn "$file: Is a directory: skipping"
        fi
    elif [[ -f "$file" || -h "$file" ]]; then
        delete "$file"
    else
        IsYes "$Silent" || \
          warn "$file: Not symlink, directory or regular file: skipping"
   fi   
done

exit $e

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# vim: expandtab tabstop=4 shiftwidth=4 ft=sh
