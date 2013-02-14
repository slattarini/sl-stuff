#!/bin/sh
set -u
vim=${VIM:-vim}
if test -n "${DISPLAY:-}"; then
  vim="$vim -g --nofork"
fi
exec $vim "$@"
