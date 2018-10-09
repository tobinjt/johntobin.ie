+++
date = 2014-11-17T22:18:15+01:00
title = 'Simple link checking'
tags = ['script', 'sysadmin']
+++

I've been working on [my wife's website](http://www.arianetobin.ie/) recently,
and I wanted to check that all the internal links and resources worked properly.
I wasn't going to do this by hand, so I wrote [a simple wrapper around
wget](https://github.com/tobinjt/bin/blob/master/check-links).  It deliberately
downloads everything and saves it to make finding the location of broken links
easier.  Any request that wasn't answered with HTTP status 200 is displayed,
e.g.:

```
--2014-11-17 22:07:14--  http://example.com/bar/
Reusing existing connection to example.com:80.
HTTP request sent, awaiting response... 404 Not Found
--
--2014-11-17 22:07:16--  http://example.com/baz/
Reusing existing connection to example.com:80.
HTTP request sent, awaiting response... 404 Not Found
--
--2014-11-17 22:07:18--  http://example.com/qwerty/
Reusing existing connection to example.com:80.
HTTP request sent, awaiting response... 404 Not Found
See /tmp/check-links-R4ZxQqw1Ak/wget.log and the contents of /tmp/check-links-R4ZxQqw1Ak for further investigation
```

That tells you which links are broken, and with that knowledge you're a simple
`grep -r /qwerty/ /tmp/check-links-R4ZxQqw1Ak` to find the page containing the
broken link.

It's not amazingly advanced, but it has been useful.  I found a couple of 404s,
and a large number of 301s that I could easily fix to avoid one more round trip
for people viewing the site.  I run this every night from `cron` for my website
and my wife's website to detect breakages.
