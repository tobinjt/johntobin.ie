+++
date = 2021-09-08T22:20:53+01:00
title = "Automatically running tests, linters, or anything"
tags = ['development', 'programming', 'shell', 'testing']
+++

In work we have tooling that automatically runs tests when you save a file from
your editor, saving you from pressing `up arrow, return` to run them manually.
I decided to implement that for use when I'm coding in my own time:
[inotify_wrapper](https://github.com/tobinjt/bin/blob/master/inotify_wrapper).

Usage is straightforward:

```
Watch the specified files and run the binary when they change.
Usage: inotify_wrapper file1 [file2 ...] -- binary [args ...]
Files will not be passed to the binary, the caller needs to do that if
required.
```

E.g. run Golang tests whenever `*.go` changes: `inotify_wrapper *.go -- go test`

I also wrote several wrappers for even easier use:

- [igocover](https://github.com/tobinjt/bin/blob/master/igocover): Golang
  coverage
- [igotest](https://github.com/tobinjt/bin/blob/master/igotest): Golang tests
- [iphpunit](https://github.com/tobinjt/bin/blob/master/iphpunit): PHP tests
- [ipylint](https://github.com/tobinjt/bin/blob/master/ipylint): Python lint
- [ipytest](https://github.com/tobinjt/bin/blob/master/ipytest): Python coverage

The tooling is very simple - watch files, run binary - so you can wrap anything,
e.g. for C programming it would be `inotify_wrapper *.c *.h -- make`, for
LaTeX it would be `inotify_wrapper *.tex -- latex main.tex`, and so on.
