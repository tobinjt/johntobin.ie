+++
lastmod = 2019-12-10T21:46:45Z
title = "Version-controlled crontab"
tags = ['sysadmin', 'Git', 'MacOS']
+++

For many years I've used [Version-controlled
/etc](/blog/version-controlled_slash-etc/) on Linux to track changes. On MacOS
there isn't a location in `/etc` to put a `crontab`, and my user `crontab` is in
`/var/at/tabs/`, so how can I keep it version-controlled?

I solved this problem by writing a wrapper program:
[crontab-edit](https://github.com/tobinjt/bin/blob/master/crontab-edit).

When run without arguments it sets `$EDITOR` so that `crontab -e` runs
`crontab-edit TEMPORARY_FILE`. When run with an argument it:

- changes directory to a git repository
- checks that there aren't any uncommitted changes
- pulls and pushes to ensure the repository is up to date
- runs `vimdiff CHECKED_IN_FILE TEMPORARY_FILE` so you can make the edits in
  both files (or recover existing edits)
- commits the changes
- pulls and pushes so your changes are upstream

There's a little more complexity around checking whether there are any changes
to commit, following symlinks, and creating files if necessary, but overall it's
relatively straightforward.
