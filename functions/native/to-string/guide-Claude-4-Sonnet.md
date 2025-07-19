# Unoffical User's Guide: `to-string` Function

## Overview

The `to-string` function converts values from various Rebol datatypes into their string representation. While conceptually simple, this function has several important behaviors and edge cases that novice programmers should understand to use it effectively.

**Syntax:**`to-string value`

**Returns:** A `string!` value representing the input

**Errors on:**`none!` and `unset!` values

---

The key differences between `to-string` and `mold` are:

The `mold` function creates REBOL-readable strings (constructor format) - mold "hello" → "hello"
while `to-string` creates human-readable strings (display format) - to-string "hello" → hello

The `to-string` function exists for cases where you want the content of a value as a string for display purposes, not for serialization back to REBOL code.

This is particularly important for:

- User interfaces where you don't want quotes around strings.
- File output where you want raw content.
- Concatenation where you want the actual values, not their constructor syntax.

## Core Behavior Categories

### 1. Identity Conversions (Returns Unchanged)

These datatypes convert to strings that look exactly like their original form:

```rebol
to-string "hello"           ;== "hello"
to-string ""               ;== ""
to-string "multi^/line"    ;== "multi^/line"
```

**Key Point:** String-to-string conversion is always identity - the same string is returned unchanged.

### 2. Standard Formatted Conversions

These datatypes convert to predictable string formats:

```rebol
;; Numbers
to-string 42               ;== "42"
to-string -123             ;== "-123"
to-string 3.14             ;== "3.14"
to-string 0.0              ;== "0.0"

;; Logic values
to-string true             ;== "true"
to-string false            ;== "false"

;; Dates and times
to-string 1-Jan-2025       ;== "1-Jan-2025"
to-string 12:30:45         ;== "12:30:45"

;; Network types
to-string user@domain.com  ;== "user@domain.com"
to-string http://site.com  ;== "http://site.com"
```

### 3. Stripped Prefix Conversions

These datatypes lose their visual prefixes when converted:

```rebol
;; All word types become plain strings
to-string 'hello           ;== "hello"    (word!)
to-string hello:           ;== "hello"    (set-word!)
to-string :hello           ;== "hello"    (get-word!)
to-string 'hello           ;== "hello"    (lit-word!)

;; Special types lose their markers
to-string #"A"             ;== "A"        (character!)
to-string #issue-123       ;== "issue-123" (issue!)
to-string <html>           ;== "html"     (tag!)
to-string %/path/file.txt  ;== "/path/file.txt" (file!)
```

### 4. Concatenated Conversions (⚠️ Critical Gotcha!)

**Blocks convert by concatenating all elements as strings WITHOUT spaces:**

```rebol
to-string [1 2 3]         ;== "123"      (NOT "1 2 3")
to-string [a b c]         ;== "abc"      (NOT "a b c")
to-string [a [b c] d]     ;== "abcd"     (flattens completely)
to-string ["hi" "bye"]    ;== "hibye"    (NO spaces added)
to-string []              ;== ""         (empty string)
```

**This is the #1 source of confusion for beginners!** If you want spaced output, use `form` instead:

```rebol
form [1 2 3]              ;== "1 2 3"    (what you probably want)
```

### 5. Binary-to-Text Conversions

**Binary data converts to actual text characters (not hex representation):**

```rebol
to-string #{48656C6C6F}   ;== "Hello"    (interprets as UTF-8)
to-string #{DEADBEEF}     ;== "ޭ��"      (may produce non-printable chars)
to-string #{}             ;== ""         (empty binary = empty string)
```

**Warning:** Converting arbitrary binary data can produce unprintable or invalid UTF-8 characters.

### 6. Error Cases

**These datatypes will cause `to-string` to throw an error:**

```rebol
;; Always use try/error handling for these:
to-string none             ;== ERROR!
to-string ()               ;== ERROR! (unset! value)

;; Safe pattern:
set/any 'result try [to-string some-uncertain-value]
either error? result [
    print "Conversion failed"
][
    print ["Converted to:" result]
]
```

---

## Practical Usage Patterns

### Safe Conversion with Error Handling

```rebol
safe-to-string: function [
    {Safely converts a value to string, returning "N/A" on error}
    value [any-type!]
][
    set/any 'result try [to-string value]
    either error? result ["N/A"] [result]
]
```

### Converting Collections with Proper Spacing

```rebol
;; Wrong way (concatenated):
to-string [name: "John" age: 30]  ;== "nameJohnage30"

;; Right way (readable):
form [name: "John" age: 30]       ;== "name: John age: 30"

;; Manual control:
rejoin [to-string 'name ": " to-string "John"]  ;== "name: John"
```

### Type-Aware Conversion

```rebol
smart-convert: function [
    {Converts value to string with type-appropriate handling}
    value [any-type!]
][
    case [
        none? value        ["<none>"]
        unset? value       ["<unset>"]
        block? value       [form value]    ; Use form for readable blocks
        binary? value      [enbase value]  ; Convert to Base64 instead
        true              [to-string value]
    ]
]
```

---

## Common Gotchas and Solutions

### Gotcha #1: Block Concatenation

**Problem:**`to-string [1 2 3]` gives `"123"` not `"1 2 3"`**Solution:** Use `form` for readable output, or `rejoin` with explicit spacing

### Gotcha #2: Binary Interpretation

**Problem:**`to-string #{41}` gives `"A"` (ASCII 65), not `"#{41}"`**Solution:** Use `mold` to get the literal representation, or `enbase` for hex

### Gotcha #3: None/Unset Errors

**Problem:**`to-string none` crashes your script **Solution:** Always check for `none?` first, or use `try` blocks

### Gotcha #4: Word Type Confusion

**Problem:** All word types (`'word`, `word:`, `:word`) become identical strings **Solution:** Use `type?` to check the original datatype before conversion if distinction matters

---

## Quick Reference Cheat Sheet

| Input Type       | Example       | Output        | Notes                    |
| ------------------ | --------------- | --------------- | -------------------------- |
| `string!`    | `"hello"` | `"hello"` | Identity                 |
| `integer!`   | `42`      | `"42"`    | Decimal format           |
| `decimal!`   | `3.14`    | `"3.14"`  | Preserves decimals       |
| `logic!`     | `true`    | `"true"`  | Literal text             |
| `word!`      | `'hello`  | `"hello"` | Strips quote             |
| `block!`     | `[1 2]`   | `"12"`    | ⚠️ Concatenated!       |
| `character!` | `#"A"`    | `"A"`     | Single char              |
| `binary!`    | `#{41}`   | `"A"`     | ⚠️ Interprets as text! |
| `none!`      | `none`    | ERROR!        | ⚠️ Always errors       |
| `unset!`     | `()`      | ERROR!        | ⚠️ Always errors       |

---

## Best Practices

1. **Always handle `none` explicitly** before calling `to-string`
2. **Use `form` instead of `to-string` for blocks** when you want readable output
3. **Use `try` blocks** when converting uncertain values
4. **Check the datatype** with `type?` if the conversion behavior matters
5. **Consider `mold`** when you need the exact literal representation
6. **Be careful with binary data** - test with small samples first

Remember: `to-string` prioritizes conversion speed over human readability. When in doubt, test your specific use case.
