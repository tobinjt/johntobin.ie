+++
date = 2018-11-03T14:07:02+01:00
title = "Restoring dev website from production website"
tags = ['automation', 'backups', 'MySQL', 'sysadmin', 'Wordpress']
draft = true
+++

I wrote and maintain [the theme](https://github.com/tobinjt/ariane-theme) for
[my wife's website](https://www.arianetobin.ie/), and I maintain her website in
general.  I have a development version of the website so that I can develop the
theme and test plugins without breaking the production site.  For several years
I had only a small number of pages in the development website, each testing some
combination of features, but they weren't properly representative of the pages
on the production website so sometimes bugs slipped through my testing.  Earlier
this year I got fed up of bugs slipping through so I decided to find a way to
copy the content from the production website to the development website, because
by testing with real content I'm more likely to find the bugs before deploying
to production, however I couldn't find anything out there that does this so I
wrote
[restore-dev-from-www](https://github.com/tobinjt/bin/blob/master/restore-dev-from-www).
The code is generic except for two lines in `main()` and the list of `(table,
column)` pairs to be updated; the latter is harder to make truly generic than
the former, though both should be possible.

Here are the actions taken by the tool:

*   Trigger a backup of the production database using the tool described in
    [Backing up a Wordpress database](/blog/backing_up_a_wordpress_database/) so
    that I have a really recent backup to restore from, because I frequently
    restore after making changes to the production website.

    `backup-wordpress` required a couple of small changes as part of writing
    `restore-dev-from-www`:

    *   Do not use `--databases` flag with `mysqldump` because it adds `use
        $database` and `create database $database` lines to the output;
        `$database` is the database being backed up (the production database),
        but `restore-dev-from-www` needs to restore the backup to a *different*
        database (the development database).
    *   Pass `--skip-extended-insert` to `mysqldump` to make the dump more
        readable by using individual insert statements rather than one giant
        insert statement.  This isn't strictly necessary for
        `restore-dev-from-www`, but it was very helpful when figuring out what
        columns need to change and diffing dumps.  Sadly this appears to make
        restoring from the dump much slower.

*   Restore the dump to the development database.  Like `backup-wordpress`,
    `restore-dev-from-www` extracts authentication info and other configuration
    from the development site's `wp-config.php`.

*   Make necessary changes in the newly restored database: currently that's just
    replacing `www.$domain` with `dev.$domain`.  I figured out what changes are
    required and which tables and columns to change by examining a dump, though
    I could have brute-force applied the necessary changes to every column in
    every table instead.

    I generate the SQL `UPDATE` statements because the updates are simple and
    repetitive, and I'm using [Template
    Toolkit](http://www.template-toolkit.org/) for that rather than trying to
    get all the quoting and expansion right using shell.  Generating an
    intermediate file also makes debugging a bit easier because I can read the
    SQL statements, copy and paste individual statements into `mysql`, and
    editor syntax highlighting will help catch mistakes.
