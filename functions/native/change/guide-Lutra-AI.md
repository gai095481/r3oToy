# The Complete CHANGE Function User Guide

## Overview

The `CHANGE` function in Rebol modifies series by replacing values at the current position. This guide covers all behaviors,
including critical nuances discovered through systematic testing that can confuse novice programmers.

## Basic Syntax

```rebol
CHANGE series value
CHANGE/part series value count     ; Replace specified number of elements
CHANGE/only series value           ; Treat blocks as single values
CHANGE/dup series value count      ; Duplicate the value count times
```

## Core Behavior

CHANGE always:

- **Modifies the series at the current position**
- **Returns the position just past the change**
- **Maintains the original series reference**

## Basic CHANGE Operations

### ✅ Standard Position-Based Changes

```rebol
; Basic replacement
data: [a b c d]
pos: change data 'X              ; Returns [b c d]
; data is now [X b c d]

; Change at specific position
data: [a b c d]
pos: change next data 'Y         ; Returns [c d]
; data is now [a Y c d]

; String changes
text: "hello"
pos: change text "H"             ; Returns "ello"
; text is now "Hello"
```

### ⚠️ CRITICAL NUANCE: CHANGE at Tail Position

**Important Behavior:**

```rebol
; CHANGE at tail position APPENDS to the series
data: [a b c]
pos: change tail data 'Z         ; Returns []
; data is now [a b c Z] - Z was appended!
```

**Why This Matters:**
Unlike other positions, CHANGE at tail doesn't replace anything—it appends. This is by design and consistent across all series types.

## Working with Different Value Types

### Block Values Without /only

```rebol
; WITHOUT /only - block contents are expanded
data: [1 2 3]
change data [a b]
; Result: [a b 3] - the block [a b] was expanded

; WITH /only - block treated as single value
data: [1 2 3]
change/only data [a b]
; Result: [[a b] 2 3] - the block [a b] is inserted as one element
```

### Special Value Display

```rebol
; Logic values display as #(true)/#(false) in Rebol 3
data: [x y z]
change data true
; Result: [#(true) y z]

; None values display as #(none)
data: [x y z]
change data none
; Result: [#(none) y z]
```

## The /part Refinement

### Basic /part Usage

```rebol
; Replace specified number of elements
data: [a b c d e]
change/part data [X Y] 2         ; Replace 2 elements
; Result: [X Y c d e]
```

### ⚠️ CRITICAL NUANCE: /part Can Extend Series

**Unexpected Behavior:**

```rebol
; /part doesn't limit insertion length
data: [a b c]
change/part data [X Y Z W] 3     ; Replace 3, but insert 4
; Result: [X Y Z W] - series was extended beyond original boundaries!
```

**Why This Happens:**
The /part refinement specifies how many elements to replace, but doesn't limit how many can be inserted. The replacement can extend the series.

### /part with Zero Count

```rebol
; /part with 0 still performs the change
data: [a b c d]
pos: change/part data [X Y] 0    ; Replace 0 elements
; Result: [X Y a b c d] - values were inserted, not replaced!
```

## The /dup Refinement

### Basic Duplication

```rebol
; Duplicate a value multiple times
data: [a b c d e]
change/dup data 'X 3
; Result: [X X X d e]

; /dup with count 0 changes nothing
data: [a b c d]
change/dup data 'Z 0
; Result: [a b c d] - unchanged
```

### /dup with /only

```rebol
; Duplicate blocks as single values
data: [a b c d]
change/dup/only data [X Y] 2
; Result: [[X Y] [X Y] c d]
```

## Combined Refinements

### ⚠️ CRITICAL NUANCE: /part + /dup Interaction

**Key Behavior:**

```rebol
; /dup count takes precedence over /part limit
data: [a b c d e f]
change/part/dup data 'X 2 3      ; /part 2, /dup 3
; Result: [X X X c d e f] - 3 X's inserted, not 2!
```

**Why This Happens:**
When /part and /dup are used together, the /dup count determines how many elements are inserted, while /part determines how many to replace. The /dup count takes precedence.

### Triple Refinement Combinations

```rebol
; /part + /dup + /only
data: [a b c d e]
change/part/dup/only data [Y Z] 1 2
; Result: [[Y Z] [Y Z] b c d e]
; - Replaces 1 element (/part 1)
; - Inserts 2 copies (/dup 2)  
; - Treats [Y Z] as single value (/only)
```

## Edge Cases and Special Behaviors

### Empty Series

```rebol
; CHANGE on empty series modifies it by appending
empty: []
pos: change empty 'X             ; Returns []
; empty is now [X]
```

