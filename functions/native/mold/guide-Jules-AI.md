# A User's Guide to the `mold` Function in Rebol 3 Oldes branch

## I. Introduction: What is `mold`?

The `mold` function is one of the most fundamental and powerful tools in Rebol. Its primary purpose is to take **any Rebol value** and convert it into a **loadable string representation**. This means the string that `mold` produces can be copied, saved to a file, or sent over a network, and then later loaded back into Rebol using `load` to perfectly recreate the original value.

It is the inverse of `load`.

-   **`mold`**: Rebol Value -> `string!`
-   **`load`**: `string!` -> Rebol Value

Think of it as Rebol's universal serializer. It's what makes Rebol's data exchange capabilities so seamless and powerful.

```rebol
my-data: [1 "hello" 15-Jul-2025]

; Convert the block to a string
molded-string: mold my-data
print molded-string
; Output: {[1 "hello" 15-Jul-2025]}

; Load the string back into a new variable
new-data: load molded-string

; Verify that the new data is identical to the original
print ["Is the data the same?" my-data = new-data]
; Output: Is the data the same? true
```

## II. Basic Usage: Common Data Types

The behavior of `mold` is straightforward for most common data types. It produces exactly what you would type into the REPL to create that value.

### Scalar Types (Numbers, Logic, etc.)

`mold` wraps some scalar types in special syntax to ensure they are loaded correctly.

| Datatype      | Example Code                | Molded Output     | Notes                                            |
| :------------ | :-------------------------- | :---------------- | :----------------------------------------------- |
| `integer!`    | `mold 1024`                 | `"1024"`          | A simple string representation.                  |
| `decimal!`    | `mold 10.24`                | `"10.24"`         | A simple string representation.                  |
| `string!`     | `mold "hello"`              | `{"hello"}`       | **Wrapped in `{}` or `""`**.                      |
| `char!`       | `mold #"A"`                 | `{#"A"}`          | Includes the `#"..."` syntax.                    |
| `logic!`      | `mold true`                 | `#(true)`         | **Wrapped in `#()`**. This is the R3 representation. |
| `none!`       | `mold none`                 | `#(none)`         | **Wrapped in `#()`**.                            |
| `unset!`      | `mold unset!`               | `#(unset!)`       | **Wrapped in `#()`**.                            |

### Word & Path Types

Words and paths are molded into their literal, directly usable forms.

| Datatype        | Example Code                             | Molded Output          | Notes                                     |
| :-------------- | :--------------------------------------- | :--------------------- | :---------------------------------------- |
| `word!`         | `mold 'some-word`                        | `"some-word"`          | The plain word.                           |
| `lit-word!`     | `mold to-lit-word 'word`                 | `"'word"`              | Prepended with a `'` (tick).              |
| `set-word!`     | `mold to-set-word 'word`                 | `"word:"`              | Appended with a `:`.                      |
| `get-word!`     | `mold to-get-word 'word`                 | `":word"`              | Prepended with a `:`.                     |
| `refinement!`   | `mold to-refinement 'word`               | `"/word"`              | Prepended with a `/`.                     |
| `path!`         | `mold 'obj/field/value`                  | `"obj/field/value"`    | The full path.                            |
| `file!`         | `mold %path/to/file.txt`                 | `"%path/to/file.txt"`  | The path prepended with `%`.              |

### Series Types (Blocks, Strings, Binaries)

`mold` on a series will represent the entire series, including its delimiters.

```rebol
; A block is molded with its square brackets
print mold [a b [c d]]
; Output: {[a b [c d]]}

; A string is molded with its braces or quotes
print mold "a quote "" inside"
; Output: {{a quote "" inside}}

; A binary is molded with its hash and braces
print mold #{DECAFBAD}
; Output: #{DECAFBAD}
```

## III. Refinements: Controlling the Output

`mold` has several powerful refinements to control the format of the output string.

### `/only` - Molding Block Contents

The `/only` refinement is used to mold the *contents* of a block without the outer `[]` brackets.

```rebol
my-block: [a b c]

print mold my-block
; Output: {[a b c]}

print mold/only my-block
; Output: {a b c}
```

### `/all` - Construction Syntax

The `/all` refinement produces a "constructor" syntax for certain types, like `object!` and `map!`, which is more verbose but can be useful for recreating the value.

```rebol
my-obj: make object! [name: "Test"]

; Default mold is not loadable for objects
print mold my-obj
; Output: {make object! [^/    name: "Test"^/]}

; /all creates a loadable representation
print mold/all my-obj
; Output: {#(object! [^/    name: "Test"^/])}
```

### `/flat` - Removing Indentation

The `/flat` refinement is used *with* `/all` to remove newlines and indentation, creating a compact, single-line representation.

```rebol
my-obj: make object! [name: "Test" value: 10]

print mold/all my-obj
; Output:
; #(object! [
;     name: "Test"
;     value: 10
; ])

print mold/all/flat my-obj
; Output: {#(object! [name: "Test" value: 10])}
```

### `/part` - Limiting Output Length

The `/part` refinement limits the total length of the resulting string to a specific number of characters.

**Nuance for Novices:** The behavior of `/part` can be quirky. It's a hard character limit and may cut off in the middle of a value or miss the closing delimiter.

```rebol
my-block: [1 2 3 4 5 6 7 8 9]
my-string: "abcdefghijklmnopqrstuvwxyz"

; Mold the block up to 10 characters
print mold/part my-block 10
; Output: {[1 2 3 4 5}  ; Notice the missing closing bracket

; Mold the string up to 10 characters
print mold/part my-string 10
; Output: {^"abcdefghi} ; Notice it's 9 chars + quote, and no closing quote
```
**Tip:** Use `/part` primarily for creating truncated strings for display (e.g., in logs or error messages), not for creating loadable data.

## IV. Overcoming Nuances & Quirks

Based on our diagnostic tests, here are key behaviors to be aware of:

### 1. `logic!`, `none!`, and `unset!` use `#( ... )`

A common point of confusion is the `#[...]` vs `#( ... )` syntax. Rebol 3 uses parentheses for these built-in values.

-   **Correct:** `mold true` -> `"#(true)"`
-   **Incorrect:** Expecting `#[true]`

### 2. Escaping Quotes in Strings

When a string contains a double-quote (`"`), `mold` does not escape it with a caret (`^"`). Instead, it intelligently switches the outer delimiters to curly braces `{}`.

```rebol
print mold {a "quoted" string}
; Output: {{a "quoted" string}}
```

### 3. Molding Functions

`mold` on a `function!` value reveals its internal structure, including an explicit `/local` section even if you didn't define one.

```rebol
my-func: function [arg] [arg + 1]
print mold :my-func
; Output: {make function! [[arg^//local][arg + 1]]}
```

This is the correct, loadable representation of the function.

## V. Summary

-   **Use `mold`** when you need a string representation of *any* Rebol value that you can reliably `load` back into the system later.
-   **Use `form`** when you need a simple, human-readable string for display, without any Rebol-specific formatting (like quotes on strings or brackets on blocks).
-   **Be aware of the refinements:** `/only` is for block contents, `/all` and `/flat` are for creating constructor-style code, and `/part` is for truncation.
-   **Trust the REPL:** The `mold` function's output is the "ground truth" for how Rebol represents its own data as a string.

By understanding these principles and nuances, you can leverage `mold` as a powerful tool for serialization, debugging, and code generation.
