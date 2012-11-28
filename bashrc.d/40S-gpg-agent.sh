# -*- bash -*-

# gpg-agent machinery is not to be run be default
[ -f ~/.gpg-agent-is-to-be-run ] || return $SUCCESS

if [[ ${GPG_AGENT_INFO+set} == set ]]; then
    # gpg-agent machinery has been already started
    mwarn "Not starting gpg-agent machinery: it is already active"
    mwarn "GPG_AGENT_INFO=$GPG_AGENT_INFO"
    # This is required, if we open an xterm in an X session already
    # wrapped by gpg-agent.
    export GPG_TTY=$(tty)
    # Nothing more to do.
    return $SUCCESS
fi

kill_gpg_agent()
{
    [ -z "${GPG_AGENT_PID-}" ] || kill $GPG_AGENT_PID
}

eval "$(gpg-agent --daemon --sh)" \
  && GPG_AGENT_PID=${GPG_AGENT_INFO%:*} \
  && GPG_AGENT_PID=${GPG_AGENT_PID%:*} \
  && export GPG_AGENT_PID GPG_AGENT_INFO \
  && atexit 'kill_gpg_agent' \
  || { kill_gpg_agent; return $FAILURE; }

# vim: ft=sh ts=4 sw=4 et
