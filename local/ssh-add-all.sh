#!bash

me=${0##*/}

if [ $# -gt 0 ]; then
    echo "$me: must be called without arguments" >&2
    exit 2
fi

shopt -s nullglob

set -- "$HOME"/.ssh/*.id_[rd]sa
if [ $# -eq 0 ]; then
    echo "$me: no key to add (check ~/.ssh)" >&2
    exit 1
else
    exec ssh-add "$@"
fi

exit 255 # NOTREACHED

# vim: ft=sh ts=4 sw=4 et
