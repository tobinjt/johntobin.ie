+++
lastmod = 2010-02-17T18:20:31+00:00
title = 'I need a better LISP book'
tags = ['LISP', 'programming']
+++

I've been learning LISP from
[LISP](https://www.amazon.co.uk/LISP-Patrick-Winston/dp/0201083191/), and
solving problems from [Project Euler](https://projecteuler.net/) in LISP. Once
you solve a problem, you gain access to the forum thread about that problem.
After I solved Project Euler 10, I read someone else's LISP solution; it was
quite different to mine, and contained some LISP constructs I hadn't seen
before, e.g.

```lisp
(defun seq-list (min max)
  (loop for i from min to max collect i)
)
```

I'd have written that like so:

```lisp
(defun seq-list (lower-bound upper-bound)
  (let
    (
      (current-number lower-bound)
      (result '())
    )

    (loop
      (when (> current-number upper-bound)
        (return result)
      )
      (setf result (append result (list current-number)))
      (setf current-number (1+ current-number))
    )
  )
)
```

That's 16 lines of code versus 3 lines of code. OK, I could knock at least 6
lines off mine by squishing closing parentheses onto earlier lines, but that's
ignoring the real problem: his code is simple and clear, whereas my code is all
tangled up in the mechanics of declaring local variables, looping, and updating
the list. A programmer who didn't know LISP would probably understand his code,
but wouldn't have a clue what mine is doing.

I didn't remember seeing syntax like that when reading the section on `(loop)`
in my book, so I checked it out: it has nothing like that. There's also nothing
about `(collect)` in the index. I need to learn from a book that covers all of
LISP, so that I can reasonably expect to understand other people's code. I know
that I'm writing baby-LISP (cute and helpless) at the moment, but I want to
progress on to child-LISP (enthusiastic and energetic), teenage-LISP (angsty and
rebellious), and finally adult-LISP (uh, serious and . . . my analogy has run
out of steam). I don't think there's any point in learning from an incomplete
textbook, because later I'll need to start at the beginning of another textbook
anyway. I'm putting Project Euler on hold until I find a better book; I might
even redo some of the problems I've already solved.
