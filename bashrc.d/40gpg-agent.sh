# -*- bash -*-

if ! IsHost bigio; then
    # gpg-agent machinery is not to be run
    return $SUCCESS
elif [[ ${GPG_AGENT_INFO+set} == set ]]; then
    # gpg-agent machinery has been already started
    mwarn "Not starting gpg-agent machinery: it is already active"
    mwarn "GPG_AGENT_INFO=$GPG_AGENT_INFO"
    return $SUCCESS
fi

kill_gpg_agent() {
    [ -z "${GPG_AGENT_PID-}" ] || kill $GPG_AGENT_PID
}
declare -rf kill_gpg_agent

eval "$(gpg-agent --daemon --sh)" \
  && GPG_AGENT_PID=${GPG_AGENT_INFO%:*} \
  && GPG_AGENT_PID=${GPG_AGENT_PID%:*} \
  && export GPG_AGENT_PID GPG_AGENT_INFO \
  && ExecOnExit 'kill_gpg_agent' \
  || { kill_gpg_agent; return $FAILURE; } \
  && export GPG_TTY=$(tty) \
  || { kill_gpg_agent; return $FAILURE; }

# vim: ft=sh ts=4 sw=4 et
