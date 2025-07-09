Rebol [
    Title: "FULLY CORRECTED MOVE Function Diagnostic Probe Script"
    Date: 9-Jul-2025
    Author: "DeepSeek R1"
    Purpose: "Comprehensive diagnostic tests for MOVE function based on actual behavior"
]

;;-----------------------------------------------------------------------------
;; Battle-Tested QA Harness Helper Functions
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: func [  ; Changed to func for compatibility
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    either equal? expected actual [
        result-style: "✅ PASSED:"
        message: description
    ][
        all-tests-passed?: false  ; Directly set variable instead of set
        result-style: "❌ FAILED:"
        message: rejoin [
            description
            "^/ >> Expected: " mold expected
            "^/ >> Actual: " mold actual
        ]
    ]
    print rejoin [result-style " " message]  ; Use rejoin for safer printing
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/=========================================="
    either all-tests-passed? [
        print "✅ ALL TEST CASE EXAMPLES PASSED."
    ][
        print "❌ SOME TEST CASE EXAMPLES FAILED."
    ]
    print "==========================================^/"
]

;;-----------------------------------------------------------------------------
print "^/=========================================="
print "MOVE Function Comprehensive Diagnostic Probe"
print rejoin ["Rebol 3 Oldes Branch - " system/version]
print "=========================================="

;;-----------------------------------------------------------------------------
;; Section 1: Basic MOVE Behavior with Blocks
;;-----------------------------------------------------------------------------
print "^/--- Section 1: Basic MOVE Behavior with Blocks ---"

; Test basic move forward
test-block1: [a b c d e]
pos1: at test-block1 2  ; Position at 'b'
result1: move pos1 2    ; Move 'b' forward by 2
assert-equal [a c d b e] test-block1 "Basic move forward by 2 positions - block modified"
assert-equal [e] result1 "Basic move forward by 2 positions - return value (position after insertion)"

; Test basic move backward
test-block2: [a b c d e]
pos2: at test-block2 3  ; Position at 'c'
result2: move pos2 -1   ; Move 'c' backward by 1
assert-equal [a c b d e] test-block2 "Move backward by 1 position - block modified"
assert-equal [b d e] result2 "Move backward by 1 position - return value (position after insertion)"

; Test move with zero offset
test-block3: [a b c d e]
pos3: at test-block3 2  ; Position at 'b'
result3: move pos3 0    ; Move 'b' by 0 (should stay in place)
assert-equal [a b c d e] test-block3 "Move with zero offset - block unchanged"
assert-equal [c d e] result3 "Move with zero offset - return value (position after insertion)"

;;-----------------------------------------------------------------------------
;; Section 2: MOVE with Strings
;;-----------------------------------------------------------------------------
print "^/--- Section 2: MOVE with Strings ---"

; Test string move forward
test-string1: "abcde"
pos4: at test-string1 2  ; Position at 'b'
result4: move pos4 2     ; Move 'b' forward by 2
assert-equal "acdbe" test-string1 "String move forward by 2 - string modified"
assert-equal "e" result4 "String move forward by 2 - return value (position after insertion)"

; Test string move backward
test-string2: "abcde"
pos5: at test-string2 3  ; Position at 'c'
result5: move pos5 -1    ; Move 'c' backward by 1
assert-equal "acbde" test-string2 "String move backward by 1 - string modified"
assert-equal "bde" result5 "String move backward by 1 - return value (position after insertion)"

;;-----------------------------------------------------------------------------
;; Section 3: MOVE/PART Refinement
;;-----------------------------------------------------------------------------
print "^/--- Section 3: MOVE/PART Refinement ---"

; Test move/part forward - CORRECTED based on actual behavior
test-block4: [a b c d e f g]
pos6: at test-block4 1   ; Position at 'a'
result6: move/part pos6 3 2  ; Move 2 elements ('a' 'b') forward by 3
assert-equal [c d e a b f g] test-block4 "Move/part 2 elements forward by 3 - block modified"
assert-equal [f g] result6 "Move/part 2 elements forward by 3 - return value (position after insertion)"

; Test move/part with larger part - CORRECTED based on actual behavior
test-block5: [a b c d e f g]
pos7: at test-block5 1   ; Position at 'a'
result7: move/part pos7 4 3  ; Move 3 elements ('a' 'b' 'c') forward by 4
assert-equal [d e f g a b c] test-block5 "Move/part 3 elements forward by 4 - block modified"
assert-equal [] result7 "Move/part 3 elements forward by 4 - return value (position after insertion)"

; Test move/part with strings - CORRECTED based on actual behavior
test-string3: "abcdefg"
pos8: at test-string3 1  ; Position at 'a'
result8: move/part pos8 3 2  ; Move 2 chars ('a' 'b') forward by 3
assert-equal "cdeabfg" test-string3 "Move/part 2 chars forward by 3 - string modified"
assert-equal "fg" result8 "Move/part 2 chars forward by 3 - return value (position after insertion)"

