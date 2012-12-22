#!bash
# apply: applies a program to multiple arguments in row

## GLOBAL SETTINGS

set -u          # don't accept to expand unset variables
set -o noglob   # no file globbing
set -C          # don't clobber existing file with redirections

## EXIT STATUSES

readonly SUCCESS=0
readonly FAILURE=1
readonly E_USAGE=2

## CONSTANTS

readonly progname=${0##*/}
readonly version='0.1beta3'
readonly usage="[--help|--version] [-X ARG-FOR-ALL] [--] PROGRAM [ARGS]"

## SUBROUTINES

xecho () {
    printf '%s\n' "$*"
}

print_usage () {
    xecho "Usage: $progname $usage"
}

print_version () {
    xecho "apply, version $version"
}

print_help () {
    print_version \
     && print_usage \
     && cat <<EOH

$progname: applies a program to multiple arguments in row.

If you want an option/argument to be passed to every PROGRAM's call,
give it to $progname as argument of the \`-X' option.

Examples (with GNU echo(1)):
  $ $progname echo 1 2 3
  1
  2
  3
  $ $progname -X -e echo '1' 'x\\0100y' '2'
  1
  x@y
  2
  $ $progname -X foo echo 1 2 3
  foo 1
  foo 2
  foo 3
  $ $progname -X foo -X bar echo 1 2 3
  foo bar 1
  foo bar 2
  foo bar 3
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

## OPTION PARSING

case ${1-} in
    --help) print_help; exit $?;;
    --version) print_version; exit $?;;
esac

declare -a program_opts=()
while getopts ":X:" OPTION; do
    case "$OPTION" in
         X) program_opts[${#program_opts[@]}]=$OPTARG;;
        \?) usage_error "'-$OPTARG': Invalid option";;
        \:) usage_error "'-$OPTARG': Option requires an argument";;
    esac
done
shift $((OPTIND - 1))
unset OPTION OPTERR OPTIND

case $# in
    0) usage_error "missing program to apply";;
    *) program=$1;;
esac
shift

st=$SUCCESS
for arg in "$@"; do
    "$program" ${program_opts+"${program_opts[@]}"} "$arg" || st=$FAILURE
done
exit $st

# vim: ft=sh ts=4 sw=4 et
