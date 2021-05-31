---
title: "The Ink blog"
---

<p><img class="blend-multiply logo-img" src="/img/logo.png" alt="Ink programming language logo"></p>

# The Ink blog

I'm [Linus](https://thesephist.com). In 2019, I made a programming language called **Ink**. Since then, I've used it to [build a number of side projects](/docs/projects/), including a ray tracer, a compiler, an assembler, a Twitter client, a writing app, and some personal productivity tools. I write about Ink, programming languages, and software at large on this blog, which is served by a [server written in Ink](https://github.com/thesephist/dotink/blob/master/src/fileserver.ink).

Ink takes after Go, JavaScript, and Lua. Here's a simple Ink program.

<iframe src="https://play.dotink.co/?embed=1&code=%60%20Ink%20prime%20sieve%20%60%0A%0A%60%20is%20a%20single%20number%20prime%3F%20%60%0Aprime%3F%20%3A%3D%20n%20%3D%3E%20(%0A%09%60%20is%20n%20coprime%20with%20nums%20%3C%20p%3F%20%60%0A%09max%20%3A%3D%20floor(pow(n%2C%200.5))%20%2B%201%0A%09(ip%20%3A%3D%20p%20%3D%3E%20p%20%3A%3A%20%7B%0A%09%09max%20-%3E%20true%0A%09%09_%20-%3E%20n%20%25%20p%20%3A%3A%20%7B%0A%09%09%090%20-%3E%20false%0A%09%09%09_%20-%3E%20ip(p%20%2B%201)%0A%09%09%7D%0A%09%7D)(2)%0A)%0A%0A%60%20primes%20under%20N%20are%20numbers%202%20..%20N%2C%20filtered%20by%20prime%3F%20%60%0AgetPrimesUnder%20%3A%3D%20n%20%3D%3E%20filter(range(2%2C%20n%2C%201)%2C%20prime%3F)%0A%0A%60%20log%20result%20%60%0Aprimes%20%3A%3D%20getPrimesUnder(100)%0Alog(f('Primes%20under%20100%3A%20%7B%7B%200%20%7D%7D'%2C%20%5BstringList(primes)%5D))" frameborder="0" class="maverick"></iframe>

<a href="/docs/overview/" class="button">An overview of Ink &rarr;</a>
<a href="https://inkbyexample.com/" class="button">Ink by Example &rarr;</a>
