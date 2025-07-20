Rebol [
    Title: "Diagnostic Probe for APPLY Function"
    Description: {
        Final test script for APPLY function in REBOL/Bulk 3.19.0.
        Updated to reflect observed behaviors from test runs.
    }
]

;;----------------------------------------
;; QA Test Harness
;;----------------------------------------
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

;;----------------------------------------
;; Helper Functions for Test Scenarios
;;----------------------------------------
adder: function [
    "Add two numbers"
    a [number!]
    b [number!]
][
    a + b
]

identity: function [
    "Return the argument unchanged"
    value [any-type!]
][
    value
]

thunk: function [
    "Function taking no arguments"
][
    42
]

return-error-object: function [
    "Return an error object (not thrown)"
][
    make error! "Returned error object"
]

throw-error: function [
    "Function that throws an error"
][
    cause-error 'math 'zero-divide []
]

;; Test block containing expressions
expression-block: [(1 + 1) (2 * 2)]

;;----------------------------------------
;; Group 1: Basic Application (without /only)
;;----------------------------------------
print "=== GROUP 1: Basic Application (without /only) ==="

;; Hypothesis: APPLY reduces block arguments before function application
assert-equal 3 apply :adder [1 2] "1.1: Apply adder to reduced [1 2] -> 3"

;; Hypothesis: Reduction evaluates expressions in argument block
assert-equal 6 apply :adder expression-block "1.2: Apply to expression block (reduced to [2 4] -> 2+4=6)"

;; Hypothesis: Works with different data types after reduction
assert-equal "test" apply :identity ["test"] "1.3: Apply identity to string"

;; Hypothesis: Functions with no arguments work with empty block
assert-equal 42 apply :thunk [] "1.4: Apply thunk (no args) with empty block"

;; Hypothesis: Block reduction resolves words to their values
word-val: 10
assert-equal 20 apply :adder [word-val 10] "1.5: Words in block are reduced to values"

;;----------------------------------------
;; Group 2: /ONLY Refinement
;;----------------------------------------
print "=== GROUP 2: /ONLY Refinement ==="

;; Hypothesis: /ONLY passes arguments without reduction
assert-equal 3 apply/only :adder [1 2] "2.1: /ONLY with self-evaluating values"

;; Hypothesis: /ONLY passes expressions unevaluated (causes type errors)
adder-result: try [apply/only :adder expression-block]
assert-equal true error? adder-result "2.2: /ONLY with expressions causes error"

;; Hypothesis: /ONLY passes words literally (without evaluation)
block-arg: [a b c]
assert-equal 'block-arg apply/only :identity [block-arg] "2.3a: /ONLY passes word literally"

;; Hypothesis: /ONLY preserves literal blocks
assert-equal [a b c] apply/only :identity [ [a b c] ] "2.3b: /ONLY preserves literal block"

;; Hypothesis: /ONLY works with functions taking no arguments
assert-equal 42 apply/only :thunk [] "2.4: /ONLY with thunk (no args)"

;;----------------------------------------
;; Group 3: Argument Handling Edge Cases
;;----------------------------------------
print "=== GROUP 3: Argument Handling Edge Cases ==="

;; Observation: Argument count mismatch doesn't throw errors in this implementation
;; Hypothesis: No-arg function ignores extra arguments
assert-equal 42 apply :thunk [1] "3.1: No-arg function ignores extra arguments"

;; Hypothesis: Functions use only declared arguments (extra ignored)
assert-equal 1 apply :identity [1 2] "3.2: Single-arg function ignores extra arguments"

;; Hypothesis: Empty block works for no-arg functions
assert-equal 42 apply :thunk [] "3.3: Empty block for no-arg function"

;;----------------------------------------
;; Group 4: Input Validation
;;----------------------------------------
print "=== GROUP 4: Input Validation ==="

;; Hypothesis: Non-function first argument causes error
non-func-result: try [apply "not a function" [1]]
assert-equal true error? non-func-result "4.1: Non-function first argument"

;; Hypothesis: Non-block second argument causes error
non-block-result: try [apply :adder 123]
assert-equal true error? non-block-result "4.2: Non-block second argument"

;; Hypothesis: Invalid function spec causes error
invalid-func: function [] [does-not-exist]
invalid-result: try [apply :invalid-func []]
assert-equal true error? invalid-result "4.3: Function with invalid body"

;;----------------------------------------
;; Group 5: Function Execution Behavior
;;----------------------------------------
print "=== GROUP 5: Function Execution Behavior ==="

;; Hypothesis: Functions returning error objects don't throw
error-obj: apply :return-error-object []
assert-equal true error? error-obj "5.1: Function returning error object"

;; Hypothesis: Functions throwing errors propagate correctly
error-thrown: try [apply :throw-error []]
assert-equal true error? error-thrown "5.2: Function that throws error"

;;----------------------------------------
;; Group 6: Special Data Types
;;----------------------------------------
print "=== GROUP 6: Special Data Types ==="

;; Hypothesis: Handles nested blocks appropriately
nested-block: [ [1 + 1] ]
assert-equal [1 + 1] apply :identity nested-block "6.1: Apply with nested block"

;; Hypothesis: None values passed correctly
assert-equal none apply :identity [none] "6.2: None value handling"

;;----------------------------------------
;; Final Summary
;;----------------------------------------
print-test-summary
