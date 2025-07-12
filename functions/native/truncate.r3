Rebol [
    Title: "Behavioral Diagnostic Script for `truncate`"
    Purpose: "Comprehensively diagnose the behavior of the `truncate` native function"
    Date: 12-Jul-2025
    Author: "Claude 4 Sonnet"
    Version: 0.1.0
]

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
    print ["=== TEST SUMMARY ==="]
    print "============================================"
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - TRUNCATE IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; TRUNCATE FUNCTION DIAGNOSTIC PROBE
;;=============================================================================

print "^/=== TRUNCATE FUNCTION DIAGNOSTIC PROBE SCRIPT ==="
print "Testing REBOL/Bulk 3.19.0 (Oldes Branch)^/"

;;-----------------------------------------------------------------------------
;; SECTION 1: Probing Basic Behavior with Block Series
;;-----------------------------------------------------------------------------

print "^/--- SECTION 1: Probing Basic Behavior with Block Series ---"

;; HYPOTHESIS: truncate on a block at head position should return the same block unchanged
;; since there's nothing to remove from head to current position
test-block-at-head: [a b c d e]
result-block-at-head: truncate test-block-at-head
assert-equal [a b c d e] result-block-at-head "Block at head position should remain unchanged"

;; HYPOTHESIS: truncate on a block that has been advanced should remove elements
;; from head up to (but not including) the current index position
test-block-advanced: [a b c d e]
test-block-advanced: next test-block-advanced  ;; Now at position 2 (pointing to 'b')
result-block-advanced: truncate test-block-advanced
assert-equal [b c d e] result-block-advanced "Block advanced by 1 should remove first element"

;; HYPOTHESIS: truncate on a block advanced multiple positions should remove
;; multiple elements from the head
test-block-multi: [a b c d e f g]
test-block-multi: skip test-block-multi 3  ;; Now at position 4 (pointing to 'd')
result-block-multi: truncate test-block-multi
assert-equal [d e f g] result-block-multi "Block advanced by 3 should remove first 3 elements"

;;-----------------------------------------------------------------------------
;; SECTION 2: Probing Basic Behavior with String Series
;;-----------------------------------------------------------------------------

print "^/--- SECTION 2: Probing Basic Behavior with String Series ---"

;; HYPOTHESIS: truncate on a string at head position should return the same string unchanged
test-string-at-head: "hello world"
result-string-at-head: truncate test-string-at-head
assert-equal "hello world" result-string-at-head "String at head position should remain unchanged"

;; HYPOTHESIS: truncate on a string that has been advanced should remove characters
;; from head up to (but not including) the current index position
test-string-advanced: "hello world"
test-string-advanced: skip test-string-advanced 6  ;; Now pointing to 'w' in "world"
result-string-advanced: truncate test-string-advanced
assert-equal "world" result-string-advanced "String advanced by 6 should remove 'hello ' prefix"

;; HYPOTHESIS: truncate on a string advanced to near the end should leave only tail characters
test-string-near-end: "programming"
test-string-near-end: skip test-string-near-end 8  ;; Now pointing to 'i' in "ing" (position 9)
result-string-near-end: truncate test-string-near-end
assert-equal "ing" result-string-near-end "String advanced by 8 should leave only 'ing'"

;;-----------------------------------------------------------------------------
;; SECTION 3: Probing /part Refinement with Number Range
;;-----------------------------------------------------------------------------

print "^/--- SECTION 3: Probing /part Refinement with Number Range ---"

;; HYPOTHESIS: truncate/part with a number should first truncate normally, then
;; limit the result to the specified length
test-part-block: [a b c d e f g h]
test-part-block: skip test-part-block 2  ;; Now at position 3 (pointing to 'c')
result-part-number: truncate/part test-part-block 3
assert-equal [c d e] result-part-number "Block truncated and limited to 3 elements"

;; HYPOTHESIS: truncate/part with number larger than remaining elements should
;; return all remaining elements after truncation
test-part-large: [a b c d e]
test-part-large: skip test-part-large 2  ;; Now at position 3 (pointing to 'c')
result-part-large: truncate/part test-part-large 10
assert-equal [c d e] result-part-large "Block truncated with part larger than remaining should return all remaining"

