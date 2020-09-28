---
title: "Schrift: a faster, bytecode-driven interpreter for Ink"
date: 2020-09-23T06:36:34-04:00
toc: true
---

I've been working on a new big project recently: a faster, better-designed, more versatile interpreter for Ink, rewritten from the ground-up, called **Schrift**.

Schrift is an **experimental runtime for Ink focused on performance and runtime instrumentation capabilities**, and is still very much under development. Many parts of the interpreter are not correctly implemented yet, but the high-level architecture has been pinned down for most pieces of the project. This post is an overview of the architecture of this new interpreter, and how it differs from the existing, [Go-based interpreter](https://github.com/thesephist/ink).

<a href="https://github.com/thesephist/schrift" class="button">See Schrift on GitHub &rarr;</a>

Incidentally, the name _schrift_ comes from the German noun "Schrift,", which stands for "handwriting" or "script," which parallels the name "Ink" nicely. The word itself also sounds quite speedy, and speedy is what we're going for with this project.

## Why a second interpreter?

When I first created the Ink language and built the initial Go-based interpreter (which I'll call the "naive interpreter" to disambiguate against Schrift), I was also concurrently learning about the basics of a programming language runtime. As a result, the naive interpreter's design is, well, _naive_. It has a rather inefficient design across the pipeline, and is built as a tree-walk interpreter which has quite a low ceiling for efficiency. The naive interpreter's design doesn't lend itself very easily to the kinds of optimizations common to all modern interpreters, and makes some fundamental assumptions about how runtime variables are represented that makes it difficult to incrementally improve it with a more efficient design.

In addition, the naive interpreter depends on the Go runtime for many essential features like garbage collection, efficient hashmaps, and managing the call stack. While the Go runtime is fast and efficient, by letting the host language take over for these facilities, the naive interpreter gives up a lot of control that we would want over the interpreter if we want to make certain kinds of optimizations and deliver better error messages.

In summary, the naive interpreter based on Go and the Go runtime gave up control and performance headroom for simplicity of implementation, and now that we have one simple, correct implementation, I wanted to experiment with a faster interpreter for Ink that could exercise more control over the design of the runtime, and leave more room for performance optimizations to the language.

### Schrift's values and goals

I'm a big believer an idea borrowed from Oxide Computing's Bryan Cantrill, that programming languages and implementations have _values_. Values are deeper than goals, and guide decisions and priorities of a language or implementation's design. Schrift's values are intentionally different than that of the naive Ink interpreter. The naive interpreter values simplicity of implementation and "hackability" above all else. By contrast, Schrift is less of a prototype. Schrift's values are:

- **Performance**. Schrift will run Ink programs quickly and efficiently, taking good advantage of available hardware, and allow for new optimizations to be introduced into the interpreter easily.
- **Compatibility**. Schrift's implementation of Ink will try to be 100% compatible with the existing implementation.
- **Developer experience**. Specifically, Schrift will produce great error messages against erroneous programs, and allow errors to produce useful stack traces.
- **Observability**. It's important to understand how a program executes on a machine. Schrift should support runtime profiling and tracing with minimal overhead, and offer hooks in the Ink language to take advantage of these capabilities.

### Why Rust?

In light of Schrift's values, it should be no surprise that Rust is the implementation language of choice. Rust is fast, and offers enough control over the runtime environment of the program that we can ensure that we can move things around and use data representations in the runtime that best fit what makes Ink run best. Rust, unlike Go used in the naive interpreter, has a lightweight runtime, so Schrift can define its own garbage collection mechanism, its own concurrency style for event handling, and its own choice of implementations for fundamental data structures like hashmaps.

I would be lying if I didn't include the fact that I've wanted to learn Rust for a while. Writing a new interpreter was also a good opportunity for me to learn Rust while writing a non-trivial project. Rust was a great fit for Schrift's needs, balancing performance headroom with safety and control over the runtime's data representation and memory.

## Schrift's bytecode and virtual machine

You can find a high level overview of Schrift's overall architecture in the [GitHub repository](https://github.com/thesephist/schrift)'s readme. Here, I want to explore implementation details of the compiler, and the bytecode format more specifically.

Ink's naive interpreter was a simple tree-walking interpreter, and as a result, didn't need any intermediate representation beyond an abstract syntax tree. Schrift, by comparison, wants to compile Ink down to some binary format that a virtual machine can optimize and execute efficiently. Schrift uses a bytecode format that's somewhat unique, but inspired by Lua and Python's designs.

### Register-based SSA-style bytecode

Schrift's bytecode format is a hybrid between a low-level [SSA](https://en.wikipedia.org/wiki/Static_single_assignment_form) and a true "bytecode" format. Schrift's VM is designed to be a register machine, and the bytecode format makes it easy to map each SSA operation derived from an Ink program to instructions acting on registers in the VM.

For example, one instruction in the Schrift bytecode might be

```
@3  ADD @1 @2
```

This instruction copies the values from registers 1 and 2, adds them together following Ink's add semantics (addition for numbers, a boolean "or" for booleans, concatenation for strings) and places it in register 3. A more complex instruction is the `CALL` instruction for calling a closure or a function with variadic arguments. (There are more efficient, non-variadic forms of `CALL` for 1, 2, or 3-argument calls, which are common.) This takes the form

```
@5  CALL @3 [@4, @5, @6, @7]
```

This instruction takes a callable value from register 3, and calls it with arguments copied from registers 4, 5, 6, and 7. The return value of that call is then placed into register 5. This code might have been derived from an Ink program line that does something like

```
b := f(a, b, c, d)
```

These examples illustrate how the bytecode instructions generally have an SSA-like feel to them -- primitive operations take operands on the right and map them to registers on the left. However, unlike in SSA, destination registers in Schrift bytecode can be reused if a variable is mutated. In this way, we follow the SSA style but deviate where Ink's semantic simplicity allows us to.

Every bytecode instruction takes one destination register, and every instruction may optionally take zero or more argument registers. For simplicity's sake, there are no "immediates" in the Schrift bytecode -- all constants are loaded from a per-block constant pool using the specialized `LOAD_CONST` instruction, before they are used by other instructions. You can find the full list of valid Ink bytecode instructions in [`src/gen.ink`](https://github.com/thesephist/schrift/blob/master/src/gen.rs).

### Blocks and scopes

Schrift compiles a single Ink program down into a series of **blocks**, each of which contain bytecode **instructions**, as well as some per-block metadata. A block in Schrift bytecode is similar to the "basic block" abstraction used in SSA-driven compilers like LLVM -- a block in Schrift represents a contiguous stretch of control flow whose only entrypoint is at the top of the code, and whose only exit point is at the bottom of the code. Beyond a single specialized instruction for jumping forward conditionally, used to implement match expressions, Schrift compiles control flow down to jumps (or calls) from blocks to other blocks.

Schrift blocks are inspired by CPython's code blocks, in that each block contains a sequential chunk of code, alongside some metadata like a constant pool and array of surrounding captured variables in the case of closures. Here's an annotated overview of one such block generated by Schrift, using the `--debug-compile` compiler flag.

```
#5                  # this is Block #5 in the program.
                    # blocks are globally indexed from zero.
                    # and indexes are used to call and jump to
                    # blocks in the bytecode.

consts: [           # constants used in this block
    0,              # number constant
    Func(2, []),    # Funcs are other blocks we can jump to
    1,
    Func(3, []),
    Func(4, [])
]

binds: [6]          # implementation detail for closures,
                    # references a parent scope's register
  @0    NOP
  @2    LOAD_CONST 0        # load constant from constant pool
  @3    LOAD_CONST 1
  @1    CALL_IF_EQ @3, @0 == @2, 2
                    # CALL_IF_EQ is the only branching
                    # construct in Schrift. It calls a closure
                    # if two register values are equal, and
                    # optionally does a forward jump.
  @4    LOAD_CONST 2
  @5    LOAD_CONST 3
  @1    CALL_IF_EQ @5, @0 == @4, 1
  @6    NOP
  @0    ESCAPE @0           # escape stack value to vm heap
  @7    LOAD_ESC 0          # load escaped value to stack
  @8    LOAD_CONST 4
  @1    CALL_IF_EQ @8, @0 == @6, 0
```

A block corresponds in source code to either a function or an expression list, and represents its own lexical scope.

At runtime, the Schrift VM will begin execution at the top of block 0 (the hard-coded "main" entrypoint). Every time a new function is called, the corresponding block will be loaded from its index and the VM will allocate a new stack frame in which to execute the called block's code.

Let's look at some generated bytecode for a complete Ink program. Here's a simple hello world in Ink.

```
log := s => out(s + char(10))

message := 'Hello, Ink!'
log(message)
```

Before optimizations, Schrift compiles this code down to two blocks, one entrypoint block at index zero, and one block for the `log` function.

Here's the first block, the program entrypoint.

```
#0      
consts: [
    NativeFunc(...),
    NativeFunc(...),
    NativeFunc(...),
    NativeFunc(...),
        # NativeFuncs are builtin functions
        # defined at the global scope.
    Func(1, []),
        # function definition for "log"
    'Hello, Ink!'
        # the string literal for "message"
]
binds: []
  @0    LOAD_CONST 0    # load global constants
  @1    LOAD_CONST 1
  @2    LOAD_CONST 2
  @3    LOAD_CONST 3
  @0    ESCAPE @0       # "out" and "char" need to "escape"
  @3    ESCAPE @3       # to be used in closures (more below).
  @6    LOAD_CONST 4    # load the `log` function block
  @4    MOV @6
  @7    LOAD_CONST 5    # load the message string value
  @5    MOV @7
  @8    CALL @4, [@5]   # call `log` with the string argument

```

Here's the second block, which represents the `log` function.

```
#1      
consts: [10]
        # `log` only has one constant, the number 10
binds: [3, 0]
        # `log` "closes over" values in parent frame's
        # registers 0 and 3 (out and char builtin functions)
  @1    LOAD_ESC 0          # load "out" from heap
  @2    LOAD_ESC 1          # load "char" from heap
  @3    LOAD_CONST 0        # load constant 10
  @4    CALL @2, [@3]       # perform char(10)
  @5    @0 + @4             # concatenate strings
  @6    CALL @1, [@5]       # perform out(...) and return
```

### Memory allocation and escape analysis

One of the more sophisticated tasks that the compiler performs during code generation is [escape analysis](https://en.wikipedia.org/wiki/Escape_analysis).

In Ink, every function is a closure. This means that a function "captures" the lexical environment in which it was created. In other words, it can reference any variables outside of its local scope, in a parent scope many levels up. By default, values in Schrift are stack allocated as a performance measure, but if a value is captured by a closure in a child scope, it can survive longer than the scope in which that value was first created. This is a problem for stack-allocated values, so variables which are captured by a closure need to be either allocated on a heap, or moved to the heap before its original stack frame exits. The task of figuring out which variables must be heap-allocated due to closures is called escape analysis, and in Schrift, the compiler performs this job.

During code generation, the compiler will also compute lexical variable bindings to prove which variable names refer to which variable declarations in a program. Because this work is already being done, the compiler can also do a bit of extra work to check whether a variable access is pulling a value out of a local frame or its parent frame. When this happens, the original variable declaration in the parent scope is annotated with the fact that that variable must "escape" into the heap before any closures are invoked. Then, the compiler uses this information to add an `ESCAPE` instruction to the variable declaration, to let the variable's value escape to the heap during execution.

We see this in the sample hello world program and bytecode above, where the `log` function captures the `char` and `out` builtins of the parent scope. As a result, before the `log` function (block 1) is actually called, in block 0, two `ESCAPE` instructions push those values out to the heap.

### The virtual machine

All of the effort to generate and optimize bytecode for an Ink program culminates in a finale at runtime, when the Schrift virtual machine loads the bytecode blocks and begins executing the program.

In comparison to the bytecode format and the compiler itself, the Schrift virtual machine is quite conventional. The VM follows a basic `while`/`switch` instruction dispatch loop, where the VM iterates through every bytecode instruction, incrementing the instruction pointer and dispatching instructions based on the opcode at each iteration. At a function call, the VM allocates a new stack frame, loads the right arguments into the new frame, and begins executing bytecode from the newly loaded block.

The primary design quirk of the Schrift VM is that, while it's designed as a register machine, the "registers" technically live on the stack. The Ink VM doesn't have a "stack" in the traditional sense of a call stack that exists apart from the VM's registers. Rather, the VM uses slots in a stack frame's allocated memory region as the registers for executing that particular function call. New "register" slots are allocated for every stack frame, and each frame is optionally reused for tail-recursive calls on loops. This simplifies the code complexity and calling convention of the VM.

Unlike the naive interpreter, Schrift allocates and manages its own runtime stack and program state for executing Ink. Because of this, Schrift can have much finer control over how certain Ink semantics are executed, and offer much more straightforward visibility into the VM state. For example, it should be much easier to implement an error stack trace in Schrift than in the naive interpreter, as we have control and visibility through the entire call stack of a running Ink program.

The VM will continue to evolve -- what's there today is a minimal implementation that naively executes the generated bytecode. But I'm excited for the opportunity created by this new abstraction for Ink to take advantage of the higher performance headroom and debugging affordances like high quality traces and profiling. For example, the VM could currently benefit from a more data-oriented design, with a single contiguous stack of registers in memory and an explicit return register between function invocations, with a separate stack frame metadata stack.

All of this goes to show that Schrift has a lot of ways to improve from its current state, but I'm excited by the new possibilities for improvement it opens up for optimizations and instrumentation, and I've also been enjoying diving into Rust as a part of the process. Many of the ideas outlined here are up for change, but I think the high-level goals and design of Schrift are pointing in the right direction, and I'm looking forward to the possibilities it can open up for Ink.



