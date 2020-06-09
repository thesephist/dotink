---
title: "Runtime and builtins"
brief: Ink's native runtime functions, asynchrony, and other details of the interpreter
toc: true
---

## Operating system interfaces

Many system interface builtin functions are designed around asynchronous callbacks, and will return an event object to a callback function in response. Such an event object is of a semi-standard form, on success

```
{
    type: 'data'
    data: [... some data]
}
```

and on error, frequently the error interface

```
{
    type: 'error'
    message: <string>
}
```

When a system-interface builtin is capable of returning such an error event, we'll simply state so, without repeating the shape of the object again every time. Some builtin functions also need to send a "the task is complete successfully" event without sending any data. In such instances, an end event, shown below, is sent.

```
{
    type: 'end'
}
```

### `args()`

Returns the list of command-line arguments as strings.

### `in(cb)`

Reads from standard input, calls `cb` with an event of the form

```
{
    type: 'data'
    data: <string>
}
```

or an end event.

Ink will keep reading from stdin until `cb` returns `false` to a callback invocation.

### `out(s)`

Prints the exact string `s` to standard out. Notably, `out` will not append a newline to the end of `s`.

### `dir(path, cb)`

Returns a directory listing of the given path, in an event of the form

```
{
    type: 'data'
    data: list<FileInfo>
}
```

Where the `FileInfo` interface is the same one that `stat()` calls return to the callback. On error, it returns an error event.

### `make(path, cb)`

Recursively creates directories in `path`, like `mkdir -p`. If successful, sends an end event, otherwise an error event.

### `stat(path, cb)`

Returns metadata about a given object in the file tree, of the form

```
{
    type: 'data'
    data: list<{
        name: <string>
        `` if file, size in bytes; if dir, ambiguous
        len: <number>
        `` true if the entry is a directory
        dir: <boolean>
        `` last-modified time, as a UNIX timestamp
        mod: <number>
    }>
}
```

or an error event.

### `read(path, offset, length, cb)`

Reads a file in the given path, at the byte offset `offset` for a length `length`. The callback is invoked with an event of shape

```
{
    type: 'data'
    data: <string>
}
```

or an error event, on a read error.

### `write(path, offset, data, cb)`

Writes to a file in the given path, in the same way `read()` does. `data` is to be given as a string, and `cb` is called with an end event or an error event.

`write` will create a file in the given path if already exists, but will send an error if the path already exists as a directory or it cannot be written to.

### `delete(path, cb)`

Deletes a file or directory, recursively, at a given path. `delete()` sends either an end event or an error event.

### `listen(host, handler)`

Starts an HTTP web server. `host` should specify the host the server should bind to, like `localhost:80`. The handler is invoked per each HTTP request received, with an event of the form

```
{
    type: 'req'
    data: {
        method: <string>
        url: <string>
        headers: map<string, string>
        body: <string>
    }
    end: <function>
}
```

After the handler processes the request, it should call `end(response)` to respond, with the response object of the shape

```
{
    status: <number>
    headers: map<string, string>
    body: <string>
}
```

On any server error, the handler is called with an error event. The `listen()` call returns a `close` callback, which can be invoked to stop the server.

### `req(data, callback)`

Makes an HTTP request. Complementary to `listen`, `req` takes a request object of the form

```
{
    method: <string>
    url: <string>
    headers: map<string, string>
    body: <string>
}
```

The callback is called with a response event, of the form

```
{
    type: 'resp'
    data: {
        status: <number>
        headers: map<string, string>
        body: <string>
    }
}
```

or an error event. Like `listen`, the `req` call also returns a `close` callback that can abort the request.

### `rand()`

Returns a random number in the range [0, 1), using the system pseudorandom number generator.

### `urand(length)`

Using the system's cryptographically secure random number generator, return a string buffer of length `length` of random data.

### `time()`

Return the current time as a floating-point UNIX timestamp.

### `wait(duration, cb)`

Waits for `duration` seconds before calling `cb` with no arguments.

### `exec(path, args, stdin, stdoutFn)`

Spawns a child process with the executable at `path`, with command line arguments given in the list `args`, and a standard input `stdin`.

When the process ends, the callback `cb` is invoked with the event of shape

```
{
    type: 'data'
    data: <string>
}
```

## Math builtins

### `sin(n)`

Takes the sine of a number.

### `cos(n)`

Takes the cosine of a number.

### `asin(n)`

Takes the arcsin / inverse-sine of a number. If the number is not in the range [-1, 1], it throws a runtime error.

### `acos(n)`

Takes the arccosine / inverse-cosine of a number. If the number is not in the range [-1, 1], it throws a runtime error.

### `pow(b, n)`

Returns `b` raised to power `n`.

### `ln(n)`

Natural logarithm. Throws if `n` <= 0.

### `floor(n)`

Truncates the number to an integer.

## Runtime introspection functions

### `load(path)`

Loads another Ink program as a module. Read more [in the language overview](/docs/overview/#imports-and-libraries).

### `string(x)`

Converts or serialize `x` into a string value.

### `number(x)`

Converts `x` into a number value, parsing it from a string if necessary. If it cannot be cast correctly, returns 0.

### `point(c)`

Returns the first byte of `c` as a number. In other words, `point` converts an ASCII character to its number value.

### `char(n)`

Returns the number `n` as a byte, in a string. In other words, `char` converts an ASCII number to a character.

### `type(x)`

Return the runtime type of `x` as a string, _e.g._ `'string'`, `'number'`, `'composite'`, `'function'`, `()`.

### `len(x)`

For string `x`, return its length. For composite value `x`, return the number of keys in the object.

### `keys(x)`

Return the keys of a composite value `x` in a list of strings.
