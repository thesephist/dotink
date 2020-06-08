---
title: "Syntax"
brief: Specification for Ink's syntax
toc: true
---

// in the style of: http://wren.io/syntax.html

Ink programs are UTF-8 or ASCII text files with the `.ink` file extension. Ink's syntax takes inspiration from Go and modern JavaScript, and strives to be minimal, concise, unambiguous, and fast to parse.

## Comments

Ink, like C, has both single- and multi-line comments.

## Keywords

## Commas and automatic comma insertion

## Grouping

## Whitespace and indentation

## Variables and assignment

Ink identifiers can start with any alphabetic character and can contain any alphanumeric character. Ink variables cannot contain the characters `-`, `_`, or `$`, unlike many other scripting languages. This means Ink variables that are more than one word are written in `camelCase`.

By convention, mutable and local variables start with a lowercase letter, and constants and global variables start with an uppercase letter.

```
` global variable `
MaxLineLength := 80

` local/mutable variable `
currentLine := getInput()
counter := 1
```

There is only one assignment operator in Ink, the "define" operator `:=`. `:=` creates a new variable for a value if one doesn't exist in the current scope, and mutates a variable if one exists in the current scope. This means that in Ink, a variable _always shadows_ the same name from a larger scope.

## Operators

## Match expressions


