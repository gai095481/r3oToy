Rebol []

;;=============================================================================
;; COMPREHENSIVE DIAGNOSTIC PROBE SCRIPT FOR SUPPLEMENT FUNCTION (TRULY FINAL)
;; Target: REBOL/Bulk 3.19.0 (Oldes Branch)
;; Purpose: Systematically test supplement function behavior and edge cases
;; TRULY FINAL VERSION: All behaviors now correctly understood and tested
;;=============================================================================

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

print "^/=== SUPPLEMENT FUNCTION DIAGNOSTIC PROBE (TRULY FINAL) ==="
print "Testing supplement function behavior and edge cases..."
print "============================================^/"

;;=============================================================================
;; SECTION 1: PROBING BASIC BEHAVIOR - VALUE NOT FOUND
;;=============================================================================
print "^/--- Section 1: Probing Basic Behavior - Value Not Found ---"
;; HYPOTHESIS: When value is not found in series, supplement should append it
;; and return the original series at the same position.

test-block-1: [1 2 3]
original-position: test-block-1
result-1: supplement test-block-1 4

assert-equal [1 2 3 4] test-block-1 "Block should be modified with new value appended"
assert-equal original-position result-1 "Function should return series at same position"
assert-equal true same? test-block-1 result-1 "Returned series should be same object as input"

;;=============================================================================
;; SECTION 2: PROBING BASIC BEHAVIOR - VALUE ALREADY EXISTS
;;=============================================================================
print "^/--- Section 2: Probing Basic Behavior - Value Already Exists ---"
;; HYPOTHESIS: When value already exists in series, supplement should not modify
;; the series and return it at the same position.

test-block-2: [1 2 3]
original-position-2: test-block-2
result-2: supplement test-block-2 2

assert-equal [1 2 3] test-block-2 "Block should remain unchanged when value exists"
assert-equal original-position-2 result-2 "Function should return series at same position"
assert-equal true same? test-block-2 result-2 "Returned series should be same object as input"

;;=============================================================================
;; SECTION 3: PROBING STRING VALUES
;;=============================================================================
print "^/--- Section 3: Probing String Values ---"
;; HYPOTHESIS: supplement should work with string values using default case-insensitive
;; comparison for find operation.

test-block-3a: ["hello" "world"]
result-3a: supplement test-block-3a "test"
assert-equal ["hello" "world" "test"] test-block-3a "String value should be appended when not found"

test-block-3b: ["hello" "world"]
result-3b: supplement test-block-3b "hello"
assert-equal ["hello" "world"] test-block-3b "Block should remain unchanged when string exists"

;;=============================================================================
;; SECTION 4: PROBING /CASE REFINEMENT WITH STRINGS
;;=============================================================================
print "^/--- Section 4: Probing /case Refinement with Strings ---"
;; HYPOTHESIS: With /case refinement, supplement should perform case-sensitive
;; comparison, so "Hello" and "hello" should be treated as different values.

test-block-4a: ["hello" "world"]
result-4a: supplement/case test-block-4a "Hello"
assert-equal ["hello" "world" "Hello"] test-block-4a "Case-sensitive: 'Hello' should be added when 'hello' exists"

test-block-4b: ["Hello" "world"]
result-4b: supplement/case test-block-4b "Hello"
assert-equal ["Hello" "world"] test-block-4b "Case-sensitive: 'Hello' should not be added when 'Hello' exists"

;;=============================================================================
;; SECTION 5: PROBING DIFFERENT DATA TYPES - CORRECTED EXPECTATIONS
;;=============================================================================
print "^/--- Section 5: Probing Different Data Types - Corrected Expectations ---"
;; HYPOTHESIS: supplement should work with any-type! values.
;; DISCOVERY: Logic and none values display as #(true) and #(none) in mold output.
;; DISCOVERY: Block values get appended element-wise, not as nested blocks!