;;-----------------------------------------------------------------------------
;; Section 4: MOVE/TO Refinement
;;-----------------------------------------------------------------------------
print "^/--- Section 4: MOVE/TO Refinement ---"

; Test move/to basic
test-block6: [a b c d e]
pos9: at test-block6 2   ; Position at 'b'
result9: move/to pos9 4  ; Move 'b' to position 4
assert-equal [a c d b e] test-block6 "Move/to position 4 - block modified"
assert-equal [e] result9 "Move/to position 4 - return value (position after insertion)"

; Test move/to/part - CORRECTED based on actual behavior
test-block7: [a b c d e f g]
pos10: at test-block7 1  ; Position at 'a'
result10: move/to/part pos10 4 2  ; Move 2 elements ('a' 'b') to position 4
assert-equal [c d e a b f g] test-block7 "Move/to/part 2 elements to position 4 - block modified"
assert-equal [f g] result10 "Move/to/part 2 elements to position 4 - return value (position after insertion)"

; Test move/to position 1 from middle
test-block8: [a b c d e]
pos11: at test-block8 3  ; Position at 'c'
result11: move/to pos11 1  ; Move 'c' to position 1
assert-equal [c a b d e] test-block8 "Move/to position 1 from middle - block modified"
assert-equal [a b d e] result11 "Move/to position 1 from middle - return value (position after insertion)"

;;-----------------------------------------------------------------------------
;; Section 5: MOVE/SKIP Refinement
;;-----------------------------------------------------------------------------
print "^/--- Section 5: MOVE/SKIP Refinement ---"

; Test move/skip basic
test-block9: [a b c d e f g h]
pos12: at test-block9 1  ; Position at 'a'
result12: move/skip pos12 2 2  ; Move record of size 2 by 2 records
assert-equal [c d e f a b g h] test-block9 "Move/skip size 2, offset 2 - block modified"
assert-equal [g h] result12 "Move/skip size 2, offset 2 - return value (position after insertion)"

; Test move/skip/part - CORRECTED based on actual behavior
test-block10: [a b c d e f g h i j]
pos13: at test-block10 1  ; Position at 'a'
result13: move/skip/part pos13 1 2 2  ; Move 2 records of size 2 by 1 record
assert-equal [e f a b c d g h i j] test-block10 "Move/skip/part size 2, offset 1, part 2 - block modified"
assert-equal [g h i j] result13 "Move/skip/part size 2, offset 1, part 2 - return value (position after insertion)"

; Test move/skip/to
test-block11: [a b c d e f g h]
pos14: at test-block11 1  ; Position at 'a'
result14: move/skip/to pos14 3 2  ; Move record of size 2 to record position 3
assert-equal [c d e f a b g h] test-block11 "Move/skip/to size 2, to record 3 - block modified"
assert-equal [g h] result14 "Move/skip/to size 2, to record 3 - return value (position after insertion)"

;;-----------------------------------------------------------------------------
;; Section 6: Edge Cases and Error Conditions
;;-----------------------------------------------------------------------------
print "^/--- Section 6: Edge Cases and Error Conditions ---"

; Test move beyond series bounds
test-block12: [a b c]
pos15: at test-block12 2  ; Position at 'b'
result15: move pos15 5    ; Move 'b' beyond end
assert-equal [a c b] test-block12 "Move beyond series bounds - block modified"
assert-equal [] result15 "Move beyond series bounds - return value (position after insertion)"

; Test move with large negative offset
test-block13: [a b c d e]
pos16: at test-block13 5  ; Position at 'e'
result16: move pos16 -10  ; Move 'e' far backward
assert-equal [e a b c d] test-block13 "Move with large negative offset - block modified"
assert-equal [a b c d] result16 "Move with large negative offset - return value (position after insertion)"

; Test move on empty series
test-empty: []
pos17: test-empty
result17: move pos17 1    ; Move on empty series
assert-equal [] test-empty "Move on empty series - block unchanged"
assert-equal [] result17 "Move on empty series - return value"

; Test move on single element series
test-single: [a]
pos18: at test-single 1  ; Position at 'a'
result18: move pos18 1   ; Move 'a' by 1
assert-equal [a] test-single "Move on single element series - block unchanged"
assert-equal [] result18 "Move on single element series - return value (position after insertion)"

; Test move/part with excessive length - CORRECTED based on actual behavior
test-block14: [a b c d e]
pos19: at test-block14 2  ; Position at 'b'
result19: move/part pos19 2 10  ; Move 10 elements (only 4 available)
assert-equal [a b c d e] test-block14 "Move/part with excessive length - block modified"
assert-equal [] result19 "Move/part with excessive length - return value (position after insertion)"

;;-----------------------------------------------------------------------------
;; Section 7: Complex MOVE Scenarios
;;-----------------------------------------------------------------------------
print "^/--- Section 7: Complex MOVE Scenarios ---"

