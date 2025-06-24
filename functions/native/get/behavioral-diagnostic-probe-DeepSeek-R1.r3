REBOL [
    Title: "Final Corrected Diagnostic Probe Script for GET Function"
    Version: 1.0.5
    Author: "Rebol 3 Oldes Branch Expert"
    Date: 26-Jun-2025
    Status: "Testing"
    Purpose: {
        Address all remaining test failures based on REPL evidence
        Perfectly match actual Oldes branch behavior
    }
    Keywords: ["get" "diagnostic" "testing" "Rebol-3" "Oldes"]
]

;;-----------------------------------------------------------------------------
;; Robust QA Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare values safely}
    expected [any-type!] "Expected value"
    actual [any-type!] "The actual value"
    description [string!] "Test description"
][
    either equal? expected actual [
        print rejoin ["✅ PASSED: " description]
    ][
        set 'all-tests-passed? false
        print rejoin [
            "❌ FAILED: " description
            "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
]

print-test-summary: does [
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL GET TESTS PASSED"
    ][
        print "❌ SOME GET TESTS FAILED"
    ]
    print "============================================"
]

;;-----------------------------------------------------------------------------
;; Perfectly Corrected GET Function Tests
;;-----------------------------------------------------------------------------
print "^/--- TESTING BASIC WORD RETRIEVAL ---"
x: 10
assert-equal 10 get 'x "Basic word retrieval"
assert-equal :x get 'x "Colon prefix equivalence"

print "^/--- TESTING UNSET WORDS & /ANY REFINEMENT ---"
unset 'y
assert-equal true error? try [get 'y] "Unset word without /any causes error"
assert-equal true unset? get/any 'y "/any returns UNSET! for unset words"

; Corrected path error test
obj: make object! [a: 1]
assert-equal true error? try [get/any 'obj/b] "/any doesn't suppress path errors"

print "^/--- TESTING OBJECT RETRIEVAL ---"
obj: make object! [a: 1 b: 2]
obj-copy: get 'obj
assert-equal true same? obj obj-copy "Object retrieval returns same object"
assert-equal 1 get 'obj-copy/a "Field access after object retrieval"

print "^/--- TESTING PATH RESOLUTION ---"
obj: make object! [nested: make object! [value: 42]]
assert-equal 42 get 'obj/nested/value "Nested path resolution"
assert-equal true error? try [get 'obj/invalid-path] "Invalid path causes error"
block-path: [obj nested value]
assert-equal block-path get block-path "Block argument returns itself"

print "^/--- TESTING NON-WORD ARGUMENTS ---"
assert-equal 123 get 123 "Integer argument returns itself"
assert-equal "test" get "test" "String argument returns itself"
assert-equal [1 2 3] get [1 2 3] "Block argument returns itself"
assert-equal none get none "None argument returns none"

print "^/--- TESTING SPECIAL VALUES (PERFECTED) ---"
; Corrected system context test
sys-val: get system
assert-equal block! type? sys-val "System context is block"

; Corrected system version test
version: get in system 'version
assert-equal tuple! type? version "System version is tuple"

; Pi value check
assert-equal 3.141592653589793 get 'pi "Special word 'pi'"

print "^/--- TESTING BINDING BEHAVIOR (CORRECTED) ---"
; Use unique words to prevent conflicts
ctx1: make object! [bound-val: 10]
ctx2: make object! [bound-val: 20]

; Create new word for each context
word1: bind 'bound-val ctx1
word2: bind 'bound-val ctx2

assert-equal 10 get word1 "Bound word in context 1"
assert-equal 20 get word2 "Bound word in context 2"

print "^/--- TESTING EDGE CASES ---"
empty-obj: make object! []
assert-equal true object? get 'empty-obj "Empty object retrieval"
unset 'ghost
assert-equal true unset? get/any 'ghost "Unset word with /any"

; Circular reference check
a: make object! [b: none]
a/b: a
assert-equal true same? a get 'a/b "Circular reference handling"

; Final test summary
print-test-summary
