#-*- bash -*-

#
# Enable advanced bash completion by loading the proper files
#
# **** IMPORTANT NOTE ****
# This file should be the last one sourced in the initialization process,
# otherwise it could not recognize the proper completion for some personal
# aliases and/or functions defined in the other shell initialization files.
#

if [[ -z $BASH_COMPLETION ]]; then
    for d in $HOME/etc /usr/local/opt/etc /usr/local/etc /etc; do
        if test -f $d/bash_completion; then
            BASH_COMPLETION=$d/bash_completion
            break
        fi
    done
fi

if [[ -z $BASH_COMPLETION ]]; then
    mwarn "  no bash completion file could be found"
    mwarn "  Bash advanced completion features won't be avaible."
    return $SUCCESS
fi

if [[ ! -f $BASH_COMPLETION || ! -r $BASH_COMPLETION ]]; then
    mwarn "  expected bash completion file '$BASH_COMPLETION"
    mwarn "  does not exist or is not a regular readable file."
    mwarn "  Bash advanced completion features won't be avaible."
    return $SUCCESS
fi

. "$BASH_COMPLETION"
if (($? != 0)); then
    mwarn "some errors occurred while loading bash completion file" \
          "'$BASH_COMPLETION'"
    mwarn "Some bash's advanced completion features may not be avaible."
    return $SUCCESS
fi

# FIXME: hack to support git completion on FreeBSD; there should be a
#        better way!
if [ -f /usr/local/share/git-core/contrib/completion/git-completion.bash ]; then
  . /usr/local/share/git-core/contrib/completion/git-completion.bash
fi

return $SUCCESS

# vim: expandtab tabstop=4 shiftwidth=4 ft=sh
