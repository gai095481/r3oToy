REBOL [
    Title: "4. `take` - Edge Case Examples (Corrected)"
    Date: 22-Jun-2025
    Purpose: "To test and document `take`'s behavior with unusual but valid inputs."
]

;-----------------------------------------------------------------------------
;;; Battle-Tested QA Harness
;-----------------------------------------------------------------------------
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
        print "✅ ALL `take` EDGE CASE TESTS PASSED"
    ][
        print "❌ SOME `take` EDGE CASE TESTS FAILED"
    ]
    print "============================================^/"
]

print "--- `take` Function: Edge Case Examples ---"

;-----------------------------------------------------------------------------
print "^/--- Edge Case 1: Taking from an Empty Series ---"
;-----------------------------------------------------------------------------
data: []
result: take data
assert-equal none result "Taking from an empty block returns `none`."


;-----------------------------------------------------------------------------
print "^/--- Edge Case 2: Taking from the Tail of a Series ---"
;-----------------------------------------------------------------------------
data: [a b c]
tail-pos: tail data
result: take tail-pos
assert-equal none result "Taking from the tail of a block returns `none`."


;-----------------------------------------------------------------------------
print "^/--- Edge Case 3: Using `/part` with a Zero Count ---"
;-----------------------------------------------------------------------------
data: [a b c d]
original-copy: copy data
result-zero: take/part data 0
assert-equal [] result-zero "Taking `/part 0` returns an empty block."
assert-equal original-copy data "Taking `/part 0` does not modify the original series."


;-----------------------------------------------------------------------------
print "^/--- Edge Case 4: Using `/part` with a Negative Argument ---"
;-----------------------------------------------------------------------------
; This documents the actual behavior: it does not error, it does nothing.
data: [a b c]
original-copy: copy data
result: take/part data -2
assert-equal [] result "Taking `/part` with a negative number returns an empty block."
assert-equal original-copy data "Taking `/part` with a negative number does not modify the original."


;-----------------------------------------------------------------------------
print "^/--- Edge Case 5: Taking more items than available ---"
;-----------------------------------------------------------------------------
data: [a b c]
result: take/part data 10
assert-equal [a b c] result "Taking more items than available returns all items."
assert-equal true empty? data "Taking more items than available empties the original series."


;-----------------------------------------------------------------------------
print "^/--- Edge Case 6: Taking from a string ---"
;-----------------------------------------------------------------------------
data-string: "Rebol"
char: take data-string
assert-equal #"R" char "Taking from a string returns the first character."
assert-equal "ebol" data-string "Taking from a string modifies the original string."

print-test-summary
