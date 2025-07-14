# Rebol 3 Oldes Branch: The `resolve` User's Guide

## 1. Overview

The `resolve` function is a powerful tool for merging or synchronizing two objects (contexts).
It copies values from a `source` object to a `target` object based on a set of rules determined by refinements.

**Key Insight:** By default, `resolve` is extremely conservative. Without any refinements,
it does almost nothing to a target object that already has words defined, even if their values are `unset!`.
You **must** use refinements like `/all` and `/extend` to see any significant changes.

## 2. Syntax

```rebol
resolve target source
resolve/all target source
resolve/extend target source
resolve/all/extend target source
resolve/only target source words-or-index
;; ... and combinations thereof
```

- **`target`**: The object to be modified. This object is **modified in-place.**
- **`source`**: The object to copy values from.
- **Refinements**: Control the merging logic.

By itself, resolve performs a subtle but powerful operation: it re-binds words.
It was designed to link a context containing unbound code to another context that provides the definitions.
```
libs: context [ greet: func [name] [print ["Hi," name]] ]
app:  context [ main-logic: [greet "Rebol"] ]

;; This will fail because 'greet' has no meaning inside 'app'
;; >> do app/main-logic

;; Now we use resolve to link them:
resolve app libs

;; This now works, because 'greet' inside 'app' is now bound to the function in 'libs'
do app/main-logic
;; == Hi, Rebol
```

Key Takeaway: For 99% of use cases (like managing configuration), you won't use the base resolve function. You'll almost always use the refinements:
`/all`: To overwrite existing values.
`/extend`: To add new words.

See: _Using `resolve` without Function Refinements in Detail_ near the bottom of this document for further details.

## 3. The Refinements: Controlling the Merge

Understanding the refinements is the key to using `resolve`.

### `/all` - The "Overwrite" Switch

The `/all` refinement tells `resolve` to **overwrite** values in the `target` with
values from the `source` for all words that exist in *both* objects.

```rebol
source: context [a: 100 b: 200]
target: context [a: 1   b: 2   c: 3]

resolve/all target source

;; `target` is now: context [a: 100 b: 200 c: 3]
;; - `a` and `b` were overwritten.
;; - `c` was untouched because it's not in the source.
```

### `/extend` - The "Add New" Switch

The `/extend` refinement tells `resolve` to **add** words (and their values) from the `source` to
the `target` if they don't already exist in the `target`. It **will not** overwrite existing words.

```rebol
source: context [a: 100 b: 200 c: 300]
target: context [a: 1   b: 2]

resolve/extend target source

;; `target` is now: context [a: 1 b: 2 c: 300]
;; - `a` and `b` were untouched because they already existed.
;; - `c` was added because it was new.```

### `/all` + `/extend` - The "Full Sync"

When used together, these refinements create a full synchronization: existing words are overwritten, and new words are added.

```rebol
source: context [a: 100 b: 200 c: 300]
target: context [a: 1   b: 2]

resolve/all/extend target source

;; `target` is now: context [a: 100 b: 200 c: 300]
;; - `a` and `b` were overwritten.
;; - `c` was added.
```

### `/only` - The "Selective" Switch

The `/only` refinement restricts the operation to a specific subset of words.
It can be used with a block of words or an integer index.

```rebol
source: context [a: 100 b: 200 c: 300]
target: context [a: 1   b: 2   c: 3]

;; Only overwrite the value for the word 'b'
resolve/only/all target source [b]

;; `target` is now: context [a: 1 b: 200 c: 3]
```

---

## 4. Nuances and Edge Cases for Novice Programmers

### Critical Nuance #1: Basic `resolve` does almost nothing!

This is the most common pitfall. A novice might expect `resolve target source` to fill in missing values.
It **does not**.  It was designed with a "do no harm" default.

```rebol
;; BEGINNER'S MISTAKE
source: context [x: 100]
target: context [x: unset!] ;; has the word, but no value

resolve target source ; ; This does NOTHING!

print target/x  ;; ==> unset!
```

**Solution:** You almost always want to use `resolve` with `/all`, `/extend`, or both.

### Critical Nuance #2: `unset!` values count as "existing"

The `resolve/extend` refinement will **not** add a value from the source if
the target already has the word, even if that word's value is `unset!`.

