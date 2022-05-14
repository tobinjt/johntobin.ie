+++
lastmod = 2009-12-14T00:54:32+00:00
title = 'Learning LISP'
tags = ['LISP', 'programming']
+++

I first thought about learning LISP when I was still an undergrad, but I was
stymied by Real Life and a lack of material to learn from. Shortly before I
submitted my MSc thesis I picked up two LISP books -
[LISP](https://www.amazon.co.uk/LISP-Patrick-Winston/dp/0201083191/) and [On
LISP: Advanced Techniques for Common
LISP](https://www.amazon.co.uk/LISP-Advanced-Techniques-Common/dp/0130305529/) -
but my MSc was taking up all my time, so I put them on a shelf and forgot about
them. About a month ago, I read [Recursive Functions of Symbolic Expressions and
their Computation by Machine (Part
I)](http://jmc.stanford.edu/articles/recursive.html), the original paper about
LISP. It's very clearly written, and explains the design of LISP so well (in
only 34 pages) that someone could make a reasonable attempt at implementing LISP
based solely on reading it. Inspired by the paper, I dug out my books and
started learning LISP; I've now reached a point where the solutions to some
exercises are interesting enough to post.

---

Problem 5-3: Now write a pair of procedures KEEP-FIRST-N-CLEVERLY and
KEEP-FIRST-N-CLEVERLY-AUX, that together make a list of the first _n_ elements
in a list. Be sure that KEEP-FIRST-N-CLEVERLY-AUX is tail recursive.

My solution:

```lisp
(defun keep-first-n-cleverly (n alist)
  (keep-first-n-cleverly-aux n alist nil)
)

(defun keep-first-n-cleverly-aux (n alist newlist)
  (if (zerop n)
    newlist
    (keep-first-n-cleverly-aux
      (- n 1)
      (rest alist)
      (append newlist (list (first alist)))
    )
  )
)
```

I like tail recursion: lots of problems are simpler to solve recursively, and
knowing that a tail recursive call will be optimised to a goto satisfies the
part of my mind that thinks "What if my function is run on a list with 1000
elements? Would I be better writing it iteratively, so that it doesn't run out
of stack space?".

---

Problem 5-9: Define SQUASH, a procedure that takes an expression as its argument
and returns a non-nested list of all atoms found in the expression. Here is an
example:

```lisp
* (squash '(a (a (a (a b))) (((a b) b) b) b))
(A A A A B A B B B B)
```

Essentially, this procedure explores the fringe of the tree represented by the
list given as its argument, and returns a list of all the leaves.

My solution:

```lisp
(defun squash (alist)
  (cond
    ((null alist) nil)
    ((atom alist) (list alist))
    (t (append
         (squash (first alist))
         (squash (rest alist))
       )
    )
  )
)
```

---

Problem 5-12: The version of Fibonacci we have already exhibited is inefficient
beyond comparison. Many computations are repeated. Write a version with optional
parameters that does not have this flaw. Think of working forward from the first
month rather than backward from the nth month.

My solution:

```lisp
(defun fib (n &optional (count 2) (fibn-2 0) (fibn-1 1))
  (case n
    (0 0)
    (1 1)
    (otherwise
      (if
        (equal n count)
        (+ fibn-2 fibn-1)
        (fib n (+ count 1) fibn-1 (+ fibn-2 fibn-1))
      )
    )
  )
)
```

The point of this exercise was to use optional parameters; if I was writing
`fib()` for real, I would use an auxiliary procedure, like this:

```lisp
(defun fib (n)
  (case n
    (0 0)
    (1 1)
    (otherwise (fib-aux n 2 0 1))
  )
)
(defun fib-aux (n num-calculated fibn-2 fibn-1)
  (if (equal n num-calculated)
    (+ fibn-2 fibn-1)
    (fib-aux n (+ num-calculated 1) fibn-1 (+ fibn-2 fibn-1))
  )
)
```

My first inclination when writing a Fibonacci function is to use
[Memoization](https://en.wikipedia.org/wiki/Memoization); if I was writing it in
Perl I would use the standard module
[Memoize](https://metacpan.org/pod/release/MJD/Memoize-1.01/Memoize.pm), where
Fibonacci is presented as an example in the documentation. I don't know yet how
hard it would be to do this in LISP, but I expect that closures should be easy
enough.
