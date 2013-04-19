#-*- bash -*-

#
# Enable advanced bash completion by loading the proper files
#
# **** IMPORTANT NOTE ****
# This file should be the last one sourced in the initialization process,
# otherwise it could not recognize the proper completion for some personal
# aliases and/or functions defined in the other shell initialization files.
#

if [[ -z $BASH_COMPLETION_SL ]]; then
    for d in $HOME/etc /usr/local/etc /etc /usr/share/bash-completion; do
        if test -f $d/bash_completion; then
            BASH_COMPLETION_SL=$d/bash_completion
            break
        fi
    done
fi

if [[ -z $BASH_COMPLETION_SL ]]; then
    mwarn "  no bash completion file could be found"
    mwarn "  Bash advanced completion features won't be available."
    return $SUCCESS
fi

if [[ ! -f $BASH_COMPLETION_SL || ! -r $BASH_COMPLETION_SL ]]; then
    mwarn "  expected bash completion file '$BASH_COMPLETION_SL"
    mwarn "  does not exist or is not a regular readable file."
    mwarn "  Bash advanced completion features won't be available."
    return $SUCCESS
fi

. "$BASH_COMPLETION_SL"
if (($? != 0)); then
    mwarn "some errors occurred while loading bash completion file" \
          "'$BASH_COMPLETION_SL'"
    mwarn "Some bash advanced completion features may not be available."
    return $SUCCESS
fi

return $SUCCESS

# vim: et ts=4 sw=4 ft=sh