test-block-5a: [1 2 3]
result-5a: supplement test-block-5a true
assert-equal [1 2 3 #(true)] test-block-5a "Logic value should be appended (displays as #(true))"

test-block-5b: [1 2 3]
result-5b: supplement test-block-5b [a b]
assert-equal [1 2 3 a b] test-block-5b "Block elements should be appended individually, not as nested block"

test-block-5c: [1 2 3]
result-5c: supplement test-block-5c none
assert-equal [1 2 3 #(none)] test-block-5c "None value should be appended (displays as #(none))"

;;=============================================================================
;; SECTION 6: PROBING EDGE CASES - EMPTY BLOCK
;;=============================================================================
print "^/--- Section 6: Probing Edge Cases - Empty Block ---"
;; HYPOTHESIS: supplement should work with empty blocks, always appending
;; the value since nothing exists to find.

test-block-6: []
result-6: supplement test-block-6 "first"
assert-equal ["first"] test-block-6 "Value should be appended to empty block"
assert-equal true same? test-block-6 result-6 "Returned series should be same object as input"

;;=============================================================================
;; SECTION 7: PROBING DUPLICATE VALUES ALREADY IN SERIES
;;=============================================================================
print "^/--- Section 7: Probing Duplicate Values Already in Series ---"
;; HYPOTHESIS: supplement should only check for existence, not prevent
;; multiple occurrences if they already exist.

test-block-7a: [1 2 2 3]
result-7a: supplement test-block-7a 2
assert-equal [1 2 2 3] test-block-7a "Should not add duplicate when value already exists"

test-block-7b: [1 2 2 3]
result-7b: supplement test-block-7b 4
assert-equal [1 2 2 3 4] test-block-7b "Should add new value even when duplicates exist"

;;=============================================================================
;; SECTION 8: PROBING SERIES POSITION PRESERVATION - CORRECTED TEST
;;=============================================================================
print "^/--- Section 8: Probing Series Position Preservation - Corrected Test ---"
;; HYPOTHESIS: supplement should return the series at the same position
;; it was passed, regardless of whether value was found or appended.
;; CORRECTION: Test logic was wrong - checking position correctly now.

test-block-8: [1 2 3 4 5]
positioned-series: next next test-block-8  ; Position at index 3
result-8: supplement positioned-series 6

assert-equal [1 2 3 4 5 6] test-block-8 "Original block should be modified"
assert-equal positioned-series result-8 "Should return series at same position"
assert-equal [3 4 5 6] result-8 "Position should be preserved (at index 3 content)"

;;=============================================================================
;; SECTION 9: PROBING WORD VALUES
;;=============================================================================
print "^/--- Section 9: Probing Word Values ---"
;; HYPOTHESIS: supplement should work with word! values, treating them
;; as distinct values that can be found and compared.

test-block-9a: ['hello 'world]
result-9a: supplement test-block-9a 'test
assert-equal ['hello 'world 'test] test-block-9a "Word value should be appended when not found"

test-block-9b: ['hello 'world]
result-9b: supplement test-block-9b 'hello
assert-equal ['hello 'world] test-block-9b "Block should remain unchanged when word exists"

;;=============================================================================
;; SECTION 10: PROBING NESTED BLOCKS - CORRECTED EXPECTATIONS
;;=============================================================================
print "^/--- Section 10: Probing Nested Blocks - Corrected Expectations ---"
;; HYPOTHESIS: supplement should treat nested blocks as single values
;; DISCOVERY: Actually, it appears to append block contents individually!

test-block-10a: [[1 2] [3 4]]
result-10a: supplement test-block-10a [5 6]
assert-equal [[1 2] [3 4] 5 6] test-block-10a "Block elements should be appended individually, not as nested block"

test-block-10b: [[1 2] [3 4]]
result-10b: supplement test-block-10b [1 2]
assert-equal [[1 2] [3 4] 1 2] test-block-10b "Block elements should be appended individually when block content is not found"

;;=============================================================================
;; SECTION 11: PROBING ZERO AND NEGATIVE NUMBERS
;;=============================================================================
print "^/--- Section 11: Probing Zero and Negative Numbers ---"
;; HYPOTHESIS: supplement should handle zero and negative numbers correctly
;; as distinct values.

test-block-11a: [1 -1 2]
result-11a: supplement test-block-11a 0
assert-equal [1 -1 2 0] test-block-11a "Zero should be appended when not found"

test-block-11b: [1 -1 2]
result-11b: supplement test-block-11b -1
assert-equal [1 -1 2] test-block-11b "Block should remain unchanged when negative number exists"

;;=============================================================================
;; SECTION 12: PROBING DECIMAL VALUES
;;=============================================================================
print "^/--- Section 12: Probing Decimal Values ---"
;; HYPOTHESIS: supplement should work with decimal values and distinguish
;; between integers and decimals.

test-block-12a: [1 2 3]
result-12a: supplement test-block-12a 1.5
assert-equal [1 2 3 1.5] test-block-12a "Decimal should be appended when not found"

test-block-12b: [1.0 2 3]
result-12b: supplement test-block-12b 1.0
assert-equal [1.0 2 3] test-block-12b "Block should remain unchanged when decimal exists"

;;=============================================================================
;; SECTION 13: PROBING BLOCK APPENDING BEHAVIOR - TRULY FINAL DISCOVERY
;;=============================================================================
print "^/--- Section 13: Probing Block Appending Behavior - Truly Final Discovery ---"
;; HYPOTHESIS: Based on discoveries, supplement uses append which spreads block contents
;; rather than appending blocks as single nested elements.
;; FINAL DISCOVERY: supplement checks the ENTIRE block as a value, not individual elements!

test-block-13a: [a b]
result-13a: supplement test-block-13a [c d]
assert-equal [a b c d] test-block-13a "Block contents should be spread when appending"

test-block-13b: [a b]
result-13b: supplement test-block-13b [a]
assert-equal [a b] test-block-13b "Block should remain unchanged when block element already exists"

test-block-13c: [a b]
result-13c: supplement test-block-13c [a c]
assert-equal [a b a c] test-block-13c "ALL block elements should be appended regardless of individual existence"

test-block-13d: [a b]
result-13d: supplement test-block-13d [x y]
assert-equal [a b x y] test-block-13d "All elements should be appended when none exist in target"

;;=============================================================================
;; RUN FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
