Rebol [
    Title: "Diagnostic Probe for SWAP Function"
    Version: 0.1.0
    Author: "DeepSeek R1"
    Purpose: {Systematically probe the behavior of the SWAP function in Rebol 3 Oldes.}
]

;;------------------------------
;; Battle-Tested QA Test Harness
;;------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected/correct value."
    actual [any-type!] "The actual value."
    description [string!] "Description of the specific test."
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
        print "❌ SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;===================================
;; DIAGNOSTIC PROBE FOR SWAP FUNCTION
;;===================================
print "*** Starting SWAP Probe Diagnostics ***^/"

;;---------------------------------------------------------------------------
;; Group 1: Basic Behavior - Swapping Between Two Different Series
;; Hypothesis: SWAP will exchange elements at current positions of two distinct
;; series of the same type without affecting surrounding elements.
;;---------------------------------------------------------------------------
print "=== Probing Basic Behavior (Different Series) ==="

;; Test 1.1: String swapping
str1: "abc"
str2: "123"
swap next str1 next str2  ; Swap 'b' and '2'
assert-equal "a2c" head str1 "Swap strings: str1 modified"
assert-equal "1b3" head str2 "Swap strings: str2 modified"
assert-equal #"2" first next str1 "Swap strings: str1 current position"
assert-equal #"b" first next str2 "Swap strings: str2 current position"

;; Test 1.2: Block swapping
blk1: [a b c]
blk2: [1 2 3]
swap next blk1 next blk2  ; Swap 'b' and 2
assert-equal [a 2 c] head blk1 "Swap blocks: blk1 modified"
assert-equal [1 b 3] head blk2 "Swap blocks: blk2 modified"
assert-equal 2 first next blk1 "Swap blocks: blk1 current position"
assert-equal 'b first next blk2 "Swap blocks: blk2 current position"

;; Test 1.3: Same series type with different element types
blk3: ['word]
blk4: [123]
swap blk3 blk4
assert-equal [123] head blk3 "Block swap: word replaced with integer"
assert-equal ['word] head blk4 "Block swap: integer replaced with word"

;;----------------------------------------------------------------------
;; Group 2: Same Series Swapping
;; Hypothesis: SWAP will correctly exchange elements at different positions
;; within the same series without altering other elements.
;;----------------------------------------------------------------------
print "^/=== Probing Same Series Behavior ==="

;; Test 2.1: Adjacent elements in block
blk: [a b c]
swap blk next blk  ; Swap 'a' and 'b'
assert-equal [b a c] head blk "Same series: adjacent swap"
assert-equal 'b first blk "Same series: position1 after swap"
assert-equal 'a first next blk "Same series: position2 after swap"

;; Test 2.2: Non-adjacent elements in string
str: "abcd"
swap str skip str 2  ; Swap 'a' and 'c'
assert-equal "cbad" head str "Same series: non-adjacent swap"

;; Test 2.3: Swapping identical position
str4: "test"
swap str4 str4
assert-equal "test" head str4 "Same series: identical position (no change)"

;;-----------------------------------------------------------------------
;; Group 3: Edge Cases - Empty and Boundary Conditions (Final)
;; Hypothesis: SWAP will perform no operation when either series is at tail
;; position, maintaining original series content.
;;-----------------------------------------------------------------------
print "^/=== Probing Edge Cases (Final) ==="

;; Test 3.1: Empty series - no operation
empty1: make string! 0
empty2: copy ""
swap empty1 empty2
assert-equal "" head empty1 "Empty series: empty1 remains empty"
assert-equal "" head empty2 "Empty series: empty2 remains empty"

;; Test 3.2: Tail position with head position
str5: "foo"
str6: "bar"
swap tail str5 str6  ; Tail position with head position
assert-equal "foo" head str5 "Tail position: str5 unchanged"
assert-equal "bar" head str6 "Tail position: str6 unchanged"

;; Test 3.3: Both tails - no operation
str7: "abc"
str8: "def"
swap tail str7 tail str8
assert-equal "abc" head str7 "Both tails: str7 unchanged"
assert-equal "def" head str8 "Both tails: str8 unchanged"

;; Test 3.4: Tail position with valid position
short: "a"
long: "xyz"
swap next short long  ; Tail of short with head of long
assert-equal "a" head short "Short series: unchanged"
assert-equal "xyz" head long "Long series: unchanged"

;;-----------------------------------------------------------------------
;; Group 4: Type Handling and Errors
;; Hypothesis: SWAP requires series! of same type and will fail with
;; incompatible series types or non-series arguments.
;;-----------------------------------------------------------------------
print "^/=== Probing Type Handling ==="

;; Test 4.1: Non-series arguments
err: try [swap 10 20]
assert-equal true error? err "Non-series: integer arguments"

;; Test 4.2: Mixed series types
str9: "abc"
blk5: [1 2 3]
err: try [swap str9 blk5]
assert-equal true error? err "Mixed series types: string and block"

;; Test 4.3: GOB! placeholder test (gob! not available in headless environment)
;; This test is for documentation only - remove comment if gob! exists
comment {
    gob-test: make gob! [size: 0x0]
    err: try [swap gob-test gob-test]
    assert-equal true error? err "GOB! type not supported in this context"
}

;;----------------------------
;; Print Final Test Summary
;;----------------------------
print-test-summary
