REBOL [
    Title: "Corrected Diagnostic Probe for the 'apply' function"
    Date: 20-Jul-2025
    File: %diag-apply-revised.r
    Author: "Expert Rebol3 Oldes Engineer"
    Purpose: {
        A revised and corrected script to probe 'apply' behavior based on
        initial test failures. This version reflects a more accurate
        understanding of its non-obvious functionality.
    }
]

;-----------------------------------------------------------------------------
; A Battle-Tested QA Harness
;-----------------------------------------------------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    either equal? expected actual [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {Output the final summary of the entire test run.}
    print "^/============================================"
    print "=== TEST SUMMARY ==="
    print "============================================"
    print rejoin ["Total Tests: " test-count]
    print rejoin ["Passed: " pass-count]
    print rejoin ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - FUNCTION IS STABLE"
    ][
        print "❌  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]
;-----------------------------------------------------------------------------
; Test Fixtures - Functions and Data for Probing
;-----------------------------------------------------------------------------

; A simple function for testing basic application.
add-two: func [a [integer!] b [integer!]] [a + b]

; A function that accepts any value, useful for testing /only.
identity: func [value] [:value]

; A function with no arguments.
return-pi: does [3.14]

; A function that returns unset!
return-unset: func [] [()]

; A simple operator for testing op! application
plus: :+

;-----------------------------------------------------------------------------
; SECTION 1: Probing Basic Behavior (Default / No Refinements)
;-----------------------------------------------------------------------------
print "^/--- SECTION 1: Probing Basic Behavior ---"

;-- Hypothesis: `apply` will evaluate a block of arguments and apply them
;-- to the specified function.
test-block-one: [10 20]
assert-equal 30 (apply :add-two test-block-one) "Basic apply with a native function and integer arguments."

;-- Hypothesis: The argument block is reduced before being passed to the
;-- function. Expressions within the block will be evaluated.
test-block-two: [5 * 2 10 + 10]
assert-equal 30 (apply :add-two test-block-two) "Argument block is reduced before application."

;-- Hypothesis: `apply` works correctly with native operators (op!).
test-block-three: [100 50]
assert-equal 150 (apply :+ test-block-three) "Apply works with a native op!."
assert-equal 150 (apply :plus test-block-three) "Apply works with an op! stored in a word."

;-- Hypothesis: `apply` works correctly with a function that takes no arguments,
;-- provided the argument block is empty.
assert-equal 3.14 (apply :return-pi []) "Apply with a function that takes zero arguments."

;-- Hypothesis: `apply` correctly handles functions that return `unset!`.
assert-equal true (unset? apply :return-unset []) "Apply correctly handles a return value of unset!."


;-----------------------------------------------------------------------------
; SECTION 2: Probing the `/only` Refinement
;-----------------------------------------------------------------------------
print "^/--- SECTION 2: Probing /only Refinement ---"

;-- REVISED Hypothesis: The `/only` refinement prevents reduction of the
;-- argument block's *elements*, passing them as literal arguments. It does NOT
;-- pass the entire block as a single argument.
test-block-four: [1 + 2]
; Without /only, this block reduces to a single integer value, 3.
assert-equal 3 (apply :identity test-block-four) "Default apply reduces the argument block."

;-- REVISED Hypothesis: To pass a literal block using /only, it must be
;-- an element within the argument block.
assert-equal [1 + 2] (apply/only :identity [ [1 + 2] ]) "/only passes a literal block if it's an element of the argument block."

;-- REVISED Hypothesis: The reduction of a word variable results in its value,
;-- which itself may be another word. `apply` does not perform a second evaluation.
word-to-pass: 'hello
value-of-word: "world"
set word-to-pass value-of-word ;-- `hello` is now a variable for "world"
test-block-five: [word-to-pass] ;-- This block will be reduced to `[hello]`
assert-equal 'hello (apply :identity test-block-five) "Default apply reduces a word to its value (which can be another word)."

;-- Hypothesis: With `/only`, words are passed as literal words, not their values.
assert-equal 'word-to-pass (apply/only :identity test-block-five) "/only passes literal words without reduction."


;-----------------------------------------------------------------------------
; SECTION 3: Probing Arity and Argument Errors
;-----------------------------------------------------------------------------
print "^/--- SECTION 3: Probing Arity and Argument Errors ---"

;-- Hypothesis: `apply` will raise an error if the number of provided
;-- arguments (after reduction) is less than the function's arity.
error-obj-less: try [apply :add-two [1]]
assert-equal true (error? error-obj-less) "Error: Too few arguments."

;-- REVISED Hypothesis: `apply` does NOT raise an error if too many arguments
;-- are provided. It simply consumes the number of arguments required by the
;-- function's spec and ignores any extras.
assert-equal 30 (apply :add-two [10 20 999 1000]) "REVISED: Extra arguments are ignored and do not cause an error."

;-- Hypothesis: `apply` will raise an error if a function requiring arguments
;-- is given an empty block.
error-obj-empty: try [apply :add-two []]
assert-equal true (error? error-obj-empty) "Error: Empty block for function requiring arguments."

;-- Hypothesis: A type error will be raised if the reduced arguments do not
;-- match the types specified in the function spec.
error-obj-type: try [apply :add-two ["a" "b"]]
assert-equal true (error? error-obj-type) "Error: Argument of the wrong type."

;-- Hypothesis: /only can still cause an error if the literal argument's
;-- type does not match the function's spec.
error-obj-only-type: try [apply/only :add-two [['a] ['b]]]
assert-equal true (error? error-obj-only-type) "Error: /only argument of the wrong type."


;-----------------------------------------------------------------------------
; Final Summary
;-----------------------------------------------------------------------------
print-test-summary
