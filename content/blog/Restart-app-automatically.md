+++
date = 2019-04-15T12:33:19+01:00
title = "Restarting an app automatically on MacOS X"
tags = ['automation', 'MacOS', 'shell', 'sysadmin']
+++

There are several apps I run in the background on my laptop that occasionally
crash, e.g. [Google Backup and
Sync](https://www.google.com/drive/download/backup-and-sync/) and
[Pauses](https://itunes.apple.com/ie/app/pauses/id481375590?mt=12).  After
several crashes that I didn't notice for a few days each, I'd had enough and
decided I needed tooling to automatically restart certain apps.  I searched for
existing tools but only found some blog posts about the problem, so I wrote my
own.  The implementation is relatively simple on MacOS X:
[launchd](https://developer.apple.com/library/archive/documentation/MacOSX/Conceptual/BPSystemStartup/Chapters/CreatingLaunchdJobs.html)
exists to run daemons and apps and restart them as necessary, so mostly I just
needed to generate configuration files - but that didn't allow updating apps,
so I needed a wrapper around the apps too.

There are three parts to the implementation:

[restart-app-automatically](https://github.com/tobinjt/bin/blob/master/restart-app-automatically)
: This program generates and manages
[plist](https://en.wikipedia.org/wiki/Property_list) files that configure
`launchd` to start the desired app (via the wrapper below) and restart it when
it exits.  It uses `launchctl` to load the configs, restart apps, remove
configs, and so on.

[restart-app-automatically-wrapper](https://github.com/tobinjt/bin/blob/master/restart-app-automatically-wrapper)
: When upgrading an app the typical process is 1) stop the app, 2) overwrite
files, 3) start the app.  If step 3 happens before or during step 2 the upgrade
may fail, so I can't just have `launchd` restart the app directly because it
will do so *immediately* after the app exits.  `launchd` does have a
`ThrottleInterval` option that looks like it would solve the problem, but that
just enforces a minimum time period between job starts, so if a job has been
running for longer than `ThrottleInterval` seconds (true in the common case) it
will start again immediately.  The wrapper sleeps for 60 seconds after the app
exits to give upgrades a chance, and when the wrapper is executed again by
`launchd` it kills any app processes that were left hanging around when the
previous run finished then runs the app.

Per-app wrapper programs
: They aren't strictly necessary, but for ease of use and consistency I have
a small wrapper program for each app, e.g. for Google Backup and Sync I have
[restart-backup-and-sync-automatically](https://github.com/tobinjt/bin/blob/master/restart-backup-and-sync-automatically).

Mac OS Mojave introduced a small problem: `restart-app-automatically-wrapper`
needs extra permissions, but thankfully a dialog appears making it easy to grant
the permissions:

![Extra permissions
dialog](/images/restart-app-automatically-wrapper_extra-permissions-dialog.png)

It's unclear what happens if you press `Deny` though - will you ever get a
chance to approve it again?
