#!bash
# Search the definition of a C function in the given files.

set -u
progname=${0##*/}

print_usage() {
    echo "Usage: $progname [-r|-R] [EGREP-OPTS] [-L] [FUNCNAME] [FILES]"
}

print_help() {
    echo "$progname: search the definition of a C function" \
         "in the given files."
    print_usage
    cat <<'EOH'
If FUNCNAME is not given, defaults to "main".
If FILES are not given, a recursive search in the current directory is
performed.
Accepted EGREP-OPTS are: cinhHABC.
The option `-L' ("lax") means that not only definition of FUNCNAME is
searched, but also definitions of rpl_FUNCNAME, _FUNCNAME or __FUNCNAME.
EOH
}

usage_error() {
    [ $# -gt 0 ] && echo "$progname: $*" >&2
    print_usage >&2
    exit 2
}

rec= flags= lax=
case ${1-} in
    --help) print_help; exit $?;;
esac
while getopts ":cinhlrA:B:C:EHRL" OPTION; do
    case $OPTION in
        r|R) rec='-r' ;;
        c|i|n|h|H) flags="$flags -$OPTION" ;;
        L) lax=yes;;
        A|B|C) flags="$flags -$OPTION $OPTARG" ;;
        \?) usage_error "'-$OPTARG': invalid option";;
        \:) usage_error "'-$OPTARG': option requires an argument";;
        *) echo 'INTERNAL ERROR' >&2; exit 100;;
    esac
done
shift $(($OPTIND - 1))

case $# in
    0) funcname=main;;
    *) funcname=$1; shift;;
esac
if [ $# -eq 0 ]; then
    rec='-r'
    set .
fi

regexp="($funcname)[ 	]*\\( *($|[^0-9])"
case $lax in
    '') regexp="^$regexp";;
     *) regexp="^(rpl_|_|__)?$regexp";;
esac

exec egrep -I -n $rec $flags -e "$regexp" "$@"

# vim: ft=sh ts=4 sw=4 et
