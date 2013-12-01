lisp-moochine
=============

A Lisp interpreter written in MOO code. Hosted on LambdaMOO, as object #83882.
You should be able to port it to your own MOO easily enough: the only external
objects it depends on are $list_utils and $string_utils.

It's got lexical scope, lambdas, and simple arithmatic right now. Eventually it
will get MOO interop - so you can program your MOO objects with glorious LISP-y
syntax!

```You feed a punch-card that says (((lambda (f)
((lambda (x) (f (x x))) (lambda (x) (f (lambda (y)
((x x) y)))))) (lambda (f) (lambda (n) (if (= n 0)
1 (* n (f (- n 1))))))) 5) into the Lisp Machine.

The Lisp Machine spits out a new punch-card that
says 120.
```
