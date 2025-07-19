# Unofficial `task` Function User's Guide

## Overview

The `task` function creates the `task!` datatype objects to serve as a standardized object container. Despite the name suggesting executable functionality, tasks are **data containers**, not executable functions.

## Function Signature

> task *spec body*


### Parameters

* `spec` [block!] - Specification block (copied deeply during creation)
* `body` [block!] - Body block (copied deeply during creation)

### Returns

* `task!` datatype object

## Critical Behavioral Characteristics

### 🚨 All Tasks Are Equal (Major Gotcha!)

**Most Important:** ALL task objects are equal to each other, regardless of their spec or body content.

```rebol
task-a: task [x] [print x]
task-b: task [y] [return y * 2] 
task-c: task [] []

print equal? task-a task-b  ;; true (surprising!)
print equal? task-a task-c  ;; true (surprising!)
print strict-equal? task-a task-b  ;; true (surprising!)
```

**Why This Happens:** All tasks have identical internal structure with all fields set to `none`.

### 🔒 Tasks Cannot Be Copied

Tasks do not support any copy operations:

```rebol
my-task: task [data] [process data]

;; All of these FAIL:
;; copied-task: copy my-task           ;; Error!
;; deep-task: copy/deep my-task        ;; Error!  
;; part-task: copy/part my-task 1      ;; Error!
```

### 🔍 Limited Introspection

Tasks don't support standard object reflection despite being object-like:

```rebol
my-task: task [x] [print x]

;; These FAIL:
;; task-words: words-of my-task        ;; Error!
;; task-values: values-of my-task      ;; Error!
;; spec-data: my-task/spec             ;; Error!
;; body-data: my-task/body             ;; Error!
```

### ✅ What DOES Work

```rebol
my-task: task [x] [print x]

;; Type checking works reliably
print task? my-task                    ;; true
print type? my-task                    ;; task!
print any-object? my-task              ;; true
print object? my-task                  ;; false

;; Conversion to string/block works
print mold my-task                     ;; Shows internal structure
task-as-block: to block! my-task      ;; Works
```

## Internal Structure

Every task has this standardized internal structure:

```rebol
make task! [
    title: #(none)
    header: #(none)
    parent: #(none)
    path: #(none)
    args: #(none)
]
```

## Safe Task Creation Patterns

### Basic Usage

```rebol
;; Simple task creation
empty-task: task [] []
param-task: task [name age] [print [name "is" age "years old"]]

;; Complex specifications work fine
complex-task: task [
    config [block!] "Configuration data"
    data [string! integer!] "Input data"
    /local temp result
] [
    temp: first config
    result: length? data
    reduce [temp result]
]
```

### Input Validation Pattern

```rebol
create-safe-task: function [
    spec [block!] "Task specification"
    body [block!] "Task body"
] [
    if any [
        not block? spec
        not block? body
    ] [
        throw make error! "Both spec and body must be blocks"
    ]
    
    task spec body
]

;; Usage
safe-task: create-safe-task [x] [print x]
```

## Common Pitfalls & Solutions

### ❌ Pitfall 1: Using Task Equality for Logic

```rebol
;; WRONG - This will always be true!
if equal? task-a task-b [
    print "Tasks are the same"  ;; Always executes!
]
```

```rebol
;; CORRECT - Use reference comparison
if same? task-a task-b [
    print "Same task reference"  ;; Only true if actually same object
]

;; BETTER - Maintain separate tracking
task-registry: make map! []
task-registry/processor: task [data] [process data]
task-registry/validator: task [input] [validate input]
```

### ❌ Pitfall 2: Expecting to Access Original Spec/Body

```rebol
;; WRONG - These don't work
;; original-spec: my-task/spec      ;; Error!
;; original-body: my-task/body      ;; Error!
```

```rebol
;; CORRECT - Maintain separate documentation
task-info: make object! [
    name: "data-processor"
    spec: [data [block!]]
    body: [foreach item data [print item]]
    task-object: none
]
task-info/task-object: task task-info/spec task-info/body
```

### ❌ Pitfall 3: Trying to Execute Tasks

```rebol
my-task: task [x] [print x]

;; WRONG - Tasks are not executable
;; my-task "hello"  ;; This won't work!
```

