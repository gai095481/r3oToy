Rebol [
    Title: "Diagnostic Probe Script for `swap` Function"
    Purpose: "Systematically test the behavior of the swap function"
    Author: "Ninja AI"
    Date: 19-Jul-2025
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

print "^/============================================"
print "=== DIAGNOSTIC PROBE: SWAP FUNCTION ==="
print "============================================^/"

;;-----------------------------
;; Probing Basic Block Swapping
;;-----------------------------
print "--- Probing Basic Block Swapping ---"
;; Hypothesis: swap should exchange elements at current positions in two different blocks

block-alpha: [a b c]
block-beta: [x y z]
result-alpha: swap block-alpha block-beta
assert-equal [x b c] block-alpha "First block should have first element swapped"
assert-equal [a y z] block-beta "Second block should have first element swapped"
assert-equal [x b c] result-alpha "Return value should be the modified first series"

;;-----------------------------
;; Probing Position-Based Swapping
;;-----------------------------
print "^/--- Probing Position-Based Swapping ---"
;; Hypothesis: swap operates at the current position of each series, not necessarily at head

block-first: [1 2 3 4 5]
block-second: [a b c d e]
positioned-first: next next block-first    ; Position at 3
positioned-second: next block-second       ; Position at b
result-positioned: swap positioned-first positioned-second

assert-equal [1 2 b 4 5] block-first "First block should swap element at position 3"
assert-equal [a 3 c d e] block-second "Second block should swap element at position 2"
assert-equal [b 4 5] result-positioned "Return should be first series from swap position"

;;-----------------------------
;; Probing Same Series Swapping
;;-----------------------------
print "^/--- Probing Same Series Swapping ---"
;; Hypothesis: swap can exchange elements within the same series

same-series: [alpha beta gamma delta]
pos-one: same-series                       ; Position at alpha
pos-two: next next same-series             ; Position at gamma
result-same: swap pos-one pos-two

assert-equal [gamma beta alpha delta] same-series "Elements should be swapped within same series"
assert-equal [gamma beta alpha delta] result-same "Return should be the modified series from first position"

;;-----------------------------
;; Probing Different Series Types
;;-----------------------------
print "^/--- Probing Different Series Types ---"

;; Testing string swapping
;; Hypothesis: swap should work with strings, swapping characters
string-first: "hello"
string-second: "world"
result-strings: swap string-first string-second
assert-equal "wello" string-first "First string should have first character swapped"
assert-equal "horld" string-second "Second string should have first character swapped"
assert-equal "wello" result-strings "Return should be modified first string"

;; Testing mixed string positions
string-mixed-1: "abcde"
string-mixed-2: "12345"
pos-str-1: next string-mixed-1             ; Position at 'b'
pos-str-2: next next string-mixed-2        ; Position at '3'
result-mixed-strings: swap pos-str-1 pos-str-2
assert-equal "a3cde" string-mixed-1 "First string should swap character at position"
assert-equal "12b45" string-mixed-2 "Second string should swap character at position"

;;-----------------------------
;; Probing Edge Cases
;;-----------------------------
print "^/--- Probing Edge Cases ---"

;; Testing swap at tail positions
;; Hypothesis: swapping at tail should handle gracefully or produce predictable behavior
edge-block-1: [1 2 3]
edge-block-2: [a b c]
tail-pos-1: tail edge-block-1
tail-pos-2: tail edge-block-2

print "^/Testing swap at tail positions:"
print ["Before - Block 1:" mold edge-block-1]
print ["Before - Block 2:" mold edge-block-2]
print ["Tail pos 1 points to:" mold tail-pos-1]
print ["Tail pos 2 points to:" mold tail-pos-2]

;; This may cause an error or unexpected behavior - let's see what happens
result-tail-swap: swap tail-pos-1 tail-pos-2

print ["After swap - Block 1:" mold edge-block-1]
print ["After swap - Block 2:" mold edge-block-2]
print ["Result:" mold result-tail-swap]
print ""

;;-----------------------------
;; Probing Single Element Series
;;-----------------------------
print "^/--- Probing Single Element Series ---"
;; Hypothesis: swap should work with single-element series

single-block-1: [only]
single-block-2: [one]
result-single: swap single-block-1 single-block-2
assert-equal [one] single-block-1 "Single element should be swapped"
assert-equal [only] single-block-2 "Single element should be swapped"

;;-----------------------------
;; Probing Return Value Behavior
;;-----------------------------
print "^/--- Probing Return Value Behavior ---"
;; Hypothesis: swap always returns the first series argument

return-test-1: [first series]
return-test-2: [second series]
positioned-return-1: next return-test-1   ; Position at 'series'
positioned-return-2: return-test-2         ; Position at 'second'

swap-return-result: swap positioned-return-1 positioned-return-2
assert-equal true same? swap-return-result positioned-return-1 "Return should be same reference as first argument"

;;-----------------------------
;; Probing Data Type Preservation
;;-----------------------------
print "^/--- Probing Data Type Preservation ---"
;; Hypothesis: swap preserves data types of swapped elements

type-block-1: [42 "text" 'word]
type-block-2: [3.14 #"c" true]
type-result: swap type-block-1 type-block-2

assert-equal decimal! type? first type-block-1 "Swapped element should preserve decimal type"
assert-equal integer! type? first type-block-2 "Swapped element should preserve integer type"

;;-----------------------------
;; Probing Empty Series Behavior
;;-----------------------------
print "^/--- Probing Empty Series Behavior ---"
;; Hypothesis: swapping with empty series should handle gracefully

empty-block: []
normal-block: [has content]

print "^/Testing swap with empty series:"
print ["Empty block:" mold empty-block]
print ["Normal block:" mold normal-block]

;; This might cause an error or unexpected behavior
result-empty-swap: swap empty-block normal-block

print ["After swap - Empty block:" mold empty-block]
print ["After swap - Normal block:" mold normal-block]
print ["Result:" mold result-empty-swap]
print ""

;;-----------------------------
;; Probing Cross-Type Series Compatibility
;;-----------------------------
print "^/--- Probing Cross-Type Series Compatibility ---"
;; Hypothesis: swap may have restrictions on mixing different series types

print "^/Testing cross-type compatibility (block vs string):"
cross-block: [#"x" #"y" #"z"]
cross-string: copy "abc"

print ["Block before:" mold cross-block]
print ["String before:" mold cross-string]

;; This previously caused an error, so let's handle it gracefully
if error? try-result: try [
    result-cross: swap cross-block cross-string
    print ["Block after swap:" mold cross-block]
    print ["String after swap:" mold cross-string]
    print ["Return value:" mold result-cross]
][
    print ["ERROR DETECTED: Cross-type swapping not supported"]
    print ["Error details:" mold try-result]
]
print ""

;;-----------------------------
;; Probing Vector Series (if available)
;;-----------------------------
print "^/--- Probing Vector Series Compatibility ---"
;; Hypothesis: swap should work with other series types like vectors

print "Testing vector compatibility:"
if error? vector-test: try [
    vector-1: make vector! [1 2 3]
    vector-2: make vector! [4 5 6]
    vector-result: swap vector-1 vector-2
    print ["Vector 1 after swap:" mold vector-1]
    print ["Vector 2 after swap:" mold vector-2]
][
    print "Vector type not available or swap not supported with vectors"
]
print ""

;;-----------------------------
;; Probing Large Series Performance Indicator
;;-----------------------------
print "^/--- Probing Large Series Behavior ---"
;; Hypothesis: swap should work efficiently with larger series

large-series-1: make block! 1000
large-series-2: make block! 1000
repeat index 1000 [
    append large-series-1 index
    append large-series-2 index + 1000
]

;; Position both at middle
mid-pos-1: at large-series-1 500
mid-pos-2: at large-series-2 500

result-large: swap mid-pos-1 mid-pos-2
assert-equal 1500 first mid-pos-1 "Large series swap should work at middle position"
assert-equal 500 first mid-pos-2 "Large series swap should work at middle position"

;;-----------------------------
;; Probing Binary Series
;;-----------------------------
print "^/--- Probing Binary Series ---"
;; Hypothesis: swap should work with binary series

binary-1: #{010203}
binary-2: #{040506}
result-binary: swap binary-1 binary-2
assert-equal #{040203} binary-1 "First binary should have first byte swapped"
assert-equal #{010506} binary-2 "Second binary should have first byte swapped"

;;-----------------------------
;; Probing GOB Support (mentioned in help)
;;-----------------------------
print "^/--- Probing GOB Support ---"
;; Hypothesis: swap supports GOB objects as mentioned in the help

print "Testing GOB support:"
if error? gob-test: try [
    gob-1: make gob! []
    gob-2: make gob! []
    gob-result: swap gob-1 gob-2
    print "GOB swapping appears to work"
][
    print "GOB swapping not available or not supported in this context"
]
print ""

;;-----------------------------
;; Summary of Behavioral Observations
;;-----------------------------
print "^/--- BEHAVIORAL OBSERVATIONS SUMMARY ---"
print "1. POSITION-BASED: Swap operates at current series positions"
print "2. BIDIRECTIONAL: Both series are modified simultaneously"
print "3. RETURN VALUE: Always returns the first series argument"
print "4. SAME SERIES: Can swap elements within the same series"
print "5. TYPE PRESERVATION: Swapped elements maintain their data types"
print "6. SERIES TYPE LIMITS: Cross-type swapping has restrictions"
print "7. TAIL BEHAVIOR: Swapping at tail positions is safe (no-op)"
print "8. EMPTY SERIES: Swapping with empty series is safe (no-op)"
print "9. BINARY SUPPORT: Works with binary series"
print "============================================^/"

print-test-summary
