+++
date = 2018-10-27T18:07:02+01:00
title = "Restoring dev from www"
tags = ['automation', 'backups', 'MySQL', 'sysadmin', 'Wordpress']
draft = true
+++

I wrote and maintain [the theme](https://github.com/tobinjt/ariane-theme) for
[my wife's website](https://www.arianetobin.ie/), and I maintain her website in
general.  I have a development version of the website so that I can develop
without breaking the production site.  For several years I had only a small
number of pages in the development website, each testing some combination of
features, but they weren't properly representative of the pages on the
production website so sometimes bugs slipped through my testing.  Earlier this
year I got fed up of bugs slipping through so I decided to find a way to copy
the content from the production website to the development website, so that by
testing with real content I'm more likely to find the bugs in testing.  I
couldn't find anything that does this, so I wrote
[restore-dev-from-www](https://github.com/tobinjt/bin/blob/master/restore-dev-from-www)
to do it.

Here are the actions taken by the tool:

*   Trigger a backup using the tool described in [Backing up a Wordpress
    database](/blog/backing_up_a_wordpress_database/) so that I have a really
    recent backup to restore from, because I frequently restore after making
    changes to the production website.

    `backup-wordpress` required a couple of small changes as part of writing
    `restore-dev-from-www`:

    *   Do not use `--databases` flag with `mysqldump` because it adds `use
        $database` and `create database $database` lines to the output, where
        `$database` is the database being backed up, but `restore-dev-from-www`
        needs to restore the backup to a *different* database.
    *   Pass `--skip-extended-insert` to `mysqldump` to make the dump more
        readable by using individual insert statements rather than one giant
        insert statement.  This isn't strictly necessary for
        `restore-dev-from-www`, but it was very helpful when figuring out what
        columns need to change and diffing dumps.  Sadly this appears to make
        restoring from the dump much slower.

*   Restore
