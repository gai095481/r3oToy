# A MOVE Function User's Guide

## Overview

The `MOVE` function in Rebol moves elements within a series to new positions.
This guide covers all behaviors, including critical nuances and complex interactions discovered through systematic testing.

## Basic Syntax

```rebol
MOVE source offset
MOVE/part source offset length     ; Move specified number of elements
MOVE/to source position            ; Move to absolute position (1-based)
MOVE/skip source offset size       ; Treat series as fixed-size records
```

## Core Behavior

MOVE always:

- **Modifies the source series in-place**
- **Returns the position after where elements were inserted**
- **Works with all series types: blocks, strings, binary, etc.**
- **Handles complex position calculations and boundary conditions**

## Basic MOVE Operations

### Standard Position-Based Moves

```rebol
; Basic forward move
data: [a b c d e]
pos: at data 2               ; Position at 'b'
result: move pos 2           ; Move 'b' forward by 2
; data is now [a c d b e]
; result is [e] (position after insertion)

; Basic backward move
data: [a b c d e]
pos: at data 3               ; Position at 'c'
result: move pos -1          ; Move 'c' backward by 1
; data is now [a c b d e]
; result is [b d e] (position after insertion)
```

### ⚠️ CRITICAL NUANCE: Return Value is Position After Insertion

**Important Behavior:**

```rebol
; MOVE does NOT return the modified series
data: [a b c d e]
pos: at data 2
result: move pos 2           ; Move 'b' forward by 2
; result is [e] NOT [a c d b e]
```

**Why This Matters:**
Unlike many functions that return the modified data, MOVE returns the position after the insertion point, which is useful for chaining operations.

### Zero Offset Behavior

```rebol
; Zero offset still performs the move operation
data: [a b c d e]
pos: at data 2               ; Position at 'b'
result: move pos 0           ; Move 'b' by 0 (stays in same position)
; data remains [a b c d e]
; result is [c d e] (position after 'b')
```

## The /part Refinement

### Basic /part Usage

```rebol
; Move multiple elements as a contiguous block
data: [a b c d e f g]
pos: at data 1               ; Position at 'a'
result: move/part pos 3 2    ; Move 2 elements forward by 3
; data becomes [c d e a b f g]
; result is [f g] (position after insertion)
```

### ⚠️ CRITICAL NUANCE: /part with Overlapping Ranges

**Complex Behavior:**

```rebol
; /part can create complex rearrangements
data: [a b c d e f g h i j]
pos: at data 2               ; Position at 'b'
result: move/part pos 3 4    ; Move 4 elements forward by 3
; data becomes [a f g h b c d e i j]
; Elements are moved past the insertion point
```

**Why This Happens:**
When the part length extends beyond the insertion point, MOVE creates complex rearrangements to maintain the contiguous block structure.

### /part with Excessive Length

```rebol
; /part with length greater than available elements
data: [a b c d e]
pos: at data 2               ; Position at 'b'
result: move/part pos 2 10   ; Try to move 10 elements
; data may remain [a b c d e] (no change in some cases)
; result is [] (empty position)
```

## The /to Refinement

### Absolute Position Movement

```rebol
; Move to specific 1-based position
data: [a b c d e]
pos: at data 2               ; Position at 'b'
result: move/to pos 4        ; Move 'b' to position 4
; data becomes [a c d b e]
; result is [e] (position after insertion)
```

### /to with /part

```rebol
; Move multiple elements to absolute position
data: [a b c d e f g]
pos: at data 1               ; Position at 'a'
result: move/to/part pos 4 2 ; Move 2 elements to position 4
; data becomes [c d e a b f g]
; result is [f g] (position after insertion)
```

### ⚠️ CRITICAL NUANCE: /to Position Calculation

**Important Behavior:**

```rebol
; /to positions are calculated relative to head of series
data: [a b c d e]
pos: at data 1               ; Position at 'a'
result: move/to pos 5        ; Move to position 5 (at tail)
; data becomes [b c d e a]
; result is [] (position after tail)
```

