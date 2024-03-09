+++
lastmod = 2018-10-26T20:36:56+01:00
title = "Backing up a Wordpress database"
tags = ['backups', 'MySQL', 'sysadmin', 'Wordpress']
+++

My wife's [website](https://www.arianetobin.ie/) is built on
[Wordpress](https://wordpress.org/). Wordpress uses a
[MySQL](https://www.mysql.com) (or [MariaDB](https://mariadb.org/)) database to
store pages, posts, comments, sessions, and everything else except media. That
database needs to be backed up regularly in case of data loss. Backing up a
MySQL database is easy - just run
[mysqldump](https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html) - so why
would I need anything else? I wrote
[backup-wordpress](https://github.com/tobinjt/bin/blob/master/backup-wordpress)
to wrap some extra functionality around `mysqldump`:

- Extract the username, password, and database name from the Wordpress
  `wp-config.php` and pass them as arguments to `mysqldump`, so you can just run
  `backup-wordpress /path/to/wordpress-base`, e.g. in `cron(8)`.
- Run [mysqlcheck](https://dev.mysql.com/doc/refman/8.0/en/mysqlcheck.html) to
  repair and optimise the database.
- Run `mysqldump` with the right arguments and compress the output.
- Run [tmpreaper](https://packages.debian.org/stable/tmpreaper) to delete old
  backups. `tmpreaper` is run under
  [flock](https://www.linux.org/docs/man1/flock.html) so that parallel
  invocations of `backup-wordpress` won't result in parallel invocations of
  `tmpreaper`. When two `tmpreaper` instances run in parallel, it's possible
  that both will call `readdir(3)`, one will `stat(2)` then `unlink(2)` a file,
  and the second will then fail to `stat(2)` that file, resulting in error
  messages.

I run this for both the dev and production instances of my wife's website every
hour from `cron(8)`.
