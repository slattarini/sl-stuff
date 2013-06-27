#!/bin/bash
# Convert a file from ogg to mp3.

#--------------------------------------------------------------------------

#
# Global variables and settings.
#

set -u

readonly progname=${0##*/}

# program official name
readonly PROGRAM=ogg2mp3
# program official version
readonly VERSION="0.4beta1"

# directory for temporary files.
declare -rx TMPDIR=${TMPDIR-"/tmp"}

# standard exit statuses
declare -ir EXIT_SUCCESS=0
declare -ir EXIT_FAILURE=1
declare -ir E_USAGE=2

# lame and sox utilities possibly passed through environment
readonly SOX=${SOX-"sox"}
readonly LAME=${LAME-"lame"}

readonly moreinfo="Try \`$progname --help' for more info."

readonly tab=$'\t'
readonly nl=$'\n'

#--------------------------------------------------------------------------

#
# Informational functions.
#

print_version() {
    echo "$PROGRAM, version $VERSION"
}

print_usage() {
    cat <<EOU
Usage: $progname [--help] [--version] [--preset=LAME-PRESET] 
       [--verbose|--quiet] [--] INFILE.ogg [OUTFILE]"
EOU
}

print_help() {
    print_version
    echo "Convert a file from ogg format to mp3 format," \
         "using lame(1) and sox(1)."
    echo
    print_usage
    echo
    cat <<'EOT'
User is free to select a lame(1) preset to be used in creation of the mp3
file, with `--preset' option.
Option `--verbose' makes both sox and lame more verbose, while option 
`--quiet' makes them more quiet.

If OUTFILE is not explicitly specified, it will be automatically set to
`INFILE.mp3'; if OUTFILE is `-', then output will be written to standard
output; if INFILE is `-', then input will be read from standard input.

Name or path of sox utility can be passed to the script through `SOX' 
environmental variable (defaults to "sox"), and similarly name or path 
of sox utility can be passed to the script through `LAME' environmental
variable (defaults to "lame").
EOT
}

#--------------------------------------------------------------------------

#
# Working functions.
#

error() {
   echo "$progname: error: ${*-(unknown error)}" >&2
   exit $EXIT_FAILURE
}

usage_error() {
    [ -n "$*" ] && echo "$progname: $*" >&2
    print_usage >&2
    printf '%s\n' "$moreinfo" >&2
    exit $E_USAGE
}

# Perform any needed cleanup for temporary files.
cleanup_at_exit() {
   rm -rf ${tmpdir+"$tmpdir"}
}

# Create the temporary directory (if it has not been created yet), and
# save its name in the global readonly variable `tmpdir'.
mktempdir() {
   if [[ ${tmpdir+set} != set ]]; then
      tmpdir=`(umask 077 && mktemp -t -d -- "$progname-XXXXXXXXXXXX")` ||
        error "failed to create temporary directory in \`$TMPDIR'"
      readonly tmpdir
   fi
}

# Return 1 if $1 is an executable program or a command found in PATH,
# return 0 otherwise.
wh() {
    type -P "$1" &>/dev/null
}

# Return 0 if $1 is writable, and 1 if not.
# Write any possible error message on standard error.
can_write_to() {
   f="$1" sh -c '( : >> "$f" )' "$progname" || return $EXIT_FAILURE
   return $EXIT_SUCCESS
}

# Return 0 if $1 is readable, and 1 if not.
# Write any possible error message on standard error.
can_read_from() {
   if [ -d "$1" ]; then
      echo "$progname: $1: Is a directory" >&2
      return $EXIT_FAILURE
   fi
   f="$1" sh -c '( : <"$f" )' "$progname" || return $EXIT_FAILURE
   return $EXIT_SUCCESS
}

lame_wrapper() {
    local infile="$1" outfile="$2" tmpfile=""
    if [[ "$outfile" == - ]]
    then
        $LAME $lame_verbosity -h --preset "$lame_preset" "$infile" -
        return $?
    fi
    tmpfile="$tmpdir/lame-output.mp3"
    $LAME $lame_verbosity -h --preset "$lame_preset" "$infile" "$tmpfile"
    case $? in
        $EXIT_SUCCESS)
            cat "$tmpfile" > "$outfile"
            return $EXIT_SUCCESS
            ;;
        *)
            return $EXIT_FAILURE
            ;;
    esac
    
}

#--------------------------------------------------------------------------

#
# Option parsing.
#

lame_preset='extreme'
lame_verbosity=''
sox_verbosity=''

while [ $# -gt 0 ]; do
    case "$1" in
        --help)
            print_help
            exit $EXIT_SUCCESS
            ;;
        --version)
            print_version
            exit $EXIT_SUCCESS
            ;;
        --quiet|-q)
            lame_verbosity="--quiet"
            sox_verbosity="-V1"
            ;;
        --verbose|-v)
            lame_verbosity="--verbose"
            sox_verbosity="-V3"
            ;;
        --preset|--lame-preset|-p)
            lame_preset=${2-}
            if [ -z "$lame_preset" ]; then
                usage_error "option \`$1' requires an argument"
            fi
            shift
            ;;
        -p*)
            lame_preset=`echo X"$1" | sed '1s/^X-p//'`
            ;;
        --lame-preset=*|--preset=*)
            lame_preset=`echo X"$1" | sed '1s/^[^=]*=//'`
            ;;
        --)
            shift
            break
            ;;
        -)
            break
            ;;
        -*)
            usage_error "\`$1': invalid option"
            ;;
        *)
            break
            ;;
    esac
    shift
done

#--------------------------------------------------------------------------

#
# Main code.
#

trap 'cleanup_at_exit $?' EXIT
trap 'exit 1' HUP INT QUIT PIPE TERM

(( $# == 0 )) && usage_error  "missing argument"
(( $# > 2  )) && usage_error  "too many arguments"

# check lame and sox utilities.
wh "$SOX"  || error "cannnot find sox(1) utility.${nl}$moreinfo"
wh "$LAME" || error "cannnot find lame(1) utility.${nl}$moreinfo"

ogg_file="$1"
mp3_file=${2-"$(basename -- "$ogg_file" .ogg).mp3"}

can_read_from "$ogg_file" || exit $EXIT_FAILURE
can_write_to  "$mp3_file" || exit $EXIT_FAILURE

set -o pipefail
$SOX $sox_verbosity -t ogg "$ogg_file" -t wav - | lame_wrapper "$mp3_file"
exit $(( $? == $EXIT_SUCCESS ? $EXIT_SUCCESS : $EXIT_FAILURE ))

#--------------------------------------------------------------------------

# vim: ft=sh ts=4 sw=4 et
