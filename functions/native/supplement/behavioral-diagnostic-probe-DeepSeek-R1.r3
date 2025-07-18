Rebol [
    Title: "Diagnostic Probe for SUPPLEMENT Function"
    Author: "DeepSeek R1"
    Version: 0.1.3
    Purpose: {Systematically probe behavior of SUPPLEMENT function in REBOL/Bulk 3.19.0}
]

;;-----------------------------
;; Battle-Tested QA Harness
;;-----------------------------
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

;;------------------------------------
;; Diagnostic Probe: SUPPLEMENT
;;------------------------------------
print "Starting Diagnostic Probe for SUPPLEMENT function^/"

;;
;; Group 1: Basic Value Handling
;;
print "^/=== Group 1: Basic Value Handling ==="

;; Hypothesis: New values should be appended to block when not found
print "Hypothesis: New values (any type) should be appended when not present in block"
test-block: copy [a b 10]
expected-block: [a b 10 "new"]
ret: supplement test-block "new"
assert-equal expected-block test-block "1.1: New string appended"
assert-equal test-block ret "1.1: Returned original block head"

test-block: copy [1 2 3]
expected-block: [1 2 3 4]
ret: supplement test-block 4
assert-equal expected-block test-block "1.2: New integer appended"

test-block: copy [x y]
expected-block: [x y #(true)]
ret: supplement test-block true
assert-equal expected-block test-block "1.3: New logic value appended"

;; Hypothesis: Existing values should not append and block remains unchanged
print "Hypothesis: Existing values (any type) should leave block unchanged"
test-block: copy [a b c]
expected-block: [a b c]
ret: supplement test-block 'b
assert-equal expected-block test-block "1.4: Existing word found (no append)"

test-block: copy [10 20 30]
expected-block: [10 20 30]
ret: supplement test-block 20
assert-equal expected-block test-block "1.5: Existing integer found (no append)"

test-block: copy ["apple" "banana"]
expected-block: ["apple" "banana"]
ret: supplement test-block "banana"
assert-equal expected-block test-block "1.6: Existing string found (no append)"

;;
;; Group 2: /case Refinement Behavior
;;
print "^/=== Group 2: /case Refinement Behavior ==="

;; Hypothesis: /case makes string comparisons case-sensitive
print "Hypothesis: /case enables case-sensitive string comparison"
test-block: copy ["Apple" "Banana"]
expected-block: ["Apple" "Banana" "apple"]
ret: supplement/case test-block "apple"
assert-equal expected-block test-block "2.1: /case: Different case string appended"

test-block: copy ["Red" "Green"]
expected-block: ["Red" "Green"]
ret: supplement/case test-block "Red"
assert-equal expected-block test-block "2.2: /case: Same case string not appended"

;; Hypothesis: /case has no effect on non-string comparisons
print "Hypothesis: /case doesn't affect non-string value comparisons"
test-block: copy [apple BANANA]
expected-block: [apple BANANA]
ret: supplement/case test-block 'apple
assert-equal expected-block test-block "2.3: /case: Word comparison unaffected (found)"

test-block: copy [10 20]
expected-block: [10 20 30]
ret: supplement/case test-block 30
assert-equal expected-block test-block "2.4: /case: Integer comparison unaffected (appended)"

;;
;; Group 3: Special Value Handling
;;
print "^/=== Group 3: Special Value Handling ==="

;; Hypothesis: NONE values can be supplemented like any other value
print "Hypothesis: NONE values are handled like other values"
test-block: copy [a b #(none)]
expected-block: [a b #(none)]
ret: supplement test-block none
assert-equal expected-block test-block "3.1: Existing NONE found (no append)"

test-block: copy [1 2 3]
expected-block: [1 2 3 #(none)]
ret: supplement test-block none
assert-equal expected-block test-block "3.2: New NONE appended"

;; Hypothesis: Block values are treated as subsequence patterns
print "Hypothesis: Block values are treated as subsequence patterns"
test-block: copy [1 2 3 4]
expected-block: [1 2 3 4]
ret: supplement test-block [2 3]
assert-equal expected-block test-block "3.3: Existing subsequence found (no append)"

test-block: copy [a b c d]
expected-block: [a b c d]
ret: supplement test-block [b c]
assert-equal expected-block test-block "3.4: Existing subsequence found (no append)"

test-block: copy [10 20 30]
expected-block: [10 20 30 40 50]
ret: supplement test-block [40 50]
assert-equal expected-block test-block "3.5: New subsequence appended as elements"

test-block: copy [x y]
expected-block: [x y z w]
ret: supplement test-block [z w]
assert-equal expected-block test-block "3.6: New subsequence appended as elements"

;;
;; Group 4: Edge Cases
;;
print "^/=== Group 4: Edge Cases ==="

;; Hypothesis: Empty blocks should accept first supplement
print "Hypothesis: Empty blocks accept first supplemented value"
test-block: copy []
expected-block: [first]
ret: supplement test-block 'first
assert-equal expected-block test-block "4.1: First value added to empty block"
assert-equal test-block ret "4.1: Returned head of modified block"

;; Hypothesis: Duplicate values prevent appends
print "Hypothesis: Single occurrence prevents duplicate appends"
test-block: copy [a a a]
expected-block: [a a a]
ret: supplement test-block 'a
assert-equal expected-block test-block "4.2: Existing duplicate prevents append"

;; Hypothesis: Different datatypes don't match even with similar appearance
print "Hypothesis: Values of different types never match"
test-block: copy [1 "1" #"1"]
expected-block: [1 "1" #"1" one]
ret: supplement test-block 'one
assert-equal expected-block test-block "4.3: Different types don't match (word appended)"

test-block: copy [10]
expected-block: [10 "10"]
ret: supplement test-block "10"
assert-equal expected-block test-block "4.4: String vs integer not equal (appended)"

;;
;; Group 5: Positional Integrity
;;
print "^/=== Group 5: Positional Integrity ==="

;; Hypothesis: Always returns original head position
print "Hypothesis: Always returns original series head regardless of changes"
test-block: copy [a b c]
original-head: head test-block
ret: supplement test-block 'd
assert-equal original-head ret "5.1: Returns original head after append"
assert-equal head test-block ret "5.1: Current head matches return value"

test-block: copy [x y z]
original-head: head test-block
ret: supplement test-block 'y
assert-equal original-head ret "5.2: Returns original head when no append"

;; Print final test summary
print-test-summary
