---
title: "Notable papers about computing and software"
date: 2020-07-26T13:13:16-04:00
toc: true
---

This year, I've been spending more time reading papers about computer science and software engineering. I'm not in academia, so I don't always read papers in the cutting edge of the field, but I've enjoyed reading seminal papers written at the birth of interesting technologies. These papers are a glimpse into the past half century of computing -- what people anticipated to be problems, and what unanswered questions programmers were battling then. These classic papers show what their authors valued and cared about in their vintage.

Many high level ideas in computer science recur throughout history. The industry might be constantly focused on building with news tools for new products, but the design problems, the architectural patterns, and the tradeoffs we face today in building for modern platforms are not new. We've been investigating these same patterns and tradeoffs for the better part of a century now, and reading old literature has helped me build better mental models for computing and for software I write today.

The list I've compiled here isn't meant to be "the best," just the papers I've personally read that I found insightful or interesting enough to recommend. If you want to recommend an addition, feel free to find me on [Twitter](https://twitter.com/thesephist).

I've grouped these papers into three rough buckets.

## Software history and engineering

### _The UNIX Time-Sharing System_, Dennis Ritchie & Ken Thompson

Ritchie and Thompson are two of the "fathers of UNIX," which in turn is the spiritual ancestor for today's Internet infrastructure operating systems like Linux, Solaris, and BSD. The UNIX operating system pioneered both principles in systems design (like [the UNIX Philosophy](https://en.wikipedia.org/wiki/Unix_philosophy)) and the seeds of a robust, cross-architecture operating system whose legacy we still enjoy today. The paper lays out in plain easy language the basic design principles behind UNIX, the core ideas that surprisingly hold up well today, and the reasons they think they could arrive at such an elegant design of the system. Even disregarding its commercial success and popularity, I think UNIX is one of the canonical examples in the software industry of elegantly designed, great timeless tools, and this paper offers a lot that tool builders can learn from even today.

<a href="https://people.eecs.berkeley.edu/~brewer/cs262/unix.pdf" class="button">Read PDF &rarr;</a>

### _A Note on Distributed Computing_, Jim Waldo et. al.

_A Note on Distributed Computing_ is one of the classic papers on distributed systems. The authors provide a clean definition for distributed systems as systems where components don't share an address space, and they argue at a high level that distributed systems have emergent properties and failure modes that are fundamentally different from local systems. They extend the argument to claim that rather than designing components and programming paradigms that try to paper over the difference between local and distributed computation, we should make those differences and failure modes obvious in the design of protocols and interfaces so programmers can use them appropriately.

Despite being from the dawn of the distributed systems era, I found many of the ideas in the paper timeless and useful in today's world of containers and microservices. I also think their argument for see-through APIs that open up the underlying failure modes is a generally useful design principle we can apply elsewhere in computing fruitfully.

<a href="https://github.com/papers-we-love/papers-we-love/blob/master/distributed_systems/a-note-on-distributed-computing.pdf" class="button">Read PDF &rarr;</a>

### _Plan 9 from Bell Labs_, Rob Pike et. al.

After the success of UNIX, Bell Labs took the core ideas behind UNIX, their learnings from previous operating systems research, and baked it into what they deemed a better-designed system called Plan 9. Plan 9 built on the principles of UNIX to better integrate newer trends of the time -- networked computing, graphical interfaces, and software services distributed across remote machines. Plan 9 was never a commercial success in the way that UNIX was, but pieces of Plan 9's architecture still thrive today in places like the Go toolchain and the [9p filesystem protocol](https://en.wikipedia.org/wiki/9P_(protocol)) on Chromebooks. More importantly, Plan 9's design is an interesting exercise in extending the UNIX philosophy to support more modern computing environments.

<a href="https://9p.io/sys/doc/9.pdf" class="button">Read PDF &rarr;</a>

### _Bicycles for the mind have to be see-through_, Kartik Agaram

Software engineering is fundamentally the work of designing and implementing layers of abstractions. The central problem of software design, then, is to choose the right abstractions, and the right places in a system to place them. This paper is a more recent work, but one I really enjoyed reading and one that heavily influenced the way I think about software interface design. It's a more epistemological read than the other papers here, but I found it insightful nonetheless and broadly applicable in everything from talking about consumer productivity tools to creating API definitions in my day job.

<a href="http://akkartik.name/akkartik-convivial-20200315.pdf" class="button">Read PDF &rarr;</a>

## Programming languages

### _The Awk Programming Language_, Aho, Kernighan, and Weinberger

Okay, TAPL is really not a paper _per se_, but this manual book for the small language is one of my favorite "programming language books." Awk is a great example of a "small language" designed for a very specific domain of problems -- structured text manipulation, in this case. Awk is worth learning, since it's easy to pick up and will save you time in the long run if you do any kind of work with text data in the terminal, but the book itself is also worth reading. I think it's a good example of a kind of irreverent, easygoing, plain writing about software and computers that's an endangered species in technical writing these days.

