# Rebol 3 Oldes Branch - EXTEND Function User's Guide

## Overview

The `extend` function is a powerful utility in Rebol 3 (Oldes Branch) that adds key-value pairs to objects, maps, blocks, and paren! structures.
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

## CRITICAL: Non-Evaluative Nature

⚠️ **IMPORTANT**: `extend` is **NON-EVALUATIVE**. It takes its value argument literally and stores it as-is.

```rebol
obj: make object! []

; `extend` stores the block literally
extend obj 'my-block [10 + 20]
; obj/my-block is now [10 + 20] (the block, not 30)

; To store the result of an expression, evaluate it BEFORE calling extend
result: 10 + 20
extend obj 'my-result result
; obj/my-result is now 30

; Another example with a more complex expression
extend obj 'literal-code [print "hello" 1 + 2]
; obj/literal-code is now [print "hello" 1 + 2] (not executed)

; To store the result of the code, evaluate first
calculated: do [print "hello" 1 + 2]
extend obj 'calculated-result calculated
; obj/calculated-result is now 3 (and "hello" was printed)
```

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

`extend` accepts any word! type and normalizes it to a standard word:

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

## CRITICAL: Function Storage

⚠️ **IMPORTANT**: To store a function in a property, pass the **word** that holds the function.
Be very careful not to use a get-word (`:my-func`), as the Rebol interpreter will run the function *before* calling extend and will pass its return value instead.

```rebol
my-obj: make object! []
my-func: function [] [return 123]

; CORRECT: Pass the word. The function value is stored.
extend my-obj 'stored-func my-func
; my-obj/stored-func is now a function!

; INCORRECT: Pass a get-word. The function runs first.
extend my-obj 'result-of-func :my-func
; my-obj/result-of-func is now 123 (the return value)

; Verify the function was stored correctly
print function? my-obj/stored-func  ; true
print my-obj/stored-func            ; calls the function, prints 123
```

## Falsy Value Behavior

⚠️ **IMPORTANT**: `extend` has special behavior with falsy values - this is a **feature**, not a bug:

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

### Unconditional Setting with PUT

The conditional behavior of `extend` with `none` and `false` is a useful feature.
If you want to bypass this and set a key unconditionally, the correct tool is `put`, not a workaround for `extend`:

```rebol
obj: make object! []

; Use put for unconditional setting
put obj 'my-key none    ; Correctly and unconditionally sets the key
put obj 'flag-key false ; Correctly and unconditionally sets the key

; Verify the properties exist
print in obj 'my-key     ; true
print in obj 'flag-key   ; true
print obj/my-key         ; none
print obj/flag-key       ; false
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

### 1. Conditional Extension (Leveraging the Feature)

```rebol
;; Use extend's conditional behavior for clean code
config: make object! []

;; Only add properties if they have meaningful values
extend config 'debug-mode debug-flag        ; Only added if not false/none
extend config 'log-level log-setting        ; Only added if not false/none
extend config 'max-connections max-conn     ; Only added if not false/none

;; Use put when you need to store false/none unconditionally
put config 'allow-anonymous false  ; Always set this flag
```

### 2. Builder Pattern

```rebol
;; Chain extensions for object building
build-config: function [name version] {
    Build a configuration object
} [
    config: make object! []
    extend config 'name name
    extend config 'version version
    extend config 'timestamp now
    extend config 'debug false      ; Won't be added due to false
    put config 'debug false         ; Use put to actually set false
    config  ; Return the built object
]
```

### 3. Safe Block Extension

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

### 4. Literal vs Evaluated Values

```rebol
;; Store code vs store results
code-storage: make object! []

;; Store code blocks for later execution
extend code-storage 'init-code [print "Initializing..."]
extend code-storage 'cleanup-code [print "Cleaning up..."]

;; Store calculated results
extend code-storage 'startup-time now
extend code-storage 'config-hash checksum to-string config

;; Execute stored code later
do code-storage/init-code     ; Prints "Initializing..."
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

The `extend` function is powerful with these key characteristics:
- Returns the **value added**, not the container
- Modifies containers **in place**
- Is **non-evaluative** - stores values literally
- Handles falsy values (`none`, `false`) by NOT adding them (use `put` for unconditional setting)
- Stores functions when passed as words, not get-words
- Works with objects, maps, blocks, and paren! structures
- Accepts any word! type as the key

Understanding these behaviors will help you use `extend` effectively and leverage its conditional features appropriately.
