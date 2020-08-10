---
title: "The September compiler: translating Ink to JavaScript"
date: 2020-08-10T09:42:24-04:00
toc: true
---

[September](https://github.com/thesephist/september) is an [Ink](https://github.com/thesephist/ink) to JavaScript compiler, written in Ink itself. It's so-called because it's the first in a forthcoming series of autumn-month-themed tools written in and for Ink:

- September, a compiler to JavaScript, which is what this post is about
- August, an assembler and linker, which is yet to be started
- October, a symbolic mathematics environment, which is even more yet to be started, but which I'm _really_ excited about

Autumn months are great, especially because [august](https://genius.com/Taylor-swift-august-lyrics) is the best song on [folklore](https://en.wikipedia.org/wiki/Folklore_(Taylor_Swift_album)) which is a lyrical and aural masterpiece by the queen of pop Taylor Swift herself, but that's for me to go on about on a different website. Back to the point:

**September compiles Ink programs to equivalent (though not necessarily _elegant_) JavaScript programs**. What does this mean? It means September can transform Ink code like this

```
a := 2
b := 3

log(a + b)
log('Hello, World!')
```

to valid JavaScript code like this, which performs the exact same computation.

```
let a = 2;
let b = 3;
log(__as_ink_string(a + b));
log(__Ink_String(`Hello, World!`))
```

September is a _working prototype_ at the moment. Except for tail recursion optimization, which September cannot currently perform, September passes much of Ink's standard library tests. This allows me to write Ink programs targeting JavaScript environments, including the Web. With September, I'm one step closer to being able to write full-stack applications entirely in Ink, which would be pretty cool.

This post is about why it's useful to compile to JavaScript, how September works, and where I want to take it in the future. If you've got limited time, I recommend starting with the [How it works](#how-it-works) section, because it takes you inside the compiler with a concrete example, and I think it's the most interesting bit.

<a href="https://github.com/thesephist/september" class="button">See September on GitHub &rarr;</a>

![september banner](/img/september.jpg)

## Why compile to JavaScript?

Why might we want to compile other languages to JavaScript?

The most obvious reason is that, even with the advent of [WebAssembly](https://en.wikipedia.org/wiki/WebAssembly), JavaScript is the language most interoperable with the Web platform.

<blockquote class="twitter-tweet"><p lang="en" dir="ltr">It&#39;s a good question! Someone asked this yesterday:<br><br>Big things are<br>- lack of native GC support<br>- JS is semantically closer, compilation is less work<br>- I&#39;ll probably want to access DOM APIs directly from Ink<a href="https://t.co/OHjWP8OTkZ">https://t.co/OHjWP8OTkZ</a></p>&mdash; Linus (@thesephist) <a href="https://twitter.com/thesephist/status/1292820353727762432?ref_src=twsrc%5Etfw">August 10, 2020</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

In particular, if I want to write web applications entirely in Ink, I need to be able to call into DOM APIs. While there is some movement to create WebAssembly interfaces for the DOM, and some momentum behind providing [system interfaces for Wasm](https://hacks.mozilla.org/2019/03/standardizing-wasi-a-webassembly-system-interface/), WebAssembly today is still a low-level _compile target_ that requires JavaScript to communicate with the outside world. WebAssembly also doesn't interoperate gracefully with JavaScript types like objects and strings, which are a core part of the Web platform's API.

Compiling to JavaScript would still allow Ink programs to run on the Web and run fast, and because the semantics of JavaScript and Ink are similar, it's trivial to access JavaScript-based APIs from Ink code to do things like manipulate a webpage or make web requests.

Besides compatibility with the Web platform, JavaScript is a good compile target for Ink specifically because the types, values, functions, and concurrency models of Ink are largely inspired by JavaScript and map over very nicely to JavaScript. This makes compilation rather straightforward, which is the main reason I could write a first working prototype of the compiler in a weekend.

### Prior art

Compiling to program source code is pretty common in the wild. I think these days the most common textual compile target is JavaScript, because of its ubiquity as The Web Language, but languages also compile frequently to C for its omnipresence and performance, to Lua for its simplicity, and to various other niche languages.

A few projects in particular inspired my work on September.

- [Fengari](https://fengari.io), a Lua runtime on top of JavaScript. Studying Fengari's implementation was especially helpful in thinking about how to translate mutable strings and Ink-JavaScript interoperability.
- [Babel](https://babeljs.io), the industry standard JavaScript compiler.
- [Emscripten](https://emscripten.org/), an LLVM IR to JavaScript compiler. Practically, this means Emscripten can compile C, C++, and Rust to JavaScript.

## How it works

I've written an in-depth guide to how September works in the [readme](https://github.com/thesephist/september/blob/master/README.md) to the project. Here, I'll just give you a taste with a small but illustrative example.

Let's take this simple Ink program.

```
a := 3
b := 17
log(a + b)
```

When we're done, we'll end up with this equivalent JavaScript program.

```
a = 3;
b = 17;
log(__as_ink_string(a + b))
```

### Tokenization

The first step in the September compiler is scanning, handled by the **[tokenizer](https://github.com/thesephist/september/blob/master/src/tokenize.ink)**. The tokenizer scans through the program text as a string, and produces a list of tokens, or symbols. In the Ink tokenizer, these tokens are also sometimes tagged with their type, like "number literal" or "string literal" or "addition operator". For our small program, September yields the following tokens. I've added some blank lines and comments to make the output easier to read.

```
# a := 3
Ident(a) @ 1:1
DefineOp(()) @ 1:3
NumberLiteral(3) @ 1:5
Separator(()) @ 1:6

# b := 7
Ident(b) @ 2:1
DefineOp(()) @ 2:3
NumberLiteral(17) @ 2:5
Separator(()) @ 2:6

# log(a + b)
Ident(log) @ 3:1
LParen(()) @ 3:4
Ident(a) @ 3:5
AddOp(()) @ 3:7
Ident(b) @ 3:9
Separator(()) @ 3:10
RParen(()) @ 3:10
Separator(()) @ 3:11
```

We can see that the token stream is a straightforward list of symbols that we see in the program. These tokens are also annotated with the line and column numbers in the source code where they occur, like `@ 3:9` to mean `line 3, column 9`. This is useful for debugging and emitting useful syntax error messages.

You might be wondering where the `Separator` token came from. This is an implicit detail of the Ink language syntax, and functions like the semicolon in most C-style languages, as an expression terminator. It's not necessary most of the time, and inferred by the interpreter or compiler. Here, our tokenizer has inferred where the implicit Separator tokens should be and added them for us. This makes the next step easier. If this bit about the `Separator` token doesn't make sense, don't worry -- it's not important to the compilation process.

### Parsing

Next up, we need to group these tokens into meaningful hierarchies. We want to know, for example, that the `a + b` expression is a single expression, while `log(a` is not. This work is done by the **[parser](https://github.com/thesephist/september/blob/master/src/parse.ink)**, which builds up a recursive data structure called the [abstract syntax tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree). The AST for our program looks like this.

```
BinExpr(Ident(a) DefineOp Lit(3))
BinExpr(Ident(b) DefineOp Lit(17))
Call(Ident(log) (BinExpr(Ident(a) AddOp Ident(b))))
```

We can see our parser has grouped tokens into meaningful hierarchies. This representation of our program is meaningful enough for the rest of the compiler to draw good conclusions about what the program does.

### Semantic analysis

Before we generate the equivalent JavaScript code for this Ink program, we need to take a final step: [semantic analysis](https://ruslanspivak.com/lsbasi-part13/). In September, this is handled by the **[analyzer](https://github.com/thesephist/september/blob/master/src/analyze.ink)**.

The analyzer traverses the syntax tree from top-down, and makes small annotations or transformations on the nodes of the tree that help us generate better code.

The most common kind of annotation made by September's analyzer is clarifying variable declaration. Like in Python, Ink doesn't have explicit variable declarations. The first time we reference a variable, Ink creates a new variable in that scope. JavaScript code requires that new variables in a scope be declared with `let` or `const`. The analyzer combs through variables declared in each scope, and [sets a flag called `node.decl?` if the expression should be a `let` declaration](https://github.com/thesephist/september/blob/6a959e9d5a12936d0a322982e812f9726260c5fd/src/analyze.ink#L37).

In our toy example, the analyzer doesn't make any visible changes, because the information in the original syntax tree is enough to generate a valid JavaScript program.

### Code generation

Code generation is the step where we walk through the annotated syntax tree and output the equivalent JavaScript code for each node in the tree. This is handled in September by the **[code generator](https://github.com/thesephist/september/blob/master/src/gen.ink)**.

The code generator contains a comprehensive list of every possible node in the syntax tree, and knows what JavaScript snippet is a faithful translation of each node type. For example, the generator knows that the syntax tree node `BinExpr(Ident(a) MulOp Ident(b))`, which is `a * b`, gets translated into [`(a * b)` in JavaScript](https://github.com/thesephist/september/blob/master/src/gen.ink#L112). This is a simple example -- the generator encodes much more complex transformations I won't explain here, but you can explore them for yourself in the source code I linked in this paragraph, if you're curious.

When the code generator steps through our syntax tree and outputs the resulting Ink code, we get the final output, a valid JavaScript program.

```
a = 3;
b = 17;
log(__as_ink_string(a + b))
```

... nearly. You might be wondering what the `__as_ink_string()` function is doing in our code. This is an example of a **runtime library** function.

### The runtime library

There are some parts of Ink's semantics that are better emulated not by translating code directly to JavaScript, but by calling out to some special piece of functionality written in JavaScript and packaged with the resulting JavaScript program. These pre-written pieces of functionality are collectively called the runtime library, or _runtime_ for short. All languages have runtime libraries of varying sizes, and low-level languages like C have much smaller runtimes than rich, dynamic languages like JavaScript or Python.

In September, the runtime library implements small pieces of Ink's behavior that are different from JavaScript. An example is the negation operator `~` in Ink, which negates a number or negates a boolean, depending on the type of the operand.

```
# Ink
~true `` -> false
~1    `` -> negative 1
      `` same operator!

# JS
!true // false
-1    // negative 1
      // differenet operators!
```

JavaScript doesn't have an equivalent operator, so instead, September compiles `~x` to `__ink_negate(x)`, which is a runtime library function that just does the right thing. Ink's runtime also implements various Ink built-in functions like `len()` for sizing an object or string, and the Ink `string` type, which behaves differently than JavaScript strings in important ways. The `__as_ink_string()` runtime function we see in our toy example ensures that a string value is represented in a way that's consistent with Ink's string type throughout the generated program.

When September generates the full, final JavaScript program, it takes its [full runtime library. ink.js](https://github.com/thesephist/september/blob/master/runtime/ink.js) and outputs this with the resulting program, so we can run the whole thing on a JavaScript environment like Node.js.

## Progress

At time of writing, I've been hacking on September for two days and change. Today, September is something between a proof-of-concept and an alpha. It can compile moderately large Ink programs (including itself and the [Ink standard library](https://github.com/thesephist/september/blob/master/runtime/std.js)) correctly, but doesn't implement all of the Ink language for the resulting program to work correctly all of the time.

One way I've been tracking the progress of September is by **testing the compiler** against the [test suite I wrote for the original Ink interpreter](https://github.com/thesephist/ink/blob/master/samples/test.ink). This can give us better confidence that an Ink program compiled with September behaves identically to one that runs on the original interpreter.

So far, September passes something like 283 of the 370 tests in the test suite. It would likely pass far more, but I haven't had time to translate dependencies of the test outside of the standard libraries yet.

Besides the ample room for further optimization work, one critical missing piece of September today is [tail call optimization](https://en.wikipedia.org/wiki/Tail_call), which is _required_ for a correct implementation of Ink, but not implemented in September yet. This is tricky, because most JavaScript environments don't support tail recursion, so we need to expand out tail recursion in Ink code to `while` or `for` loops in the generated JavaScript program. I'm quite sure this is possible, but doing it well will take some thought, and I haven't had a chance yet to give it that much thought.

Even so, September compiles many useful Ink programs correctly, and can run it on Node.js. One promising development is that **Ink programs compiled to JavaScript sometimes _run faster_ than when run on the original interpreter** for many kinds of workloads, like number crunching. This is thanks to the many person-years of optimization work that goes into JavaScript engines like V8.

## Future work

As I've been careful to mention before, September is a work in progress. Besides tail call elimination and better general optimizations, There are a few other ideas I want to explore with September going forward.

- **Bundling.** An Ink program can be spread across many files. Since we can identify all of an Ink program's dependencies through semantic analysis, we should be able to combine all the Ink program files that go into a single application and bundle it into a single JavaScript file.
- **Interoperability.** One of my hopes for September is that it lets me write web apps with Ink. I haven't had a chance to run any September-generated code in browsers yet (only Node.js), and when I do, I hope to think more about how Ink programs can best access the cornucopia of Web APIs exposed to JavaScript.
- **Self-hosting.** While September can currently compile itself, the runtime isn't sufficiently complete for the compiled code to compile itself again -- i.e. September isn't strictly self-hosting. This is because things like the filesystem APIs aren't implemented yet. I hope to get to a point where September can produce code that can compile itself again, and be truly self-hosting, independently of the original Go-based Ink interpreter.

Although I've been reading deeply into the design of compilers lately, September is young (as am I) and building September is a continual learning process. There are some design decisions I really like about the compiler, some that I regret, and some that are just carried over from the design of the original interpreter.

September is the first time I've written a semantic analysis algorithm of any sort, and the first time I've written a compiler with a code generation backend of any kind. So it seems like there's a lot of space for me to improve there and dig deeper into literature with some preliminary knowledge of what kinds of problems I want to solve. And I'm excited to go do exactly that.

