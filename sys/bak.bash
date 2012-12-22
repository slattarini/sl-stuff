#!bash
# A simple script to quickly make in-place backups of regular files and
# directories.

#--------------------------------------------------------------------------

set -u
shopt -s extglob

readonly progname=${0##*/}
readonly version="0.5beta2"

declare -ir EXIT_SUCCESS=0
declare -ir EXIT_FAILURE=1
declare -ir E_USAGE=2
declare -ir E_INTERNAL=100

declare -ir TRUE=1
declare -ir FALSE=0

#--------------------------------------------------------------------------

vwarn () {
    ((force)) || echo "$progname: $*" >&2
    exit_status=$EXIT_FAILURE
}

warn () {
    echo "$progname: $*" >&2
    exit_status=$EXIT_FAILURE
}

error () {
    echo "$progname: error: $*" >&2
    exit $EXIT_FAILURE
}

print_version () {
    echo "$progname, version $version"
}

# TODO: add description of all options, and maybe some examples
print_help () {
    print_version \
     && echo "\
A simple script to quickly make in-place backups of regular files and
directories." \
     && print_usage
}

usage_error () {
    [ $# -gt 0 ] && echo "$progname: $*" >&2
    print_usage >&2
    exit $E_USAGE
}

print_usage () {
    echo "Usage: $progname [-m] [-f] [-s BACKUP-SUFFIX] [--]" \
         "FILES-TO-BACKUP"
}

#--------------------------------------------------------------------------

case ${1-} in
    --help) print_help; exit $?;;
    --version) print_version; exit $?;;
esac

force=$FALSE
move=$FALSE
backup_suffix='~'
while getopts ":mfxb:s:S:" OPTION; do
    case $OPTION in
        m) move=$TRUE;;
        s) backup_suffix=$OPTARG;;
        f) force=$TRUE;;
       \?) usage_error "'-$OPTARG': invalid option";;
       \:) usage_error "'-$OPTARG': option requires an argument";;
        *) echo "INTERNAL ERROR at line $LINENO" >&2; exit $E_INTERNAL;;
    esac
done
shift $((OPTIND - 1))
unset OPTION OPTERR OPTARG OPTIND
declare -r backup_suffix force move

if (($# == 0)); then
    if ((force)); then
        exit $EXIT_SUCCESS
    else
        usage_error "missing arguments"
    fi
fi

# TODO: make these portable and defined at "compile-time"
if ((move)); then
    if LC_ALL=C mv -T 2>&1 | grep -i 'invalid option' >/dev/null; then
        BAKFILE='mv --'
        BAKDIR='mv --'
    else
        BAKFILE='mv -T --'
        BAKDIR='mv -T --'
    fi
else
    BAKFILE='cp -d -p --'
    BAKDIR='cp -a --'
fi

#--------------------------------------------------------------------------

declare -i exit_status=$EXIT_SUCCESS

for item in "$@"; do
    if [ -d "$item" ]; then
        # We must remove the (possible) trailing slash(es).
        dir=${item%%+(/)}
        # Remove any preexisting backup, also if it's a directory.
        if rm -rf -- "${dir}${backup_suffix}"; then
            $BAKDIR "${dir}" "${dir}${backup_suffix}" || {
                warn "failed to backup directory '$dir'"
                continue
            }
        else
            warn "pre-existent file '${dir}${backup_suffix}' can't" \
                 "be removed: directory '$dir' not backupped"
        fi
    elif [ -f "$item" ]; then
        file=$item
        # remove any preexisting backup, but not if it's a directory
        if rm -f -- "${file}${backup_suffix}"; then
            $BAKFILE "${file}" "${file}${backup_suffix}" || {
                warn "failed to backup file '$file'"
                continue
            }
        else
            warn "pre-existent file '${file}${backup_suffix}' can't" \
                 "be removed: file '$file' not backupped"
        fi
    else  # [ ! -f $item ] && [ ! -d $item ]
        if ((! force)); then
            if [ ! -e "$item" ]; then
                if [ -h "$item" ]; then
                    warn "'$item': Broken symlink"
                else
                    warn "'$item': No such file or directory"
                fi
            else  # [ -e "$item" ]
                warn "'$item': Not a regular file nor a directory"
            fi
        fi  # ! $force
    fi  # $item
done

#--------------------------------------------------------------------------

exit $exit_status

# vim: ft=sh ts=4 sw=4 et
