# -*- bash -*-

# Permette di definire ed estendere dinamicamente le azioni da
# intraprendere all'uscita dalla shell.

declare -a EXEC_ON_EXIT_ACTIONS=(":")

exit_trap() {
    local exit_status=$?
    local i exit_action
    unset PS1 PS2 PS3 PS4 PROMPT_COMMAND
    trap - EXIT
    # Execute planned cleanup actions in the proper order.
    local exit_action
    for exit_action in "${EXEC_ON_EXIT_ACTIONS[@]}"; do
        eval "$exit_action" || exit_status=$FAILURE
    done
    # Really clear screen, so that even page-up commands cannot show
    # it anymore.
    if [ 1 -eq $SHLVL ] && { IsHost bigio || IsHost bplab; }; then
        declare -i i
        for ((i = 0; i < 5000; i++)); do
            echo
        done
    fi
    # Clear history file.
    : > "${HISTFILE-"$HOME/.bash_history"}" || exit_status=$FAILURE
    # Reset terminal defaults.
    tput reset || exit_status=$FAILURE
    exit $exit_status

}
declare -rf exit_trap

trap exit_trap EXIT HUP QUIT ABRT PIPE TERM

atexit() {
    EXEC_ON_EXIT_ACTIONS=("$@" "${EXEC_ON_EXIT_ACTION[@]}")
}
declare -rf atexit

atexit_clear() {
    EXEC_ON_EXIT_ACTIONS=(":")
}
declare -rf atexit_clear

# vim: ft=sh et sw=4 ts=4
