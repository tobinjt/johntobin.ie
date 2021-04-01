+++
date = 2019-01-14T20:29:52Z
title = "PHP development"
tags = ['PHP', 'programming', 'website', 'Wordpress']
+++

I wrote and maintain [the theme](https://github.com/tobinjt/ariane-theme) for
[my wife's website](https://www.arianetobin.ie/). When working on it in the past
I've been under time pressure because the [Craft
Fair](http://www.giftedfair.ie/) was close, so I haven't kept the code to my
usual standards. Over the past year I've been improving my processes, e.g.
[Populating dev website from production
website](/blog/populating_dev_website_from_production_website/), and more
recently I've been improving the code by breaking the monolithic `functions.php`
into [separate files](https://github.com/tobinjt/ariane-theme/tree/master/src)
and writing [tests](https://github.com/tobinjt/ariane-theme/tree/master/tests).
`functions.php` still exists, but it's now [149 lines
long](https://github.com/tobinjt/ariane-theme/blob/b7f481a3d4d988f055493fb73b15830e4b6fb025/functions.php)
rather than [1227 lines
long](https://github.com/tobinjt/ariane-theme/blob/4ad3e162332f156241a0190bf5f360e1c75692b6/functions.php)!

For testing I'm using [PHPUnit](https://phpunit.de/) with
[CodeCoverage](https://github.com/sebastianbergmann/php-code-coverage) enabled;
I've been able to achieve 100% test coverage (excluding `functions.php` which is
now mostly configuration rather than code), and along the way I've improved and
cleaned up the code significantly. The other PHP files in the theme are used
automatically by Wordpress to display content of different types and have very
little logic in them, so I don't feel they are worth testing and testing would
require faking lots of Wordpress functions. I created a [phpunit.xml config
file](https://github.com/tobinjt/ariane-theme/blob/master/phpunit.xml) using
`phpunit --generate-configuration` plus editing so that I don't have to keep
supplying command line flags. I wrote some test helpers and fakes (e.g.
[FakeWordpress.php](https://github.com/tobinjt/ariane-theme/blob/master/src/FakeWordpress.php));
I put them in `src/` rather than `test/` so code coverage would be measured for
them - this gives me an easy way to spot unused code in test helpers that I can
delete.

Breaking up `functions.php` into separate files has had multiple benefits:

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

I tried [PHPLint](https://www.icosaedro.it/phplint/) because I'm a big fan of
linters and style guides. I found it very, very restrictive - there is no way to
suppress a warning, and the type annotations are intrusive. The biggest benefit
I got from it is that I defined proper classes for holding data; for years I had
followed the Wordpress approach of stuffing everything into an array, but the
many complaints from PHPLint convinced me to define properly structured classes
instead. Sadly I got there the long way and made lots of intermediate changes :(
Several problems still stand out with PHPLint:

1.  There is no way to suppress warnings, see
    https://www.icosaedro.it/phplint/FAQ.html#H14_Can_I_turn_off_some_boring_error_PHPLint_signals?
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
    program](https://github.com/tobinjt/ariane-theme/blob/master/src/phplint-wrapper)
    and a
    [Makefile](https://github.com/tobinjt/ariane-theme/blob/master/src/Makefile)
    to make usage easier.
1.  The module declaration files use a slightly modified version of PHP function
    declarations, so I needed to generate some of the module definitions.
1.  PHPLint interprets `cast(type, variable)` to cast a variable to a different
    type. I didn't want to include the PHPLint libraries so I wrote [a fake
    version](https://github.com/tobinjt/ariane-theme/blob/master/src/Cast.php).
1.  PHPLint has been broken far more often than it has been working, though it's
    definitely possible that this is a problem with Homebrew packaging rather
    than PHPLint.

Overall I think PHPLint is too difficult and intrusive to be worthwhile, though
I might feel differently if I had jumped directly to defining my own data
structures. I got maybe 20% of the benefit I needed to justify the effort I put
into it.

I used [PHP Coding Standards Fixer](http://cs.symfony.com/) to automatically fix
some things that a linter would complain about. When I enabled the large sets of
rules like `@PhpCsFixer` I was unhappy with the output, e.g. multi-line arrays
and function calls had their indentation removed, which I strongly dislike. I
read through the [docs](http://cs.symfony.com/#usage) and picked out the rules I
agreed with, put them in a [.php_cs.dist config
file](https://github.com/tobinjt/ariane-theme/blob/master/.php_cs.dist), and
enabled them one at a time to make small related changes I could easily review
rather than one giant commit. Having tests made me confident that the tool
hadn't broken my code with the changes - yay for the tests! I'll probably test
out more of the rules in future, but an evening's work has already gotten me
good benefits so I'm happy with the investment of time. There are many different
style guides for PHP that seldom agree, so this is an area for future
investigation.

I installed everything I needed on my laptop with these commands:

```shell
brew install phplint phpunit php-cs-fixer
pecl install xdebug
```
