+++
lastmod = 2021-12-27T22:20:53+01:00
title = 'Python development'
tags = ['Python', 'programming', 'testing']
+++

Normally I do Python development in work, where everything is already set up for
easy development and testing. It took considerable research and setup to get a
similarly good environment for Python development at home, so I decided to
document it for myself and others :)

## Install all the packages

### Mac OS

The list of Python modules you need is:

```text
black lxml mutmut mypy pudb pyfakefs pylint pytest pytest-cov
```

See [Upgrading packages installed with pip3 is troublesome]({{< relref
"#upgrading-packages-installed-with-pip3-is-troublesome" >}}) for
how I install and upgrade packages; I recommend using
`virtualenv` as described there rather than installing globally.

### Linux

These package names are correct for Debian.

```shell
sudo apt install black pylint3 python3-mypy python3-pudb python3-pyfakefs \
  python3-pytest python3-pytest-cov
```

`mutmut` isn't packaged for Debian, so you might want to install it with Pip.

## Testing

I use [pytest](https://docs.pytest.org/en/stable/) for running tests and
[pytest-cov](https://pypi.org/project/pytest-cov/) to get test coverage so I
can figure out which parts of my code still need to be tested.

```shell
cd test-directory
pytest
```

### Test coverage

To enable test coverage with `pytest`, create `pytest.ini` in the directory
containing your tests, with contents like
<https://github.com/tobinjt/bin/blob/master/python/pytest.ini>. Every time your
tests are run successfully coverage will be generated and a message will be
printed showing the coverage percentage.

I found that test coverage needed quite a bit of configuration through the file
`.coveragerc` in the directory containing your tests; my final contents are
<https://github.com/tobinjt/bin/blob/master/python/.coveragerc>. I highly
recommend configuring testing to fail if there is insufficient coverage. You can
also configure a HTML output directory so that you can easily see which lines of
code you haven't tested; configuring a portable output directory might be
difficult, I haven't needed to do so yet.

### Integration tests

I'm a fan of integration tests, where instead of testing individual functions
you test large swathes of code at a time. I take the approach of picking a piece
of functionality that should be supported, then writing a test to exercise that
functionality end to end.

<https://github.com/tobinjt/bin/blob/ad5b57afa03d650ac657249c886300d581a8c60f/python/linkdirs_test.py#L39> is a
good example of this, where I test progressively more complex use cases and
scenarios by:

1.  Populating a fake filesystem (`pyfakefs` is great for this) with the
    scenario to deal with.
1.  Calling `main()` with the right arguments.
1.  Checking that the resulting filesystem is correct.

This was particularly reassuring when I added deletion to `linkdirs.py` :)

### Automatically running tests

I like having tests run every time I save the source or test file because it
saves me from doing it manually. See [Automatically running tests, linters, or
anything](https://www.johntobin.ie/blog/automatically_running_tests_linters_or_anything/)
for an easy way to do this.

### Mutation testing

Mutation testing is where minor changes are made to source code (e.g.
initialising a variable to `True` instead of `False`) and then the tests are run
with the changed source. If the tests still pass despite the change it _might_
indicate a gap in testing, or it might indicate that the default value is simply
a placeholder that is always overwritten, or the change might not be meaningful
(e.g. `.rstrip('\n')` changing to `.rstrip('XX\nXX')`), or other reasons. There
isn't a one-size-fits-all approach that you can take to addressing mutations
that don't cause test failures - sometimes you will add tests, sometimes you
will change the source, and sometimes you will mark the line so it's not mutated
in future.

I use [mutmut](https://mutmut.readthedocs.io/en/latest/) for mutation testing.
I have [made some changes to my
code](https://github.com/tobinjt/bin/tree/master/python) in response to `mutmut`
warnings, and thus far I think the most significant change was to add tests for
the output from `--help` to ensure that I don't accidentally make it confusing
(e.g. changing the description so it no longer matches the options).

The first run of `mutmut` for any file will be slow, but for subsequent runs
`mutmut` will only check mutations that previously failed, so it speeds up as
you make fixes. Sadly there have been a couple of occasions where it stayed
reporting problems despite me fixing them, and the only way to mitigate that
situation was `rm .mutmut-cache` and rerun from scratch :( `mutmut` runs your
tests once without mutations to get a timing baseline so it can detect mutations
that cause tests to run for too long, but this means that you cannot switch to
doing anything else while testing mutations, because if the extra system load
from doing something else slows down the testing enough you will have false
positives.

Beware: `mutmut` only runs your tests with unmodified source the _first_ time
you run it. If you break your tests while addressing `mutmut` warnings, on the
next run it will make all the mutations, run the tests, and declare that you
have no problems to fix because the tests fail - but not because of the
mutations :(

I found running `mutmut` was awkward - it doesn't understand that tests for
`foo.py` are in `foo_test.py`, so I wrote a [wrapper for mutmut
run](https://github.com/tobinjt/bin/blob/master/mutmut_run) that first runs
tests with unmodified sources, then runs `mutmut` with the correct arguments,
and fixes permissions afterwards (because `mutmut` replaces the source files it
operates on and doesn't set permissions correctly).

I use `mutmut` like this:

1.  Run mutation testing:

    ```text
    $ mutmut_run colx.py

    - Mutation testing starting -

    These are the steps:
    1. A full test suite run will be made to make sure we
       can run the tests successfully and we know how long
       it takes (to detect infinite loops for example)
    2. Mutants will be generated and checked

    Results are stored in .mutmut-cache.
    Print found mutants with `mutmut results`.

    Legend for output:
    🎉 Killed mutants.   The goal is for everything to end up in this bucket.
    ⏰ Timeout.          Test suite took 10 times as long as the baseline so were killed.
    🤔 Suspicious.       Tests took a long time, but not long enough to be fatal.
    🙁 Survived.         This means your tests needs to be expanded.
    🔇 Skipped.          Skipped.

    1. Using cached time for baseline tests, to run baseline again delete the cache file

    2. Checking mutants
    ⠋ 88/88  🎉 62  ⏰ 1  🤔 0  🙁 25  🔇 0

    real    4m38.098s
    user    4m17.888s
    sys     0m17.081s
    ```

1.  Show results:

    ```text
    $ mutmut show colx.py

    To apply a mutant on disk:
        mutmut apply <id>

    To show a mutant:
        mutmut show <id>


    Timed out ⏰ (1)

    ---- colx.py (1) ----

    # mutant 229
    --- colx.py
    +++ colx.py
    @@ -121,7 +121,7 @@
         # Strip leading and trailing empty fields.
         first_index = 0
         while len(split_columns) > first_index and not split_columns[first_index]:
    -      first_index += 1
    +      first_index = 1
         last_index = len(split_columns) - 1
         while last_index > first_index and not split_columns[last_index]:
           last_index -= 1


    Survived 🙁 (25)

    ---- colx.py (25) ----

    # mutant 161
    --- colx.py
    +++ colx.py
    @@ -39,7 +39,7 @@
       Returns:
         argparse.Namespace, with attributes set based on the arguments.
       """
    -  description = '\n'.join(__doc__.split('\n')[1:])
    +  description = 'XX\nXX'.join(__doc__.split('\n')[1:])
       usage = __doc__.split('\n')[0]

       argv_parser = argparse.ArgumentParser(
    ```

1.  Investigate and fix some of the reported mutants.

    - False positives (e.g. changing a constant used consistently throughout
      the codebase) can be disabled with `# pragma: no mutate`.
    - Tests can be added or expanded, e.g. changing regexes to be anchored, or
      adding edge cases so that boundary conditions are tested more tightly.
    - Source changes may be appropriate, but I haven't encountered any good
      examples yet.

1.  `GOTO 1`.

I've found that I can fix a lot of the mutations pretty quickly, then my
progress slows down as I pick off more and more of the low hanging fruit. My aim
is to reach 0 mutations that pass tests, and sometimes the pragmatic way to deal
with the last few is to just disable them. I aim for 0 so that future runs give
me a better signal, and I'm not left wondering _"is that something I decided to
ignore in the past?"_ because I know I didn't decide to ignore anything. I've
also found that I'm getting faster with each subsequent file, because I'm
learning patterns and I can reuse tests and fixes from earlier files, which
encourages me to continue.

## Linting

I use [pylint](https://pypi.org/project/pylint/) for linting. I have [configured
Syntastic and Vim]({{< relref "#vim-configuration" >}}) to run `pylint`
automatically on saving, or see [Automatically running tests, linters, or
anything](https://www.johntobin.ie/blog/automatically_running_tests_linters_or_anything/)
for an easy way to run `pylint` every time you save a file.

```shell
pylint *.py
```

<https://github.com/tobinjt/dotfiles/blob/master/.pylintrc> is my
`$HOME/.pylintrc`.

## Automatic formatting

I use [Black](https://black.readthedocs.io/en/stable/) for autoformatting my
code. I run this manually and as a pre-commit hook but will probably make it
automatic the next time I write some Python. I used to use
[YAPF](https://github.com/google/yapf) but Google is now developing a fork of
[Black](https://github.com/psf/black) named
[Pyink](https://github.com/google/pyink), so I switched to Black.

```shell
black *.py
```

## Type checking

I use [mypy](https://mypy.readthedocs.io/en/latest/index.html) for checking type
annotations, which gives me more confidence that I'm passing the right types to
functions, and helps document my code - particularly when I use type aliases to
give meaningful names to parameter types. I have [configured Syntastic and
Vim]({{< relref "#vim-configuration" >}}) to run `mypy` automatically on saving,
or see [Automatically running tests, linters, or
anything](https://www.johntobin.ie/blog/automatically_running_tests_linters_or_anything/)
for an easy way to run `mypy` every time you save a file.

```shell
mypy *.py
```

<https://github.com/tobinjt/dotfiles/blob/master/.mypy.ini> is my
`$HOME/.mypy.ini`.

## Debugging

I've started using [pudb](https://documen.tician.de/pudb/index.html) for
debugging because it presents so much more information at once. I recently
debugged a failing test where displaying all the local variables made the
problem obvious, but without that display (e.g. using `pdb` or printing debug
information on each run) the debugging process would have been far slower.

To trigger debugging at a specific point in your code:

```python
import pudb
pudb.set_trace()
```

## Stop generating `.pyc` files

By default Python will write compiled bytecode for `foo.py` to `foo.pyc`, which
I found annoying because it clutters up your source directory. I disabled that
by setting the environment variable `PYTHONDONTWRITEBYTECODE`, e.g.:

```shell
export PYTHONDONTWRITEBYTECODE="No .pyc files please"
```

Note that you'll probably want to unset this when installing Python modules so
that you get the benefit of loading bytecode; to do that I use this wrapper
function:

```shell
pip3() {
  (unset PYTHONDONTWRITEBYTECODE; command pip3 "$@")
}
```

## Upgrading packages installed with `pip3` is troublesome

`pip3` doesn't track manually installed packages vs auto-installed packages, and
doesn't have a way to upgrade all packages. Upgrading all packages (manually
installed and auto-installed) _can_ be done with a shell one-liner, except that
it doesn't take dependencies into account, so you might upgrade a dependency to
a version that breaks a package you manually installed :(

If you keep track of the packages you've installed, you can upgrade them with
`pip3 install --upgrade pkg1 pkg2 ...`i, but I found that wasn't reliable -
sometimes dependencies weren't updated properly. For a long time I used a _nuke
it from orbit_ approach: remove the `site-packages` directory, reinstall Python,
and reinstall the packages I need. This approach was probably overkill, but
after debugged a failed upgrade a couple of times I found this was easier. I
used this approach for a couple of years until Homebrew started packaging Python
modules (specifically `pre-commit` depends on `six`); this complicated the
restoration process enough that I figured sooner or later I'd break a package,
so I changed approach.

My current approach is to use
[virtualenv](https://virtualenv.pypa.io/en/latest/) to install all the modules
in a separate directory, which I can then delete when I want to update them.  I
add this directory to the end of my PATH (so that the python binary in it
isn't used in preference to the system python binary) and everything Just Works.
A simplified version would be:

```shell
install_dir="${HOME}/tmp/virtualenv"
mkdir -p "${install_dir}"
# Run virtualenv from the destination directory just in case.
cd "${install_dir}"
virtualenv --no-periodic-update "${install_dir}"
# virtualenv sometimes deletes the destination directory so cd there again.
cd "${install_dir}"
source bin/activate
pip3 install black lxml mypy pudb pyfakefs pylint pytest pytest-cov \
  pytest-flakefinder pyyaml
```

I do this once a month because frequent updates make it far easier to figure out
breakages, so I've written
<https://github.com/tobinjt/bin/blob/master/update-python-modules> to make it a
single command.

## Vim configuration

I don't have much configuration for Python:

- Make sure that [syntastic](https://github.com/vim-syntastic/syntastic) uses
  Python 3 so type annotations can be parsed:

  ```vim
  let g:syntastic_python_python_exec = 'python3'
  ```

- Configure [syntastic](https://github.com/vim-syntastic/syntastic) to use
  `mypy` too:

  ```vim
  let g:syntastic_python_checkers = ['python', 'mypy', 'pylint']
  ```

  I chose the order `python`, `mypy`, `pylint` to fail fast and surface errors
  from most severe to least severe - syntax errors will be caught by `python`,
  type errors by `mypy`, and lint errors by `pylint`.
