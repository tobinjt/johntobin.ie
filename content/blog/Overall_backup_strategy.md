+++
date = 2019-05-05T17:29:11+01:00
title = "Overall backup strategy"
tags = ['backups', 'SRE', 'sysadmin']
+++

This blog post describes the overall backup strategy and implementation for my
personal machines.

*   Each machine backs up everything except photos to
    [rsync.net](https://www.rsync.net/), providing offsite backups with history;
    photos are excluded because of their sheer size.  See [backing up to
    rsync.net](/blog/backing_up_to_rsync.net/) for implementation details.
*   Each Mac uses [Google Backup and
    Sync](https://www.google.com/drive/download/backup-and-sync/) to back up all
    data including photos, for offsite backups without history.
*   My iMac uses [Time Machine](https://support.apple.com/en-ie/HT201250) to
    back up to a locally attached hard disk
*   With Mac OS Mojave remote Time Machine backups became so unreliable that I
    gave up on them; below is what I used to do.
    *   Each Mac laptop uses Time Machine to back up through the iMac, giving us
        onsite backups with history.  Backups from laptops fail a lot, and so I
        [repair the backup volumes
        nightly](/blog/repairing_a_time_machine_backup_volume/), but
        occasionally they are corrupted badly enough that they cannot be
        repaired or Time Machine just refuses to back up to them until they have
        been reinitialised (with the resulting loss of history).  I haven't
        needed to restore from them for real, but a test restore has worked in
        the past; I don't have any confidence in these backups, but they're
        almost free so I might as well have them.
*   On my hosting, the databases used for Wordpress are [backed up
    locally](/blog/backing_up_a_wordpress_database/) every hour, and my iMac
    rsyncs those backups down every hour.  The database dumps are included in
    backups to rsync.net from both my iMac and my hosting.
*   Every hour my iMac updates local git clones of my hosting's `/etc`, my
    wife's website, and the development version of my wife's website.  All are
    included in backups to rsync.net from both my iMac and my hosting.
*   Some data is backed up to rsync.net multiple times, which is unnecessary but
    doesn't hurt.  The most important data is backed up to rsync.net, Google
    Drive, and Time Machine - this gives offsite backups with history,
    unreliable onsite backups with history, and (less usefully) offsite backups
    without history.
*   The most vulnerable data is photos: because of their sheer size they aren't
    backed up to rsync.net, they are just in Google Photos and Time Machine, so
    I have offsite backups without history and unreliable onsite backups with
    history.
