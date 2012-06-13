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

    local mkgui_check_arg='
      if test $# -lt 2; then
          fwarn "option '\'\$1\'' require an argument" >&2
          return $E_USAGE
      fi'

    # TODO: maybe use getopts for option parsing?
    local mkgui_action='eval'
    local mkgui_program_wrapper=command
    while test $# -gt 0;  do
        case "$1" in
            --)
                shift
                break
                ;;
            -p)
                mkgui_action='xecho'
                ;;
            -h)
                eval "$mkgui_check_arg"
                mkgui_added_head_code="$mkgui_added_head_code$'\n'$2"
                shift
                ;;
            -t)
                eval "$mkgui_check_arg"
                mkgui_added_tail_code="$mkgui_added_tail_code$'\n'$2"
                shift
                ;;
            -w)
                eval "$mkgui_check_arg"
                mkgui_program_wrapper="$2"
                shift
                ;;
            -*)
                fwarn "'$1': invalid option" >&2
                return $E_USAGE
                ;;
            *)
                break
                ;;
        esac
        shift
    done

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
                  "due to an unkown error"
            mkgui_exitval=$FAILURE
            continue
        }

    done

    return $mkgui_exitval
}

MakeGUI \
    konqueror firefox xterm kghostview xman kdvi khelpcenter kate \
    kdcop kview quanta openoffice oobase oodraw oofromtemplate \
    oomath ooweb oocalc ooffice ooimpress oowriter kpdf gimp kopete \
    dolphin systemsettings gitk qgit hgview easytag kchmviewer \
    gnomebaker


if W firefox3; then
    MakeGUI firefox3
    W firefox || firefox() { firefox3 "$@"; }
fi

if IsHost bigio; then
    MakeGUI \
       iceweasel insight smalltalk gftp kdevelop bluej appletviewer \
       icedove kmix cssed netbeans civ freeciv heretic alsaplayer ggr
    MakeGUI -h 'set -- media://dev/dvd "$@"' "kscd"
    MakeGUI -w aoss clanbomber bomberclone
fi

MakeGUI -h '[ $# -eq 0 ] && set -- --profile stefano;' konqueror

case $hostname in
   bplab) mkgui_geometry='1280x940';;
   bigio) mkgui_geometry='1152x840';;
esac

chc='{ set -- -geometry "$mkgui_geometry" "$@"; }'

MakeGUI -h "$chc" -- xpdf zxpdf gv ddd emacs djview
MakeGUI -h "$chc; set -- -s 4 \"\$@\"" -- xdvi zxdvi
IsHost bigio && MakeGUI -h "$chc" snake4

# A dirty hack for kile(1).
MakeGUI -h '
    case $# in
        0)
            if (shopt -s failglob && : *.kilepr) >/dev/null 2>&1; then
                set -- *.kilepr
                if (($# > 1)); then
                    fwarn "Too many project files: $*"
                    return $FAILURE
                fi
            fi
            ;;
        *)
            [[ "$*" == "-" ]] && set --
    esac
' kile

return $SUCCESS

#--------------------------------------------------------------------------

# vim: ft=sh ts=4 sw=4 et
