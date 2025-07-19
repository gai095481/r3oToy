# Unofficial Guide to the `task` Function

## Overview

The `task` function in Rebol 3 (Oldes Branch), creates `task!` datatype objects from specification and body blocks.
The  `task` function creates standardized object containers rather than executable functions despite its name suggesting executable functionality.

## Function Signature

>  task *SPEC BODY*

### Parameters

* `spec` [block!] - Name or specification block (copied deeply)
* `body` [block!] - The body block of the task (copied deeply)

### Returns

* `task!` datatype object

## Basic Usage Examples

### Simple Task Creation

```rebol
;; Create a basic empty task
empty-task: task [] []
print type? empty-task  ;; task!

;; Create task with parameters
param-task: task [name value] [print [name "=" value]]
print task? param-task  ;; true
```

### Complex Specifications

```rebol
;; Task with typed parameters and local variables
complex-task: task [
    config [block!] "Configuration block"
    data [[string! integer!]] "Structured data"
    /local temp result
] [
    temp: first config
    result: length? data
    print [temp result]
]
```

## Critical Understanding: Task Behavior Nuances

### 1. **All Tasks Are Equal** ⚠️

​**IMPORTANT**​: All `task!` objects are equal to each other regardless of their input specification or body.

```rebol
task-a: task [x] [print x]
task-b: task [y] [probe y]
task-c: task [] []

print equal? task-a task-b  ;; true (surprising!)
print equal? task-a task-c  ;; true (surprising!)
print equal? task-b task-c  ;; true (surprising!)
```

​**Why This Happens**​: All tasks have identical internal structure with the same fields (`title`, `header`, `parent`, `path`, `args`) all set to `none`.

### 2. **Reference vs Content Identity**

While tasks are content-equal, they maintain separate object references:

```rebol
task-1: task [value] [return value]
task-2: task [value] [return value]
task-3: task-1

print same? task-1 task-2  ;; false (different objects)
print same? task-1 task-3  ;; true (same reference)
print equal? task-1 task-2 ;; true (identical content)
```

### 3. **Deep Copy Protection**

Tasks use `copy/deep` internally, so original blocks remain unaffected:

```rebol
original-spec: [param1 param2]
original-body: [print param1]

my-task: task original-spec original-body

;; Modify originals - task is unaffected
append original-spec 'param3
append original-body [print "modified"]

;; my-task remains unchanged
```

## Internal Structure Inspection

Tasks have a standardized internal structure:

```rebol
sample-task: task [x] [print x]
probe sample-task
;; Output:
;; make task! [
;;     title: #(none)
;;     header: #(none)
;;     parent: #(none)
;;     path: #(none)
;;     args: #(none)
;; ]
```

​**Caution**​: The original spec and body blocks are not directly accessible after task creation.

## Type Checking with `task?`

The `task?` function reliably identifies task objects:

```rebol
my-task: task [x] [print x]
regular-object: make object! [name: "test"]
my-function: function [x] [print x]

print task? my-task        ;; true
print task? regular-object ;; false
print task? my-function    ;; false
print task? "string"       ;; false
print task? []             ;; false
print task? none           ;; false
```

## Error Handling and Validation

### Input Validation

The `task` function strictly validates its arguments:

```rebol
;; ✅ Valid usage
valid-task: task [] []
valid-task: task [param] [print param]

;; ❌ Invalid usage - will cause errors
; task "invalid" []        ; Error: spec must be block!
; task [] "invalid"        ; Error: body must be block!
; task none []             ; Error: spec cannot be none!
; task [] none             ; Error: body cannot be none!
```

### Safe Task Creation Pattern

```rebol
create-safe-task: function [
    spec [block!]
    body [block!]
] {
    Creates a task with validation and error handling.
    Returns task! on success, none on failure.
} [
    set/any 'result try [
        task spec body
    ]
    either error? result [
        print ["Task creation failed:" result/id]
        none
    ] [
        result
    ]
]

;; Usage
safe-task: create-safe-task [x] [print x]
if task? safe-task [
    print "Task created successfully"
]
```

## Best Practices for Novice Programmers

### 1. **Don't Rely on Task Equality for Logic**

```rebol
;; ❌ Avoid this pattern:
if equal? my-task other-task [
    print "Same task logic"  ;; This will always be true!
]

;; ✅ Use reference comparison or custom identification
if same? my-task other-task [
    print "Same task reference"  ;; This works correctly
]
```

### 2. **Use Descriptive Variable Names**

```rebol
;; ✅ Good - clear purpose
data-processor-task: task [data] [process-data data]
validation-task: task [input] [validate input]

;; ❌ Avoid - unclear purpose
task1: task [x] [do-something x]
temp-task: task [] []
```

### 3. **Validate Inputs Before Task Creation**

```rebol
create-validated-task: function [
    spec [block!] 
    body [block!]
] {
    Creates task with comprehensive validation
} [
    ;; Validate spec is proper block
    if empty? spec [
        print "Warning: Empty spec block"
    ]
    
    ;; Validate body is proper block  
    if empty? body [
        print "Warning: Empty body block"
    ]
    
    task spec body
]
```

### 4. **Handle Large Block Scenarios**

Tasks can handle large specifications and bodies:

```rebol
;; Safe for large data structures
large-spec: []
large-body: []

repeat counter 100 [
    append large-spec to-word rejoin ["param" counter]
    append large-body reduce ['print to-word rejoin ["param" counter]]
]

large-task: task large-spec large-body  ;; This works fine.
```

## Common Pitfalls and Solutions

### Pitfall 1: Expecting Different Tasks to Be Unequal

```rebol
;; ❌ This assumption is wrong
task-a: task [x] [print x]
task-b: task [y] [print y]
if not equal? task-a task-b [
    print "Different tasks"  ;; This never executes.
]

;; ✅ Use reference comparison or maintain separate tracking:
task-registry: make map! []
task-registry/task-a: "printer-x"
task-registry/task-b: "printer-y"
```

### Pitfall 2: Trying to Access Original Spec/Body

```rebol
;; ❌ These don't work - no direct access
; spec-data: my-task/spec      ;; Error
; body-data: my-task/body      ;; Error
; first-param: first my-task   ;; Error

;; ✅ Maintain separate documentation if needed
task-info: [
    spec: [param1 param2]
    body: [print param1 param2]
    task-obj: none
]
task-info/task-obj: task task-info/spec task-info/body
```

### Pitfall 3: Assuming Tasks Are Executable

Tasks are **data containers**, not executable functions:

```rebol
my-task: task [x] [print x]

;; ❌ Tasks cannot be called directly:
; my-task "hello"  ;; This won't work.

;; ✅ If you need executable behavior, use `function`
my-function: function [x] [print x]
my-function "hello"  ;; This works
```

## Summary

The `task` function creates standardized `task!` datatype objects that:

* Accept block specifications and bodies with deep copy protection.
* All evaluate as equal regardless of content.
* Maintain separate object references.
* Provide reliable type checking with `task?`.
* Validate input arguments strictly.
* Handle complex and large block structures safely.

Understanding these characteristics is essential for effective use of tasks in Rebol 3 applications.
