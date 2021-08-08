---
title: "Open-source Ink projects"
brief: A growing list of Ink projects, from web apps to ray tracers to interpreters and compilers
toc: true
---

## Projects

### Monocle

![Screenshot of Monocle running on iPads](/img/monocle-banner.png)

Monocle is my universal, personal search engine. It can query across tens of thousands of documents from my blog posts, journal entries, notes, Tweets, contacts, and more to act as my extended memory spanning my entire life. Monocle is designed with a focus on speed, privacy, and hackability. It's built on top of a full text search engine built from scratch in Ink that runs both natively and in the browser.

<a href="https://thesephist.com/posts/monocle/" class="button">Blog post</a>
<a href="https://monocle.surge.sh" class="button">Try demo &rarr;</as>
<a href="https://github.com/thesephist/monocle" class="button">See on GitHub &rarr;</a>

### Lucerne

![A screenshot of Lucerne displaying a timeline](/img/lucerne.png)

Lucerne is a Twitter reader and web client designed to amplify my personal Twitter workflows around learning from conversations and sharing my own writing and projects. Lucerne is built around the concept of persistent search filtered called "channels" and designed around my needs from the Twitter platform. The client is written from scratch in Ink, including the various cryptographic algorithms needed to interface with Twitter's API.

<a href="https://thesephist.com/posts/lucerne/" class="button">Blog post</a>
<a href="https://github.com/thesephist/lucerne" class="button">See on GitHub &rarr;</a>

### Ink codebase browser, _"Kin"_

![Screenshots of Ink codebase browser running on a browser window and an iPhone](/img/kin.png)

The Ink codebase browser is a refined tool for exploring open-source projects on GitHub. Compared to the experience of clicking through file hierarchies and previews on GitHub's website, this app provides you with a file tree, rich Markdown and image previews, multi-pane multi-tab layouts and first-class support for Ink syntax highlighting.

<a href="https://code.dotink.co" class="button">Try demo &rarr;</as>
<a href="https://github.com/thesephist/kin" class="button">See on GitHub &rarr;</a>

### Merlot

![Photos of Merlot running on various devices](/img/merlot-devices.png)

Merlot is a writing app for the Web that supports drafting in Markdown, and was designed to fit neatly into my blogging and writing workflow. It's built entirely and purely with Ink: the Markdown engine that runs on both the backend and the web app is written in Ink. The backend is written in Ink to run natively, and the client is written in Ink and, alongside the Markdown library, compiled down to a single-page JavaScript application.

<a href="https://merlot.vercel.app/" class="button">Try demo &rarr;</a>
<a href="https://github.com/thesephist/merlot" class="button">See on GitHub &rarr;</a>

### Sistine

