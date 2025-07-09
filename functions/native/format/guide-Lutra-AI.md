# The Complete FORMAT Function User Guide

## Overview

The `FORMAT` function in Rebol creates formatted strings by applying formatting rules to a series of values. This guide covers all behaviors, including critical nuances and idiosyncratic behaviors discovered through systematic testing.

## Basic Syntax

```rebol
FORMAT rules values
FORMAT/pad rules values         ; Apply padding to all integer field formatting
```

## Core Behavior

FORMAT always:

- **Returns a string! type**
- **Processes rules sequentially with corresponding values**
- **Supports multiple rule types: integers, strings, characters, money, tags, words**
- **Handles extra values by appending them without formatting**

## Rule Types and Behaviors

### 1. Integer Rules (Field Width Formatting)

#### ⚠️ CRITICAL NUANCE: Inverted Alignment Convention

**Rebol's FORMAT uses OPPOSITE alignment from most systems:**

```rebol
; Positive integers = LEFT-align (unusual!)
format [5] ["ABC"]               ; Returns "ABC  " (left-aligned)
format [3] ["X"]                 ; Returns "X  " (left-aligned)

; Negative integers = RIGHT-align (unusual!)
format [-5] ["ABC"]              ; Returns "  ABC" (right-aligned)
format [-3] ["X"]                ; Returns "  X" (right-aligned)
```

**Why This Matters:**
Most formatting systems use positive for right-align and negative for left-align. Rebol does the opposite, which can cause confusion for developers from other languages.

#### Field Width Behavior

```rebol
; Field width larger than content - pads with spaces
format [8] ["hello"]             ; Returns "hello   " (left-aligned)
format [-8] ["hello"]            ; Returns "   hello" (right-aligned)

; Field width smaller than content - truncates
format [3] ["hello"]             ; Returns "hel" (truncated)
format [-3] ["hello"]            ; Returns "llo" (truncated from left)

; Zero field width - empty field
format [0] ["hello"]             ; Returns "" (empty)
```

#### Numeric Value Formatting

```rebol
; Numbers follow same alignment rules
format [6] [42]                  ; Returns "42    " (left-aligned)
format [-6] [42]                 ; Returns "    42" (right-aligned)
format [3] [123456]              ; Returns "123" (truncated)
```

### 2. String Rules (Literal Text Insertion)

```rebol
; String rules insert literal text
format ["Hello"] []              ; Returns "Hello"
format ["Hello" " " "World"] []  ; Returns "Hello World"

; String rules work between field formatting
format ["Name: " 10 " Age: " 3] ["John" 25]  ; Returns "Name: John       Age: 25 "
```

### 3. Character Rules (Single Character Insertion)

```rebol
; Character rules insert single characters
format [#"-"] []                 ; Returns "-"
format [#"*" #"*" #"*"] []       ; Returns "***"

; Character rules work between field formatting
format [5 #"-" 5] ["ABC" "XYZ"]  ; Returns "ABC  -XYZ  "
```

### 4. Money Rules (ANSI Color Code Generation)

#### ⚠️ CRITICAL NUANCE: Money Rules Generate ANSI Codes

**Unexpected Behavior:**

```rebol
; Money rules generate ANSI escape sequences
format [$1.50] []                ; Returns ANSI color code ending in 'm'
format [$2.75] []                ; Returns different ANSI color code

; Different money values generate different codes
format [$1.00] []                ; One ANSI sequence
format [$5.00] []                ; Different ANSI sequence
```

**Why This Happens:**
Money rules in FORMAT are designed to generate ANSI color codes, likely for terminal coloring. This is an unusual and specialized behavior.

### 5. Tag Rules (Date/Time Formatting)

#### ⚠️ CRITICAL NUANCE: Extremely Limited Date/Time Support

**Strict Type Checking:**

```rebol
; Tag rules ONLY work with date! or time! values
format [<MM>] [now]              ; Works - formats month
format [<MM>] ["January"]        ; Doesn't work - inserts "<MM>January"

; Most specifiers DON'T work - treated as literals
format [<YYYY-MM-DD>] [now]      ; Returns "YYYY-31-DD" (only MM works!)
format [<HH:MI:SS>] [now/time]   ; Returns "HH:MI:SS" (none work for time!)
```

**Supported Specifiers:**

- `<MM>` - Month number (the ONLY working specifier)
- All other common specifiers (YYYY, DD, HH, MI, SS) are treated as literal text

**Real-World Example:**

```rebol
; This is what you might expect:
format [<YYYY-MM-DD>] [now]      ; Hoping for "2025-07-09"
; What you actually get: "YYYY-07-DD" (only MM is replaced!)
```

### 6. Word Rules (Variable Resolution)

```rebol
; Word rules resolve to their values and apply formatting
width: 8
format [width] ["hello"]         ; Returns "hello   " (left-aligned in 8 chars)

; String word rules resolve properly
padding: ">>>"
format [padding] []              ; Returns ">>>"

; Integer word rules resolve and apply alignment
right-width: -6
format [right-width] ["test"]    ; Returns "  test" (right-aligned)
```

## The /pad Refinement

```rebol
; /pad applies to all integer field formatting
format/pad [5 " | " -5] ["ABC" "XYZ"]  ; Left-aligns first, right-aligns second
; Without /pad: "ABC   | XYZ  "
; With /pad: "ABC   |   XYZ"
```

## Complex Formatting Scenarios

### Table-Style Formatting

```rebol
; Creating aligned columns
format ["Name: " 12 " Age: " -3 " Status: " 8] ["John Smith" 25 "Active"]
; Returns: "Name: John Smith   Age:  25 Status: Active   "
```

### Mixed Rule Combinations

