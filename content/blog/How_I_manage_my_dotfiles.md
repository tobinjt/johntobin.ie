+++
title = 'How I manage my dotfiles'
tags = ['Git', 'automation', 'shell', 'sysadmin']
+++

Your `dotfiles` are the project that you'll work on for longest.

I spend a lot of my time using Vim, Bash, and various CLI tools. Over the past
15 years I've spent a lot of time configuring these tools, and I've gotten so
used to my configuration that it's really weird when I don't have it. I use 6
machines on a regular basis (some with multiple accounts), so I need a way of
managing those configuration files (typically known as `dotfiles`) and keeping
them in sync between machines.

Configuration files aren't much different to code, so the obvious way to
maintain them is a Version Control System. I originally used
[CVS](https://en.wikipedia.org/wiki/Concurrent_Versions_System) back in 2002 or
so, then migrated to [Subversion](https://subversion.apache.org/) around 2007 (I
think), and I've been using [Git](https://git-scm.com/) since 2010. The big
difference between dotfiles and code is that dotfiles need to be in your home
directory, not a subdirectory somewhere. One approach is to make your home
directory into a VCS repository and configure the VCS to ignore everything you
don't want checked in, but that requires more maintenance than I'm happy with,
and it possibly leaks information (e.g. if `.gitignore` contains
`bank-details.txt`). The other approach is keep the checked out repository
somewhere else and link all the files into your home directory - this is what
I'm doing.

Start by creating a Git repository on a hosting service somewhere; I use
<https://github.com/>, but others have recommended <https://bitbucket.org/>. Why
use a hosted service? Because you want the repository to be easily available and
you want someone else taking care of backups for you. I was very imaginative and
named mine `dotfiles` :) Check out a copy of it somewhere; the tools I wrote
assume it will be under `~/src` and match `*dotfiles*`.

Now I need a tool to link the files in `~/src/dotfiles` into your home
directory. I couldn't find one with a quick search back in 2010 (though now
there appear to be many available), and I needed a project to learn Python after
starting work in Google, so I wrote one:
[linkdirs](https://github.com/tobinjt/bin/blob/master/python/linkdirs.py). It's
one of the first pieces of Python I wrote and it wasn't very good to start with,
so a couple of years ago I wrote tests and improved it significantly - but even
the first version was better than the ugly Perl code from 2002 it replaced.
`linkdirs` is generic: it ignores various files associated with VCS systems, and
Vim swap files, but you can use it for linking directories for other reasons.
It links from multiple source directories, creates destination directories as
necessary, ignores specific files if you want, and hard links files from source
to destination. If a destination file exists but isn't a hard link to the source
file, it will check if the contents are the same; if they are it will delete the
destination and create the hard link, otherwise it will display the diffs. If
anything fails or there are diffs it will exit unsuccessfully.

`linkdirs` is pretty low level, so I wrote a wrapper:
[dotfiles](https://github.com/tobinjt/bin/blob/master/dotfiles). If finds all
directories matching `*dotfiles*` directly under `~/src` (so I can have a
standard repository on every computer plus a work repository on work computers),
runs `linkdirs` with the right arguments, and does some more things:

1.  `cat "${HOME}"/.ssh/config-??-* > "${HOME}/.ssh/config"`

    `ssh` doesn't support multiple config files or includes, but I have standard
    configs and work configs in different repositories, so I keep the config
    snippets in separate files and combine them. This is done every time
    dotfiles runs - there's nothing clever to check if an update is necessary.

1.  Add missing `known_hosts` entries to `"${HOME}/.ssh/known_hosts"`.

    Again, ssh doesn't support multiple `known_hosts` files, so multiple files
    need to be combined. Originally I just replaced `known_hosts` entirely, but
    that turned out to be a maintenance nightmare, e.g. machines getting
    different IP or IPv6 addresses.

1.  `vim` help tags from different plugins (see below) need to be updated, and
    spell files need to be compiled. I wrote a simple `vim` function for each
    ([UpdateBundleHelptags](https://github.com/tobinjt/dotfiles/blob/master/.vim/plugin/JT_functions.vim#L48)
    and
    [UpdateSpellFiles](https://github.com/tobinjt/dotfiles/blob/master/.vim/plugin/JT_functions.vim#L53)),
    and they're both run every time by `dotfiles`.

Both `linkdirs` and `dotfiles` support reporting and deleting unexpected files
in the destination directory, making it relatively easy to find or cleanup
leftover files that I've deleted from the repository.

I use about 20 Vim plugins, and I manage each plugin as a [git
submodule](https://git-scm.com/docs/git-submodule), allowing me to easily update
each plugin over time. Because I add and update plugins quite infrequently I've
written instructions for myself in [my
.vimrc](https://github.com/tobinjt/dotfiles/blob/master/.vimrc#L85). I use
[vim-plug](https://github.com/junegunn/vim-plug) to manage Vim's `runtimepath`,
but I add the repositories manually because `vim-plug` doesn't support
submodules. I wrote
[update-dotfiles-and-bin-plugins](https://github.com/tobinjt/bin/blob/master/update-dotfiles-and-bin-plugins)
to automate updating plugins, and I run it every 4 weeks to stay current so that
I don't need to deal with large diffs when I need a bug fix. It also runs
[install-extra-tools-for-vim](https://github.com/tobinjt/bin/blob/master/install-extra-tools-for-vim)
to install extra tools needed by Vim plugins, mainly for Golang and Rust (tools
for Python are installed differently, see [Upgrading packages installed with
pip3 is
troublesome](https://www.johntobin.ie/blog/python_development/#upgrading-packages-installed-with-pip3-is-troublesome)
for details.

When I push a change to Github I later need to sync that change to every machine
(normally the next time I use the machine, or when I notice that something is
missing). This is simple but tedious, so I wrapped up the per-machine work in
[update-dotfiles-and-bin](https://github.com/tobinjt/bin/blob/master/update-dotfiles-and-bin).
That program checks for unexpected diffs, unexpected files, updates every `bin`
and `dotfiles` repository, updates submodules if a newer version has been
committed to my repository, pushes any local changes, and deletes any unexpected
files.

I update all my home machines and users easily using
[update-dotfiles-and-bin-everywhere](https://github.com/tobinjt/bin/blob/master/update-dotfiles-and-bin-everywhere)
by using ssh to run `update-dotfiles-and-bin`.

A relatively rare action is setting up a new machine or a new user, but I also
made that really simple:
[clone-dotfiles](https://github.com/tobinjt/bin/blob/master/clone-dotfiles).
Originally `dotfiles` was a shell function rather than a standalone tool, so
`clone-dotfiles` was more complicated back then. When I use a new machine I
clone my `bin` repository, run `clone-dotfiles`, and I'm ready to go.

Most of these tools are generic and can be reused by anyone, `clone-dotfiles`
and `update-dotfiles-and-bin-everywhere` are the exceptions.
