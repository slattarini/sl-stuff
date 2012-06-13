# -*- bash -*-

#
# Build "alias functions" to launch GUI commands from a shell (in an
# X-Terminal).
#

IsHost bigio || IsHost bplab || return $SUCCESS

#--------------------------------------------------------------------------

# An helper subroutine.
_mkgui_process_added_code_in_var() {
    [[ -n "${!1}" ]] || return 0
    eval $1=\${$1//@FUNC@/\$mkgui_funcname}
    eval $1=\${$1//@PROG@/\$mkgui_program}
}

declare -rf _mkgui_process_added_code_in_var

# The big, ugly, do-it-all function.
MakeGUI() {

    local mkgui_E_OK=$SUCCESS
    local mkgui_E_FAIL=$FAILURE
    local mkgui_E_NOGUI=15
    local mkgui_added_head_code=''
    local mkgui_added_tail_code=''
    local mkgui_exitval=${mkgui_E_OK}

    local mkgui_check_arg='
      if test $# -lt 2; then
          fwarn "option \`$1'\'' require an argument" >&2
          return $E_USAGE
      fi'

    # TODO: maybe use getopts for option parsing?
    local mkgui_action='eval'
    local mkgui_program_wrapper=command
    declare -i mkgui_subify=$FALSE
    declare -i mkgui_bg_from_terminal_only=$FALSE
    while test $# -gt 0;  do
        case "$1" in
            --)
                shift
                break
                ;;
            -S)
                mkgui_subify=$TRUE
                ;;
            -p)
                mkgui_action='xecho'
                ;;
            -T)
                mkgui_bg_from_terminal_only=$TRUE
                ;;
            -h)
                eval "$mkgui_check_arg"
                mkgui_added_head_code="$mkgui_added_head_code$NL$2"
                shift
                ;;
            -t)
                eval "$mkgui_check_arg"
                mkgui_added_tail_code="$mkgui_added_tail_code$NL$2"
                shift
                ;;
            -w)
                eval "$mkgui_check_arg"
                mkgui_program_wrapper="$2"
                shift
                ;;
            -*)
                fwarn "\`$1': unknwon option" >&2
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
            fwarn "\`$mkgui_program': program not found"
            mkgui_exitval=${mkgui_E_FAIL}
            continue
        fi

        local mkgui_funcname
        mkgui_funcname=${mkgui_program##*/}
        mkgui_funcname=${mkgui_funcname%%.*}

        # Is `$mkgui_funcname 'a valid function identifier?
        case "$mkgui_funcname" in
          ([a-zA-Z_]*([a-zA-Z0-9_])) ;;
          (*)
            fwarn "\`$mkgui_funcname' is not a valid function identifier"
            mkgui_exitval=${mkgui_E_FAIL}
            continue
            ;;
        esac

        _mkgui_process_added_code_in_var 'mkgui_added_head_code'
        _mkgui_process_added_code_in_var 'mkgui_added_tail_code'

        if (($mkgui_subify)); then
            local mkgui_par_open='('
            local mkgui_par_close=')'
            local mkgui_return='exit'
        else
            local mkgui_par_open=''
            local mkgui_par_close=''
            local mkgui_return='return'
        fi
        local mkgui_as_true='1|+([yY])|[yY][eE][sS]|[tT]rue'
        local mkgui_as_false='*'
        if ((mkgui_bg_from_terminal_only)); then
            local mkgui_main_code="(
                case \"\${XFUNC_VERBOSE-}\" in
                    ($mkgui_as_true) exec 98>&1 99>&2;;
                    ($mkgui_as_false) exec 98>/dev/null 99>/dev/null;;
                esac
                if test -t 1; then
                  $mkgui_program_wrapper $mkgui_program \"\$@\" \\
                    >&98 2>&99
                else
                  $mkgui_program_wrapper $mkgui_program \"\$@\" \\
                    >&98 2>&99 &
                fi
                exec 98>&-
                exec 99>&-
            )"
        else
            local mkgui_main_code="{
                case \"\${XFUNC_VERBOSE-}\" in
                  ($mkgui_as_true)
                    $mkgui_program_wrapper $mkgui_program \"\$@\" &
                    ;;
                  ($mkgui_as_false)
                    $mkgui_program_wrapper $mkgui_program \"\$@\" \\
                      >/dev/null 2>&1 &
                esac
            }"
        fi

        $mkgui_action "
            $mkgui_funcname() {
              ${mkgui_par_open}
                if [ -z \"\${DISPLAY-}\" ]; then
                    fwarn '\`DISPLAY'\\'' variable not set, cannot' \\
                          'connect to screen. Is X server running?'
                    $mkgui_return $mkgui_E_NOGUI
                fi

                $mkgui_added_head_code

                $mkgui_main_code

                $mkgui_added_tail_code

                $mkgui_return $mkgui_E_OK
              ${mkgui_par_close}
            }
        "

        (($? == 0)) || {
            fwarn "$mkgui_funcname can't be declared as function," \
                  "due to an unkown error"
            mkgui_exitval=${mkgui_E_FAIL}
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

# The `kompare' subroutine *must* not to go in background is standard
# input is not a tty.
MakeGUI -T kompare

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
