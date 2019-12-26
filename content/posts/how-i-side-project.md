---
title: "How I side project"
date: 2019-07-22T00:00:00-00:00
location: "San Francisco, CA"
---

(This is an archived copy of a post originally published at [thesephist.com](https://thesephist.com/posts/how-i-side-project/).)

This post started out as a long-form response to this tweet by Raj Kunkolienkar:

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Question to all the side project machines that I follow (with much respect) : what framework / setup / infrastructure / tools do you use to push out ideas to MVP so quickly?<a href="https://twitter.com/kognise?ref_src=twsrc%5Etfw">@kognise</a> <a href="https://twitter.com/thesephist?ref_src=twsrc%5Etfw">@thesephist</a> <a href="https://twitter.com/jajoosam?ref_src=twsrc%5Etfw">@jajoosam</a></p>&mdash; Raj Kunkolienkar 🚀 (@kunksed) <a href="https://twitter.com/kunksed/status/1130681972794175490?ref_src=twsrc%5Etfw">May 21, 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

... but then, I got busy, a few weeks passed, and it took a while for me to get back to it. On the upside, I have a new place for my ramblings now, which is [dotink.co](https://dotink.co). It's meant to be a more technical blog for when I want to talk more about software and design, but we'll see how things go.

## Side projects

Over the last year, it seems like I've developed a habit of working on and releasing a large number of side projects, from the mundane (like [the blocks.css library](https://thesephist.github.io/blocks.css/)) to the interesting (like [Sounds from Places](https://soundsfromplaces.surge.sh)) to the technical (like [making a new programming language](https://github.com/thesephist/ink)). Everybody's process and working style is different, but I thought it may be interesting to share how I think about side projects, and go from question to idea to execution to promotion.

For me, a side project is always some mixture of learning something new, fixing some problem I have in my life, or making something that I wish existed in the world, but doesn't. I usually first get the idea for a project from needing to scratch some itch in my life or from an idea someone tosses out, but I let it simmer on my to-do list for a while before deciding that it's worth spending some time on it to make it real.

### Ideas

If I ventured a guess, I'd say I only attempt to build about 20% of the project ideas I write down, and end up working on only about half of that 20% to completion. So in total, given that I don't always write down all of the ideas I have, less than one in ten ideas I have ever become useful side projects. Some are left on the cutting room floor because I don't have time, and others are abandoned because I just end up without the time to finish them once I start.

Here are some ideas I currently have on my to-do's, but may not get to for some time.

- "FreeBusy", a web app that allows people to find a time that's open on my calendar and suggest or schedule a meeting time quickly without email back-and-forths.
- `goodfirstissue.org`, a website with guides and interactive tools to help first-time open-source contributors find easy, low-barrier ways to get involved in open source software using GitHub's APIs.
- A "shopping cart for nonprofits". I think there's something psychologically satisfying about collecting items into a metaphorical shopping cart and "checking out". It may be interesting if we can redesign the experience of giving to nonprofits to be more like online shopping, and less like finding your way around a 10-year-old website for an online bank that hasn't had a developer on staff for a year.
- "Gestural", a JavaScript library for making multi-touch gesture recognition easy on the web. This was inspired by my positive experience building [Animated Value](https://linus.zone/av), a small library for physics-based web animations.
- A new version of my personal / internal dashboard for keeping track of the health of my servers / apps I run. I have an older implementation called Callisto, but it's starting to show its age.
- "Ren", a code editor that edits at the level of the abstract syntax tree, not the text content of the program. Check out [this earlier experiment](https://www.facebook.com/notes/kent-beck/prune-a-code-editor-that-is-not-a-text-editor/1012061842160013/) by another engineer for a taste of what it might become.
- A read-it-later service. I currently use Pocket, but have some complaints and shortcomings that I'd like to address with a homebrew solution.
- "Nocturne", a Dropbox replacement. I love Dropbox for its core features, but their consumer offering has been bloating at intergalactic speeds recently.

(If any of these ideas strike your fancy, feel free to start a conversation with me or go implement it yourself! I don't own these ideas.)

So... I've got a lot simmering on my mind. You'll notice that most of these are intended to just solve some minor problem or complaint I have with my current workflow. Some of these ideas are more fueled by personal curiosity, or thinking "wouldn't it be really cool if this existed?" The shopping-cart-for-nonprofits is one such idea, and an earlier project called [Sounds from Places](https://soundsfromplaces.surge.sh) is another like it.

This part -- getting ideas -- feels like the hardest part of my side project puzzle to describe, because I don't really ever sit down and think, "Okay, what should I built next?" I try to remember and write down ideas when they come up in conversation or in the shower, and remember to check back on that list whenever I have some free cycles in my life.

### Naming

Definitively the most important part of my workflow!

Jokes aside, names do mean a lot to me. At the beginning of a project, I don't really know what its public name is going to be at the end, so I usually end up giving the project some codename that I can use to identify it, until I settle on a good launch name. For example, [Studybuddy](https://getstudybuddy.com) was codenamed "gemini", [Zero to Code](https://zerotocode.org) was codenamed "Trident", and my upcoming personal to-do app is codenamed "sigil".

And obviously, some codenames stick around post-launch, like [Torus](https://github.com/thesephist/torus) and [Ink](https://github.com/thesephist/ink). Some names are also decided from the get-go. [Codeframe](https://beta.codeframe.co), [Looking Glass](https://github.com/thesephist/looking-glass), and [blocks.css](https://github.com/thesephist/blocks.css) were all named from the beginning.

I try to give projects names that reflect something about the idea, but are relatively unique and sound good to my ear. I get a lot of inspiration from foreign languages, some from thesauruses and archaic names for people and places, and occasionally, made-up words.

### Start when the motivation's high

The number-one advice I have when people ask me how to productively work on side projects is this -- **when you first have the idea, you have more motivation to work on the project than you will for a while, so start immediately.**

This isn't always practical, and sometimes life just gets in the way. But I find that when I have an idea and immediately get down and dirty prototyping within a few hours, I can always crank out a working prototype that looks usable within the same day. Codeframe, Studybuddy, Zero to Code, Looking Glass, blocks.css, and [Lyrics.rip](https://genius.com/a/a-teen-programmer-built-a-tool-called-lyrics-rip-to-generate-fake-lyrics-for-your-favorite-artists) were all mostly built the same day I had the idea and got down to it right then.

There are counterexamples -- Torus took about 3 weeks with a 5-month hiatus in between, [Ink](https://github.com/thesephist/ink) has been about two months in the making with a month hiatus in between, and Sounds from Places languished on my computer untouched for so long that when I got back to it, I scrapped everything and started over.

But on balance, I find that whenever I get a chance to start on a project the same day I have the idea, I'm the most energized and excited about the idea, and able to get the most done and stay focused easily. When I manage to do this, I almost always get to a presentable prototype in 6-8 hours. Most of what you see on my Facebook and Twitter are prototypes after this 6-8 hour initial sprint, and sometimes it's in a good enough shape that I don't really feel the need to touch it after that, like [Calhacks.org](https://calhacks.org).

### Picking out obstacles from my workflow

After getting started immediately, the next trick that has helped me become the most productive in the last year has been to consciously remove obstacles from my side project workflow. _What kind of obstacles?_, you might ask. Here's a non-comprehensive list of things that I may have spent hours doing last year, that are now trivial or take just a few minutes.

- It used to take me hours to get everything set up to deploy a project, from getting a domain to setting up DNS, finding a server, getting all the configurations right, and so on. These days, depending on the kind of project, I can deploy it within seconds or minutes of it being done. I don't need to think about it these days, and it's mostly due to repetition and practice that I've gotten to this point. I use [Surge.sh](https://surge.sh) for static deploys, (Zeit Now)(https://zeit.co) for serverless deployments, and my custom server infrastructure on [DigitalOcean](https://digitalocean.com) for more heavyweight apps and services.
- Having built a variety of apps, I now have some template or framework that I can copy from a previous project when I start almost anything new. I use [Torus](https://github.com/thesephist/torus), my frontend framework, for all my web projects, and I have a template I copy for my backend projects and static sites. I have a lightweight slap-on CSS library for making things look good with low effort with blocks.css, and these templates and copy-paste snippets make getting started super quick, even with fairly involved projects. I was only able to release [RecruitBot](https://github.com/calhacks/recruitbot) in 6 hours because I could lean on both my frontend framework and a backend I copy-pasted from Studybuddy, and because I could easily deploy it on a server I had available for my projects. This might not be the most glamorous approach to starting new projects, but it gets me up and running quickly with a new idea, and that matters more than anything at the start. Having these battle-tested tools that I've used over and over again within easy reach has been the single most helpful thing in being able to push out MVPs and prototypes quickly.
- Use a consistent set of small tools, and know it well. Some people use side projects to learn a galaxy of different tools and frameworks and libraries, which is great for them. But I don't really work that way, and I've come to use a really small set of tools and libraries for all of my projects. As a benefit of using a consistent set of tools, I've come to know all the tools I use _very well_. If anything goes wrong, chances are, I've probably seen and solved the problem before, and I can probably fix it with a single Google search at most. Besides the ones mentioned above, these tool are Vim and Tmux for text editing and working in the command line, Chrome Developer Tools for web development, telnet, curl, dig, and whois for troubleshooting network issues, and Adobe XD for UI prototyping and design, when I need it.
    - This is also one of the reasons I enjoy working with tools I write myself, like Torus and Ink, rather than using other heavyweight libraries or languages -- if something's broken, I can just dive into the source code of the framework or language I'm using and figure out what exactly is going on, because I wrote it!

### Embrace the rough prototype

The first working version of _anything_ is _rough_. It's ugly. It works, but just barely, and it's fragile, and it's so satisfying. Here's a glimpse into those moments from the last week.

This is a 2-by-2-pixel image that I rendered by manually writing each byte to a file in the BMP image format.

<blockquote class="twitter-tweet" data-lang="en"><p lang="en" dir="ltr">Current state of affairs:<br><br>In just under 100 lines of Ink code…. <a href="https://t.co/PXZqh5PxI8">pic.twitter.com/PXZqh5PxI8</a></p>&mdash; Linus (@thesephist) <a href="https://twitter.com/thesephist/status/1151420325462102016?ref_src=twsrc%5Etfw">July 17, 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

Here, I've just managed to render a blurry, blotchy black-and-white image of a Mandelbrot set. I'd go on to polish the algorithm here to render a full-color 1080p image later that night.

<blockquote class="twitter-tweet" data-conversation="none" data-lang="en"><p lang="en" dir="ltr">~67 lines of Ink, and we have the first glimpse of a picture!<br><br>Took most of the last hour troubleshooting a sign error. Smh. <a href="https://t.co/59WnSqo80P">pic.twitter.com/59WnSqo80P</a></p>&mdash; Linus (@thesephist) <a href="https://twitter.com/thesephist/status/1152098082642808832?ref_src=twsrc%5Etfw">July 19, 2019</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

I've been trying to share more and more of my projects at this early "it's kind of mostly working, but only sometimes" stage. I think this is the most satisfying part of early-stage projects. Until this point, I've been working on it fueled purely by the hopes and guesses at whether the project idea would pan out, but once I hit this point, it's easy to see how I could iterate my way to a prettier, smoother, more high-quality, more stable solution. It's the tipping point -- the rough prototype.

Sometimes, I'd be fueled by this moment to keep going, but this is also a safe point to stop and pause, catch up on sleep, get to that meeting I've been pushing back, or whatever else. It's safe to take a break here, because I've hit that tipping point, and I know I can pick things right back up when I return, because there's something already working. But until I get to this point, it feels like an endless sprint.

Once I have the rough, working prototype, it's also a good time to reflect and refactor or rewrite my initial implementation of something. [Torus's HTML parser](https://github.com/thesephist/torus/blob/master/src/jdom.js) went through a big rewrite a week into the project, because I thought of a much faster, less bug-prone design. But I couldn't take risks in rewriting the parser until it was at least complete.

No matter the project, the bottom line is, if I get to this rough prototype point, I've done it. There is a thing that does a thing, and sometimes, that's enough of a starting point to feel like it's 80% done.

### Don't be shy about giving up

If you've scrolled through my GitHub repository list or my [unofficial-official personal projects directory](https://linus.zone/projects), you'll know that for every project I've "launched" or finished, there's a graveyard of things I've attempted but given up on. I used to be more troubled by that ratio, but I'm less bothered by it these days.

I think when it comes to personal projects, some ratio of finished- to abandoned-projects is a sign that I'm experimenting and playing around with ideas, and more importantly, that I'm prioritizing judiciously and saying no to things when it doesn't make sense to keep pushing forward on a project that isn't feeling productive or interesting to me anymore. Heck, I have, like, four different versions of a to-do list manager I've attempted and I haven't got a single working version yet. That's a bit annoying, but I think that's fine.

While giving up or stopping work on projects isn't problematic, I do think it's important to find or study what went wrong at each instance and try to avoid the same miscalculation in the future. The tricks I outlined above, about how I try to work on an idea the same day it pops into my head, staying consistent with tools, and so on -- these tricks are the result of thinking about why some projects didn't work out in the end, and considering how I could avoid the same problems in the future.

### Make it easy to iterate

As I've been steadily growing my zoo of active projects, I've been learning to place a greater emphasis on easy maintenance and iteration. In a word, this means making it easily to monitor when things are up and things go down, making it quick to push out updates, to find out what's going wrong, to restore from a backup with minimal effort, and to hit the reset button when something inexplicably explodes without notice.

When I had one or two running projects, if one went down or lost some data, I could just go in, restart it, may be fix a bug that day. But I have more projects in actively operation these days than I can keep in my head, and it's become increasingly important that I figure out the "ops" side of things. I may go into a deeper dive on my personal ops and infrastructure (Tweet at me if you'd like to read about that), but for here, suffice it to say that I've written many a scripts and automation configurations so that I can backup, restore, push out updates, and run tests against changes easily for all of the breakable projects I have running. DigitalOcean's easy backups has been really helpful here, as well as learning some basic shell scripting and automated testing.

### Be ambitious, not comfortable

My most successful projects have been, without question, the ones that I've attempted with _absolutely no clue_ on where I would even start.

When I began working on Apogee, a Chrome extension to cite webpages that ended up growing to about a quarter million users, I could barely write working JavaScript. The first thing I did that night was Google search "how to make a chrome extension". When I started writing Torus, I had used frameworks like Backbone before, but had no clue how I would go about writing my own. And my latest pet project, [Ink](https://github.com/thesephist/ink) started when I barely knew what parsers were, let alone understand how interpreters and compilers worked deep under the hood.

I compensated for these holes in my knowledge with two useful skills: typing quickly and precisely into Google Search, and not being afraid of reading and re-reading things I didn't fully understand until I did. For the Ink project in particular, for the last month, I've probably been reading 1000-2000 words per day on compilers, language design, garbage collectors, memory management, and a bunch of other related topics. I'm still confused about lots of things, but I have a _far_ better understanding of what's going on on my computer than I did prior, and I have a mental compass for what topics I should poke into next. (In particular, big thanks to [Crafting Interpreters](http://craftinginterpreters.com/contents.html), which was invaluable in initially figuring out where the heck I was even supposed to start.)

**Err on the side of being too ambitious, and don't worry about starting in your comfort zone.** I find that the most satisfying, interesting, fulfilling projects are the ones where I had to find and draw the map as I went.

### Sharing

Lastly, I'd like to do more of what I'm doing right now -- sharing, talking about what I'm working on and what I'm learning, what's interesting and surprising, and occasionally, about how I work personally and what makes my schedule tick, if it's interesting to you.

It surprises me what kinds of projects people find interesting. Sounds from Places wasn't technically interesting at all -- just a static site linking to some MP3 files -- but that received the warmest reception online that I've had for any project except Lyrics.rip. Neither project was technically challenging or involved brilliant strokes of insight, but I think they were artistically interesting and fun ideas, and that seems to be what sparks people's imaginations more than custom programming languages or frontend frameworks.

I like to joke that, in an alternate timeline, my dream career would to be move to LA to become a professional concert pianist and composer. I'm constantly amazed by what art can communicate -- well-crafted art doesn't necessarily communicate technical knowledge or know-how, but it begs interesting questions and opens up people's imaginations in unexpected ways.

Even as my personal projects continue to be a way for me to learn and experiment with technologies, I hope I can get to a point where I can also build things that go beyond that, to be tools that artists can use to tell better stories or find better media for their ideas, or even to open up new and interesting questions altogether.

At any rate, I'll keep hacking and sharing, and I appreciate you being here to tune in when things get interesting. If you've got thoughts or questions, you can [share it and discuss on Hacker News](https://news.ycombinator.com/item?id=20551571).
