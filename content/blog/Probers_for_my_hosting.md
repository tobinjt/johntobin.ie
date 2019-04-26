+++
date = 2019-04-27T18:44:12Z
title = "Probers for my hosting"
tags = ['automation', 'shell', 'SRE', 'sysadmin', 'website']
+++

I have a VM from [Hetzner](https://www.hetzner.de/) for [my wife's
website](https://www.arianetobin.ie/) and my own.  I run several probers hourly
from `cron` on the VM and on a machine in my house (so they aren't singly homed)
to ensure that the VM, DNS, Apache, and websites are working properly:

*   The [simple link checker](/blog/simple_link_checking/) I wrote checks my
    wife's website, the development version of my wife's website, and my
    website.  Checking the development version of my wife's website gives me an
    early notification when I've broken something during development rather than
    finding out after deploying to production.
*   I run a second prober to check links on my wife's website and my website.
    [linkchecker-cron](https://github.com/tobinjt/bin/blob/master/linkchecker-cron)
    wraps [linkchecker](https://wummel.github.io/linkchecker/), runs it with the
    right set of flags, and is silent unless something goes wrong.  Like the
    previous prober when run interactively or when something goes wrong it
    leaves the temporary directory and output around for easier debugging,
    otherwise it cleans up after itself.

    This prober is only run on my hosting because 1) it's not easily available
    for MacOS X and 2) the checks aren't essential.  This prober can be noisy
    because problems with external sites cause false positives, e.g.  I've had
    to exclude `www.amazon.co.uk` because requests to it fail so frequently.

    The reason to run this in addition to the previous checker is that this tool
    supports checking external links without recursing through the external
    sites, which the previous tool doesn't.  The reason to run the previous tool
    is that it reports any HTTP result that isn't `200 OK`, making it easy to
    find unnecessary redirects (`301`, `302`) that I can change to remove the
    redirect.
*   Check that a magic string is present in the response from
    https://www.arianetobin.ie/ to detect failures:
    [probe-arianetobin.ie](https://github.com/tobinjt/bin/blob/master/probe-arianetobin.ie).
*   Check that `A`, `AAAA`, and `MX` records are correct for every domain:
    [check-dns-for-hosting](https://github.com/tobinjt/bin/blob/master/check-dns-for-hosting).
*   Check that HTTP requests are redirected to HTTPS, that requests for `DOMAIN`
    are redirected to `www.DOMAIN`, and that requests for dormant domains are
    redirected to the correct domain:
    [check-redirects-for-hosting](https://github.com/tobinjt/bin/blob/master/check-redirects-for-hosting).
