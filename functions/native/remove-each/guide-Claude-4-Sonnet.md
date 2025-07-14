# REMOVE-EACH Function User's Guide
## Rebol 3 Oldes Branch (REBOL/Bulk 3.19.0)

### Function Signature
```rebol
REMOVE-EACH 'word data body
REMOVE-EACH/count 'word data body
```

### Description
`remove-each` removes values from a series or map based on a conditional expression. It **modifies the original series** and returns the modified result.

### Arguments
- `'word` - [word! block!] Variable name(s) to bind each element during iteration
- `data` - [series! map!] The series to traverse and modify
- `body` - [block!] Condition block that returns truthy value to remove element

### Refinements
- `/count` - Returns the number of removed elements instead of the modified series

---

## Core Behavior

### 1. Basic Removal
```rebol
;; Remove numbers greater than 3
numbers: [1 2 3 4 5]
remove-each num numbers [num > 3]
;; numbers is now [1 2 3]

;; Remove vowels from string
text: "hello world"
remove-each char text [find "aeiou" char]
;; text is now "hll wrld"
```

### 2. Multiple Variable Binding
```rebol
;; Process pairs of values
pairs: [1 10 2 20 3 30 4 40]
remove-each [first second] pairs [first > 2]
;; pairs is now [1 10 2 20]
```

### 3. Count Refinement
```rebol
data: [1 2 3 4 5 6]
removed-count: remove-each/count num data [num > 3]
;; removed-count is 3
;; data is now [1 2 3]
```

---

## ⚠️ Critical Nuances & Gotchas

### 1. **NONE VALUES CANNOT BE REMOVED**
This is the most important limitation to understand:

```rebol
;; ❌ THESE DO NOT WORK
data: [1 none 2 none 3]
remove-each item data [none? item]     ; Does nothing!
remove-each item data [item = none]    ; Does nothing!
;; data remains [1 none 2 none 3]

;; ✅ WORKAROUND: Use different approach
data: [1 none 2 none 3]
clean-data: copy []
foreach item data [
    if not none? item [
        append clean-data item
    ]
]
;; clean-data is now [1 2 3]
```

**Why this happens:** `remove-each` appears to skip over `none` values entirely during iteration, making them invisible to the removal condition.

### 2. **Series Modification During Iteration**
The function modifies the series as it iterates, which can affect positioning:

```rebol
;; This works correctly
data: [1 2 3 4 5]
remove-each num data [num > 3]
;; Result: [1 2 3]

;; But be careful with complex conditions that depend on order
```

### 3. **Return Value Consistency**
```rebol
;; Without /count: returns modified series
data: [1 2 3 4 5]
result: remove-each num data [num > 3]
;; result and data are both [1 2 3]

;; With /count: returns number, series still modified
data: [1 2 3 4 5]
count: remove-each/count num data [num > 3]
;; count is 2, data is [1 2 3]
```

---

## Best Practices

### 1. **Handle None Values Explicitly**
```rebol
;; Instead of remove-each, use filtering approach
filter-none: function [series] {
    result: copy []
    foreach item series [
        if not none? item [
            append result item
        ]
    ]
    result
}

clean-data: filter-none [1 none 2 none 3]
;; clean-data is [1 2 3]
```

### 2. **Use Clear, Explicit Conditions**
```rebol
;; ✅ Good: Clear and explicit
remove-each num data [num > threshold]

;; ✅ Good: Complex but readable
remove-each num data [
    either even? num [
        num > 6
    ][
        num < 4
    ]
]
```

### 3. **Test Your Conditions First**
```rebol
;; Test your removal logic with foreach first
test-data: [1 2 3 4 5]
foreach num test-data [
    if num > 3 [
        print ["Would remove:" num]
    ]
]
;; Then apply with remove-each
remove-each num test-data [num > 3]
```

### 4. **Consider Copy If You Need Original**
```rebol
original: [1 2 3 4 5]
modified: copy original
remove-each num modified [num > 3]
;; original is still [1 2 3 4 5]
;; modified is [1 2 3]
```

---

## Common Use Cases

### 1. **Data Cleaning**
```rebol
;; Remove empty strings
clean-strings: function [string-list] {
    remove-each str string-list [empty? str]
    string-list
}

;; Remove invalid numbers
clean-numbers: function [num-list] {
    remove-each num num-list [not number? num]
    num-list
}
```

### 2. **Filtering with External State**
```rebol
;; Remove items based on external criteria
blacklist: ["bad" "worse" "terrible"]
remove-each word word-list [find blacklist word]
```

### 3. **Conditional Removal with Counting**
```rebol
;; Remove and count in one operation
removed-count: remove-each/count item data [meets-removal-criteria? item]
print ["Removed" removed-count "items"]
```

---

## Error Handling

### 1. **Catch Evaluation Errors**
```rebol
safe-remove: function [series condition] {
    set/any 'result try [
        remove-each item series condition
    ]
    either error? result [
        print ["Error in remove-each:" result]
        series  ; return unchanged series
    ][
        result
    ]
}
```

### 2. **Validate Input Types**
```rebol
validated-remove: function [data condition] {
    if not any [series? data map? data] [
        print "Error: Data must be series or map"
        return none
    ]
    remove-each item data condition
}
```

---

## Performance Notes

- `remove-each` modifies the series in place, making it memory efficient
- For large datasets, it's faster than creating new filtered series
- The `/count` refinement adds minimal overhead
- String operations are generally faster than block operations

---

## Summary

`remove-each` is a powerful but nuanced function. Key points to remember:

1. **It modifies the original series** - use `copy` if you need to preserve the original
2. **None values cannot be removed** - use alternative filtering approaches
3. **Test your conditions** before applying to important data
4. **The `/count` refinement** is useful for reporting and validation
5. **Error handling** is important when conditions might fail

Master these nuances, and `remove-each` becomes an invaluable tool for data manipulation in Rebol 3.
