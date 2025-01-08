+++
title = "PHP development"
lastmod = 2025-01-08T22:05:50+01:00
tags = ['PHP', 'programming', 'website', 'Wordpress']
+++

I wrote and maintain [the theme](https://github.com/tobinjt/ariane-theme) for
[my wife's website](https://www.arianetobin.ie/).

I installed everything I used on my laptop with these commands:

```shell
brew install composer php php-code-sniffer php-cs-fixer phplint phpmd phpstan \
    phpunit
composer require nunomaduro/phpinsights --dev
pecl install xdebug
```

## Testing

For testing I'm using [PHPUnit](https://phpunit.de/index.html) with
[CodeCoverage](https://github.com/sebastianbergmann/php-code-coverage) enabled
(code coverage also requires [Xdebug](https://xdebug.org/)); I've been able to
achieve near 100% test coverage (excluding `functions.php` which is now mostly
configuration rather than code), and along the way I've improved and cleaned up
the code significantly. The other PHP files in the theme are used automatically
by Wordpress to display content of different types and have very little logic in
them, so I don't feel they are worth testing and testing would require faking
lots of Wordpress functions.

I created a [phpunit.xml config
file](https://github.com/tobinjt/ariane-theme/blob/master/phpunit-10.xml) using
`phpunit --generate-configuration` plus editing so that I don't have to keep
supplying command line flags. Note that PHPUnit 9 and 10 have incompatible
config files: although PHPUnit 10 will accept a config from PHPUnit 9, it will
exit unsuccessfully, making it impossible to use in a
[pre-commit](https://www.johntobin.ie/blog/git-pre-commits/), so I have checked
in both configs and symlink the correct one in each checkout.

I wrote some test helpers and fakes (e.g.
[FakeWordpress.php](https://github.com/tobinjt/ariane-theme/blob/master/src/FakeWordpress.php));
I put them in `src/` rather than `test/` so code coverage would be measured for
them - this gives me an easy way to spot unused code in test helpers that I can
delete.

## Linting

Beware: there are many different style guides for PHP that seldom agree, so
different tools might disagree over how your code should be formatted.

### PHPLint

Note: development of PHPLint seems to have stopped in 2020, and it refers to
supporting PHP 5 and PHP 7, which is not encouraging.  I would not recommend
PHPLint now, I suggest trying [PHPStan](https://phpstan.org/) or [PHP
Insights](https://github.com/nunomaduro/phpinsights), both briefly described
below.

I tried [PHPLint](https://www.icosaedro.it/phplint/) because I'm a big fan of
linters and style guides. I found it very, very restrictive - there is no way to
suppress a warning, and its custom type annotations are intrusive. The biggest
benefit I got from it is that I defined proper classes for holding data; for
years I had followed the Wordpress approach of stuffing everything into an
array, but the many complaints from PHPLint convinced me to define properly
structured classes instead. Sadly I got there the long way and made lots of
intermediate changes :( Several problems still stand out with PHPLint:

1.  There is no way to suppress warnings, see
    <https://www.icosaedro.it/phplint/FAQ.html#H14_Can_I_turn_off_some_boring_error_PHPLint_signals?>

1.  You need to add metadata to every file declaring which libraries are used by
    that file. I understand that for external libraries or optional libraries,
    but it's silly to have to write `/*. require_module 'core'; .*/` to tell
    PHPLint that core PHP functions will be used in this file. You can include a
    bigger set of modules, but then PHPLint will complain that you included
    unnecessary modules.

1.  PHPLint doesn't support multiple module directory paths, so you either need
    to copy definitions for external libraries into the system path, or
    copy/symlink necessary files from the system path into a local directory and
    use `--modules-path` with the local directory; I chose option 2, and I wrote
    [a wrapper
    program](https://github.com/tobinjt/ariane-theme/blob/1c9a08d25a79fd299a1049d3f5497fd7b8ababc8/src/phplint-wrapper)
    and a
    [Makefile](https://github.com/tobinjt/ariane-theme/blob/1c9a08d25a79fd299a1049d3f5497fd7b8ababc8/src/Makefile)
    to make usage easier.

1.  The module declaration files use a slightly modified version of PHP function
    declarations, so I needed to generate some of the module definitions (see
    the [wrapper
    program](https://github.com/tobinjt/ariane-theme/blob/1c9a08d25a79fd299a1049d3f5497fd7b8ababc8/src/phplint-wrapper)).

1.  PHPLint interprets `cast(type, variable)` to cast a variable to a different
    type. I didn't want to include the PHPLint libraries so I wrote [a fake
    version](https://github.com/tobinjt/ariane-theme/blob/cb16b610f821900edc01cc1e1e74ac4ef4fff56e/src/Cast.php).
    This did not work when I added type annotations everywhere, because it works
    on many different types, so I deleted it because by that point I was using
    PHPStan (see below) rather than PHPLint.

1.  PHPLint has been broken far more often than it has been working, though it's
    definitely possible that this is a problem with Homebrew packaging rather
    than PHPLint.

Overall I think PHPLint is too difficult and intrusive to be worthwhile, though
I might feel differently if I had jumped directly to defining my own data
structures. I got maybe 20% of the benefit I needed to justify the effort I put
into it.

### Other checkers

I used [PHPStan](https://phpstan.org/), and it mostly identified missing type
annotations, which were easy to fix so it was a quick return on investment. I
fairly easily reached level 8, but level 9 looked like a lot more work so I
haven't tried to reach that yet. I would recommend PHPStan for sure. I needed to
use [Composer](https://getcomposer.org/) to add PHPUnit as a dependency for
PHPStan to resolve the PHPUnit imports in my tests; `composer require --dev
phpunit/phpunit ^9` was all it took.

I used [PHP Coding Standards Fixer](https://cs.symfony.com/) to automatically
fix some things that a linter would complain about. When I enabled the large
sets of rules like `@PhpCsFixer` I was unhappy with the output, e.g. multi-line
arrays and function calls had their indentation removed, which I strongly
dislike. I read through the [docs](https://cs.symfony.com/#usage) and picked out
the rules I agreed with, put them in a [.php_cs.dist config
file](https://github.com/tobinjt/ariane-theme/blob/master/.php_cs.dist), and
enabled them one at a time to make small related changes I could easily review
rather than one giant commit. Having tests made me confident that the tool
hadn't broken my code with the changes - yay for the tests! I had initially
thought about testing out more of the rules in future, but an evening's work has
already gotten me good benefits, and further work looks like it will have very
diminishing returns, so I'm happy with the investment of time I've made and
probably won't be investing any more.

I used [PHP Insights](https://github.com/nunomaduro/phpinsights), first to
automatically reformat my code and fix lint warnings, and secondly to provide a
list of warnings that I manually fixed.  I recommend running the fixer multiple
times: some of the changes it made will trigger its own lint checks :(  I found
some of the lint checks useful, and some I ignored because the return on
investment for them didn't seem to justify the work required.  I can see myself
using this again in the future.

I tried [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer) but it
produced a huge number of warnings and the documentation about configuring it is
hard to follow, so I quickly gave up on that.

I tried [PHP Mess Detector](https://phpmd.org/) but PHP itself output ~1000
lines of deprecation warnings for the PHP Mess Detector code so I quickly gave
up on that too. I tried it again later and it complained about boolean
parameters and `else` branches on `if` statements, so I quickly gave up on it
again.

## Breaking up `functions.php`

`functions.php` is the Wordpress theme file that most documentation will tell
you to modify, and for several years I put every new function into it, leading
to a mixed up mess of code. Breaking up `functions.php` into separate files
while writing tests has had multiple benefits:

- It's much easier to understand a piece of functionality because all the
  related code is in an individual file rather than jumbled up with lots of
  other code.
- Writing tests was much more satisfactory because I had intermediate targets to
  hit 100% coverage on rather than a single gigantic file where progress would
  be glacially slow. I wouldn't ever get to 100% coverage on `functions.php`
  anyway because too much of it is Wordpress configuration that can't be
  meaningfully tested in isolation.
- I improved the code as I wrote the tests by removing unnecessary code, making
  cleaner interfaces, and breaking spaghetti code down into separate functions.
  This was all easier when working on small piece of functionality than it would
  have been working on everything at once. The code grew in size by
  approximately 200 lines or a factor of 1.158.

`functions.php` still exists, but it's now [148 lines
long](https://github.com/tobinjt/ariane-theme/blob/b7f481a3d4d988f055493fb73b15830e4b6fb025/functions.php)
rather than [1226 lines
long](https://github.com/tobinjt/ariane-theme/blob/4ad3e162332f156241a0190bf5f360e1c75692b6/functions.php)!
