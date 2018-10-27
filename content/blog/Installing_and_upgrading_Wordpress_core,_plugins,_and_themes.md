+++
date = 2018-10-23T21:29:26+01:00
title = 'Installing and upgrading Wordpress core, plugins, and themes'
tags = ['automation', 'sysadmin', 'Wordpress']
+++

My wife's [website](https://www.arianetobin.ie/) is built on
[Wordpress](https://wordpress.org/).  It uses a small number of plugins, and
I've tested many plugins over the years; all those plugins need to be installed,
and of course Wordpress core, plugins, and themes need to be upgraded when new
versions are released.  This isn't difficult (download core/plugin/theme,
extract zip file in the correct directory) but it's tedious so it's ideal for
automating.  I wrote
[wordpress-install](https://github.com/tobinjt/bin/blob/master/wordpress-install)
to do this; it's not the most elegant code because it has to deal with paths and
URLs being different for each supported type, but it works.  It requires the
Wordpress install to be inside a `git` repository so that changes can be
reverted if necessary, though I've rarely needed to revert an upgrade so the
tool doesn't support reverting - you need to use `git revert`.  You can
optionally choose a specific version of the core/plugin/theme to install, so you
could use that as a mechanism to downgrade; by default the latest version is
installed.  It uses the tool described in [Checking a git client is
clean](/blog/checking_a_git_client_is_clean/) to check that there aren't any
uncommitted changes in the client before performing the upgrade, and commits all
changes after the upgrade.

Usage:

```shell
# Upgrade Wordpress core:
wordpress-install ~/dev.arianetobin.ie/ wordpress
# Upgrade akismet plugin:
wordpress-install ~/dev.arianetobin.ie/ plugin akismet/
# Upgrade akismet plugin to a specific version:
wordpress-install ~/dev.arianetobin.ie/ plugin akismet/ 4.0.8
# Upgrade twentyfourteen theme:
wordpress-install ~/dev.arianetobin.ie/ theme twentyfourteen
```
