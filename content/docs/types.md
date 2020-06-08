---
title: "Types and interfaces"
brief: Working with dynamically typed values in Ink programs
toc: true
---

## Primitive Types

Ink has four primitive types:

- 

## The composite interface

Ink's `string` and `composite` (and there for list) data types both follow the same interface for composite data types. This means that any functions buit around the interface will be correct for strings (including arbitrary blob data), composite dictionaries, and lists. The coposite interface consists of the following operations and functions. Say we have a composite `c` with string key `k`.

- `c.(k)`: return the value the composite holds at key `k`. For strings, this returns a character at a given integer index.
- `len(c)`: return the number of distinct keys in the composite. For strings and integer-keyed lists, this is the length; for blob data stored in strings, it's the size of the blob in bytes; for composite dictionaries, it's the number of keys in the dictionary.
- When passed to function calls or returned from call sites, all composite types (strings, composites, lists, blobs) are passed by reference; no copying takes place unless explicit with `std.clone`, which is polymorphic over all composite types.

By convention, a value in a string is often represented by `c` (character), and an integer index in a string or list is often represented by `i`.

### Polymorphism over composite types

Having a single interface shared by all composite data types in Ink enables an elegant kind of polymorphism over key functions in the standard library, and hopefully, in other more complex programs.

## Type introspection

Use Ink's `type()` builtin function to query a value for its run-time type as a string.

## Type conversion

Ink does not have implicit type casts -- every type conversion must be explicit using the `string()` or `number()` function. A `boolean()` is not provided to avoid ambiguity:

- A boolean type conversion works differently in different languages. Some languages only consider `false` and the null value falsy, while other languages also consider values like `0` and the empty string / empty list falsy. Forcing the program to define what it means by a falsy value avoids this kind of ambiguity.
- Writing a case-specific `boolean()` is trivial, especially compared to `string()` and `number()`, which must be versatile -- one either returns true or false based on a few checks.
