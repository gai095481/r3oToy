Rebol [
    Title: "FINAL FIXED CHANGE Function Diagnostic Probe Script"
    Date: 9-Jul-2025
    Author: "Claude 4 Sonnet fixed by Lutra AI"
    Purpose: "Diagnostic tests for CHANGE function"
]

;;-----------------------------------------------------------------------------
;; Battle-Tested QA Harness Helper Functions
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
            description
            "^/ >> Expected: " mold expected
            "^/ >> Actual: " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL TEST CASE EXAMPLES PASSED."
    ][
        print "❌ SOME TEST CASE EXAMPLES FAILED."
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; CHANGE Function Diagnostic Probe Script
;;-----------------------------------------------------------------------------
print "^/=== DIAGNOSTIC PROBE: CHANGE FUNCTION ==="

;;-----------------------------------------------------------------------------
;; SECTION 1: Basic CHANGE with Block! Series
;;-----------------------------------------------------------------------------
print "^/--- SECTION 1: Basic CHANGE with Block! Series ---"

; Test basic change behavior
test-block1: [a b c]
pos1: change test-block1 'X
assert-equal [X b c] test-block1 "Block modified correctly after basic change"
assert-equal [b c] pos1 "Change returns position just past the change"

; Test change at middle position
test-block2: [a b c d]
pos2: change next test-block2 'Y
assert-equal [a Y c d] test-block2 "Change works at middle position"
assert-equal [c d] pos2 "Change returns correct position from middle"

; Test change at tail - CORRECTED: CHANGE at tail DOES modify by appending
test-block3: [a b c]
pos3: change tail test-block3 'Z
assert-equal [a b c Z] test-block3 "Change at tail appends to the series"
assert-equal [] pos3 "Change at tail returns empty series"

;;-----------------------------------------------------------------------------
;; SECTION 2: CHANGE with String! Series
;;-----------------------------------------------------------------------------
print "^/--- SECTION 2: CHANGE with String! Series ---"

test-string1: "abc"
pos4: change test-string1 "X"
assert-equal "Xbc" test-string1 "String modified correctly after basic change"
assert-equal "bc" pos4 "Change returns position just past change in string"

test-string2: "hello"
pos5: change test-string2 "H"
assert-equal "Hello" test-string2 "Single character replacement works"
assert-equal "ello" pos5 "Character change returns correct position"

test-string3: "abcdef"
pos6: change at test-string3 3 "X"
assert-equal "abXdef" test-string3 "Change works at string middle position"
assert-equal "def" pos6 "String change returns correct position from middle"

;;-----------------------------------------------------------------------------
;; SECTION 3: CHANGE with Different Value Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 3: CHANGE with Different Value Types ---"

test-block4: [x y z]
change test-block4 42
assert-equal [42 y z] test-block4 "Change accepts integer values"

test-block5: [x y z]
change test-block5 true
; CORRECTED: Logic values display as #(true) in Rebol 3
assert-equal [#(true) y z] test-block5 "Change accepts logic! values (displays as #(true))"

test-block6: [x q r]
change test-block6 none
; CORRECTED: None values display as #(none) in Rebol 3
assert-equal [#(none) q r] test-block6 "Change accepts none! values (displays as #(none))"

test-block7: [1 2 3]
change test-block7 [a b]
; CORRECTED: Without /only, block contents are expanded
assert-equal [a b 3] test-block7 "Change without /only expands block contents"

;;-----------------------------------------------------------------------------
;; SECTION 4: Probing /part Refinement
;;-----------------------------------------------------------------------------
print "^/--- SECTION 4: Probing /part Refinement ---"

test-block8: [a b c d e]
pos7: change/part test-block8 [X Y] 2
assert-equal [X Y c d e] test-block8 "Part refinement with number changes specified count"
assert-equal [c d e] pos7 "Part change returns correct position"

test-block9: [a b c]
pos8: change/part test-block9 [X Y Z W] 3
; CORRECTED: CHANGE/part doesn't respect series boundaries for replacement
assert-equal [X Y Z W] test-block9 "Part refinement can extend series beyond boundaries"

test-block10: [a b c d]
pos9: change/part at test-block10 2 [X Y] at test-block10 4
assert-equal [a X Y d] test-block10 "Part refinement with series position works"

test-block11: [a b c d]
pos10: change/part test-block11 [X Y] 0
; CORRECTED: CHANGE/part with 0 still performs the change
assert-equal [X Y a b c d] test-block11 "Part refinement with zero still changes"
assert-equal [a b c d] pos10 "Part with zero returns position after insertion"

;;-----------------------------------------------------------------------------
;; SECTION 5: Probing /only Refinement
;;-----------------------------------------------------------------------------
print "^/--- SECTION 5: Probing /only Refinement ---"

test-block12: [a b c]
change/only test-block12 [X Y]
assert-equal [[X Y] b c] test-block12 "Only refinement treats block as single value"

test-block13: ["a" "b" "c"]
change/only test-block13 "XY"
assert-equal ["XY" "b" "c"] test-block13 "Only refinement works with strings"

test-block14: [a b c]
change test-block14 [X Y]
assert-equal [X Y c] test-block14 "Without /only, block contents are expanded"

;;-----------------------------------------------------------------------------
;; SECTION 6: Probing /dup Refinement
;;-----------------------------------------------------------------------------
print "^/--- SECTION 6: Probing /dup Refinement ---"

test-block15: [a b c d e]
change/dup test-block15 'X 3
assert-equal [X X X d e] test-block15 "Dup refinement duplicates value correctly"

test-block16: [a b c]
change/dup test-block16 'Y 1
assert-equal [Y b c] test-block16 "Dup refinement with count 1 works normally"

test-block17: [a b c d]
pos11: change/dup test-block17 'Z 0
assert-equal [a b c d] test-block17 "Dup refinement with count 0 changes nothing"
assert-equal [a b c d] pos11 "Dup with count 0 returns original position"

test-block18: [a b c d]
change/dup/only test-block18 [X Y] 2
assert-equal [[X Y] [X Y] c d] test-block18 "Dup with /only duplicates blocks correctly"

;;-----------------------------------------------------------------------------
;; SECTION 7: Probing Combined Refinements - CORRECTED
;;-----------------------------------------------------------------------------
print "^/--- SECTION 7: Probing Combined Refinements ---"

test-block19: [a b c d e f]
change/part/dup test-block19 'X 2 3
; CORRECTED: /part 2 limits replacement to 2 elements, /dup 3 creates 3 X's but /part overrides
assert-equal [X X X c d e f] test-block19 "Part and dup refinements work together - dup count takes precedence"

test-block20: [a b c d e]
change/part/dup/only test-block20 [Y Z] 1 2
; CORRECTED: /part 1 replaces 1 element, /dup 2 creates 2 copies, /only keeps blocks intact
assert-equal [[Y Z] [Y Z] b c d e] test-block20 "Part, dup, and only refinements work together"

;;-----------------------------------------------------------------------------
;; SECTION 8: Probing Edge Cases
;;-----------------------------------------------------------------------------
print "^/--- SECTION 8: Probing Edge Cases ---"

test-empty: []
pos12: change test-empty 'X
; CORRECTED: CHANGE on empty series DOES modify it
assert-equal [X] test-empty "Change on empty block modifies it by appending"
assert-equal [] pos12 "Change on empty block returns empty series"

test-single: [a]
pos13: change test-single 'X
assert-equal [X] test-single "Change works on single-element block"
assert-equal [] pos13 "Change on single-element returns empty series"

test-dup-large: [a b c d e f g h i j]
change/dup test-dup-large 'X 100
; CORRECTED: CHANGE/dup creates exact count without boundary limits
expected-large: []
loop 100 [append expected-large 'X]
assert-equal expected-large test-dup-large "Large dup count creates exact duplications"

;;-----------------------------------------------------------------------------
;; SECTION 9: Different Series Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 9: Different Series Types ---"

test-binary: #{010203}
change test-binary #{FF}
assert-equal #{FF0203} test-binary "Change works with binary! series"

; Test vector series if available
if find system/catalog/datatypes 'vector! [
    test-vector: make vector! [1 2 3 4]
    change test-vector 99
    assert-equal make vector! [99 2 3 4] test-vector "Change works with vector! series"
][
    print "ℹ️  INFO: Vector! series not available or not supported in this build"
]

;;-----------------------------------------------------------------------------
;; SECTION 10: Return Value Verification
;;-----------------------------------------------------------------------------
print "^/--- SECTION 10: Return Value Verification ---"

test-return1: [a b c d]
result1: change test-return1 'X
assert-equal series? result1 true "Change always returns a series"
assert-equal none? result1 false "Change never returns none"
assert-equal type? result1 type? test-return1 "Change returns same series type as input"

test-return2: [a b c d]
result2: change next test-return2 'Y
assert-equal [c d] result2 "Returned position is correctly positioned"
assert-equal [a Y c d] test-return2 "Original series was modified correctly"

;;-----------------------------------------------------------------------------
;; Final Test Summary
;;-----------------------------------------------------------------------------
print-test-summary

;;-----------------------------------------------------------------------------
;; CHANGE Function Behavior Summary
;;-----------------------------------------------------------------------------
print "^/📝 CHANGE Function Behavior Summary:"
print "====================================="
print "1. CHANGE modifies the series at the current position"
print "2. CHANGE returns the position just past the change"
print "3. CHANGE at tail position appends to the series"
print "4. CHANGE without /only expands block contents"
print "5. CHANGE/only treats blocks as single values"
print "6. CHANGE/part can extend series beyond original boundaries"
print "7. CHANGE/dup creates exact number of duplications"
print "8. CHANGE/part with 0 still performs the change operation"
print "9. CHANGE on empty series modifies it by appending"
print "10. Logic/none values display as #(true)/#(none) in Rebol 3"
print "11. CHANGE/part/dup: /dup count takes precedence over /part limit"
print "12. Combined refinements work together as expected"
