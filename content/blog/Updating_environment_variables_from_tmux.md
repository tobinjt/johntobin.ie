+++
date = 2015-06-15T19:11:02+01:00
title = 'Updating environment variables from tmux'
tags = ['tmux', 'shell']
+++

Note: this was originally a lot longer and more complex, but a later version of
`tmux show-environment` supports formatting the output as shell commands to
eval, so this is much easier now.

[tmux](https://github.com/tmux/tmux) is a tty multiplexer similar to
[screen](https://www.gnu.org/software/screen/), but with some really nice
features.  One of those features is updating environment variables when you
reconnect to a session - the client sends the current values to the tmux server,
and they can be retrieved with:

```shell
$ tmux show-environment -s
unset DISPLAY
SSH_AGENT_PID=3912; export SSH_AGENT_PID
unset SSH_ASKPASS
SSH_AUTH_SOCK=/tmp/ssh-lXpzMY3205/agent.3205; export SSH_AUTH_SOCK
SSH_CONNECTION=192.0.2.1 43512 192.0.2.1 22; export SSH_CONNECTION
unset WINDOWID
unset XAUTHORITY
```

Of course, tmux can't force other processes to update their environment.  `bash`
has a hook you can use to do it: `PROMPT_COMMAND`.  If this variable is set to
the name of a function, `bash` will run that function before displaying your
prompt.  Here's a function and supporting settings to update your environment:

```shell
function prompt_command() {
    if [ -n "${TMUX}" ]; then
        eval "$(tmux show-environment -s)"
    fi
}
PROMPT_COMMAND=prompt_command
```
