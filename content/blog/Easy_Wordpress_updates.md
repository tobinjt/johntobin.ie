+++
date = 2019-04-02T21:22:35+01:00
title = "Easy Wordpress updates"
tags = ['automation', 'sysadmin', 'website', 'Wordpress']
+++

New versions of Wordpress are released regularly, and themes and plugins are
upgraded frequently. I wrote
[wordpress-install](/blog/installing_and_upgrading_wordpress_core_plugins_and_themes/)
to make updating a single plugin/theme/Wordpress easy, but it still requires
running a command like `wordpress-install DIRECTORY theme twentynineteen` for
each plugin/theme/Wordpress that needs to be updated. That's quite toilsome so I
wrote a simple wrapper around `wordpress-install`:
[update-wordpress-core-plugins-and-themes](https://github.com/tobinjt/bin/blob/master/update-wordpress-core-plugins-and-themes).
It tries to update every plugin/theme/Wordpress (unless the plugin or theme
contains a file named `excluded-from-automatic-updates`), so updating everything
is just `update-wordpress-core-plugins-and-themes DIRECTORY`. The only extra
action needed is when there's a major update to Wordpress: you need to login as
an admin and go to the updates page to update the database schema.
