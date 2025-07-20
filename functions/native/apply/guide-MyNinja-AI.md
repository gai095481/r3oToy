# Unofficial `apply` Function User's Guide

## Overview

The `apply` function provides a way to call functions dynamically with arguments stored in a block.
It's particularly useful for meta-programming, dynamic function calls and when you need to construct function arguments programmatically.

## Basic Syntax

```rebol
apply function-value argument-block
apply/only function-value argument-block  ; prevents argument evaluation
```

## Key Concepts

### 1. Function Values vs Function Words

**CRITICAL:**`apply` requires a function VALUE (with colon), not a function word.

```rebol
;; ✅ CORRECT - Using function value
apply :uppercase ["hello"]        ; → "HELLO"
apply :+ [3 5]                   ; → 8

;; ❌ WRONG - Using function word (will error)
apply uppercase ["hello"]        ; ERROR!
apply + [3 5]                   ; ERROR!
```

### 2. How Arguments Are Passed

The argument block contains the individual arguments that will be passed to the function:

```rebol
;; These are equivalent:
uppercase "hello"                ; Direct call
apply :uppercase ["hello"]       ; Via apply

;; These are equivalent:
+ 3 5                           ; Direct call  
apply :+ [3 5]                  ; Via apply

;; Multiple arguments
rejoin ["Hello" " " "World"]    ; Direct call
apply :rejoin [["Hello" " " "World"]]  ; Via apply
```

### 3. Argument Block Evaluation

By default, `apply` evaluates expressions in the argument block:

```rebol
;; Expressions are evaluated before passing to function
apply :+ [2 + 3 4]              ; → 9 (evaluates to: + 5 4)
apply :uppercase [lowercase "HELLO"]  ; → "hello" (evaluates lowercase first)

;; Variables are resolved
name: "world"
apply :uppercase [name]         ; → "WORLD"
```

### 4. The /ONLY Refinement

Use `/only` to prevent evaluation of the argument block:

```rebol
;; Without /only - expressions are evaluated
apply :print [2 + 3]            ; Prints: 5

;; With /only - expressions passed literally  
apply/only :print [2 + 3]       ; Prints: 2 + 3 (the words, not the result)
```

## Common Patterns and Solutions

### Pattern 1: Dynamic Function Selection

```rebol
;; Method 1: Using GET with word selection
condition: true
func-name: either condition ['uppercase] ['lowercase]
selected-func: get func-name
result: apply selected-func ["Hello"]  ; → "HELLO" or "hello"

;; Method 2: Direct function value selection
up-func: :uppercase
low-func: :lowercase
chosen-func: either condition [up-func] [low-func]
result: apply chosen-func ["Hello"]
```

### Pattern 2: Storing Function Values

```rebol
;; ✅ CORRECT way to store and use function values
my-func: :uppercase              ; Store function value
result: apply :my-func ["hello"] ; Use with colon prefix

;; Alternative using the stored value directly
my-func: :uppercase
result: apply my-func ["hello"]  ; Also works
```

### Pattern 3: Building Arguments Dynamically

```rebol
;; Building argument list programmatically
args: reduce ["Hello" " " "World"]
result: apply :rejoin [args]     ; → "Hello World"

;; Computing arguments
compute-math-args: func [a b] [reduce [a + 1 b * 2]]
math-args: compute-math-args 5 10  ; → [6 20]
result: apply :+ math-args       ; → 26
```

### Pattern 4: Spreading Block Elements

```rebol
;; To pass individual elements from a block as separate arguments
data: [1 2 3]

;; ❌ This passes the block as ONE argument
apply :some-func [data]          ; Passes [1 2 3] as single argument

;; ✅ This passes elements as separate arguments
apply :some-func data            ; Passes 1, 2, 3 as separate arguments

;; ✅ Using compose to build argument block
spread-data: [1 2 3]
apply :some-func compose [(spread-data)]  ; → apply :some-func [1 2 3]
```

## Common Pitfalls and Solutions

### Pitfall 1: Block Arguments vs Individual Arguments

```rebol
;; Function expecting individual arguments
my-func: func [a b c] [print [a b c]]

data: [1 2 3]

;; ❌ WRONG - passes block as first argument
apply :my-func [data]            ; Calls: my-func [1 2 3] none none

;; ✅ CORRECT - passes elements as separate arguments  
apply :my-func data              ; Calls: my-func 1 2 3
```

### Pitfall 2: Missing Arguments

```rebol
;; Function expecting 3 arguments, only 2 provided
my-func: func [a b c] [reduce [a b c]]

result: apply :my-func ["first" "second"]
;; → ["first" "second" none]  ; Missing arguments become 'none'
```

### Pitfall 3: Too Many Arguments

```rebol
;; Function expecting 2 arguments, 4 provided
my-func: func [a b] [reduce [a b]]

result: apply :my-func ["first" "second" "third" "fourth"]  
;; → ["first" "second"]  ; Extra arguments are ignored
```

### Pitfall 4: String Functions and Argument Types

```rebol
;; ✅ CORRECT - uppercase expects a string argument
apply :uppercase ["hello"]       ; → "HELLO"

;; ❌ WRONG - trying to pass wrong type
apply :uppercase [123]           ; ERROR! (number, not string)
```

## Advanced Usage

### Working with Refinements

```rebol
;; Some functions with refinements can be tricky
;; Check function's help for proper usage patterns

;; Example with copy/part
data: [1 2 3 4 5]
apply :copy/part [data 3]        ; May work depending on implementation
```

### Error Handling

```rebol
;; apply passes through errors from the target function
result: try [apply :uppercase [123]]  ; Catches type error
if error? result [
    print "Function call failed with wrong argument type"
]
```

### Performance Considerations

```rebol
;; Direct function calls are faster than apply
;; Use apply when you need the dynamic behavior, not for static calls

;; ✅ Good use case - dynamic function selection
func-to-call: either condition [:uppercase] [:lowercase]
result: apply func-to-call [text]

;; ❌ Unnecessary use case - static call
result: apply :uppercase ["hello"]  ; Just use: uppercase "hello"
```

## Quick Reference

| Task                                 | Solution                                                |
| -------------------------------------- | --------------------------------------------------------- |
| Store function value                 | `my-func: :original-func`                           |
| Apply stored function                | `apply :my-func [args]`or`apply my-func [args]` |
| Dynamic function selection           | `func: get either condition ['func1] ['func2]`      |
| Prevent argument evaluation          | `apply/only :func [args]`                           |
| Pass block elements as separate args | `apply :func block-of-args`                         |
| Pass block as single argument        | `apply :func [block-variable]`                      |
| Handle missing arguments             | Function receives`none`for missing args             |
| Handle extra arguments               | Extra arguments are ignored                             |

## Summary

* Always use function VALUES (`:func`) with `apply`
* The argument block contains the arguments to pass to the function
* Arguments are evaluated unless you use `/only`
* Missing arguments become `none`, extra arguments are ignored
* Blocks are passed as-is, not flattened
* Use `apply` for dynamic scenarios, direct calls for static ones
