REBOL [
    Title: "Rebol 3 Oldes function/with Refinement Demonstration"
    Version: 0.7.1
    Author: "AI Assistant"
    Date: 03-Jun-2025
    Purpose: {
        A script to comprehensively demonstrate the practical and typical
        uses of the `function/with` refinement. It serves as a reliable
        educational and testing resource for developers, clarifying how to
        create stateful functions and object-like behaviors in Rebol 3.
    }
    Notes: {
        Targeting REBOL/Bulk 3.19.0 (Oldes branch).
        - When using `function/with`, docstrings must be inline strings.
        - `function/with` given an `object!` provides an empty `self`.
        - `function/with` given a `block!` spec creates a stateful `self`.
        - CORRECTING repeated syntax error (extraneous empty `[]` block)
          in both Demo 1 and Demo 2 function definitions.
    }
    Keywords: [rebol rebol3 function with refinement stateful closure object method]
]

;; --- Demonstration 1: Function with /with, modifying global object directly ---
print "^/-- Demo 1: Function with /with, Modifying Global Object --^/"
my-external-object: make object! [name: "Global Demo Object" counter: 0]

increment-global-counter: function/with [
    "Increments the global counter."
][
    my-external-object/counter: my-external-object/counter + 1
] my-external-object

print "Action: Call increment-global-counter three times and verify operation."
loop 3 [increment-global-counter]
print ["Result: " either (my-external-object/counter = 3) ["✅ PASSED"] ["❌ FAILED"]]
print newline

;; --- Demonstration 2: Stateful Closure using a Block Spec for /with ---
print "^/-- Demo 2: Stateful Closure from Block Spec --^/"

make-counter: function [
    "Make a new counter function with its own private state."
    start-value [integer!] "The initial value for the counter."
][
    function/with [
        "Increments its own private counter. Returns the new value."
    ][
        self/count: self/count + 1
    ] [ ;; This is the SPEC block for the 'self' object, passed to `/with`:
        count: start-value
    ]
]

print "Action: Create two independent counters and call them."
counter-A: make-counter 100
counter-B: make-counter 500

val-A2: none
loop 2 [val-A2: counter-A]

val-B3: none
loop 3 [val-B3: counter-B]

expected-A: 102
expected-B: 503
passed-A: (val-A2 = expected-A)
passed-B: (val-B3 = expected-B)
passed-overall-demo2: all [passed-A passed-B]
print ["Result: " either passed-overall-demo2 ["✅ PASSED"] ["❌ FAILED"]]
print newline

;; --- Demonstration 3: Multiple Functions Sharing State via Global Object ---
print "^/-- Demo 3: Multiple Functions Sharing One Global State --^/"

shared-state-object: make object! [value: 10 log: copy []]
print "Initial State:"
print ["    shared-state-object/value: " mold shared-state-object/value]
print newline

add-to-state: function/with [
    "Adds a number to the shared state's 'value'."
    amount [integer!]
][
    shared-state-object/value: shared-state-object/value + amount
    append shared-state-object/log reform ["Added" amount]
] shared-state-object

multiply-state: function/with [
    "Multiplies the shared state's 'value'."
    factor [integer!]
][
    shared-state-object/value: shared-state-object/value * factor
    append shared-state-object/log reform ["Multiplied by" factor]
] shared-state-object

print "Action: Call functions to manipulate the shared state."
add-to-state 5
multiply-state 3
add-to-state -20
print newline

expected-value: 25
expected-log: ["Added 5" "Multiplied by 3" "Added -20"]
passed-value: (shared-state-object/value = expected-value)
passed-log: (shared-state-object/log = expected-log)
passed-overall-demo3: all [passed-value passed-log]

print "Verification:"
print ["    Expected final value: " mold expected-value]
print ["    Actual final value:   " mold shared-state-object/value]
print ["Result: " either passed-overall-demo3 ["✅ PASSED"] ["❌ FAILED"]]

print "^/=== Script completed ==="
