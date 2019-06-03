+++
date = 2019-06-03T00:31:29+01:00
title = "Checking external links"
tags = ['automation', 'shell', 'SRE', 'sysadmin', 'website']
+++

[Simple link checking](/blog/simple_link_checking/) describes how I check
*internal* links, but what about checking *external* links?  You need to
traverse every page on your website to find the external links to check, but you
definitely must not traverse every page on external sites!  I found a tool that
supports this: [linkchecker](https://wummel.github.io/linkchecker/).  (Note that
development seems to have stopped there and moved to a [new
group](https://github.com/linkchecker/linkchecker), but I've linked to the
version packaged by Debian stable because that's what I'm using.)

The key to checking external links without recursing through external websites
with linkchecker is to pass the flags `--check-extern` and
`--no-follow-url=!://DOMAIN-BEING-CHECKED/` (e.g.
`--no-follow-url=!://www.johntobin.ie/`); this will check external links but
will not recurse on any URL that doesn't match `://DOMAIN-BEING-CHECKED/`.

I ran linkchecker like this for a month or so, but after the initial cleanup
where I fixed some broken links it was too noisy - there are temporary failures
frequently enough that the signal-to-noise ratio was very low.  Some sites
consistently fail, e.g. Wikipedia and Amazon , and consistent failures can
easily be excluded with `--ignore-url=//en.wikipedia.org`, but most failures are
transient.  (Wikipedia and Amazon block the default linkchecker `User-Agent`,
setting the `User-Agent` to match Chrome fixes them.)  linkchecker supports a
simple output format of `failure_count URL` that is updated on each run, but the
counters are never reset and it doesn't track *when* the failures occurred so
the signal-to-noise ratio for alerts from that would decline over time.

I decided to write a wrapper to post-process the results and only warn about
URLs that fail multiple times in a short period.  Happily linkchecker supports
SQL output, so I can import the failures into an
[SQLite](https://www.sqlite.org/index.html) database and easily query it.  The
schema that linkchecker uses is fine except it doesn't have a timestamp, but
that was easy to solve with SQLite: when creating the database I add an extra
column defined as `timestamp DATETIME DEFAULT CURRENT_TIMESTAMP` that will
automatically be populated when records without it are inserted.  I arbitrarily
picked 3 failures in 2 days as the thresholds for warning about a URL, and the
output looks like this:

```
Bad URLs for https://www.johntobin.ie/ since 2019-05-31
3 https://dev.mysql.com/doc/refman/8.0/en/mysqlcheck.html
3 https://dev.mysql.com/doc/refman/8.0/en/mysqldump.html
3 https://www.mysql.com
Output in /tmp/linkchecker-cron.PZ8nr8xjfy
```

To investigate further I can use an SQL query like `SELECT * FROM linksdb WHERE
urlname LIKE '%mysqldump%';`.  The output files are also available for debugging
when linkchecker fails, otherwise they are cleaned up.  Both the output files
and the database contain the referring URL for failures, so it's easy to go edit
the page and fix the link if there is a genuine failure, e.g. several links in
my blog needed to be updated because the destinations had been moved over the
years.

The wrapper program is
[linkchecker-cron](https://github.com/tobinjt/bin/blob/master/linkchecker-cron)
and my
[linkcheckerrc](https://github.com/tobinjt/dotfiles/blob/master/.linkchecker/linkcheckerrc)
might also be useful.