### Single Element Series

```rebol
; Works normally
single: [a]
pos: change single 'X            ; Returns []
; single is now [X]
```

### Large Duplication Counts

```rebol
; No built-in limits
data: [a b c d e f g h i j]
change/dup data 'X 100
; Result: [X X X X X ... ] - exactly 100 X's, no boundary limits
```

## Common Pitfalls and Solutions

### Pitfall 1: Expecting /part to Limit Insertion

**Problem:**

```rebol
; This doesn't limit insertion to 2 elements
data: [a b c]
change/part data [W X Y Z] 2     ; Might expect [W X c]
; ACTUAL: [W X Y Z] - all 4 elements inserted!
```

**Solution:**

```rebol
; Use /part with the replacement data, not the target
data: [a b c]
replacement: [W X Y Z]
change/part data copy/part replacement 2  ; [W X c]
```

### Pitfall 2: Forgetting CHANGE at Tail Appends

**Problem:**

```rebol
; Expecting no change at tail
data: [a b c]
change tail data 'X              ; Might expect [a b c]
; ACTUAL: [a b c X] - X was appended!
```

**Solution:**

```rebol
; Check if at tail before changing
data: [a b c]
if not tail? data [
    change data 'X
]
```

### Pitfall 3: Block Expansion vs. Single Value

**Problem:**

```rebol
; Expecting block to be inserted as single value
data: [1 2 3]
change data [a b]               ; Might expect [[a b] 2 3]
; ACTUAL: [a b 3] - block contents expanded!
```

**Solution:**

```rebol
; Use /only to treat block as single value
data: [1 2 3]
change/only data [a b]          ; [[a b] 2 3]
```

### Pitfall 4: Misunderstanding /part + /dup

**Problem:**

```rebol
; Expecting /part to limit /dup
data: [a b c d e]
change/part/dup data 'X 2 3     ; Might expect [X X c d e]
; ACTUAL: [X X X c d e] - /dup count wins!
```

**Solution:**

```rebol
; Use separate operations if you need strict limits
data: [a b c d e]
change/part data copy [] 2       ; Remove 2 elements
change data [X X]                ; Insert exactly 2 X's
```

## Best Practices

### 1. Always Consider the Return Value

```rebol
; CHANGE returns position past the change
data: [a b c d]
pos: change data 'X              ; pos = [b c d]
; Use pos to continue operations or data for the modified series
```

### 2. Use Appropriate Refinements

```rebol
; For single block values
change/only data [a b]

; For multiple copies
change/dup data 'X 3

; For controlled replacement
change/part data [X Y] 2
```

### 3. Handle Edge Cases

```rebol
; Check for tail position
if not tail? series [
    change series new-value
]

; Check for empty series
either empty? series [
    ; Handle empty case differently
    append series new-value
] [
    change series new-value
]
```

### 4. Understand Series Extension

```rebol
; CHANGE can extend series beyond original size
original-length: length? data
change/part data [lots of new values here] 1
; Series may now be longer than original-length
```

## Working with Different Series Types

### Strings

```rebol
text: "hello"
change text "H"                  ; "Hello"
change at text 3 "X"             ; "HeXlo"
```

### Binary Data

```rebol
binary: #{010203}
change binary #{FF}              ; #{FF0203}
```

### Blocks (Most Common)

```rebol
data: [a b c]
change data 'X                   ; [X b c]
change/only data [X Y]           ; [[X Y] b c]
```

## Quick Reference

| Operation | Refinement | Example | Result |
|-----------|------------|---------|---------|
| Basic change | none | `change [a b c] 'X` | `[X b c]` |
| Multiple elements | `/part` | `change/part [a b c] [X Y] 2` | `[X Y c]` |
| Single block value | `/only` | `change/only [a b c] [X Y]` | `[[X Y] b c]` |
| Duplicate values | `/dup` | `change/dup [a b c] 'X 2` | `[X X c]` |
| At tail position | none | `change tail [a b c] 'X` | `[a b c X]` |
| Empty series | none | `change [] 'X` | `[X]` |

## Summary

CHANGE is a powerful function for series modification, but its behavior at tail positions, refinement interactions, and block handling can be surprising.
Understanding these nuances—especially that CHANGE at tail appends, /part doesn't limit insertion length
and /dup count takes precedence over /part—will help you use CHANGE effectively and avoid common mistakes.

The key insight is that CHANGE is designed for flexible series modification, not strict replacement, which explains many of its seemingly unexpected behaviors.
