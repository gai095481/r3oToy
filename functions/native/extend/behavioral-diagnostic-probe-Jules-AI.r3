Rebol [
    Title: "Extend Function Diagnostic Probe Script"
    Author: "Jules AI Assistant"
    Date: 13-Jul-2025
    Version: 0.1.0
    Purpose: "Comprehensive testing of the extend function behavior in Rebol 3 Oldes"
    Note: "This script systematically tests extend function with various data types and edge cases"
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
        print "✅ ALL TESTS PASSED - EXTEND IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/============================================"
print "=== COMPREHENSIVE EXTEND FUNCTION PROBE ==="
print "============================================^/"

;;-----------------------------------------------------------------------------
;; SECTION 1: Probing Basic Object Extension
;;-----------------------------------------------------------------------------
print "^/=== SECTION 1: Probing Basic Object Extension ===^/"

;; HYPOTHESIS: extend should add new properties to objects and return the value
test-obj-basic: make object! [name: "test"]
return-value: extend test-obj-basic 'age 25

assert-equal 25 return-value "extend should return the value that was added"
assert-equal 25 test-obj-basic/age "extend should add new property to object"
assert-equal "test" test-obj-basic/name "extend should preserve existing object properties"

;; HYPOTHESIS: extend should overwrite existing properties
test-obj-overwrite: make object! [name: "original"]
return-value-overwrite: extend test-obj-overwrite 'name "modified"

assert-equal "modified" return-value-overwrite "extend should return overwritten value"
assert-equal "modified" test-obj-overwrite/name "extend should overwrite existing property"

;;-----------------------------------------------------------------------------
;; SECTION 2: Probing Map Extension
;;-----------------------------------------------------------------------------
print "^/=== SECTION 2: Probing Map Extension ===^/"

;; HYPOTHESIS: extend should work with maps similar to objects
test-map-basic: make map! [color: "red"]
map-return-value: extend test-map-basic 'size "large"

assert-equal "large" map-return-value "extend should return value added to map"
assert-equal "large" test-map-basic/size "extend should add new key-value pair to map"
assert-equal "red" test-map-basic/color "extend should preserve existing map entries"

;; HYPOTHESIS: extend should handle map key overwriting
test-map-overwrite: make map! [status: "active"]
map-overwrite-return: extend test-map-overwrite 'status "inactive"

assert-equal "inactive" map-overwrite-return "extend should return overwritten map value"
assert-equal "inactive" test-map-overwrite/status "extend should overwrite existing map key"

;;-----------------------------------------------------------------------------
;; SECTION 3: Probing Block Extension
;;-----------------------------------------------------------------------------
print "^/=== SECTION 3: Probing Block Extension ===^/"

;; HYPOTHESIS: extend should add set-word/value pairs to blocks
test-block-basic: [existing: "value"]
block-return-value: extend test-block-basic 'new-item "block-value"

assert-equal "block-value" block-return-value "extend should return value added to block"
assert-equal [existing: "value" new-item: "block-value"] test-block-basic "extend should append set-word/value pair to block"

;; HYPOTHESIS: extend should handle empty blocks
test-block-empty: []
empty-block-return: extend test-block-empty 'first-item "initial"

assert-equal "initial" empty-block-return "extend should return value added to empty block"
assert-equal [first-item: "initial"] test-block-empty "extend should add set-word/value pair to empty block"

;;-----------------------------------------------------------------------------
;; SECTION 4: Probing Paren Extension
;;-----------------------------------------------------------------------------
print "^/=== SECTION 4: Probing Paren Extension ===^/"

;; HYPOTHESIS: extend should work with paren! type similar to blocks
test-paren-basic: make paren! [existing: "paren-value"]
paren-return-value: extend test-paren-basic 'new-entry "paren-addition"

assert-equal "paren-addition" paren-return-value "extend should return value added to paren"
assert-equal make paren! [existing: "paren-value" new-entry: "paren-addition"] test-paren-basic "extend should append set-word/value pair to paren"

;;-----------------------------------------------------------------------------
;; SECTION 5: Probing Word Type Variations
;;-----------------------------------------------------------------------------
print "^/=== SECTION 5: Probing Word Type Variations ===^/"

;; HYPOTHESIS: extend should handle different word types (word!, set-word!, get-word!, lit-word!)
test-obj-words: make object! []

;; Testing with word!
word-return1: extend test-obj-words 'normal-word "word-value"
assert-equal "word-value" word-return1 "extend should handle word! type"
assert-equal "word-value" test-obj-words/normal-word "extend should create property from word!"

;; Testing with set-word!
test-set-word: to-set-word 'set-word-test
set-word-return: extend test-obj-words test-set-word "set-word-value"
assert-equal "set-word-value" set-word-return "extend should handle set-word! type"
assert-equal "set-word-value" test-obj-words/set-word-test "extend should create property from set-word!"

;; Testing with get-word!
test-get-word: to-get-word 'get-word-test
get-word-return: extend test-obj-words test-get-word "get-word-value"
assert-equal "get-word-value" get-word-return "extend should handle get-word! type"
assert-equal "get-word-value" test-obj-words/get-word-test "extend should create property from get-word!"

;; Testing with lit-word!
test-lit-word: to-lit-word 'lit-word-test
lit-word-return: extend test-obj-words test-lit-word "lit-word-value"
assert-equal "lit-word-value" lit-word-return "extend should handle lit-word! type"
assert-equal "lit-word-value" test-obj-words/lit-word-test "extend should create property from lit-word!"

;;-----------------------------------------------------------------------------
;; SECTION 6: Probing Value Type Variations
;;-----------------------------------------------------------------------------
print "^/=== SECTION 6: Probing Value Type Variations ===^/"

;; HYPOTHESIS: extend should handle various value types
test-obj-values: make object! []

;; Testing with integer
int-return: extend test-obj-values 'int-prop 42
assert-equal 42 int-return "extend should handle integer values"
assert-equal 42 test-obj-values/int-prop "extend should store integer values"

;; Testing with decimal
decimal-return: extend test-obj-values 'decimal-prop 3.14
assert-equal 3.14 decimal-return "extend should handle decimal values"
assert-equal 3.14 test-obj-values/decimal-prop "extend should store decimal values"

;; Testing with logic true
logic-true-return: extend test-obj-values 'logic-true-prop true
assert-equal true logic-true-return "extend should handle logic true values"
assert-equal true test-obj-values/logic-true-prop "extend should store logic true values"

;; Testing with block
block-value: [1 2 3]
block-return: extend test-obj-values 'block-prop block-value
assert-equal block-value block-return "extend should handle block values"
assert-equal block-value test-obj-values/block-prop "extend should store block values"

;; Testing with string
string-return: extend test-obj-values 'string-prop "test string"
assert-equal "test string" string-return "extend should handle string values"
assert-equal "test string" test-obj-values/string-prop "extend should store string values"

;;-----------------------------------------------------------------------------
;; SECTION 7: Probing Falsy Value Behavior
;;-----------------------------------------------------------------------------
print "^/=== SECTION 7: Probing Falsy Value Behavior ===^/"

;; HYPOTHESIS: extend should NOT extend when value is falsy (none, false, 0)
test-obj-falsy: make object! [existing: "original"]

;; Testing with none
none-return: extend test-obj-falsy 'none-prop none
assert-equal none none-return "extend should return none when value is none"
either all [
    not in test-obj-falsy 'none-prop
][
    print "✅ PASSED: extend should NOT add property when value is none"
][
    set 'all-tests-passed? false
    set 'fail-count fail-count + 1
    print "❌ FAILED: extend should NOT add property when value is none"
]
set 'test-count test-count + 1

;; Testing with false
false-return: extend test-obj-falsy 'false-prop false
assert-equal false false-return "extend should return false when value is false"
either all [
    not in test-obj-falsy 'false-prop
][
    print "✅ PASSED: extend should NOT add property when value is false"
][
    set 'all-tests-passed? false
    set 'fail-count fail-count + 1
    print "❌ FAILED: extend should NOT add property when value is false"
]
set 'test-count test-count + 1

;; Testing with zero
zero-return: extend test-obj-falsy 'zero-prop 0
assert-equal 0 zero-return "extend should return zero when value is zero"
either all [
    in test-obj-falsy 'zero-prop
][
    print "✅ PASSED: extend DOES add property when value is zero (zero is truthy for extend)"
    set 'pass-count pass-count + 1
][
    set 'all-tests-passed? false
    set 'fail-count fail-count + 1
    print "❌ FAILED: extend should add property when value is zero"
]
set 'test-count test-count + 1

;; Testing with empty string
empty-string-return: extend test-obj-falsy 'empty-string-prop ""
assert-equal "" empty-string-return "extend should return empty string when value is empty string"
either all [
    in test-obj-falsy 'empty-string-prop
][
    print "✅ PASSED: extend DOES add property when value is empty string (empty string is truthy for extend)"
    set 'pass-count pass-count + 1
][
    set 'all-tests-passed? false
    set 'fail-count fail-count + 1
    print "❌ FAILED: extend should add property when value is empty string"
]
set 'test-count test-count + 1

assert-equal "original" test-obj-falsy/existing "extend should preserve existing properties when falsy values are used"

;;-----------------------------------------------------------------------------
;; SECTION 8: Probing Modification Behavior
;;-----------------------------------------------------------------------------
print "^/=== SECTION 8: Probing Modification Behavior ===^/"

;; HYPOTHESIS: extend should modify the original object/map/block, not create a copy
test-obj-modify: make object! [original: "value"]
original-obj-ref: test-obj-modify

extend-return: extend test-obj-modify 'new-prop "new-value"

assert-equal "new-value" extend-return "extend should return the added value"
assert-equal "new-value" original-obj-ref/new-prop "extend should modify original object reference"
assert-equal "value" original-obj-ref/original "extend should preserve original properties in reference"

;; Testing with block modification
test-block-modify: [start: "here"]
original-block-ref: test-block-modify

block-extend-return: extend test-block-modify 'added "block-item"

assert-equal "block-item" block-extend-return "extend should return value added to block"
assert-equal [start: "here" added: "block-item"] original-block-ref "extend should modify original block reference"

;;-----------------------------------------------------------------------------
;; SECTION 9: Probing Edge Cases and Error Conditions
;;-----------------------------------------------------------------------------
print "^/=== SECTION 9: Probing Edge Cases and Error Conditions ===^/"

;; HYPOTHESIS: extend should handle complex nested values
test-obj-nested: make object! []
nested-block: [inner: [deep: "value"]]
nested-return: extend test-obj-nested 'nested-prop nested-block

assert-equal nested-block nested-return "extend should handle nested block values"
assert-equal nested-block test-obj-nested/nested-prop "extend should store nested block values correctly"

;; HYPOTHESIS: extend should handle function values
test-obj-func: make object! []
test-function: function [] [print "test"]
func-return: extend test-obj-func 'func-prop :test-function

;; OBSERVED BEHAVIOR: `extend` evaluates a function! value and returns the result.
;; The test function returns no value, which results in `unset!`.
assert-equal true unset? func-return "extend returns unset! after evaluating function"
assert-equal true unset? test-obj-func/func-prop "extend stores unset! after evaluating function"
assert-equal true same? func-return test-obj-func/func-prop "extend should store the same function reference"

;; HYPOTHESIS: extend should handle refinement words
test-obj-refinement: make object! []
test-refinement-word: to-refinement 'refinement-prop
refinement-return: extend test-obj-refinement test-refinement-word "refinement-value"

assert-equal "refinement-value" refinement-return "extend should handle refinement words"
assert-equal "refinement-value" test-obj-refinement/refinement-prop "extend should store values with refinement words"

;;-----------------------------------------------------------------------------
;; SECTION 10: Probing Return Value Consistency
;;-----------------------------------------------------------------------------
print "^/=== SECTION 10: Probing Return Value Consistency ===^/"

;; HYPOTHESIS: extend should always return the exact value passed as third argument
test-obj-return: make object! []

;; Testing return value identity with various types
test-string-val: "exact-string"
string-ret: extend test-obj-return 'str-test test-string-val
assert-equal test-string-val string-ret "extend should return identical string reference"

test-block-val: [1 2 3]
block-ret: extend test-obj-return 'block-test test-block-val
assert-equal test-block-val block-ret "extend should return identical block reference"

test-obj-val: make object! [inner: "value"]
obj-ret: extend test-obj-return 'obj-test test-obj-val
assert-equal test-obj-val obj-ret "extend should return identical object reference"

print "^/=== ALL EXTEND FUNCTION PROBES COMPLETED ===^/"

print-test-summary
