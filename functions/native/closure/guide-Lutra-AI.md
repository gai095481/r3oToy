# Closure Functions: Basic User's Guide

## Overview

Rebol 3 Oldes branch supports closures as first-class functions with some nuances. Closures create `closure!` datatypes, support local variables, recursion, and context refinements. Understanding their behavior is key to effective use.

---

## Key Concepts

- **Closure datatype:** Closures are of type `closure!`.
- **Locals:** Set-words inside closure blocks become local variables, reinitialized on each call (no persistent state).
- **/with refinement:** Runs closure with an object context, allowing access to object fields as locals.
- **/extern refinement:** Allows closures to access and modify global variables.
- **Recursive and nested closures:** Supported and function correctly.
- **Type checking:** Use get-word syntax (`:closure-var`) to check type without executing the closure.
- **No-argument closures:** To execute a closure with no arguments, use `do :closure-var`.

---

## Creating Closures

```rebol
;; Simple closure returning 42
my-closure: closure [] [42]

;; Execute closure
result: my-closure
print result  ; => 42
```

---

## Locals and Scope

Locals are reinitialized on each call; they do not retain state between calls.

```rebol
counter: closure [] [
    local: 0
    local: local + 1
    local
]

print counter  ; => 1
print counter  ; => 1  ;; local resets each call
```

---

## Using /with Refinement

Run closure with an object context to access object fields as locals.

```rebol
obj: make object! [x: 10 y: 20]

sum-closure: closure [] [
    x + y
]

print sum-closure/with obj  ;; => 30
```

---

## Using /extern Refinement

Access and modify global variables inside closures.

```rebol
global-var: 5

modify-global: closure [] [
    /extern global-var
    global-var: global-var + 10
]

modify-global
print global-var  ; => 15
```

---

## Recursive Closures

Closures can call themselves recursively.

```rebol
factorial: none

factorial: closure [n] [
    either n <= 1 [
        1
    ][
        n * factorial n - 1
    ]
]

print factorial 5  ; => 120
```

---

## Type Checking Closures

To check if a variable is a closure without executing it, use get-word syntax:

```rebol
if closure? :my-closure [
    print "It's a closure!"
]
```

Avoid using the variable directly in `type?` or `closure?` as it executes the closure.

---

## Executing No-Argument Closures

Closures with no arguments require `do :closure-var` to execute if you want to avoid direct call syntax:

```rebol
no-arg: closure [] [print "Hello"]

do :no-arg  ;; Executes closure
```

---

## Common Pitfalls

- **Locals do not persist:** Locals are reset on every call; closures do not maintain state internally.
- **Type checking executes closure if not using get-word:** Use `:closure-var` to avoid execution.
- **No-argument closures need `do :closure-var` or direct call:** `no-arg-closure` alone returns the closure, not the result.
- **Misunderstanding /with and /extern:** `/with` sets object context, `/extern` accesses globals; they are not interchangeable.

---

## Best Practices

- Use `/with` to run closures in object contexts for clean, encapsulated code.
- Use `/extern` sparingly to modify globals; prefer passing parameters or using object contexts.
- Always use get-word syntax for type checking closures.
- For persistent state, use objects or external variables rather than relying on closure locals.
- Test recursive closures carefully to avoid infinite loops.

---

## Practical Example: Counter with External State

```rebol
counter-state: 0

counter: closure [] [
    /extern counter-state
    counter-state: counter-state + 1
    counter-state
]

print counter  ; => 1
print counter  ; => 2
print counter  ; => 3
```

---

## Summary

Rebol 3 Oldes branch closures are powerful but require understanding of their execution model:

- Locals reset each call.
- Use `/with` for object context.
- Use `/extern` for globals.
- Use get-word syntax for type checks.
- Use `do :closure` for no-arg execution.

Mastering these will enable effective functional programming in Rebol 3 Oldes.
