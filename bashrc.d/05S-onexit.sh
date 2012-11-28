# -*- bash -*-
# C-like atexit: allow definition of actions to be performed when the
# shell exits.

declare -a EXEC_ON_EXIT_ACTIONS=(":")

exit_trap() {
    # No need to bother with local variables here; we will soon exit.
    exit_status=$?
    unset PS1 PS2 PS3 PS4 PROMPT_COMMAND
    trap - EXIT
    # Execute planned cleanup actions in the proper order.
    for exit_action in "${EXEC_ON_EXIT_ACTIONS[@]}"; do
        eval "$exit_action" || exit_status=$FAILURE
    done
    # Really clear screen, so that even page-up commands cannot show
    # it anymore.
    if [[ 1 -eq $SHLVL && -z ${DISPLAY-} && -z ${SSH_CONNECTION-} ]]; then
        for ((i = 0; i < 5000; i++)); do
            echo
        done
        # Reset terminal defaults.
        tput reset || exit_status=$FAILURE
    fi
    # Clear history file.
    : > "${HISTFILE-"$HOME/.bash_history"}" || exit_status=$FAILURE
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
