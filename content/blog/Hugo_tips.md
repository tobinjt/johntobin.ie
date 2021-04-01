+++
date = 2019-04-28T15:07:02Z
title = "Hugo tips"
tags = ['Hugo', 'automation', 'website']
+++

I migrated my website from [Ikiwiki](https://ikiwiki.info/) to
[Hugo](https://gohugo.io/). I had been using Ikiwiki since 2009 but a few things
annoyed me about it:

- It's not packaged for MacOS, which means I have to write on my hosting instead
  of my laptop, and my slow internet access makes that a bit painful.

- Because I'm editing remotely previewing changes is awkward and is not a good representation
  of what the page will look like in a modern browser.

  `ikiwiki --setup ~/.ikiwiki/johntobin.ie --render "${file}" | w3m -T text/html`

- Ikiwiki's Markdown flavour doesn't support [fenced code
  blocks](https://help.github.com/articles/creating-and-highlighting-code-blocks/)
  (three backticks) or syntax highlighting, both of which I use extensively in
  work.

Switching from Ikiwiki to Hugo wasn't too hard: rename all the files from
`.mdwn` to `.md`, add [front
matter](https://gohugo.io/content-management/front-matter/) to every file,
change the syntax of links. I've gradually improved the website and the
experience of using Hugo over the past few weeks so I figured I'd offer some
tips to save other people from discovering them the hard way.

## Don't follow the standard instructions for adding a theme

The Hugo docs tell you to add a theme by directly adding the git repository for
the theme as a submodule. Don't do it this way unless you're absolutely certain
that you will never make a change to the theme; instead fork the theme, create a
branch for your changes, and use that branch as the theme.

- Go to the theme you plan to use on Github and fork it.
- Check out your fork somewhere _outside_ the Hugo directory.
- Create a new branch: `git branch my-changes` and push to Github so that the
  branch is available there.
- Now add the theme in the Hugo directory: `git submodule add -b my-changes git@github.com:tobinjt/hugo-coder.git themes/hugo-coder`.

This lets you make changes and keep them cleanly separated from upstream
changes; if you want to push fixes upstream you can create a new branch (I
imaginatively named mine `changes-for-upstream`) commit there, push to Github,
and make a pull request (like
[mine](https://github.com/luizdepra/hugo-coder/pull/112)). Make sure the new
branch is based on `master` rather than `my-changes` so that it only includes
the changes you want to push upstream!

Dealing with multiple Git branches and checkouts is painful, so I wrote
[update-hugo-coder](https://github.com/tobinjt/bin/blob/master/update-hugo-coder)
to automate the process away. It'll probably need a couple of more tweaks as I
run into edge conditions but it's working pretty well already.

## Suggested config.toml changes

I suggest adding these options to `config.toml`:

````toml
# Syntax highlight code blocks based on the syntax in the starting line (e.g.
# ```shell).
pygmentsCodefences = true
# You must choose a theme or the syntax highlighting does nothing.
pygmentsStyle = "solarized-dark"
# Start vim when I run `hugo new blog/foo.md` so I don't need to copy and paste
# the path that is output.
newContentEditor = "vim"
````

## hugo vs rsync

Hugo regenerates every output file every time you run it, and the changed
timestamps cause `rsync` to replace all the files on the remote side rather than
just transferring the new or updated files unless you pass the right arguments:

- `--checksum`: force checksumming of every file rather than using timestamp and
  size comparison so that identical files are detected and skipped rather than
  being transferred. This saves some bandwidth at the cost of CPU, but more
  importantly if you're using `-v` the output will show the files with
  meaningful differences rather than all files.
- `--no-times`: don't update timestamps on the remote side, which would
  otherwise happen because the timestamp of every file has been changed on the
  source side. Updating the timestamps on the remote side breaks browser caching
  unnecessarily so I avoid it.

A complete `rsync` command:

```shell
rsync -av --delete --checksum --no-times public/ hosting:/destination/
```

Themes typically include the version of Hugo that generated the page in the
`<head>` section of each page. This guarantees that every Hugo upgrade will
cause every file to be updated on the remote side because the contents differ,
making other upgrade-related changes harder to find and breaking browser caching
for no benefit. I [removed this
line](https://github.com/tobinjt/hugo-coder/commit/bd184a825cfd60c7de80e6a1beb00740fd0c7a6f)
and you might want to also.

## Archetypes are useful

Huge uses [archetypes](https://gohugo.io/content-management/archetypes/) when
creating new pages with `hugo new foo/bar.md`. The subdirectory (`foo`)
determines the archetype used, which in this case will be
`your-theme/archetypes/foo.md` or `your-theme/archetypes/default.md` if the
former doesn't exist. The theme I chose provides a `post` archetype and a very
bare `default` archetype, so I wrote a [blog
archetype](https://raw.githubusercontent.com/tobinjt/hugo-coder/my-changes/archetypes/blog.md)
that adds a `tags` placeholder and determines the title of the post from the
filename.

## Full RSS feed

The default RSS feed that Hugo only provides contains partial content, which I
really dislike - I want to be able to read the full content in my RSS reader
instead of loading the page separately. There isn't an option to control whether
partial or full content is used, though there is a [long-standing request to
support it](https://github.com/gohugoio/hugo/issues/4071) and [an offer to
implement it](https://github.com/gohugoio/hugo/issues/5002). Currently the only
solution is to save the [default RSS
template](https://gohugo.io/templates/rss/#the-embedded-rss-xml) that is
compiled into Hugo as `your-theme/layouts/_default/rss.xml` and change
`.Summary` to `.Content`; here is [the resulting
file](https://github.com/tobinjt/hugo-coder/blob/my-changes/layouts/_default/rss.xml)
if you would prefer to just copy it.

## Inconsistently capitalised tags cause churn

When tags are inconsistently capitalised Hugo will use a random tag, causing
unnecessary changes in output from run to run and breaking external links. I use
a [git pre-commit
check](https://github.com/tobinjt/johntobin.ie/blob/master/git-pre-commit-hook)
to detect inconsistently capitalised tags and block the commit, see [Git
pre-commits](/blog/git-pre-commits/) for more information.

## Automating common operations

I wrote a
[Makefile](https://github.com/tobinjt/johntobin.ie/blob/master/Makefile) to
automate common tasks, e.g. starting a local server with the correct flags or
regenerating content and copying it to my hosting. There are also less obvious
operations that I actually use more often:

- Running `rsync` with `--dry-run` to see which files would be transferred and
  thus which files have been updated or newly added.
- Transferring the published content from my hosting to my laptop with `rsync`
  then running `diff -Naur` on the published and generated content to see
  detailed changes.