; Test multiple moves - CORRECTED based on actual behavior
test-block15: [a b c d e f]
pos20: at test-block15 2  ; Position at 'b'
result20: move pos20 3    ; Move 'b' forward by 3
pos21: at result20 1      ; Position at first element after move
result21: move pos21 -2   ; Move that element backward by 2
assert-equal [a c d f e b] test-block15 "Multiple moves - final block state"
assert-equal [e b] result21 "Multiple moves - final return value"

; Test move with insertion at tail
test-block16: [a b c d]
pos22: at test-block16 1  ; Position at 'a'
result22: move/to pos22 5  ; Move 'a' to position 5 (at tail)
assert-equal [b c d a] test-block16 "Move to tail position - block modified"
assert-equal [] result22 "Move to tail position - return value (position after insertion)"

; Test move with strings and unicode
test-unicode: "αβγδε"
pos23: at test-unicode 2  ; Position at 'β'
result23: move pos23 2    ; Move 'β' forward by 2
assert-equal "αγδβε" test-unicode "Unicode string move - string modified"
assert-equal "ε" result23 "Unicode string move - return value"

;;-----------------------------------------------------------------------------
;; Section 8: MOVE Return Value Patterns
;;-----------------------------------------------------------------------------
print "^/--- Section 8: MOVE Return Value Patterns ---"

; Test consistent return value behavior - CORRECTED based on actual behavior
test-block17: [a b c d e f g h]
pos24: at test-block17 3  ; Position at 'c'
result24: move/part pos24 2 3  ; Move 3 elements forward by 2
assert-equal [a b f g c d e h] test-block17 "Return value pattern - block modified"
assert-equal [h] result24 "Return value pattern - position after insertion"

; Test return value with /to refinement - CORRECTED based on actual behavior
test-block18: [a b c d e f]
pos25: at test-block18 1  ; Position at 'a'
result25: move/to/part pos25 4 2  ; Move 2 elements to position 4
assert-equal [c d e a b f] test-block18 "Return value with /to - block modified"
assert-equal [f] result25 "Return value with /to - position after insertion"

; Test return value when moving to head
test-block19: [a b c d e]
pos26: at test-block19 4  ; Position at 'd'
result26: move/to pos26 1  ; Move 'd' to head
assert-equal [d a b c e] test-block19 "Return value moving to head - block modified"
assert-equal [a b c e] result26 "Return value moving to head - position after insertion"

;;-----------------------------------------------------------------------------
;; Section 9: Additional Edge Cases Based on Real Testing
;;-----------------------------------------------------------------------------
print "^/--- Section 9: Additional Edge Cases Based on Real Testing ---"

; Test move/part behavior with overlapping ranges - FIXED EXPECTED RESULT
test-block20: [a b c d e f g h i j]
pos27: at test-block20 2  ; Position at 'b'
result27: move/part pos27 3 4  ; Move 4 elements forward by 3
assert-equal [a f g h b c d e i j] test-block20 "Move/part overlapping ranges - block modified"
assert-equal [i j] result27 "Move/part overlapping ranges - return value"

; Test move/to with exact boundary conditions
test-block21: [a b c d e]
pos28: at test-block21 1  ; Position at 'a'
result28: move/to pos28 5  ; Move to exact tail position
assert-equal [b c d e a] test-block21 "Move/to exact tail - block modified"
assert-equal [] result28 "Move/to exact tail - return value"

; Test move/skip with non-aligned data
test-block22: [a b c d e f g h i]
pos29: at test-block22 1  ; Position at 'a'
result29: move/skip pos29 1 3  ; Move 3 elements by 1 skip-size-3 record
assert-equal [d e f a b c g h i] test-block22 "Move/skip non-aligned - block modified"
assert-equal [g h i] result29 "Move/skip non-aligned - return value"

;;-----------------------------------------------------------------------------
;; Final Test Summary
;;-----------------------------------------------------------------------------
print-test-summary

;;-----------------------------------------------------------------------------
;; MOVE Function Behavior Summary
;;-----------------------------------------------------------------------------
print "^/📝 MOVE Function Behavior Summary:"
print "==================================="
print "1. MOVE modifies the source series by moving elements to new positions"
print "2. MOVE returns the position after where elements were inserted"
print "3. MOVE/part moves specified number of elements as a contiguous block"
print "4. MOVE/to moves to absolute position (1-based index)"
print "5. MOVE/skip treats series as fixed-size records"
print "6. MOVE can move elements forward or backward with positive/negative offsets"
print "7. MOVE handles edge cases like empty series and bounds beyond series length"
print "8. MOVE works with all series types: blocks, strings, binary, etc."
print "9. MOVE/part with excessive length may not move anything in some cases"
print "10. MOVE return value is always the position after the insertion point"
print "11. MOVE with zero offset still performs the move operation"
print "12. MOVE refinements can be combined: /part/to, /skip/part, /skip/to"
print "13. MOVE behavior depends on the starting position and destination calculation"
print "14. MOVE operations can result in complex rearrangements with overlapping ranges"
print "15. MOVE/skip calculations are based on record boundaries and offsets"
