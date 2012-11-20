# -*- bash -*-

##--------------------------------------------##
##  CUSTOMIZATION OF COMMAND PROMPT FOR BASH  ##
##--------------------------------------------##

# Get current directory, with $HOME abbreviated with a tilde.
# Handle also the case where $HOME is a symlink (e.g., FreeBSD).
_ps1_real_HOME=$(cd "$HOME" && pwd -P)
_ps1_pretty_cwd()
{
    local d='' red='' std=''
    declare -i short=0
    while (($#)); do
        case $1 in
            -c|--color*) red=${_ps1_red} std=${_ps1_std};;
            -s|--short*) short=1;;
            *) break;;
        esac
        shift
    done
    d=$(pwd -L 2>/dev/null)
    if [[ $? -eq 0 && -n "$d" ]]; then
        if ((short)); then
            case $d in
                /) echo '/';;
                $HOME|${_ps1_real_HOME}) echo '~';;
                *) echo "${d##*/}";;
            esac
        else
            sed <<<"$d" -e "s|^${HOME}$|~|" \
                        -e "s|^${HOME}/|~/|" \
                        -e "s|^${_ps1_real_HOME}$|~|" \
                        -e "s|^${_ps1_real_HOME}/|~/|" \
                        -e 's|//*|/|g'
        fi
        return $SUCCESS
    else
        if ((short)); then
            xecho "$red[INVALID DIR]$std"
        else
            xecho "$red[INVALID DIR${PWD:+" -- $PWD"}]$std"
        fi
        return $FAILURE
    fi
}
declare -rf _ps1_pretty_cwd

# The detailed name of the running shell.
_ps1_sh_version=${BASH_VERSINFO[0]}.${BASH_VERSINFO[1]}

# Real terminal escape character mess up *badly* the command line
# editing, so we use only escape sequence that will be suitably
# interpreted by bash itself when drawing the prompt.
_ps1_escape()
{
    printf '%s' "\\[\\e[${1}m\\]"
}
declare -rf _ps1_escape

# Start bold text.
readonly _ps1_B=$(_ps1_escape 1)
# End bold text.
readonly _ps1_b=$(_ps1_escape 22)
# Start underlined text.
readonly _ps1_U=$(_ps1_escape 4)
# End underlined text.
readonly _ps1_u=$(_ps1_escape 24)
# Restore normal text
readonly _ps1_raw=$(_ps1_escape 0)
# Restore normal color
readonly _ps1_std=$(_ps1_escape '')
# Set to cyan foreground
readonly _ps1_cyan=$(_ps1_escape '1;36')
# Set to magenta foreground
readonly _ps1_magenta=$(_ps1_escape '1;35')
# Set to red foreground
readonly _ps1_red=$(_ps1_escape '1;31')

#--------------------------------------------------------------------------

# Be happy or sad depending on the previous exit status (or to the given
# parameter, if any).
# Only for internal use in prompt drawing.
_ps1_smiley()
{
    local _ps1_prev_rc=$?
    [ $# -gt 0 ] && _ps1_prev_rc=$1
    ps1_smiley="{$_ps1_prev_rc} "
    if ((${_ps1_prev_rc} == 0)); then
        ps1_smiley="${ps1_smiley}${_ps1_cyan}:-)"
    else
        ps1_smiley="${ps1_smiley}${_ps1_magenta}:-("
    fi
    ps1_smiley="${ps1_smiley}${_ps1_raw}"
}
declare -rf _ps1_smiley

#--------------------------------------------------------------------------

#
# The huge complex function that will draw our prompt.
#

_ps1() {

    local s='##'
    case "${1-}" in
        --funny-string=*) s=${1#*=}; shift;;
        --funny-string) s=$2; shift 2;;
    esac

    # The exit status of the last command (hopefully).
    _ps1_last_exit_status=${1-$?}

    case "${HACKED_PS1-}" in
        ""|0|[nN]o|[Ff]alse) return;; # rely on PS1 defined by the user
        *) ;; # go ahead: we have to reset PS1 properly
    esac

    # Get a colorful smiley that (should) represent the exit status of the
    # last command.
    local ps1_smiley                     # Will be set by...
    _ps1_smiley ${_ps1_last_exit_status} # ... this.

    # The string "user@host", underlined.
    local uh="${_ps1_U}\\u@\\h${_ps1_u}"

    # The small coloured prompt which is on the same line where command is
    # entered.
    local mini_prompt=${ps1_smiley}
    case $BLEEDING_WITNESS in
      [yY]es) mini_prompt="${mini_prompt} ${_ps1_red}\$${_ps1_raw} ";;
           *) mini_prompt="${mini_prompt} \$ ";;
    esac

    # Try to display the most fitting prompt, depending on the size of the
    # screen.
    if ! [ 0 -lt "${COLUMNS-0}" ] >/dev/null 2>&1; then
        # COLUMNS  variable seems broken, do not rely on it
        PS1=""
    elif [ $COLUMNS -gt 94 ]; then
        PS1="\
$_ps1_raw
$uh $s \\D{%T} $s"
        if [ -n "$VIRTUAL_ENV" ]; then
            local _ps1_venv="${_ps1_B}${VIRTUAL_ENV}${_ps1_b}"
            PS1=$PS1$'\n'"virtualenv --> ${_ps1_venv}"
        fi
        local _ps1_cwd="${_ps1_U}$(_ps1_pretty_cwd --color)${_ps1_u}"
        PS1=$PS1$'\n'"dir --> ${_ps1_cwd}"
    elif [ $COLUMNS -gt 50 ]; then
        local _ps1_cwd="${_ps1_U}$(_ps1_pretty_cwd -s -c)${_ps1_u}"
        PS1="$_ps1_raw"$'\n'"$uh [${_ps1_cwd}]"
        if [ -n "$VIRTUAL_ENV" ]; then
            PS1="${PS1} (${_ps1_B}$(basename "$VIRTUAL_ENV")${_ps1_b})"
        fi
    fi
    PS1=${PS1}$'\n'${mini_prompt}

    # Return the exit status of the command which preceded us.
    return ${_ps1_last_exit_status}

}
declare -rf _ps1

case "$TERM" in
    xterm*|rxvt*)
        PROMPT_COMMAND='
            _ps1_last_exit_status=$?
            echo -ne "\033]0;${USER}@${HOSTNAME%%.*}: $(_ps1_pretty_cwd)"
            echo -ne "  §§  ${_ps1_sh_version}  §§  \007"
            _ps1 --funny-string="§§" ${_ps1_last_exit_status}
            unset _ps1_last_exit_status'
        ;;
    *)
        # NOTE: the first assignment of PS1 is necessary on FreeBSD,
        # otherwise PROMPT_COMMAND won't work
        PROMPT_COMMAND='_ps1 --funny-string="%%" $?'
        eval "$PROMPT_COMMAND"
        ;;
esac

function @myp { PS1=@HACKME; HACKED_PS1=yes; }
function @mip { HACKED_PS1=no; PS1='$ '; }

# Default prompt: bells and whistles and chrome!
@myp

#=#=#----------------------------------------------------------------------

# vim: ft=sh ts=4 sw=4 et
