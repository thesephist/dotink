---
title: "A retrospective on toy programming language design mistakes"
date: 2020-11-26T21:13:28-05:00
toc: true
---

I've written a few toy programming languages, mostly of the functional paradigm. The most significant of those is [Ink](https://github.com/thesephist/ink), but I've also written a Lisp-style mini-language called [Xin](https://github.com/thesephist/xin), and now a proper Lisp in [Klisp](/posts/klisp/). Besides those implementations, I've also played with a half dozen other concepts and ideas for alternative programming languages as I've learned about array programming, pipelines, shells, and other more esoteric concepts in programming language design.

In the process, I've made lots of mistakes and miscalculations that I regret, and I've learned a lot from them. Many decisions (like Ink's pattern-match syntax or byte strings) panned out well, while other design decisions (like error handling, or the lack thereof) have not aged so well. Since many people seem to reference my past experiments for embarking on a project to build their own toy languages, I thought I'd summarize my regrets and learnings here. For a more comprehensive guide to building your own programming language, you should read [my post on the topic on my main blog](https://thesephist.com/posts/pl/).

## Error handling impacts language design more than you think

By far the biggest mistake I made in designing Ink was that I neglected to consider how errors and exceptions would be handled. In software, there are two kinds of errors:

1. **Expected error conditions**. When you attempt to open a file, you should expect that the file might not exist. When you send some data on a network, you should expect the network to be unavailable sometimes. These are errors that a programmer expects as a result of normal operations of computers. Depending on your use case, memory allocations may also result in expected errors -- if the machine is out of memory to allocate, should your language handle this error? Can it?

    I decided to handle errors in most of these cases in Ink by wrapping fallible actions in event objects that can either contain an error or a successful response to an action. For example, reading a file in Ink using the `read` built-in function may return an object like `{type: 'data', data: '...'}` on a successful read, or `{type: 'error', message: '...'}` on an unsuccessful read. These are expected errors, and I'm happy with how Ink handles them for the most part.
2. **Unexpected errors from incorrect programs**. Unexpected errors are a different kind of beast, and a result of _incorrect programs_. This is an important point to grasp -- if a program produces an error due to an invalid program, like "divided by zero" or "unexpected argument type", it implies that a programmer made a mistake somewhere. Most of the time, the program that a programmer is writing will be incorrect -- most of the time, when we're working on a program, we are building an incomplete program or fixing a broken one. This means error messages to unexpected errors are one of the _primary user interfaces_ that a programmer has to your interpreter or compiler.

    When I first built Ink, I didn't think about how Ink programs might recover from or react to unexpected errors like type errors or division by zero. The lack of a good recovery mechamism resulted in two poor points of UX for the interpreter: (1) when such an error happens, the entire interpreter exits irrecoverably, and (2) it's impossible for a program to respond to unexpected errors happening inside of it, and try to recover or print runtime information to help debug the issue. The interpreter's design also made this more difficult than it should have been to remedy later, so the Ink interpreter reacts to runtime errors poorly to this day. This is by far my biggest regret in Ink's first implementation, and I'm hoping to improve the situation in [Schrift](/posts/schrift-code/), a second generation interpreter for Ink.

### Do you care about stack traces?

Stack tracing is one of those topics that "programming language 101" guides rarely cover, but is important to get right in production languages. As I began using Ink for more meaningful projects like my productivity tool suite or my website, it became important to be able to debug my way out of errors that occurred deep in a program's execution. My initial design for Ink didn't allow the interpreter to produce useful stack traces on a program crash or runtime error. Ink's "execution stack" was really just the Go call stack in the interpreter, and to retrieve a stack trace, the interpreter would have to `panic()` and `recover()` up the stack, which isn't ideal.

The second-generation interpreter I'm writing for Ink, called [Schrift](/posts/schrift-code/), uses a bytecode VM that keeps its own Ink call stack in memory. In this setup, it's much more straightforward to retrieve a stack trace at any point in the program by walking up the call stack in the virtual machine state.

If you want to use a new language to build meaningful (non-toy example) programs, it seems important to think about how your interpreter design will impact how easily you can collect stack traces (and more generally instrument program state) at runtime.

## Tradeoffs of combining integer and floating-point types

Ink, Xin, and Klisp all take after JavaScript to have a single `number` type rather than separate integer and floating-point types. These `number`s are double-precision numbers and serve their purpose well -- I haven't really ever felt that I needed a raw integer type in my usage of those languages. However, I use these languages mostly for programming command-line tools, algorithms, simulations, and web services, none of which really require manipulating integers and binary integer representations.

There are also programming domains where it's critical to have integers as primitive, native types in the language, and where binary representations of signed and unsigned integers are necessary. If you're implementing efficient and packed data structures, talking to hardware or lower level parts of an operating system, or trying to squeeze out the most performance out of your language, you'll most definitely want native integer types in the language that can work in the native data formats of a CPU, instead of burning floating point registers and floating point throughput unnecessarily.

There's also an interesting middle ground that tries to balance the ergonomics of a single number type and the performance benefits of native integer representations: the *safe integer optimization*. When using safe integers, a single `number` type may be represented in the interpreter as either the full floating-point value, or an integer type of equivalent or smaller size in memory. For example, if the interpreter sees a number `100`, it can determine that `100` is safe to represent as a signed integer in the particular machine architecture, and use more efficient integer operations when operating on the number until the guarantees of the integer's representability no longer holds (e.g. when multiplied by a fraction). V8, for example, uses a kind of safe integers called small integers (SMI) to optimize many operations on integers in the JavaScript VM. The safe integer optimization is also on the best-effort roadmap for Schrift.

## String representations

Ink strings are mutable arrays of bytes (8-bit chars), but actually began as a wrapper around simple immutable Go strings. Go strings had better safety guarantees, automatic handling of Unicode characters, and simplified the interpreter code. But when it came time for Ink to interact with the host operating system with things like file and network I/O, I found it simpler to expand the string type to be mutable bytes instead, rather than add a new byte array type to the language. And from then on, the string type in Ink has been just a mutable array of bytes.

I think this decision ended up ok for Ink as a language for my use cases, but I wish I had put more thought into string mutability from the start. For minimal languages like Ink or even Lua and Zig (minimal as in simple, not as in naive), strings are byte arrays, but for higher level languages like Go and C++, an immutable, Unicode-aware string type makes more sense.

## Asynchrony and concurrency

Ink also grew support for asynchrony and concurrency later in its life, as I started integrating operating system interfaces like file and network IO into the language. It inherits JavaScript's excellent callback-based interface for concurrency, and I'm happy with it. For Xin, I tried to implement a green threads and channels-based primitive for asynchrony, and discovered I hadn't thought it though enough in design. Xin ended up with a kludgey solution based on callbacks that doesn't really fit into the language, that I now regret.

In general, how a language lets you schedule execution in the future is a core part of the design of a language. If you want the language to handle the details, you probably need to implement an event loop, and maybe a more sophisticated thread scheduler in the interpreter. If you want to yield asynchrony to the operating system's threads, you end up accepting the performance compromises of using OS threads. Either way, these decisions are difficult to reverse, and I think they're worth thinking deeply about in the design of a language from the outset if you intend to support concurrent programming.

As with most other disciplines in computer science, programming language design has a rich and deep history, and when asking these questions to design a programming language -- even a toy example to learn -- I think it's worthwhile to look at prior art, especially the attempts that failed or receded into a niche, to see how design decisions in a language can be implemented, and how they can influence the kinds of programs you'll be able to write in a new programming language.

