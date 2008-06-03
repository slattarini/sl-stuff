#-*- bash -*-

# NOTE: We can safely assume we are running under bash version 2.05
#       or grater

#
# Enable advanced bash completion by loading the proper files
#
# **** IMPORTANT NOTE ****
# This file should be the last one sourced in the initialization process,
# otherwise it could not recognize the proper completion for some personal
# aliases and/or functions defined in the other shell initialization files.
#

BASH_COMPLETION="$HOME/lib/bash_completion"
BASH_COMPLETION_DIR="${BASH_COMPLETION}.d"

if ! [[ -f "$BASH_COMPLETION" && -r "$BASH_COMPLETION" ]]; then
    mwarn "  expected bash completion file \`$BASH_COMPLETION"
    mwarn "  does not exist or is not a regular readable file."
    mwarn "  Bash's advanced completion features will not be avaible."
    return $SUCCESS
fi

if ! [[ -d "$BASH_COMPLETION_DIR" && -r "$BASH_COMPLETION_DIR" &&
        -x "$BASH_COMPLETION_DIR" ]]; then
    mwarn "  expected bash completion directory \`$BASH_COMPLETION_DIR'"
    mwarn "  does not exist, is not a directory or is not fully readable."
    mwarn "  Some bash's advanced completion features will not be avaible."
    return $SUCCESS
fi

# Some variables influential for command completion.
MAKE_PROGRAMS='make-3.75 gmake-3.75' #XXX: ???

. "$BASH_COMPLETION"
if [ $? -ne 0 ]; then
    mwarn "some errors occurred while loading bash completion file" \
          "\`$BASH_COMPLETION'"
    mwarn "Some bash's advanced completion features may not be avaible."
    return $SUCCESS
fi

return $SUCCESS

# vim: expandtab tabstop=4 shiftwidth=4 ft=sh
