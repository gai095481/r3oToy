# Unofficial User's Guide - `combine` Function

## Overview

The `combine` function is a powerful tool for merging blocks of values into strings or other series types.
It evaluates expressions, handles multiple data types and provides fine-grained control over output formatting.

**Signature:**`COMBINE data /with delimiter /into out /ignore ignored /only`

## Basic Usage

### Simple Concatenation

```rebol
combine [1 2 3]                    ;; => "123"
combine [1 "abc" 3]                ;; => "1abc3"
combine []                         ;; => ""
```

### Expression Evaluation

**Key Feature:** Parentheses `()` are automatically evaluated:

```rebol
combine [1 (1 + 1) 2 (2 + 2) 3]   ;; => "122436"
combine ["Result: " (10 * 5)]      ;; => "Result: 50"
```

### Get-Word Resolution

Get-words (`:word`) are resolved to their values:

```rebol
test-word: "hello"
combine [1 :test-word 2]           ;; => "1hello2"
combine [1 :undefined-var 2]       ;; => "12" (undefined ignored)
```

## Refinements Guide

### `/with` - Add Delimiters

Inserts a delimiter between values:

```rebol
combine/with [1 2 3] ","           ;; => "1,2,3"
combine/with [1 2 3] " | "         ;; => "1 | 2 | 3"
combine/with [42] ","              ;; => "42" (no delimiter needed)
combine/with [] ","                ;; => "" (empty input)
```

### `/into` - Target Series Control

**Critical Understanding:**`/into` preserves original data types (doesn't stringify):

```rebol
target: copy ["prefix"]
combine/into [1 2 3] target        ;; => ["prefix" 1 2 3] (integers preserved!)

;; String target works as expected:
str-target: copy "prefix:"
combine/into [1 2 3] str-target    ;; => "prefix:123"

;; Empty targets work fine:
empty-target: copy []
combine/into [1 2 3] empty-target  ;; => [1 2 3]
```

### `/ignore` - Custom Type Filtering

Override the default ignored types:

```rebol
;; Default ignored: none! unset! error! any-function!
combine [1 none 3]                               ;; => "1none3" (none NOT ignored by default!)

;; Custom filtering:
custom-ignored: make typeset! [integer!]
combine/ignore [1 "text" 3] custom-ignored      ;; => "text"

;; Include everything:
empty-ignored: make typeset! []
combine/ignore [1 none 3] empty-ignored         ;; => "1none3"
```

### `/only` - Block Preservation

Treat blocks as single values instead of processing recursively:

```rebol
combine [[a b] [c d]]              ;; => "abcd" (recursive processing)
combine/only [[a b] [c d]]         ;; => "[a b][c d]" (blocks as single values)

;; With /into, blocks are inserted as single items:
target: copy ["prefix"]
combine/only/into [[a b]] target   ;; => ["prefix" [a b]]
```

## Refinement Combinations

### `/with` + `/into`

**Important:** Delimiter is inserted before each non-first value:

```rebol
target: copy ["prefix"]
combine/with/into [1 2 3] "," target  ;; => ["prefix" "," 1 "," 2 "," 3]
```

### `/ignore` + `/with`

Filter types while adding delimiters:

```rebol
ignore-ints: make typeset! [integer!]
combine/ignore/with [1 "a" 2 "b"] ignore-ints ","  ;; => "a,b"
```

### `/only` + `/with`

Blocks as single values with delimiters:

```rebol
combine/only/with [[a b] [c d]] ","  ;; => "[a b],[c d]"
```

## Advanced Features & Edge Cases

### Nested Block Processing

Without `/only`, blocks are processed recursively:

```rebol
combine [[a b] [c d]]              ;; => "abcd"
combine [1 [2 [3 [4]]]]          ;; => "1234"
```

### Complex Mixed Content

```rebol
combine [1 (2 + 3) [4 (5 * 2)] none "text"]  ;; => "15410nonetext"
;; Breakdown: 1, (2+3)→5, [4 (5*2)]→4,10, none, "text"
```

### Error Handling

Errors in expressions are gracefully handled:

```rebol
combine [1 (1 / 0) 3]              ;; => "13" (error ignored, processing continues)
```

### Unicode Support

```rebol
combine ["café" "naïve" "résumé"]  ;; => "cafénaïverésumé"
```

## Common Pitfalls & Solutions

### Pitfall 1: Expecting `none` to be Ignored by Default

**Problem:**`none` values appear in output

```rebol
combine [1 none 3]  ;; => "1none3" (not "13" as might be expected)
```

**Solution:** Use `/ignore` with a custom typeset if you want to filter `none`:

```rebol
ignore-none: make typeset! [none!]
combine/ignore [1 none 3] ignore-none  ;; => "13"
```

### Pitfall 2: Misunderstanding `/into` Behavior

**Problem:** Expecting string concatenation with block targets

```rebol
target: copy []
combine/into [1 2 3] target  ;; => [1 2 3] (integers preserved, not "123")
```

**Solution:** Use string target for concatenation:

```rebol
target: copy ""
combine/into [1 2 3] target  ;; => "123"
```

### Pitfall 3: Block Processing vs. Block Preservation

**Problem:** Nested blocks processed when you want them preserved

```rebol
combine [[a b] [c d]]        ;; => "abcd" (recursive processing)
```

**Solution:** Use `/only` to treat blocks as single values:

```rebol
combine/only [[a b] [c d]]   ;; => "[a b][c d]"
```

### Pitfall 4: Delimiter Placement with `/into`

**Problem:** Unexpected delimiter placement

```rebol
target: copy ["start"]
combine/with/into [1 2] "," target  ;; => ["start" "," 1 "," 2] (delimiter before each value)
```

**Solution:** Understand that delimiters are inserted before each non-first combined value.


## Best Practices

1. **Test with Your Data:** The behavior can be subtle with complex nested structures
2. **Use `/only` Judiciously:** Only when you specifically want blocks preserved as single values
3. **Validate Your Target:** When using `/into`, ensure your target series type matches expectations
4. **Handle Errors Gracefully:** Wrap in `try` blocks when processing untrusted data with expressions
5. **Document Your Typesets:** When using custom `/ignore` typesets, clearly document what's being filtered

---

## Quick Reference

| Use Case                    | Code Pattern                                          | Result                   |
| ----------------------------- | ------------------------------------------------------- | -------------------------- |
| Simple concatenation        | `combine [1 2 3]`                                 | `"123"`              |
| With delimiter              | `combine/with [1 2 3] ","`                        | `"1,2,3"`            |
| Into block (preserve types) | `combine/into [1 2] copy []`                      | `[1 2]`              |
| Into string                 | `combine/into [1 2] copy ""`                      | `"12"`               |
| Ignore specific types       | `combine/ignore [1 "a"] make typeset! [integer!]` | `"a"`                |
| Preserve blocks             | `combine/only [[a] [b]]`                          | `"[a][b]"`           |
| Expression evaluation       | `combine [1 (1 + 1) 3]`                           | `"1 2 3"`            |
| Get-word resolution         | `combine [1 :var 3]`                              | Depends on`var`value |

The `combine` function is extremely versatile but requires understanding of its evaluation model and datatype handling to use it effectively.
