Rebol [
    Title: "remove-each Diagnostic Probe Script"
    Purpose: "Comprehensive testing of remove-each function behavior"
    Author: "Diagnostic Probe Generator"
    Date: 14-Jul-2025
    Version: 1.0.0
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
        print "✅ ALL TESTS PASSED - REMOVE-EACH IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/=== REMOVE-EACH DIAGNOSTIC PROBE SCRIPT ==="
print "Systematically testing remove-each function behavior^/"

;;=============================================================================
;; SECTION 1: Probing Basic Block Removal Behavior
;;=============================================================================
print "^/--- SECTION 1: Probing Basic Block Removal Behavior ---"

;; HYPOTHESIS: remove-each should remove elements from a block where the body returns true
;; and leave the original block modified with only the elements where body returned false

test-block-1: [1 2 3 4 5]
original-block-1: copy test-block-1
result-1: remove-each num test-block-1 [num > 3]
assert-equal [1 2 3] test-block-1 "Basic removal: block modified to contain only elements <= 3"
assert-equal [1 2 3] result-1 "Basic removal: function returns the modified series"

;; HYPOTHESIS: remove-each with condition that matches no elements should leave block unchanged
test-block-2: [1 2 3]
result-2: remove-each num test-block-2 [num > 10]
assert-equal [1 2 3] test-block-2 "No match removal: block unchanged when condition matches nothing"
assert-equal [1 2 3] result-2 "No match removal: function returns unchanged series"

;; HYPOTHESIS: remove-each with condition that matches all elements should result in empty block
test-block-3: [1 2 3]
result-3: remove-each num test-block-3 [num > 0]
assert-equal [] test-block-3 "All match removal: block becomes empty when all elements match"
assert-equal [] result-3 "All match removal: function returns empty series"

;;=============================================================================
;; SECTION 2: Probing String Series Behavior
;;=============================================================================
print "^/--- SECTION 2: Probing String Series Behavior ---"

;; HYPOTHESIS: remove-each should work on strings, removing characters based on condition
test-string-1: "hello"
result-string-1: remove-each char test-string-1 [char = #"l"]
assert-equal "heo" test-string-1 "String removal: removes specified characters"
assert-equal "heo" result-string-1 "String removal: returns modified string"

;; HYPOTHESIS: remove-each on string with vowels removal
test-string-2: "programming"
result-string-2: remove-each char test-string-2 [find "aeiou" char]
assert-equal "prgrmmng" test-string-2 "String vowel removal: removes vowels correctly"
assert-equal "prgrmmng" result-string-2 "String vowel removal: returns modified string"

;;=============================================================================
;; SECTION 3: Probing Multiple Word Binding
;;=============================================================================
print "^/--- SECTION 3: Probing Multiple Word Binding ---"

;; HYPOTHESIS: remove-each should support block of words for multiple variable binding
test-block-pairs: [1 10 2 20 3 30 4 40]
result-pairs: remove-each [first-val second-val] test-block-pairs [first-val > 2]
assert-equal [1 10 2 20] test-block-pairs "Multiple words: removes pairs where first > 2"
assert-equal [1 10 2 20] result-pairs "Multiple words: returns modified series"

;; HYPOTHESIS: Multiple word binding with different data types
test-mixed-pairs: ["a" 1 "b" 2 "c" 3]
result-mixed: remove-each [str-val num-val] test-mixed-pairs [num-val > 1]
assert-equal ["a" 1] test-mixed-pairs "Mixed pairs: removes pairs where number > 1"
assert-equal ["a" 1] result-mixed "Mixed pairs: returns modified series"

;;=============================================================================
;; SECTION 4: Probing /count Refinement
;;=============================================================================
print "^/--- SECTION 4: Probing /count Refinement ---"

;; HYPOTHESIS: /count refinement should return the number of removed elements instead of modified series
test-count-block: [1 2 3 4 5 6]
removal-count: remove-each/count num test-count-block [num > 3]
assert-equal 3 removal-count "/count refinement: returns count of removed elements"
assert-equal [1 2 3] test-count-block "/count refinement: still modifies original series"

;; HYPOTHESIS: /count with no removals should return 0
test-count-none: [1 2 3]
no-removal-count: remove-each/count num test-count-none [num > 10]
assert-equal 0 no-removal-count "/count no removal: returns 0 when nothing removed"
assert-equal [1 2 3] test-count-none "/count no removal: series unchanged"

;; HYPOTHESIS: /count with all removals should return original length
test-count-all: [1 2 3 4]
all-removal-count: remove-each/count num test-count-all [num > 0]
assert-equal 4 all-removal-count "/count all removal: returns original length"
assert-equal [] test-count-all "/count all removal: series becomes empty"

;;=============================================================================
;; SECTION 5: Probing Edge Cases - Empty Series
;;=============================================================================
print "^/--- SECTION 5: Probing Edge Cases - Empty Series ---"

;; HYPOTHESIS: remove-each on empty block should return empty block unchanged
empty-block: []
result-empty: remove-each item empty-block [true]
assert-equal [] empty-block "Empty block: remains empty"
assert-equal [] result-empty "Empty block: returns empty block"

;; HYPOTHESIS: remove-each/count on empty block should return 0
empty-count-block: []
empty-count-result: remove-each/count item empty-count-block [true]
assert-equal 0 empty-count-result "Empty block count: returns 0"
assert-equal [] empty-count-block "Empty block count: block remains empty"

;; HYPOTHESIS: remove-each on empty string should return empty string
empty-string: ""
result-empty-string: remove-each char empty-string [true]
assert-equal "" empty-string "Empty string: remains empty"
assert-equal "" result-empty-string "Empty string: returns empty string"

;;=============================================================================
;; SECTION 6: Probing Different Data Types in Blocks
;;=============================================================================
print "^/--- SECTION 6: Probing Different Data Types in Blocks ---"

;; HYPOTHESIS: remove-each should handle mixed data types correctly
mixed-types: [1 "hello" 2.5 #"x" true [nested]]
result-mixed-types: remove-each item mixed-types [string? item]
assert-equal [1 2.5 #"x" true [nested]] mixed-types "Mixed types: removes strings only"
assert-equal [1 2.5 #"x" true [nested]] result-mixed-types "Mixed types: returns modified series"

;; HYPOTHESIS: remove-each does not remove `none` values, regardless of the condition.
with-none: [1 none 2 none 3]
result-with-none: remove-each item with-none [none? item]
assert-equal [1 none 2 none 3] with-none "None values: condition `none? item` does not remove nones"
assert-equal [1 none 2 none 3] result-with-none "None values: returns modified series"

with-none-2: [1 none 2 none 3]
result-with-none-2: remove-each item with-none-2 [item = none]
assert-equal [1 none 2 none 3] with-none-2 "None values: condition `item = none` does not remove nones"
assert-equal [1 none 2 none 3] result-with-none-2 "None values: returns modified series"

;;=============================================================================
;; SECTION 7: Probing Complex Conditions
;;=============================================================================
print "^/--- SECTION 7: Probing Complex Conditions ---"

;; HYPOTHESIS: remove-each should handle complex logical conditions
;; Logic: For odds, remove if < 4 (removes 1,3); For evens, remove if > 6 (removes 8,10)
;; Expected remaining: [2 4 5 6 7 9]
complex-block: [1 2 3 4 5 6 7 8 9 10]
result-complex: remove-each num complex-block [either even? num [num > 6] [num < 4]]
assert-equal [2 4 5 6 7 9] complex-block "Complex condition: removes odds < 4 and evens > 6"
assert-equal [2 4 5 6 7 9] result-complex "Complex condition: returns modified series"

;; HYPOTHESIS: remove-each with condition that accesses external variables
external-threshold: 5
threshold-block: [1 2 3 4 5 6 7 8]
result-external: remove-each num threshold-block [num > external-threshold]
assert-equal [1 2 3 4 5] threshold-block "External variable: removes using external threshold"
assert-equal [1 2 3 4 5] result-external "External variable: returns modified series"

;;=============================================================================
;; SECTION 8: Probing Modification During Iteration
;;=============================================================================
print "^/--- SECTION 8: Probing Modification During Iteration ---"

;; HYPOTHESIS: remove-each should handle cases where the condition modifies external state
counter: 0
counter-block: [1 2 3 4 5]
result-counter: remove-each num counter-block [
    set 'counter counter + 1
    num > 3
]
assert-equal [1 2 3] counter-block "Side effects: removes elements > 3"
assert-equal 5 counter "Side effects: counter incremented for each element"
assert-equal [1 2 3] result-counter "Side effects: returns modified series"

;;=============================================================================
;; SECTION 9: Probing Series Position Behavior
;;=============================================================================
print "^/--- SECTION 9: Probing Series Position Behavior ---"

;; HYPOTHESIS: remove-each should work correctly regardless of series position
positioned-block: [1 2 3 4 5]
positioned-at-3: skip positioned-block 2  ; position at index 3
result-positioned: remove-each num positioned-at-3 [num > 3]
assert-equal [1 2 3] positioned-block "Series position: original series modified correctly"
assert-equal [3] positioned-at-3 "Series position: positioned series shows remaining elements"

;;=============================================================================
;; SECTION 10: Probing Error Conditions
;;=============================================================================
print "^/--- SECTION 10: Probing Error Conditions ---"

;; HYPOTHESIS: remove-each should handle error conditions gracefully
error-test-block: [1 2 3]

;; Test with condition that might cause error
set/any 'error-result try [
    remove-each num error-test-block [num / 0]  ; Division by zero
]
assert-equal true error? error-result "Error condition: catches division by zero error"

;; Test with invalid body that references undefined variable
set/any 'undefined-result try [
    test-undefined: [1 2 3]
    remove-each num test-undefined [undefined-var > 2]
]
assert-equal true error? undefined-result "Undefined variable: catches undefined variable error"

print "^/=== REMOVE-EACH DIAGNOSTIC PROBE COMPLETE ==="
print-test-summary
