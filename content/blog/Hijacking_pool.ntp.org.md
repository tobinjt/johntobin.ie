+++
date = 2009-12-14T17:19:20+00:00
title = 'Hijacking pool.ntp.org'
tags = ['NTP', 'sysadmin']
+++

From <http://pool.ntp.org>:

> The pool.ntp.org project is a big virtual cluster of timeservers providing
> reliable easy to use NTP service for millions of clients.
>
> The pool is being used by millions or tens of millions of systems around the
> world. It's the default "time server" for most of the major Linux
> distributions and many networked appliances (see information for vendors).

The NTP package in Debian Lenny uses the NTP pool, so when a user installs NTP
on their home machine, it Just Works.  Unfortunately, the
[SCSS](http://www.scss.tcd.ie/) firewall blocks NTP traffic for all hosts except
our NTP server, breaking the default configuration for users on our network.
Rather than reconfiguring every client, I configured bind on our DNS servers to
hijack the pool.ntp.org domain, answering nearly <a href="#footnote1">\[1]</a>
all requests for hosts in that domain with the address of our NTP server.  This
means that a user can just

    apt-get install ntp

and NTP will work properly for them.

<a name="footnote1"></a>\[1] The sole exception is www.pool.ntp.org: I want the
URL <http://www.pool.ntp.org> to work in a user's browser.  Although
pool.ntp.org *does* resolve to our NTP server, the web server running on that
host redirects requests for <http://pool.ntp.org> to <http://www.pool.ntp.org>,
so that URL works too.

The bind zone file is quite short:

    ; vim: set filetype=bindzone :
    ; ----------------------------------------------------------------------
    ; Zonefile to hijack the pool.ntp.org domain, so NTP clients use our local
    ; NTP server instead of futilely trying to get through the firewall.
    ; ----------------------------------------------------------------------

    $TTL			1D

    @			IN SOA	ns.cs.tcd.ie. postmaster.cs.tcd.ie. (
                    2009052001	; Serial
                    2H		; Refresh - how often slaves
                            ; check for changes.
                    2H		; Retry - how often slaves will
                            ; retry if cheking for changes
                            ; fails
                    14D		; Expire - how long slaves
                            ; consider their copies fo our
                            ; zone to be valid for
                    6H		; Minimum
                )

                ; Name server records
                IN NS		ns.cs.tcd.ie.
                IN NS		ns2.cs.tcd.ie.
                IN NS		ns3.cs.tcd.ie.
                IN NS		ns4.cs.tcd.ie.

                ; There are no MX records, because pool.ntp.org doesn't have any.

    ; This makes www.pool.ntp.org work, but of course the real address could
    ; change at any time.
    www		IN CNAME	ntppool-varnish.develooper.com.
    ; pool.ntp.org resolves to ntp.cs.tcd.ie
    ; We can't use a CNAME, because bind complains that the record has
    ; "CNAME and other data", and ignores it.
    @		IN A		134.226.32.57
    ; *.pool.ntp.org resolves to ntp.cs.tcd.ie
    *		IN CNAME	ntp.cs.tcd.ie.


You can play with it using commands like:

    dig @ns.cs.tcd.ie pool.ntp.org
    dig @ns.cs.tcd.ie www.pool.ntp.org
    dig @ns.cs.tcd.ie didgeridoo.pool.ntp.org
    dig @ns.cs.tcd.ie i.play.with.matches.pool.ntp.org

Our NTP server (ntp.scss.tcd.ie) is part of the NTP pool, and can be used by
anybody, but you're probably better off [using the
pool](http://www.pool.ntp.org/en/use.html).
