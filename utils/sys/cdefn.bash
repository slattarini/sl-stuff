#!bash
# Search the definition of a C macro in the given files.

set -u

rec= flags=
while getopts "cinhlrA:B:C:EHRL" OPTION; do
    case $OPTION in
        r|R) rec='-r';;
        c|i|n|h|H) flags="$flags -$OPTION";;
        A|B|C) flags="$flags -$OPTION $OPTARG";;
        \?|\:) exit 2;;
        *) echo 'INTERNAL ERROR' >&2; exit 100;;
    esac
done
shift $(($OPTIND - 1))

if [ -n "${1-}" ]; then
    tab='	' # An horizontal tabulation character.
    regexp="^[ $tab]*#[ $tab]*define[ $tab]+($1)[ $tab]+"
    shift
else
    echo Missing argument >&2
    exit 2
fi

if [ $# -eq 0 ]; then
    rec='-r'
    set .
fi

exec grep -E -n $rec $flags -e "$regexp" "$@"

# vim: ft=sh ts=4 sw=4 et
