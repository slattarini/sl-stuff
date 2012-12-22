#!sh
# Print a single field from all records in the given file(s).
# Field separator is configurable from command-line option '-F'.
# Basically, just a thin convenience wrapper around awk.

set -u

progname=${0##*/}
field=0
usage="\
usage: $progname [--help|-h] [-F FIELD-SEPARATOR] [--] FIELD-NUM
       [FILE-1 ... FILE-n]"
help="$usage
\"FILED-NUM = 0\" means all fields."

usage_error ()
{
    [ $# -gt 0 ] && echo "$progname: $*" >&2
    echo "$usage" >&2
    exit 2
}

awk_field_separator=' '

while [ $# -gt 0 ]; do
    case "$1" in
        --help|-help|-h|-\?)
            echo "$help"
            exit
            ;;
        -F)
            [ $# -eq 1 ] && usage_error "Option  '$1' requires an argument"
            awk_field_separator="$2"
            shift
            ;;
        -F*)
            awk_field_separator=`echo "X$1" | sed 's/^X-F//'`
            ;;
        --)
            shift
            break
            ;;
        -*)
            usage_error "'$1': Unknown option"
            ;;
        *)
            break
            ;;
    esac
    shift
done

[ $# -gt 0 ] || usage_error "No field specified"

[ 0 -le "$1" ] >/dev/null 2>&1 || \
  usage_error "'$1': Not a non-negative integer"

field=$1 && shift

exec awk -F"$awk_field_separator" "{ print \$$field; }" ${1+"$@"}

# vim: ft=sh ts=4 sw=4 et
