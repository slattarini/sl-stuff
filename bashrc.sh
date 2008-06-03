#-*- bash -*-

# Shell must be interactive.
case "$-" in *i*) ;; *) return 0;; esac

# The shell must have an associate tty.
(
 PATH='/bin:/usr/bin'; export PATH
 LC_ALL=C tty | grep -i 'not.*tty' >/dev/null
) && return 0

# The shell standard output and error must be associated to terminals.
{ test -t 1 && test -t 2; } || return 0

# Refuse to run with shells != bash
[ -n "${BASH-}" ] && [ -n "${BASH_VERSION-}" ] || return 0

# Provide at least a suitable prompt for all bash shells
case "$BASH_VERSION" in
    1.*) PS1='\u@\h[bash-'${BASH_VERSION%%[^0-9.]*}']\$ ';;
      *) PS1='\u@\h[bash-\v]$ ';;
esac

# NOTE: we need this weird test since older versions of bash (e.g. 1.14)
# does not propagate correlty the exit status from an eval failed due to
# syntax errors.
(eval 'if >/dev/null 2>&1') >/dev/null 2>&1 && return 0

# Refuse to run with too much older versions of bash.
(eval '(
  { unset PATH || export PATH=""; } \
    && [[ 2 < ${BASH_VERSINFO[0]-0} \
          || 2 == ${BASH_VERSINFO[0]-0} && 04 < ${BASH_VERSINFO[1]-00} ]] \
    && set -o pipefail \
    && enable printf
) >/dev/null 2>&1') >/dev/null 2>&1 || return 0

# Protect against multiple inclusion
[ x${BASHSHRC_INCLUDED+"set"} = x"set" ] && return 0
readonly BASHSHRC_INCLUDED=1

BASHRC_DIR="$HOME/.bashrc.d"

# Shell settings and function definition used by (possibly) many
# initialization files and procedures.

# Restore the PATH to a basic safe value.
PATH='/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
export PATH

# Real shell configuarion is done here.
if test -d "$BASHRC_DIR"; then
    declare -rx BASHRC_DIR
    # Source the real initialization scripts.
    for shrc_file in "$BASHRC_DIR"/[0-9][0-9]*.sh; do
    if test -f "$shrc_file"; then
        echo "** SHINIT: including $shrc_file"
        . "$shrc_file" || {
            echo "ERROR while loading file \`$shrc_file'" >&2
            break
        }
    fi
    done
    unset shrc_file
else
    echo "WARNING: $BASHRC_DIR: Not a directory." >&2
    echo "No shell personalization avaible." >&2
    unset BASHRC_DIR
    return 1
fi

# vim: ft=sh ts=4 sw=4 et