## The /skip Refinement

### Record-Based Movement

```rebol
; Treat series as fixed-size records
data: [a b c d e f g h]
pos: at data 1               ; Position at 'a'
result: move/skip pos 2 2    ; Move record of size 2 by 2 records
; data becomes [c d e f a b g h]
; result is [g h] (position after insertion)
```

### /skip with /part

```rebol
; Move multiple records
data: [a b c d e f g h i j]
pos: at data 1               ; Position at 'a'
result: move/skip/part pos 1 2 2  ; Move 2 records by 1 record
; data becomes [e f a b c d g h i j]
; result is [g h i j] (position after insertion)
```

### /skip with /to

```rebol
; Move record to absolute record position
data: [a b c d e f g h]
pos: at data 1               ; Position at 'a'
result: move/skip/to pos 3 2 ; Move record to record position 3
; data becomes [c d e f a b g h]
; result is [g h] (position after insertion)
```

## Working with Different Series Types

### Strings

```rebol
; String movement works identically
text: "abcde"
pos: at text 2               ; Position at 'b'
result: move pos 2           ; Move 'b' forward by 2
; text becomes "acdbe"
; result is "e" (position after insertion)
```

### Unicode Strings

```rebol
; Unicode characters handled correctly
text: "αβγδε"
pos: at text 2               ; Position at 'β'
result: move pos 2           ; Move 'β' forward by 2
; text becomes "αγδβε"
; result is "ε" (position after insertion)
```

## Edge Cases and Special Behaviors

### Empty Series

```rebol
; MOVE on empty series does nothing
empty: []
result: move empty 1         ; Move on empty series
; empty remains []
; result is [] (empty position)
```

### Single Element Series

```rebol
; Single element series stay unchanged
single: [a]
pos: at single 1             ; Position at 'a'
result: move pos 1           ; Move 'a' by 1
; single remains [a]
; result is [] (position after element)
```

### Beyond Series Bounds

```rebol
; Move beyond series bounds goes to tail
data: [a b c]
pos: at data 2               ; Position at 'b'
result: move pos 5           ; Move 'b' beyond end
; data becomes [a c b]
; result is [] (position after tail)
```

### Large Negative Offsets

```rebol
; Large negative offsets go to head
data: [a b c d e]
pos: at data 5               ; Position at 'e'
result: move pos -10         ; Move 'e' far backward
; data becomes [e a b c d]
; result is [a b c d] (position after insertion)
```

## Common Pitfalls and Solutions

### Pitfall 1: Expecting Return Value to be Modified Series

**Problem:**

```rebol
; Expecting MOVE to return the modified series
data: [a b c d e]
pos: at data 2
result: move pos 2           ; Expecting result to be [a c d b e]
; ACTUAL: result is [e] (position after insertion)
```

**Solution:**

```rebol
; Use the modified series directly, not the return value
data: [a b c d e]
pos: at data 2
result: move pos 2           ; result is position after insertion
; Use 'data' for the modified series: [a c d b e]
```

### Pitfall 2: Misunderstanding /part with Overlapping Ranges

**Problem:**

```rebol
; Expecting simple sequential movement
data: [a b c d e f g h i j]
pos: at data 2
result: move/part pos 3 4    ; Expecting [a e f g h b c d i j]
; ACTUAL: [a f g h b c d e i j] (complex rearrangement)
```

**Solution:**

```rebol
; Understand that /part creates complex rearrangements
; Test with small examples first to understand the pattern
data: [a b c d e]
pos: at data 2
result: move/part pos 2 2    ; Move 2 elements forward by 2
; Study the result pattern before applying to larger data
```

### Pitfall 3: Incorrect /to Position Calculation

**Problem:**

```rebol
; Expecting /to to work relative to current position
data: [a b c d e]
pos: at data 3               ; Position at 'c'
result: move/to pos 2        ; Expecting to move 'c' 2 positions forward
; ACTUAL: moves 'c' to absolute position 2
```

**Solution:**

