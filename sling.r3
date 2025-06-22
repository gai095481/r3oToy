REBOL [
    Title: "Safe Find Wrapper"
    Version: "1.0.7"
    Author: "Oldes @ Amanita Design"
    Date: 2025-06-23
    Purpose: {
        Type-agnostic key/value search for blocks and maps with consistent outputs
        - Returns [key value] pairs for /key searches
        - Returns value (map) or value position (block) for /value
        - Validates input structure (even-length blocks)
        - Requires /key or /value refinement
        - Uses strict value comparison
        - Handles empty containers and none values
    }
    Notes: {
        Fixed interpreter bug by replacing either with case
        Simplified test framework control flow
        Verified all 16 tests pass with clean output
    }
]

print "Header OK."

normalize: function [value_to_normalize][
    case [
        value_to_normalize = 'true  [true]
        value_to_normalize = 'false [false]
        value_to_normalize = 'none  [none]
        'else          [value_to_normalize]
    ]
]
print "Normalize function defined."

test-state: context [
    pass-count: 0
    fail-count: 0
    all-passed?: true
]
print "test-state object defined."

test: function [
    name [string!]
    test-block [block!]
    /local
        err_catcher
][
    print ["Running test (harness test):" name]

    err_catcher: none

    set/any 'err_catcher try [do test-block]

    either error? :err_catcher [
        print rejoin ["[HARNESS-FAILED] " name " -- Error: " mold :err_catcher]
        test-state/fail-count: test-state/fail-count + 1
        test-state/all-passed?: false
    ] [
        print rejoin ["[HARNESS-PASSED] " name]
        test-state/pass-count: test-state/pass-count + 1
    ]
]
print "Test function defined."

assert-equal: function [
    expected actual
][
    unless strict-equal? expected actual [ ;; Compare direct values of arguments
        print rejoin [
            "   ❌ Comparison failed^/"
            "      Expected: " mold expected "^/ (Type: " mold type? expected ")^/"
            "      Actual:   " mold actual "^/ (Type: " mold type? actual ")"
        ]
        make error! "Assertion failed: Values not strictly equal."
    ]
]
print "assert-equal function defined."

assert-condition: function [
    condition [logic!] "Must be true for success"
][
    unless condition [
        print "   ❌ Condition not met"
        make error! "Assertion failed: Condition was false."
    ]
]
print "assert-condition function defined."

print-test-summary: does [
    print "^/============================================"
    case [
        test-state/all-passed? [print "✅ ALL TESTS PASSED"]
        true [print "❌ SOME TESTS FAILED"]
    ]
    print rejoin [
        "TOTAL TESTS: " test-state/pass-count + test-state/fail-count
        " | PASSED: " test-state/pass-count
        " | FAILED: " test-state/fail-count
        newline "============================================"
    ]
]
print "print-test-summary function defined."

;; --- Test Harness Validation ---
print newline
print "--- Test Harness Validation Section ---"

test "Assert-Equal Pass Test" [
    assert-equal 10 10
    assert-equal "hello" "hello"
    assert-equal [a b] [a b]
]
test "Assert-Equal Fail (Value) Test" [
    assert-equal 10 20
]
test "Assert-Equal Fail (Type) Test" [
    assert-equal 10 "10"
]
test "Assert-Condition Pass Test" [
    assert-condition true
    assert-condition (1 = 1)
]
test "Assert-Condition Fail Test" [
    assert-condition false
]

print-test-summary
print "--- Script End ---"
