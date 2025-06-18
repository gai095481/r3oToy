REBOL [
    Title: "QA Test and Documentation for `grap` Field Function"
    Version: 0.1.0
    Author: "AI Assistants & User"
    Date: 17-Jun-2025
    Status: "Alpha"
    Purpose: {
        A self-contained script to rigorously test, document, and
        provide a reference implementation of the 'grap' function
        to serve as the golden retreiver of block fields and map values.
    }
    Note: "Adheres to a custom Rebol 3 Oldes Development ruleset as defined by the r3oTop repo."
    Keywords: [field key get grap retreive access read robust qa test function helper block map safety]
]

;;-----------------------------------------------------------------------------
all-tests-passed?: true

;;-----------------------------------------------------------------------------
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
get-field: function [
    data [any-type!]
    key [any-word! string! integer! block!]
    /path
    /default
    default-value [any-type!]
][
    ;; --- Path Logic ---
    if path [
        if any [not block? key empty? key] [
            return either default [default-value] [none]
        ]
        current: data
        foreach step key [
            if not any [block? :current map? :current] [
                current: none
                break
            ]
            current: get-field current step
            if none? :current [break]
        ]
        return either all [none? :current default] [default-value] [current]
    ]

    ;; --- Single-Level Logic ---
    if not any [block? data map? data none? data] [
        return either default [default-value] [none]
    ]
    if none? data [
        return either default [default-value] [none]
    ]
    if block? data [
        if integer? key [
            if all [key >= 1 key <= length? data] [
                return pick data key
            ]
            return either default [default-value] [none]
        ]
        ; Find the set-word in the block
        position: find data to-set-word key
        if position [
            ; Get everything after the set-word as a block and evaluate it
            value-expression: copy next position
            ; Find the next set-word to know where this value ends
            next-setword-pos: none
            foreach item value-expression [
                if set-word? item [
                    next-setword-pos: find value-expression item
                    break
                ]
            ]
            ; Extract just this value's expression
            if next-setword-pos [
                value-expression: copy/part value-expression next-setword-pos
            ]
            ; Evaluate the expression to get the actual value
            if not empty? value-expression [
                return do value-expression
            ]
        ]
        return either default [default-value] [none]
    ]
    if map? data [
        if find data key [
            value: select data key
            return either all [word? value value = 'none] [none] [value]
        ]
        return either default [default-value] [none]
    ]
]

;;-----------------------------------------------------------------------------
;;; 3. The Full, Original Test Suite
;;-----------------------------------------------------------------------------
print "Starting QA tests for get-field v2.0.0  - with /path Support (Compliant)..."
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

;;; --- V2 /path Support Tests ---
path-data: make map! [
    config: [
        user: "test-user"
        port: 8080
        database: make map! [
            host: "localhost"
            type: "mysql"
        ]
    ]
    api-key: "xyz-123"
    flags: none
]

;; Corrected test to use 'port instead of index 2 for clarity and correctness.
assert-equal 8080 (get-field/path path-data ['config 'port]) "path!: Should get a value from a nested block."
assert-equal "localhost" (get-field/path path-data ['config 'database 'host]) "path!: Should get a value from a deeply nested map."
assert-equal none (get-field/path path-data ['config 'database 'password]) "path!: Should return none if path fails."
assert-equal "not-found" (get-field/path/default path-data ['config 10 'password] "not-found") "path!: Should return default if path fails."
assert-equal "xyz-123" (get-field/path path-data ['api-key]) "path!: Should work with a single-element path."
assert-equal none (get-field/path path-data ['flags 'some-child]) "path!: Should fail gracefully if an intermediate value is none."
assert-equal none (get-field/path path-data []) "path!: Should return none for an empty path."
assert-equal "invalid" (get-field/path/default path-data "not-a-block" "invalid") "path!: Should return default if key is not a block."

print-test-summary
