+++
lastmod = 2021-12-27T22:20:53+01:00
title = "Git pre-commits"
tags = ['automation', 'Git', 'development']
+++

Humans make mistakes - that's why we write tests for our code. Automatically
running tests or other checks when committing code is a useful way to catch
mistakes and prevent committing bad code, and Git provides many different hooks
that can be used to automatically run such checks. Initially I wrote hooks as
shell scripts, but recently I checked out <https://pre-commit.com/> and it both
makes overall management easy and provides many hooks, so I have migrated to
that.

There are many packaged hooks available; I've used those for complex checks, but
for simpler checks I've found it easier to just write a hook config, e.g.
running [shellcheck](https://www.shellcheck.net/) requires [just 5 lines of
config](https://github.com/tobinjt/bin/blob/ad5b57afa03d650ac657249c886300d581a8c60f/.pre-commit-config.yaml#L45-L49).
My [bin directory](https://github.com/tobinjt/bin/) has [the most
checks](https://github.com/tobinjt/bin/blob/master/.pre-commit-config.yaml)
because it has the biggest mix of code.

### If you're interested in writing your own hooks

- You can get the files being committed using `git diff --cached --name-only`,
  and you can further filter the list down using `--diff-filter=ACM` to only
  output files that have been Added, Copied, or Modified; see `git help diff`
  for more filter and output options. This can make your checks faster, and
  allow you to skip checks for files you're not trying to commit yet.
  <https://pre-commit.com/> only runs checks for files being committed.
- Annoyingly, hooks are not versioned or tracked in any way :( You can deal with
  this by putting the hook in the root of the repository and symlinking it into
  the `.git/hooks/` directory; this gives version control for the hook code but
  still requires manual action every time the repository is cloned to create the
  symlink. <https://pre-commit.com/> also requires manual action when the
  repository is cloned.
- A warning about git pre-commit hooks: they run with whatever contents are in
  your local directory, so if you're partially committing they might pass
  incorrectly. E.g. if you modify `foo.go` and `foo_test.go`, but you're only
  committing `foo_test.go`, `go test` will pass in a pre-commit but won't pass
  on the committed code because your changes to `foo.go` won't have been
  committed. This is one of the problems that <https://pre-commit.com/> saves
  you from - it stashes uncommitted changes so that checks run against only the
  code being committed.
