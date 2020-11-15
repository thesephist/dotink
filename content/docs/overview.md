---
title: "An overview of Ink"
brief: A from-scratch introduction to writing Ink programs
toc: true
---

## What's Ink?

Ink is a functional, general-purpose, interpreted scripting language. It's dynamically and strongly typed. Ink programs can be web servers, short scripts, drawing programs, or anything else that interfaces with files and networks. Ink is designed to be minimal and simple, first and foremost.

I made Ink as an experiment to study writing interpreters and compilers in mid-2019. Since then, I've worked on several other related projects in the programming language space, but continue to write programs and apps in Ink in my day to day work. Because the language and runtime is so small, it's easy for me to understand the entire stack and debug Ink programs easily. Because Ink's interpreter is a single static binary that runs across operating systems, deploying Ink programs is also pretty simple.

Ink is inspired primarily by JavaScript, as much in syntax as in semantics. Ink has data structures, lists and maps (called "composite values"), that work very similarly to JavaScript arrays and objects. Ink, like JavaScript, doesn't make a distinction between integer and floating-point numerical values. Most importantly, Ink takes after JavaScript's model of concurrency and asynchrony -- event-driven tasks are scheduled onto a single execution thread in an event loop, and run deterministically.

## Quick start

One of the advantages of a small language is that it's easy to pick up and start using. Ink's interpreter and runtime weighs in at just under 10MB of a static executable, which makes it easy to download and experiment.

### Setup and installation

