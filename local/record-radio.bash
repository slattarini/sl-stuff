#!bash
# Record music from web radio(s) into pcm/wav format.

set -u
shopt -s extglob

readonly progname=${0##*/}
readonly version=0.5
readonly MPLAYER=${MPLAYER-mplayer}
readonly default_outfile=stream.pcm

print_usage () {
    echo "Usage: $progname [--help|--version] [-o OUTFILE] RADIO-URL"
}

print_version () {
    echo "$progname, version $version"
}

print_help () {
    print_version \
      && echo \
      && echo "\
Record music from \"web radio(s)\" into PCM/WAV format.
Default output file is \`$default_outfile' in the current directory, but
this can be changhed through the \`-o' option." \
      && echo \
      && print_usage
}

error () {
    echo "$progname: $*" >&2
    exit 1
}

usage_error () {
    echo "$progname: $*" >&2
    print_usage >&2
    exit 2
}

case ${1-} in
     --help) set -- '-h';;
  --version) set -- '-V';;
esac

outfile=$default_outfile
while getopts ":hVo:" OPTION; do
    case "$OPTION" in
         h) print_help; exit;;
         V) print_version; exit;;
         o) outfile=$OPTARG;;
        \:) usage_error "option '-$OPTARG' requires an argument" ;;
        \?) usage_error "unknown option '-$OPTARG'";;
    esac
done
shift $((OPTIND - 1))

case $# in
    0) usage_error "Missing argument";;
    1) radiourl=$1;;
    *) usage_error "Too many arguments";;
esac

# Check that outfile is writable.
err=$(true 2>&1 >>"$outfile") || error "$outfile: ${err##*:*( )}"

# Run mplayer to dump stream from radio.
exec $MPLAYER -cache 640 -vc dummy -vo null -ao pcm:waveheader \
              -ao pcm:file="$outfile" "$radiourl"

# vim: ft=sh et sw=4 ts=4