```rebol
;; CORRECT - Use functions for executable behavior
my-function: function [x] [print x]
my-function "hello"  ;; This works

;; Or store tasks as templates/documentation
task-template: task [x] [print x]
;; Use the task as a reference, create function separately
my-executor: function [x] [print x]
```

## Best Practices for Novice Programmers

### 1. Don't Rely on Task Equality

Never use `equal?` between different tasks for business logic - it's always true!

### 2. Use Descriptive Variable Names

```rebol
;; Good
user-data-processor: task [user-info] [validate-and-store user-info]
config-validator: task [config] [check-config-format config]

;; Bad
task1: task [x] [do-something x]
temp: task [] []
```

### 3. Maintain External Task Documentation

```rebol
task-catalog: [
    "processor" [
        spec: [data [block!]]
        body: [process-data data]
        purpose: "Processes incoming data blocks"
    ]
    "validator" [
        spec: [input [string!]]
        body: [validate-input input]  
        purpose: "Validates string inputs"
    ]
]

;; Create tasks and link to documentation
foreach [name info] task-catalog [
    task-catalog/:name/instance: task info/spec info/body
]
```

### 4. Use Tasks as Templates, Functions for Execution

```rebol
;; Define task as a template/specification
calculation-template: task [a b operation] [
    switch operation [
        "add" [a + b]
        "multiply" [a * b]
        "subtract" [a - b]
    ]
]

;; Create actual executable function based on template
calculate: function [a b operation] [
    switch operation [
        "add" [a + b]
        "multiply" [a * b]  
        "subtract" [a - b]
    ]
]

;; Use the function, reference the task for documentation
result: calculate 5 3 "add"  ;; Works
;; calculation-template documents the expected interface
```

## Error Handling

Tasks strictly validate their inputs:

```rebol
;; These cause errors:
;; task "invalid" []        ;; spec must be block!
;; task [] "invalid"        ;; body must be block!
;; task none []             ;; spec cannot be none
;; task [] none             ;; body cannot be none
;; task [x] [print x] []    ;; too many arguments
```

---

## Reasons to Use `task!` Instead of `object!`

### Deep Copy Protection Required

```rebol
;; task! automatically deep copies input blocks
original-spec: [param1 param2]
my-task: task original-spec [do-something]
clear original-spec  ;; task is unaffected
```

### Standardized Container Structure

- All tasks have identical structure [title header parent path args]

- Useful when you need predictable, uniform containers

### Type-Safe Identification

```rebol
;; task? provides reliable type checking
if task? my-container [
    ;; Guaranteed to be a task, not just any object
]
```

### Input Validation Requirements

- The `task` function strictly validates `block!` inputs.
- Prevents creation with invalid datatypes.

### Immutable Container Needs

- Tasks cannot be copied or modified.

- Useful when you need guaranteed immutability.

### Template/Specification Storage

```rebol
;; Store function specifications without executable behavior:
api-template: task [endpoint [url!] data [block!]] [send-request endpoint data]
```

### All-Equal Semantics Required

- When you need containers that compare as equal regardless of content

- Useful for certain algorithmic patterns where content doesn't matter for equality

### Documentation Containers

```rebol
;; Store code patterns, examples, or documentation
code-example: task [data] [
    ;; This shows the expected pattern
    validate data
    process data
    return result
]
```

### Namespace Separation

- `task!` is a distinct datatype from `object!`
- Useful when you need clear type distinction in your data model.

  ### Block-Based Configuration Storage

```rebol
;; When you specifically need to store block-based specifications
;; and want the deep-copy protection task provides
config-template: task [database [url!] timeout [integer!]] [
    connect database
    set-timeout timeout
]
```

## **Reality Check** ⚠️

​However, the behavioral diagnostics revealed that `object!` is usually a better choice because:

* Objects have accessible fields (`obj/field`)
* Objects can be copied when needed
* Objects support reflection (`words-of`, `values-of`)
* Objects can have custom equality logic
* Objects are more flexible and feature-rich

**The main use case for `task!`** appears to be as **immutable specification containers** with deep-copy protection, not as general-purpose objects.

---

## Summary

Tasks in Rebol 3 Oldes are:

* **Object containers** that store specifications and bodies
* **All equal** to each other regardless of content
* **Non-copyable** and have limited introspection
* **Not executable** - use functions for executable behavior
* **Useful as templates** or documentation containers

Understanding these limitations is crucial for effective use in real applications.
