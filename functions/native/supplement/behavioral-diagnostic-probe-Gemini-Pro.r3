Rebol []

;-----------------------------
; A Battle-Tested QA Harness
;------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    "Compare two values and output a formatted PASSED or FAILED message."
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
    "Output the final summary of the entire test run."
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

;================================================================
; Probing the `supplement` function
;================================================================

; --- Hypothesis 1: Basic Behavior & Return Value ---
; `supplement` appends a value if it's not found. If found, the series is unchanged.
; The comparison for strings is case-insensitive by default.
; CRITICAL: The function returns the series at the *exact position* it was passed.
print "^/--- Probing Basic Behavior & Return Value ---"

; Test 1.1: Appending a new integer
block-one: [1 2 3]
supplement block-one 4
assert-equal [1 2 3 4] block-one "Appends an integer when it is not present."

; Test 1.2: Attempting to append an existing integer
block-two: [1 2 3]
supplement block-two 2
assert-equal [1 2 3] block-two "Does not append an integer when it is already present."

; Test 1.3: Appending a new string (case-insensitive check)
block-three: ["apple" "banana" "cherry"]
supplement block-three "ORANGE"
assert-equal ["apple" "banana" "cherry" "ORANGE"] block-three "Appends a new string."

; Test 1.4: Attempting to append an existing string (different case)
block-four: ["apple" "banana" "cherry"]
supplement block-four "APPLE"
assert-equal ["apple" "banana" "cherry"] block-four "Does not append a string that exists with different casing (default)."

; Test 1.5: Return value check (when value is appended)
block-five: [10 20]
return-val-one: supplement block-five 30
assert-equal block-five return-val-one "Returns the series itself (at head) when a value is appended."
assert-equal [10 20 30] block-five "Block is correctly modified when checking return value."

; Test 1.6: Return value check (when value is not appended)
block-six: [10 20 30]
return-val-two: supplement block-six 20
assert-equal block-six return-val-two "Returns the series itself (at head) when no value is appended."
assert-equal [10 20 30] block-six "Block is not modified when checking return value."


; --- Hypothesis 2: /case Refinement ---
; The /case refinement makes the comparison case-sensitive.
; A string will be appended if it exists but in a different case.
print "^/--- Probing /case Refinement ---"

; Test 2.1: Appending a string that exists in a different case
block-seven: ["apple" "banana" "cherry"]
supplement/case block-seven "APPLE"
assert-equal ["apple" "banana" "cherry" "APPLE"] block-seven "/case appends a string that exists in a different case."

; Test 2.2: Not appending a string that exists in the exact same case
block-eight: ["apple" "banana" "cherry"]
supplement/case block-eight "apple"
assert-equal ["apple" "banana" "cherry"] block-eight "/case does not append a string that exists in the exact same case."


; --- Hypothesis 3: Block Value Behavior ---
; `supplement` does NOT treat a block! value as a single unit because it uses `find` and `append` without `/only`.
; `find` will not find the block, and `append` will add the *contents* of the block to the series.
print "^/--- Probing Block Value Behavior ---"

; Test 3.1: Supplementing with a new block value
nested-block-one: [[a b] [c d]]
supplement nested-block-one [e f]
assert-equal [[a b] [c d] e f] nested-block-one "Appends the CONTENTS of a block, not the block itself."

; Test 3.2: Attempting to supplement with an existing block value
nested-block-two: [[a b] [c d]]
supplement nested-block-two [a b]
assert-equal [[a b] [c d] a b] nested-block-two "Fails to find block value, so appends its contents."


; --- Hypothesis 4: Data Types & Edge Cases ---
; `supplement` should handle various data types and behave predictably with edge cases like empty inputs or `none`.
print "^/--- Probing Data Types & Edge Cases ---"

; Test 4.1: Handling char!
char-block: [#"a" #"b" #"c"]
supplement char-block #"d" ; append
supplement char-block #"A" ; no append (case-insensitive)
supplement/case char-block #"A" ; append
assert-equal [#"a" #"b" #"c" #"d" #"A"] char-block "Correctly handles char! type with and without /case."

; Test 4.2: Supplementing an empty block
empty-block: []
supplement empty-block "first"
assert-equal ["first"] empty-block "Correctly appends to an empty block."

; Test 4.3: Supplementing the value `none`
none-block: [1 2]
expected-none-block: copy [1 2]
append expected-none-block none
supplement none-block none
assert-equal expected-none-block none-block "Correctly appends `none` when not present."
supplement none-block none
assert-equal expected-none-block none-block "Does not append `none` when already present."

; Test 4.4: Series position is not at the head
positioned-block: ["a" "b" "c" "d" "e"]
second-pos: next positioned-block
supplement second-pos "c" ; "c" is in the series, so no append
assert-equal ["a" "b" "c" "d" "e"] positioned-block "Does not append if value is present, even with non-head series."

; Test 4.5: Appending when series is not at head
return-val-three: supplement second-pos "f" ; "f" is not in the series, so append
assert-equal ["a" "b" "c" "d" "e" "f"] positioned-block "Appends correctly when series is not at head."
assert-equal second-pos return-val-three "Returns series at original position, NOT head."


; --- Hypothesis 5: Error Conditions ---
; `supplement` is defined for `block!` series. Other types should error.
print "^/--- Probing Error Conditions ---"

; Test 5.1: Using a string! series (should error)
description: "Passing a string! series raises an error as expected."
either error? try [
    supplement "a string" "x"
][
    ; Test passed, error was generated as expected
    assert-equal true true description
][
    ; Test failed, no error was generated
    assert-equal true false description
]

; --- Final Summary ---
print-test-summary
