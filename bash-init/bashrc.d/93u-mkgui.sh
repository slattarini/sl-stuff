# -*- bash -*-
# Build "alias functions" to launch GUI commands from a shell (in an
# X-Terminal).

# No point sourcing this if we are not in an X session.
[ -n "$DISPLAY" ] || return $SUCCESS

MakeGUI ()
{
    local mkgui_program # Will be looped on later.
    local mkgui_exitval=$SUCCESS
    local mkgui_added_head_code=''
    local mkgui_added_tail_code=''
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
        :) fwarn "'-$OPTARG': argument required"; return $E_USAGE;;
        *) fwarn "'-$OPTARG': invalid option"; return $E_USAGE;;
      esac
    done
    shift $((OPTIND - 1))
    (($#)) || { fwarn "missing argument"; return $E_USAGE; }

    for mkgui_program in "$@"; do

        # Ignore empty arguments.
        [ -z "$mkgui_program" ] && continue

        # Does the program exist, and is it executable?
        if ! W "$mkgui_program"; then
            if [[ ${MKGUI_VERBOSE_ON_MISSING_PROGRAMS-} == [yY]* ]]; then
              fwarn "'$mkgui_program': program not found"
              mkgui_exitval=$FAILURE
            fi
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

        if (($? != 0)); then
            fwarn "$mkgui_funcname can't be declared as function," \
                  "due to an unknown error"
            mkgui_exitval=$FAILURE
            continue
        fi

    done

    return $mkgui_exitval
}

MakeGUI \
    firefox libreoffice pidgin vuze easytag emacs \
    gitk qgit hgview xpdf xdvi gv iceweasel icedove \
    smalltalk cssed gimp freeciv heretic alsaplayer \
    audacity ristretto comix

MakeGUI -w aoss -- clanbomber bomberclone

if W firefox3; then
    MakeGUI firefox3
    W firefox || firefox() { firefox3 "$@"; }
fi

return $SUCCESS

#--------------------------------------------------------------------------

# vim: ft=sh ts=4 sw=4 et
