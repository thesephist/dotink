---
title: "The Ink blog"
---

<p><img class="blend-multiply logo-img" src="/img/logo.png" alt="Ink programming language logo"></p>

# The Ink blog

_A blog by [Linus](https://thesephist.com/) about the human-software interface._

In 2019, I made a programming language for myself called **Ink**. Since then, I've used it to [build a number of side projects](/docs/projects/), including a ray tracer, a compiler, an assembler, a Twitter client, and a few of my personal productivity tools. I write about Ink and software at large on this blog, and it's also served by a [server written in Ink](https://github.com/thesephist/dotink/blob/master/src/fileserver.ink).

Ink takes after Go, JavaScript, and Lua. Here's a simple web server in Ink.

```
std := load('std')
log := std.log

listen('0.0.0.0:8080', evt => evt.type :: {
    'error' -> log('Error: ' + evt.message)
    'req' -> (evt.end)({
        status: 200
        headers: {'Content-Type': 'text/plain'}
        body: 'Hello, World!'
    })
})
```

<a href="/docs/overview/" class="button">An overview of Ink &rarr;</a>
<a href="https://inkbyexample.com/" class="button">Ink by Example &rarr;</a>
