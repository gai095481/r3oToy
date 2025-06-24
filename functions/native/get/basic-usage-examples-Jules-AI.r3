REBOL [
    Title: "GET Function - Happy Path Examples"
    Date: 2025-06-24
    Author: "Jules (AI Agent)"
    Purpose: {
        Demonstrates common, simple, and correct uses of the GET function.
        This script is intended for Rebol developers looking to understand
        the basic operations of GET through clear, runnable examples.
        Each example is verified using the assert-equal test harness.
    }
    File: %get_happy_path_examples.r3
    Version: 1.0.1
]

print "=== GET Function - Happy Path Examples (v1.0.1) ==="
print ["Script Version:" system/script/header/version]
print "=== Using Battle-Tested QA Harness ==="
print newline

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    either equal? expected actual [
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

assert-error: function [
    {Confirm that a block of code correctly throws an error.}
    code-to-run [block!] "The code block expected to error."
    description [string!] "A description of the specific QA test being run."
][
    result: try code-to-run
    either error? result [
        print ["✅ PASSED:" description]
    ][
        set 'all-tests-passed? false
        print ["❌ FAILED:" description "^/   >> Expected an error, but none occurred."]
    ]
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL `get` HAPPY PATH EXAMPLES PASSED"
    ][
        print "❌ SOME `get` HAPPY PATH EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; Happy Path Examples Start Here
;;=============================================================================
print newline

;;-----------------------------------------------------------------------------
;; EXAMPLE 1: Get Value of a Simple Word
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 1: Get Value of a Simple Word ---"
my-variable: "Hello Rebol!"
retrieved-value-1: get 'my-variable
assert-equal "Hello Rebol!" retrieved-value-1 "HP1: Get value of a simple word holding a string"
print ["Value of 'my-variable is:" mold retrieved-value-1]
print newline

;;-----------------------------------------------------------------------------
;; EXAMPLE 2: Get Value of a Word Containing a Block
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 2: Get Value of a Word Containing a Block ---"
my-block-var: [10 20 "alpha" true]
retrieved-block-2: get 'my-block-var
assert-equal [10 20 "alpha" true] retrieved-block-2 "HP2: Get value of a word holding a block"
print ["Value of 'my-block-var is:" mold retrieved-block-2]
print newline

;;-----------------------------------------------------------------------------
;; EXAMPLE 3: Get Value from an Object Path
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 3: Get Value from an Object Path ---"
my-object-hp3: make object! [
    name: "Test Object"
    version: 1.2
    data: make object! [
        count: 50
    ]
]
retrieved-name-hp3: get 'my-object-hp3/name
assert-equal "Test Object" retrieved-name-hp3 "HP3: Get 'name' from object path"
print ["Value of 'my-object-hp3/name is:" mold retrieved-name-hp3]

retrieved-count-hp3: get 'my-object-hp3/data/count
assert-equal 50 retrieved-count-hp3 "HP3: Get 'count' from nested object path"
print ["Value of 'my-object-hp3/data/count is:" mold retrieved-count-hp3]
print newline

;;-----------------------------------------------------------------------------
;; EXAMPLE 4: Get Value from a Block Path (Index)
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 4: Get Value from a Block Path (Index) ---"
data-list-hp4: ["red" "green" "blue" "yellow"]
second-color-hp4: get 'data-list-hp4/2
assert-equal "green" second-color-hp4 "HP4: Get 2nd element from block path"
print ["Value of 'data-list-hp4/2 is:" mold second-color-hp4]

fourth-color-hp4: get 'data-list-hp4/4
assert-equal "yellow" fourth-color-hp4 "HP4: Get 4th element from block path"
print ["Value of 'data-list-hp4/4 is:" mold fourth-color-hp4]
print newline

;;-----------------------------------------------------------------------------
;; EXAMPLE 5: Using `get/any` with a Set Word
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 5: Using `get/any` with a Set Word ---"
active-setting-hp5: true
setting-val-hp5: get/any 'active-setting-hp5
assert-equal true setting-val-hp5 "HP5: Get/any with a set word (true)"
print ["Value of 'active-setting-hp5 using get/any is:" mold setting-val-hp5]

count-hp5: 0
count-val-hp5: get/any 'count-hp5
assert-equal 0 count-val-hp5 "HP5: Get/any with a set word (0)"
print ["Value of 'count-hp5 using get/any is:" mold count-val-hp5]
print newline

;;-----------------------------------------------------------------------------
;; EXAMPLE 6: Using `get/any` with an Unset Word
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 6: Using `get/any` with an Unset Word ---"
; `get/any` does not error if the word is unset.
; The expression `get/any 'unset-word` results in an unset value.
; We can test this using `unset?`.

unset 'maybe-nonexistent-hp6-b ; Use a fresh word

hp6-did-not-error: false
try [
    get/any 'maybe-nonexistent-hp6-b  ; Just evaluate it
    hp6-did-not-error: true
]
assert-equal true hp6-did-not-error "HP6: Expression (get/any 'unset-word) itself does not error"

assert-equal true unset? get/any 'maybe-nonexistent-hp6-b "HP6: unset? (get/any 'unset-word) is true"
print ["Result of unset? get/any 'maybe-nonexistent-hp6-b:" unset? get/any 'maybe-nonexistent-hp6-b]
print newline

;;-----------------------------------------------------------------------------
;; END OF BASIC EXAMPLES
;;-----------------------------------------------------------------------------
print-test-summary
