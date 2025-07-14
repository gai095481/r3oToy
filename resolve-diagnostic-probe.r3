Rebol [
    Title: "Resolve Function Diagnostic Probe"
    Purpose: "Comprehensive testing of the resolve native function and its refinements"
    Author: "AI Assistant"
    Date: 14-Jul-2025
    Version: 1.0.0
    Target: "REBOL/Bulk 3.19.0 (Oldes Branch)"
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
        print "✅ ALL TESTS PASSED - RESOLVE IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; RESOLVE FUNCTION COMPREHENSIVE DIAGNOSTIC PROBE
;;=============================================================================

print "^/=== RESOLVE FUNCTION DIAGNOSTIC PROBE ==="
print "Testing resolve native function behavior systematically^/"

;;-----------------------------------------------------------------------------
;; Section 1: Basic Behavior - No Refinements
;;-----------------------------------------------------------------------------

print "^/--- Section 1: Basic Behavior (No Refinements) ---"

;; Hypothesis: resolve copies values from source object to target object
;; but only for words that exist in both objects and only if target value is unset
target-obj1: make object! [name: none, age: none, city: "Default"]
clear 'target-obj1/name
clear 'target-obj1/age
source-obj1: make object! [name: "John" age: 30 country: "USA"]

;; Test basic copying behavior
resolve target-obj1 source-obj1
assert-equal "John" target-obj1/name "Basic resolve: copies name from source to target"
assert-equal 30 target-obj1/age "Basic resolve: copies age from source to target"
assert-equal "Default" target-obj1/city "Basic resolve: leaves existing target values unchanged"

;; Hypothesis: resolve does not add new words to target by default
target-has-country: false
set/any 'country-check try [target-obj1/country]
either error? country-check [
    target-has-country: false
][
    target-has-country: true
]
assert-equal false target-has-country "Basic resolve: does not add new words to target"

;; Test with objects containing different value types
target-obj2: make object! [num: none, text: none, flag: none, lst: none]
clear 'target-obj2/num
clear 'target-obj2/text
clear 'target-obj2/flag
clear 'target-obj2/lst
source-obj2: make object! [num: 42 text: "hello" flag: true lst: [1 2 3]]

resolve target-obj2 source-obj2
assert-equal 42 target-obj2/num "Basic resolve: copies integer values"
assert-equal "hello" target-obj2/text "Basic resolve: copies string values"
assert-equal true target-obj2/flag "Basic resolve: copies logic values"
assert-equal [1 2 3] target-obj2/lst "Basic resolve: copies block values"

;; Test with none values
target-obj3: make object! [value1: none, value2: "preset"]
source-obj3: make object! [value1: "test" value2: "new"]

resolve target-obj3 source-obj3
assert-equal none target-obj3/value1 "Basic resolve: does not overwrite existing none values"
assert-equal "preset" target-obj3/value2 "Basic resolve: does not overwrite existing set values"


;;-----------------------------------------------------------------------------
;; Section 2: /all Refinement
;;-----------------------------------------------------------------------------

print "^/--- Section 2: /all Refinement ---"

;; Hypothesis: /all refinement forces resolve to overwrite existing values in target
target-obj4: make object! [name: "Jane" age: 25 city: "Default"]
source-obj4: make object! [name: "John" age: 30 country: "USA"]

resolve/all target-obj4 source-obj4
assert-equal "John" target-obj4/name "/all refinement: overwrites existing name value"
assert-equal 30 target-obj4/age "/all refinement: overwrites existing age value"
assert-equal "Default" target-obj4/city "/all refinement: leaves non-matching words unchanged"

;; Test /all with mixed unset and set values
target-obj5: make object! [val1: "existing" val2: none val3: 100]
clear 'target-obj5/val2
source-obj5: make object! [val1: "new" val2: "fresh" val3: 200]

resolve/all target-obj5 source-obj5
assert-equal "new" target-obj5/val1 "/all refinement: overwrites existing non-unset values"
assert-equal "fresh" target-obj5/val2 "/all refinement: sets unset values"
assert-equal 200 target-obj5/val3 "/all refinement: overwrites existing numeric values"

;;-----------------------------------------------------------------------------
;; Section 3: /extend Refinement
;;-----------------------------------------------------------------------------

print "^/--- Section 3: /extend Refinement ---"

;; Hypothesis: /extend refinement adds new words from source to target
target-obj6: make object! [name: none, age: 25]
clear 'target-obj6/name
source-obj6: make object! [name: "Alice" age: 30 country: "Canada" city: "Toronto"]

resolve/extend target-obj6 source-obj6
assert-equal "Alice" target-obj6/name "/extend refinement: copies to existing unset words"
assert-equal 25 target-obj6/age "/extend refinement: leaves existing set values unchanged"

;; Check if new words were added
target-has-country6: false
target-has-city6: false
set/any 'country-check6 try [target-obj6/country]
set/any 'city-check6 try [target-obj6/city]

either error? country-check6 [
    target-has-country6: false
][
    target-has-country6: true
]

either error? city-check6 [
    target-has-city6: false
][
    target-has-city6: true
]

assert-equal true target-has-country6 "/extend refinement: adds new words to target"
assert-equal true target-has-city6 "/extend refinement: adds multiple new words to target"

if target-has-country6 [
    assert-equal "Canada" target-obj6/country "/extend refinement: new word has correct value"
]
if target-has-city6 [
    assert-equal "Toronto" target-obj6/city "/extend refinement: second new word has correct value"
]

;;-----------------------------------------------------------------------------
;; Section 4: /all and /extend Combined
;;-----------------------------------------------------------------------------

print "^/--- Section 4: /all and /extend Combined ---"

;; Hypothesis: /all and /extend together both overwrite existing values and add new words
target-obj7: make object! [name: "Bob" age: none]
clear 'target-obj7/age
source-obj7: make object! [name: "Charlie" age: 35 country: "UK"]

resolve/all/extend target-obj7 source-obj7
assert-equal "Charlie" target-obj7/name "/all + /extend: overwrites existing values"
assert-equal 35 target-obj7/age "/all + /extend: sets unset values"

;; Check if new word was added
target-has-country7: false
set/any 'country-check7 try [target-obj7/country]
either error? country-check7 [
    target-has-country7: false
][
    target-has-country7: true
]

assert-equal true target-has-country7 "/all + /extend: adds new words to target"
if target-has-country7 [
    assert-equal "UK" target-obj7/country "/all + /extend: new word has correct value"
]

;;-----------------------------------------------------------------------------
;; Section 5: /only Refinement with Block
;;-----------------------------------------------------------------------------

print "^/--- Section 5: /only Refinement with Block ---"

;; Hypothesis: /only with block limits copying to specified words only
target-obj8: make object! [name: none, age: none, city: none, country: none]
clear 'target-obj8/name
clear 'target-obj8/age
clear 'target-obj8/city
clear 'target-obj8/country
source-obj8: make object! [name: "David" age: 40 city: "London" country: "UK"]

resolve/only target-obj8 source-obj8 [name city]
assert-equal "David" target-obj8/name "/only with block: copies specified word 'name'"
assert-equal "London" target-obj8/city "/only with block: copies specified word 'city'"

;; Check that non-specified words remain unset
assert-equal true unset? get in target-obj8 'age "/only with block: leaves non-specified words unset"
assert-equal true unset? get in target-obj8 'country "/only with block: leaves non-specified words unset (2)"

;; Test /only with block containing non-existent words
target-obj9: make object! [name: none, age: none]
clear 'target-obj9/name
clear 'target-obj9/age
source-obj9: make object! [name: "Emma" age: 28 city: "Paris"]

resolve/only target-obj9 source-obj9 [name nonexistent]
assert-equal "Emma" target-obj9/name "/only with block: copies existing specified word"
assert-equal true unset? get in target-obj9 'age "/only with block: ignores non-specified existing words"

;;-----------------------------------------------------------------------------
;; Section 6: /only Refinement with Integer
;;-----------------------------------------------------------------------------

print "^/--- Section 6: /only Refinement with Integer ---"

;; Hypothesis: /only with integer copies words starting from that position in target
target-obj10: make object! [word1: none, word2: none, word3: none, word4: none]
clear 'target-obj10/word1
clear 'target-obj10/word2
clear 'target-obj10/word3
clear 'target-obj10/word4
source-obj10: make object! [word1: "val1" word2: "val2" word3: "val3" word4: "val4"]

;; Test with integer 3 (should copy from 3rd position onward)
resolve/only target-obj10 source-obj10 3

;; Check which words were copied
assert-equal true unset? get in target-obj10 'word1 "/only with integer: skips words before specified position"
assert-equal true unset? get in target-obj10 'word2 "/only with integer: skips words before specified position (2)"
assert-equal "val3" target-obj10/word3 "/only with integer: copies word at specified position"
assert-equal "val4" target-obj10/word4 "/only with integer: copies words after specified position"

;;-----------------------------------------------------------------------------
;; Section 7: Edge Cases and Error Conditions
;;-----------------------------------------------------------------------------

print "^/--- Section 7: Edge Cases and Error Conditions ---"

;; Test with empty objects
empty-target: make object! []
empty-source: make object! []
resolve empty-target empty-source
assert-equal 0 length? words-of empty-target "Edge case: resolving empty objects does nothing"

;; Test with object containing functions
target-with-func: make object! [func-val: none, data-val: none]
clear 'target-with-func/func-val
clear 'target-with-func/data-val
source-with-func: make object! [func-val: does [print "hello"] data-val: "test"]

resolve target-with-func source-with-func
assert-equal "test" target-with-func/data-val "Edge case: copies non-function values normally"
assert-equal true function? get in target-with-func 'func-val "Edge case: copies function values"

;; Test with very long word names
target-long: make object! [very-long-word-name-for-testing: none]
clear 'target-long/very-long-word-name-for-testing
source-long: make object! [very-long-word-name-for-testing: "long-test"]

resolve target-long source-long
assert-equal "long-test" target-long/very-long-word-name-for-testing "Edge case: handles long word names"

;; Test resolve behavior with refinement combinations that should error
;; (This tests the error handling rather than successful operation)
error-target: make object! [test: none]
error-source: make object! [test: "value"]

;; Test invalid /only argument (should handle gracefully or error)
set/any 'resolve-error try [resolve/only error-target error-source "invalid"]
assert-equal true error? resolve-error "/only with invalid argument type produces expected error"

;;-----------------------------------------------------------------------------
;; Section 8: Return Value Testing
;;-----------------------------------------------------------------------------

print "^/--- Section 8: Return Value Testing ---"

;; Hypothesis: resolve returns the modified target object
ret-target: make object! [name: none]
clear 'ret-target/name
ret-source: make object! [name: "Return Test"]

returned-value: resolve ret-target ret-source
assert-equal ret-target returned-value "Return value: resolve returns the target object"
assert-equal "Return Test" returned-value/name "Return value: returned object has expected modifications"

;; Test return value with refinements
ret-target2: make object! [name: "old"]
ret-source2: make object! [name: "new"]

returned-value2: resolve/all ret-target2 ret-source2
assert-equal ret-target2 returned-value2 "Return value: resolve/all returns the target object"
assert-equal "new" returned-value2/name "Return value: resolve/all returned object has expected modifications"

print "^/=== RESOLVE DIAGNOSTIC PROBE COMPLETE ==="
print-test-summary
