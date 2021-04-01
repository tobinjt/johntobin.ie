+++
date = 2010-06-17T17:00:23+01:00
title = 'Merging repositories with Git'
tags = ['Git', 'Subversion']
+++

For several years I had a Subversion repository named `cs_misc`, where I
accumulated various pieces of code that didn't need a repository of their own.
A year ago, I decided to switch to Git, and created a repository named
`cs-misc`. As described in [Importing Subversion repositories to
Git](/blog/importing_subversion_repositories_to_git/), I migrated `cs_misc` from
Subversion to Git, and now I wanted to merge the two repositories (`cs-misc` and
`cs_misc`). Having used `git remote` and `git push` with
[Github](https://github.com/), I figured I'd try a similar approach, and this
worked:

```shell
cd ~/src/cs_misc
git remote add integrate ~/src/cs-misc
git pull --allow-unrelated-histories integrate master
git remote rm integrate
```

Two things struck me about this:

1. It was so easy and intuitive. OK, it wouldn't have been intuitive if I hadn't
   used `git remote` before, but that's a fairly basic Git operation.

2. This didn't just import the current version of each file from `cs-misc`, it
   imported the entire history. I have no idea how to do that in Subversion,
   except for the obvious: check out each revision from repository A, and commit
   it to repository B. I'm not saying it can't be done with Subversion, and it
   may actually be easy; I'm saying that, after five years of using Subversion,
   I have no idea where to begin.

The more I use Git, the happier I am to be using it instead of Subversion.
