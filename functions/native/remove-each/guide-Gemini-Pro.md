# Rebol 3 Oldes Branch: The `remove-each` User's Guide

## 1. Overview

The `remove-each` function is a powerful iterator that **modifies a series in-place** by removing elements that match a given condition. It is one of the most common and idiomatic tools for filtering data directly.

The fundamental rule is simple: If the condition block returns `true` for an item, that item is removed.

---

## 2. Syntax

`remove-each` has two main forms:

**A. Single Word Binding (most common):**

```rebol
remove-each word series body
```

- **`word`**: A word that will hold the current value for each iteration.
- **`series`**: The series to iterate over and modify (e.g., a `block!` or `string!`).
- **`body`**: A block of code that is evaluated for each item. If it returns `true`, the item is removed.

**B. Multi-Word Binding (for processing in chunks):**

```rebol
remove-each [word1 word2 ...]
```

series body

- **`[word1 word2 ...]`**: A block of words that will hold values from the series in chunks.
  The number of words determines the chunk size.


---

## 3. Core Behavior & Examples

### Basic Block Filtering

`remove-each` iterates through the block and if the `body` returns `true`, the element is removed.

```rebol
my-numbers: [1 8 3 9 5 12]

;; Remove any number greater than 7
remove-each number my-numbers [
    number > 7
]

print my-numbers
;; == [1 3 5]
```

### Working with Strings

It works just as easily on strings, character by character.

```rebol
my-string: "r-e-b-o-l-!"

;; Remove any character that is a dash
remove-each char my-string [
    char = #"-"
]

print my-string
;; == "rebol!"
```

### The `/count` Refinement

Use the `/count` refinement when you need to know how many  items were removed instead of getting the modified block back.

```rebol
data: [10 20 30 40 50]

removed-count: remove-each/count item data [
    item > 25
]

print ["Removed:" removed-count]
print ["Data is now:" data]

;; == Removed: 3
;; == Data is now: [10 20]
```

**Notice** The original series is still modified, even when using `/count`.

---

## 4. Advanced Usage: Multi-Word Binding

You can process a series in fixed-size chunks by providing a block of words. Then `remove-each` will remove the entire chunk if the condition is true.

```rebol
user-data: [
    "John"  25   ;; Keep this pair
    "Jane"  42   ;; Remove this pair
    "Joe"   19   ;; Keep this pair
    "Jill"  50   ;; Remove this pair
]

;; Remove any user pair where the age is over 30
remove-each [name age] user-data [
    age > 30
]

print user-data
;; == ["John" 25 "Joe" 19]
```

---

## 5. CRITICAL NUANCE: `remove-each` Skips `none` Values

⚠️ **Caution:** This is the most important behavior to understand to avoid bugs. The `remove-each` iterator **completely ignores and skips over `none` values**.

If you have `none` values in your series, the condition block will **never execute** for them.

### Demonstration of the Behavior

```rebol
my-series: [1 2 none 4 none 6]

;; This code will NOT remove the `none` values
remove-each item my-series [
    print ["Testing:" mold item]
    none? item
]

print my-series

;; ---- CONSOLE OUTPUT ----
;; Testing: 1
;; Testing: 2
;; Testing: 4
;; Testing: 6
;; == [1 2 none 4 none 6]
```

Notice how "*Testing: none*" was never printed. The iterator skipped those values entirely.

### Correct Way to Remove `none` Values

Because `remove-each` cannot see `none` values, you must use a different, more direct pattern: a `while` loop that combines `find` and `remove`. This is the robust, idiomatic solution.

```rebol
data-with-nones: [1 2 none 4 none 6]

;; Loop as long as we can find a `none` value in the series
while [series-pos: find data-with-nones none] [
    remove series-pos ;; Remove the `none` at the found position
]

print data-with-nones
;; == [1 2 4 6]
```

---

## 6. Best Practices and Patterns

### A. Make a copy if you need to preserve the original data

`remove-each` is destructive. If you need to preserve the original block, work on a copy.

```rebol
original: [1 2 3 4 5]
filtered-data: remove-each item copy original [
    even? item
]

print ["Original:" original]   ;; Unchanged
print ["Filtered:" filtered-data] ;; Only contains odd numbers
```

### B. Inverting Logic for a `keep-each`

Rebol doesn't have a `keep-each`, but you can easily create one by inverting the logic of your condition block with `not`.

```rebol
data: [1 "apple" 2 "orange" 3 "banana"]

;; Keep only the strings
unwanted: remove-each item copy data [
    not string? item
]

print unwanted
;; == ["apple" "orange" "banana"]
```

### C. Series Position Matters

`remove-each` starts from the current position in the series. This allows you to process only the tail of a series.

```rebol
data: [a b c d e f]
tail-of-data: skip data 3 ;; Position the series at 'd'

remove-each item tail-of-data [
    find "aeiou" item ;; Remove vowels
]

print data
;; == [a b c d f] (only 'e' was removed from the tail part)
```
