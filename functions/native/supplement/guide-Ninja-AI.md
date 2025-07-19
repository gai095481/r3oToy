## Unoffical `supplement` Function User's Guide

### SYNTAX

```rebol
supplement series value
supplement/case series value
```

DESCRIPTION
The supplement function appends a value to a block only if that value is not already found in the block. It returns the series at the same position it was given. The series is modified in-place.

ARGUMENTS
`series [block!]` - The block to modify (modified in-place)
`value [any-type!]` - The value to append if not found

REFINEMENTS
`/case` - Use case-sensitive comparison for strings

✅ BASIC BEHAVIORS
Basic Usage

```
data: [1 2 3]
supplement data 4        ;; => [1 2 3 4] (appends 4)
supplement data 2        ;; => [1 2 3 4] (no change, 2 exists)
```

Position Preservation

```
data: [a b c d]
positioned: next next data    ;; at position 'c
result: supplement positioned 'e
;; data is now [a b c d e]
;; result is [c d e] (preserves input position)
```

Case Sensitivity

```
data: ["Hello" "World"]
supplement data "hello"       ;; => ["Hello" "World"] (case-insensitive match)
supplement/case data "hello"  ;; => ["Hello" "World" "hello"] (case-sensitive)
```

Numeric Type Coercion

```
data: [1.0 2.0]
supplement data 1            ;; => [1.0 2.0] (1 matches 1.0)
```

⚠️ CRITICAL NUANCES AND WORKAROUNDS

1. BLOCK SPLICING ISSUE
   Problem: When supplementing with a block, elements get spliced instead of appended as a single element.

```
;; NUANCED BEHAVIOR:
data: [[1 2] [3 4]]
supplement data [5 6]        ;; => [[1 2] [3 4] 5 6] (NOT [[1 2] [3 4] [5 6]])
```

WORKAROUND: Use append/only manually or create a wrapper:

```
safe-supplement: func [series value] [
    unless find series :value [
        either block? :value [
            append/only series :value
        ][
            append series :value
        ]
    ]
    series
]

;; Usage:
data: [[1 2] [3 4]]
safe-supplement data [5 6]   ;; => [[1 2] [3 4] [5 6]] (correct)
```

2. LOGIC VALUE COMPARISON FAILURE
   Problem: supplement fails to detect existing `true` or `false` values, causing duplicates.

```
;; NUANCED BEHAVIOR:
data: [true]
supplement data false        ;; => [true false] (correct)
supplement data true         ;; => [true false true] (WRONG - true already exists!)
```

WORKAROUND: Manual check for logic values:

```
safe-supplement-logic: func [series value] [
    if all [
        any [value = true value = false]
        find series :value
    ][
        return series
    ]
    supplement series :value
]
```

3. NONE VALUE COMPARISON FAILURE
   Problem: supplement fails to detect existing none values.

```
;; NUANCED BEHAVIOR:
data: [1 none 3]
supplement data none         ;; => [1 none 3 none] (WRONG - none already exists!)
```

WORKAROUND: Manual `none` checking:

```
safe-supplement-none: func [series value] [
    if all [
        none? :value
        find series none
    ][
        return series
    ]
    supplement series :value
]
```

🛡️ POSSIBLE SAFE WRAPPER
For production code, use this robust wrapper that handles all edge cases:

```
safe-supplement: func [
    "Safely supplement a series, handling all edge cases"
    series [block!] "Series to modify"
    value [any-type!] "Value to add if not found"
    /case "Case-sensitive comparison"
][
    ;; Handle none values explicitly
    if none? :value [
        unless find series none [
            append series none
        ]
        return series
    ]
    
    ;; Handle logic values explicitly :
    if any [value = true value = false] [
        unless find series :value [
            append series :value
        ]
        return series
    ]
    
    ;; Handle blocks to prevent splicing:
    if block? :value [
        unless find series :value [
            append/only series :value
        ]
        return series
    ]
    
    ;; Use standard supplement for other types:
    either case [
        supplement/case series :value
    ][
        supplement series :value
    ]
]
```

📋 BEST PRACTICES

1. Know Your Data Types
   - Safe for: strings, numbers, words, characters
   - Riskier for: blocks, logic values, `none` values
2. Test Edge Cases
   - Always test your specific use case, especially with:
     - Empty blocks: `[]`
     - Mixed data types.
      -  Nested structures.
3. Consider Alternatives
   For simple uniqueness, consider:

```
unique append copy data new-value    ;; Always appends, then removes duplicates
```

4. Position Awareness
   Remember that supplement preserves the input position:

```
data: [a b c]
tail-pos: tail data
supplement tail-pos 'd               ;; Appends 'd', returns at tail position
```

🎯 WHEN TO USE SUPPLEMENT
Good for:

- Adding unique strings to a list.
- Building word lists.
- Simple numeric collections.
- When you need position preservation.

Less useful for:

- Collections containing blocks.
- Boolean flag management.
- Data structures with none values.
- Critical applications without testing.

🔍 DEBUGGING TIPS

- Always probe your results:

```
data: [some data]
result: supplement data new-value
probe data                           ;; Check the modified series
probe result                         ;; Check the return value
```

Test with your actual data types:
Don't assume - test with real data.

```
test-data: copy your-real-data
supplement test-data your-real-value
probe test-data
```

Tip: Use the diagnostic script provided in this guide to test edge cases specific to your use case.
