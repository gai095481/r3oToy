Rebol []

;;=============================================================================
;; Diagnostic Probe Script for the `take` Function.
;;=============================================================================
;; This script systematically tests the `take` function in Rebol 3 (Oldes Branch)
;; using the provided assert-equal and print-test-summary functions.
;;
;; Each test group is preceded by a hypothesis about the expected behavior.
;;=============================================================================

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

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL `take` EXAMPLES PASSED"
    ][
        print "❌ SOME `take` EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Probing Basic Behavior
;;-----------------------------------------------------------------------------
;; Hypothesis: When called without refinements, `take` removes and returns the
;; first element of a series. The original series is modified by removing that element.
;;-----------------------------------------------------------------------------
block1: [1 2 3 4 5]
assert-equal 1 take block1 "Take first element from a block."
assert-equal [2 3 4 5] block1 "Block after taking first element."

string1: "Hello"
assert-equal #"H" take string1 "Take first character from a string."
assert-equal "ello" string1 "String after taking first character."

;;-----------------------------------------------------------------------------
;; Probing `/last` Refinement
;;-----------------------------------------------------------------------------
;; Hypothesis: The `/last` refinement makes `take` remove and return the last element of a series.
;;-----------------------------------------------------------------------------
block2: [a b c d]
assert-equal 'd take/last block2 "Take last element from a block."
assert-equal [a b c] block2 "Block after taking last element."

string2: "World"
assert-equal #"d" take/last string2 "Take last character from a string."
assert-equal "Worl" string2 "String after taking last character."

;;-----------------------------------------------------------------------------
;; Probing `/part` Refinement
;;-----------------------------------------------------------------------------
;; Hypothesis: The `/part` refinement allows `take` to remove and return a
;; specified number of elements from the beginning of a series when used
;; without `/last`, or from the end when combined with `/last`.
;;-----------------------------------------------------------------------------
block3: [10 20 30 40 50]
assert-equal [10 20] take/part block3 2 "Take first two elements from a block."
assert-equal [30 40 50] block3 "Block after taking first two elements."

block4: [a b c d e]
assert-equal [d e] take/last/part block4 2 "Take last two elements from a block."
assert-equal [a b c] block4 "Block after taking last two elements."

string3: "REBOL"
assert-equal "RE" take/part string3 2 "Take first two characters from a string."
assert-equal "BOL" string3 "String after taking first two characters."

string4: "SCRIPT"
assert-equal "PT" take/last/part string4 2 "Take last two characters from a string."
assert-equal "SCRI" string4 "String after taking last two characters."

;;-----------------------------------------------------------------------------
;; Probing `/deep` Refinement
;;-----------------------------------------------------------------------------
;; Hypothesis: The `/deep` refinement is ignored by `take` in Rebol 3 Oldes branch,
;; as it does not support deep copying when taking elements.
;;-----------------------------------------------------------------------------
block5: [[1 2] [3 4] [5 6]]
assert-equal [1 2] take/deep block5 "Take first sub-block from a block with `/deep`."
assert-equal [[3 4] [5 6]] block5 "Block after taking first subblock."

;;-----------------------------------------------------------------------------
;; Probing Edge Cases with Empty Series
;;-----------------------------------------------------------------------------
;; Hypothesis: Taking from an empty series should result in an error.
;;-----------------------------------------------------------------------------
empty-block: []
attempt-result1: attempt [take empty-block]
assert-equal none? attempt-result1 true "Attempt to take from empty block results in `none`."

empty-string: ""
attempt-result2: attempt [take empty-string]
assert-equal none? attempt-result2 true "Attempt to take from empty string results in `none`."

;;-----------------------------------------------------------------------------
;; Probing with Invalid Inputs
;;-----------------------------------------------------------------------------
;; Hypothesis: Providing non-series types or invalid arguments should result in errors.
;;-----------------------------------------------------------------------------
;error1: trap [take 123]
;assert-equal 'script error1/id "Taking from non-series value should error."

;error2: trap [take/part "Test" -1]
;assert-equal 'script error2/id "Using negative /part value should error."

;;-----------------------------------------------------------------------------
;; Probing with Explicit Index Positions using `/part`.
;;-----------------------------------------------------------------------------
;; Hypothesis: When `/part` is given a position within the series, it takes elements up to that position.
;;-----------------------------------------------------------------------------
block6: [100 200 300 400 500]
assert-equal [100 200] take/part block6 find block6 300 "The `take` return value after taking element 300 and all elements after it."
assert-equal [300 400 500] block6 "The block6 after taking all elements before 300."

;;-----------------------------------------------------------------------------
;; Probing `/part` with Entire Series Length.
;;-----------------------------------------------------------------------------
;; Hypothesis: Taking with `/part` equal to the series length removes all elements.
;;-----------------------------------------------------------------------------
block8: [5 10 15]
assert-equal [5 10 15] take/part block8 length? block8 "Take all elements with `/part` equal to length."
assert-equal [] block8 "Block is empty after taking all elements"

;;-----------------------------------------------------------------------------
;; Probing `/last` with `/part` Exceeding Series Length.
;;-----------------------------------------------------------------------------
;; Hypothesis: Using `/last` with `/part` exceeding the series length takes all elements from the end.
;;-----------------------------------------------------------------------------
block9: [a b]
assert-equal [a b] take/last/part block9 5 "Take all elements with `/part` exceeding the block's length."
assert-equal [] block9 "Block is empty after taking all its elements."

;;-----------------------------------------------------------------------------
;; Test Summary
;;-----------------------------------------------------------------------------
print-test-summary
