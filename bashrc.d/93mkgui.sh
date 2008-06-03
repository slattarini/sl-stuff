# -*- bash -*-

#
# Costruzione di funzioni-alias per lanciare comandi GUI da una
# shell (in X)
#

IsHost bigio || IsHost bplab || return $SUCCESS

#--------------------------------------------------------------------------

# helper subroutine
_mkgui_process_added_code() {
    case $# in (0) cat;; (*) xecho "$*";; esac | \
    sed -e "s|@FUNC@|$mkgui_funcname|g" \
        -e "s|@PROG@|$mkgui_safe_program_path|g" |  \
    sed -e "s|%___dot___%|.|g"
}

declare -rf _mkgui_process_added_code

# big ugly function
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

    # TODO: use getopts for option parsing
    local mkgui_action='eval'
    local mkgui_program_wrapper=''
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

        [ -z "$mkgui_program" ] && continue #  ignore empty args

        # does program exist, and is it executable?
        local mkgui_program_path=$(which "$mkgui_program")
        if [ -z "$mkgui_program_path" ]; then
            fwarn "\`$mkgui_program': program not found"
            mkgui_exitval=${mkgui_E_FAIL}
            continue
        fi

        local mkgui_funcname
        mkgui_funcname=${mkgui_program##*/}
        mkgui_funcname=${mkgui_funcname%%.*}

        # mkgui_funcname is a valid function identifier?
        case "$mkgui_funcname" in
          ([a-zA-Z_]*([a-zA-Z0-9_])) ;;
          (*)
            fwarn "\`$mkgui_funcname' is not a valid function identifier"
            mkgui_exitval=${mkgui_E_FAIL}
            continue
            ;;
        esac

        local mkgui_safe_program_path=$(xecho "$mkgui_program_path" | \
                                        sed -e 's|\.|%___dot___%|g')

        if [ -n "$mkgui_added_head_code" ]; then
            mkgui_added_head_code=$(
                _mkgui_process_added_code "$mkgui_added_head_code")
        fi

        if [ -n "$mkgui_added_tail_code" ]; then
            mkgui_added_tail_code=$(
                _mkgui_process_added_code "$mkgui_added_tail_code")
        fi

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
                  $mkgui_program_wrapper $mkgui_program_path \"\$@\" \\
                    >&98 2>&99
                else
                  $mkgui_program_wrapper $mkgui_program_path \"\$@\" \\
                    >&98 2>&99 &
                fi
                exec 98>&-
                exec 99>&-
            )"
        else
            local mkgui_main_code="{
                case \"\${XFUNC_VERBOSE-}\" in
                  ($mkgui_as_true)
                    $mkgui_program_wrapper $mkgui_program_path \"\$@\" &
                    ;;
                  ($mkgui_as_false)
                    $mkgui_program_wrapper $mkgui_program_path \"\$@\" \\
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
    konqueror mozilla firefox xterm ksysguard kghostview xman kdesvn kdvi \
    khelpcenter kedit kwrite kate kdcop kview quanta idle gedit pidgin \
    gaim openoffice oobase oodraw oofromtemplate oomath ooweb oocalc \
    ooffice ooimpress ooo-wrapper oowriter kprof kpdf display open_url \
    xfig gimp akregator kopete dolphin systemsettings gitk qgit hgview \
    easytag


if W firefox3; then
    MakeGUI firefox3
    W firefox || firefox() { firefox3 "$@"; }
fi

# kompare subroutine *must* not to go in background is standard input is
# not a tty
MakeGUI -T kompare

if IsHost bigio; then
    MakeGUI                                                         \
       iceweasel insight smalltalk xabiword gftp k3b kdevelop bluej \
       appletviewer galeon kmail kaddressbook kmix cssed netbeans   \
       bittorrent civ freeciv paman heretic alsaplayer bmpx ggr     \
       VirtualBox
    MakeGUI -h 'set -- media://dev/dvd "$@"' "kscd"
    MakeGUI -w aoss clanbomber bomberclone
fi

MakeGUI -h '[ $# -eq 0 ] && set -- --profile stefano;' konqueror

case $hostname in
   bplab) mkgui_geometry='1280x940';;
   bigio) mkgui_geometry='1152x840';;
esac

chc='{ set -- -geometry "$mkgui_geometry" "$@"; }'

MakeGUI -h "$chc; set -- -nomail \"\$@\"" -- opera
MakeGUI -h "$chc" -- xpdf zxpdf gv ddd {x,}emacs djview
MakeGUI -h "$chc; set -- -s 4 \"\$@\"" -- xdvi zxdvi
IsHost bigio && MakeGUI -h "$chc" snake4

# dirty hack
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
