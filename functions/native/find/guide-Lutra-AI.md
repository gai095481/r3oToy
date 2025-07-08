# FIND Function - Help Reference by Lutra AI

## Overview

The `FIND` function searches for a value in a series and returns the position where found, or `none` if not found. This reference covers all refinements, edge cases, and behavioral nuances discovered through systematic testing.

## Syntax

```rebol
FIND series value
FIND/refinement series value [refinement-args]
```

## Basic Behavior

### String Searches
- **Substring matching**: `find "Hello World" "llo"` → `"llo World"`
- **Character matching**: `find "Hello World" "H"` → `"Hello World"`
- **Case insensitive by default**: `find "Hello" "hello"` → `"Hello"`
- **Returns none for no match**: `find "Hello" "xyz"` → `none`

### Block Searches
- **Value matching**: `find [1 2 3] 2` → `[2 3]`
- **Returns position from match**: `find [a b c] 'b` → `[b c]`
- **Exact value comparison**: `find [1 2 3] 4` → `none`

## Refinements

### `/part` - Limited Search Range
Limits the search to a specified length or position.

```rebol
find/part "abcdefg" "c" 5    ; → "cdefg" (found within limit)
find/part "abcdefg" "f" 3    ; → none (beyond limit)
find/part [1 2 3 4 5] 4 3    ; → none (beyond limit)
```

### `/only` - Treat Series as Single Value
Treats a series search value as a single element rather than searching within it.

```rebol
nested: [1 [2 3] 4]
find/only nested [2 3]       ; → [[2 3] 4] (finds the block)
find nested [2 3]            ; → none (doesn't find nested block)
```

### `/case` - Case Sensitive Search
Makes string searches case-sensitive.

```rebol
find "Hello" "hello"          ; → "Hello" (case insensitive)
find/case "Hello" "hello"     ; → none (case sensitive)
find/case "Hello" "Hello"     ; → "Hello" (exact match)
```

### `/same` - Identity Comparison
Uses `same?` instead of `equal?` for comparison, requiring identical object references.

```rebol
str1: "test"
str2: "test"
container: reduce [str1 str2 "other"]

find container str1           ; → [str1 str2 "other"] (finds first occurrence)
find/same container str1      ; → [str1 str2 "other"] (same reference)
find/same container "test"    ; → none (different reference)
```

⚠️ **Important**: Regular `find` always returns the first occurrence, regardless of reference equality.

### `/any` - Wildcard Pattern Matching
Enables `*` (multi-character) and `?` (single-character) wildcards.

```rebol
find/any "Hello World" "H?llo"    ; → "Hello World"
find/any "Hello World" "W*d"      ; → "World"
find/any "Hello World" "X*"       ; → none
```

### `/with` - Custom Wildcards
Allows custom wildcard characters instead of `*` and `?`.

```rebol
find/any/with "Hello World" "H@llo" "#@"  ; → "Hello World" (@ = single char)
find/any/with "Hello World" "W#" "#@"     ; → "World" (# = multi char)
```

The wildcard string format: first character = multi-character wildcard, second character = single-character wildcard.

### `/skip` - Record-Based Search
Treats the series as fixed-size records and only searches at record boundaries.

```rebol
records: [name "John" age 30 name "Jane" age 25]
find/skip records 'name 3     ; → [name "John" age 30 name "Jane" age 25]
find/skip records 30 3        ; → [30 name "Jane" age 25]
find/skip records "John" 3    ; → none (not at record boundary)
```

### `/last` - Search from End
Searches backwards from the end of the series.

```rebol
find/last "Hello World Hello" "Hello"  ; → "Hello" (last occurrence)
find/last [1 2 3 2 4] 2               ; → [2 4] (last occurrence)
```

### `/reverse` - Search Backwards from Position
Searches backwards from the current position.

```rebol
text: "Hello World Hello"
pos: find text "World"
find/reverse pos "Hello"      ; → "Hello World Hello" (finds backwards)
```

### `/tail` - Return Position After Match
Returns the position immediately after the found value.

```rebol
find/tail "Hello World" "Hello"   ; → " World"
find/tail [1 2 3 4] 2            ; → [3 4]
```

### `/match` - Return Head of Match
Performs comparison and returns the head of the match if found at current position.

```rebol
pos: find "Hello World" "World"
find/match pos "World"           ; → "World"
find/match pos "xyz"             ; → none
```

## Edge Cases & Sharp Edges

### Empty Values
- **Empty series**: `find "" "a"` → `none`
- **Empty search**: `find "Hello" ""` → `none` (not series head!)
- **Empty blocks**: `find [] 1` → `none`

### Special Values
- **None values**: `find [1 none 3] none` → `none` (cannot find none!)
- **Zero values**: `find [1 0 3] 0` → `[0 3]` (zero can be found)
- **Logic values**: `find [true false] true` → `none` (logic values not findable!)

### Data Type Behavior
| Type | Findable in Blocks | Notes |
|------|-------------------|-------|
| Integer | ✅ | Works as expected |
| String | ✅ | Works as expected |
| Word | ✅ | Use quoted form: `'word` |
| Decimal | ✅ | Works as expected |
| Logic | ❌ | `true`/`false` not findable |
| None | ❌ | Always returns `none` |

### Block Reference Behavior
Block references in containers have complex behavior:
- Variable references to blocks may not be findable
- Literal blocks work with `/only` refinement
- Use `/only` when searching for block values as single elements

## Refinement Combinations

### `/last/tail`
Finds last occurrence and returns tail position:
```rebol
find/last/tail "Hello World Hello" "Hello"  ; → "" (end of string)
```

### `/part/tail`
Limits search and returns tail position:
```rebol
find/part/tail [1 2 3 4 5] 3 4  ; → [4 5]
```

### `/case/last`
Case-sensitive search from end:
```rebol
find/case/last "Hello HELLO hello" "hello"  ; → "hello"
```

## Best Practices

1. **Use `/only` for block-in-block searches**
2. **Remember case sensitivity defaults** - use `/case` when needed
3. **Be aware of data type limitations** - logic values and none cannot be found
4. **Use `/same` carefully** - it requires identical references
5. **Test edge cases** - empty values and special types behave unexpectedly
6. **Consider `/part` for performance** - limits search scope

## Common Pitfalls

⚠️ **Empty string search returns `none`**, not the series head
⚠️ **Logic values (`true`/`false`) cannot be found in blocks**
⚠️ **`none` values cannot be found with regular `find`**
⚠️ **Block references may not be findable without `/only`**
⚠️ **`/same` requires identical object references, not just equal values**

## Examples

### Basic Usage
```rebol
; String searching
text: "The quick brown fox"
find text "quick"           ; → "quick brown fox"
find text "slow"            ; → none

; Block searching  
items: [apple banana cherry]
find items 'banana          ; → [banana cherry]
find items 'grape           ; → none
```

### Advanced Usage
```rebol
; Pattern matching with wildcards
find/any "filename.txt" "*.txt"     ; → ".txt"
find/any "test123" "test???"        ; → "test123"

; Record processing
data: [id 1 name "John" id 2 name "Jane"]
find/skip data 'name 3              ; → [name "John" id 2 name "Jane"]

; Case-sensitive last occurrence
find/case/last "Test TEST test" "test"  ; → "test"
```

This comprehensive reference covers all tested behaviors and edge cases of the `FIND` function in Rebol 3 Oldes branch.
