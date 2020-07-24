+++
date = 2020-07-24T10:58:16-04:00
title = 'Python development'
tags = ['Python', 'programming', 'testing']
+++

Normally I do Python development in work, where everything is already set up for
easy development and testing.  It took considerable research and setup to get a
similarly good environment for Python development at home, so I decided to
document it for myself and others :)

## Install all the packages

Note: I'm using `pip3` to install packages because I'm running on Mac OS, but if
you're running on Linux I'd recommend using packages provided by your
distribution.

```shell
pip3 install lxml mock mutmut mypy pudb pyfakefs pylint pytest pytest-cov
```

See [Upgrading packages installed with pip3 is troublesome]({{< relref
"#upgrading-packages-installed-with-pip3-is-troublesome" >}}) for
how I upgrade packages.

## Testing

I use [pytest](https://docs.pytest.org/) for running tests and
[pytest-cov](https://pypi.python.org/pypi/pytest-cov) to get test coverage so I
can figure out which parts of my code still need to be tested.

```shell
cd test-directory
pytest
```


### Test coverage

To enable test coverage, create `pytest.ini` in the directory containing your
tests, with contents like
<https://github.com/tobinjt/bin/blob/master/python/pytest.ini>.  Every time your
tests are run successfully coverage will be generated and a message will be
printed showing the coverage percentage.

I found that test coverage needed quite a bit of configuration through the file
`.coveragerc` in the directory containing your tests; my final contents are
<https://github.com/tobinjt/bin/blob/master/python/.coveragerc>.  I highly
recommend configuring testing to fail if there is insufficient coverage.  You
can also configure a HTML output directory so that you can easily see which
lines of code you haven't tested.

### Integration tests.

I'm a fan of integration tests, where instead of testing individual functions
you test large swathes of code at a time.  I take the approach of picking a
piece of functionality that should be supported, then writing a test to exercise
that functionality end to end.

<https://github.com/tobinjt/bin/blob/master/python/linkdirs_test.py#L38> is a
good example of this, where I test progressively more complex use cases and
scenarios by:

1. Populating a fake filesystem (`pyfakefs` is great for this) with the scenario
   to deal with.
1. Calling `main()` with the right arguments.
1. Checking that the resulting filesystem is correct.

This was particularly reassuring when I added deletion to `linkdirs.py` :)

## Linting

I use [pylint](https://www.pylint.org/) for linting.  I have [configured
Syntastic and Vim]({{< relref "#vim-configuration" >}}) to run `pylint`
automatically on saving.

```shell
pylint *.py
```

<https://github.com/tobinjt/dotfiles/blob/master/.pylintrc> is my
`$HOME/.pylintrc`.

## Type checking

I use [`mypy`](https://mypy.readthedocs.io/en/latest/index.html) for checking
type annotations, which gives me more confidence that I'm passing the right type
of data to functions, and helps document my code - particularly when I use type
aliases to give meaningful names to parameter types.  I have [configured
Syntastic and Vim]({{< relref "#vim-configuration" >}}) to run `mypy`
automatically on saving.

```shell
mypy *.py
```

<https://github.com/tobinjt/dotfiles/blob/master/.mypy.ini> is my
`$HOME/.mypy.ini`.

## Debugging

I've started using [pudb](https://documen.tician.de/pudb/index.html) for
debugging because it presents so much more information at once.  I recently
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
I found annoying because it clutters up your source directory.  I disabled that
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
doesn't have a way to upgrade all packages.  Upgrading all packages *can* be
done with a shell one-liner, except that it doesn't take dependencies into
account, so you might upgrade a dependency to a version that breaks a package
you care about :(

If you keep track of the packages you've installed, you can upgrade them with
`pip3 install --upgrade pkg1 pkg2 ...`.  Keeping track of which packages I need
also lets me use the *nuke it from orbit* approach: remove the `site-packages`
directory, reinstall Python, and reinstall the packages I need.  I do this once
a month because frequent updates make it far easier to figure out breakages, so
I've written <https://github.com/tobinjt/bin/blob/master/update-python-modules>
to make it a single command.  This approach is probably overkill, but I'd prefer
overkill than debugging a failed upgrade.

## Vim configuration

I don't have much configuration for Python:

*   Make sure that [syntastic](https://github.com/vim-syntastic/syntastic) uses
    Python 3 so type annotations can be parsed:

    ```vim
    let g:syntastic_python_python_exec = 'python3'
    ```

*   Configure [syntastic](https://github.com/vim-syntastic/syntastic) to use
    `mypy` too:

    ```vim
    let g:syntastic_python_checkers = ['python', 'mypy', 'pylint']
    ```
