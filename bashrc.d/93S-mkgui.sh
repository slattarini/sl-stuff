# -*- bash -*-

#
# Build "alias functions" to launch GUI commands from a shell (in an
# X-Terminal).
#

IsHost bigio || IsHost bplab || return $SUCCESS

#--------------------------------------------------------------------------

readonly mkgui_E_NOGUI=15

_mkgui_check_display ()
{
    if [[ -z ${DISPLAY-} ]]; then
        fwarn "'DISPLAY' variable not set, cannot connect to screen." \
              " Is the X server running?"
        return $mkgui_E_NOGUI
    else
        return $SUCCESS
    fi
}
declare -rf _mkgui_check_display

# The big, ugly, do-it-all function.
MakeGUI ()
{
    local mkgui_added_head_code=''
    local mkgui_added_tail_code=''
    local mkgui_exitval=$SUCCESS

    # TODO: maybe use getopts for option parsing?
    local mkgui_action='eval'
    local mkgui_program_wrapper=command
    local OPTION OPTARG OPTIND
    while getopts ':-ph:t:w:' OPTION; do
      case $OPTION in
        p) mkgui_action='xecho';;
        h) mkgui_added_head_code=$mkgui_added_head_code$'\n'$OPTARG;;
        t) mkgui_added_tail_code=$mkgui_added_tail_code$'\n'$OPTARG;;
        w) mkgui_program_wrapper=$OPTARG;;
        -) break;;
        :) fwarn "'-$OPTARG': argument required" >&2; return $E_USAGE;;
        *) fwarn "'-$OPTARG': invalid option" >&2; return $E_USAGE;;
      esac
    done
    shift $((OPTIND - 1))

    if (($# == 0)); then
        fwarn "missing argument"
        return $E_USAGE
    fi

    # Here we go...

    local mkgui_program

    for mkgui_program in "$@"; do

        # Ignore empty arguments.
        [ -z "$mkgui_program" ] && continue

        # Does the program exist, and is it executable?
        if ! which "$mkgui_program" &>/dev/null; then
            fwarn "'$mkgui_program': program not found"
            mkgui_exitval=$FAILURE
            continue
        fi

        local mkgui_funcname
        mkgui_funcname=${mkgui_program##*/}
        mkgui_funcname=${mkgui_funcname%%.*}

        # Is '$mkgui_funcname 'a valid function identifier?
        case "$mkgui_funcname" in
          ([a-zA-Z_]*([a-zA-Z0-9_])) ;;
          (*)
            fwarn "'$mkgui_funcname' is not a valid function identifier"
            mkgui_exitval=$FAILURE
            continue
            ;;
        esac

        local mkgui_as_true='1|+([yY])|[yY][eE][sS]|[tT]rue'
        local mkgui_as_false='*'

        # So that these values can be accessed by user-specified code in
        # $mkgui_added_head_code and $mkgui_added_tail_code, if needed.
        if [[ -n "$mkgui_added_head_code$mkgui_added_tail_code" ]]; then
            local mkgui_setup_names="
                local mkgui_funcname=$mkgui_funcname
                local mkgui_progname=$mkgui_progname
            "
        else
            local mkgui_setup_names=''
        fi

        $mkgui_action "
            $mkgui_funcname ()
            {

                _mkgui_check_display || return \$?

                $mkgui_setup_names
                $mkgui_added_head_code

                case \"\${XFUNC_VERBOSE-}\" in
                  ($mkgui_as_true)
                    $mkgui_program_wrapper $mkgui_program \"\$@\" &
                    ;;
                  ($mkgui_as_false)
                    $mkgui_program_wrapper $mkgui_program \"\$@\" \\
                      >/dev/null 2>&1 &
                esac

                $mkgui_added_tail_code

                return $SUCCESS
            }
        "

        (($? == 0)) || {
            fwarn "$mkgui_funcname can't be declared as function," \
                  "due to an unknown error"
            mkgui_exitval=$FAILURE
            continue
        }

    done

    return $mkgui_exitval
}

MakeGUI \
    firefox xterm xman libreoffice  pidgin vuze easytag \
    gitk qgit hgview xpdf zxpdf xdvi zxdvi gv ddd emacs \
    djview snake4

if W firefox3; then
    MakeGUI firefox3
    W firefox || firefox() { firefox3 "$@"; }
fi

if IsHost bigio; then
    MakeGUI \
       iceweasel icedove smalltalk bluej appletviewer \
       cssed netbeans civ freeciv heretic alsaplayer ggr
    MakeGUI -w aoss clanbomber bomberclone
fi

return $SUCCESS

#--------------------------------------------------------------------------

# vim: ft=sh ts=4 sw=4 et