```rebol
; Combining different rule types
format [#"[" 8 #"]" " - " $2.50 " - " <MM>] ["Task" $2.50 now]
; Returns: "[Task    ] - [ANSI-color-code] - 07"
```

## Edge Cases and Special Behaviors

### Extra Values Handling

```rebol
; Extra values are appended without formatting
format [5] ["ABC" "XYZ"]         ; Returns "ABC  XYZ"
format ["Hello"] ["World" "!"]   ; Returns "HelloWorld!"
```

### Empty Values

```rebol
; Empty string still respects field width
format [5] [""]                  ; Returns "     " (5 spaces)
format [-5] [""]                 ; Returns "     " (5 spaces)
```

### None Values

```rebol
; None values are converted to string "none"
format [6] [none]                ; Returns "none  "
format [-6] [none]               ; Returns "  none"
```

### Non-Block Rules

```rebol
; Non-block rules are reduced to block
format 5 ["test"]                ; Same as format [5] ["test"]
```

## Common Pitfalls and Solutions

### Pitfall 1: Expecting Standard Alignment Convention

**Problem:**

```rebol
; Expecting positive = right-align (like printf)
format [10] ["right?"]           ; Expecting "    right?"
; ACTUAL: "right?    " (left-aligned!)
```

**Solution:**

```rebol
; Remember Rebol's inverted convention
format [-10] ["right"]           ; Returns "     right" (right-aligned)
format [10] ["left"]             ; Returns "left      " (left-aligned)
```

### Pitfall 2: Expecting Full Date/Time Formatting

**Problem:**

```rebol
; Expecting comprehensive date formatting
format [<YYYY-MM-DD>] [now]      ; Expecting "2025-07-09"
; ACTUAL: "YYYY-07-DD" (only MM works!)
```

**Solution:**

```rebol
; Use alternative date formatting approaches
date-val: now
formatted: rejoin [
    date-val/year "-" 
    format [<MM>] [date-val] "-" 
    date-val/day
]
; Or use TO-ISODATE or other date functions
```

### Pitfall 3: Expecting Money Rules to Format Currency

**Problem:**

```rebol
; Expecting money formatting
format [$19.99] []               ; Expecting "$19.99"
; ACTUAL: ANSI color escape sequence
```

**Solution:**

```rebol
; Format money values manually
price: $19.99
formatted: rejoin ["$" price]    ; Returns "$19.99"
```

### Pitfall 4: Tag Rules with Wrong Data Types

**Problem:**

```rebol
; Using tag rules with wrong data types
format [<MM>] ["January"]        ; Expecting month formatting
; ACTUAL: "<MM>January" (literal tag + string)
```

**Solution:**

```rebol
; Ensure proper data types for tag rules
month-date: 15-Jan-2025
format [<MM>] [month-date]       ; Returns "01" (works with date!)
```

## Best Practices

### 1. Remember the Inverted Alignment

```rebol
; Use negative for right-align, positive for left-align
format [-10] ["right"]           ; Right-aligned
format [10] ["left"]             ; Left-aligned
```

### 2. Use Alternative Date Formatting

```rebol
; Don't rely on tag rules for complex date formatting
date-val: now
manual-format: rejoin [
    date-val/day "-" 
    pick system/locale/months date-val/month " " 
    date-val/year
]
```

### 3. Handle Edge Cases

```rebol
; Check for none values and empty strings
format-safe: function [width value] [
    if none? value [value: ""]
    format [width] [value]
]
```

### 4. Use String Building for Complex Formatting

```rebol
; For complex formatting, consider string building
build-report: function [name age status] [
    rejoin [
        "Name: " format [-15] [name]
        " Age: " format [-3] [age]
        " Status: " format [10] [status]
    ]
]
```

## Working with Different Data Types

### Strings

```rebol
format [15] ["Hello World"]      ; Left-aligned in 15 chars
format [-15] ["Hello World"]     ; Right-aligned in 15 chars
format [5] ["Hello World"]       ; Truncated to "Hello"
```

### Numbers

```rebol
format [8] [42]                  ; "42      " (left-aligned)
format [-8] [42]                 ; "      42" (right-aligned)
format [8] [3.14159]             ; "3.14159 " (left-aligned)
```

### Dates (Limited Support)

```rebol
; Only MM specifier works reliably
format [<MM>] [now]              ; Returns current month number
format [<MM/DD>] [now]           ; Returns "07/DD" (only MM works)
```

## Quick Reference

| Rule Type | Example | Behavior |
|-----------|---------|----------|
| Positive Integer | `[5]` | Left-align in 5 chars |
| Negative Integer | `[-5]` | Right-align in 5 chars |
| String | `["text"]` | Insert literal text |
| Character | `[#"-"]` | Insert single character |
| Money | `[$1.50]` | Generate ANSI color code |
| Tag (Date) | `[]` | Format month (MM only!) |
| Word | `[width]` | Resolve variable and apply |

## Alignment Quick Reference

| Width | Alignment | Example | Result |
|-------|-----------|---------|---------|
| Positive | LEFT | `format [5] ["hi"]` | `"hi   "` |
| Negative | RIGHT | `format [-5] ["hi"]` | `"   hi"` |
| Zero | Empty | `format [0] ["hi"]` | `""` |

## Summary

FORMAT is a specialized function with several idiosyncratic behaviors:

1. **Inverted alignment convention** - Positive = left, negative = right
2. **Limited date/time support** - Only MM specifier works for dates
3. **Money rules generate ANSI codes** - Not currency formatting
4. **Strict type checking for tags** - Only works with date!/time! values
5. **Automatic truncation** - Field width smaller than content truncates
6. **Extra values appended** - Unformatted values are appended to result

Understanding these nuances is crucial for effective use of FORMAT in Rebol applications. For complex formatting needs, consider combining FORMAT with manual string building techniques.
