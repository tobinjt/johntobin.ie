+++
lastmod = 2010-02-11T17:36:22+00:00
title = 'Version-controlled /etc'
tags = ['sysadmin', 'Git', 'Debian']
+++

In 2009 I migrated the [School of Computer Science and
Statistics](https://www.scss.tcd.ie/) mail server from Solaris to Debian Linux.
I made a lot of changes and improvements during the migration; one of the
simplest was to keep `/etc` under version control. I assume most people are
familiar with version control from writing code - if you're not, please spend a
couple of hours reading and experimenting with any modern VCS, you'll be
thankful you did. I first set up a version controlled `/etc` almost 10 years ago
when I was [Netsoc's](https://www.netsoc.tcd.ie/) sysadmin, but back then I was
using CVS, and it was complicated by Solaris putting binaries and named pipes in
`/etc` for backwards (and I really mean backwards) compatibility. This time I
used [etckeeper](https://etckeeper.branchable.com/) and
[git](https://git-scm.com/). One of the reasons for using git is that it's
distributed: if we added a second mail server, I wanted to make synchronising
`/etc` as simple as possible. It has proven to be very useful:

- Being able to see the changes I made in previous days, especially during the
  initial setup, when a lot of services needed a lot of configuration.

- Finding out when files last changed, so we can assure ourselves and users that
  we haven't changed anything that would cause the problems they're having, or
  find out that someone else made a change unbeknownst to us that could be
  responsible.

- Avoiding directory listings like this:

  ```
  dovecot.conf
  dovecot.conf.2008-2009
  dovecot.conf.2009-05-07
  dovecot.conf.2009.07.13
  dovecot.conf.2009-12-19.attempt.3.nearly.there
  dovecot.conf.before-changes
  dovecot.conf.Friday
  dovecot.conf.worked-for-brendan
  dovecot.conf.worked.yesterday
  dovecot.conf.yesterday
  dovecot.jic.conf.jan
  ```

Setup is explained in _/usr/share/doc/etckeeper/README.gz_ but I'll summarise
here:

```shell
cd /etc
etckeeper init
git status
# review the list of files to be added; files can be removed with
#   git rm --cached FILE
# files can be ignored by adding them to /etc/.gitignore
git commit -m "Initial import of /etc"
```

That's it - you now have a version controlled /etc. Chances are that you'll need
to ignore some files because they're generated from others or modified daemons,
but that's easy to do. If you intend cloning the repository, please read the
security advice in _/usr/share/doc/etckeeper/README.gz_ to avoid any nasty
surprises.
