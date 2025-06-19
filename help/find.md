## find: A Technical Guide

The `find` function is a fundamental `action!` in Rebol 3.  Its primary purpose is to locate a value within a `series!` and return a new `series!` representing the position where the value was found.  This behavior distinguishes it from `select`, which returns the value *following* the key.  `find` is the principal tool for existence checks and positional manipulation.

### Formal Definition

The formal usage provided by the Rebol interpreter is:
`FIND series value`

- **`series`**: The aggregate data structure to be searched.  This argument accepts a wide range of types including any `series!`, `port!`, `map!`, `object!` or `bitset!`.
- **`value`**: The element to locate within the `series`.  Its type is `any-type!`.

### Core Behavior

The `find` function iterates through a `series` searching for the first occurrence of `value`.  It returns a new `series!` whose head is at the position of the found element if a match is successful.  The function returns `none` if `value` is not found within the `series`.  The truthy nature of a returned `series!` makes `find` ideal for conditional logic.

```rebol
>> data-block: ['alpha 'bravo 'charlie 'delta]

>> find data-block 'bravo
== ['bravo 'charlie 'delta]

>> find data-block 'omega
== none
```

A common and idiomatic use of `find` is for existence checking within a conditional block.

```rebol
>> if find data-block 'charlie [
    print "The value 'charlie exists in the block."
]
The value 'charlie exists in the block.
```

### Behavior with Key-Value Structures

The `find` function is essential for verifying the existence of keys in `map!` and `block!` based key-value structures.

#### `block!` with `set-word!` Keys

When operating on a `block!` containing `set-word!` keys, `find` can locate the key's position.  This is a critical first step before retrieving the associated value.

```rebol
>> config-block: [
    host: "localhost"
    port: 8080
]

>> position: find config-block 'host:
== [host: "localhost" port: 8080]

>> if position [
    print ["The value is:" second position]
]
The value is: localhost
```

#### `map!` Datatype

When used with a `map!`, `find` reliably checks for the existence of a key.  REPL evidence from the target Rebol environment confirms that `find` successfully locates a key even when its associated value is `none`.  This makes `find` the definitive tool for distinguishing between a missing key and a key that exists with a `none` value.

```rebol
>> data-map: make map! [
    active: true
    session: none
]

>> find data-map 'active
== [active: true session: none]

>> find data-map 'session
== [session: none]

>> find data-map 'missing-key
== none
```

### Refinements

The `find` function includes numerous refinements to control its search behavior precisely.

- **/case**: Performs a case-sensitive search on `string!` data.
- **/skip**: Treats the `series` as records of a fixed size, advancing the search by `size` on each step.
- **/last**: Begins the search backward from the end of the `series`, finding the last occurrence of the value.
- **/tail**: Returns the `series!` positioned at the tail *after* the found value instead of at the value itself.
- **/match**: Performs a head-of-series comparison.  The `series` must start with the `value` for it to be considered a match.

```rebol
>> data: "abcdefg"

>> find/tail data "cde"
== "fg"
```

### `find` with `none` Input

The `find` function's `series` argument accepts `none!`.  However, attempting to perform a find on a `none` value will result in a script error.  This requires a guard condition in production code.

```rebol
>> invalid-data: none
>> find invalid-data 'any-key
** Script error: Invalid argument: none
```
