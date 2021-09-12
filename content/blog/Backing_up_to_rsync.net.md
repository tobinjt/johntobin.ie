+++
lastmod = 2019-05-16T21:42:09+01:00
title = "Backing up to rsync.net"
tags = ['automation', 'backups', 'shell', 'SRE', 'sysadmin']
+++

I use [rsync.net](https://www.rsync.net/) for offsite backups with history
(extended to 21 days of snapshots). The simple way to use it would be to have a
single ssh key without a passphrase that all machines backing up use, and run
rsync once for each directory being backed up. I didn't take that approach
because that single ssh key would give access to all our backups if one of our
laptops was stolen; instead I figured out my requirements and wrote tooling
wrapping rsync.

## Requirements

I had several requirements:

1.  Use a different ssh key for every (machine, directory) pair being backed up.
    Ssh keys must allow making backups but not allow retrieving files, so that
    an attacker obtaining the ssh key could delete/overwrite a backup but not
    steal data. Daily snapshots on rsync.net mean that an attacker can't cause
    significant data loss - at most up to one day of new data will be lost.
1.  Run hourly from cron. Flaky networks, files being changed while the backup
    is ongoing, and laptops going asleep will all cause failures - I need to
    suppress common error messages or I'll be flooded with warning mails like
    `rsync warning: some files vanished before they could be transferred`.
    Notifications like that are just noise, and train the recipient (me) to
    ignore them, so sooner or later I would ignore a useful notification.
1.  Tracking the time of the last successful backup for each machine so I can
    detect if backups are consistently failing anywhere. Reporting stale backups
    needs to be configurable on a per-machine basis: there's no point in
    alerting every day for a laptop that's asleep at home while we're
    travelling, or for a work laptop that won't be backing up over the weekend.
1.  Easy setup because I have N\*M (machine, directory) pairs to setup.
1.  Per-directory exclusions because there will be files that don't need to be
    backed up.

## Implementation of backups

Most requirements are implemented in the
[backup-to-rsync-net-lib](https://github.com/tobinjt/bin/blob/master/backup-to-rsync-net-lib)
library, which is used by
[backup-single-directory-to-rsync-net](https://github.com/tobinjt/bin/blob/master/backup-single-directory-to-rsync-net)
to backup a single directory, and that in turn is called once per directory to
be backed by per-machine backup programs like
[backup-johntobin-laptop-to-rsync-net](https://github.com/tobinjt/bin/blob/master/backup-johntobin-laptop-to-rsync-net).
When run interactively they output progress information, but when run
non-interactively they are silent unless an interesting error occurs, so they
can be run from `cron`.

- All the code references `rsync-net` rather than `rsync.net`, so the actual
  hostname is specified in `~/.ssh/config` along with any other configuration.
- It uses per-source ssh keys, based on supplied hostname and destination
  directory - these are hard-coded in the per-machine backup programs. The
  hostnames are hard-coded because I don't want them to change as laptops move
  across networks. The backup will be placed in
  `hostname/destination-directory/` on rsync.net; there is no protection against
  hostname clashes between source machines or clashes between destination
  directories for a single source machine.
- To make setup easier, the `--make-keys-only` flag skips backing up and creates
  any missing keys using `ssh-keygen` and prints the necessary lines for
  `authorized_keys` on rsync.net; example output is shown below (note that it's
  wrapped here so you can easily read it).

  ```
  Missing SSH key :( SourceDirectory
  command="rsync --server -vlogDtpre.iLsfxC \
    --delete --partial-dir=.rsync-partial \
    . johntobin-laptop/DestinationDirectory",\
    no-pty,no-agent-forwarding,no-port-forwarding PUB_KEY
  ```

  The exception to this is the key for updating the sentinel files tracking
  successful backups (described [below](#tracking-successful-backups)) is not
  created because it's shared across all machines, so it needs to be copied into
  place manually.

- The command specified in `authorized_keys` on rsync.net sets rsync up to
  receive files rather than send files, so attackers can't retrieve files using
  the ssh key. It also specifies the destination directory and all the other
  arguments necessary. The downside is that changing the arguments for rsync
  requires changes in both the code and `authorized_keys` files, which is
  awkward.
- Filtering error messages is accomplished by piping rsync's stderr to grep with
  a long list of patterns to exclude; for details search for `Suppress certain error messages` in
  [backup-johntobin-laptop-to-rsync-net](https://github.com/tobinjt/bin/blob/master/backup-johntobin-laptop-to-rsync-net).
- rsync supports filters for excluding or including files, and the library uses
  it twice:

  - `--filter=dir-merge,- .gitignore`: ignore the same files git does.
  - `--filter=dir-merge rsync-net_filters`: read filter specifications from
    files named `rsync-net_filters` if any are found. Example filter contents:

    ```
    # Exclude files that can be regenerated.
    exclude *Previews.lrdata
    # Exclude files broken by Mojave full disk access.
    exclude Photos Library.photoslibrary
    ```

## Implementation of reporting

- <a name="tracking-successful-backups"></a> Tracking successful backups is
  accomplished by using
  [backup-update-rsync-net-sentinel](https://github.com/tobinjt/bin/blob/master/backup-update-rsync-net-sentinel)
  to save the current timestamp in a sentinel file in a specific directory on
  rsync.net; it's run by the per-machine backup programs if all directories were
  successfully backed up. There is support for setting the maximum acceptable
  delay between backups on a per-machine basis with
  [backup-set-max-delay](https://github.com/tobinjt/bin/blob/master/backup-set-max-delay),
  and for marking a machine as asleep (e.g. because a machine is at home while
  we're travelling) using
  [backup-set-sleeping-until](https://github.com/tobinjt/bin/blob/master/backup-set-sleeping-until),
  which both use the same code for copying a file to rsync.net as
  `backup-update-rsync-net-sentinel` and put the requisite files in the same
  directory. The files contain seconds since the epoch as a text string, e.g.
  `1553385602`.
- Reporting on machines that haven't successfully backed up for too long is
  handled by
  [backup-check-sentinels-on-rsync-net](https://github.com/tobinjt/bin/blob/master/backup-check-sentinels-on-rsync-net),
  which grabs all the sentinel files from rsync.net using the same code that
  uploads the files, and then runs
  [check_backup_sentinels](https://github.com/tobinjt/bin/blob/master/python/check_backup_sentinels.py)
  which handles all the heavy lifting. When run interactively it dumps all the
  information it has to make debugging easier; otherwise it only outputs
  warnings about out-of-date backups. `backup-check-sentinels-on-rsync-net` runs
  from cron on two different machines every night. The output is fairly simple,
  e.g. (wrapped for easier reading):

  ```
  Backup for "johntobin-laptop" too old:
    current time 1553385602/2019-03-24 00:00;
    last backup 1552953713/2019-03-19 00:01;
    max allowed delay: 172800/1970-01-03 00:00;
    sleeping until: 1541204831/2018-11-03 00:27
  ```

  The same ssh key is used for all sentinel uploads regardless of source machine
  or type, because a fixed hostname of `update` is used and the destination
  directory is the same. However a different ssh key must be used for sentinel
  downloads, because `authorized_keys` specifies the command to run including
  whether files are being uploaded or downloaded. This is difficult because in
  the code I wrote the ssh key filename is based on the hostname and destination
  directory, so I need to change either the hostname or directory when
  downloading. To do this I use a symlink on rsync.net: `update` is the
  directory sentinels are uploaded to; `retrieve` is a symlink pointing to
  `update` and is where sentinels are downloaded from. The code generates a
  different key filename, and the corresponding line in `authorized_keys` is set
  up for files to be retrieved rather than pushed.

## Setting up a new machine

- On MacOS you need to install some necessary tools: `brew install coreutils lockrun rsync`.
  - `coreutils` provides `gtimeout`, so that stuck backups will be killed
    eventually.
  - `lockrun` ensures that only one backup runs at a time.
  - I use `rsync` features that aren't supported by the version shipped by
    Apple.
- Add a config stanza to `~/.ssh/config` for rsync-net like:

```sshconfig
Host rsync-net
    HostName HOSTNAME.rsync.net
    User USERNAME
    ForwardAgent no
    ForwardX11 no
    ControlMaster no
    ControlPath none
```

- `mkdir -p ~/tmp/locks ~/.ssh/rsync-net`
- Copy the ssh key for updating sentinels (`~/.ssh/rsync-net/update_sentinel`)
  from another machine.
- `cp backup-johntobin-laptop-to-rsync-net backup-NEW-MACHINE-to-rsync-net`,
  edit the new file changing the hostname and the directories to backup.
- `./backup-NEW-MACHINE-to-rsync-net --make-keys-only`, copy the lines it
  outputs to `authorized_keys` on rsync.net.
- `./backup-NEW-MACHINE-to-rsync-net`; it will fail because the destination
  directory on rsync.net doesn't exist, so create the directory manually: `ssh rsync-net mkdir -p DIRECTORY`
- `./backup-NEW-MACHINE-to-rsync-net`; it should work this time.
- Run from cron hourly (wrapped for easier reading):
  - MacOS:
    ```
    @hourly /usr/local/bin/lockrun --quiet \
      --lockfile="${HOME}/tmp/locks/rsync-net" -- \
        /usr/local/bin/gtimeout --kill-after=60 6h \
          "${HOME}/bin/backup-NEW-MACHINE-to-rsync-net"`
    ```
  - Linux:
    ```
    @hourly flock "${HOME}/tmp/locks/rsync-net" \
      timeout 6h \
        "${HOME}/bin/backup-NEW-MACHINE-to-rsync-net"
    ```
