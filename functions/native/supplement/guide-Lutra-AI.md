# Rebol `supplement` Function: Unofficial User Guide


## Overview

The `supplement` function appends a value to a block **only if that value is not already found** in the block. It returns the original block at the same position it was passed, making it ideal for building unique collections.

```rebol
USAGE: SUPPLEMENT series value
REFINEMENTS: /case - Case-sensitive comparison
```

## Basic Behavior

### Adding New Values

```rebol
data: [1 2 3]
supplement data 4
; Result: data is now [1 2 3 4]
```

### Skipping Existing Values

```rebol
data: [1 2 3]
supplement data 2
; Result: data remains [1 2 3] (unchanged)
```

## Return Value Behavior

**Important:** `supplement` always returns the same block object at the same position:

```rebol
original: [a b c]
positioned: next original    ; Points to [b c]
result: supplement positioned 'd

; original is now [a b c d]
; result is still positioned at [b c d] (same position as 'positioned')
; same? positioned result  ; Returns true
```

## Case Sensitivity

### Default Behavior (Case-Insensitive)

```rebol
data: ["hello" "world"]
supplement data "HELLO"
; Result: data remains ["hello" "world"] (unchanged)
```

### Using /case Refinement (Case-Sensitive)

```rebol
data: ["hello" "world"]
supplement/case data "HELLO"
; Result: data becomes ["hello" "world" "HELLO"]
```

## Data Type Handling

### Strings

```rebol
data: ["apple" "banana"]
supplement data "cherry"
; Result: ["apple" "banana" "cherry"]
```

### Numbers

```rebol
data: [1 2 3]
supplement data 0        ; Adds zero
supplement data -5       ; Adds negative numbers
supplement data 1.5      ; Adds decimals
; Result: [1 2 3 0 -5 1.5]
```

### Logic and None Values

```rebol
data: [a b]
supplement data true     ; Adds logic value
supplement data none     ; Adds none value
; Result: [a b #(true) #(none)]
; Note: Display shows #(true) and #(none) but values work normally
```

### Words

```rebol
data: ['red 'green]
supplement data 'blue
; Result: ['red 'green 'blue]
```

## Block Value Handling (CRITICAL BEHAVIOR)

**⚠️ Important:** When supplementing with a block value, the elements are **spread individually** into the target block, not added as a nested block.

### Block Spreading Behavior

```rebol
data: [a b]
supplement data [c d]
; Result: [a b c d]  (NOT [a b [c d]])
```

### Existence Checking with Blocks

The function checks if the **entire block** exists as a value before appending:

```rebol
data: [a b]
supplement data [a]      ; Even though 'a exists individually...
; Result: [a b a]       ; ...the block [a] doesn't exist, so 'a gets added
```

### Nested Block Example

```rebol
data: [[1 2] [3 4]]
supplement data [5 6]
; Result: [[1 2] [3 4] 5 6]  (elements 5 and 6 are spread)

; To add as nested block, you need a different approach:
data: [[1 2] [3 4]]
nested-block: [5 6]
unless find data nested-block [append/only data nested-block]
; Result: [[1 2] [3 4] [5 6]]  (nested block preserved)
```

## Common Patterns and Workarounds

### Building Unique Collections

```rebol
unique-items: []
supplement unique-items "apple"
supplement unique-items "banana"
supplement unique-items "apple"    ; Won't be added again
; Result: ["apple" "banana"]
```

### Case-Sensitive Unique Collections

```rebol
case-sensitive-items: []
supplement/case case-sensitive-items "Apple"
supplement/case case-sensitive-items "apple"
; Result: ["Apple" "apple"]  (both added due to case difference)
```

### Working with Empty Blocks

```rebol
empty-list: []
supplement empty-list "first-item"
; Result: ["first-item"]  (always adds to empty blocks)
```

### Preserving Nested Blocks (Workaround)

If you need to add blocks as nested elements instead of spreading:

```rebol
; Instead of: supplement data [nested block]
; Use this pattern:
data: [a b c]
new-block: [x y z]
unless find data new-block [
    append/only data new-block
]
; Result: [a b c [x y z]]  (block preserved as nested element)
```

## Edge Cases and Gotchas

### 1. Block Spreading Surprise

```rebol
; SURPRISING BEHAVIOR:
items: [task1 task2]
supplement items [task3 task4]
; You might expect: [task1 task2 [task3 task4]]
; You actually get: [task1 task2 task3 task4]
```

### 2. Duplicate Handling

```rebol
; Works with existing duplicates:
data: [1 2 2 3]
supplement data 2     ; No change (2 already exists)
supplement data 4     ; Adds 4
; Result: [1 2 2 3 4]
```

### 3. Position Preservation

```rebol
; The returned block maintains your position:
full-list: [a b c d e]
middle: next next full-list    ; Points to [c d e]
result: supplement middle 'f   ; Adds 'f to the end
; full-list is now: [a b c d e f]
; result points to: [c d e f]   (same relative position)
```

## Best Practices

1. **Use for unique collections**: Perfect for maintaining lists without duplicates
2. **Be aware of block spreading**: Use `append/only` if you need nested blocks
3. **Consider case sensitivity**: Use `/case` when exact case matching matters
4. **Test with your data types**: Behavior may vary with complex data structures
5. **Remember position preservation**: The function maintains your series position

## Alternative Functions

- `unique` - Removes duplicates from existing series
- `union` - Combines series with unique values
- `append/only` - Adds blocks as nested elements
- `append` - Always adds values regardless of existence

## Example: Building a Tag System

```rebol
; Building a unique tag collection:
article-tags: []
supplement article-tags "programming"
supplement article-tags "rebol"
supplement article-tags "tutorial"
supplement article-tags "programming"    ; Won't be added again
; Result: ["programming" "rebol" "tutorial"]
```
