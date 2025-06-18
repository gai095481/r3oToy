REBOL [
    Title: "QA Test and Documentation for get-field Function"
    Version: 2.0.0
    Author: "AI Assistant & User"
    Date: 17-Jun-2025
    Status: "In Development"
    Purpose: {
        A self-contained script to rigorously test, document, and
        provide a reference implementation of the 'get-field' utility
        function. It serves as the golden copy of the function and its
        quality assurance harness.
    }
    Note: "This script adheres to the Rebol 3 Oldes Development Ruleset."
    Keywords: [qa test utility function helper block map safe-access]
]

;;-----------------------------------------------------------------------------
;;; 1. The Simple, Original, and Correct QA Test Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    {...docstring...}
    either equal? expected actual [
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {...docstring...}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED"
    ][
        print "❌ SOME TESTS FAILED"
    ]
    print "============================================^/"
]


;;-----------------------------------------------------------------------------
;;; 2. The Complete and Correct `get-field` Function
;;-----------------------------------------------------------------------------
;;-----------------------------------------------------------------------------
;;; 2. The Final, Syntactically Correct `get-field` Function
;;-----------------------------------------------------------------------------
get-field: function [
    data [block! map! none!] "The block or map to access."
    key [any-word! string! integer! block!] "The key, index, or path to retrieve."
    /default "Provide a default value if missing."
    default-value [any-type!]
][
    ;; This function uses a single return path for maximum stability.
    result: case [
        none? data [
            either default [default-value] [none]
        ]
        block? data [
            ;; The `within?` function is removed and replaced with native
            ;; comparison operators for correctness.
            either all [
                integer? key
                key >= 1
                key <= length? data
            ] [
                pick data key
            ][
                either default [default-value] [none]
            ]
        ]
        map? data [
            either find data key [
                value: select data key
                ;; This is the definitive fix: if `select` returns the
                ;; word 'none, convert it to the datatype none!.
                either all [word? value value = 'none] [
                    none
                ][
                    value
                ]
            ][
                either default [default-value] [none]
            ]
        ]
        true [ ;; Fallthrough for any other unexpected type
            either default [default-value] [none]
        ]
    ]

    return result
]



;;-----------------------------------------------------------------------------
;;; 3. The Full, Original Test Suite
;;-----------------------------------------------------------------------------
print "Starting QA tests for get-field v2.0.0 (Final Corrected)..."
print newline

;;; --- V1 Core Functionality Tests (Happy Path) ---
core-data-block: [10 "hello" true 3.14]
assert-equal 10 get-field core-data-block 1 "Core: Should get the first element."
assert-equal "hello" get-field core-data-block 2 "Core: Should get a middle element."
assert-equal 3.14 get-field core-data-block 4 "Core: Should get the last element."

;;; --- V1 Invalid Input Tests ---
assert-equal none get-field none 1 "Invalid Input: Should return none for a none block."
assert-equal "default" get-field/default none 1 "default" "Invalid Input: Should return default for a none block."

;;; --- V1 Out-of-Bounds Index Tests ---
assert-equal none get-field core-data-block 0 "Out-of-Bounds: Should return none for index 0."
assert-equal none get-field core-data-block -1 "Out-of-Bounds: Should return none for a negative index."
assert-equal none get-field core-data-block 5 "Out-of-Bounds: Should return none for an index greater than length."
assert-equal "default" get-field/default core-data-block 5 "default" "Out-of-Bounds: Should return default for an index greater than length."
assert-equal "default" get-field/default core-data-block 0 "default" "Out-of-Bounds: Should return default for index 0."

;;; --- V1 Default Value Edge Case Tests ---
assert-equal "fallback" get-field/default core-data-block 99 "fallback" "Default: Should return the provided default value on failure."
assert-equal none get-field/default core-data-block 99 none "Default: Should return `none` when it is explicitly provided as the default."
assert-equal true get-field/default core-data-block 99 true "Default: Should handle a `true` logical as a default value."

;;; --- V1 Enhanced Edge Case Tests ---
empty-data-block: []
assert-equal none get-field empty-data-block 1 "Edge Case: Should return none for empty block access."
assert-equal "empty-default" get-field/default empty-data-block 1 "empty-default" "Edge Case: Should return default for empty block access."

;;; --- V2 map! Support Tests ---
core-data-map: make map! [
    user: "gemini"
    id: 1234
    active: true
    profile: none
]
empty-data-map: make map! []

assert-equal "gemini" get-field core-data-map 'user "map!: Should get an existing value."
assert-equal none get-field core-data-map 'password "map!: Should return none for a missing key."
assert-equal "default-pass" get-field/default core-data-map 'password "default-pass" "map!: Should return default for a missing key."
assert-equal none get-field core-data-map 'profile "map!: Should return the value `none` when it is the stored value."
assert-equal none get-field empty-data-map 'any-key "map!: Should return none for an empty map."
assert-equal "default" get-field/default empty-data-map 'any-key "default" "map!: Should return default for an empty map."

print-test-summary
