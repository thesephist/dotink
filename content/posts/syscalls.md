---
title: "Minimum Viable Syscalls of the Ink interpreter"
date: 2020-07-29T13:13:06-04:00
toc: true
draft: true
---

Studying the output of

```
strace ink -eval "out('hello world')" > /dev/null
```

Things to keep in mind:

- x86 Linux specific
- dynamically linked `ink` binary will have dylib accesses we should (could?) ignore. If so, run the statically linked binary from `/noctd`
- for most syscalls we can just `man syscall_name` to study it initially.
- what's the Go runtime's syscalls vs our own?
