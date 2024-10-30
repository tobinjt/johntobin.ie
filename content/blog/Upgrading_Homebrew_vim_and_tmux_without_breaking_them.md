+++
date = 2022-05-01T23:23:31+01:00
lastmod = 2022-05-01T23:23:31+01:00
title = "Upgrading homebrew vim and tmux without breaking them"
tags = ['homebrew', 'MacOS', 'shell', 'tmux', 'vim']
+++

By default, when [Homebrew](https://brew.sh) upgrades a package, it removes the
older version. This is generally the right thing to do, but it will badly affect
some running programs, e.g. `tmux` and `vim`, because the binary no longer
exists. `tmux` cannot create a new window, and `vim` cannot run any external
programs. The error message from `vim` is very confusing and it took me a lot of
debugging to figure out the problem: it says `E282: Cannot read from ....` where
`....` is a temp file. I reported this for vim:
<https://github.com/vim/vim/issues/10331>

Mitigating this problem is straightforward: stop Homebrew cleaning up `tmux` and
`vim`. You do this by setting the environment variable
`HOMEBREW_NO_CLEANUP_FORMULAE` to a comma-separated list of packages not to
clean up, e.g. `export HOMEBREW_NO_CLEANUP_FORMULAE=tmux,vim`. You will want to
manually clean up old binaries occasionally with `brew cleanup tmux vim`.
