#!sh
# Print a single field from all records in the given file(s).
# Field separator is configurable from command-line option '-F'.
# Basically, just a thin convenience wrapper around awk.

set -u

progname=${0##*/}

print_usage ()
{
  echo "Usage: $progname [--help] [-F FIELD-SEPARATOR] [--]"
  echo "       FIELD-NUMBER [FILE-1 ... FILE-n]"
}

print_help ()
{
  print_usage
  echo "\"FIELD-NUM = 0\" means all fields."
}

usage_error ()
{
  [ $# -gt 0 ] && echo "$progname: $*" >&2
  print_usage >&2
  exit 2
}

awk_field_separator=' '
while [ $# -gt 0 ]; do
  case $1 in
    --help)
      print_help; exit $?
      ;;
    -F)
      if [ $# -eq 1 ]; then
        usage_error "'$1': option requires an argument"
      else
        awk_field_separator=$2
        shift
      fi
      ;;
    -F*)
      awk_field_separator=${1##-F};;
    --)
      shift; break;;
    -*)
      usage_error "'$1': invalid option";;
    *)
      break
      ;;
  esac
  shift
done

if [ $# -gt 0 ]; then
  usage_error "no field specified"
elif ! [ 0 -le "$1" ] >/dev/null 2>&1; then
  usage_error "'$1': not a non-negative integer"
else
  field=$1
  shift
fi

exec awk -F"$awk_field_separator" "{ print \$$field; }" ${1+"$@"}

# vim: ft=sh ts=4 sw=4 et
