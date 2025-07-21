# Unofficial User's Guide - CLOSURE Functions

## Table of Contents

1. [Overview](#overview)
2. [Basic Usage](#basic-usage)
3. [Key Differences from Functions](#key-differences-from-functions)
4. [The /WITH Refinement - True Persistence](#the-with-refinement---true-persistence)
5. [The /EXTERN Refinement - Global Access](#the-extern-refinement---global-access)
6. [Combined Refinements](#combined-refinements)
7. [Common Pitfalls and Solutions](#common-pitfalls-and-solutions)
8. [Best Practices](#best-practices)
9. [Advanced Examples](#advanced-examples)

## Overview

Closures in Rebol 3 Oldes are specialized functions that provide enhanced variable scoping and optional state persistence.
The `closure` function creates `closure!` values that behave like functions but with important differences in how they handle local variables.

**Key Functions:**

- `closure` - Creates a closure.
- `closure?` - Tests if a value is a closure.

**Important Discovery:** Basic closures (without refinements), do NOT automatically maintain a persistent state between calls.
True persistence requires the `/with` refinement.

## Basic Usage

### Creating Simple Closures

```rebol
;; Basic closure creation
simple-closure: closure [x] [x * 2]
result: simple-closure 5  ;; Returns: 10

;; Closure with documentation
documented-closure: closure ["Multiplies input by 3" value [integer!]] [
    value * 3
]

;; Closure with refinements
math-closure: closure [base /double "Double the result"] [
    result: base + 10
    either double [result * 2] [result]
]
```

### Type Checking

```rebol
closure? :simple-closure     ;; Returns: true
closure? func [x][x]         ;; Returns: false
closure? 42                  ;; Returns: false
```

## Key Differences from Functions

### Variable Scoping Behavior

**Critical Understanding:** Without `/with`, closures behave similarly to functions regarding variable persistence:

```rebol
;; Function with local variable:
func-counter: func [] [
    set/any 'result try [counter + 1]
    counter: either error? result [1] [result]
    counter
]

;; Basic closure with local variable :
closure-counter: closure [] [
    set/any 'result try [counter + 1]
    counter: either error? result [1] [result]
    counter
]

;; Both maintain some persistence:
func-counter     ;; Returns: 1
func-counter     ;; Returns: 2 (functions persist in R3 Oldes)

closure-counter  ;; Returns: 1
closure-counter  ;; Returns: 1 (closures reset without /with)
```

### Automatic Local Variables

All set-words in closure bodies automatically become local variables:

```rebol
global-var: "I'm global"

test-closure: closure [input] [
    local-var1: input * 2      ;; Automatically local
    local-var2: local-var1 + 5 ;; Automatically local
    global-var: "Modified"     ;; Also local! Won't affect global
    local-var2
]

test-closure 10  ;; Returns: 25
print global-var ;; Still prints: "I'm global"
```

## The /WITH Refinement - True Persistence

The `/with` refinement is the key to creating truly persistent closures:

### Using Object Specification Block

```rebol
;; Persistent counter using `/with`:
persistent-counter: closure/with [] [
    counter: counter + 1
    counter
] [counter: 0]  ;; Initial state specification.

persistent-counter  ;; Returns: 1
persistent-counter  ;; Returns: 2
persistent-counter  ;; Returns: 3
```

### Using Existing Objects

```rebol
;; Create a shared state object:
state-obj: make object! [
    total: 0
    count: 0
]

;; Closure that modifies an existing object:
accumulator: closure/with [value] [
    total: total + value
    count: count + 1
    reduce [total count]
] state-obj

accumulator 10  ;; Returns: [10 1]
accumulator 20  ;; Returns: [30 2]
print state-obj/total  ;; Prints: 30
```

### Complex State Management

```rebol
;; Advanced persistent closure:
statistics-closure: closure/with [new-value] [
    ;; Add to running totals:
    sum: sum + new-value
    count: count + 1
    
    ;; Track min/max:
    if new-value < minimum [minimum: new-value]
    if new-value > maximum [maximum: new-value]
    
    ;; Calculate average:
    average: sum / count
    
    ;; Return statistics object:
    make object! [
        sum: sum count: count average: average
        minimum: minimum maximum: maximum
    ]
] [
    sum: 0 count: 0
    minimum: 2147483647  ;; Large initial value.
    maximum: -2147483648 ;; Small initial value.
]

stats1: statistics-closure 10
stats2: statistics-closure 20
stats3: statistics-closure 5
print stats3/average  ;; Prints: 11.666...
```

## The /EXTERN Refinement - Global Access

The `/extern` refinement prevents specified words from becoming local:

```rebol
global-counter: 100

;; Closure that modifies global variable:
global-modifier: closure/extern [increment] [
    global-counter: global-counter + increment  ;; Modifies the global.
    local-temp: increment * 2                   ;; This stays local.
    global-counter
] [global-counter]  ;; Specify which words are external.

global-modifier 10  ;; Returns: 110
global-modifier 5   ;; Returns: 115
print global-counter ;; Prints: 115
```

## Combined Refinements

You can use `/with` and `/extern` together:

```rebol
shared-global: 1000

combined-closure: closure/with/extern [input] [
    ;; Persistent state (from /with):
    internal-counter: internal-counter + 1
    
    ;; Global access (from /extern):
    shared-global: shared-global + input
    
    ;; Local calculation:
    temp-calc: input * internal-counter
    
    reduce [internal-counter shared-global temp-calc]
] [
    internal-counter: 0  ;; `/with` state.
] [
    shared-global        ;; `/extern` specification.
]

combined-closure 25  ;; Returns: [1 1025 25]
combined-closure 75  ;; Returns: [2 1100 150]
```

## Common Pitfalls and Solutions

### Pitfall 1: Expecting Automatic Persistence

**Problem:**

```rebol
;; This WON'T maintain state between calls:
broken-counter: closure [] [
    counter: counter + 1  ;; Resets each time.
    counter
]
```

**Solution:**

```rebol
;; Use `/with` for persistence:
working-counter: closure/with [] [
    counter: counter + 1
    counter
] [counter: 0]
```

### Pitfall 2: Unset Variable Errors

**Problem:**

```rebol
;; This will error on first call:
risky-closure: closure [] [
    counter: counter + 1  ;; 'counter' is unset initially.
]
```

**Solution:**

```rebol
;; Safe initialization pattern:
safe-closure: closure [] [
    set/any 'result try [counter + 1]
    counter: either error? result [1] [result]
    counter
]

;; Or better yet, use `/with`
better-closure: closure/with [] [
    counter: counter + 1
    counter
] [counter: 0]
```

### Pitfall 3: Expecting Global Variable Modification

**Problem:**

```rebol
global-var: 100
modify-closure: closure [] [
    global-var: 200  ;; Creates local variable instead!
]
modify-closure
print global-var  ;; It's still 100.
```

**Solution:**

```rebol
global-var: 100
modify-closure: closure/extern [] [
    global-var: 200  ;; Now modifies the global.
] [global-var]
modify-closure
print global-var  ;; Now 200
```

## Best Practices

### 1. Use `/with` for State Persistence

Always use `/with` when you need variables to persist between calls:

```rebol
;; Good: Explicit persistence
session-manager: closure/with [action data] [
    switch action [
        'store [
            session-data: data
            "Data stored"
        ]
        'retrieve [
            session-data
        ]
        'clear [
            session-data: none
            "Session cleared"
        ]
    ]
] [session-data: none]
```

### 2. Initialize State Properly

Always provide initial values in the `/with` block:

```rebol
;; Good: Complete initialization
calculator: closure/with [operation value] [
    switch operation [
        'add [accumulator: accumulator + value]
        'multiply [accumulator: accumulator * value]
        'reset [accumulator: 0]
        'get [accumulator]
    ]
    accumulator
] [accumulator: 0]  ;; Clear initial state
```

### 3. Use Descriptive Names for Persistent Variables

```rebol
;; Good: Clear variable names
request-tracker: closure/with [url] [
    request-count: request-count + 1
    last-request-time: now
    append request-history url
    
    make object! [
        count: request-count
        last-time: last-request-time
        history: copy request-history
    ]
] [
    request-count: 0
    last-request-time: none
    request-history: []
]
```

### 4. Handle Edge Cases

```rebol
;; Robust closure with error handling:
safe-divider: closure/with [numerator denominator] [
    attempt-count: attempt-count + 1
    
    if zero? denominator [
        error-count: error-count + 1
        return make error! "Division by zero"
    ]
    
    result: numerator / denominator
    success-count: success-count + 1
    last-result: result
    result
] [
    attempt-count: 0
    success-count: 0
    error-count: 0
    last-result: none
]
```

## Advanced Examples

### Event System with Closures

```rebol
;; Event dispatcher using closures:
create-event-dispatcher: func [] [
    closure/with [event-type handler] [
        switch event-type [
            'register [
                if not find event-handlers handler [
                    append event-handlers handler
                ]
                length? event-handlers
            ]
            'unregister [
                remove find event-handlers handler
                length? event-handlers
            ]
            'trigger [
                foreach h event-handlers [
                    if function? :h [h handler]  ;; handler contains event data
                ]
                length? event-handlers
            ]
            'list [
                copy event-handlers
            ]
        ]
    ] [event-handlers: []]
]

;; Usage:
dispatcher: create-event-dispatcher
dispatcher 'register func [data] [print ["Handler 1:" data]]
dispatcher 'register func [data] [print ["Handler 2:" data]]
dispatcher 'trigger "Test event"
```

### Memoization with Closures

```rebol
;; Memoized function using closures:
create-memoized: func [computation-func] [
    closure/with [input] [
        ;; Check the cache first:
        if cached-result: select cache input [
            cache-hits: cache-hits + 1
            return cached-result
        ]
        
        ;; Compute and cache result:
        result: computation-func input
        cache-misses: cache-misses + 1
        repend cache [input result]
        result
    ] [
        cache: []
        cache-hits: 0
        cache-misses: 0
    ]
]

;; Usage
fibonacci: create-memoized func [n] [
    either n <= 1 [n] [
        (fibonacci n - 1) + (fibonacci n - 2)
    ]
]
```

### State Machine with Closures

```rebol
;; Simple state machine
create-state-machine: func [initial-state transitions] [
    closure/with [input] [
        if transition: select/skip transitions reduce [current-state input] 3 [
            previous-state: current-state
            current-state: transition/3
            transition-count: transition-count + 1
            return make object! [
                from: previous-state
                to: current-state
                input: input
                valid: true
            ]
        ]
        
        ;; Invalid transition
        make object! [
            from: current-state
            to: current-state
            input: input
            valid: false
        ]
    ] compose [
        current-state: (initial-state)
        previous-state: none
        transition-count: 0
    ]
]

;; Usage
door-machine: create-state-machine 'closed [
    closed 'open opened
    opened 'close closed
    opened 'lock locked
    locked 'unlock opened
]

result1: door-machine 'open   ;; valid transition
result2: door-machine 'lock   ;; valid transition  
result3: door-machine 'open   ;; invalid transition
```

This guide provides robust coverage of Rebol 3 Oldes closure functionality based on empirical testing.
The key insight is that closures require the `/with` refinement for true state persistence,
making them powerful tools for creating stateful, encapsulated functionality.
