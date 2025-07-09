# The Complete PUT Function User Guide by Lutra AI

## Overview

The `PUT` function in Rebol replaces or adds values in series, maps, and objects.
This guide covers all behaviors, including important nuances that can trip up novice programmers.

## Basic Syntax

```rebol
PUT series key value
PUT/case series key value      ; Case-sensitive key matching
PUT/skip series key value size ; Treat series as fixed-size records
```

## Core Behavior

PUT always:

- **Returns the value that was inserted**
- **Modifies the original series in place**
- **Maintains reference integrity** for the inserted values

## Working with Blocks (Key-Value Pairs)

### ✅ Standard Key-Value Operations

```rebol
; With word keys (recommended)
data: [name "John" age 30]
put data 'name "Jane"        ; Returns "Jane"
; data is now [name "Jane" age 30]

; With string keys
data: ["name" "John" "age" "30"]
put data "name" "Jane"       ; Returns "Jane"
; data is now ["name" "Jane" "age" "30"]

; Adding new key-value pairs
put data 'city "New York"    ; Returns "New York"
; data is now [name "Jane" age 30 city "New York"]
```

### ⚠️ CRITICAL NUANCE: Integer Keys Don't Work as Indexes

**Common Mistake:**

```rebol
; DON'T expect this to work like array indexing!
data: [10 20 30 40]
put data 2 99                ; You might expect [10 99 30 40]
; ACTUAL RESULT: [10 20 30 40 2 99] - appends key-value pair!
```

**The Fix - Use POKE for Index-Based Replacement:**

```rebol
; For index-based replacement, use POKE instead
data: [10 20 30 40]
poke data 2 99               ; Returns 99
; data is now [10 99 30 40]  - this is what you wanted!
```

**Why This Happens:**
PUT treats integer values as keys in key-value pairs, not as array indexes.
This is by design for consistency with word and string keys.

## Working with Maps

Maps work intuitively with PUT:

```rebol
user: make map! [name "John" age 30]
put user 'name "Jane"        ; Updates existing key
put user 'city "Boston"      ; Adds new key
; user now contains: name="Jane" age=30 city="Boston"
```

## Working with Objects

Objects also work as expected:

```rebol
person: make object! [name: "John" age: 30]
put person 'name "Jane"      ; Updates field
put person 'city "Boston"    ; Adds new field (if allowed)
```

## Refinements

### /case - Case-Sensitive Matching

```rebol
data: ["Key" "value1" "KEY" "value2" "key" "value3"]

; Without /case (case-insensitive, matches first occurrence)
put data "key" "updated"
; Result: ["Key" "updated" "KEY" "value2" "key" "value3"]

; With /case (exact case match required)
put/case data "key" "updated"
; Result: ["Key" "value1" "KEY" "value2" "key" "updated"]
```

### /skip - Record-Based Operations

Useful for structured data with fixed-size records:

```rebol
; Database-like records: 3 fields per record
records: [
    "John"   "Doe"     "Engineer"
    "Jane"   "Smith"   "Designer"  
    "Bob"    "Johnson" "Manager"
]

; Update the role for "Jane" (searches every 3rd position)
put/skip records "Jane" "Senior Designer" 3
; Finds "Jane" and updates the following value
```

## Handling Special Values

### None Values

```rebol
data: [key1 "value1"]
put data 'key2 none
; Result: [key1 "value1" key2 #(none)]
; Note: none displays as #(none) in Rebol 3
```

### Block Values

```rebol
data: [key1 "value1"]
nested: [a b c]
put data 'key2 nested
; Result: [key1 "value1" key2 [a b c]]
; The block reference is preserved
```

## Common Pitfalls and Solutions

### Pitfall 1: Expecting Array-Style Indexing

**Problem:**

```rebol
; This doesn't work as expected!
arr: [10 20 30]
put arr 2 99    ; Results in [10 20 30 2 99]
```

**Solution:**

```rebol
; Use POKE for positional updates
arr: [10 20 30]
poke arr 2 99   ; Results in [10 99 30]

; Or use path notation
arr/2: 99       ; Same result
```

### Pitfall 2: Expecting Series Extension with Padding

**Problem:**

```rebol
; This doesn't extend the series with none values
data: ["a" "b"]
put data 5 "e"  ; Results in ["a" "b" 5 "e"], not ["a" "b" none none "e"]
```

**Solution:**

```rebol
; For series extension, use INSERT with proper positioning
data: ["a" "b"]
insert at data 5 "e"  ; Or use other series manipulation functions
```

### Pitfall 3: Case Sensitivity Confusion

**Problem:**

```rebol
data: ["Name" "John"]
put data "name" "Jane"  ; Might not update what you expect
```

**Solution:**

```rebol
; Be explicit about case sensitivity
put/case data "Name" "Jane"  ; Exact case match
; OR ensure consistent casing in your data
```

## Best Practices

### 1. Use Word Keys When Possible

```rebol
; Preferred
data: [name "John" age 30]
put data 'name "Jane"

; Less preferred (but sometimes necessary)
data: ["name" "John" "age" "30"]
put data "name" "Jane"
```

### 2. Remember PUT Modifies In-Place

```rebol
original: [a 1 b 2]
modified: put original 'c 3  ; modified equals 3 (the return value)
; original is now [a 1 b 2 c 3] - it was modified!
```

### 3. Use Appropriate Function for Your Intent

```rebol
; For key-value operations
put data 'key "value"

; For positional replacement
poke data 2 "value"

; For insertion at position
insert at data 3 "value"

; For appending
append data "value"
```

### 4. Handle Return Values Appropriately

```rebol
; PUT returns the inserted value, not the modified series
data: [a 1]
result: put data 'b 2        ; result = 2
; If you need the modified series, use the original variable
print mold data              ; [a 1 b 2]
```

## Quick Reference

| Operation | Use | Example |
|-----------|-----|---------|
| Update/add key-value | `PUT` | `put data 'key "value"` |
| Case-sensitive key | `PUT/case` | `put/case data "Key" "value"` |
| Record-based update | `PUT/skip` | `put/skip records "key" "value" 3` |
| Index replacement | `POKE` | `poke data 2 "value"` |
| Position insertion | `INSERT AT` | `insert at data 3 "value"` |

## Summary

PUT is powerful for key-value operations but has specific behaviors that differ from array indexing.
Understanding these nuances—especially that integer keys create key-value pairs rather than index replacements—will help you use PUT effectively and avoid common mistakes.
