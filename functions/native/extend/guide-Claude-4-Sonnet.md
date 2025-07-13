# Rebol 3 Oldes Branch - EXTEND Function User's Guide

## Overview

The `extend` function is a powerful utility in Rebol 3 Oldes Branch that adds key-value pairs to objects, maps, block, and `paren!` structures.
It modifies the target container **in place** and returns the value that was added.

## Syntax

```rebol
extend target word value
```

- **target**: The container to extend (object!, map!, block!, or paren!)
- **word**: The key/property name (any word! type)
- **value**: The value to associate with the word

## Return Value

**CRITICAL**: `extend` always returns the **value** that was added, NOT the modified container.

## Supported Container Types

### 1. Objects

```rebol
;; Basic object extension
my-obj: make object! [name: "John"]
result: extend my-obj 'age 25
;; result = 25 (the value added)
;; my-obj/age = 25 (property added to object)

;; Overwriting existing properties
extend my-obj 'name "Jane"
;; my-obj/name = "Jane" (original value overwritten)
```

### 2. Maps

```rebol
;; Basic map extension
my-map: make map! [color: "red"]
result: extend my-map 'size "large"
;; result = "large"
;; my-map/size = "large"

;; Maps behave identically to objects
extend my-map 'color "blue"  ; Overwrites existing key
```

### 3. Blocks

```rebol
;; Block extension (adds set-word/value pairs)
my-block: [existing: "value"]
result: extend my-block 'new-item "block-value"
;; result = "block-value"
;; my-block = [existing: "value" new-item: "block-value"]

;; Empty blocks work too
empty-block: []
extend empty-block 'first-item "initial"
;; empty-block = [first-item: "initial"]
```

### 4. Paren! Structures

```rebol
;; Paren extension (similar to blocks)
my-paren: make paren! [existing: "paren-value"]
result: extend my-paren 'new-entry "paren-addition"
;; result = "paren-addition"
;; my-paren = (existing: "paren-value" new-entry: "paren-addition")
```

## Word Type Handling

`extend` accepts any `word!` datatype and normalizes it to a standard word:

```rebol
obj: make object! []

;; All of these create the same property
extend obj 'normal-word "value1"      ; word!
extend obj to-set-word 'set-word "value2"       ; set-word!
extend obj to-get-word 'get-word "value3"       ; get-word!
extend obj to-lit-word 'lit-word "value4"       ; lit-word!
extend obj to-refinement 'refinement "value5"   ; refinement!

;; Access all properties normally
print obj/normal-word    ; "value1"
print obj/set-word       ; "value2"
print obj/get-word       ; "value3"
print obj/lit-word       ; "value4"
print obj/refinement     ; "value5"
```

## Value Type Support

`extend` handles all Rebol value types:

```rebol
obj: make object! []

extend obj 'integer-val 42
extend obj 'decimal-val 3.14
extend obj 'string-val "hello"
extend obj 'block-val [1 2 3]
extend obj 'logic-val true
extend obj 'zero-val 0          ; Zero is truthy for extend
extend obj 'empty-string-val "" ; Empty string is truthy for extend
```

## CRITICAL GOTCHA: Falsy Value Behavior

⚠️ **WARNING**: `extend` has special behavior with falsy values:

```rebol
obj: make object! [existing: "original"]

;; These values cause extend to NOT add the property:
extend obj 'none-prop none     ; Property NOT added, returns none
extend obj 'false-prop false   ; Property NOT added, returns false

;; These values ARE added (they're truthy for extend):
extend obj 'zero-prop 0        ; Property IS added, returns 0
extend obj 'empty-prop ""      ; Property IS added, returns ""

;; Check if property exists
print in obj 'none-prop        ; false (not added)
print in obj 'false-prop       ; false (not added)
print in obj 'zero-prop        ; true (added)
print in obj 'empty-prop       ; true (added)
```

### Safe Pattern for Falsy Values

```rebol
;; To force addition of none or false values, use conditional logic:
safe-extend: function [target word value] {
    Safe extend that always adds the property regardless of value
} [
    either any [none? value, false = value] [
        ;; Handle falsy values explicitly
        do compose [extend (target) (word) (value)]
        value
    ][
        extend target word value
    ]
]
```

## CRITICAL GOTCHA: Function Value Evaluation

⚠️ **WARNING**: `extend` evaluates function values instead of storing them:

```rebol
obj: make object! []
test-func: function [] [print "Hello"]

;; This evaluates the function and stores the result (unset!)
result: extend obj 'func-prop :test-func
;; result is unset! (function was called, returned nothing)
;; obj/func-prop is unset! (not the function itself)
```

### Workaround for Function Storage

```rebol
;; To store functions, wrap them in a block or use a different approach:
obj: make object! []
test-func: function [] [print "Hello"]

;; Method 1: Store in a block
extend obj 'func-prop reduce [:test-func]
;; Access with: do first obj/func-prop

;; Method 2: Direct object assignment (recommended)
obj: make obj [func-prop: :test-func]
;; Access with: obj/func-prop
```

## In-Place Modification

**IMPORTANT**: `extend` modifies the original container, not a copy:

```rebol
original-obj: make object! [count: 1]
obj-reference: original-obj

extend original-obj 'new-prop "added"

;; Both references point to the same modified object
print obj-reference/new-prop  ; "added"
print obj-reference/count     ; 1
```

## Common Patterns and Best Practices

### 1. Safe Property Addition

```rebol
;; Always check return value for expected result
safe-add: function [obj key val] {
    Add property and verify it was added successfully
} [
    result: extend obj key val
    either in obj key [
        result
    ][
        make error! "Property was not added (likely falsy value)"
    ]
]
```

### 2. Conditional Extension

```rebol
;; Only extend if value is meaningful
conditional-extend: function [obj key val] {
    Only extend if value is not none or false
} [
    either any [none? val, false = val] [
        none  ; Don't extend
    ][
        extend obj key val
    ]
]
```

### 3. Builder Pattern

```rebol
;; Chain extensions for object building
build-config: function [name version] {
    Build a configuration object
} [
    config: make object! []
    extend config 'name name
    extend config 'version version
    extend config 'timestamp now
    extend config 'debug false
    config  ; Return the built object
]
```

### 4. Safe Block Extension

```rebol
;; When extending blocks, ensure proper set-word format
safe-block-extend: function [block-target key val] {
    Safely extend a block with proper set-word formatting
} [
    ;; Ensure key is a set-word for proper block syntax
    set-key: either set-word? key [key] [to-set-word key]
    extend block-target set-key val
]
```

## Error Handling

```rebol
;; Always wrap extend in try blocks when dealing with uncertain data
safe-extend-with-error: function [target key val] {
    Extend with error handling
} [
    set/any 'result try [extend target key val]
    either error? result [
        print ["Extension failed:" result/message]
        none
    ][
        result
    ]
]
```

## Performance Notes

- `extend` is efficient for adding single properties
- For bulk additions, consider using `make` with a spec block
- Map extensions are generally faster than object extensions
- Block extensions append to the end (O(1) operation)

## Summary

The `extend` function is powerful but has important nuances:
- Returns the **value added**, not the container
- Modifies containers **in place**
- Handles falsy values (`none`, `false`) by NOT adding them
- Evaluates function values instead of storing them
- Works with objects, maps, blocks, and paren! structures
- Accepts any word! type as the key

Understanding these behaviors will help you use `extend` effectively and avoid common pitfalls.
