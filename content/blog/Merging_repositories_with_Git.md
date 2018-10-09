+++
date = 2010-06-17T17:00:23+01:00
title = 'Merging repositories with Git'
tags = ['Git', 'Subversion', 'script', 'sysadmin']
+++

For several years I had a Subversion repository named <tt>cs\_misc</tt>, where I
accumulated various pieces of code that didn't need a repository of their own.
A year ago, I decided to switch to Git, and created a repository named
<tt>cs-misc</tt>.  As described in [[Importing Subversion repositories to Git]],
I migrated <tt>cs\_misc</tt> from Subversion to Git, and now I wanted to merge
the two repositories.   Having used <tt>git remote</tt> and <tt>git push</tt>
with [Github](http://guthub.com/), I figured I'd try a similar approach, and
this worked:

    cd ~/src/cs_misc
    git remote add integrate ~/src/cs-misc
    git pull integrate master
    git remote rm integrate

Two things struck me about this:

1. It was so easy and intuitive.  OK, it wouldn't have been intuitive if I
   hadn't used <tt>git remote</tt> before, but that's a fairly basic Git
   operation.

2. This didn't just import the current version of each file from
   <tt>cs-misc</tt>, it imported the entire history.  I have no idea how to do
   that in Subversion, except for the obvious: check out each revision from
   repository A, and commit it to repository B.  I'm not saying it can't be done
   with Subversion, and it may actually be easy; I'm saying that, after five
   years of using Subversion, I have no idea where to begin.

The more I use Git, the happier I am to be using it instead of Subversion.