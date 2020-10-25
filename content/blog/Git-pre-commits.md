+++
date = 2019-04-15T09:37:08+01:00
title = "Git pre-commits"
tags = ['automation', 'Git', 'development']
+++

Humans make mistakes - that's why we write tests for our code.  Automatically
running tests or other checks when committing code is a useful way to catch
mistakes and prevent committing bad code.  Git provides many different hooks
that can be used to automatically run such checks: there's a good introduction
at <https://githooks.com/> with links to many different tools for configuring
and managing Git hooks.  I've looked at several of these tools in the past and
decided not to use them because the hooks they provide weren't useful to me.

Some useful information about git pre-commit hooks:

*   You can get the list of files being committed using `git diff --cached
    --name-only`, and you can further filter the list down using
    `--diff-filter=ACM` to only output files that have been Added, Copied, or
    Modified; see `git help diff` for more filter and output options.  This can
    make your checks faster, and allow you to skip checks for files you're not
    trying to commit yet.
*   Annoyingly, hooks are not versioned or tracked in any way :(  I deal with
    this by putting the hook in the root of the repository and symlinking it
    into the `.git/hooks/` directory; this gives me version control for the hook
    code but still requires manual action every time the repository is checked
    out to create the symlink.

I've used git's `pre-commit` hook in four different repositories:

*   Ariane's website theme uses [a very simple
    hook](https://github.com/tobinjt/ariane-theme/blob/master/git-pre-commit-hook)
    that runs `phpunit --no-coverage` to check that all the tests pass.  I don't
    generate coverage information because that requires installing [PHP
    Xdebug](https://xdebug.org/) which is fine on my laptop but not in the
    production web server, where I sometimes make changes.  More recently I've
    had to disable tests entirely on the production web server because PHPUnit
    has made backwards incompatible changes between versions so I can't run the
    same set of tests on the old and new versions.
*   For my Project Euler repository (which is private, so I'm not linking to
    it), I wrote a hook that performs several checks:
    *   Are all the test functions named correctly?  It's easy to write test
        functions that are never executed because they are named incorrectly.
    *   Check for badly formatted files; very unlikely to happen because files
        are formatted on write, but defence in depth is good.
    *   Ensure all tests pass, and that test coverage is 100% (except for one
        file where it's not possible).
*   My website's [pre-commit
    hook](https://github.com/tobinjt/johntobin.ie/blob/master/git-pre-commit-hook):
    *   Prevents checking in posts with `draft = true` because Hugo won't
        publish them.
    *   When tags are inconsistently capitalised Hugo will use a random tag,
        causing unnecessary changes in output from run to run and breaking
        external links.  Inconsistently capitalised tags are detected and block
        the commit.
*   For my [bin](https://github.com/tobinjt/bin) repository I wrote a
    [hook](https://github.com/tobinjt/bin/blob/master/bin-git-precommit-hook)
    that runs tests and checks lint.
