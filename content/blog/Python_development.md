+++
date = 2017-09-16T21:55:16+01:00
title = 'Python development'
tags = ['Python', 'programming']
+++

Normally I do Python development in work, where everything is already set up for
easy development and testing.  Recently I did some Python development at home,
so I had to figure out how to do it, and here's what I came up with.

Note: I'm using `pip` to install packages because I'm running on Mac OS, but if
you're running on Linux I'd recommend using packages provided by your
distribution.

## Testing

I use [`pytest`](https://docs.pytest.org/) for running tests and
[`pytest-cov`](https://pypi.python.org/pypi/pytest-cov) to
get test coverage so I can figure out which parts of my code still need to be
tested.

`$ pip install pytest pytest-cov`

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

I use [`pylint`](https://www.pylint.org/) for linting.

`$ pip install pylint`

To configure linting, create `$HOME/.pylintrc` with contents like
<https://github.com/tobinjt/dotfiles/blob/master/.pylintrc>.

To check files run `pylint *.py`.

## Misc

### Stop generating `.pyc` files

By default, Python will write compiled bytecode for `foo.py` to `foo.pyc`, which
I found annoying.  Disabled that by setting the environment variable
`PYTHONDONTWRITEBYTECODE`, e.g.:

`$ export PYTHONDONTWRITEBYTECODE="No .pyc files please"`

### Upgrading packages installed with `pip` is troublesome

`pip` doesn't track requested packages vs auto-installed packages, and doesn't
have a way to upgrade all packages.  Doing that is a shell one-liner, except
that it doesn't take dependencies into account, so you might upgrade a
dependency to a version that breaks a package you care about :(

The only way I've found to upgrade packages with `pip` is to keep track of the
ones you've installed, then upgrade them with `pip install --upgrade pkg1 pkg2
...`.
