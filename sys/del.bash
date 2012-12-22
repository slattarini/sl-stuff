#!bash
# Reversible file deleter: move files and directory in a "trash" directory
# rather than really removing them.

set -u
shopt -s extglob

readonly progname=${0##*/}
readonly VERSION=0.9alpha
readonly PROGRAM="Reversible Delete"

declare -ir EXIT_SUCCESS=0
declare -ir EXIT_FAILURE=1
declare -ir E_USAGE=2
declare -ir E_INTERNAL=100

print_usage ()
{
  echo "Usage: $progname [-i] [--] FILE-1 [FILE-2... FILE-n]"
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
  --version:
       print program version and exit
  --help:
       print this help message and exit
EOT
}

warn ()
{
  echo "$progname: $*" >&2
}

fatal ()
{
  warn "$@"
  exit $EXIT_FAILURE
}

usage_error ()
{
  [ $# -gt 0 ] && warn "$@"
  print_usage >&2
  exit $E_USAGE
}

exists ()
{
  [[ -e "$1" || -h "$1" ]]
}

trashname ()
{
  local f=${1%%*(/)}
  echo "${T}/${f##*/}___$(LC_ALL=C date '+%Y-%m-%d_%H:%M:%S')"
}

delete ()
{
  local file=$1

  if ((ask)); then
    local reply
    printf "Delete '$file'? (y/n) [N] " >&2
    read reply
    case $reply in [yY]*);; *) return 0;; esac
  fi

  local destfile=$(trashname "$file")

  if exists "$destfile"; then
    sleep 1
    destfile=$(trashname "$file")
    if exists "$destfile"; then
      warn "$file: cannot delete: preexisting file in trash dir"
      return 1
    fi
  fi

  mv -- "$file" "$destfile"
}

declare -i ask=0
while [ $# -gt 0 ]; do
  case $1 in
    --help) print_help; exit $?;;
    --version) print_version; exit $?;;
    -i|--ask) ask=1;;
    --) shift; break;;
    -*) usage_error "'$1': unrecognized option";;
     *) break;;
  esac
done
[ $# -gt 0 ] || usage_error "missing argument"

T=${TRASH_DIRECTORY:-"$HOME/.trash"}

[ -d "$T" ] || mkdir -p -m 700 "$T" || \
  fatal "trash directory '$T': is not a directory, and cannot be created"

[[ -r "$T" && -x "$T" && -w "$T" ]] || \
  fatal "trash directory '$T': bad permissions"

exit_status=$EXIT_SUCCESS
for file in "$@"; do
  delete "$file" || exit_status=$EXIT_FAILURE
done
exit $exit_status

# vim: et ts=2 sw=2 ft=sh
