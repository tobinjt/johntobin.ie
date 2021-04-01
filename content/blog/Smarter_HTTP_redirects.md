+++
date = 2010-03-10T20:31:05+01:00
title = 'Smarter HTTP redirects'
tags = ['sysadmin', 'Apache']
+++

If your website is available under more than one FQDN, [standard SEO
advice](https://www.google.com/search?q=seo+multiple+hostnames) is to pick a
canonical FQDN and redirect the others to it. You can see that in action on this
website: clicking on <http://johntobin.ie/blog/smarter_http_redirects> will
redirect you to <https://www.johntobin.ie/blog/smarter_http_redirects/> (and
won't interrupt you reading this article). The simplest way to do this in Apache
is to configure a VirtualHost for johntobin.ie, and use a single
[RewriteRule](https://httpd.apache.org/docs/2.2/mod/mod_rewrite.html#rewriterule):

```apache
RewriteRule ^(.*)$ https://www.johntobin.ie$1
```

This also works for redirecting all HTTP requests to HTTPS requests.

You can improve this approach in two easy ways. Firstly, heed the SEO advice and
turn that temporary redirect (302) into a permanent redirect (301), which
browsers and (more importantly) search engines' crawlers are supposed to cache.

```apache
RewriteRule ^(.*)$ https://www.johntobin.ie$1 [L,R=301]
```

See <https://en.wikipedia.org/wiki/HTTP_response_codes> for a list of HTTP
response codes.

The second change will reduce the load on your web server slightly, and more
importantly will also slightly speed up your readers' browsing experience (and
should therefore have some SEO benefits). You may have noticed that when you
click on a URL like https://www.example.org/directory, your browser will display
https://www.example.org/directory/ (note the trailing `/` on the second URL).
When your browser makes a HTTP request for a directory, but the request doesn't
end with a `/`, the web server will redirect your browser to the same URL with a
`/` appended. When you combine that with a redirection from example.org to
www.example.org, your web browser will have to make three requests:

```
http://example.org/directory
http://www.example.org/directory
http://www.example.org/directory/
```

This is even worse if you subsequently redirect from http://www.example.org/ to
https://www.example.org/ because that adds a fourth request.

We can reduce the sequence to two requests by appending a `/` whenever a request
is missing one and redirecting to HTTPS rather than HTTP.

Here's the Apache config snippet:

```apache
# Add a trailing / if a request for a directory is missing one.
# This avoids an extra redirection: instead of
#   http://johntobin.ie/blog -> https://www.johntobin.ie/blog ->
#   https://www.johntobin.ie/blog/
# we get
#   http://johntobin.ie/blog -> https://www.johntobin.ie/blog/
#
# If the request is for a directory . . .
RewriteCond %{DOCUMENT_ROOT}/%{REQUEST_URI} -d
# . . . and the URL doesn't end with a / . . .
RewriteCond %{REQUEST_URI} !/$
# append a /, and fall through to the next RewriteRule.
RewriteRule ^(.*)$ $1/
# Redirect as before.
RewriteRule ^(.*)$ https://www.johntobin.ie$1 [L,R=301]
```
