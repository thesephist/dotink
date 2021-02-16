---
title: "Assembler in Ink, Part I: processes, assembly, and ELF files"
date: 2021-02-10T18:33:58-05:00
toc: true
---

Over the holidays, I decided to learn about the lower level components of programs by writing an assembler and linker from scratch. Assembly and linking are two of the last steps of a typical "compile" process that generates an executable file from an assembly program, and going through the process of building a basic x86 assembler revealed a lot about the inner workings of programs and operating systems I didn't know before.

The mini assembler/linker I built is written in Ink, of course, and is called _August_, like the autumn month. It contains some internal libraries to work with ELF files and assemble x86 instruction text, but is otherwise quite a simple learning project.

<a href="https://github.com/thesephist/august" class="button">See August on GitHub &rarr;</a>

In the next couple of blogs, I want to share my process of building the assembler, and shed some light on aspects of computers I learned through the build process, from operating system internals to interesting facts about assembly programs and machine code.

We'll start where I started, by figuring out exactly what goes in an assembler.

## What's in an assembler?

When I started out, what I really wanted was to bridge the gap between the lowest-level part of programs that I knew about, assembly source code, and the underlying processor running in the computer. It turns out there are two different steps we need to perform to transform assembly source into executable machine code for the processor, and they're referred to as **assemble** and **link** steps, respectively. Depending on the tool, some assemblers may perform both jobs (like August) while others like NASM only perform the assemble step, and rely on _linkers_ like `ld` to perform the second step.

Here's our high level roadmap. We need to go from x86 assembly, which looks like this for a Hello World program:

