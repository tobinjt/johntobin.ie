+++
date = 2010-06-16T09:02:03+01:00
title = 'Importing Subversion repositories to Git'
tags = ['Git', 'Subversion', 'automation']
+++

I'm migrating all my source code repositories from Subversion to Git. I tried
`git-svnimport`, but it only works if your repository has the recommended layout
of `trunk`, `tags`, and `branches`; unfortunately, a lot of mine don't.
`git-svn` initially looked like overkill, but it worked quite well. Below is the
simple shell script I used to import my repositories and push them to Github; I
manually created each repository using Github's web interface, but it may be
possible to script that too.

```shell
#!/bin/bash

set -e -f -u -o pipefail

for repo in $( < "${HOME}/repo-list" ); do
  echo "${repo}"
  cd "${HOME}/src"
  git svn clone \
    "svn+ssh://subversion.scss.tcd.ie/users/staff/tobinjt/src/svnroot/${repo}"
  cd "${repo}"
  git remote add origin "git@github.com:tobinjt/${repo}.git"
  git push origin master
done
```
