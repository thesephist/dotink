---
title: "Weighing software abstractions to design better programs"
date: 2020-11-14T23:34:45-05:00
toc: true
math: true
---

I like thinking about software as if it were matter, following some pre-ordained laws of nature as if they occupied real space and time. Of course, the metaphor often only stretches so far, but I think metaphors of physics in software can often give us great mental models for thinking about the complexity that we create when we build software, which I believe to be [the most complex machines humans design](https://thesephist.com/posts/software/).

I've written on my main blog [about software and degrees of freedom](https://thesephist.com/posts/dof/), a concept in mathematical physics. This time, I want to talk about the _weight_ of software, specifically the weight of abstractions we create when we build software. Can functions and classes and variables feel _heavy_ or _lightweight_? How can we use that intuition to help us write better software?

## Cost vs weight

An often cited related idea to the **weight** of abstractions in software is the [**cost** of abstractions](https://250bpm.com/blog:86/). When we refer to a design as an "over-abstraction,", for example, we're claiming that the costs of a particular abstraction, say a class that's reused many times, is not worth the benefits we get in return. Abstraction cost is an economic idea -- do we get a good deal? Do the benefits outweigh the costs?

Abstraction cost takes into account a whole ensemble of factors, like performance, maintainability, and even compile-time costs. The _cost_ of an abstraction is the total price you pay over the lifetime of a software project for the benefits of abstraction, like code reuse and maintainability benefits. As a result, abstraction cost is a concept _unique to software_. Other disciplines also deal with abstraction. Mathematics, for example, is in some ways just a study of abstractions. But it doesn't make sense to talk about abstraction costs in the context of mathematics, because there's nothing to run, nothing to maintain, and very little to break.

The **weight of an abstraction** is a much more specific idea. **Lightweight abstractions are easy and quick to create, and just as trivial to delete. Heavy abstractions are the opposite -- they take some effort to create, and are usually even harder to dispose of.** At first glance, this sounds as if we should make all our abstractions as light as possible. But that's not always the case. Heavy abstractions, when used right, are able to provide all the benefits of a great abstraction. The `String` type in many low level languages is exactly one such a heavy abstraction. In nearly all software projects, the string type is absolutely fundamental, and adding a new string type or removing an existing one would mean rewriting significant parts of most apps. But the string type also pulls its weight -- it provides an interface to a string of characters that everyone needs.

**When an abstraction pulls its weight, it's very probably a good abstraction.**

Before examining weights of software abstractions further, let's take a detour into mathematics.

## Mathematical notation

Mathematical notation is a language of abstractions. When we say, "let \\(y = f(x)\\)," we're creating a (short-lived) abstraction, a stand-in for \\(f(x)\\) named \\(y\\). There are also more complex abstractions, like the summation:

$$\sum^n_{i = 1} a\_i = a\_1 + a\_2 + a\_3 + \dots + a\_n$$

The summation sign \\(\sum\\) is a _notational abstraction_, one that replaces a sum of a sequence, something that occurs extremely often in mathematics, into a recognizable, universally reusable symbol. Notational abstractions are everywhere. Even trivial things like the equals sign, the exponentiation notation (\\(x^n\\)), and the constant \\(\pi\\) are notational abstractions, symbols that stand in for other symbols.

Notational abstractions tend to be **lightweight**, because they are either short-lived or universal. In a proof, you might say "let \\(S\\) be the set of all integers that satisfy X property." The abstraction \\(S\\) lives for the duration of that proof, and no longer. In such a limited scope, notational abstractions also tend not to change. A proof would never change its mind halfway through about what a symbol means. This short life span of an abstraction, combined with this immutability, means notational abstractions are rarely heavy -- they're easily replaced, easily added, and easily deleted for something else.

## Natural languages

Abstractions in natural languages have a completely opposite property to mathematical notation. One abstraction (word or phrase) rarely substitutes for another, and the meaning of specific words change constantly, in a world where most words will live on effectively forever.

Take the word "disk" as an example. The word "disk" was birthed in reference to flat, round objects that athletes in Ancient Greece would throw as a sport. The abstraction quickly grew through the millenia to denote flat-rounded objects in general. The etymological family tree took a sharp turn when, towards the end of the 20th century, disk-shaped storage devices were invited for use in electronic computers. These magnetic disks became the dominant form of electronic storage for a few decades, and "disk" became a colloquial way to refer to persistent storage in computers. In 2020, fewer and fewer computers have rotating, circular disks as their storage media, but we continue to refer to these storage devices as "disks." The word no longer resembles its origin, and yet, "disk" continues to evolve as a linguistic abstraction.

Words and phrases are nothing like mathematical notation. They are constantly changing and adapting to the needs of its speakers, and few words have "limited" scope of usage. Words, once created, are hard to destroy. For these reasons, almost all natural-linguistic abstractions like words are **heavy**.

Software, being the lovechild of mathematics and language, perches somewhere in between these two extremes in the weight spectrum of abstractions.

## Programming languages

Programming abstractions come in all sizes, and most languages provide the tools to create both lightweight abstractions and heavy ones. Here are a few lightweight abstractions. These are trivial to introduce, and easy to delete or replace.

- A local variable
- The array type
- The function \\(f(x) \rightarrow x^2\\)

Here are a few heavy abstractions. These are usually created with a lot of thought and intent, and very complicated to delete or modify as time goes on.

- The `User` type in a web app
- A Java class
- A C++ template

Some languages tend to push programmers towards using lightweight abstractions, and others seem to guide them towards heavier ones, even for the same task. Put another way, abstractions are easy to create and remove in some languages, and harder to both create and delete in others. We also sometimes call this extra "weight" languages add to abstractions "boilerplate code."

In older versions of **Java**, fore example, creating a small utility function like "increment this by one" necessarily meant also creating some anonymous class to contain the function. A small record type in Java may require a full class of getters and setters, by convention. Creating most abstractions in Java used to be tedious, and resulted in heavy abstractions that were more work they worth to create. As a result, new features and code would frequently be added to existing abstractions, in the end also making them more complicated to remove from a codebase.

**Lisp**, I think, is in the opposite end of the spectrum. Both by convention and by design, Lisp favors lightweight abstractions that are easy to create. Lisp functions tend to be small, and tend to do one or few things. Good lisp programs compose these small functions together to create more complex programs. This means each function (which is our main abstraction) is relatively cheap to create, and easy to replace or modify. Functions grow and mutate less often than in other more imperative, inheritance-based languages.

### Gravity of abstractions

Heavy abstractions have an interesting effect on codebases that seem to be universal. They have gravity, (vaguely) like heavy objects in physics.

Heavy abstractions also seem like they get heavier with time. Heavy abstractions accumulate other use cases and requirements, because it's often easier to expand a complex, heavy abstraction to support some new use case than to create another heavy abstraction. The heavier an abstraction, the stronger the tendency for it to accumulate even more weight, and become even harder to modify later. This is the *gravity* of heavy abstractions.

Heavy abstractions are not _de facto_ bad, but an abstraction constantly accumulating new surface area is an important risk for any codebase. Light abstractions, by contrast, don't accumulate mass and bloat in the same way, because it's usually cheaper to create another light abstraction independent of existing ones. Light abstractions stay lightweight. They have little gravity to worry about.

## Abstraction weights in program design

Abstractions we create when we design programs affect the codebase they inhabit in ways that aren't obvious from the start. Some abstractions deserve to be embedded deeply into a codebase, growing and changing over time, while others are better off lightweight, coming and going as needed. While deciding on what kind of abstraction to use is the job of the programmer, the tool that they use, the programming language, also influences how easy it is to create heavy or light abstractions in the language. Sometimes, this leads projects to become bloated with abstractions that should have been lightweight, but are too heavy for their own good, accumulating lots of peripheral changes and becoming difficult to move or remove.

When we design programming languages and software libraries, we should **take care that the weights of abstractions the language encourages reflect how we want people to use them**. Functions and types should be lightweight if we want programmers to use lots of them, creating and disposing them often. Packages should be heavyweight if we don't want to flood the ecosystem with lots of small libraries that should really just be functions or types. Fast, lightweight abstractions are not always good, and a judicious allocation of weight between different abstractions will serve us programmers best.