![Screenshot of Sistine's documentation site, built with Sistine](/img/sistine-screenshot.png)

Sistine is a simple, flexible, productive static site generator written entirely in Ink and built on [Merlot](#merlot)'s Markdown engine. Although it's a work in progress, Sistine is meant to eventually become a part of my primary blogging infrastructure. The documentation site is built with Sistine already, and serves as a demo.

<a href="https://sistine.vercel.app/" class="button">Visit demo site &rarr;</a>
<a href="https://github.com/thesephist/sistine" class="button">See on GitHub &rarr;</a>

### Traceur

![Path traced scene generated with Traceur](/img/traceur.bmp)

Traceur is a path-tracing renderer in Ink, supporting Monte-Carlo antialiasing, realistic shadows, reflections, refractions, and focus blur.

<a href="/posts/traceur/" class="button">Blog post</a>
<a href="https://github.com/thesephist/traceur" class="button">See on GitHub &rarr;</a>

### Klisp

![The Klisp repl](/img/klisp.png)

Klisp is a very minimal LISP written in Ink. It's primarily a pedagogical project -- I made it to understand Lisp better. Ink's semantics are already quite Lispy, so Klisp builds on Ink's semantics and adds an S-expression grammar and a repl, a true read-eval-print loop, for an ergonomic Lisp experience.

<a href="/posts/klisp/" class="button">Blog post</a>
<a href="https://github.com/thesephist/klisp" class="button">See on GitHub &rarr;</a>

### Nightvale

![Nightvale sandbox screenshot](/img/nightvale.png)

Nightvale is an interactive notebook in the browser for literate programming and communicating computational ideas using prose, mathematical notation, and Klisp code. Nightvale runs entirely on Ink on the backend and on [Torus](https://github.com/thesephist/torus) on the client.

<a href="/posts/nightvale/" class="button">Blog post</a>
<a href="https://nightvale.dotink.co/" class="button">Try the Nightvale sandbox &rarr;</a>

### Histools analyzer

![Histools screenshot](/img/histools.png)

Histools is a collection of tools for generating heatmaps and data visualizations from browser history data. Ink is used for a small script that exports and transforms data for display.

<a href="/posts/histools/" class="button">Blog post</a>
<a href="https://github.com/thesephist/histools" class="button">See demo on GitHub &rarr;</a>

### Eliza

![A screenshot of Eliza's web interface](/img/eliza.png)

Eliza is an implementation of the classic 1960's chat bot written in isomorphic Ink, so that the same algorithm can run on the server (through the native interpreter) and the browser (through [September](/posts/september/)). This Ink version of Eliza provides a command-line chat interface and a web app powered by the same Ink algorithm.

<a href="/posts/eliza/" class="button">Blog post</a>
<a href="https://github.com/thesephist/eliza" class="button">See on GitHub &rarr;</a>
<a href="https://eliza.dotink.co/" class="button">Try Eliza &rarr;</a>

### Inc(remental)

![A screenshot of Inc's history feature to see a timeline of my note-taking history](/img/inc-remental.jpg)

Inc (short for _incremental_) is a note-taking tool based on the principles of [incremental note-taking](https://thesephist.com/posts/inc/), designed for quickly capturing fleeting ideas and growing a knowledge base over time. It's built with Ink as an interactive command-line application.

<a href="https://thesephist.com/posts/inc/#incremental" class="button">Blog post</a>
<a href="https://github.com/thesephist/inc" class="button">See on GitHub &rarr;</a>

### Matisse

![A grid of images generated by Matisse](/img/matisse.jpg)

Matisse is a minimalistic gallery of generative art pieces that are written in Ink. As a web app, Matisse depends on the September compiler to compile Ink programs and algorithms down to JavaScript.

<a href="https://github.com/thesephist/matisse" class="button">See on GitHub &rarr;</a>
<a href="https://matisse.vercel.app/" class="button">Try demo &rarr;</a>

### Micropress

Micropress is an Ink library for _automatic text summarization_, using an extractive algorithm built on a custom tokenizer from the [Monocle](#monocle) project. Micropress can take an arbitrarily long document, like a blog post, and generate a summary of much shorter length by finding key sentences in the document that are most representative of the main ideas in the text.

<a href="https://github.com/thesephist/micropress" class="button">See on GitHub &rarr;</a>

### Polyx

Polyx is Linus's personal productivity suite which includes services like file sync, notes, contacts, and other information management tools.

<a href="https://github.com/thesephist/polyx" class="button">See on GitHub &rarr;</a>

### August

August is an educational assembler written from scratch in Ink, supporting 64-bit x86 ELF executables to start with more under development. It features an x86_64 instruction encoder and ELF file format library written in Ink.

<a href="/posts/elf/" class="button">Blog Part I</a>
<a href="/posts/x86/" class="button">Blog Part II</a>
<a href="https://github.com/thesephist/august" class="button">See on GitHub &rarr;</a>

### Codeliner

Codeliner generates graphics from program source files that mimic the shape of code displayed on the page.

<a href="https://github.com/thesephist/codeliner" class="button">See on GitHub &rarr;</a>

## Language tooling

### Ink playground, _"Maverick"_

![Screenshot of Ink playground running a prime sieve program](/img/maverick.png)

Maverick is a simple web IDE and REPL for Ink, written in pure Ink and built on a self-hosted September compiler toolchain that runs entirely in the browser. September, the Ink-to-JavaScript compiler, was compiled to JavaScript using itself for this project so that it could compile other Ink programs in the browser.

<a href="/posts/maverick/" class="button">Blog post</a>
<a href="https://play.dotink.co" class="button">Try demo &rarr;</as>
<a href="https://github.com/thesephist/maverick" class="button">See on GitHub &rarr;</a>

### September

September is an Ink to JavaScript compiler, written in Ink itself and tested against Ink's standard library tests. September is also self-hosting -- it can compile itself on Node.js or in the browser.

<a href="/posts/september/" class="button">Blog post</a>
<a href="https://github.com/thesephist/september" class="button">See on GitHub &rarr;</a>

### Ink by Example

Ink by Example is a hands-on introduction to programming in Ink using annotated example programs. The website is run by [@healeycodes](https://healeycodes.com/) and [powered by Ink](https://github.com/healeycodes/inkbyexample/tree/main/src).

<a href="https://inkbyexample.com/" class="button">Visit Ink by Example &rarr;</a>

### dotink

This website is served by a web server written in Ink.

<a href="https://github.com/thesephist/dotink" class="button">See on GitHub &rarr;</a>

### inkfmt

![inkfmt screenshot](/img/inkfmt.jpg)

inkfmt is a self-hosting code formatter for Ink used in almost every Ink project. Under the hood, inkfmt implements a tokenizer for Ink written in Ink itself.

<a href="/posts/inkfmt/" class="button">Blog post</a>
<a href="https://github.com/thesephist/inkfmt" class="button">See on GitHub &rarr;</a>

## Libraries

### ansi.ink

![ansi.ink demo](/img/ansi.png)

`ansi` is an Ink library for printing with ANSI escape sequences to a terminal emulator. It supports basic ANSI colors and cursor movements.

<a href="/posts/ansi/" class="button">Blog post</a>
<a href="https://github.com/thesephist/ansi.ink" class="button">See on GitHub &rarr;</a>