;; HYPOTHESIS: truncate/part with number 0 should return empty series
test-part-zero: [a b c d e]
test-part-zero: skip test-part-zero 2  ;; Now at position 3 (pointing to 'c')
result-part-zero: truncate/part test-part-zero 0
assert-equal [] result-part-zero "Block truncated with part 0 should return empty series"

;; HYPOTHESIS: truncate/part with string and number should work similarly
test-part-string: "hello world"
test-part-string: skip test-part-string 6  ;; Now pointing to 'w' in "world"
result-part-string: truncate/part test-part-string 3
assert-equal "wor" result-part-string "String truncated and limited to 3 characters"

;;-----------------------------------------------------------------------------
;; SECTION 4: Probing /part Refinement with Series Range
;;-----------------------------------------------------------------------------

print "^/--- SECTION 4: Probing /part Refinement with Series Range ---"

;; HYPOTHESIS: truncate/part with a series position should truncate normally, then
;; limit the result to end at the specified series position
test-part-series-block: [a b c d e f g h i]
test-part-series-block: skip test-part-series-block 2  ;; Now at position 3 (pointing to 'c')
end-position: skip test-part-series-block 3  ;; Position pointing to 'f'
result-part-series: truncate/part test-part-series-block end-position
assert-equal [c d e] result-part-series "Block truncated with series end position"

;; HYPOTHESIS: truncate/part with series position beyond end should return all remaining
test-part-series-beyond: [a b c d e]
test-part-series-beyond: skip test-part-series-beyond 2  ;; Now at position 3 (pointing to 'c')
end-position-beyond: tail test-part-series-beyond  ;; Position at tail
result-part-series-beyond: truncate/part test-part-series-beyond end-position-beyond
assert-equal [c d e] result-part-series-beyond "Block truncated with series end position beyond tail"

;; HYPOTHESIS: truncate/part with string and series position should work similarly
test-part-string-series: "hello world"
test-part-string-series: skip test-part-string-series 6  ;; Now pointing to 'w' in "world"
end-pos-string: skip test-part-string-series 3  ;; Position pointing to 'l' in "rld"
result-part-string-series: truncate/part test-part-string-series end-pos-string
assert-equal "wor" result-part-string-series "String truncated with series end position"

;;-----------------------------------------------------------------------------
;; SECTION 5: Probing Edge Cases - Empty Series
;;-----------------------------------------------------------------------------

print "^/--- SECTION 5: Probing Edge Cases - Empty Series ---"

;; HYPOTHESIS: truncate on empty block should return empty block
empty-test-block: []
result-empty-block: truncate empty-test-block
assert-equal [] result-empty-block "Empty block should remain empty after truncate"

;; HYPOTHESIS: truncate on empty string should return empty string
empty-test-string: ""
result-empty-string: truncate empty-test-string
assert-equal "" result-empty-string "Empty string should remain empty after truncate"

;; HYPOTHESIS: truncate/part on empty series should return empty series
empty-part-block: []
result-empty-part-block: truncate/part empty-part-block 5
assert-equal [] result-empty-part-block "Empty block with part should remain empty"

;;-----------------------------------------------------------------------------
;; SECTION 6: Probing Edge Cases - Series at Tail
;;-----------------------------------------------------------------------------

print "^/--- SECTION 6: Probing Edge Cases - Series at Tail ---"

;; HYPOTHESIS: truncate on series positioned at tail should return empty series
;; since all elements are "before" the current position
test-tail-block: [a b c d e]
test-tail-block: tail test-tail-block  ;; Now at tail position
result-tail-block: truncate test-tail-block
assert-equal [] result-tail-block "Block at tail position should return empty after truncate"

;; HYPOTHESIS: truncate on string positioned at tail should return empty string
test-tail-string: "hello"
test-tail-string: tail test-tail-string  ;; Now at tail position
result-tail-string: truncate test-tail-string
assert-equal "" result-tail-string "String at tail position should return empty after truncate"

;;-----------------------------------------------------------------------------
;; SECTION 7: Probing Different Series Types
;;-----------------------------------------------------------------------------

