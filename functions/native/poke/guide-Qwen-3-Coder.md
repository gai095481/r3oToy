# Unofficial `poke` Function User's Guide

Based on comprehensive diagnostic testing, this guide explains the `poke` function's behavior with precision and practical examples.

## Function Signature

```rebol
USAGE:
     POKE series index value

DESCRIPTION:
     Replaces an element at a given position.
     POKE is an action! value.

ARGUMENTS:
     series        [series! port! map! gob! bitset!] (modified).
     index         [any-type!] Index offset, symbol, or other value to use as index.
     value         [any-type!] The new value (returned).
```

## Core Behavior

The `poke` function modifies a `series` by replacing an element at a specified `index` with a new `value`. Importantly, `poke` **mutates the original series** and returns the `value` that was poked.

### Return Value

Unlike `change` or `insert`, `poke` returns the **value that was inserted**, not the series itself. This is useful for chaining operations.

```rebol
blk: [a b c]
poked-value: poke blk 2 'X
print poked-value  ;; prints X
print blk          ;; prints [a X c]
```

## Supported Series Types

### 1. `block!` and `paren!`

Works with standard 1-based indexing. Negative indices count from the tail.

```rebol
blk: [1 2 3 4 5]
poke blk 3 'new    ;; => [1 2 new 4 5]
poke blk -1 'last  ;; => [1 2 new 4 last] (negative index from tail)
```

**Important**: Index must be within bounds (1 to length). Index 0 or beyond length raises an error.

### 2. `string!`

Replaces a character at the specified position.

```rebol
str: "hello"
poke str 2 #"a"    ;; => "hallo"
poke str 1 66      ;; => "Ballo" (66 is ASCII for "B")
```

**Important**:

- Poking `none` into a string raises an error.
- Only valid character codes (0-255) are accepted.

### 3. `binary!`

Replaces a byte at the specified position.

```rebol
bin: #{01020304}
poke bin 3 255     ;; => #{0102FF04}
poke bin 2 #"A"    ;; => #{0141FF04} (#"A" = 65)
```

**Important**:

- Poking logic values (`true`, `false`) raises an error.
- Integer values are stored as bytes (modulo 256).

### 4. `map!`

Uses the `index` as a key to set or update a key-value pair.

```rebol
m: make map! [a 1 b 2]
poke m 'a 100      ;; => #(a: 100 b: 2)
poke m 'c 300      ;; => #(a: 100 b: 2 c: 300) (adds new key)
```

**Important**: Any valid Rebol value can be used as a key.

### 5. `bitset!`

Sets the bit at the given index to `true`.

```rebol
bs: make bitset! 8
poke bs 3 true     ;; Sets bit 3
```

### 6. `gob!`

Modifies a facet or property of a graphical object.

## Key Nuances and Gotchas

### Bounds Checking

- **Blocks/Strings/Binary**: Index must be >= 1 and <= length.
- **Index 0** always raises an error.
- **Empty series**: Any poke operation raises an error.

### Type Compatibility

- **Strings**: Cannot poke `none`.
- **Binary**: Cannot poke logic values.
- **Blocks**: Can poke any value including `none` (displayed as `#(none)` in molded output).

### Negative Indices

Negative indices are **NOT supported** in Rebol 3 Oldes branch for `poke`. The diagnostic probe confirmed that attempting to use negative indices raises a "value out of range" error.

### Modulo Behavior

When poking integers into `binary!` or `string!`:

- Binary accepts values 0-255 directly.
- Values outside this range for binary raise errors (no automatic modulo).
- For strings, integers are converted to characters (0-255).

## Practical Examples

### Safe Poke Wrapper

For defensive programming, wrap `poke` with bounds checking:

```rebol
safe-poke: func [
    series [series!] 
    index [integer!] 
    value [any-type!]
][
    if any [index < 1 index > length? series] [
        make error! "Index out of bounds"
    ]
    poke series index value
]
```

### Using Poke for Performance

When you need to modify series elements using in-place efficiently:

```rebol
;; Faster than reconstructing the series:
data: copy [0 0 0 0 0]
repeat i 5 [poke data i i * 10]
print data  ;; [10 20 30 40 50]
```

## Error Handling

Common errors include:

- **"Index out of range"**: Index < 1 or > length
- **"Invalid argument"**: Type mismatch (e.g., poking logic into binary)
- **"Value out of range"**: Invalid numeric values for target series

Always use `try/with` or `try` when poking with dynamic indices:

```rebol
result: try [poke series index value]
if error? result [
    print ["Poke failed!"]
]
```

## Summary

`poke` is a powerful mutator function for in-place series modification. While simple in concept,
understanding its type-specific behaviors and boundary conditions is crucial for robust Rebol programming. Always validate indices and value types to prevent runtime errors.
