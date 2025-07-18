# Unofficial COPY Function User Guide

## Overview

The `COPY` function in Rebol creates independent copies of series, maps, objects, and other data structures. This guide covers all behaviors, including critical nuances discovered through systematic testing.

## Basic Syntax

```rebol
COPY series
COPY/part series length     ; Copy specified number of elements
COPY/part series position   ; Copy up to specified position  
COPY/deep series            ; Create deep copies of nested structures
```

## Core Behavior

COPY always:

- **Creates a new independent copy with different identity**
- **Preserves the content and structure of the original**
- **Returns the same data type as the input**
- **Works with series, maps, objects, bitsets, functions, and more**

## Basic COPY Operations

### ✅ Standard Series Copying

```rebol
; Block copying
original: [a b c d]
copied: copy original        ; Returns [a b c d]
; copied and original have same content but different identity
same? original copied        ; Returns false

; String copying  
text: "hello"
text-copy: copy text         ; Returns "hello"
append text " world"
; text is now "hello world", text-copy is still "hello"

; Independence verification
append original 'e
; original is now [a b c d e], copied is still [a b c d]
```

### Empty Series Handling

```rebol
; Empty series create new empty instances
empty-block: []
empty-copy: copy empty-block
same? empty-block empty-copy ; Returns false - different identity

empty-string: ""
string-copy: copy empty-string
; Creates new empty string with different identity
```

## The /part Refinement

### Copying Specific Number of Elements

```rebol
; Copy first N elements
data: [a b c d e f]
partial: copy/part data 3    ; Returns [a b c]

; Copy first N characters
text: "hello world"
partial-text: copy/part text 5  ; Returns "hello"

; Edge cases with /part
copy/part data 0             ; Returns []
copy/part data 100           ; Returns [a b c d e f] (entire series)
```

### Copying Up to Position

```rebol
; Copy up to specific position
data: [a b c d e f]
position: at data 4          ; Points to 'd'
partial: copy/part data position  ; Returns [a b c]

; Works with strings too
text: "abcdef"
pos: at text 4               ; Points to 'd'
partial-text: copy/part text pos  ; Returns "abc"
```

### ⚠️ CRITICAL NUANCE: Position-Based /part

**Important Behavior:**

```rebol
; /part with position copies UP TO (not including) that position
data: [a b c d e]
pos: at data 3               ; Points to 'c'
result: copy/part data pos   ; Returns [a b] - stops BEFORE 'c'
```

## The /deep Refinement

### Understanding Shallow vs Deep Copying

```rebol
; Shallow copy shares nested references
nested: [a [b c] d]
shallow: copy nested
; The inner block [b c] is shared between nested and shallow

; Proof of shared reference
inner-original: second nested
inner-shallow: second shallow
same? inner-original inner-shallow  ; Returns true

; Deep copy creates independent nested structures
deep: copy/deep nested
inner-deep: second deep
same? inner-original inner-deep     ; Returns false
```

### When to Use /deep

```rebol
; Use /deep when you need complete independence
original: [user [name "John" age 30] status "active"]

; Shallow copy - nested blocks shared
shallow: copy original
put second shallow 'name "Jane"
; This modifies the original too!

; Deep copy - completely independent
deep: copy/deep original
put second deep 'name "Jane"
; Original remains unchanged
```

## Working with Different Data Types

### Maps

```rebol
; Map copying preserves all key-value pairs
original-map: make map! [name "John" age 30]
copied-map: copy original-map

; Maps are independent after copying
put original-map 'city "New York"
select copied-map 'city         ; Returns none - independent
same? original-map copied-map    ; Returns false
```

### Objects

```rebol
; Object copying creates new instance
person: make object! [name: "John" age: 30]
person-copy: copy person

; Object copies are independent
person/city: "Boston"            ; Add field to original
in person-copy 'city             ; Returns none - field not in copy
same? person person-copy         ; Returns false
```

### Functions

```rebol
; Function copying creates independent function instances
add-one: function [x] [x + 1]
add-one-copy: copy add-one

; Both functions work identically
add-one 5                        ; Returns 6
add-one-copy 5                   ; Returns 6
same? add-one add-one-copy       ; Returns false - different instances
```

### Bitsets

```rebol
; Bitset copying preserves bit patterns
charset-abc: make bitset! "abc"
charset-copy: copy charset-abc

; Bitsets are independent
insert charset-abc "def"
find charset-copy #"d"           ; Returns none - independent
same? charset-abc charset-copy   ; Returns false
```

### Binary Data

```rebol
; Binary copying preserves byte values
binary-data: #{010203FF}
binary-copy: copy binary-data

; Binary copies are independent
append binary-data #{AA}
length? binary-copy              ; Still 4 bytes - independent
same? binary-data binary-copy    ; Returns false
```

## Combined Refinements

### /part with /deep

```rebol
; Combine /part and /deep for partial deep copying
nested-data: [a [b [c d] e] f [g h] i]
partial-deep: copy/part/deep nested-data 2

; Result: [a [b [c d] e]] with independent nested structures
; Verify deep copying worked
original-nested: second nested-data
copy-nested: second partial-deep
same? original-nested copy-nested    ; Returns false
```

