# Truncate Function User's Guide
*For Rebol 3 Oldes Branch (REBOL/Bulk 3.19.0)*

## Overview

The `truncate` function removes all elements from a series' head position up to (but not including) the current index position. Think of it as "cutting off the beginning" of a series based on where you're currently positioned within it.

## Basic Syntax

```rebol
truncate series
truncate/part series range
```

## Core Concept: Understanding Series Position

**Critical for novices:** Rebol series have a "current position" that acts like a cursor. The `truncate` function removes everything *before* this cursor position.

```rebol
;; Example: Understanding position
my-block: [a b c d e]        ;; Position 1 (at 'a')
my-block: skip my-block 2    ;; Position 3 (at 'c') 
result: truncate my-block    ;; Removes [a b], keeps [c d e]
;; Result: [c d e]
```

## Basic Usage Examples

### Working with Blocks

```rebol
;; At head position - nothing to remove
data: [apple banana cherry date]
truncate data
;; Result: [apple banana cherry date] (unchanged)

;; Advanced position - removes leading elements
data: [apple banana cherry date]
data: skip data 2              ;; Now pointing to 'cherry'
truncate data
;; Result: [cherry date]
```

### Working with Strings

```rebol
;; Remove prefix from string
text: "Hello World"
text: skip text 6             ;; Now pointing to 'W' in "World"
truncate text
;; Result: "World"

;; Remove multiple characters
filename: "document.txt"
filename: skip filename 8     ;; Now pointing to 't' in ".txt"
truncate filename
;; Result: ".txt"
```

## The /part Refinement

The `/part` refinement allows you to limit the length of the result after truncation.

### Using /part with Numbers

```rebol
;; Truncate then limit to specific length
data: [a b c d e f g h]
data: skip data 3             ;; Now at position 4 (pointing to 'd')
truncate/part data 3
;; Result: [d e f] (truncated to 'd e f g h', then limited to 3 elements)
```

### Using /part with Series Positions

```rebol
;; Truncate then limit to specific end position
data: [a b c d e f g h]
data: skip data 2             ;; Now at position 3 (pointing to 'c')
end-pos: skip data 3          ;; End position at 'f'
truncate/part data end-pos
;; Result: [c d e] (from 'c' to just before 'f')
```

## Edge Cases and Special Behaviors

### Empty Series
```rebol
empty-block: []
truncate empty-block
;; Result: [] (remains empty)
```

### Series at Tail Position
```rebol
data: [a b c d e]
data: tail data               ;; Position after last element
truncate data
;; Result: [] (all elements removed)
```

### Negative /part Values (Undocumented Feature)
```rebol
;; Discovered behavior: negative numbers are handled gracefully
data: [a b c d e]
data: skip data 2             ;; Now at position 3 (pointing to 'c')
truncate/part data -1
;; Result: [c] (takes 1 element from current position)
```

## Common Pitfalls for Novices

### Pitfall 1: Forgetting About Series Position
```rebol
;; WRONG: Assuming truncate removes from the end
data: [a b c d e]
truncate data                 ;; Does nothing - already at head!

;; CORRECT: Position the series first
data: [a b c d e]
data: skip data 2             ;; Move to desired position
truncate data                 ;; Now removes [a b]
```

### Pitfall 2: Confusing String Index Counting
```rebol
;; WRONG: Miscounting character positions
text: "programming"           ;; 11 characters total
text: skip text 8             ;; Points to 'i' (position 9), not 'm'
truncate text
;; Result: "ing" (not "ming" as you might expect)

;; CORRECT: Count carefully or test first
text: "programming"
print index? text             ;; Shows current position
text: skip text 7             ;; Now points to 'm' (position 8)
truncate text
;; Result: "ming"
```

### Pitfall 3: Not Understanding Mutation
```rebol
;; IMPORTANT: truncate modifies the original series
original: [a b c d e]
copy-ref: skip original 2     ;; Both variables point to same series
result: truncate copy-ref
;; Now both 'original' and 'copy-ref' show [c d e]
;; The original series has been permanently modified!

;; SAFE: Use copy if you need to preserve original
original: [a b c d e]
working-copy: skip copy original 2
result: truncate working-copy
;; 'original' remains [a b c d e], 'result' is [c d e]
```

## Practical Use Cases

### Removing File Path Prefixes
```rebol
full-path: "/home/user/documents/file.txt"
full-path: find full-path "documents"  ;; Position at "documents"
truncate full-path
;; Result: "documents/file.txt"
```

### Processing Data Streams
```rebol
;; Remove processed items from a queue
queue: [task1 task2 task3 task4 task5]
queue: skip queue 2           ;; Skip first 2 processed tasks
truncate queue               ;; Remove them permanently
;; Result: [task3 task4 task5]
```

### Cleaning Up Parsed Data
```rebol
;; Remove unwanted header elements
parsed-data: [header1 header2 data1 data2 data3]
parsed-data: find parsed-data 'data1  ;; Position at first data element
truncate parsed-data
;; Result: [data1 data2 data3]
```

## Error Handling

```rebol
;; Always validate input for robust code
safe-truncate: function [series-input] {
    {Safely truncate a series with error handling}
    either series? series-input [
        truncate series-input
    ][
        make error! "Input must be a series"
    ]
}
```

## Best Practices

1. **Always know your position**: Use `index?` to check current position before truncating
2. **Use `copy` to preserve originals**: Truncate modifies the series permanently
3. **Test edge cases**: Empty series, tail position, single-element series
4. **Validate inputs**: Check that arguments are proper series types
5. **Document mutations**: Make it clear when functions modify their inputs

## Summary

The `truncate` function is a powerful tool for series manipulation in Rebol 3. Understanding series positioning is crucial for using it effectively. Remember that it modifies the original series and always removes elements from the beginning up to the current position, not from the end.
