Rebol [
    Title: "Diagnostic Probe Script for the SWAP function"
    Purpose: "Robust behavioral analysis of SWAP in Rebol 3 Oldes"
    Author: "Kimi K2 AI"
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

;;---------------------------------------------------
;; Diagnostic Probe: SWAP function
;;---------------------------------------------------
print "^/=== SWAP Diagnostic Probe ===^/"
print "Testing SWAP behavior across all argument types and edge cases^/"

;;---------------------------------------------------
;; Probing Basic Series Swapping
;; Hypothesis: SWAP exchanges only the *current* element at each series position
;;---------------------------------------------------
print "^/--- Basic Series Swapping ---"

;; Test 1: Simple block swap – single element at head
test-block-1: [1 2 3]
test-block-2: [a b c]
swap test-block-1 test-block-2
assert-equal [a 2 3] test-block-1 "Swapping two blocks – only first element swapped"
assert-equal [1 b c] test-block-2 "Swapping two blocks – only first element swapped"

;; Test 2: String swapping – single character at head
test-string-1: "hello"
test-string-2: "world"
swap test-string-1 test-string-2
assert-equal "wello" test-string-1 "Swapping two strings – only first character swapped"
assert-equal "horld" test-string-2 "Swapping two strings – only first character swapped"

;; Test 3: Binary swapping – single byte at head
test-binary-1: #{010203}
test-binary-2: #{AABBCC}
swap test-binary-1 test-binary-2
assert-equal #{AA0203} test-binary-1 "Swapping two binaries – only first byte swapped"
assert-equal #{01BBCC} test-binary-2 "Swapping two binaries – only first byte swapped"

;;---------------------------------------------------
;; Probing GOB! Type Exclusion
;; Hypothesis: SWAP does NOT accept gob! values (confirmed by REPL error)
;;---------------------------------------------------
print "^/--- GOB! Type Exclusion ---"

;; Test 4: Verify GOB! is rejected
attempt-gob-swap: does [
    error? try [
        gob-one: make gob! [size: 100x100]
        gob-two: make gob! [size: 200x200]
        swap gob-one gob-two
    ]
]
assert-equal true attempt-gob-swap "SWAP rejects gob! values with error"

;;---------------------------------------------------
;; Probing Same-Series Swapping
;; Hypothesis: SWAP swaps single elements between positions in same series
;;---------------------------------------------------
print "^/--- Same-Series Swapping ---"

;; Test 5: Swap within same block – adjacent elements
same-block: [1 2 3 4 5]
swap same-block next same-block
assert-equal [2 1 3 4 5] same-block "Swapping within same block – adjacent elements 0 and 1"

;; Test 6: Swap within same string – adjacent characters
same-string: "abcde"
swap same-string next same-string
assert-equal "bacde" same-string "Swapping within same string – adjacent characters 0 and 1"

;; Test 7: Swap non-adjacent positions in same series
same-block-2: [1 2 3 4 5]
pos-a: at same-block-2 2
pos-b: at same-block-2 4
swap pos-a pos-b
assert-equal [1 4 3 2 5] same-block-2 "Swapping non-adjacent positions (1-based indices 2 and 4)"

;;---------------------------------------------------
;; Probing Empty Series Edge Cases
;; Hypothesis: SWAP with empty series is safe but swaps nothing
;;---------------------------------------------------
print "^/--- Empty Series Edge Cases ---"

;; Test 8: Swap with empty block
empty-block: []
non-empty-block: [1 2 3]
swap empty-block non-empty-block
assert-equal [] empty-block "Swapping with empty block – empty remains empty"
assert-equal [1 2 3] non-empty-block "Swapping with empty block – non-empty unchanged"

;; Test 9: Swap two empty series
empty-1: []
empty-2: []
swap empty-1 empty-2
assert-equal [] empty-1 "Swapping two empty blocks – both remain empty"
assert-equal [] empty-2 "Swapping two empty blocks – both remain empty"

;;---------------------------------------------------
;; Probing Single-Element Series
;; Hypothesis: SWAP works with single-element series but swaps the only element
;;---------------------------------------------------
print "^/--- Single-Element Series ---"

;; Test 10: Single-element blocks
single-a: [42]
single-b: [99]
swap single-a single-b
assert-equal [99] single-a "Swapping single-element blocks"
assert-equal [42] single-b "Swapping single-element blocks"

;; Test 11: Single-character strings
char-a: "X"
char-b: "Y"
swap char-a char-b
assert-equal "Y" char-a "Swapping single-character strings"
assert-equal "X" char-b "Swapping single-character strings"

;;---------------------------------------------------
;; Probing Position Independence
;; Hypothesis: SWAP always swaps the single element at the current index
;;---------------------------------------------------
print "^/--- Position Independence ---"

;; Test 12: Swap from different positions
pos-block-1: skip [a b c d] 1  ; at 'b'
pos-block-2: skip [x y z] 2     ; at 'z'
swap pos-block-1 pos-block-2
assert-equal [a z c d] head pos-block-1 "Swapping from offset positions – single element swap"
assert-equal [x y b] head pos-block-2 "Swapping from offset positions – single element swap"

;; Test 13: Swap head with last element in 4-element block
tail-block: [1 2 3 4]
swap tail-block back tail tail-block
assert-equal [4 2 3 1] head tail-block "Swapping head with last element in 4-element block"

;;---------------------------------------------------
;; Probing Type Restrictions
;; Hypothesis: SWAP only accepts series! values
;;---------------------------------------------------
print "^/--- Type Restrictions ---"

;; Test 14: Attempt swap with non-series types
attempt-swap-with-integer: does [
    error? try [
        swap 123 456
    ]
]
assert-equal true attempt-swap-with-integer "SWAP rejects integer values with error"

;; Test 15: Attempt swap with none
attempt-swap-with-none: does [
    error? try [
        swap none none
    ]
]
assert-equal true attempt-swap-with-none "SWAP rejects none values with error"

;;---------------------------------------------------
;; Probing Large Series Performance
;; Hypothesis: SWAP is O(1) – always swaps single element regardless of size
;;---------------------------------------------------
print "^/--- Large Series Handling ---"

;; Test 16: Large block swap – only head element affected
large-block-a: append/dup [] 1 10000
large-block-b: append/dup [] 2 10000
original-head-a: first large-block-a
original-head-b: first large-block-b
swap large-block-a large-block-b
assert-equal original-head-b first large-block-a "Large block swap – only head element swapped"
assert-equal original-head-a first large-block-b "Large block swap – only head element swapped"

;;---------------------------------------------------
;; Probing Nested Structure Swapping
;; Hypothesis: SWAP can swap whole sub-blocks when given series positions
;;---------------------------------------------------
print "^/--- Nested Structure Swapping ---"

;; Test 17: Swap entire sub-blocks (series references)
nested-a: [[1 2] [3 4]]
nested-b: [[a b] [c d]]
swap at nested-a 2 at nested-b 2
assert-equal [[1 2] [c d]] nested-a "Swapping sub-blocks – entire series reference swap"
assert-equal [[a b] [3 4]] nested-b "Swapping sub-blocks – entire series reference swap"

;;---------------------------------------------------
;; Probing Series with Different Lengths
;; Hypothesis: SWAP swaps single element regardless of series length
;;---------------------------------------------------
print "^/--- Different Length Series ---"

;; Test 18: Swap between different length series – single element
short-block: [1]
long-block: [a b c d e f g]
original-short: first short-block
original-long-head: first long-block
swap short-block long-block
assert-equal original-long-head short-block/1 "Swapping different lengths – single element swap"
assert-equal original-short long-block/1 "Swapping different lengths – single element swap"

;;---------------------------------------------------
;; Final Summary
;;---------------------------------------------------
print-test-summary