_(If you've written x86 assembly before, you might notice this isn't standard syntax. Because August is a toy assembler, I made some subjective aesthetic choices in syntax to make parsing a little simpler and syntax a little nicer, but it shouldn't get in the way of reading the code. Notably, we don't have commas separating arguments, we don't have the `global` directive because every symbol is global, and data segment syntax is a little different.)_

```
section .text

_start:
    mov eax 0x1     ; write syscall
    mov edi 0x1     ; stdout
    mov esi msg     ; string to print
    mov edx len     ; length
    syscall

exit:
    mov eax 60      ; exit syscall
    mov edi 0       ; exit code
    syscall

section .rodata

msg:
    db "Hello, World!" 0xa
len:
    eq 14
```

... to a binary file that the operating system (in my case, Linux) can understand and spin up into a process. If I compile the above with the latest version of August and dump the resulting file with `xxd`, I get file a few kilobytes large:

```
$ august ./hello-world.asm ./hello-world
$ xxd -a ./hello-world

00000000: 7f45 4c46 0201 0100 0000 0000 0000 0000  .ELF............
00000010: 0200 3e00 0100 0000 0010 4000 0000 0000  ..>.......@.....
00000020: 4000 0000 0000 0000 8320 0000 0000 0000  @........ ......
00000030: 0000 0000 4000 3800 0200 4000 0500 0400  ....@.8...@.....
00000040: 0100 0000 0500 0000 0010 0000 0000 0000  ................
00000050: 0010 4000 0000 0000 0010 4000 0000 0000  ..@.......@.....
00000060: 0010 0000 0000 0000 0010 0000 0000 0000  ................
00000070: 0010 0000 0000 0000 0100 0000 0400 0000  ................
00000080: 0020 0000 0000 0000 0050 6b00 0000 0000  . .......Pk.....
00000090: 0050 6b00 0000 0000 0e00 0000 0000 0000  .Pk.............
000000a0: 0e00 0000 0000 0000 0010 0000 0000 0000  ................
000000b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
*
00001000: b801 0000 00bf 0100 0000 be00 506b 00ba  ............Pk..
00001010: 0e00 0000 0f05 b83c 0000 00bf 0000 0000  .......<........
00001020: 0f05 0000 0000 0000 0000 0000 0000 0000  ................
00001030: 0000 0000 0000 0000 0000 0000 0000 0000  ................
*
00002000: 4865 6c6c 6f2c 2057 6f72 6c64 210a 0000  Hello, World!...
00002010: 0000 0000 0000 0000 0000 0000 0000 0000  ................
00002020: 0000 0000 0000 0100 0000 0200 0100 0010  ................
00002030: 4000 0000 0000 0000 0000 0000 0000 0800  @...............
00002040: 0000 0200 0100 1610 4000 0000 0000 0000  ........@.......
00002050: 0000 0000 0000 005f 7374 6172 7400 6578  ......._start.ex
00002060: 6974 002e 7465 7874 002e 726f 6461 7461  it..text..rodata
00002070: 002e 7379 6d74 6162 002e 7368 7374 7274  ..symtab..shstrt
00002080: 6162 0000 0000 0000 0000 0000 0000 0000  ab..............
00002090: 0000 0000 0000 0000 0000 0000 1000 0000  ................
000020a0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000020b0: 0000 0000 0000 0000 0000 0000 0000 0000  ................
000020c0: 0000 000d 0000 0001 0000 0006 0000 0000  ................
000020d0: 0000 0000 1040 0000 0000 0000 1000 0000  .....@..........
000020e0: 0000 0000 1000 0000 0000 0000 0000 0000  ................
000020f0: 0000 0010 0000 0000 0000 0000 0000 0000  ................
00002100: 0000 0013 0000 0001 0000 0002 0000 0000  ................
00002110: 0000 0000 506b 0000 0000 0000 2000 0000  ....Pk...... ...
00002120: 0000 000e 0000 0000 0000 0000 0000 0000  ................
00002130: 0000 0001 0000 0000 0000 0000 0000 0000  ................
00002140: 0000 001b 0000 0002 0000 0000 0000 0000  ................
00002150: 0000 0000 0000 0000 0000 000e 2000 0000  ............ ...
00002160: 0000 0048 0000 0000 0000 0004 0000 0003  ...H............
00002170: 0000 0001 0000 0000 0000 0018 0000 0000  ................
00002180: 0000 0023 0000 0003 0000 0000 0000 0000  ...#............
00002190: 0000 0000 0000 0000 0000 0056 2000 0000  ...........V ...
000021a0: 0000 002d 0000 0000 0000 0000 0000 0000  ...-............
000021b0: 0000 0001 0000 0000 0000 0000 0000 0000  ................
000021c0: 0000 00                                  ...
```

So this is our end goal. In the file, the first chunk of data is the executable file's header containing metadata and some format description, and the following parts contain the machine code, debug symbols, and data contained within the program. The job of the assembler is to go from the assembly code to this generated file, and we'll build up to this end result in this blog post and the next.

In most toolchains, there's a file format that sits in between these two representations of a program, called an [**object file**](https://en.wikipedia.org/wiki/Object_file). An object file is a packaged-up bundle of machine code and data that a program needs to run. But an object file might not be directly executable. For example, an object file for the `libc` library might contain code to implement `printf`, but it doesn't t make sense to run the library as an executable.

In most compilation steps, the compiler or assembler generates object files for each "compilation unit" of code -- usually a file or a library -- and then a _linker_ links the various parts of the different object files together into a final executable. For example, if we had an object file containing a Hello World program that then referenced the `printf` function in an external C library, we'd compile each of the two components, then link them together with a linker to generate a final executable binary file.

August, being a small project, isn't capable of linking multiple object files (yet?). Instead, it takes in a single assembly program, generates an internal representation of the program's machine code and data, and then simply outputs an executable file. In the case of my system, that executable file needs to be an [ELF file](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) because my computer runs the Linux kernel, which expects executable binary files to be ELF files.

With this rough map of where we're headed, let's start where I began.

## Faking it to an MVP

The first piece of code I wrote for the assembler was a program that simply output a hard-coded binary file and marked it as executable (you can find the [diff of the commit here](https://github.com/thesephist/august/commit/fab25f47598746e04611013d3a2bc4ed05832638)). I wanted to begin with a program that worked for a very specific input and output (a basic Hello World program) and slowly generalize it as I understood more parts of the assembler.

The first version of this "fake" assembler output the binary for this assembly program, hard-coded into the program itself:

```
mov eax 0x1
mov ebx 0x2a
int 0x80
```

All this program does is make an "exit" system call, so that the program exits with an exit status code of 42 (`0x2a`). This is the simplest valid assembly program I could make on x86 -- it uses two instructions, `mov` and `int`, two registers, `eax` and `ebx`, and a few [immediate](https://en.wikipedia.org/wiki/Value_(computer_science)#In_assembly_language) integer values.

Once I had this "fake" assembler working, I started breaking up the big hard-coded binary file into many smaller parts that I could understand and generalize for any assembly program. To do that though, we need to first understand the format of ELF files, which are the native executable file formats for Linux and other UNIX systems like BSD.

## Deconstructing the ELF format

[ELF](https://en.wikipedia.org/wiki/Executable_and_Linkable_Format) is a file format for executable binary files and object files. It's a widely accepted standard, used by most UNIX-like systems like Linux and BSD. Annoyingly, neither macOS nor Windows accept ELF executables.

The structure of an ELF file is pretty well specified on the [ELF manual page](https://man7.org/linux/man-pages/man5/elf.5.html), and it's quite flexible. If you want to follow along with a diagram, [this one by @corkami seems to be the best](https://commons.wikimedia.org/wiki/File:ELF_Executable_and_Linkable_Format_diagram_by_Ange_Albertini.png). An ELF file:

1. Begins with a small header section specifying the type and size of various parts of the ELF file, which is followed by
2. Any number of "sections", which can contain anything from program machine code to data to debugging information or really anything else
3. Where some of the sections may also be "segments" that are loaded into memory when the program is executed

All executable binary files on Linux systems are ELF files, and you can peer into the internal structure of any ELF file using `readelf` or `elfdump` (depending on your operating system). Somewhere in the ELF file are also a _program header table_ and a _section header table_. These tables can be anywhere in the file, and tell whoever's interpreting the ELF file where to find all the segments and sections in the ELF file. Since these tables can be located anywhere in the file, the ELF header at the start of the file point to a byte offset in the file where these tables live.

This is the high-level structure of an ELF file: a header, pointing to the program and section header tables, which in turn point to the rest of the segments and sections in the file. Sections are designed to hold arbitrary data, but segments are specifically for holding data useful in actually loading up a program to execute, like machine code, a pool of constants, and any global variables.

An operating system that's trying to run an ELF binary _only looks for the program segments_, and disregards any sections and section headers, but other tools like the `objdump` disassembler and debugger rely on these sections holding meaningful data to work. If you're linking multiple object files together, these sections holding symbol data and the like also become useful.

For building August, because I wanted to output executable files that I could disassemble and examine, I chose to include the following sections and segments.

Sections...

- A **null section**, which must be the first section in any ELF file
- A **text section**, conventionally labelled `.text`, containing the machine code also commonly called the "text" of a program
- A **read-only section**, conventionally called `.rodata`, containing any constants for the program like the string `"Hello, World!"`
- A **symbol table section**, conventionally labelled `.symtab`, which holds a table of "symbols" in the program like function names
- A **string table**, which we need to hold the names of the other sections in this list. This is conventionally labelled `.shstrtab`, for "Section Header STRing TABle".

Segments...

- One pointing to the text section, holding the machine code the program needs to run
- One pointing to the read-only data section, holding the constants the machine code will reference when it runs.

When we generate this ELF file and give it to the operating system, the operating system will spin up a new process in which our program can run. The OS will look at the two segments holding our machine code and constants, and reference the program header table to figure out where in the process's virtual address space these segments should be placed, and assign the segments their correct places in the process's virtual memory. Then it moves the CPU's [program counter](https://en.wikipedia.org/wiki/Program_counter) or instruction pointer register to the starting address of the executable, specified the ELF header. Finally, the OS task-switches to the new process, where the CPU will begin executing our machine code!

This is the simplest model of an executable ELF binary. Most languages and compilers will produce binaries that involve more complex moving parts, like linking to interpreters or libc's, loading in other dynamically linked libraries, or referencing debugging information embedded in the binary. Binaries that include large runtimes like the Go programming language runtime might have many segments loaded into memory that are responsible for different tasks or data in the program.

For a simple toy assembler like August, though, these few sections and segments are enough to get a running executable that we can peer inside.

### Dissecting ELF files with `readelf`

To start writing a program that can generate an ELF file that we want, we need two things. First, we need a detailed spec of exactly what bits and bytes we need to place into our ELF file to represent our sections and segments. We can find this information in the manual page (on Linux a simple `man elf` will get us there), or in various nooks and crannies of the low-level programming world online, some of which I've linked on the [August project readme](https://github.com/thesephist/august#references-and-further-reading). Second, we need to be able to easily inspect the ELF structure of any file we output. We can theoretically do this by using a binary file-dumping tool like `hexdump` and reading the bytes, but that's painful and time consuming. I chose to use `readelf` to get a continuous read-out of the data in ELF files my program output to make sure my code produced a valid ELF file.

A `readelf` output is pretty human-readable. Let's break it down.

```
$ readelf --all ./hello-world

ELF Header:
  Magic:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00
  Class:                             ELF64
  Data:                              2's complement, little endian
  Version:                           1 (current)
  OS/ABI:                            UNIX - System V
  ABI Version:                       0
  Type:                              EXEC (Executable file)
  Machine:                           Advanced Micro Devices X86-64
  Version:                           0x1
  Entry point address:               0x401000
  Start of program headers:          64 (bytes into file)
  Start of section headers:          8323 (bytes into file)
  Flags:                             0x0
  Size of this header:               64 (bytes)
  Size of program headers:           56 (bytes)
  Number of program headers:         2
  Size of section headers:           64 (bytes)
  Number of section headers:         5
  Section header string table index: 4
```

The first set of information is a decoding of the ELF header at the start of our file. It contains metadata about the target machine architecture of this executable file, as well as various version information, and sizes and locations of program and section headers within this ELF file.

The ELF header for this binary also contains a critical piece of information, the "entry point address", which in this case is `0x401000`. Remember this address, because we'll see it again down below.

```
Section Headers:
  [Nr] Name              Type             Address           Offset
       Size              EntSize          Flags  Link  Info  Align
  [ 0]                   NULL             0000000000000000  00001000
       0000000000000000  0000000000000000           0     0     0
  [ 1] .text             PROGBITS         0000000000401000  00001000
       0000000000001000  0000000000000000  AX       0     0     16
  [ 2] .rodata           PROGBITS         00000000006b5000  00002000
       000000000000000e  0000000000000000   A       0     0     1
  [ 3] .symtab           SYMTAB           0000000000000000  0000200e
       0000000000000048  0000000000000018           4     3     1
  [ 4] .shstrtab         STRTAB           0000000000000000  00002056
       000000000000002d  0000000000000000           0     0     1
Key to Flags:
  W (write), A (alloc), X (execute), M (merge), S (strings), I (info),
  L (link order), O (extra OS processing required), G (group), T (TLS),
  C (compressed), x (unknown), o (OS specific), E (exclude),
  l (large), p (processor specific)

There are no section groups in this file.
```

Next up is a list of sections `readelf` found in this file's section header. It found our five sections I outlined above: the null section, `.text`, `.rodata`, the symbol table, and the string table. We can also see some extra metadata, like that the `.text` section has `AX` (allocate and execute) flag bits set, and that the `.symtab` and `.shstrtab` sections have their "type" set to those respective types so another program like a debugger can recognize them.

`readelf` also tells us that there are no "section groups" in this file. I'm not sure what section groups are, but I guess we don't have any.

```
Program Headers:
  Type           Offset             VirtAddr           PhysAddr
                 FileSiz            MemSiz              Flags  Align
  LOAD           0x0000000000001000 0x0000000000401000 0x0000000000401000
                 0x0000000000001000 0x0000000000001000  R E    0x1000
  LOAD           0x0000000000002000 0x00000000006b5000 0x00000000006b5000
                 0x000000000000000e 0x000000000000000e  R      0x1000

 Section to Segment mapping:
  Segment Sections...
   00     .text
   01     .rodata
```

Here are our two program headers: one pointing to our machine code, marked with `R` (read) and `E` (execute) flags, and one pointing to our data (the "Hello, World!" string), with just the read flag set. `readelf` has also helpfully given us a mapping between our sections and segments based on their locations in the ELF file.

One interesting piece of information here is the `VirtAddr` column on our text segment holding the program's code. It's `0x401000`, the same address as the "entry point address" specified in the ELF header above. When this executable file runs, it'll start running the code located at `0x401000`, which starts at the beginning of our machine code segment.

```
There is no dynamic section in this file.

There are no relocations in this file.

The decoding of unwind sections for machine type Advanced Micro Devices X86-64 is not currently supported.
```

Because our executable file is neither dynamically linked nor a linkable library object file, we don't have any dynamic sections or relocations.

```
Symbol table '.symtab' contains 3 entries:
   Num:    Value          Size Type    Bind   Vis      Ndx Name
     0: 0000000000000000     0 NOTYPE  LOCAL  DEFAULT  UND
     1: 0000000000401000     0 FUNC    LOCAL  DEFAULT    1 _start
     2: 0000000000401016     0 FUNC    LOCAL  DEFAULT    1 exit

No version information found in this file.
```

Lastly, we get our [symbol table](https://en.wikipedia.org/wiki/Symbol_table#Applications), which tells disassemblers and debuggers where various symbols in our program reside in our code. In the case of this program, which was built from an assembly source, these symbols correspond to labels in our assembly code. `_start`, for example, is our program entry point and lives at virtual address `0x401000`, the start of our text segment.

If you have a Linux or BSD system, try using `readelf` to break open other programs you're familiar with, like `bash` or `vi`. You'll see extra sections, more debug symbols, and more complex link-time structures, but the basics high level structure of segments and sections will be the same across all ELF formats.

The first part of our assembler is a subprogram that can construct the simple ELF file we just dissected.

## Generating an ELF binary in August

If we simplify a bit, constructing an ELF file is mostly a matter of moving bytes of data around so they go in the right locations in a file. Because we're sticking to a simple structure, we can pre-determine a lot of constants to simplify our process. August's ELF library assumes the following.

- An entry point address of `0x401000`
- The start of read-only data segment of `0x6b5000`
- A pre-set order of parts:
    1. The ELF header
    2. The program header (table of segments)
    3. Padding of 0x00 bytes up to the page boundary of 4K bytes
    4. All sections: null, text, read-only data, symbol table, and string table, in that order
    5. Section header table

Though ELF doesn't strictly enforce an order like this, for simple binaries, this seemed to be conventional. It's especially useful to have the program header immediately follow the ELF header, because when the operating system executes this binary, it'll have to load that part of the file into memory anyways. It's also generally useful to have the section header table as the last part of an ELF file, because it makes it easier to append sections to this file -- you only have to modify the end of the file rather than the entire file.

These assumed constants are arbitrary, but they're useful to have, because it makes the task of writing the ELF header much easier. Numbers like "location of the section headers" and "number of segments" become constants we know from the start.

From this more concrete structure, I started to plan out my function to take program text and data, and emit an ELF binary.

You can see the structure I ended up with at [`./src/elf.ink`](https://github.com/thesephist/august/blob/master/src/elf.ink) in the repository. For example, here is a little bit of logic in the library to generate each of the sections in the ELF file. For example, my definition for the `.text` section looks like this.

```
TextSection := {
    name: toBytes(registerString('.text'), 4)
    type: toBytes(SectionType.ProgBits, 4)
    flags: toBytes(SectionFlag.Alloc | SectionFlag.ExecInstr, 8)
    addr: toBytes(ExecStartAddr, 8)
    offset: toBytes(PageSize, 8)
    align: toBytes(16, 8)
    body: text
}
```

Most of this corresponds directly to the section metadata we saw in the `readelf` output. While debugging this part of August, I had a continuous `readelf` output up side-by-side with my editor so I could validate that what I wrote in the assembler matched the sections it generated.

Here's the read-only data section, where I'll draw your attention to the different flag bits from the text section (just `Alloc` rather than `Alloc | ExecInstr`).

```
RODataSection := {
    name: toBytes(registerString('.rodata'), 4)
    type: toBytes(SectionType.ProgBits, 4)
    flags: toBytes(SectionFlag.Alloc, 8)
    addr: toBytes(ROStartAddr, 8)
    offset: toBytes(PageSize + len(text), 8)
    align: toBytes(1, 8)
    body: rodata
}
```

Here I define their corresponding segments

```
TextProg := {
    type: toBytes(ProgType.Load, 4)
    flags: toBytes(ProgFlag.Read | ProgFlag.Execute, 4)
    offset: toBytes(PageSize, 8)
    addr: toBytes(ExecStartAddr, 8)
    size: toBytes(len(text), 8)
}
RODataProg := {
    type: toBytes(ProgType.Load, 4)
    flags: toBytes(ProgFlag.Read, 4)
    offset: toBytes(PageSize + len(text), 8)
    addr: toBytes(ROStartAddr, 8)
    size: toBytes(len(rodata), 8)
}
```

This ELF-file-generating function also builds the symbol table. Given a dictionary of symbols and their virtual addresses, the `makeSymTab` function creates entries in the `.symtab` section and strings it all together.

```
SymTabSection := {
    name: toBytes(registerString('.symtab'), 4)
    type: toBytes(SectionType.SymTab, 4)
    flags: zeroes(8)
    addr: zeroes(8)
    offset: toBytes(PageSize + len(text) + len(rodata), 8)
    align: toBytes(1, 8)
    body: symtab
    ` ... `
}
```

Given all these sections and segments, we simply map over all the descriptions of sections and segments to encode them into table entries and lay them out next to each other so we can place them in our resulting ELF file.

The last task in the ELF library is to generate the ELF header. This step is counterintuitively left to the end so we know exactly how many sections we have, and exactly how big they ended up being. We need this information to store in the header the layout of our whole ELF file.

The final line of the ELF generation code stitches all the sections together.

```
elfFile := padEndNull(ElfHeader + ProgHeaders, PageSize) +
    SectionBodies +
    SectionHeaders
```

There we have it. A small program to take in some encoded blob of machine code, some debug symbols, and some read-only data and produce an ELF file our operating system can execute!

Now, our journey to build an assembler is half complete. We have the "backend" of August, but we still need to be able to encode assembly source code into machine code. That's the topic of the [second part to this blog, where we'll continue our trek through the underbelly of programming](/posts/x86/) to look at how to encode x86 assembly instructions and finish the assembler.

