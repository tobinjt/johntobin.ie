+++
date = 2016-04-25T22:23:53+01:00
title = 'Automatic WiFi reconnection on Mac OS'
tags = ['MacOS', 'automation', 'sysadmin']
+++

I've been annoyed recently by MacOS not automatically reconnecting to WiFi when
our router is restarted. This is slightly annoying when it's my laptop, but it's
really annoying when it's the Mac Mini, because I have to grab a keyboard and
manually reconnect. I decided that I should automate this away, and after some
searching I found `networksetup`. I wrapped that with a small tool that checks
connectivity using `ping` and runs `networksetup` if `ping` fails; I run the
tool from `cron` every 10 minutes, so even if something fails it'll be retried
pretty soon (though if it failed once it's likely to fail again if nothing has
changed). You need to figure out the network interface to consider by running
`networksetup -listnetworkserviceorder` and looking for the WiFi interface.

The code has grown more complex as I work around temporary blips in network
connectivity, see the full code at
<https://github.com/tobinjt/bin/blob/master/reconnect-wifi>
