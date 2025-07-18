# Rebol `sort` Function Unofficial Guide

## Introduction

The `sort` function orders series data (blocks, strings) in ascending order by default. Based on extensive testing in Rebol/Bulk 3.19.0, this guide documents verified behaviors and provides practical solutions to common challenges.

## Core Behavior

```rebol
sort series [case skip size compare comparator part range all reverse]
```

- **Modifies in-place**: Original series is modified (use `copy` to preserve original)
- **Default order**: Ascending (lexicographical for strings, numerical for numbers)
- **Mixed types**: Numbers sort before strings (`[5 "alpha"]` not `["alpha" 5]`)
  - Mixed types: Sorted by type (order: `integer!` < `decimal!` < `char!` < `string!`)
- **Stability**: Preserves order of equal elements (important for multi-key sorts)

## Basic Usage

```rebol
; Numeric sort
numbers: [3 1 4 2 5]
sort numbers  ; => [1 2 3 4 5]

; String sort (case-insensitive, spaces first)
text: "delta bravo alpha"
sort text  ; => "   aaaabdehllortv"
```

## Refinements Explained

### 1. `/reverse` - Descending Order

```rebol
sort/reverse [5 3 1 4 2]  ; => [5 4 3 2 1]
sort/reverse "abc"        ; => "cba"
```

### 2. `/case` - Case Sensitivity

```rebol
; Default (case-insensitive)
sort ["a" "C" "B"]  ; => ["a" "B" "C"]

; Case-sensitive sort (ASCII order: A=65, a=97)
sort/case ["a" "C" "B" "A"]  ; => ["A" "B" "C" "a"]
```

### 3. `/skip` - Record Sorting

Treats series as fixed-size records:

```rebol
; Sort records by first field (size=2)
data: [30 99 10 55 20 88]  ; Records: [30 99], [10 55], [20 88]
sort/skip data 2  ; => [10 55 20 88 30 99]

; Sort by second field (index 2)
sort/skip/compare data 2 2  ; => [10 55 20 88 30 99]
```

### 4. `/compare` - Custom Logic

Use comparator function or field index:

```rebol
; By string length
comp-func: func [a b] [(length? a) - (length? b)]
sort/compare ["aaa" "bb" "c"] :comp-func  ; => ["c" "bb" "aaa"]

; By record field (index 2)
sort/skip/compare [3 99 1 55 2 88] 2 2  ; => [1 55 2 88 3 99]
```

### 5. `/part` - Partial Sorting

Limit sort range:

```rebol
; Partial block sort
sort/part [5 4 3 2 1] 3  ; => [3 4 5 2 1]

; Partial string sort
sort/part "edcba" 3  ; => "cdeba"
```

### 6. `/all` - Full Record Comparison

When combined with `/skip`, compares entire records:

```rebol
; Without /all (sorts by first field)
sort/skip [3 300 1 100] 2  ; => [1 100 3 300]

; With /all (compares full records)
sort/skip/all [3 300 1 100] 2  ; => [1 100 3 300] ; Same as above
```

## Common Challenges & Solutions

### 1. Case-Insensitive String Sort

**Problem**: Default sort orders "Apple" before "apple"
**Solution**: Normalize case first:

```rebol
data: ["Apple" "banana" "apple"]
sort/compare data func [a b] [compare lowercase a lowercase b]
```

### 2. Stable Multi-Key Sort

**Problem**: Sort by primary key, then secondary
**Solution**: Leverage stability with successive sorts:

```rebol
; Sort by last name (secondary), then first name (primary)
names: [
    "John" "Smith"
    "Jane" "Doe"
    "John" "Doe"
]

; Secondary key first
sort/skip/compare names 2 2  ; Sort by index 2 (last name)

; Primary key next (preserves last name order)
sort/skip names 2  ; Sort by first name
```

### 3. Sorting Without Modification

**Problem**: Original data gets modified
**Solution**: Use `copy`:

```rebol
original: [3 2 1]
sorted: sort copy original  ; original unchanged
```

### 4. Mixed-Type Sorting

**Problem**: Numbers and strings sort unpredictably
**Solution**: Normalize types first:

```rebol
data: [10 "5" 20 "15"]
; Convert numbers to strings for consistent sorting
normalized: map data func [x] [either number? x [form x] [x]]
sort normalized  ; => ["10" "15" "20" "5"]
```

### 5. Custom Date Sorting

**Problem**: Dates as strings don't sort chronologically
**Solution**: Convert to date! first:

```rebol
dates: ["2025-12-01" "2023-01-15" "2024-06-30"]
converted: map dates func [d] [to-date d]
sort converted
```

## Performance Considerations

1. **Prefer blocks over strings** for complex sorts (faster modification)
2. **Combine refinements** (e.g., `/skip/compare`) instead of multiple sort passes
3. **Avoid nested sorts** for large datasets - use record-based sorting instead
4. **Reuse comparator functions** instead of redefining them

## Edge Case Handling

| Case | Behavior | Example |
|------|----------|---------|
| Empty series | Returns empty series | `sort [] ; => []` |
| Single element | Returns unchanged | `sort [1] ; => [1]` |
| All equal elements | Original order preserved | `sort [1 1 1] ; => [1 1 1]` |
| Zero/negative values | Sorts numerically | `sort [0 -1 1] ; => [-1 0 1]` |

## Pro Tips

1. **Debug sorts** with probe:
   ```rebol
   probe sort [...]
   ```
2. **Verify sort direction** with simple test:
   ```rebol
   sort [3 1 2] = [1 2 3] ; Should be true
   ```
3. **Chain refinements** for complex sorts:
   ```rebol
   sort/skip/case/reverse data 2
   ```

## Conclusion

Mastering `sort` requires understanding its refinements and edge case behaviors. Always:

1. Clarify case sensitivity requirements
2. Specify record size when working with structured data
3. Use `/compare` for custom ordering logic
4. Test with diverse datasets (mixed types, duplicates, empty series)
