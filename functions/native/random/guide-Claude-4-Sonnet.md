# Rebol 3 Random Function User's Guide

## Overview

The `random` function in Rebol 3 (Oldes branch) is a versatile action that generates random values or shuffles series.
It preserves the datatype of its input and offers several refinements for specialized behavior.

## Basic Syntax

```rebol
random value
random/seed value
random/secure value
random/only series
random/secure/only series
```

## Core Behavior by Datatype

### Integer Values
- **Range**: Returns random integer from 1 to N (inclusive)
- **Special Cases**: 
  - `random 0` → always returns `0`
  - `random -5` → returns random integer from -5 to 0 (inclusive)
  - `random 1` → always returns `1`

```rebol
random 10        ;; Returns 1-10.
random 100       ;; Returns 1-100.
random -5        ;; Returns -5 to 0.
random 0         ;; Always returns 0.
```

### Decimal Values
- **Range**: Returns random decimal from 0.0 to N (exclusive of upper bound)
- **Precision**: Maintains decimal precision

```rebol
random 1.0       ;; Returns 0.0 to 0.999999...
random 10.5      ;; Returns 0.0 to 10.499999...
```

### Series (Blocks, Strings, etc.)
- **Behavior**: Shuffles the series **in-place** and returns the same series reference
- **Modification**: Original series is permanently modified
- **Empty Series**: Returns the same empty series unchanged

```rebol
my-list: [a b c d e]
random my-list   ;; my-list is now shuffled
;; Note: my-list itself has been modified!

my-string: "hello"
random my-string ;; my-string is now shuffled
```

### Time and Date Values
- **Time**: Returns random time between 0:00:00 and the specified time
- **Date**: Returns random date between system epoch and the specified date

```rebol
random 12:00:00  ;; Returns random time up to 12:00:00
random 31-Dec-2025 ;; Returns random date up to the specified date
```

## Refinements

### `/seed` - Reproducible Random Sequences
Sets the random number generator seed for reproducible results.

```rebol
random/seed 12345
sequence-1: []
repeat i 5 [append sequence-1 random 100]

random/seed 12345  ;; Same seed again.
sequence-2: []
repeat i 5 [append sequence-2 random 100]
;; sequence-1 and sequence-2 will be identical.
```

**Important**: Only accepts integer seeds. `random/seed none` produces an error.

### `/secure` - Cryptographically Secure Random
Generates cryptographically secure random numbers suitable for security applications.

```rebol
secure-number: random/secure 100
secure-decimal: random/secure 1.0
```

### `/only` - Pick Without Modification
Selects a random element from a series without modifying the original series.

```rebol
fruits: [apple banana cherry]
random-fruit: random/only fruits
;; fruits remains unchanged: [apple banana cherry]
;; random-fruit contains one element, e.g., 'banana

empty-result: random/only []  ;; Returns `none`.
```

### Combining Refinements
You can combine `/secure` and `/only`:

```rebol
secure-element: random/secure/only [x y z]
```

## Common Pitfalls and Solutions

### 1. Series Modification Surprise
**Problem**: Beginners often don't realize that `random` modifies series in-place.

```rebol
;; INCORRECT - Original data is lost!:
original-data: [important data here]
shuffled: random original-data
; original-data is now shuffled!

;; CORRECT - Preserve the original:
original-data: [important data here]
shuffled: random copy original-data
;; original-data remains unchanged
```

### 2. Unsupported Datatypes
**Problem**: Some datatypes produce errors.

```rebol
;; These ERROR:
random $100.00   ;; `money!` unsupported datatype.
random none      ;; `none!` unsupported datatype.
random/seed none ;; `none!` not supported for seed.
```

**Solution**: Always use supported datatypes (integer, decimal, series, time, date).

### 3. Range Misunderstanding
**Problem**: Decimal vs integer range behavior differs.

```rebol
;; Integer: 1 to N (inclusive):
random 10        ; Returns 1, 2, 3, ... 10

;; Decimal: 0.0 to N (exclusive of upper bound):
random 10.0      ; Returns 0.0 to 9.999999...
```

### 4. Empty Series with `/only`
**Problem**: Not handling the none return value.

```rebol
;; INCORRECT - Could cause errors later:
result: random/only []
print result  ; Prints "none"

;; CORRECT - Handle the `none` case:
result: random/only my-series
either none? result [
    print "Series was empty"
][
    print ["Selected:" result]
]
```

## Practical Examples

### Safe Random Selection
```rebol
safe-random-pick: function [
    {Safely pick a random element from a series, handling empty series.}
    series [series!] "Series to pick from"
    /default "Default value if series is empty"
        default-value [any-type!] "Value to return if series is empty"
][
    either empty? series [
        either default [default-value][none]
    ][
        random/only series
    ]
]

; Usage:
fruits: [apple banana cherry]
result: safe-random-pick fruits
result: safe-random-pick/default [] 'no-fruit
```

