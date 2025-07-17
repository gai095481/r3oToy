Rebol [
    Title: "Sort Function Diagnostic Probe (Verified)"
    Author: "Rebol Expert"
    Version: 1.1.0
    Purpose: {Comprehensive verification of SORT function behavior}
]

;;-----------------------------
;; Test Harness Implementation
;;------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare values and output PASSED/FAILED message}
    expected [any-type!] "Expected value"
    actual [any-type!] "Actual value"
    description [string!] "Test description"
][
    set 'test-count test-count + 1
    either equal? expected actual [
        set 'pass-count pass-count + 1
        print ["✅ PASSED:" description]
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        print rejoin [
            "❌ FAILED: " description
            "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
]

print-test-summary: does [
    print "^/============================================"
    print "=== TEST SUMMARY ==="
    print "============================================"
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " fail-count]
    print either all-tests-passed? [
        "✅ ALL TESTS PASSED - SORT BEHAVIOR VERIFIED"
    ][
        "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;----------------------------------------
;; SORT Function Diagnostics
;;----------------------------------------
print "=== BEGIN SORT FUNCTION DIAGNOSTICS ===^/"

;;---------------------------------------------------------------------------
;; Group 1: Basic Sorting (Hypothesis: Default = ascending lex order)
;;---------------------------------------------------------------------------
print "=== Group 1: Basic Sorting Behavior ==="

test-block: [3 1 4 2 5]
sort test-block
assert-equal [1 2 3 4 5] test-block "Basic numeric sort"

text-series: "delta bravo charlie alpha"
sort text-series
assert-equal "   aaaaabcdeehhillloprrtv" text-series "Basic string sort"

mixed-block: [10 "beta" 5 "alpha"]
sort mixed-block
assert-equal [5 10 "alpha" "beta"] mixed-block "Mixed type sort"

;;---------------------------------------------------------------------------
;; Group 2: /reverse (Hypothesis: Produces descending order)
;;---------------------------------------------------------------------------
print "^/=== Group 2: /reverse Refinement ==="

reverse-test: [5 3 4 1 2]
sort/reverse reverse-test
assert-equal [5 4 3 2 1] reverse-test "Numeric reverse sort"

text-reverse: "alpha beta gamma"
sort/reverse text-reverse
assert-equal "tpmmlhgebaaaaa  " text-reverse "String reverse sort"

;;---------------------------------------------------------------------------
;; Group 3: /case (Hypothesis: Enables case sensitivity)
;;---------------------------------------------------------------------------
print "^/=== Group 3: /case Refinement ==="

case-block: ["a" "C" "B" "c" "A"]
sort case-block
assert-equal ["a" "A" "B" "C" "c"] case-block "Case-insensitive default sort"

case-sensitive: ["a" "C" "B" "c" "A"]
sort/case case-sensitive
assert-equal ["A" "B" "C" "a" "c"] case-sensitive "Case-sensitive sort"

;;---------------------------------------------------------------------------
;; Group 4: /skip (Hypothesis: Treats series as fixed-size records)
;;---------------------------------------------------------------------------
print "^/=== Group 4: /skip Refinement ==="

record-block: [10 20 30 40 50 60]
sort/skip record-block 2
assert-equal [10 20 30 40 50 60] record-block "Sort by first field (unchanged)"

record-block2: [30 99 10 55 20 88]
sort/skip record-block2 2
assert-equal [10 55 20 88 30 99] record-block2 "Sort by first field"

;;---------------------------------------------------------------------------
;; Group 5: /compare (Hypothesis: Custom comparator overrides default logic)
;;---------------------------------------------------------------------------
print "^/=== Group 5: /compare Refinement ==="

length-compare: func [a b] [ (length? a) - (length? b) ]

word-block: ["aaa" "bb" "c" "dddd"]
sort/compare word-block :length-compare
assert-equal ["c" "bb" "aaa" "dddd"] word-block "Sort by word length"

record-compare: [3 99 1 55 2 88]
sort/skip/compare record-compare 2 2
assert-equal [1 55 2 88 3 99] record-compare "Sort by record's second field"

;;---------------------------------------------------------------------------
;; Group 6: /part (Hypothesis: Limits sorting to specified subset)
;;---------------------------------------------------------------------------
print "^/=== Group 6: /part Refinement ==="

partial-block: [5 4 3 2 1]
sort/part partial-block 3
assert-equal [3 4 5 2 1] partial-block "Partial sort (first 3 elements)"

partial-string: "edcba"
sort/part partial-string 3
assert-equal "cdeba" partial-string "Partial string sort"

;;---------------------------------------------------------------------------
;; Group 7: /all (Hypothesis: Compares full values with /skip)
;;---------------------------------------------------------------------------
print "^/=== Group 7: /all Refinement ==="

all-records: [30 99 10 55 20 88]
sort/skip/all all-records 2
assert-equal [10 55 20 88 30 99] all-records "/all with /skip"

all-records2: [3 300 1 100 2 200]
sort/skip/all all-records2 2
assert-equal [1 100 2 200 3 300] all-records2 "/all compares entire records"

;;---------------------------------------------------------------------------
;; Group 8: Edge Cases (Hypothesis: Handles special conditions gracefully)
;;---------------------------------------------------------------------------
print "^/=== Group 8: Edge Cases & Special Conditions ==="

empty-block: copy []
sort empty-block
assert-equal [] empty-block "Empty block sort"

sorted-block: [1 2 3 4 5]
sort sorted-block
assert-equal [1 2 3 4 5] sorted-block "Already sorted"

duplicate-block: [3 1 3 2 2 1]
sort duplicate-block
assert-equal [1 1 2 2 3 3] duplicate-block "Duplicate values"

zero-block: [0 -1 1]
sort zero-block
assert-equal [-1 0 1] zero-block "Zero and negative values"

single-element: [1]
sort single-element
assert-equal [1] single-element "Single element"

;;---------------------------------------------------------------------------
;; Group 9: Combined Refinements (Hypothesis: Refinements combine predictably)
;;---------------------------------------------------------------------------
print "^/=== Group 9: Combined Refinements ==="

combined-data: [30 99 10 55 20 88]
sort/skip/reverse/part combined-data 2 6
assert-equal [30 99 20 88 10 55] combined-data "Combined /skip /reverse /part"

;;--------------------------------
;; Final Test Summary
;;--------------------------------
print-test-summary
