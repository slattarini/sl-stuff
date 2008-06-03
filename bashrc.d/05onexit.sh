# -*- bash -*-

# Permette di definire ed estendere dinamicamente le azioni da
# intraprendere all'uscita dalla shell.

declare -a EXEC_ON_EXIT_ACTIONS=(":")

_exit_trap() {
    local i _exit_action _exit_status=$?
    trap - EXIT
    PS1=''
    # execute planned cleanup actions
    for _exit_action in "${EXEC_ON_EXIT_ACTIONS[@]}"; do
        eval "${_exit_action}" || _exit_status=$?
    done
    # clear screen
    if [ 1 -eq ${SHLVL} ] && { IsHost bigio || IsHost bplab; }; then
        for ((i = 0; i < 5000; i++)); do
            echo
        done
    fi
    # clear history file
    true > "${HISTFILE:-"$HOME/.bash_history"}" || _exit_status=1
    # Reset terminal defaults.
    tput reset
    exit ${_exit_status}

}
declare -rf _exit_trap

trap _exit_trap EXIT HUP QUIT ABRT PIPE TERM

ExecOnExit() {
    EXEC_ON_EXIT_ACTIONS=("$@" "${EXEC_ON_EXIT_ACTION[@]}")
}
atexit() {
    ExecOnExit "$@"
}
declare -rf ExecOnExit atexit

ClearExitActions() {
    EXEC_ON_EXIT_ACTIONS=(":")
}
declare -rf ClearExitActions

# vim: ft=sh et sw=4 ts=4
