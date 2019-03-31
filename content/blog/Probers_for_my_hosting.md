+++
date = 2019-03-31T22:44:12Z
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
*   Check that a magic string is present in the response from
    https://www.arianetobin.ie/ to detect failures:
    [probe-arianetobin.ie](https://github.com/tobinjt/bin/blob/master/probe-arianetobin.ie).
*   Check that `A`, `AAAA`, and `MX` records are correct for every domain:
    [check-dns-for-hosting](https://github.com/tobinjt/bin/blob/master/check-dns-for-hosting).
*   Check that HTTP requests are redirected to HTTPS, that requests for `DOMAIN`
    are redirected to `www.DOMAIN`, and that requests for dormant domains are
    redirected to the correct domain:
    [check-redirects-for-hosting](https://github.com/tobinjt/bin/blob/master/check-redirects-for-hosting).
