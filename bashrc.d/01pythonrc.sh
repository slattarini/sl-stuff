# -*- bash -*-

# Set PYTHONPATH variable (for search of python modules).
PYTHONPATH=""
add_to_path -B -p 'PYTHONPATH'              \
    /usr/lib/python /usr/local/lib/python   \
    /opt/lib/python "$HOME/lib/python"      \
      2>/dev/null
[ -n "$PYTHONPATH" ] && export PYTHONPATH || unset PYTHONPATH

# Set file executed at startup by interactive pyhon interpreter.
[ -f "$HOME/.pythonrc" ] && export PYTHONSTARTUP="$HOME/.pythonrc"

extend_pythonpath_for_test() {
    local extended_pythonpath
    if [ $# -eq 0 ]; then
        extended_pythonpath=$(pwd)/build/lib:$(pwd)/tests
    else
        local oIFS=$IFS
        local IFS=:
        extended_pythonpath="$*"
        IFS=$oIFS
    fi
    case "${PYTHONPATH-}" in
        "$extended_pythonpath"|"$extended_pythonpath":*)
            # do nothing
            ;;
        *)
            [[ ${PYTHONPATH+set} == set ]] && oPYTHONPATH=$PYTHONPATH
            xPYTHONPATH=${extended_pythonpath}${PYTHONPATH+":$PYTHONPATH"}
            export PYTHONPATH=$xPYTHONPATH
            ;;
    esac
}

reset_pythonpath_for_test() {
    if [[ ${oPYTHONPATH+set} == set ]]; then
        export PYTHONPATH=$oPYTHONPATH
        unset xPYTHONPATH oPYTHONPATH
    fi
}

# vim: ft=sh ts=4 sw=4 et