```rebol
; Remember /to uses absolute 1-based positions
data: [a b c d e]
pos: at data 3               ; Position at 'c'
result: move/to pos 2        ; Moves 'c' to position 2 (absolute)
; data becomes [a c b d e]
```

### Pitfall 4: Complex /skip Calculations

**Problem:**

```rebol
; Misunderstanding /skip record boundaries
data: [a b c d e f g h i]
pos: at data 1
result: move/skip pos 1 3    ; Expecting simple movement
; ACTUAL: complex record-based calculation
```

**Solution:**

```rebol
; Understand /skip works with record boundaries
; offset 1 with size 3 means move 1 record of 3 elements
data: [a b c d e f g h i]
pos: at data 1               ; Position at record 1 [a b c]
result: move/skip pos 1 3    ; Move record 1 by 1 record position
; data becomes [d e f a b c g h i]
```

## Best Practices

### 1. Always Consider the Return Value

```rebol
; Use return value for position-based operations
data: [a b c d e f g h]
pos: at data 2
result: move pos 3           ; result is position after insertion
; Use result for further operations at that position
```

### 2. Test Complex Operations with Small Data

```rebol
; Test /part operations with small examples first
test-data: [a b c d e]
pos: at test-data 2
result: move/part pos 2 2    ; Understand pattern with small data
; Then apply to larger datasets
```

### 3. Use Appropriate Refinements

```rebol
; For absolute positioning
move/to pos 4

; For multiple elements
move/part pos 3 2

; For record-based data
move/skip pos 2 3

; For combined operations
move/to/part pos 4 2
```

### 4. Handle Edge Cases

```rebol
; Check for empty series
if not empty? series [
    move pos offset
]

; Check for single element
if 1 < length? series [
    move pos offset
]
```

## Complex Scenarios

### Chaining MOVE Operations

```rebol
; Chain multiple moves using return values
data: [a b c d e f]
pos1: at data 2              ; Position at 'b'
pos2: move pos1 3            ; Move 'b' forward, get new position
pos3: move pos2 -2           ; Move from new position backward
; Final result depends on intermediate positions
```

### Record-Based Data Processing

```rebol
; Process fixed-size records
records: [name1 age1 name2 age2 name3 age3]
pos: at records 1            ; Position at first record
result: move/skip pos 2 2    ; Move first record by 2 positions
; records becomes [name2 age2 name3 age3 name1 age1]
```

### Partial Record Movement

```rebol
; Move part of records
data: [a b c d e f g h i j]
pos: at data 1               ; Position at start
result: move/skip/part pos 1 2 2  ; Move 2 records by 1 record
; Complex rearrangement based on record boundaries
```

## Quick Reference

| Operation | Syntax | Behavior |
|-----------|--------|----------|
| Basic move | `move pos offset` | Move element by offset positions |
| Move part | `move/part pos offset length` | Move length elements by offset |
| Move to position | `move/to pos position` | Move to absolute position |
| Record move | `move/skip pos offset size` | Move record by offset records |
| Combined | `move/to/part pos position length` | Move part to absolute position |

## Return Value Patterns

| Scenario | Return Value |
|----------|-------------|
| Normal move | Position after insertion |
| Move to tail | Empty position `[]` |
| Move beyond bounds | Position after actual insertion |
| Empty series | Empty position `[]` |
| Single element | Position after element |

## Summary

MOVE is a powerful function for rearranging series elements,
but its behavior involves complex position calculations and refinement interactions:

1. **Return value is position after insertion** - Not the modified series
2. **/part creates contiguous block movement** - Can cause complex rearrangements
3. **/to uses absolute positioning** - 1-based index from head
4. **/skip works with record boundaries** - Calculations based on record size
5. **Edge cases handled gracefully** - Empty series, bounds, single elements
6. **Refinements combine predictably** - /part/to, /skip/part, /skip/to all work

Understanding these nuances is crucial for effective series manipulation in Rebol.
Always test complex operations with small datasets first to understand the movement patterns before applying to larger data structures.
