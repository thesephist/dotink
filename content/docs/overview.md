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

## A brief tour of Ink

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

You'll notice here hat Ink comments are demarcated with backticks. This is Ink's multiline comment. You can also prepend two backticks to the start of a line to comment just the line.

Ink supports the basic arithmetic operations using infix operators, and more advanced functions using builtin native functions.

```
(1 + 2 * 3 / 4) + ~5 % 7 `` -> 1.78571429

pow(2, 10) `` -> 1024

t := 0.6 `` define t to be 0.6
pow(sin(t), 2) + pow(cos(t), 2) `` -> 1
```

// strings

// functions, and recursion

// composite literals

// stdlib, incl. read more

## Security and permissions model

One of Ink's more interesting features is that we can run an Ink program and selectively restrict the running program's permissions.

// TODO
