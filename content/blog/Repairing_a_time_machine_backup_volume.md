+++
lastmod = 2018-11-08T22:05:25Z
title = "Repairing a time machine backup volume"
tags = ['automation', 'backups', 'MacOS', 'sysadmin']
+++

I use Apple's [Time Machine](https://support.apple.com/en-ie/104984) to make
local backups of our home computers. It works really well with a locally
attached disk, but it fails often when backing up over the network, e.g. because
the network is slightly flaky, the machine backing up goes asleep, or something
else. After a backup fails Time Machine will try to validate the backup volume,
but there's a high chance that it is corrupt, and when that happens Time Machine
will offer two crappy choices: ![Time Machine crappy
choices](/images/time-machine-error.png)

Either I lose my history by starting a new backup, or I stop taking backups.
Sad face :( Happily there's a third option: repair the corrupted volume. There
are many articles on the internet about doing this manually, but I'm not going
to keep cutting and pasting commands so I wrote a shell script:
[repair-time-machine-volume](https://github.com/tobinjt/bin/blob/6d01e87c90d558feed9771087bdc404a198961df/repair-time-machine-volume).

Actions it takes:

- Make the volume writable using `chflags`.
- Make the volume available as a local device using `hdiutil`.
- Run `fsck` on the newly available device up to five times: even when `fsck`
  fails it will frequently have incrementally improved the filesystem, and
  enough `fsck` runs will fix it.
- Disconnect the volume.
- Update Time Machine metadata so that Time Machine will no longer see it as
  corrupt.

If a backup has recently failed the volume will probably still be locked by the
machine that was backing up, which prevents making it available as a local
device; when this happens the only recourse I have found is to disable Time
Machine on the client machine and wait.

The next time that Time Machine runs it will verify the backup volume again, and
so far the repair process has been successful every time. Backups fail and
volumes are corrupted so often that I run `repair-time-machine-volume` nightly
around 4:00 from `cron` because it's extremely unlikely that any laptops will be
in use and making backups at that time.

The process above repairs the filesystem metadata, but does not repair or check
Time Machine metadata or data. The filesystem may be intact, but that doesn't
mean that there is a coherent or usable Time Machine volume that you can restore
from. Time Machine does verify the volume on the next backup, but I don't fully
trust it. Because of this I don't rely on Time Machine backups alone; however
they are effectively free when at home so I keep them enabled to give me the
option of trying to restore from them.
