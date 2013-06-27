#!bash
# Wrapper around lame(1) to convert wav files into mp3 files.

set -u            # die if any unset variable is expanded
shopt -s extglob  # extended globbing for 'case' and '[['
set -o noglob     # don't do globbing on files

declare -r progname=${0##*/}
declare -r version=0.5
declare -r LAME=${LAME-'lame'}
declare -ir EXIT_SUCCESS=0
declare -ir EXIT_FAILURE=1
declare -ir E_USAGE=2

xecho() {
    printf '%s\n' "$*"
}

usage_error() {
    (($# > )) && echo "$progname: $*" >&2
    print_usage >&2
    exit $E_USAGE
}

error() {
    xecho "$progname: error: $*" >&2
    exit $EXIT_FAILURE
}

print_usage() {
    local _filler_=$(xecho "$progname" | sed 's/./ /g')
    cat <<EOU
Usage: $progname [--help|--version] [-v] [-p LAME-PRESET]
       $_filler_ [-o OUTFILE] [--] INFILE
EOU
}

print_version() {
    xecho "$progname, version $version"
}

print_help() {
    print_version \
      && xecho \
      && print_usage \
      && cat <<EOH

BRIEF DESCRIPTION
  $progname convert a file from WAV format to MP3 format, using lame(1).
  If the name of input file is '-', then input is taken from standard
  input.

OUTPUT FILE NAME
  By default, the name of output file is FILE.mp3, where FILE is the name
  of input file with the suffix '.wav' (if any) stripped off; but, if the
  input file is '-' (i.e. the input is taken from standard input), then
  the output is sent by default to standard output.
  Obviously, the user can explicitly choose the output file, with the
  '-o' option (see below).

OPTIONS
 --help
    Display this help screen on standard output, and exit.
    This option is recognized only if it's given as the first option.
 --version
    Display this help screen on standard output, and exit.
    This option is recognized only if it's given as the first option.
 -v
    Turn on lame verbosity.
 -p PRESET
    Set to PRESET the lame preset to be used in creation of mp3-file.
    Default is "extreme".
 -o OUTFILE
    Set the output file to OUTFILE; a value of '-' means that output
    must be written to standard output.

ENVIRONMENT
  The name/path of the lame program to use is taken from the environmental
  variable 'LAME' (default to "lame").
EOH
}

can_read_or_die() {
    local write_err
    [[ "$1" == "-" ]] && return  # assume standard input readable
    [ -d "$1" ] && error "$1: cannot read: Is a directory"
    read_err=`(exec 9<"$1") 2>&1` || \
      error "$1: cannot read: ${read_err##*:@( )}"
}

can_write_or_die() {
    local write_err
    [[ "$1" == "-" ]] && return  # assume standard output writable
    [ -d "$1" ] && error "$1: cannot write: Is a directory"
    write_err=`(exec 9>>"$1") 2>&1` || \
      error "$1: cannot write: ${write_err##*:@( )}"
}

normalize_filename() {
    local fname=$1
    case "$fname" in -?*) fname=./$fname;; esac
    xecho "$fname"
}

readonly OPTSTRING="vp:o:"
case ${1-} in
    --help) print_help; exit $?;;
    --version) print_version; exit $?;;
esac

lame_preset='extreme'
lame_verbose=''
unset outfile
while getopts ":$OPTSTRING" OPTION; do
    case "$OPTION" in
        v) lame_verbose='--verbose';;
        p) lame_preset=$OPTARG;;
        o) outfile=$OPTARG;;
        \?) usage_error "-$OPTARG: invalid option";;
        \:) usage_error "-$OPTARG: argument required";;
    esac
done
shift $((OPTIND - 1))
unset OPTION OPTARG OPTERR OPTIND

case $# in
    0) usage_error "missing argument";;
    1) infile=$1;;
    *) usage_error "too many arguments";;
esac

# MAIN CODE

if [[ ${outfile+set} != set ]]; then
    case $infile in
        -) outfile=-;;
        *) outfile=${infile%%.@(wav|WAV)}.mp3;;
    esac
fi

type -P "$LAME" >/dev/null 2>&1 || error "lame program '$LAME' not found"

can_read_or_die "$infile"
can_write_or_die "$outfile"

infile=$(normalize_filename "$infile")
outfile=$(normalize_filename "$outfile")

exec -a "$progname" "$LAME" $lame_verbose -h --preset "$lame_preset" \
                            "$infile" "$outfile"

# vim: et sw=4 ts=4 ft=sh
