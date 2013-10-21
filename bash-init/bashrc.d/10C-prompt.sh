# -*- bash -*-
# Customization of command prompt for bash. 

# Get current directory, with $HOME abbreviated with a tilde.
# Handle also the case where $HOME is a symlink (e.g., FreeBSD).
_ps1_real_HOME=$(cd "$HOME" && pwd -P)
_ps1_pretty_cwd()
{
    local d='' red='' std=''
    while (($#)); do
        case $1 in
            -c|--color*) red=${_ps1_red} std=${_ps1_std};;
            *) break;;
        esac
        shift
    done
    d=$(pwd -L 2>/dev/null)
    if [[ $? -eq 0 && -n "$d" ]]; then
        sed <<<"$d" -e "s|^${HOME}$|~|" \
                    -e "s|^${HOME}/||" \
                    -e "s|^${_ps1_real_HOME}$|~|" \
                    -e "s|^${_ps1_real_HOME}/||" \
                    -e 's|//*|/|g'
        return $SUCCESS
    else
        xecho "$red[INVALID DIR${PWD:+" -- $PWD"}]$std"
        return $FAILURE
    fi
}

# Real terminal escape character mess up *badly* the command line
# editing, so we use only escape sequence that will be suitably
# interpreted by bash itself when drawing the prompt.
_ps1_escape()
{
    printf '%s' "\\[\\e[${1}m\\]"
}

# Start bold text.
readonly _ps1_B=$(_ps1_escape 1)
# End bold text.
readonly _ps1_b=$(_ps1_escape 22)
# Restore normal text.
readonly _ps1_raw=$(_ps1_escape 0)
# Restore normal color.
readonly _ps1_std=$(_ps1_escape '')
# Set to magenta foreground.
readonly _ps1_magenta=$(_ps1_escape '1;35')
# Set to red foreground.
readonly _ps1_red=$(_ps1_escape '1;31')
# Set to blue foreground.
readonly _ps1_blue=$(_ps1_escape '1;34')
# Set to green foreground.
readonly _ps1_green=$(_ps1_escape '1;32')
# Set to green background.
readonly _ps1_green_bg=$(_ps1_escape '1;42')
# Set to "pale yellow" (basically ochre).
readonly _ps1_ochre=$(_ps1_escape '0;33')

# Be happy or sad depending on the previous exit status (or to the given
# parameter, if any).
# Only for internal use in prompt drawing.
_ps1_smiley()
{
    local _ps1_prev_rc=$?
    [ $# -gt 0 ] && _ps1_prev_rc=$1
    ps1_smiley="{$_ps1_prev_rc} "
    if ((${_ps1_prev_rc} == 0)); then
        ps1_smiley="${ps1_smiley}${_ps1_blue}:-)"
    else
        ps1_smiley="${ps1_smiley}${_ps1_red}:-("
    fi
    ps1_smiley="${ps1_smiley}${_ps1_raw}"
}

_ps1()
{
    # The exit status of the last command (hopefully).
    _ps1_last_exit_status=${1-$?}

    case ${HACKED_PS1-} in
        [nN]o) return;; # Rely on PS1 defined by the user.
            *) ;;       # Go ahead: we have to reset PS1 properly.
    esac

    # Get a colorful smiley that (should) represent the exit status of the
    # last command.
    local ps1_smiley                     # Will be set by...
    _ps1_smiley ${_ps1_last_exit_status} # ... this.

    # The string "user@host", underlined.

    # The small coloured prompt which is on the same line where command
    # is entered.
    local _ps1_dollar _ps1_dollar_color
    if [ $UID -eq 0 ]; then
      _ps1_dollar=\#
      _ps1_dollar_color=${_ps1_ochre}
    elif [[ $BLEEDING_WITNESS =~ [yY]es ]]; then
      _ps1_dollar=%
      _ps1_dollar_color=${_ps1_green_bg}
    else
      _ps1_dollar=\$
      _ps1_dollar_color=
    fi
    _ps1_dollar=${_ps1_dollar_color}${_ps1_dollar}${_ps1_raw}
    local _ps1_mini="${ps1_smiley} ${_ps1_dollar} "

    local _ps1_who_where="\\u@\\h"
    if [[ $UID -eq 0 ]]; then
      _ps1_who_where=${_ps1_red}${_ps1_who_where}${_ps1_raw}
    elif [[ -n $SSH_CONNECTION ]]; then
      _ps1_who_where=${_ps1_ochre}${_ps1_who_where}${_ps1_raw}
    # When running on a remote system under screen(1), the ssh-related
    # variables can be no longer available.  So we use a different color
    # to make it plain that, being under screen, we might be running on
    # a remote system.  This might be a bit of an hack, but since I only
    # use screen for remote systems, is good enough for me.
    elif [[ -n $STY || $TERM == screen ]]; then
      _ps1_who_where=${_ps1_blue}${_ps1_who_where}${_ps1_raw}
    fi
    PS1="$_ps1_raw\n$_ps1_who_where [$(_ps1_pretty_cwd --color)] \A"
    if [ -n "$VIRTUAL_ENV" ]; then
        local _ps1_venv="${_ps1_B}${VIRTUAL_ENV}${_ps1_b}"
        PS1="${PS1}\nvirtualenv --> ${_ps1_venv}"
    fi
    PS1="${PS1}\n${_ps1_mini}"

    # Return the exit status of the command which preceded us.
    return ${_ps1_last_exit_status}
}

case $TERM in
    xterm*|rxvt*)
        PROMPT_COMMAND='
            _ps1_last_exit_status=$?
            echo -ne "\033]0;${USER}@${HOSTNAME%%.*}: $(_ps1_pretty_cwd)\007"
            _ps1 ${_ps1_last_exit_status}
            unset _ps1_last_exit_status'
        ;;
    *)
        # NOTE: the first assignment of PS1 is necessary on FreeBSD,
        # otherwise PROMPT_COMMAND won't work
        PROMPT_COMMAND='_ps1 $?'
        eval "$PROMPT_COMMAND"
        ;;
esac

function @myp { PS1=@HACKME; HACKED_PS1=yes; }
function @mip { HACKED_PS1=no; PS1='$ '; }

# Default prompt: bells and whistles and chrome!
@myp

# vim: ft=sh ts=4 sw=4 et
