Rebol []

;; ============================================================================
;; DIAGNOSTIC PROBE SCRIPT FOR `supplement` FUNCTION
;; Target: REBOL/Bulk 3.19.0 (Oldes Branch)
;; Purpose: Systematically test the behavior of the `supplement` function and
;;          all its refinements to create a comprehensive "truth log" from the
;;          REPL.
;; ============================================================================

print "^/============================================"
print "=== SUPPLEMENT FUNCTION DIAGNOSTIC PROBE ==="
print "============================================^/"

;;-----------------------------
;; A Battle-Tested QA Harness
;;------------------------------
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

;; ============================================================================
;; SECTION 1: PROBING BASIC BEHAVIOR
;; ============================================================================

print "^/--- SECTION 1: PROBING BASIC BEHAVIOR ---^/"

;; HYPOTHESIS: `supplement` appends a value to a block if it's not already present.
test-block-1: [1 2 3]
supplement test-block-1 4
assert-equal [1 2 3 4] test-block-1 "Append a new integer to the block"

;; HYPOTHESIS: `supplement` does not modify the block if the value is already present.
test-block-2: [1 2 3]
supplement test-block-2 2
assert-equal [1 2 3] test-block-2 "Do not append an existing integer"

;; HYPOTHESIS: `supplement` works with string values.
test-block-3: ["apple" "banana"]
supplement test-block-3 "cherry"
assert-equal ["apple" "banana" "cherry"] test-block-3 "Append a new string"

;; HYPOTHESIS: `supplement` returns the series at the same position it was called from.
test-block-4: [1 2 3]
result-1: supplement test-block-4 4
assert-equal test-block-4 result-1 "Return the series at the same position"

;; ============================================================================
;; SECTION 2: PROBING /CASE REFINEMENT
;; ============================================================================

print "^/--- SECTION 2: PROBING /CASE REFINEMENT ---^/"

;; HYPOTHESIS: By default, `supplement` is case-insensitive for strings.
test-block-5: ["apple" "banana"]
supplement test-block-5 "Apple"
assert-equal ["apple" "banana"] test-block-5 "Case-insensitive: 'Apple' is found"

;; HYPOTHESIS: The `/case` refinement makes `supplement` case-sensitive.
test-block-6: ["apple" "banana"]
supplement/case test-block-6 "Apple"
assert-equal ["apple" "banana" "Apple"] test-block-6 "Case-sensitive: 'Apple' is appended"

;; ============================================================================
;; SECTION 3: PROBING EDGE CASES
;; ============================================================================

print "^/--- SECTION 3: PROBING EDGE CASES ---^/"

;; HYPOTHESIS: `supplement` works correctly with an empty block.
test-block-7: []
supplement test-block-7 1
assert-equal [1] test-block-7 "Append to an empty block"

;; HYPOTHESIS: `supplement` can handle `none` as a value.
test-block-8: [1 2]
supplement test-block-8 none
assert-equal [1 2 none] test-block-8 "Append `none` to the block"

;; HYPOTHESIS: `supplement` finds `none` if it's already in the block.
test-block-9: [1 none 2]
supplement test-block-9 none
assert-equal [1 none 2] test-block-9 "Do not append `none` if it exists"

;; ============================================================================
;; SECTION 4: PROBING SERIES POSITION
;; ============================================================================

print "^/--- SECTION 4: PROBING SERIES POSITION ---^/"

;; HYPOTHESIS: `supplement` returns the series at the head, even if a non-head position is passed.
test-block-10: [a b c]
series-pos: next test-block-10
result-2: supplement series-pos 'd
assert-equal [a b c d] test-block-10 "Append to a non-head series"
assert-equal [a b c d] result-2 "Return the series at the head"

;; ============================================================================
;; FINAL TEST SUMMARY
;; ============================================================================

print-test-summary
