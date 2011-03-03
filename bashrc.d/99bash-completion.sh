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

: "${BASH_COMPLETION=/etc/bash_completion}"

if ! [[ -f "$BASH_COMPLETION" && -r "$BASH_COMPLETION" ]]; then
    mwarn "  expected bash completion file \`$BASH_COMPLETION"
    mwarn "  does not exist or is not a regular readable file."
    mwarn "  Bash's advanced completion features will not be avaible."
    return $SUCCESS
fi

. "$BASH_COMPLETION"
if (($? != 0)); then
    mwarn "some errors occurred while loading bash completion file" \
          "\`$BASH_COMPLETION'"
    mwarn "Some bash's advanced completion features may not be avaible."
    return $SUCCESS
fi

return $SUCCESS

# vim: expandtab tabstop=4 shiftwidth=4 ft=sh
