# POKE Function User's Guide for Rebol 3 Oldes Branch

## Overview

The `poke` function is a fundamental data manipulation tool in Rebol 3 that allows you to modify elements within series (blocks, strings, binary data) and maps. It provides in-place modification with predictable return values and follows consistent 1-based indexing.

## Function Signature

```rebol
poke series index value
```

- **series**: The target data structure (block!, string!, binary!, map!)
- **index**: Position or key to modify (integer! for series, any-type! for maps)
- **value**: The new value to insert (any-type!)
- **Returns**: The exact value that was inserted

## Supported Data Types

### 1. Blocks (block!)

**Basic Usage:**
```rebol
my-block: [a b c d]
result: poke my-block 2 'CHANGED
;; Result: 'CHANGED
;; my-block is now: [a CHANGED c d]
```

**Key Points:**
- Uses 1-based indexing (first element is index 1)
- Modifies the block in-place
- Returns the exact value that was inserted
- Accepts any value type (words, integers, strings, nested blocks, etc.)

**Common Pitfalls:**
```rebol
;; ❌ DON'T: Use 0-based indexing
poke my-block 0 'value  ; Error!

;; ❌ DON'T: Access beyond series length
poke [a b c] 5 'value   ; Error!

;; ✅ DO: Use valid 1-based indices
poke my-block 1 'first   ; Replaces first element
poke my-block 3 'third   ; Replaces third element
```

### 2. Strings (string!)

**Basic Usage:**
```rebol
my-string: "hello"
result: poke my-string 3 #"X"
;; Result: #"X"
;; my-string is now: "heXlo"
```

**Character Handling:**
```rebol
;; Method 1: Using character literals
poke my-string 1 #"H"

;; Method 2: Using ASCII codes
poke my-string 2 65  ; Inserts 'A' (ASCII 65)
```

**Key Points:**
- Only accepts character values (#"c") or ASCII integers (0-255)
- Modifies string in-place
- Returns the character or ASCII code that was inserted

### 3. Maps (map!)

**Basic Usage:**
```rebol
my-map: make map! [name: "John" age: 30]
result: poke my-map 'name "Jane"
;; Result: "Jane"
;; my-map now contains: name: "Jane", age: 30
```

**Key Types:**
```rebol
;; Word keys (most common)
poke my-map 'city "New York"

;; String keys
poke my-map "email" "jane@example.com"

;; Integer keys
poke my-map 1 "first-value"

;; Logic keys
poke my-map true "yes-value"
```

**Key Points:**
- Creates new key-value pairs if key doesn't exist
- Updates existing key-value pairs if key exists
- Accepts any data type as key or value
- Returns the exact value that was inserted

### 4. Binary Data (binary!)

**Basic Usage:**
```rebol
my-binary: #{48656C6C6F}  ; "Hello" in hex
result: poke my-binary 3 108  ; 'l' in decimal
;; Result: 108
;; my-binary is now: #{48656C6C6F}
```

**Key Points:**
- Only accepts integer values (0-255) representing bytes
- Uses 1-based indexing like other series
- Modifies binary data in-place
- Returns the byte value that was inserted

## Error Conditions and Edge Cases

### Index Errors
```rebol
;; Invalid indices cause errors
poke [a b c] 0 'value    ; Error: index 0 is invalid
poke [a b c] -1 'value   ; Error: negative indices invalid
poke [a b c] 5 'value    ; Error: beyond series length
poke "" 1 #"X"           ; Error: empty string
poke [] 1 'value         ; Error: empty block
```

### Value Type Restrictions
```rebol
;; Strings only accept characters or ASCII codes
poke "hello" 1 "string"  ; Error: must be char! or integer!
poke "hello" 1 [block]   ; Error: must be char! or integer!

;; Binary only accepts byte values (0-255)
poke #{FF} 1 256         ; Error: value must be 0-255
poke #{FF} 1 #{65}       ; Error: must be integer!, not binary!
```

### Special Values
```rebol
;; none values work but display differently in blocks
my-block: [a b c]
poke my-block 2 none
;; my-block shows as: [a #(none) c]
;; This is correct - none in blocks displays as #(none)
```

## Advanced Usage Patterns

### Working with Series References
```rebol
;; poke affects all references to the same series
original: [a b c]
reference: original
poke reference 1 'CHANGED
;; Both original and reference now: [CHANGED b c]
```

### Working with Positioned Series
```rebol
my-block: [a b c d e]
positioned: next my-block  ; Points to [b c d e]
poke positioned 1 'REPLACED  ; Replaces 'b
;; my-block is now: [a REPLACED c d e]
```

### Decimal Index Handling
```rebol
;; Decimal indices are truncated to integers
poke [a b c] 2.7 'X  ; Treated as index 2
;; Result: [a X c]
```

## Best Practices for Novice Programmers

### 1. Always Validate Indices
```rebol
safe-poke: function [series index value] {
    Safely poke a series with index validation.
    RETURNS: The value if successful, none if invalid.
    ERRORS: None - returns none instead of causing errors.
} [
    if any [
        not integer? index
        index < 1
        index > length? series
    ] [
        return none
    ]
    poke series index value
]
```

### 2. Handle Empty Series
```rebol
;; Check for empty series before poking
either empty? my-series [
    print "Cannot poke empty series"
] [
    poke my-series 1 new-value
]
```

### 3. Use Defensive Programming
```rebol
;; Wrap poke in error handling
set/any 'result try [
    poke my-series index new-value
]
either error? result [
    print ["Poke failed:" result/id]
] [
    print ["Successfully poked value:" result]
]
```

### 4. Remember Return Values
```rebol
;; poke returns the inserted value, not the series
my-block: [a b c]
returned-value: poke my-block 2 'NEW
;; returned-value is: 'NEW
;; my-block is: [a NEW c]
```

## Common Misconceptions

### ❌ "poke returns the modified series"
```rebol
;; WRONG assumption
result: poke [a b c] 2 'X
;; result is 'X, not [a X c]
```

### ❌ "poke uses 0-based indexing like other languages"
```rebol
;; WRONG - Rebol uses 1-based indexing
poke my-block 0 'value  ; Error!
poke my-block 1 'value  ; Correct - first element
```

### ❌ "poke creates a new series"
```rebol
;; WRONG - poke modifies in-place
original: [a b c]
result: poke original 1 'X
;; original is now [X b c], not [a b c]
```

### ❌ "none values don't work with poke"
```rebol
;; WRONG - none values work fine
poke [a b c] 2 none
;; Result: [a #(none) c]  ; #(none) is correct display format
```

## Performance Notes

- `poke` is highly optimized for in-place modification
- No memory allocation for simple value replacements
- Map operations may trigger internal reorganization for new keys
- Binary operations are direct byte manipulations (very fast)

## Summary

The `poke` function is a powerful, consistent tool for data modification in Rebol 3. Remember these key points:

1. **Always 1-based indexing** for series types
2. **Returns the inserted value**, not the modified series
3. **Modifies data in-place** - affects all references
4. **Strict type checking** for strings and binary data
5. **Flexible key types** for maps
6. **Predictable error conditions** for invalid operations

Master these fundamentals, and `poke` will become an indispensable tool in your Rebol programming toolkit.
