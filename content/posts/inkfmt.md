---
title: "inkfmt: a self-hosting tokenizing code formatter for Ink"
date: 2020-07-15T17:15:01-04:00
location: "West Lafayette, IN"
toc: true
---

[inkfmt](https://github.com/thesephist/inkfmt) (pronounced "ink format") is a self-hosting code formatter for the Ink language. That means inkfmt takes valid Ink programs and normalizes the formatting of the code to be readable and clean. inkfmt is itself an Ink program, and inkfmt uses itself to format its source code. (This is the "self-hosting" bit.)

inkfmt isn't perfect yet -- it's a work in progress -- but it currently produces the correct output about 95% of the time with idiomatic Ink code. Code formatters in general are fascinating, and inkfmt specifically was one of the most interesting technical projects I've worked on recently (I had to switch from pen-and-paper to my whiteboard for the first time in a while!), so I wanted to share what I've encountered so far.

![inkfmt screenshot](/img/inkfmt.jpg)

## What's a code formatter?

In the course of programming, we add and remove pieces of text from our program source code many thousands of times. This process of exploration usually also leads to the shape of our program changing over time, as you try to lay out your code in a way that's readable to you, and makes sense to others.

If a team of developers all do this over the same body of source code, you'll often come across changes in code that don't really change what the program does or how it behaves, but changes the layout of the code. Sometimes they're meaningful, but most of the time, these changes like changing the amount of whitespace, re-indenting code, and converting [tabs to spaces](https://www.youtube.com/watch?v=SsoOG6ZeyUI) are more distracting than useful.

A code formatter, sometimes called a "pretty printer", takes a bit of source code and makes small transformations to it to produce a more readable, visually clean version of the same program, and in the process, removes any frivolous changes in whitespace, indentation, and more. It helps team members settle on a single style of code formatting, makes code more readable, and usually saves time, too.

For this reason, most popular languages that emerged in the last decade ship with code formatters. Go popularized this trend with [gofmt](https://golang.org/cmd/gofmt/), Rust has [Rustfmt](https://github.com/rust-lang/rustfmt), Zig has [zig fmt](https://ziglang.org/download/0.6.0/release-notes.html#zig-fmt), and JavaScript is rich with many alternatives like [Prettier](https://prettier.io) and [Standard](https://standardjs.com). They not only format the code, but provide a single, _canonical_ formatting for a program so we programmers don't spend time mentally litigating the various ways a particular expression or function could be written out.

Developers use code formatters in two major ways, either integrated into their text editor/IDE, to format on save or a keyboard shortcut; or integrated into their change control workflow, so code changes are formatted before they're shared with the team and the world. But in order for a language to support any of these use cases, it needs a code formatter, a _program that takes some bit of source code and produces a correctly formatted version of it_.

That is what inkfmt does today.

### What inkfmt does

inkfmt, the tool, is currently just an MVP, and does exactly one thing. It takes a single input file, formats the code inside, and returns the output. And it does that job reasonably well, though there still definitely are [rough edges](#case-study-hanging-indents). It takes input from `/dev/stdin` and outputs to `/dev/stdout`. This means we can run inkfmt on a file like this in the shell.

```
inkfmt < input.ink > output.ink
```

Eventually, I want to build out a command-line tool that allows me to do this for a large tree of files and format code in-place.

In the process, inkfmt currently makes four types of code transformations.

1. **Remove trailing commas at line endings**.
2. **Remove trailing commas in lists**.
3. **Re-indent code**.
4. **Canonicalize whitespace between symbols**.

### Prior art

Like parsers and compilers, pretty printers come from a long and rich historical and academic context. My favorite read on the topic so far is [Prettier Printer]() by [Phil Wadler]() from the University of Edinburgh. It's an academic investigation into the theoretical problem of pretty-printing text.

Another source of inspiration is the wealth of currently available open-source code formatters for different languages.

## Building inkfmt

I had set up the inkfmt project long ago, because I wanted my text editor (vim) to be able to auto-indent my Ink code on save. Ink's syntax is unique and we can't simply use a C-style formatter, so I thought I'd write one myself. And then the project sat and gathered dust without much work.

I've started to write more Ink programs recently, so the need arose again, and I thought I'd take a day to bring the project to an MVP level where I could start using it with real projects. I scrapped the boilerplate I had and started over, so inkfmt [as of today](https://github.com/thesephist/inkfmt/tree/add6724e715079d4d89b18b2bd48e3fca57ce4d3) is about a day's work, from noon to night.

inkfmt is a little under 250 lines of liberally commented Ink code atop the standard library, and split into two parts: the **lexer** and the **renderer**.

### Tokenizers vs. parsers

Most code formatters use an abstract syntax tree as the core data structure.

### Limitations of a tokenizing formatter

### The hard thing about indentation

What looks like "good" indentation, it turns out, is a fairly complicated question.

### Case study: hanging indents

There is at least one case that requires more than the rough indentation rule of thumb above. I call this case the "hanging indent" case.

How should we indent this piece of rather gnarly code?

```
addManyNumbers := (a, b, c
    d, e, f) => 
    a + b + c + d +
    e + f
```

This code is tricky to indent because the particular indentation we probably want isn't purely a direct result of any explicit nesting relationships between parts of the syntax.

- We want to indent the second line of the argument list, `d, e, f`, because it's a part of an unclosed list of values.
- We want to indent the body of the function, the part that follows `=>`, because function bodies are generally indented.
- We want to indent the last line, `e + f`, because it follows an incomplete expression from the line above.

Let's check out our options.

```
(1)
addManyNumbers := (a, b, c
    d, e, f) =>
    a + b + c + d +
        e + f

(2)
addManyNumbers := (a, b, c
    d, e, f) =>
    a + b + c + d +
    e + f
```

Of them all, I personally think the first option makes the most sense. We keep the second halves of incomplete expressions indented in, but also make sure the function body starts where most function bodies start, at the first indent. But you're free to disagree with me on which looks best or is most readable. This is a tricky and sometimes subjective question.

inkfmt currently produces the second solution, which I find to be satisfactory, but not ideal. This is a consequence of the limitations of a token stream-based formatter.

## Code formatting is complicated because it's a human problem

Code formatting is different from many other hard computer science problems because the metric that we optimize for isn't a well-defined measure. Instead, we look for readable, aesthetically satisfying, and useful outputs, and those goals leave a lot of room for subjectivity and taste. And I think that's a big part of the challenge of code formatting.

Adding to the complexity, a formatter's job is to take a one-dimensional piece of data (some source code text), and transform it somehow such that when laid out in two dimensions (your screen), its shape conveys meaning, while keeping the output in the same single dimension. A good formatter needs to reason about the two-dimensional shape of code while transforming it by inserting and removing whitespaces in a single line of text. This conflict in geometry of the source material and the goal was a particular challenge for me.

## Future work

I wrote a code formatter for my programming language in my programming language, and used it to format my code formatter for my programming language.

// angle: we tried a simple solution first that got us 90 / 95% of the way there. the other 10% requires AST.
    here's what I learned so far. I might continue it later.

// why we chose a token based printer
// limitations of a token based printer, and why we need an AST based one
    -> example: Promise.then(()).then().... needs AST b/c order of close-then-open matters.

// hanging indents... what a mess!


Tricky cases:

```
[[
    a, b, c,
    d, e, f,
], g, h]

[
    g, h
    [a, b, c,
        d, e, f]]

[[a, b, c,
        d, e, f]
    g
    h
]

[
    [a, b, c,
        d, e, f]
    g
    h
]

```

// how should error handing work? Format the rest? give up? return a syntax error?
