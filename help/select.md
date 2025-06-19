## select: A Technical Guide

The `select` function is a fundamental `action!` in Rebol 3.  Its primary purpose is to search a `series!` for a given key and return the value that immediately follows it.  This guide provides a comprehensive analysis of `select`, expanding upon the native `help` documentation to include critical behaviors and applications relevant to professional development.

### Formal Definition

The formal usage provided by the Rebol interpreter is:
`SELECT series value`

- **`series`**: The aggregate data structure to be searched.  This argument accepts a wide range of types including any `series!`, `port!`, `map!`, `object!`, or `module!`.
- **`value`**: The key to locate within the `series`.  Its type is `any-type!`.

### Core Behavior

The `select` function iterates through a `series` searching for the first occurrence of `value`.  It returns the single element immediately following `value` if a match is found.  The function returns `none` if `value` is not found within the `series`.

```rebol
>> data-block: [
    'alpha 1 'bravo 2 'charlie 3
]

>> select data-block 'bravo
== 2

>> select data-block 'delta
== none
```

### Behavior with Key-Value Structures

The `select` function is particularly well-suited for retrieving values from data structures that emulate key-value pairs.  Its behavior differs based on the data type of the `series`.

#### `block!` with `set-word!` Keys

When operating on a `block!` containing `set-word!` keys (e.g., `key:`), `select` provides a powerful mechanism for value retrieval.  The `value` argument must match the `set-word!` key.

```rebol
>> config-block: [
    host: "localhost"
    port: 8080
    active: true
]

>> select config-block 'port
== 8080
```
It is important to note that `select` will find the `set-word!` key `port:` even when the search `value` is the `word!` `'port`.

#### `map!` Datatype

The `map!` datatype is optimized for direct key-value lookups, and `select` is the idiomatic tool for this purpose.

```rebol
>> config-map: make map! [
    host: "localhost"
    port: 8080
]

>> select config-map 'host
== "localhost"
```

A critical distinction exists in the behavior of `select` on a `map!` versus a `block!`.  REPL evidence from the target Rebol environment confirms that when a `map!` stores a `logic!` or `none!` value, `select` returns the corresponding `word!` representation rather than the datatype itself.

```rebol
>> data-map: make map! [
    active: true
    session: none
]

>> select data-map 'active
== true  ; Returns the word! 'true.

>> select data-map 'session
== none  ; Returns the word! 'none.
```
This behavior necessitates normalization of the returned value if a true `logic!` or `none!` datatype is required by subsequent code.

### Refinements

The `select` function includes several refinements to modify its search behavior.

- **/case**: Performs a case-sensitive search.
- **/skip**: Treats the `series` as records of a fixed size, advancing the search by `size` on each step.  This is useful for searching within structured data.
- **/last**: Begins the search backward from the end of the `series`.
- **/reverse**: Begins the search backward from the current position if the series is part of a larger traversal.

```rebol
>> data: [a 1 a 2 a 3]

>> select/last data 'a
== 3
```

### `select` with `none` Input

The `select` function's `series` argument accepts `none!`.  However, attempting to perform a selection on a `none` value will result in a script error.  This requires a guard condition in production code where a variable may be `none`.

```rebol
>> invalid-data: none
>> select invalid-data 'any-key
** Script error: Invalid argument: none
```
