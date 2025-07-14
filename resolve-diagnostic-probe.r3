Rebol [
    Title: "Resolve Function Diagnostic Probe (Corrected)"
    Purpose: "Comprehensive testing of the resolve native function and its refinements"
    Author: "AI Assistant"
    Date: 14-Jul-2025
    Version: 2.3.0
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
;; Section 1: Basic Behavior - Unset vs. None
;;-----------------------------------------------------------------------------

print "^/--- Section 1: Basic Behavior (No Refinements) ---"

;; HYPOTHESIS: resolve copies values from source object to target object
;; but only for words that exist in both objects and only if target value is UNSET.
target-obj1: make object! [name: none age: none city: "Default"]
clear 'target-obj1/name
clear 'target-obj1/age
source-obj1: make object! [name: "John" age: 30 country: "USA"]

;; Test basic copying behavior on unset fields
resolve target-obj1 source-obj1
assert-equal "John" target-obj1/name "Basic resolve: copies value to unset field 'name'"
assert-equal 30 target-obj1/age "Basic resolve: copies value to unset field 'age'"
assert-equal "Default" target-obj1/city "Basic resolve: leaves existing set fields unchanged"

;; HYPOTHESIS: resolve does not add new words to target by default
assert-equal false value? get in target-obj1 'country "Basic resolve: does not add new words to target"

;; HYPOTHESIS: resolve does NOT overwrite fields that are set to `none`.
target-obj-none: make object! [value1: none value2: "preset"]
source-obj-none: make object! [value1: "test" value2: "new"]

resolve target-obj-none source-obj-none
assert-equal none target-obj-none/value1 "Basic resolve: does NOT overwrite existing none values"
assert-equal "preset" target-obj-none/value2 "Basic resolve: does not overwrite existing set values"


;;-----------------------------------------------------------------------------
;; Section 2: /all Refinement
;;-----------------------------------------------------------------------------

print "^/--- Section 2: /all Refinement ---"

;; HYPOTHESIS: /all refinement forces resolve to overwrite existing values in target, including `none`.
target-obj4: make object! [name: "Jane" age: 25 city: "Default" status: none]
source-obj4: make object! [name: "John" age: 30 country: "USA" status: "Active"]

resolve/all target-obj4 source-obj4
assert-equal "John" target-obj4/name "/all refinement: overwrites existing name value"
assert-equal 30 target-obj4/age "/all refinement: overwrites existing age value"
assert-equal "Active" target-obj4/status "/all refinement: overwrites existing none value"
assert-equal "Default" target-obj4/city "/all refinement: leaves non-matching words unchanged"

;;-----------------------------------------------------------------------------
;; Section 3: /extend Refinement
;;-----------------------------------------------------------------------------

print "^/--- Section 3: /extend Refinement ---"

;; HYPOTHESIS: /extend refinement adds new words from source to target, but still only resolves UNSET fields.
target-obj6: make object! [name: none age: 25]
clear 'target-obj6/name
source-obj6: make object! [name: "Alice" age: 30 country: "Canada" city: "Toronto"]

resolve/extend target-obj6 source-obj6
assert-equal "Alice" target-obj6/name "/extend refinement: copies to existing unset words"
assert-equal 25 target-obj6/age "/extend refinement: leaves existing set values unchanged"
assert-equal "Canada" target-obj6/country "/extend refinement: adds new 'country' word and value"
assert-equal "Toronto" target-obj6/city "/extend refinement: adds new 'city' word and value"

;;-----------------------------------------------------------------------------
;; Section 4: /all and /extend Combined
;;-----------------------------------------------------------------------------

print "^/--- Section 4: /all and /extend Combined ---"

;; HYPOTHESIS: /all and /extend together both overwrite existing values (including `none`) and add new words
target-obj7: make object! [name: "Bob" age: none]
source-obj7: make object! [name: "Charlie" age: 35 country: "UK"]

resolve/all/extend target-obj7 source-obj7
assert-equal "Charlie" target-obj7/name "/all + /extend: overwrites existing values"
assert-equal 35 target-obj7/age "/all + /extend: overwrites none values"
assert-equal "UK" target-obj7/country "/all + /extend: adds new words to target"

;;-----------------------------------------------------------------------------
;; Section 5: /only Refinement with Block
;;-----------------------------------------------------------------------------

print "^/--- Section 5: /only Refinement with Block ---"

;; HYPOTHESIS: /only with block limits copying to specified UNSET words only
target-obj8: make object! [name: none age: none city: none country: "preset"]
clear 'target-obj8/name
clear 'target-obj8/city
source-obj8: make object! [name: "David" age: 40 city: "London"]

resolve/only target-obj8 source-obj8 [name city]
assert-equal "David" target-obj8/name "/only with block: copies specified word 'name'"
assert-equal "London" target-obj8/city "/only with block: copies specified word 'city'"
assert-equal none target-obj8/age "/only block: leaves non-specified 'none' words untouched"
assert-equal "preset" target-obj8/country "/only with block: leaves non-specified set words untouched"

;;-----------------------------------------------------------------------------
;; Section 6: /only Refinement with Integer
;;-----------------------------------------------------------------------------

print "^/--- Section 6: /only Refinement with Integer ---"

;; HYPOTHESIS: /only with integer copies values to UNSET words starting from that position in target.
target-obj10: make object! [word1: none word2: none word3: none word4: "preset"]
clear 'target-obj10/word1
clear 'target-obj10/word2
clear 'target-obj10/word3
source-obj10: make object! [word1: "val1" word2: "val2" word3: "val3" word4: "val4"]

resolve/only target-obj10 source-obj10 3
assert-equal true unset? get in target-obj10 'word1 "/only with integer: skips words before specified position"
assert-equal true unset? get in target-obj10 'word2 "/only with integer: skips words before specified position (2)"
assert-equal "val3" target-obj10/word3 "/only with integer: copies word at specified position"
assert-equal "preset" target-obj10/word4 "/only with integer: leaves existing set values after position unchanged"

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
target-with-func: make object! [func-val: none data-val: none]
clear 'target-with-func/func-val
clear 'target-with-func/data-val
source-with-func: make object! [func-val: does [print "hello"] data-val: "test"]

resolve target-with-func source-with-func
assert-equal "test" target-with-func/data-val "Edge case: copies non-function values normally"
assert-equal true function? get in target-with-func 'func-val "Edge case: copies function values correctly"

;; Test invalid /only argument
error-target: make object! [test: none]
error-source: make object! [test: "value"]
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