If you like this kind of plain writing on early programming languages, the [original K&R C language book](https://www.amazon.com/Programming-Language-2nd-Brian-Kernighan/dp/0131103628) is of very similar style, not the least because it shares an author with the Awk book.

<a href="https://ia802309.us.archive.org/25/items/pdfy-MgN0H1joIoDVoIC7/The_AWK_Programming_Language.pdf" class="button">Read PDF &rarr;</a>

### _Efficient implementation of the Smalltalk-80 system_, Deutsch & Schiffman

Along with the paper on _Self_ also highlighted in this section, this paper on the optimization of the Smalltalk-80 runtime pioneered performance work on highly dynamic object-oriented languages that were impractical for industrial usage at the time, but would become the dominant programming language paradigm. Techniques for implementing short-lived closures and dynamic dispatch first discussed here are found in modern JavaScript implementations, for example. In particular, the inline dynamic dispatch cache that the paper discusses is the conceptual predecessor to modern languages' polymorphic inline caches (PICs). This paper is one of my favorites in PL history because it's short and to the point, but delivers a result that has had an enormous impact on language research and implementation in the wild.

<a href="http://web.stanford.edu/class/cs343/resources/smalltalk-80.pdf" class="button">Read PDF &rarr;</a>

### _Iterative Type Analysis and Extended Message Splitting_, Chambers & Ungar

The full title of this paper is _Iterative Type Analysis and Extended Message Splitting: Optimizing Dynamically-Typed Object-Oriented Programs_. It details research from building an optimizing compiler for the [Self](https://en.wikipedia.org/wiki/Self_(programming_language)) programming language, a prototype-based object-oriented language from the 90's that had lasting impact on the design of languages that followed like Java and JavaScript. The paper demonstrates that compile-time static analysis of programs written in dynamic languages can bridge the performance gap between those languages and statically typed, compiled languages like C.

The optimization techniques first used in Self's compilers like type specialization and abstract interpretation would have a huge influence on the performance work that went into Java's virtual machines at Sun and modern JavaScript engines. These kinds of optimization techniques are the reason dynamic object-oriented languages like JavaScript have become ubiquitous high-performance mainstream languages today.

<a href="https://bibliography.selflanguage.org/_static/iterative-type-analysis.pdf" class="button">Read PDF &rarr;</a>

## Theory

### _Communicating Sequential Processes_, C. A. R. Hoare

Commonly called "CSP", this seminal paper by Hoare presents a programming paradigm where programs are built by composing together concurrent, smaller programs that communicate with each other by passing data between them. CSP is a big inspiration for concurrency-focused languages like Erlang and Go.

<a href="https://www.cs.cmu.edu/~crary/819-f09/Hoare78.pdf" class="button">Read PDF &rarr;</a>

### _Notation as a Tool of Thought_, Ken Iverson

This celebrated paper is a Turing Award Lecture from the winner of the 1979 Turing Award. [Ken Iverson](https://en.wikipedia.org/wiki/Kenneth_E._Iverson) is the inventor of the [APL](https://en.wikipedia.org/wiki/APL_(programming_language)) programming language, and in the lecture Iverson discusses desirable traits of mathematical and programming notation to help us think better, and makes a case that APL is one such notational tool.

Though I'm not an APL programmer even a little bit, I enjoyed thinking about the traits that Iverson identifies for good, constructive notation for thought, and how we can apply this thinking more generally to abstractions in software tooling in general.

<a href="https://www.eecg.utoronto.ca/~jzhu/csc326/readings/iverson.pdf" class="button">Read PDF &rarr;</a>

### _In Search of an Understandable Consensus Algorithm_, Ongaro & Ousterhout

[Raft](https://raft.github.io/) is a modern distributed consensus algorithm. The Raft algorithm implements a way for a group of independent machines that are not 100% available in a network to work together and agree on a single version of reality and sequence of events. Before Raft, the de-fact open source consensus algorithm was [Paxos](https://en.wikipedia.org/wiki/Paxos_(computer_science)) which is criticized for being extremely difficult to learn or implement correctly. One of Raft's goals is understandability, and I think it succeeds. Raft is an interesting entrypoint into the deep world of distributed computing primitives, the ideas baked into platforms like Cassandra and MongoDB that we often take for granted.

<a href="https://raft.github.io/raft.pdf" class="button">Read PDF &rarr;</a>

## Internet and the Web

### _RFC 2068_, Tim Berners-Lee et. al.

This RFC isn't really a paper, either, but it's one of those documents that shed a light on the birth of a lasting technological trend. RFC 2068 is the HTTP 1.1 protocol proposal. Published in 1997, this is the earliest complete specification (that I could find) for the version of HTTP that runs the Web today. It's a technical specification, so comes with all the overhead of specs -- it's long, intended for spec implementers and not for the average programmer. But I think it's an interesting historical artifact of the Web.

<a href="https://tools.ietf.org/html/rfc2068" class="button">Read RFC &rarr;</a>

