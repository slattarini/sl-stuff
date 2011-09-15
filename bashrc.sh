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

# Refuse to run with non-bash shells.
if [ -z "${BASH-}" ] || [ -z "${BASH_VERSION-}" ]; then
  echo "$0: this shell is not Bash, ~/.bashrc initialization won't" \
       "be available" >&2
  return 0
fi

# Refuse to run with older bash version.
case $BASH_VERSION in
  [12].*)
    echo "$0: Bash version \`$BASH_VERSION' too old, ~/.bashrc" \
         "initialization won't be available" >&2
    return 0
    ;;
esac

PS1='\u@\h[bash-\v]$'

# Protect against multiple inclusion
[ x${BASHSHRC_INCLUDED+"set"} = x"set" ] && return 0
readonly BASHSHRC_INCLUDED=1

BASHRC_DIR="$HOME/.bashrc.d"

# Shell settings and function definition used by (possibly) many
# initialization files and procedures.

# Restore the PATH to a basic safe value.
PATH='/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin'
export PATH

# Real shell configuration is done here.
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
