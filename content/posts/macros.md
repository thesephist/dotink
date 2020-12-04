---
title: "Macro elegance: the magical simplicity of Lisp macros"
date: 2020-12-03T08:33:42-05:00
toc: true
---

Lisp is a [homoiconic](https://en.wikipedia.org/wiki/Homoiconicity) programming language -- Lisp program source code is also a first-class data structure in Lisp, made of nested lists of symbols. This allows Lisp programs to define and use really elegant macros, pieces of syntax defined in the Lisp program itself. For example, in most Lisps, then `when` form

```
(when (some-condition)
  (do-something))
```

isn't built into the language itself, but rather defined as a macro in a library. Usually, this expands to

```
(if (some-condition)
  (do-something)
  ()) ; no-op
```

Because Lisp syntax is extremely simple, Lisp macros can be as expressive as the situation requires, going from simple fill-in-the-blank substitution, as in the `when` macro above, to something more sophisticated like pattern matching or threading. As I dive further into programming in Clojure and Klisp, I've been really enjoying writing and using a handful of really elegant macros to express ideas in my programs that, in other languages, would require new language features or even new programming paradigms.

I want to briefly explain in this post how Lisp macros (specifically macros in Klisp) work, and discuss some macros I find particularly elegant. If you're familiar with Lisp macros already, feel free to skip this very next section and go straight to [Macro elegance](#macro-elegance).

## Lisp macro 101

Lisp programs are lists of _atoms_, where an atom is some indivisible unit of syntax, like a literal value or a variable name ("symbol"). A complex Lisp program is made up of many lists nested inside each other. Here's a function definition, for example.

```
   ______ atoms _____
  /       |   |  \ \ \
(defn double (x) (* 2 x))
|            | | |     ||
|           list \-list/|
|                       |
\---- list -------------/
```

Conveniently, lists are also a fundamental data structure in Lisp. This makes it easy for Lisp programs to manipulate other Lisp programs! For example, we could imagine a Lisp program that takes another Lisp program and simply prints it twice, resulting in a program that does everything in the original program twice.

In Klisp (and most Lisps), we can define functions that operate on its inputs as bits of syntax, rather than as the evaluated values. We call these functions-on-syntax _macros_.

When the Lisp evaluator comes across a macro invocation, rather than evaluating its arguments and passing them to the macro as if evaluating a function call, the evaluator simply takes the raw syntax of the arguments and passes it as a list to the called macro. When the macro returns some transformed bit of syntax as the output, the evaluator runs _that_ instead. In other words, functions take values, and return values, while macros take program syntax, and return other program syntax.

The `when` macro from the top of this post is [defined in Klisp](https://github.com/thesephist/klisp/blob/main/lib/klisp.klisp) as

```
(def when
     (macro (terms)
            (list ,if (car terms) (cadr terms) ())))
```

In other words, it takes `terms`, a list of argument expressions like `(some-condition do-something)`, and return us a new `list` for Klisp to evaluate, namely

```
(if some-condition
  do-something
  ())
```

Working this way, Lisp macros allow us to write functions _over language syntax_ the way conventional functions work _over data_ in a running program. Macros allow us to **build abstractions over our vocabulary as programmers**, not just abstractions over runtime data. While functions add functionality, macros add expressiveness.

## Macro elegance

The `when` macro is a pretty simple, primitive macro, but because macros are really just full-fledged functions, Lisp macros can be arbitrarily complex and sophisticated. Although there are many dialects of Lisp, many of them share a common set of the most useful and elegant macros, some of which I want to tell you about below.

I'll be demonstrating these macros in the context of [Klisp](/posts/klisp/), a Lisp dialect written in Ink, but I'll describe the macros at a more general level, too, and note where the behavior is similar or different in other Lisp dialects like Scheme, Clojure, and Common Lisp.

### Conditional macros `cond` and `match`

Klisp, like most Lisps, comes with one primitive for conditional evaluation: `if`. But when writing real programs, we often need to choose between not one or the other option, but between multiple options depending on some set of conditions.

The `cond` and `match` macros make this trivial. Rather than chaining `if` calls all the way down, we can describe conditions that could be met, and what to do if any are true. For example, a basic FizzBuzz program could be written:

```
(defn fizzbuzz (n)
  (each (nat n)
        (fn (i)
            (cond
              ((divisible? i 15)
               (println 'FizzBuzz'))
              ((divisible? i 3)
               (println 'Fizz'))
              ((divisible? i 5)
               (println 'Buzz'))
              (true (println i))))))
```

Similarly, the `match` macro allows us to take different actions depending on the value of some target variable, like a switch case.

```
; The Fibonacci sequence
(defn fib (n)
  (match n
    (0 1)
    (1 1)
    (n (+ (fib (- n 1))
          (fib (- n 2))))))

(map (seq 10) fib)
; => (1 1 2 3 5 8 13 21 34 55)
```

The great thing about both of these abstractions over control flow is that they're both composed of the basic `if` under the hood. The `match` macro in the Fibonacci function, for example, expands out the function to

```
(defn fib-expanded (n)
  (if (= n 0)
    1
    (if (= n 1)
      1
      (if (= n n)
        (+ (fib (- n 1))
           (fib (- n 2)))))))
```

In most other languages, switch cases and pattern matching expressions are baked into the language. They are defined into the language syntax and semantics, adding to all the other things to learn about a particular language. In Lisps, these kinds of control-flow constructs can be defined _in the language_, which is pretty cool.

In other Lisp dialects used in production like Clojure and Common Lisp, similar macros like `cond` exist, with added capabilities. For example, some versions of `cond` support a "default" case to execute if no other conditions match, and Clojure's pattern-matching macro can destructure and compare parts of values, rather than just the whole.

This is what I mean by _abstraction over syntax_. The two versions of `fib` above fundamentally do the same thing, but one is much easier to read, because it's closer to the way we think as humans about the problem. The `match` macro allows us to write programs closer to humans, with the macro bridging the abstraction gap.

### Partial application with the `partial` macro

Macros can also be useful for expressing common patterns more concisely. The `partial` macro for partial function application is a great example of this.

Let's say we have a list of numbers, and want to generate a list of their squares. To do this we need to pass to `map` some function that squares its argument. One way we could write this is

```
(map (list 1 2 3 4 5)
     (fn (n) (* n n)))
```

In functional Lisp code, we often write lots of small functions to pass to other higher-order functions. Writing `(fn (x) (...))` every time we need a small function gets tedious quickly, and the `partial` macro allows us to write a function as a _partially applied_ version of another function. The `partial` macro will create a function, where any `_` (underscore) slots in the given body will be replaced with the function's argument.

Using this macro, we can rewrite the above as

```
(map (list 1 2 3 4 5)
     (partial (* _ _)))
```

While this square-the-input function is small enough that this makes little difference, more complex functions are often more concisely or clearly represented as partial applications, than as anonymous functions using random one-time-use variables.

In some Lisps, like [Clojure](https://clojure.org/guides/weird_characters#_anonymous_function), partial application like this is baked into the reader (syntax), making it even more concise and idiomatic in the language. In Clojure, you might write this same program as

```
(map #(* % %)
     (list 1 2 3 4 5))
```

### Threading macros, `->` and `->>`

Threading macros are my favorite bit of syntax in Lisp, because it makes my code cleaner to read, easier to write, and more visually aesthetic, all in one stroke.

To understand threading macros, we need to understand _pipelines_.

A pipeline describes a program where some data flows through a sequence of functions in order, resulting in some final result in the end. For example, you may have run a command in your shell like

```
ls | grep 'report' | xargs cat | wc -l
```

This small program takes files in a directory (`ls`), filters out the ones that don't contain `report` in the name (`grep`), reads all their contents (`xargs cat`), and counts the total number of lines (`wc -l`). This is a _pipeline_, where each step modifies or acts on the data from some previous step in some way.

Threading macros allow us to write Lisp programs similarly, as a pipeline of some data traveling through a sequence of functions acting on it.

For example, this pipeline in Klisp generates a list of numbers 1-100, filters for just the prime numbers, and counts then with `size`.

```
(-> (nat 1000)
    (filter prime?)
    size)

; => 168
```

This macro `->`, called thread-first, expands this program out to

```
(size (filter (nat 1000) prime?))
```

Both programs perform the same task, but depending on the nature of a problem, it may be easier for us (humans) to think of the solution as "threading" the value `(nat 1000)` "through" a pipeline of functions, rather than as a single nested call to the same functions.

The thread-first macro `->` has a complement in Klisp, called thread-last (`->>`). The two macros differ only in that `->` places the previous step as the _first_ argument to each next step, and `->>` puts the last step as the _last_ argument in the next step. Because data usually comes first in Klisp functions, `->` is used more often. But in Clojure, for example, where data usually comes last in the argument list, `->>` is more common. Clojure also features a much broader set of useful threading macros than Klisp, as outlined [in this threading macros guide](https://clojure.org/guides/threading_macros).

## Programming our vocabulary

The magical simplicity of Lisp macros is that Lisp macros are not very special at all -- they're just functions, operating on bits of syntax just as normal functions operate on data. But because of the syntactic simplicity of Lisps, macros allow us to very easily _program the vocabulary we use to write other programs_ the same way we program the data we work with.

Like any new magical power, Lisp macros are best used with discretion. A codebase littered with custom macros, like a [story written mostly with made-up words](https://en.wikipedia.org/wiki/Jabberwocky), is more art than software. But if used judiciously, I think macros can give us a new appreciation for the [strange, boundless machine](https://thesephist.com/posts/software/) that we call software hiding in our computers.