### Reproducible Testing
```rebol
;; Set seed for reproducible test results:
random/seed 42
test-data: []
repeat i 10 [append test-data random 100]
;; test-data will always be the same sequence.
```

### Secure Token Generation
```rebol
generate-secure-token: function [
    {Generate a secure random token of specified length.}
    length [integer!] "Length of token"
][
    chars: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    token: copy ""
    repeat i length [
        append token random/secure/only chars
    ]
    return token
]

;; Usage:
secure-token: generate-secure-token 16
```

## Best Practices

1. **Always use `copy` before shuffling** if you need to preserve the original series
2. **Handle empty series** when using `/only` refinement
3. **Use `/secure` for cryptographic applications** where security matters
4. **Set seeds consistently** for reproducible testing scenarios
5. **Validate datatypes** before calling random on user input
6. **Remember range differences** between integers (1-N) and decimals (0.0-N)

## Error Handling Pattern

```rebol
safe-random: function [
    {Safely generate random value with error handling.}
    value [any-type!] "Value to randomize"
][
    set/any 'result try [random value]
    either error? result [
        print ["Error generating random value for:" mold value]
        return none
    ][
        return result
    ]
]
```

This guide covers the essential aspects of the `random` function based on comprehensive testing, helping both novice and experienced programmers use it effectively and avoid common pitfalls.

---

```
============================================
=== RANDOM FUNCTION DIAGNOSTIC PROBE ===
============================================

--- PROBING BASIC INTEGER BEHAVIOR ---
✅ PASSED: random 1 should always return 1
✅ PASSED: random 10 should return integer type
✅ PASSED: random 10 should return value between 1 and 10
✅ PASSED: random 100 should return integer type
✅ PASSED: random 100 should return value between 1 and 100
Multiple random 10 calls produced:  [10 10 2 10 9 7 9 7 2 5]

--- PROBING DECIMAL BEHAVIOR ---
✅ PASSED: random 1.0 should return decimal type
✅ PASSED: random 1.0 should return value between 0.0 and 1.0
✅ PASSED: random 10.5 should return decimal type
✅ PASSED: random 10.5 should return value between 0.0 and 10.5

--- PROBING SERIES SHUFFLING BEHAVIOR ---
✅ PASSED: random on block should return the same series reference
✅ PASSED: Original element a should still be present after shuffle
✅ PASSED: Original element b should still be present after shuffle
✅ PASSED: Original element c should still be present after shuffle
✅ PASSED: Original element d should still be present after shuffle
✅ PASSED: Original element e should still be present after shuffle
✅ PASSED: random on string should return the same series reference
✅ PASSED: random on string should return string type
✅ PASSED: random on empty block should return the same empty block

--- PROBING /SEED REFINEMENT ---
✅ PASSED: Same seed should produce identical sequences
✅ PASSED: Different seeds should produce different sequences

--- PROBING /ONLY REFINEMENT ---
✅ PASSED: random/only should return element from original series
✅ PASSED: random/only should not modify the original series
✅ PASSED: random/only should return character from original string
✅ PASSED: random/only should not modify the original string
Multiple random/only calls on  [apple banana cherry date elderberry]  produced:  [banana date apple apple banana elderberry date elderberry date date cherry date cherry apple date date apple apple cherry date]

--- PROBING /SECURE REFINEMENT ---
✅ PASSED: random/secure 100 should return integer type
✅ PASSED: random/secure 100 should return value between 1 and 100
✅ PASSED: random/secure 1.0 should return decimal type
✅ PASSED: random/secure 1.0 should return value between 0.0 and 1.0
✅ PASSED: random/secure on block should return the same series reference

--- PROBING COMBINED REFINEMENTS ---
✅ PASSED: random/secure/only should return element from original series

--- PROBING EDGE CASES AND BOUNDARY CONDITIONS ---
✅ PASSED: random 0 should return 0
✅ PASSED: random -5 should return integer type
✅ PASSED: random -5 should return value between -5 and 0
✅ PASSED: random none produces an error as expected
✅ PASSED: random/only on empty series should return none
✅ PASSED: random/seed none produces an error as expected
✅ PASSED: random on money! produces an error as expected

--- PROBING DATATYPE PRESERVATION ---
✅ PASSED: random on time! should return time! type
✅ PASSED: random on date! should return date! type

--- PROBING LARGE VALUES ---
✅ PASSED: random with large integer should return integer type
✅ PASSED: random with large integer should return value in expected range

--- PROBING DIFFERENT SERIES TYPES ---
✅ PASSED: random on vector should return same series reference
✅ PASSED: random on binary should return same series reference
✅ PASSED: random on binary should return binary type

============================================
=== DIAGNOSTIC PROBE COMPLETE ===
============================================

============================================
=== TEST SUMMARY ===
============================================
Total Tests:  44
Passed:  44
Failed:  0
============================================
✅ ALL TESTS PASSED - RANDOM IS STABLE
============================================
```
