## User's Guide to the `mold` Function in Rebol 3 Oldes

### Table of Contents

1. [What is mold?](#what-is-mold)
2. [Basic Usage](#basic-usage)
3. [Understanding Construction Syntax](#understanding-construction-syntax)
4. [Refinements Guide](#refinements-guide)
5. [Common Pitfalls and Solutions](#common-pitfalls-and-solutions)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

### What is `mold`?

The `mold` function converts any Rebol value into a REBOL-readable string representation. This means the output can be loaded (via `load`), back into Rebol to recreate the original value. Think of it as Rebol's serialization function.

**Syntax:** `mold value [refinements]`

### Basic Usage

#### Common Data Types

```rebol
;; Numbers
mold 42                    ;; => "42"
mold 3.14159              ;; => "3.14159"
mold -100                 ;; => "-100"

;; Strings (note the quotes in the output)
mold "hello world"        ;; => {"hello world"}
mold ""                   ;; => {""}

;; Blocks
mold [1 2 3]             ;; => "[1 2 3]"
mold []                  ;; => "[]"

;; Words
mold 'symbol             ;; => "symbol"

;; Characters
mold #"A"                ;; => {#"A"}
```

### Understanding Construction Syntax

**⚠️ Important:** Some values use construction syntax with the `#(...)` format:

```rebol
;; Logic values
mold true                ;; => "#(true)"
mold false               ;; => "#(false)"

;; None value
mold none               ; ; => "#(none)"
```

**Why this matters:** This ensures proper round-trip loading:

```rebol
original: true
molded: mold original      ;; => "#(true)"
loaded: load molded        ;; => true (same as original)
```

### Refinements Guide

#### `/only` - Remove Block Brackets

Removes the outer brackets from blocks only, leaving the  inner structure intact.

```rebol
;; Basic usage
mold/only [1 2 3]      ;; => "1 2 3"
mold/only []              ;; => ""

;; With nested blocks (inner brackets preserved):
mold/only [1 [2 3] 4]     ;; => "1 [2 3] 4"

;; ⚠️ Words get quote prefix in block context:
mold/only [1 "hello" 'word]  ;; => {1 "hello" 'word}

;; With non-blocks (behaves like normal mold):
mold/only "not a block"   ;; => {"not a block"}
```

#### `/flat` - Remove Indentation

Remove indentation from complex nested structures, to put everything on one line.

```rebol
;; Most effective with multi-line formatted blocks:
complex: [
    first-level: [
        second-level: [
            third-level: "deep"
        ]
    ]
]

mold complex              ;; => Multi-line formatted output.
mold/flat complex       ;; => "[first-level: [second-level: [third-level: "deep"]]]"

;; ⚠️ Simple blocks may show no difference:
mold/flat [1 2 3]         ;; => "[1 2 3]" (same as normal)
```

#### `/part` - Limit the Output Length

Truncates the output to an exact character count.

```rebol
;; Truncation examples:
mold/part "this is a very long string" 10  ;; => "this is a " (exactly 10 chars).
mold/part [1 2 3 4 5 6 7 8 9 10] 8        ;; => "[1 2 3 4" (exactly 8 chars).

;; Edge cases:
mold/part "short" 100      ;; => {"short"} (no truncation if under limit).
mold/part "anything" 0    ;; => "" (empty string).
mold/part "test" 1            ;; => {"} (truncates mid-quote).

;; Works with the construction syntax:
mold/part none 3          ;; => "#(n" (truncates construction syntax).
```

#### `/all` - Use the Construction Syntax

Force construction syntax where applicable. Often shows no visible difference for many types.

```rebol
;; Might not show differences for basic types:
mold/all 123              ;; => "123" (same as normal).
mold/all [1 2 3]          ;; => "[1 2 3]" (same as normal).

;; Already uses construction syntax:
mold/all true             ;; => "#(true)" (same as normal).
mold/all none             ;; => "#(none)" (same as normal).
```

### Refinement Combinations

All refinements can be combined logically:

```rebol
;; Combining `/only` and `/part`:
mold/only/part [1 2 3 4 5] 5    ;; => "1 2 3" (remove brackets, limit to 5 chars).

;; Combining `/flat` and `/part`:
mold/flat/part complex-block 20  ;; => First 20 chars of flattened output.

;; Triple combination:
mold/only/all/flat [1 [2 3] 4]  ;; => "1 [2 3] 4" (all effects applied).
```

### Common Pitfalls and Solutions

#### 1. **Unexpected Construction Syntax**

```rebol
;; ❌ Wrong expectation:
if (mold true) = "true" [ ... ]           ;; FAILS! 

;; ✅ Correct approach:
if (mold true) = "#(true)" [ ... ]        ;; WORKS!
;; OR better yet:
if true [ ... ]                           ;; Direct logic test.
```

#### 2. **Quote Prefix in `/only` with Words**

```rebol
;; ❌ Wrong expectation:
mold/only ['word1 'word2]                 ;; => "'word1 'word2" (quotes preserved).

;; ✅ Understanding the behavior
;; This is correct behavior - words maintain their quote prefix.
```

#### 3. **Partial Truncation Issues**

```rebol
;; ❌ Can break in the middle of quotes or construction syntax:
mold/part "test" 1                        ;; => {"} (incomplete quote).
mold/part none 2                          ;; => "#(" (incomplete construction).

;; ✅ Always check length before truncation:
content: mold value
safe-part: either (length? content) > limit [
    copy/part content limit
][
    content
]
```

#### 4. **Function Value Molding**

```rebol
;; ❌ Might cause errors with some function types:
mold :some-function                       ;; Might error.

;; ✅ Use error handling:
try [
    result: mold :some-function
    print ["Function mold: " result]
] catch [
    print "Cannot mold this function type."
]
```

### Best Practices

#### 1. **Use for Serialization**

```rebol
;; Save the data to file:
data: [name: "John" age: 30]
write %data.reb mold data

;; Load data back:
loaded-data: load read %data.reb
```

#### 2. **Debugging and Inspection**

```rebol
;; Quick value inspection:
probe-value: func [value] [
    print ["Value: " mold value]
    print ["Type: " type? value]
]
```

#### 3. **Round-trip Testing**

```rebol
;; Verify data integrity:
test-roundtrip: func [value] [
    molded: mold value
    loaded: load molded
    either equal? value loaded [
        print "Round-trip successful"
    ][
        print "Round-trip failed!"
    ]
]
```

#### 4. **Safe Partial Molding**

```rebol
safe-mold-part: funct [value limit] [
    content: mold value
    either (length? content) > limit [
        rejoin [copy/part content (limit - 3) "..."]
    ][
        content
    ]
]
```

### Troubleshooting

### Issue: Unexpected output format

**Solution:** Remember `mold` produces REBOL-readable format, not human-readable. Use `form` for human-readable output.

### Issue: Can't compare molded values

**Solution:** Be aware of construction syntax. Use `equal?` on original values, not molded strings.

### Issue: Function molding errors

**Solution:** Wrap function molding in `try/catch` blocks.

### Issue: `/flat` not working

**Solution:** `/flat` only affects multi-line formatted structures. Simple blocks might show no difference.

#### Issue: "Truncated output looks wrong"

**Solution:** `/part` truncates at exact character count, which might break in the middle of quotes or syntax.

### Memory Aids

- **mold = REBOL-readable** (can be loaded back)
- **Construction syntax** = `#(true)`, `#(false)`, `#(none)`
- `/only` = remove outer brackets (blocks only)
- `/flat` = remove indentation (complex structures)
- `/part` = truncate to exact character count
- `/all` = force construction syntax (often same as normal)
- **Refinements combine** = all work together logically

### Quick Reference

```rebol
;; Basic molding:
mold value                           ;; Standard molding

;; Common refinement combinations:
mold/only block                      ;; Remove outer brackets.
mold/part value 50                   ;; Limit to 50 characters.
mold/flat complex-structure         ;; Remove indentation.
mold/only/part block 20             ;; Combine effects.
```

Remember: When in doubt, test with small examples first!