```rebol
source: context [config: "Ready"]
target: context [config: unset!]

resolve/extend target source ;; Does nothing, because 'config' exists

print target/config ; ==> unset!
```

**Solution:** To fill `unset!` values, you must use `/all`.

```rebol
resolve/all target source ;; This works!
print target/config ;; ==> "Ready"
```

### Critical Nuance #3: `/only` with an integer index can be destructive

This is a very advanced and potentially dangerous feature. When you use `/only` with an integer index
(e.g., `resolve/only/all target source 3`), it synchronizes the `target` and `source` objects **starting from the 3rd word in each**.

The destructive part is that if the `target` object has more words than the `source` object, those extra words **are removed** (set to `unset!`).

```rebol
source: context [a: 10 b: 20]     ; ; Has 2 words
target: context [a: 1 b: 2 c: 3]   ;; Has 3 words

;; Sync starting from the 1st word
resolve/only/all target source 1

print target/c ;; ==> unset! (The word 'c' was effectively removed).
```

**Guidance:** Avoid using integer indexes with `/only` unless you are an expert user and
know exactly how it works. Using a block of words is always safer and clearer.

---

## 5. Practical Use Cases

### Default Configuration

This is the canonical use case.
Define defaults, then merge in user-provided settings, overwriting the defaults.

```rebol
default-config: context [
    port: 8080
    debug: false
    user: "guest"
]

user-config: context [
    port: 9000
    debug: true
]

;; Apply user settings over the defaults:
resolve/all default-config user-config

print default-config/port ;; ==> 9000
```

### Prototypal Inheritance

Create a base class object and use `resolve/extend` to create instances that inherit its properties without overwriting their own unique values.

```rebol
button-prototype: context [
    width: 100
    height: 25
    on-click: function [] [print "Clicked!"]
]

my-button: context [
    width: 200 ;; My button is wider
    label: "Submit"
]

;; Add any missing properties from the prototype to `my-button`
resolve/extend my-button button-prototype

print my-button/height ;; ==> 25 (Inherited from prototype)
print my-button/width  ;; ==> 200 (My value was NOT overwritten)
```
---

### Using `resolve` without Function Refinements in Detail

The `resolve` function, in its base form without any refinements, performs a single, specific and subtle operation: it re-binds words.
It is not about copying or overwriting values. It is about changing where the words in the target context look for their definitions.
It tells the words in the target to "resolve" themselves by looking inside the source context.
Think of it as a form of dynamic linking or dependency injection at the object level.

#### The Canonical Use Case: Linking Unbound Code
The primary reason this functionality exists is to link a block of code (which contains unbound words), to a context that provides the definitions for those words.
Let's demonstrate with a crystal-clear, practical example that the diagnostic script did not cover.
The Source of Functionality: First, we create a source object that contains a "helper" function.
```
source-context: context [
    helper-func: function [name] [print ["Hello," name]]
]
```

The Unlinked Code: Next, we create a target object. Inside it, we have a block of code (action-block) that uses the word helper-func, but this word is currently unbound within the target's context.
```
target-context: context [
    action-block: [helper-func "World"]
]
```

The "Before" State (Failure): If we try to execute the code in the target right now, it will fail because the word helper-func has no meaning inside target-context.
```
>> do target-context/action-block
** Script error: helper-func has no value
```

The resolve Operation: Now, we use base resolve to create the link. We are telling Rebol: "Look at all the words inside target-context.
If you find any that are unbound, try to find their definition inside source-context."
```
resolve target-context source-context
```

The "After" State (Success): The resolve operation has re-bound the helper-func word inside target-context/action-block.
It now points to the function definition in source-context. Executing the code now succeeds.
```
>> do target-context/action-block
Hello, World
```

Why It Appeared to Do Nothing
In our diagnostic script, we tested cases like this:
```
source: context [a: 100]
target: context [a: 1]
resolve target source
```

In this scenario, resolve still performs the re-binding operation on the word a in the target.
However, when you later access target/a, Rebol's evaluation rule is to find the value that exists directly inside the local context first.
Since target already has its own value for a (the integer 1), it uses that and never needs to follow the newly resolved binding to the source.
This is why, for all practical purposes in modern code, the base resolve function appears to do nothing.
Its original purpose of linking unbound code has largely been superseded by more modern constructs like module!.
