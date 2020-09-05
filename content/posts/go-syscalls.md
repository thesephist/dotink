---
title: "System calls from the Go runtime in the Minimum Viable Go Program"
date: 2020-09-05T13:13:06-04:00
toc: true
---

Go, despite being a fully compiled language, has a sizeable [runtime](https://en.wikipedia.org/wiki/Runtime_system) that helps Go programs handle things like multithreading, input/output, global variable initialization, and memory safety. To provide all of these convenience and safety features, the Go runtime interacts with the operating system in ways that are often opaque to the Go code we write.

In this post, I wanted to study the bare-basics of the Go runtime by looking at the system calls it makes in a blank Go program.

## What's a system call?

Go programs, like web servers or command line utilities you and I might write, communicate with the operating system kernel to interact with hardware, or control resources like files and processes. To communicate this way from a "userland" program like a server to the operating system, the Go program dispatches _system calls_.

System calls are implemented in coordination between the software and the hardware (processor) running the program. Making a syscall usually requires executing a specific assembly instruction (the `syscall` instruction in x86) that switches the processor's execution context from an unprivileged "user" mode to a privileged "kernel" mode and executes the requested syscall. UNIX systems like Linux usually provide a C library (`libc`) that abstracts away this process of making system calls, into C library function calls that other programs can invoke.

The popular operating system standard POSIX defines a few universal system calls across all UNIX variants, including Linux, macOS, and the BSDs. These include most of the best-known syscalls.

- `open` and `close` to open and close a file
- `read` and `write` for... what else? Reading and writing data to a file
- `chmod` and `chown` to change modes and permissions on files and directories
- `gettimeofday` to get the system time
- `stat` and its cousins `lstat`, `fstat`, `fstatat` for returning data about filesystem entries

Linux, however, includes many syscalls not defined in the POSIX spec that implement Linux-specific features. These include syscalls for asynchronous input/output (`aio` and `io_uring`) and additional parameters to the `ioctl` syscall that allow operating system virtualization, for example.

## Tracing syscalls with strace 

Linux provides a convenient way for us to look at exactly which syscalls are being dispatched when we run a program, via the **strace** utility. strace uses another special-purpose syscall `ptrace` to run a given program with special kernel hooks to inspect which system call the program makes. Running a program with strace will tell us exactly what syscalls the program is making to do its job.

Take this minimal C program.

```
#include <stdio.h>

int main() {
    printf("Ink is great!\n");
    return 0;
}
```

We can compile it

```
$ clang main.c -static -O3
```

_Note: we compile it statically here (`-static`) to make our strace output a little cleaner. In a dynamically linked binary, our strace output would contain a lot of noise about how the dynamically linked libraries are read and executed, and for this example, we're going for a minimal output._

We can run the binary with strace by running the following

```
$ strace ./a.out
execve("./a.out", ["./a.out"], 0x7ffd80aa1b30 /* 43 vars */) = 0
arch_prctl(0x3001 /* ARCH_??? */, 0x7ffe58d10f10) = -1 EINVAL (Invalid argument)
brk(NULL)                               = 0x1640000
brk(0x16411c0)                          = 0x16411c0
arch_prctl(ARCH_SET_FS, 0x1640880)      = 0
uname({sysname="Linux", nodename="localhost.localdomain", ...}) = 0
readlink("/proc/self/exe", "/home/thesephist/src/dotink/a.ou"..., 4096) = 33
brk(0x16621c0)                          = 0x16621c0
brk(0x1663000)                          = 0x1663000
mprotect(0x4ad000, 12288, PROT_READ)    = 0
fstat(1, {st_mode=S_IFIFO|0600, st_size=0, ...}) = 0
write(1, "Ink is great!\n", 14)         = 14
exit_group(0)                           = ?
+++ exited with 0 +++
```

At each line, we can see which syscall was made (like `brk`, `uname`, and `write`) and see arguments passed to it, as well as a return value if applicable. For example, in our `write` syscall line, we can see our binary made the `write` syscall with arguments:

- `1` for the file descriptor, which refers to the standard output file
- `"Ink is great!\n"`, the data we wanted to print, or "write", to output
- `14`, the size of data to print (14 bytes in this case)

... and the syscall returned `14`, which reports that all 14 bytes of data were successfully written to the "file".

For syscalls that we aren't familiar with, we can consult the system man(ual) pages by running `man [syscall]`. If we run `man arch_prctl`, for example, we can learn that the syscall "set[s] architecture-specific thread state." It's ok if we're not 100% sure yet what this means, but the page provides enough information for us to dig further if we'd like.

In this way, strace allows us to look at a program from the outside and deduce what it might be doing from the syscalls it makes. Let's take this approach with a minimal Go program to see what the Go runtime might be doing for us under the hood.

## The Go runtime and the Minimum Viable Go program

Here's the "Minimum Viable Go Program," the smallest Go program we can make without stripping out or modifying the runtime. It has a main function that does nothing, and returns nothing.

```
package main

func main() {}
```

We can build and run strace on it like this.

```
$ go build main.go -o ./main
$ strace ./main
```

For this post, I'm running all examples on Fedora 32 running Linux 5.8.4-200 on x86_64, and Go version 1.15. The tools we use here are applicable across other hardware and versions of Linux and Go, but the exact output might vary.

Running strace on the Go program for me emits about 160 lines of output. Let's dive in!

```
execve("./main", ["./main"], 0x7fffe10e1260 /* 43 vars */) = 0
```

Syscall `execve` is the first line in every strace output, because it's the syscall to begin executing a program. In this case, the `execve` syscall is invoked to run the `./main` binary, with command-line arguments (`argv`) set to `["./main"]` and the environment variable parameter set to a pointer, `0x7f...`, which should point to an array of strings showing the environment variables `main` has access to.

```
arch_prctl(ARCH_SET_FS, 0x4cc810)       = 0
```

`arch_prctl`, according to the man page, sets machine architecture-specific thread state. This doesn't explain much, but we also know that the syscall is passed `ARCH_SET_FS`, which means the passed address sets the `FS` register of the thread. Consulting [this StackOverflow response](https://stackoverflow.com/questions/10810203/what-is-the-fs-gs-register-intended-for) tells us that Go probably uses this syscall to initialize some thread-local variables used by the runtime.

```
sched_getaffinity(0, 8192, [0, 1, 2, 3]) = 8
```

`sched_getaffinity` is a syscall that sets some thread scheduling parameters in the Linux kernel, presumably invoked in order for Go to have greater control over how Goroutines are scheduled on top of operating system threads.

```
openat(AT_FDCWD, "/sys/kernel/mm/transparent_hugepage/hpage_pmd_size", O_RDONLY) = 3
read(3, "2097152\n", 20)                = 8
close(3)                                = 0
```

Now here's something more interesting! These three syscalls together open a new file, `hpage_pmd_size`, read 20 bytes of data, and close the file. The `AT_FDCWD` parameter means the path given should be interpreted relative to the current working directory. The second argument to the syscall is a buffer into which data is read, so we know that some number was read from the file. To interpret what this syscall is for, we need to know what the `hpage_pmd_size` file is used for.

According to [the Linux kernel documentation](https://www.kernel.org/doc/html/latest/admin-guide/mm/transhuge.html), reading this file returns the size of a [transparent huge page](https://www.kernel.org/doc/Documentation/vm/transhuge.txt) in the system. THPs are a performance optimization for high performance systems that I won't get into here, but you can explore in the documentation linked here or on Wikipedia if you're curious. As for its relation to the Go runtime, I can't be sure without diving into the Go runtime source code, which I have yet to do.

```
uname({sysname="Linux", nodename="localhost.localdomain", ...}) = 0
```

The syscall `uname` reports information about the current kernel and host. I'm not sure what the Go runtime uses this information for, other than to make system-specific decisions about runtime configuration.

```
mmap(NULL, 262144, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f099db9e000
mmap(NULL, 131072, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f099db7e000
mmap(NULL, 1048576, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f099da7e000
mmap(NULL, 8388608, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f099d27e000
mmap(NULL, 67108864, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f099927e000
mmap(NULL, 536870912, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f097927e000
mmap(0xc000000000, 67108864, PROT_NONE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0xc000000000
mmap(0xc000000000, 67108864, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0xc000000000
mmap(NULL, 33554432, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f097727e000
mmap(NULL, 2165768, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f097706d000
mmap(0x7f099db7e000, 131072, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f099db7e000
mmap(0x7f099dafe000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f099dafe000
mmap(0x7f099d684000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f099d684000
mmap(0x7f099b2ae000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f099b2ae000
mmap(0x7f09893fe000, 4096, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_FIXED|MAP_ANONYMOUS, -1, 0) = 0x7f09893fe000
mmap(NULL, 1048576, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f0976f6d000
mmap(NULL, 65536, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f0976f5d000
mmap(NULL, 65536, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x7f0976f4d000
```

Then we have a bunch of `mmap` calls. `mmap` "maps files or devices into memory." In smaller terms, this means the Go runtime is allocating some parts of the memory for its own bookkeeping. Understanding what these memory segments are used for probably requires peering into the runtime source.

```
rt_sigprocmask(SIG_SETMASK, NULL, [], 8) = 0
sigaltstack(NULL, {ss_sp=NULL, ss_flags=SS_DISABLE, ss_size=0}) = 0
sigaltstack({ss_sp=0xc000002000, ss_flags=0, ss_size=32768}, NULL) = 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
```

These four syscalls set how operating system signals are received by the program thread. Specifically, the Go runtime is setting an alternate "signal stack" at which a signal handler will run. The Go runtime does a lot of work to wrap the OS's signals into nicer interfaces for the Go program author, and I assume this custom signal stack allocation is a part of that. Interestingly, the newly allocated signal stack address starts at `0xc000002000`, which is very close to the segment allocated in one of the `mmap` calls earlier, hinting that the signal stack was probably allocated by an earlier `mmap`.

```
gettid()                                = 134804
```

`gettid`'s job is simple: to return the thread's thread ID, which Go presumably uses for its internal bookkeeping.

```
rt_sigaction(SIGHUP, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0
rt_sigaction(SIGHUP, {sa_handler=0x45bf20, sa_mask=~[], sa_flags=SA_RESTORER|SA_ONSTACK|SA_RESTART|SA_SIGINFO, sa_restorer=0x45c060}, NULL, 8) = 0
rt_sigaction(SIGINT, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0
rt_sigaction(SIGINT, {sa_handler=0x45bf20, sa_mask=~[], sa_flags=SA_RESTORER|SA_ONSTACK|SA_RESTART|SA_SIGINFO, sa_restorer=0x45c060}, NULL, 8) = 0
rt_sigaction(SIGQUIT, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0
rt_sigaction(SIGQUIT, {sa_handler=0x45bf20, sa_mask=~[], sa_flags=SA_RESTORER|SA_ONSTACK|SA_RESTART|SA_SIGINFO, sa_restorer=0x45c060}, NULL, 8) = 0
[...]
rt_sigaction(SIGRT_31, {sa_handler=0x45bf20, sa_mask=~[], sa_flags=SA_RESTORER|SA_ONSTACK|SA_RESTART|SA_SIGINFO, sa_restorer=0x45c060}, NULL, 8) = 0
rt_sigaction(SIGRT_32, NULL, {sa_handler=SIG_DFL, sa_mask=[], sa_flags=0}, 8) = 0
rt_sigaction(SIGRT_32, {sa_handler=0x45bf20, sa_mask=~[], sa_flags=SA_RESTORER|SA_ONSTACK|SA_RESTART|SA_SIGINFO, sa_restorer=0x45c060}, NULL, 8) = 0
```

Then we have many, _many_ `rt_sigaction` calls, with basically every signal the process can receive. `rt_sigaction` sets custom signal handlers for signals the process can receive, like `SIGHUP` and `SIGINT`. Paired with the custom signal stack allocation from earlier, this allows the Go runtime to wrap OS signals in something that's more uniform or easier for the Go program itself to handle.

```
clone(child_stack=0xc000046000, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM) = 134805
clone(child_stack=0xc000048000, flags=CLONE_VM|CLONE_FS|CLONE_FILES|CLONE_SIGHAND|CLONE_THREAD|CLONE_SYSVSEM) = 134806
```

Some of you might be familiar with the `fork` syscall, which "forks" a process to create a child process. `clone` is a more modern syscall to create a child process. The man page elaborates on the difference:

>By contrast with fork(2), these system calls provide more precise control over
>what pieces of execution context are shared between the calling process and
>the child process.  For example, using these system  calls,  the  caller  can
>control  whether  or not the two processes share the vir‐ tual address space,
>the table of  file descriptors,  and the  table  of  signal handlers.  These
>system calls also allow the new child process  to  be  placed  in  separate
>namespaces(7).

In this case, the `CLONE_THREAD` bitmask passed to the syscall tells us these `clone` calls are used to spawn threads instead of full-blown processes, for use by the garbage collector and the I/O thread in the Go runtime.

```
rt_sigprocmask(SIG_SETMASK, ~[], [], 8) = 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
rt_sigprocmask(SIG_SETMASK, ~[], [], 8) = 0
rt_sigprocmask(SIG_SETMASK, [], NULL, 8) = 0
--- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=134804, si_uid=1000} ---
rt_sigreturn({mask=[]})                 = 0
--- SIGURG {si_signo=SIGURG, si_code=SI_TKILL, si_pid=134804, si_uid=1000} ---
rt_sigreturn({mask=[]})                 = 0
```

I'm a bit stumped by these signaling handling syscalls here. `rt_sigprocmask` controls blocked signals to threads (of which there are now 2), and `rt_signreturn` resets the signal stack in response to the `SIGURG` signals, but I'm less certain on why those signals were sent, or why the masks are necessary. Nonetheless, they're here for completeness's sake.

```
futex(0xc000036548, FUTEX_WAKE_PRIVATE, 1) = 1
futex(0x4cc8c8, FUTEX_WAIT_PRIVATE, 0, NULL) = 0
futex(0xc000100148, FUTEX_WAKE_PRIVATE, 1) = 1
futex(0xc000080148, FUTEX_WAKE_PRIVATE, 1) = 1
futex(0x4cc8c8, FUTEX_WAIT_PRIVATE, 0, NULL) = -1 EAGAIN (Resource temporarily unavailable)
```

Futexes are [mutexes](https://en.wikipedia.org/wiki/Futex) provided by the Linux kernel. It's impossible to tell what kinds of tasks these futexes are synchronizing, but there's presumably some work being done across the threads here. These futexes help the threads wait on and trigger synchronization points, so the program doesn't run into concurrency bugs.

```
exit_group(0)                           = ?
+++ exited with 0 +++
```

Ah, now, we can end on something familiar. The `exit_group` syscall is like the `exit` syscall to end a program process, but `exit_group` exits all threads in the program. Unlike the other syscalls here, `exit_group` doesn't have a return value (`?`) because, well, the program is no longer running.

## Wrap-up

`strace` is just one of the many, many ways to instrument and study programs from the outside, and besides peering into complex black boxes like the Go runtime, strace is also uniquely useful for answering questions like:

- What files is this program accessing on my system?
- Why is my program not printing any output?
- Is this program accessing any data or files it shouldn't be allowed to?

If you want to learn more about strace and syscalls, Julia Evans has a [great Strange Loop talk about strace you should watch](https://www.youtube.com/watch?v=0IQlpFWTFbM).