You can download the Ink interpreter from [the GitHub releases page](https://github.com/thesephist/ink/releases). We current build release versions of Ink for Linux, macOS, Windows, and OpenBSD.

Once you download the executable, mark it as executable if necessary, and try running it with the `--version` flag.

```
$ ./ink --version
ink v0.1.7
```

If you see a version number like above, you're all set. If you want to run Ink without the preceding `./`, add it to your `$PATH` environment variable. For the rest of this guide, we'll assume Ink is in your `$PATH`.

### The repl

If you start the interpreter with no input, an interactive repl will start.

```
$ ink
>
```

At each `> ` prompt, type a new line of an Ink program to evaluate it and see its resulting value. For example, try these inputs

```
$ ink
> 3 + 4
7
> 'Hello ' + 'World!'
'Hello World!'
> acos(0.5)
1.04719755
>
```

### Writing and running programs

Given an Ink program file like `prog.ink`, you can run it with the interpreter with

```
$ ink prog.ink
```

Alternatively, the interpreter will read from `stdin` if exists, and evaluate from the input. So the above is equivalent to

```
$ ink < prog.ink
```

### Editor support

Ink currently has support for two editors, Vim and [Visual Studio Code](/posts/ink-vscode).

**Vim** support is enabled by the [Vim syntax definition file](https://github.com/thesephist/ink/blob/master/utils/ink.vim). Copy the syntax file to `~/.vim/syntax/ink.vim` in your Vim configuration directory to take advantage of the support, and enable it by adding the following line to your `.vimrc` to recognize `.ink` files as Ink programs:

```
autocmd BufNewFile,BufRead *.ink set filetype=ink
```

**Visual Studio Code** support comes from the [ink-vscode extension](https://github.com/thesephist/ink-vscode). The extension includes syntax highlighting for Ink programs within the editor. At time of writing, the extension is not in the Visual Studio Code Marketplace, and needs to be installed from source. You can find instructions on how to do so in the repository linked above.

## A brief tour of Ink

Let's get into the building blocks of Ink programs. If you like to learn from studying short example programs, you might also like [Ink by Example](https://inkbyexample.com/).

### Values and operators

Ink has number, string, boolean, null, and composite values.

```
` numbers `
2, 3.5, ~42, 0.02

` string `
'Hello, World!', ''

` booleans `
true, false

` null `
()

` composites `
[1, 2, 3], {key: 'value'}
```

You'll notice here hat Ink comments are demarcated with backticks. This is Ink's multiline comment. We can also prepend two backticks to the start of a line to comment just the line.

We define variables in Ink with the `:=` assignment operator. The assignment operator binds a value to a variable name (or a composite value's key) in the current scope. Variables in Ink are lexically scoped.

Ink supports the basic arithmetic operations using infix operators, and more advanced functions using builtin native functions. Note that to declare a negative number, Ink uses the negation operator `~` (a tilde) instead of a negative sign.

```
(1 + 2 * 3 / 4) + ~5 % 7 `` -> 1.78571429

pow(2, 10) `` -> 1024

t := 0.6
pow(sin(t), 2) + pow(cos(t), 2) `` -> 1
```

### Logical and bitwise operators

Ink has binary operators `&` (and), `|` (or), and `^` (xor). These operators can be used on booleans, integer values of numbers, and strings to perform binary or bitwise operations. Bitwise operations on byte strings are implemented natively and useful for manipulating large vectors of data at once.

```
`` boolean logic
true & false `` -> false
false ^ true `` -> true

`` bitwise integer operations
15 & 23 `` -> 7
15 | 23 `` -> 31
15 ^ 23 `` -> 24 (15 xor 23)

`` bitwise ops on strings (byte arrays)
'abcd' & 'ABCD' `` -> 'ABCD'
'abcd' | 'ABCD' `` -> 'abcd'
'abcd' ^ 'ABCD' `` -> '    '
`` note: if two string lengths don't match, the shorter
``  string will be zero-extended at the end.
```

### Variables

A variable in Ink can contain any alphanumeric Unicode character, as well as `?`, `!` and `@`. The three last special symbols are conventionally used to indicate special semantics:

- A function `foo?` returns a boolean
- A function `bar!` mutates variables and structures passed into it
- A function or variable `@foo` usually connotes metaprogramming or diagnostic utilities

Also by convention, constants begin with an uppercase letter, and local variables and other functions begin with a lowercase. Ink does not have constants whose immutability is enforced by the interpreter.

### Expressions

We can place multiple Ink expressions in a single line, if separated by a comma. Such an expression just evaluates to the last expression in the list.

```
1 + 2, 3 + 4, 5 * 6 `` -> 30
```

We can also group such a list of expressions into a single expression with parentheses.

```
(1 + 2, 3 + 4)

` equivalent to... `
(
    1 + 2
    3 + 4
) `` -> 7
```

### Strings

Ink supports string values. An Ink string is simply a byte slice, in the style of [Lua](https://www.lua.org/pil/2.4.html), and doesn't know about Unicode. We can construct a string literal by surrounding data ih single quotes, and we can escape single quotes within a string literal with a backslash.

We can access individual characters in a string with the dot `.` operator followed by an index into the string. Since Ink strings are mutable, we can also change sub-slices of a string in the same way by assigning to it.

```
s := 'Hello, World!'

` index into s `
s.0 `` -> 'H'
s.4 `` -> 'o'

` an index out of bounds will return null () `
s.20 `` -> ()

` change substring of s `
s.7 := 'World'
s `` -> 'Hello, World!'

` concatenate strings with the + operator `
t + ', I said.'
s + t `` -> 'Hello, Linus!, I said.'
```

A common idiom to append a string mutably at the end of another string (which is more efficient than concatenating two strings together) is to assign to the index that is the length of a string, `len(s)`.

```
` Append two strings mutably `
s := 'first'
t := 'second'

s.len(s) := t `` -> 'firstsecond'
```

### Match expressions

The match expression is Ink's singular control flow structure, and is an expression followed by the match symbol `::` and a list of clauses in curlybraces.

```
x := false

x :: {
    true -> 'X is true'
    false -> 'X is false'
} `` returns 'X is false'
```

In a match expression, the case clauses are checked from top to bottom, and the first path whose value matches the case is taken. If there are no matches, the expression does nothing.

Both the expression being matched and the individual cases can contain complex expressions, if parenthesized. As a contrived example:

```
(n % 2) :: {
    (0 + 1) -> 'odd'
    (0 + 0) -> 'even'
}
```

Sometimes, we'd like for a match expression to match against one or more particular cases, and then have a "default" or "else" branch that's taken if no other options match. Those cases are matched with an underscore `_`.

```
n :: {
    1 -> 'first'
    2 -> 'second'
    3 -> 'third'
    _ -> 'a lot'
}
```

Ink compares composite values deeply, so we can combine the catchall (underscore) symbol with more complex values to be able to match against some complex cases.

```
response :: {
    {status: 'ok', body: _} -> 'ok response, any body'
    {status: 'error', body: 'unknown'} -> 'error but unknown error'
    {status: 'error', body: _} -> 'any other uncaught error'
    _ -> 'any other cases'
}
```

### Functions, closures, and recursion

We create a new function with the arrow `=>` symbol, and assign it to a variable.

```
add := (a, b) => a + b
```

Here, we create a function that takes two arguments, `a`, and `b`, and performs the expression to the right, which in this case is `a + b`. The expression following the arrow can also be a parenthesized group of expressions:

```
addThree := (a, b, c) => (
    tmp := a + b
    tmp + c
)
```

In situations like this with a grouped expression as the function body, the last expression in the group effectively becomes the "return value" of the function.

Ink functions support [proper tail recursion](https://en.wikipedia.org/wiki/Tail_call), and tail recursion is the conventional and idiomatically way to create loops in Ink programs. For example, a naive fibonacci function looks simple.

```
fib := n => n :: {
	0 -> 0
	1 -> 1
	_ -> fib(n - 1) + fib(n - 2)
}
```

A tail call optimized implementation wraps loop variables into the arguments.

```
fibRec := (n, a, b) => n :: {
    0 -> a
    _ -> fibRec(b, a + b, n - 1)
}

fib := n => fibRec(n, 0, 1)
```

The Ink standard library contains many utility functions that let us use iteration without writing recursive functions ourselves, like `each`, `map`, `reduce`, `range`, and `filter`.

Ink functions are also closures. This means a function can return another function that references the local variables of the original function. As an example, 

```
makeMultiplier := factor => (
    `` return a closure over FACTOR
    n => factor * n
)

multiplier := makeMultiplier(3)
multiplier(2) `` -> 6
```

If we omit the parentheses around the function body, this also leads to an idomatic way to write curried functions.

```
curriedAdd := a => b => a + b

addTwo := curriedAdd(2)

addTwo(3) `` -> 5
addTwo(6) `` -> 8
```

A quirk of Ink's syntax is that function invocation syntax `()` takes precedence over the property-access `.` operator. So to call a function that's a property of an object, rathern than `obj.func()`, which will parse to `obj.(func())`, we should write `(obj.func)()`. This isn't particularly great for ergonomics, I admit. But it hasn't been a great paint point in the kind of idiomatic Ink code I write, which is mostly functional and not object-oriented.

### Composite values

Ink has one kind of a built-in data structure, called the composite value, that does double-duty as a list and a map, depending on usage. List and map forms of composites both have literal syntaxes.

```
list := [1, 2, 3, 4, 5]
map := {
    first: 1
    second: 2
    third: 3
    more: {
        fourth: 4
        fifth: 5
    }
}
```

At runtime, both lists and maps are represented by the same underlying structure, which is a hashmap with string keys. Lists are represented as a map with string keys representing indexes.

We can access and mutate values in lists and objects using the dot `.` operator.

```
list.0 `` -> first item
list.(len(list) - 1) `` -> last item

list.(1 + 2 + 3) `` -> equivalent to list.6

map.('three') := 3

` an identifier directly following . is considered
    a string key of the map value `
map.three `` -> 3
```

As a result of this shared underlying structure, there isn't a built-in way to iterate through a list, except to enumerate all the indexes. There are utility functions to do so in the standard library, such as `each` and `map`.

As with strings, there's a common idom to append new items to the end of a list, using `len(list)`.

```
`` append to the end of LIST
list.len(list) := newItem
```

### Imports and libraries

An Ink program can be distributed across multiple files and folders. To import values defined at the top level scope in another file, we use the `load()` builtin function. `load()` takes the path to another Ink program, minus the `.ink` file extension, and imports all values in that file to the current program, inside a new map.

If we have two files:

```
` a.ink `

myFunc := () => 2 + 3
```

```
` b.ink `

a := load('./a')

a.myFunc `` -> () => 2 + 3
```

## Security and permissions model

One of Ink's more interesting features is that we can run an Ink program and selectively restrict the running program's permissions:

Ink has a very small surface area to interface with the rest of the interpreter and runtime, which is through the list of builtin functions. In an effort to make it safe and easy to run potentially untrusted scripts, the Ink interpreter provides a few flags that determine whether the running Ink program may interface with the operating system in certain ways. Rather than simply fail or error on any restricted interface calls, the runtime will silently ignore the requested action and potentially return empty but valid data.

- `--no-read`: When enabled, the builtin `read()` function will simply return an empty read, as if the file being read was of size 0. `-no-read` also blocks directory traversals.
- `--no-write`: When enabled, the builtins `write()`, `delete()`, and `make()` will pretend to have written the requested data or finished the requested filesystem operations safely, but cause no change.
- `--no-net`: When enabled, the builtin `listen()` function will pretend to have bound to a local network socket, but will not actually bind. The builtin `req()` will also pretend to have sent a valid request, but will do nothing.

To run an Ink program completely untrusted, run `ink --isolate` (with the "isolate" flag), which will revoke all revokable permissions from the running script, except I/O from the standard input and output files.
