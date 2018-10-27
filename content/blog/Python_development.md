+++
date = 2018-10-16T22:58:16-04:00
title = 'Python development'
tags = ['Python', 'programming', 'testing']
+++

Normally I do Python development in work, where everything is already set up for
easy development and testing.  Recently I did some Python development at home,
so I had to figure out how to do it, and here's what I came up with.

Note: I'm using `pip` to install packages because I'm running on Mac OS, but if
you're running on Linux I'd recommend using packages provided by your
distribution.

## Testing

I use [pytest](https://docs.pytest.org/) for running tests and
[pytest-cov](https://pypi.python.org/pypi/pytest-cov) to get test coverage so I
can figure out which parts of my code still need to be tested.

```shell
$ pip install pytest pytest-cov
```

To run your tests simply run `pytest` in the directory containing the tests.

### Test coverage

To enable test coverage, create `pytest.ini` in the directory containing your
tests, with contents like
<https://github.com/tobinjt/bin/blob/master/python/pytest.ini>.  Every time you
run successfully run tests coverage will be generated.

I found that test coverage needed quite a bit of configuration; create
`.coveragerc` in the directory containing your tests, with contents like
<https://github.com/tobinjt/bin/blob/master/python/.coveragerc>.  In particular,
you can configure testing to fail if there is insufficient coverage, something I
highly recommend.

### Integration tests.

Unit tests are useful, but I'm a much bigger fan of integration tests, where
instead of testing individual functions you test large swathes of code at a
time.  I take the approach of picking a piece of functionality that should be
supported, then writing a test to exercise that functionality.
<https://github.com/tobinjt/bin/blob/master/python/linkdirs_test.py#L38> is a
good example of this: I test progressively more complex use cases and scenarios,
by:

1. Populating a fake filesystem (`pyfakefs` is great for this) with the scenario
   to deal with.
1. Calling `main()` with the right arguments.
1. Checking that the resulting filesystem is correct.

This was particularly reassuring when I added deletion to `linkdirs.py` :)

## Linting

I use [pylint](https://www.pylint.org/) for linting.

```shell
$ pip install pylint
```

To configure `pylint`, create `$HOME/.pylintrc` with contents like
<https://github.com/tobinjt/dotfiles/blob/master/.pylintrc>.

To check files run `pylint *.py`.

## Type checking

I use [`mypy`](https://mypy.readthedocs.io/en/latest/index.html) for checking
type annotations, which gives me more confidence and helps document my code,
particularly when I use type aliases to give meaningful names to parameter
types.

```shell
$ pip install mypy
```

To configure `mypy`, create `$HOME/.pylintrc` with contents like
<https://github.com/tobinjt/dotfiles/blob/master/.mypy.ini>.

To check files run `mypy *.py`.

## Misc

### Stop generating `.pyc` files

By default, Python will write compiled bytecode for `foo.py` to `foo.pyc`, which
I found annoying.  Disable that by setting the environment variable
`PYTHONDONTWRITEBYTECODE`, e.g.:

```shell
$ export PYTHONDONTWRITEBYTECODE="No .pyc files please"
```

### Upgrading packages installed with `pip` is troublesome

`pip` doesn't track manually installed packages vs auto-installed packages, and
doesn't have a way to upgrade all packages.  Upgrading all packages can be done
with a shell one-liner, except that it doesn't take dependencies into account,
so you might upgrade a dependency to a version that breaks a package you care
about :(

The only way I've found to upgrade packages with `pip` is to keep track of the
ones you've installed, then upgrade them with `pip install --upgrade pkg1 pkg2
...`.  Keeping track of which packages I need also lets me use the *nuke it from
orbit* approach: remove the `site-packages` directory, reinstall Python, and
reinstall the packages I need.  Thankfully I don't need to do this often.

### Vim configuration

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
