+++
date = 2018-10-17T20:10:19-04:00
title = "Checking a git client is clean"
tags = ['Git', 'automation', 'programming', 'shell']
+++

I use Git for many things, and I have written several utilities that wrap git
commands (e.g. [pushing changes to the theme for my wife's website from the dev
site to the production
site](https://github.com/tobinjt/bin/blob/master/update-ariane-theme)). A common
requirement is that the local copy is **clean**: no uncommitted changes, and no
unpushed commits. I had been checking for uncommitted changes by testing if
there is any output from `git status`, but in most cases I wasn't checking for
unpushed commits. I decided to remove the duplication and improve the
implementation by writing a git subcommand:
[git-check-local-copy-is-clean](https://github.com/tobinjt/bin/blob/master/git-check-local-copy-is-clean),
invoked as `git check-local-copy-is-clean`. You can optionally ignore unpushed
commits by using `--ignore-unpushed-commits` if you just care about uncommitted
changes.