## Edge Cases and Special Behaviors

### Copying from Different Positions

```rebol
; Copy from middle of series
data: [a b c d e]
from-middle: copy at data 3      ; Returns [c d e]
from-end: copy tail data         ; Returns []
```

### Copying None Values

```rebol
; COPY of none returns none
result: copy none                ; Returns none
same? none result                ; Returns true (none is always same)
```

### Very Large /part Values

```rebol
; Large /part values copy entire series
small-data: [a b c]
large-copy: copy/part small-data 1000  ; Returns [a b c]
; No error - just copies what's available
```

## Common Pitfalls and Solutions

### Pitfall 1: Expecting Shared References After Copy

**Problem:**

```rebol
; Thinking copied data shares references
original: [a b c]
copied: copy original
append original 'd
; Expecting copied to also have 'd' - it doesn't!
```

**Solution:**

```rebol
; Understand that COPY creates independence
original: [a b c]
copied: copy original
; copied is now independent - changes to original don't affect it
```

### Pitfall 2: Shallow Copy with Nested Data

**Problem:**

```rebol
; Not realizing nested structures are shared
data: [user [name "John"] task [status "pending"]]
backup: copy data
put second backup 'name "Jane"
; This also changes the original data!
```

**Solution:**

```rebol
; Use /deep for complete independence
data: [user [name "John"] task [status "pending"]]
backup: copy/deep data
put second backup 'name "Jane"
; Original data remains unchanged
```

### Pitfall 3: Misunderstanding /part Position Behavior

**Problem:**

```rebol
; Expecting /part to include the position element
data: [a b c d e]
pos: at data 3                  ; Points to 'c'
result: copy/part data pos      ; Expecting [a b c]
; ACTUAL: [a b] - stops BEFORE the position
```

**Solution:**

```rebol
; Use next position to include the element
data: [a b c d e]
pos: at data 3                  ; Points to 'c'
result: copy/part data next pos ; Returns [a b c]
```

### Pitfall 4: Object Field Access Errors

**Problem:**

```rebol
; Trying to access non-existent fields
obj: make object! [name: "John"]
obj/age: 25                     ; This might error in some contexts
```

**Solution:**

```rebol
; Check field existence or use proper object extension
obj: make object! [name: "John"]
; Either extend the object properly or check existence
if not in obj 'age [
    obj: make obj [age: 25]     ; Proper extension
]
```

## Best Practices

### 1. Choose Appropriate Copy Type

```rebol
; For simple data without nesting
simple-copy: copy [a b c]

; For nested data that needs complete independence  
complex-copy: copy/deep [a [b [c d] e] f]

; For partial copying
partial-copy: copy/part data 5
```

### 2. Verify Independence When Needed

```rebol
; Test that copies are truly independent
original: [a b c]
copied: copy original
append original 'd
assert not equal? original copied  ; Should be true
```

### 3. Use /part for Memory Efficiency

```rebol
; When you only need part of large data
large-data: [... thousands of elements ...]
just-first-ten: copy/part large-data 10
; More memory efficient than copying everything
```

### 4. Handle Edge Cases

```rebol
; Check for none values
either series [
    copied: copy series
] [
    copied: none
]

; Handle empty series appropriately
either not empty? series [
    copied: copy series
] [
    copied: copy []  ; Explicit empty copy
]
```

## Working with Different Series Types

### Strings

```rebol
text: "Hello World"
text-copy: copy text             ; Independent string
partial: copy/part text 5        ; "Hello"
from-pos: copy at text 7         ; "World"
```

### Blocks (Most Common)

```rebol
data: [a b c [d e] f]
data-copy: copy data             ; Shallow copy
data-deep: copy/deep data        ; Deep copy
partial: copy/part data 3        ; [a b c]
```

### Maps

```rebol
user-data: make map! [name "John" age 30]
backup: copy user-data           ; Independent map
partial: copy/part user-data 1   ; Copies first key-value pair
```

## Quick Reference

| Operation | Syntax | Result |
|-----------|--------|---------|
| Basic copy | `copy data` | Independent copy with same content |
| Partial copy | `copy/part data 3` | Copy first 3 elements |
| Copy to position | `copy/part data pos` | Copy up to (not including) position |
| Deep copy | `copy/deep data` | Independent copy with nested independence |
| Combined | `copy/part/deep data 5` | Deep copy of first 5 elements |
| From position | `copy at data 3` | Copy from position to end |
| Empty series | `copy []` | New empty series |

## Summary

COPY is essential for creating independent data structures in Rebol. Understanding the difference between shallow and deep copying, how /part works with both numbers and positions, and the independence guarantees of COPY will help you avoid common data sharing bugs and use COPY effectively.

Key insights:

- COPY always creates independence (different identity)
- Use /deep for nested data that needs complete independence
- /part with position copies UP TO that position (exclusive)
- All data types can be copied with appropriate behavior
- Combined refinements (/part/deep) work as expected

