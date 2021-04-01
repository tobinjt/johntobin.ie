+++
date = 2018-11-14T21:03:54Z
title = "Suppressing unnecessary cookie law CSS and JavaScript"
tags = ['SEO', 'website', 'Wordpress']
+++

The [EU Cookie Law](https://www.wired.co.uk/article/cookies-made-simple)
requires a notice about cookies on every website. My wife's
[website](https://www.arianetobin.ie/) is built on
[Wordpress](https://wordpress.org/), so to display the cookie notice I use the
[GDPR Cookie Consent](https://wordpress.org/plugins/cookie-law-info/) plugin.
The CSS and JavaScript resources the plugin uses are unconditionally added to
every page, but they are really only needed on the first page load: the user
accepts the cookies if they stay using the website, so the notice isn't shown a
second time to anyone. If the cookie that the plugin uses is set when processing
the user request (yes, the cookie law plugin uses a cookie), then the CSS and
JavaScript resources are unnecessary and can be stripped out of the page before
the page is sent to the browser. This is relatively _simple_ to do with
Wordpress, but figuring out the right incantation is not _easy_. The code to do
this is in the functions `ShouldRemoveCookieLawInfo`,
`MaybeHideCookieLawInfoInFooter`, and `MaybeRemoveCookieLawInfoFromHead` in
[functions.php](https://github.com/tobinjt/ariane-theme/blob/master/functions.php).
This is the second implementation of removing these resources when they are
unnecessary - the first implementation was broken by changes to the plugin. The
resources are also removed for certain Google user-agents, so that testing with
[PageSpeed Insights](https://developers.google.com/speed/pagespeed/insights/)
and similar tools produces results closer to the typical user experience.

Removing the cookie law resources was the last step (so far) in my quest to
speed up Ariane's website. There are several standard Wordpress resources
unconditionally removed by the various incantations in
[functions.php](https://github.com/tobinjt/ariane-theme/blob/master/functions.php)

- search for `Remove unnecessary resources that Wordpress or plugins include` to
  find them - e.g. not loading emoji support that isn't used anywhere in the
  website:

```php
// Stop loading emoji stuff.
remove_action('wp_head', 'print_emoji_detection_script', 7);
remove_action('wp_print_styles', 'print_emoji_styles');
```

To suppress these resources I repeated this process:

- Used [PageSpeed
  Insights](https://developers.google.com/speed/pagespeed/insights/) to test the
  speed of various pages.
- Looked at the results where it complained about unused resources.
- Searched online for the resource filename until I found a description of how
  somebody else suppressed that resource.
- Cargo-culted those instructions and verified that the resource was no longer
  referenced.

Occasionally more work was needed because Wordpress had changed enough that the
instructions didn't work, but they at least pointed me in the right direction.
