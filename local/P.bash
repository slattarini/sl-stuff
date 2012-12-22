#!bash
# Start recording current program of Radio Classica Bresciana on disk.
# Requires the auxiliary utility "record-radiocalassica".

e=0
set -e -u

dir=${RADIO_CLASSICA_BRESCIANA_CACHE-"$HOME/.radio-classica-bresciana.cache"}
[ -d "$dir" ] || mkdir -p "$dir"
cd "$dir"

max=0
for f in *; do
    n=${f%.*}
    if test "$max" -lt "$n" >/dev/null 2>&1; then
        max=$n
    fi
done
file=$(($max + 1)).wav
unset f n max

trap '
    trap - 0
    chmod a-w "$file" || e=1
    if [ -n "${devt-}" ]; then
        rm -f "$devt" || e=1
    fi
    if [ -n "${wholefile-}" ]; then
        echo "***"
        echo "*** OUTPUT FILE IS $wholefile ***"
        echo "***"
    fi
    exit $e
' 0
trap '
    echo "***" >&2
    echo "*** WARNING: recording interrupted, output file" \
                      "might be corrupted" >&2
    exit 1
' 2 3 15

wholefile=$(pwd)/$file
echo "Recording to file $wholefile..."
record-radioclassica -o "$file" || e=1

# mplayer (used by 'record-radioclassica') seems not to check if write(2)
# fails due to 'No space left on device' error, so we must do that check
# ourselves.
devt=$(mktemp ".devicetest-$file-$$-XXXXXX") || {
    echo "***"
    echo "*** WARNING: Cannot create device-testing tempfile in $(pwd),"
    echo "***          thus cannot check if device is full"
    exit 1
} >&2
# we need an echo(1) command that check for write(2) errors; the 'echo'
# builtin of bash does this, luckily
echo $$ >"$devt" || {
    echo "***"
    echo "*** WARNING: No space left on device," \
                      "recording might be incomplete"
    exit 1
} >&2

exit $e

# vim: et sw=4 ts=4 ft=sh