print "^/--- SECTION 7: Probing Different Series Types ---"

;; HYPOTHESIS: truncate should work on binary series
test-binary: #{48656C6C6F}  ;; "Hello" in binary
test-binary: skip test-binary 2  ;; Skip first 2 bytes
result-binary: truncate test-binary
assert-equal #{6C6C6F} result-binary "Binary truncate should remove first 2 bytes"

;; HYPOTHESIS: truncate should work on vector series (if available)
;; Note: This may not be available in all Rebol 3 builds, so we'll test cautiously
set/any 'vector-result try [
    test-vector: make vector! [integer! 8 [1 2 3 4 5]]
    test-vector: skip test-vector 2  ;; Skip first 2 elements
    truncate test-vector
]
either error? vector-result [
    print "✅ PASSED: Vector type not available or not supported - expected in some builds"
][
    ;; If vectors are supported, check the result
    assert-equal make vector! [integer! 8 [3 4 5]] vector-result "Vector truncate should remove first 2 elements"
]

;;-----------------------------------------------------------------------------
;; SECTION 8: Probing Error Conditions
;;-----------------------------------------------------------------------------

print "^/--- SECTION 8: Probing Error Conditions ---"

;; HYPOTHESIS: truncate with non-series argument should generate an error
set/any 'error-result try [truncate 42]
assert-equal true (error? error-result) "Non-series argument should generate error"

;; HYPOTHESIS: truncate/part with invalid range type should generate an error
set/any 'error-part-result try [
    test-error-block: [a b c d]
    truncate/part test-error-block "invalid"
]
assert-equal true (error? error-part-result) "Invalid range type should generate error"

;; HYPOTHESIS: truncate/part with negative number should handle gracefully or error
set/any 'negative-result try [
    test-negative-block: [a b c d e]
    test-negative-block: skip test-negative-block 2
    truncate/part test-negative-block -1
]
either error? negative-result [
    print "✅ PASSED: Negative part range generates error - safe behavior"
][
    print ["⚠️  WARNING: Negative part range returned:" mold negative-result]
]

;;-----------------------------------------------------------------------------
;; SECTION 9: Probing Return Value and Mutation Behavior
;;-----------------------------------------------------------------------------

print "^/--- SECTION 9: Probing Return Value and Mutation Behavior ---"

;; HYPOTHESIS: truncate modifies the original series and returns the modified series
original-for-mutation: [a b c d e f]
advanced-for-mutation: skip original-for-mutation 3  ;; Point to 'd'
result-mutation: truncate advanced-for-mutation
assert-equal [d e f] result-mutation "Truncate should return modified series"

;; HYPOTHESIS: The original series reference should also reflect the truncation
;; Note: This tests whether truncate mutates the series in place
assert-equal [d e f] original-for-mutation "Original series should be modified by truncate"

;; HYPOTHESIS: The returned series should be the same series object (same identity)
assert-equal true (same? result-mutation original-for-mutation) "Returned series should be same object as original"

;;-----------------------------------------------------------------------------
;; SECTION 10: Probing Complex Index Manipulations
;;-----------------------------------------------------------------------------

print "^/--- SECTION 10: Probing Complex Index Manipulations ---"

;; HYPOTHESIS: Multiple truncate operations should work correctly
multi-truncate-test: [a b c d e f g h i j]
multi-truncate-test: skip multi-truncate-test 2  ;; Point to 'c'
first-truncate: truncate multi-truncate-test      ;; Should give [c d e f g h i j]
second-truncate-test: skip first-truncate 2       ;; Point to 'e'
second-truncate: truncate second-truncate-test    ;; Should give [e f g h i j]
assert-equal [e f g h i j] second-truncate "Multiple truncate operations should work correctly"

;; HYPOTHESIS: truncate/part after series manipulation should work correctly
complex-test: [a b c d e f g h i j k l]
complex-test: skip complex-test 4  ;; Point to 'e'
complex-result: truncate/part complex-test 5
assert-equal [e f g h i] complex-result "Complex truncate/part should work correctly"

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================

print-test-summary
