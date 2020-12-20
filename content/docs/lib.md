---
title: "Standard library reference"
brief: "API documentation for the Ink standard library std, str, quicksort, and friends"
toc: true
---

The Ink standard library is not current packaged into the distributed binary. However, you can get up-to-date versions of these libraries [on GitHub](https://github.com/thesephist/ink/tree/master/samples).

## Standard (`std`)

`std` is Ink's core library.

<a href="https://github.com/thesephist/ink/blob/master/samples/std.ink" class="button">See source on GitHub &rarr;</a>

### `log(val)`

Prints the string version of `val` to standard output.

### `scan(cb)`

Opens standard input, and calls `cb` with the result of the first chunk of input as a string.

### `hex(n)`

Takes a positive integer and returns a lowercase hexadecimal string.

### `xeh(s)`

Takes a lowercase hexadecimal string and returns its value as a number.

### `min(numbers)`

Returns minimum of a list of numbers.

### `max(numbers)`

Returns a maximum of a list of numbers

### `range(start, end, step)`

Returns a list of numbers starting at `start`, going up by `step` until and excluding when it equals or exceeds `end`.

For example, `range(0, 5, 1)` returns `[0, 1, 2, 3, 4]`. `range(0, n, 1)` is a common idiom to generate a list `n` elements long.

### `clamp(start, end, min, max)`

Clamps a given numeric range, `[start, end]`, to the range `[min, max]`. The resulting range, if possible, is the intersection of those two ranges. If that intersection is an empty set, it returns `[min, min]` or `[max, max]`, both empty ranges.

### `slice(s, start, end)`

Returns a sub-slice of a list from and including `start`, to and excluding `end`. If `start` is an index out of bounds, it returns an empty list.

`slice` works much like the slice operator `[a:b]` of Go and Python.

### `append(base, child)`

Appends the list `child` to the end of the list `base`, mutating `base`.

### `join(base, child)`

Appends the list `child` to the end of the list `base`, while leaving `base`. In other words, `join` is the immutable counterpart to `append`.

### `clone(x)`

Shallow-clones a composite value or a string, so that mutating its return value will not mutate the original. `clone` is useful for using a mutable function against a variable that should be immutable.

### `stringList(list)`

Returns a string representation of a composite value as a list. `stringList` is useful for diagnostic purposes, for logging list values to output.

`stringList([1, 2, [3, 4]])` returns `'[1, 2, {0: 3, 1: 4}]'`.

### `reverse(list)`

Reverses a list, and returns the result as a new list without mutating the input.

### `map(list, f)`

Maps over a list and creates a new list, applying `f` to each item. `f` is passed the arguments `(item, index)`.

### `filter(list, f)`

Filters a list and creates a new list that only includes items from `list` for which `f(item)` returns true. `f` is passed the arguments `(item, index)`.

### `reduce(list, f, acc)`

Reduces over the list from left to right, in ascending index order, starting with accumulator `acc`, applying `f` to the arguments `(acc, item, index)`.

### `reduceBack(list, f, acc)`

Like `reduce`, but traverses the list from the end, in decreasing-index order.

### `flatten(list)`

Flattens a list of lists into a single list containing the sublists' items in order. `flatten` only flattens a list one-level deep.

### `some(list)`

Returns true if `list` contains at least one `true`.

### `every(list)`

Returns true if `list` contains no `false`.

### `cat(list, joiner)`

Concatenates a list of strings into a single string, with `joiner` in between each pair.

### `each(list, f)`

Loops over `list`, calling `f(item, index)` on each item. Its return value is to be discarded.

### `encode(str)`

Encodes a string buffer into a list of numbers, each byte being a number entry in the list. `encode` is useful for converting between ASCII numeric and string representations of a string, or for doing arithmetic with byte values in a string.

### `decode(data)`

Reverse of `encode`, `decode` takes a list of numbers less than 256 and returns a string where each character (byte) has the byte value of the corresponding number from the list. `decode` will simply skip over any numbers in the list greater than `255`.

### `readFile(path, cb)`

Reads file from a given path completely, and calls `cb` with the read string buffer as the argument. If the read fails for one reason or another, the null value `()` is sent instead to the callback.

### `writeFile(path, data, cb)`

Writes a string buffer, given as `data`, to the file at `path`. If a file is already present, `writeFile` truncates the existing file. If the file is not there, `writeFile` creates it. If write is successful, `cb` is called with `true`. On any error, `()` is passed instead to the callback.

### `format(raw, values)`

Returns a format string with the string formatting substrings replaced with their referenced values from `values`, which can be a map or a list. For example:

```
format('{{ 0 }} {{ 1 }} {{ 0 }}', ['A', 'B'])
`` -> 'A B A'

format('{{ steve }} met {{ jony }}', {
    steve: 'Steve Jobs'
    jony: 'Jony Ive'
})
`` -> 'Steve Jobs met Jony Ive'
```

## String (`str`)

`str` contains string manipulation functions.

<a href="https://github.com/thesephist/ink/blob/master/samples/str.ink" class="button">See source on GitHub &rarr;</a>

### `upper?(c)`

Reports whether the given character is an ASCII uppercase character.

### `lower?(c)`

Reports whether the given character is an ASCII lowercase character.

### `digit?(c)`

Reports whether the given character is an ASCII number character.

### `letter?(c)`

Reports whether the given character is an ASCII Latin letter.

### `ws?(c)`

Reports whether the given character is an ASCII whitespace character.

### `hasPrefix?(s, prefix)`

Reports whether `prefix` is a prefix of `s`, i.e. whether `s` starts with `prefix`.

### `hasSuffix?(s, suffix)`

Counterpart to `hasPrefix?`, reports whether `suffix` is a suffix of `s`, i.e. whether `s` ends with `suffix`.

### `index(s, substring)`

If `substring` is a substring of `s`, returns the index of its first occurrence. Otherwise, returns `~1`.

### `contains?(s, substring)`

Reports whether `substring` is a substring of `s`.

### `lower(s)`

Converts all ASCII uppercase characters in `s` to their lowercase counterparts.

### `upper(s)`

Converts all ASCII lowercase characters in `s` to their uppercase counterparts.

### `title(s)`

Converts `s` to "title case", which in this case simply means capitalizing the first character and lowercasing the rest.

### `replace(s, old, new)`

Replaces all occurrences of `old` with `new` in `s`. Only non-overlapping sections of overlapping matches will be replaced.

### `split(s, delim)`

Splits `s` by occurrences of `delim` into a list of strings. If `s` begins or ends in `delim`, the first or last item of the list, respectively will be the empty string.

### `trimPrefix(s, prefix)`

If `prefix` is a prefix of `s`, returns `s` without that prefix. This is done repeatedly until `prefix` is no longer at the start of `s`.

### `trimSuffix(s, suffix)`

If `suffix` is a suffix of `s`, returns `s` without that suffix. This is done repeatedly until `suffix` is no longer at the end of `s`.

### `trim(s, ss)`

Trims all instances of `ss` at either the start or end of `s`.

## Sort (`quicksort`)

`quicksort` contains an implementation of Quicksort using Hoare partition.

<a href="https://github.com/thesephist/ink/blob/master/samples/quicksort.ink" class="button">See source on GitHub &rarr;</a>

### `sortBy(v, pred)`

Sorts list `v` by the result of the given predicate. _i.e._ the list is sorted via quicksort according to the value of `pred(item)` for each item in `v`.

### `sort!(v)`

Sorts the list in-place. If the list is of numbers, the sort is ascending numerical order. If the list is of strings, the sort is in ascending lexicographical order. In all other cases, the sort is ambiguous.

### `sort(v)`

The counterpart to `sort!(v)` that does not mutate the given list.

## UUID (`uuid`)

`uuid` generates UUIDs.

<a href="https://github.com/thesephist/ink/blob/master/samples/uuid.ink" class="button">See source on GitHub &rarr;</a>

### `uuid()`

Returns a cryptographically random UUID compliant with UUID version 4.
