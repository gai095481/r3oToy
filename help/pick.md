## pick: A Technical Guide

*A Practical Guide to One of Rebol 3's Most Essential Functions*

The `pick` function is the primary method for accessing elements within a `block!`, which is Rebol's fundamental list-like datatype.

While its basic operation is straightforward, `pick` exhibits several nuanced behaviors depending on the structure of the block and the validity of the index.
A comprehensive understanding of these behaviors is essential for writing robust, predictable Rebol applications.

### The Basics: Positional Element Access

The canonical use for `pick` is retrieving a data element from a block by its numerical index. It is critical to note that Rebol uses a **one-based indexing** system, where the first element resides at position `1`.

```rebol
>> data-block: ["alpha" "bravo" "charlie"]

>> pick data-block 1
== "alpha"

>> pick data-block 3
== "charlie"
```
This represents the "happy path" or the ideal execution flow and it's simple and intuitive.
> In computer programming, the **"happy path"** (also called the "sunny-day scenario") refers to the **ideal, default execution flow of a program where everything proceeds as expected**, without errors, exceptions or edge cases.

### Scenario: Out-of-Bounds Indexing

The `pick` function doesn't generate an error if given an index outside the valid bounds of the block (e.g., less than 1 or greater than the block's length).
Instead, it returns a value of the **`none!` datatype**.

```rebol
>> data-block: ["alpha" "bravo" "charlie"]

>> pick data-block 5      ;; This position is out of bounds.
== #(none)                ;; This is a true `none!` value.

>> pick data-block 0      ;; Index 0 is invalid.
== #(none)
```

> **Verification:**
>
> Test for the `none!` datatype to verify if a `pick` operation has failed due to an out-of-bounds index using the idiomatic Rebol `none?` function.
> ```rebol
> >> result: pick data-block 5
> >> if none? result [print "Index is out of bounds."]
> Index is out of bounds.
> ```

### Scenario: Accessing "Key-Value" Blocks

A more complex behavior emerges when `pick` is used on blocks containing "key-value" pairs, denoted by `set-word!`s (e.g., `key:`).
In these cases, REPL evidence demonstrates that `pick` returns the **`word!`** representation of a stored `logic!` or `none!` value, rather than the datatype itself.

```rebol
>> profile-block: [
    name: "Alice"
    active: true
    session-id: none
]

>> pick profile-block 2      ;; Get the value for `name:`
== "Alice"                   ;; `string!` values are returned as expected.

>> pick profile-block 4      ;; Get the value for `active:`
== true                      ;; Returns the `word!`, `'true`, not the `logic!` type `true`

>> pick profile-block 6      ;; Get the value for `session-id:`
== none                      ;; Returns the `word!`, `'none`, not the datatype `none`.
```

> **Analysis of Behavior:**
>
> This functionality suggests that `pick` operates at a low level, returning the literal token from the source block without evaluation. This prioritizes speed and provides a direct view of the block's structure. However, it places the onus on the developer to normalize the result if a true `logic!` or `none!` datatype is required.  For this reason, a higher-level getter wapper function is often preferable for accessing "key-value" data in blocks.

### Senario: `pick` with `none` Input

The one scenario where `pick` is **unforgiving** is when the primary argument is `none` itself. This action is invalid and will halt the script with a syntax error.

```rebol
>> invalid-data: none
>> pick invalid-data 1
** Script error: pick does not allow #(none!) for its aggregate argument
```
This necessitates a guard condition (e.g., `if not none? data [...]`) when dealing with variables that might be `none`.

### `pick`: A Behavioral Summary

| Operation | `pick` Returns... | Analysis |
| :--- | :--- | :--- |
| `pick ["a" "b"] 1` | `"a"` (`string!`) | Standard, predictable behavior. |
| `pick ["a" "b"] 99` | `none` (`none!`) | Returns the `none!` datatype for out-of-bounds access. Verify with `none?`. |
| `pick [val: true] 2` | `'true` (`word!`) | Returns a `word!`, not a `logic!`. Requires normalization. |
| `pick [val: none] 2` | `'none` (`word!`) | Returns a `word!`, not a `none!` value. Requires normalization. |
| `pick none 1` | **Script Error** | Input must be validated before calling `pick`. |

`pick` is a fundamental, high-performance function. A clear understanding of its distinct behaviors with simple blocks versus "key-value" blocks is crucial for its effective and safe implementation in any Rebol 3 Oldes program.
