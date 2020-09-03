---
title: "System calls in the Minimum Viable Go Program"
date: 2020-09-03T13:13:06-04:00
toc: true
draft: true
---

Started by studying the output of

```
strace ink -eval "out('hello world')" > /dev/null
```

... but let's just focus on the Go stuff, since that's more widely relevant. Ink probably doesn't do much more on top.

Things to keep in mind:

- x86 Linux specific
- dynamically linked Go binary will have dylib accesses we should (could?) ignore. If so, run a statically linked binary.
- for most syscalls we can just `man syscall_name` to study it initially.
