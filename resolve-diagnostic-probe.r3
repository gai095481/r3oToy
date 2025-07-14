Rebol [
    Title: "Resolve Function Diagnostic Probe (Corrected)"
    Purpose: "Comprehensive testing of the resolve native function and its refinements"
    Author: "AI Assistant"
    Date: 14-Jul-2025
    Version: 2.0.0
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

print "^/--- Section 1: Basic Behavior (Unset vs. None) ---"

;; HYPOTHESIS: `resolve` (no refinements) only copies values from source to target
;; if the corresponding word in the target is UNSET. It does NOT overwrite `none`.

;; Test with UNSET target fields
target-obj-unset: context [name: _ age: _ city: "Default"]
clear 'target-obj-unset/name
clear 'target-obj-unset/age
source-obj1: context [name: "John" age: 30 country: "USA"]

resolve target-obj-unset source-obj1
assert-equal "John" target-obj-unset/name "Basic resolve: copies value to unset field 'name'"
assert-equal 30 target-obj-unset/age "Basic resolve: copies value to unset field 'age'"
assert-equal "Default" target-obj-unset/city "Basic resolve: leaves existing set fields unchanged"

;; HYPOTHESIS: resolve does not add new words to target by default
assert-equal false value? in target-obj-unset 'country "Basic resolve: does not add new words to target"

;; Test with NONE target fields
target-obj-none: context [name: none age: none city: "Default"]
resolve target-obj-none source-obj1
assert-equal none target-obj-none/name "Basic resolve: does NOT overwrite 'none' field"
assert-equal none target-obj-none/age "Basic resolve: does NOT overwrite 'none' field (2)"

;;-----------------------------------------------------------------------------
;; Section 2: /all Refinement
;;-----------------------------------------------------------------------------

print "^/--- Section 2: /all Refinement ---"

;; HYPOTHESIS: /all refinement forces resolve to overwrite existing values, including `none`.
target-obj-all: make object! [name: "Jane" age: 25 city: "Default" status: none]
source-obj-all: make object! [name: "John" age: 30 country: "USA" status: "Active"]

resolve/all target-obj-all source-obj-all
assert-equal "John" target-obj-all/name "/all refinement: overwrites existing string value"
assert-equal 30 target-obj-all/age "/all refinement: overwrites existing integer value"
assert-equal "Active" target-obj-all/status "/all refinement: overwrites existing none value"
assert-equal "Default" target-obj-all/city "/all refinement: leaves non-matching words unchanged"

;;-----------------------------------------------------------------------------
;; Section 3: /extend Refinement
;;-----------------------------------------------------------------------------

print "^/--- Section 3: /extend Refinement ---"

;; HYPOTHESIS: /extend adds new words from source to target, but still only resolves UNSET (not `none`) fields.
target-obj-extend: context [name: _ age: 25]
clear 'target-obj-extend/name
source-obj-extend: make object! [name: "Alice" age: 30 country: "Canada" city: "Toronto"]

resolve/extend target-obj-extend source-obj-extend
assert-equal "Alice" target-obj-extend/name "/extend: copies to existing unset words"
assert-equal 25 target-obj-extend/age "/extend: leaves existing set values unchanged"
assert-equal "Canada" target-obj-extend/country "/extend: adds new 'country' word and value"
assert-equal "Toronto" target-obj-extend/city "/extend: adds new 'city' word and value"

;;-----------------------------------------------------------------------------
;; Section 4: /all and /extend Combined
;;-----------------------------------------------------------------------------

print "^/--- Section 4: /all and /extend Combined ---"

;; HYPOTHESIS: /all and /extend together both overwrite existing values (including `none`) AND add new words.
target-obj-combo: make object! [name: "Bob" age: none]
source-obj-combo: make object! [name: "Charlie" age: 35 country: "UK"]

resolve/all/extend target-obj-combo source-obj-combo
assert-equal "Charlie" target-obj-combo/name "/all+extend: overwrites existing value"
assert-equal 35 target-obj-combo/age "/all+extend: overwrites none value"
assert-equal "UK" target-obj-combo/country "/all+extend: adds new word"

;;-----------------------------------------------------------------------------
;; Section 5: /only Refinement with Block
;;-----------------------------------------------------------------------------

print "^/--- Section 5: /only Refinement with Block ---"

;; HYPOTHESIS: /only with block limits copying to specified UNSET words.
target-obj-only: context [name: _ age: _ city: _ country: "UK"]
clear 'target-obj-only/name
clear 'target-obj-only/age
clear 'target-obj-only/city
source-obj-only: make object! [name: "David" age: 40 city: "London"]

resolve/only target-obj-only source-obj-only [name city]
assert-equal "David" target-obj-only/name "/only block: copies specified word 'name'"
assert-equal "London" target-obj-only/city "/only block: copies specified word 'city'"
assert-equal true unset? get in target-obj-only 'age "/only block: leaves non-specified unset words unset"
assert-equal "UK" target-obj-only/country "/only block: leaves existing set words unchanged"

;;-----------------------------------------------------------------------------
;; Section 6: /only Refinement with Integer
;;-----------------------------------------------------------------------------

print "^/--- Section 6: /only Refinement with Integer ---"

;; HYPOTHESIS: /only with integer copies values to UNSET words starting from that position in target.
target-obj-int: context [word1: _ word2: _ word3: _ word4: "preset"]
clear 'target-obj-int/word1; clear 'target-obj-int/word2; clear 'target-obj-int/word3
source-obj-int: make object! [word1: "val1" word2: "val2" word3: "val3" word4: "val4"]

resolve/only target-obj-int source-obj-int 3
assert-equal true unset? get in target-obj-int 'word1 "/only integer: skips word1"
assert-equal true unset? get in target-obj-int 'word2 "/only integer: skips word2"
assert-equal "val3" target-obj-int/word3 "/only integer: copies word at specified position"
assert-equal "preset" target-obj-int/word4 "/only integer: does not overwrite existing set value after position"

;;-----------------------------------------------------------------------------
;; Section 7: Edge Cases and Error Conditions
;;-----------------------------------------------------------------------------

print "^/--- Section 7: Edge Cases and Error Conditions ---"

;; Test with object containing functions
target-with-func: context [func-val: _ data-val: _]
clear 'target-with-func/func-val; clear 'target-with-func/data-val
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

;; HYPOTHESIS: resolve returns the modified target object
ret-target: context [name: _]
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
