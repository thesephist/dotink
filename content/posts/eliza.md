---
title: "Isomorphic Ink: code sharing between native and Web in Eliza"
date: 2021-03-03T20:03:53-05:00
---

Last week, I launched **[Eliza](https://eliza.dotink.co/)**, a chatbot modeled after the classic MIT conversational program and written entirely in Ink. Though the project itself isn't novel or interesting -- it's mostly a port of existing implementations of EIZA -- Eliza is built as an _isomorphic_ Ink application, meaning a substantial part of the codebase can run both natively, on a server, and on the client (a Web browser).

<a href="https://github.com/thesephist/eliza" class="button">See Eliza on GitHub &rarr;</a>
<a href="https://eliza.dotink.co/" class="button">Try Eliza &rarr;</a>

This allows Eliza to have both a command-line interface and a Web app. The CLI runs on a native Ink interpreter like the [Go-based interpreter](https://github.com/thesephist/ink) and the Web UI is Ink compiled down to JavaScript with [September](/posts/september/).

![Screenshot of Eliza running in a browser](/img/eliza.png)

For an app like Eliza, where the critical business logic (the code for generating a response to a user query in this case) is independent of a particular runtime platform, writing Ink programs that can run on any platform is useful. It means we can write one implementation of some logic and literally reuse it in many different clients. In fact, the Ink standard libraries (`std` and `str`) have already been used in this way in the September compiler when compiling Ink programs to JavaScript. Eliza takes this to the next level and runs much more complex logic, like the conversational algorithm, across platforms.

In this post, I want to give a brief overview of the Eliza project and share the process of building a real-world isomorphic app in Ink.

## Eliza, a chatbot writte in Ink

The original [ELIZA](https://en.wikipedia.org/wiki/ELIZA) was one of the first "chat bots". Invented in the MIT AI lab in the mid-60's, it demonstrated how a simple heuristic-based

// regex grammar file
// doctor
// demonstrating simplicity of conversation
// limits
// Ink implementation at a high level of the algorithm

    <iframe src="https://eliza.dotink.co" frameborder="0" style="width:100%;min-height:500px"></iframe>

## Making isomorphic Ink possible

// test suites, compiler feature parity, etc.
// torus adapter, include sample UI code.

## Future work

// what is lacking in the experience of writing web apps in ink?

