REBOL [
    Title: "GET Function - Happy Path Examples"
    Version: 1.0.1
    Author: "Rebol 3 Oldes Branch Expert"
    Date: 26-Jun-2025
    Purpose: {Demonstrate common, correct uses of GET function}
]

;;-----------------------------------------------------------------------------
;; QA Test Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare two values}
    expected [any-type!] "Expected value"
    actual [any-type!] "Actual value"
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
    print newline
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL HAPPY PATH TESTS PASSED"
    ][
        print "❌ SOME HAPPY PATH TESTS FAILED"
    ]
    print "============================================"
]

;;-----------------------------------------------------------------------------
;; Happy Path Tests
;;-----------------------------------------------------------------------------
print newline
print "*** TESTING BASIC USAGE ***"

; Test 1: Basic word retrieval
x: 10
assert-equal 10 get 'x "Basic word retrieval"

; Test 2: Path resolution in objects
person: make object! [
    name: "Alice"
    age: 30
    address: make object! [city: "Berlin"]
]
assert-equal 30 get 'person/age "Path resolution"

; Test 3: Retrieving entire objects
person-copy: get 'person
assert-equal "Alice" person-copy/name "Object retrieval"

; Test 4: Special constant access
assert-equal 3.141592653589793 get 'pi "Constant access"

; Test 5: Safe unset checking
unset 'optional-value
assert-equal true unset? get/any 'optional-value "/any refinement safety"

; Final summary
print-test-summary
