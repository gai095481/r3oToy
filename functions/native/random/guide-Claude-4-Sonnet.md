# Rebol 3 Random Function User's Guide for r3oToy

## Overview

The `random` function in Rebol 3 (Oldes branch) is a versatile action that generates random values or shuffles series.
It preserves the datatype of its input and offers several refinements for specialized behavior.

## Basic `random` Syntax

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
random 10        ;; Returns 1-10
random 100       ;; Returns 1-100
random -5        ;; Returns -5 to 0
random 0         ;; Always returns 0
```

### Using Decimal Values
- **Range**: Returns random decimal from 0.0 to N (exclusive of upper bound)
- **Precision**: Maintains decimal precision

```rebol
random 1.0       ;; Returns 0.0 to 0.999999...
random 10.5      ;; Returns 0.0 to 10.499999...
```

### Series (Blocks, Strings, etc.)
- **Behavior**: Shuffle the series **in-place** and return the same series reference.
- **Modification**: Original series is permanently modified in place.
- **Empty Series**: Returns the same empty series unchanged.

```rebol
my-list: [a b c d e]
random my-list   ; my-list is now shuffled
;; my-list itself has been modified!

my-string: "hello"
random my-string ;; my-string is now shuffled.
```

### Time and Date Values
- **Time**: Returns random time between 0:00:00 and the specified time
- **Date**: Returns random date between system epoch and the specified date

```rebol
random 12:00:00  ; Returns random time up to 12:00:00
random 31-Dec-2025 ; Returns random date up to the specified date
```

## Refinements

### `/seed` - Reproducible Random Sequences
Sets the random number generator seed for reproducible results.

```rebol
random/seed 12345
sequence-1: []
repeat i 5 [append sequence-1 random 100]

random/seed 12345  ; Same seed
sequence-2: []
repeat i 5 [append sequence-2 random 100]
;; sequence-1 and sequence-2 will be identical
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

empty-result: random/only []  ;; Returns `none`
```

### Combining Function Refinements
You can combine `/secure` and `/only`:

```rebol
secure-element: random/secure/only [x y z]
```

## Common Nuances and Solutions

### 1. Series Modification Surprise
**Caution**: Beginners often don't realize that `random` modifies series in-place.

```rebol
; WRONG - Original data is lost!
original-data: [important data here]
shuffled: random original-data
; original-data is now shuffled!

; CORRECT - Preserve original
original-data: [important data here]
shuffled: random copy original-data
; original-data remains unchanged
```

### Use with the Proper Datatypes
**Caution**: Some datatypes produce errors.

```rebol
;; These ERROR:
random $100.00   ;; `money!` is unsupported.
random none      ;; `none!` is unsupported.
random/seed none ;; `none!` is unsupported for `/seed`.
```

**Solution**: Only use supported datatypes (integer, decimal, series, time, date).

### 3. Range Nuance
**Caution**: Decimal vs integer range behavior differs.

```rebol
;; Integer: 1 to N (inclusive)
random 10        ; Returns 1, 2, 3, ... 10

;; Decimal: 0.0 to N (exclusive of upper bound)
random 10.0      ; Returns 0.0 to 9.999999...
```

### 4. Empty Series with `/only`
**Caution**: Not handling the `none` return value.

```rebol
;; INCORRECT - Could cause errors later:
result: random/only []
print result  ; Prints "none"

;; CORRECT - Handle the `none` case:
result: random/only my-series
either none? result [
    print "Series is empty."
][
    print ["Selected:" result]
]
```

## Practical Examples

### Safe Random Selection Function Wrapper
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
        return random/only series
    ]
]

;; Examples:
fruits: [apple banana cherry]
result: safe-random-pick fruits
result: safe-random-pick/default [] 'no-fruit
```

### Reproducible Testing
```rebol
;; Specify the seed for consistent test results:
random/seed 42
test-data: []
repeat i 10 [append test-data random 100]
;; test-data will always be the same sequence
```

### Secure Token Generation
```rebol
generate-secure-token: function [
    {Generate a secure random token of specified length.}
    length [integer!] "Length of token."
][
    chars: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
    token: copy ""
    repeat i length [
        append token random/secure/only chars
    ]
    token
]

;; Usage:
secure-token: generate-secure-token 16
```

## Best Practices

1. **Use `copy` before shuffling** when you need to preserve the original series.
2. **Handle empty series** when using `/only` refinement.
3. **Use `/secure` for cryptographic applications** when security matters.
4. **Specify seeds consistently** for reproducible testing scenarios.
5. **Validate datatypes** before calling random on user input.
6. **Remember range differences** between integers (1-N), and decimals (0.0-N).

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

This guide covers the essential aspects of the `random` function based on comprehensive testing,
helping both novice and experienced programmers use it effectively and avoid common pitfalls.
