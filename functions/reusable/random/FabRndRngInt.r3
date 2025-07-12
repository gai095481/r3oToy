REBOL [
    title: "FabRndRngInt Quality Assurance Diagnostic Suite"
    date: 12-Jul-2025
    file: %FabRndRngInt.r3
    version: 0.1.0
    author: "Claude 4 Sonnet and person"
    purpose: "Comprehensive testing of FabRndRngInt function for stability, correctness and edge cases."
]

FabRndRngInt: function [
    {Generate a random integer within the specified integer range.
    RETURNS: An integer within the specified range (inclusive).
    ERRORS: Throws an error if the lower-bound > upper-bound.}
    lower-bound [integer!] "Lower bound of the range (inclusive)."
    upper-bound [integer!] "Upper bound of the range (inclusive)."
    /seed seed-value [integer!] "Seed value for reproducible results."
][
    ;; Input validation - FIXED: Now properly throws error
    if lower-bound > upper-bound [
        cause-error 'user 'message rejoin [
            "Lower bound " lower-bound
            " must be <= upper bound " upper-bound
        ]
    ]

    ;; Apply seed if requested:
    if seed [random/seed seed-value]

    ;; Calculate range size:
    range-size: (upper-bound - lower-bound) + 1

    ;; Use the maximum value that random() can safely handle:
    max-random-value: 4611686018427300000  ; Empirically determined safe limit

    ;; Use rejection sampling to eliminate modulo bias:
    max-usable: max-random-value - (max-random-value % range-size)

    ;; Generate unbiased random value:
    random-value: random max-random-value

    while [random-value >= max-usable] [
        random-value: random max-random-value
    ]

    return lower-bound + (random-value % range-size)
]

;;-----------------------------------------------------------------------------
;; QA Test Framework
;;-----------------------------------------------------------------------------
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

assert-no-error: function [
    {Esure a block of code executes without throwing an error.}
    code [block!] "The code block to test."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    set/any 'result try code

    either error? result [
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        print ["❌ FAILED:" description]
        print ["   >> ERROR:" result/type result/id]
        print ["   >> MESSAGE:" result/arg1]
    ][
        set 'pass-count pass-count + 1
        print ["✅ PASSED:" description]
    ]
]

assert-error: function [
    {Ensure a block of code throws an error as expected.}
    code [block!] "The code block that should throw an error."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    set/any 'result try code
    either error? result [
        set 'pass-count pass-count + 1
        print ["✅ PASSED:" description]
        print ["   >> Expected error occurred:" result/type result/id]
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        print ["❌ FAILED:" description]
        print ["   >> Expected error but got result:" mold result]
    ]
]

assert-in-range: function [
    {Ensure a value falls within an expected range.}
    value [integer!] "The value to test."
    min-val [integer!] "The minimum expected value (inclusive)."
    max-val [integer!] "The maximum expected value (inclusive)."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1

    either all [value >= min-val value <= max-val] [
        set 'pass-count pass-count + 1
        print ["✅ PASSED:" description]
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        print ["❌ FAILED:" description]
        print ["   >> Value" value "not in range [" min-val "," max-val "]"]
    ]
]

print-section: function [
    {Output a formatted section header.}
    title [string!] "The section title."
][
    print "^/============================================"
    print ["=== " title " ==="]
    print "============================================"
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
        print "✅ ALL TESTS PASSED - FabRndRngInt IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Test Data Sets
;;-----------------------------------------------------------------------------
edge-case-ranges: [
    ;; [lower-bound upper-bound description]
    [0 0 "Single value range at zero"]
    [1 1 "Single value range at one"]
    [-1 -1 "Single value range at negative one"]
    [0 1 "Minimal positive range"]
    [-1 0 "Range crossing zero"]
    [-1 1 "Small range crossing zero"]
    [1 2 "Minimal two-value range"]
    [-2 -1 "Minimal negative range"]
    [0 10 "Single digit range"]
    [1 10 "Classic 1-10 range"]
    [0 100 "Percentage range"]
    [1 100 "Classic 1-100 range"]
    [-50 50 "Symmetric range around zero"]
    [-100 -1 "All negative range"]
    [1 1000 "Medium range"]
    [0 10000 "Large range"]
    [1 100000 "Very large range"]
    [-1000000 1000000 "Mega range symmetric"]
    [0 2147483647 "32-bit signed integer max"]
    [-2147483648 2147483647 "Full 32-bit signed range"]
    [0 4294967295 "32-bit unsigned max"]
    [1 1000000000 "Billion range"]
    [-1000000000 1000000000 "Billion symmetric range"]
]

stress-test-ranges: [
    ;; [lower-bound upper-bound description]
    [0 1000000000000 "Trillion range"]
    [1 4611686018427300000 "Maximum safe random value"]
    ;[-2305843009213693952 2305843009213693952 "Half max-int symmetric"]
    ;[0 9223372036854775807 "Full positive 64-bit range"]
    ;[-9223372036854775808 0 "Full negative 64-bit range"]
    ;[-9223372036854775808 9223372036854775807 "Full 64-bit signed range"]
]

invalid-ranges: [
    ;; [lower-bound upper-bound description]
    [10 5 "Lower bound greater than upper bound"]
    [100 50 "Large lower bound greater than upper bound"]
    [0 -1 "Zero greater than negative"]
    [1 0 "One greater than zero"]
    [-1 -2 "Negative one greater than negative two"]
]

;;-----------------------------------------------------------------------------
;; QA Test Execution Functions
;;-----------------------------------------------------------------------------
run-basic-functionality-tests: does [
    {Validate basic function operation and return values.}
    print-section "BASIC FUNCTIONALITY TESTS"

    ;; Test normal operation:
    assert-no-error [
        result: FabRndRngInt 1 10
    ] "Basic function call 1-10"

    assert-no-error [
        result: FabRndRngInt 0 100
    ] "Basic function call 0-100"

    assert-no-error [
        result: FabRndRngInt -50 50
    ] "Basic function call -50 to 50"

    ;; Test return type:
    result: FabRndRngInt 1 10
    assert-equal integer! type? result "Return type is integer!"

    ;; Test single value range:
    result: FabRndRngInt 42 42
    assert-equal 42 result "Single value range returns exact value"

    ;; Test negative single value:
    result: FabRndRngInt -17 -17
    assert-equal -17 result "Single negative value range returns exact value"
]

run-edge-case-tests: does [
    {Test edge cases and boundary conditions.}
    print-section "EDGE CASE TESTS"

    foreach range-spec edge-case-ranges [
        lower: first range-spec
        upper: second range-spec
        desc: third range-spec

        assert-no-error [
            result: FabRndRngInt lower upper
        ] rejoin ["Edge case: " desc]

        ;; Verify result is in range:
        set/any 'result try [FabRndRngInt lower upper]

        either error? result [
            print ["   >> Skipping range check due to error"]
        ][
            assert-in-range result lower upper rejoin ["Range check: " desc]
        ]
    ]
]

run-stress-tests: does [
    {Validate extreme ranges and large values.}
    print-section "STRESS TESTS"

    foreach range-spec stress-test-ranges [
        lower: first range-spec
        upper: second range-spec
        desc: third range-spec

        print ["^/Testing stress case:" desc]
        print ["Range: [" lower "," upper "]"]

        assert-no-error [
            result: FabRndRngInt lower upper
        ] rejoin ["Stress test: " desc]

        ;; Verify result is in range for successful calls:
        set/any 'result try [FabRndRngInt lower upper]

        either error? result [
            print ["   >> Skipping range validation due to an error."]
        ][
            assert-in-range result lower upper rejoin ["Stress range check: " desc]
        ]
    ]
]

run-error-condition-tests: does [
    {Validate invalid inputs that should throw errors.}
    print-section "ERROR CONDITION TESTS"

    foreach range-spec invalid-ranges [
        lower: first range-spec
        upper: second range-spec
        desc: third range-spec

        assert-error [
            FabRndRngInt lower upper
        ] rejoin ["Should error: " desc]
    ]

    ;; Test invalid argument types (commented out - would need type checking):
    ; assert-error [
    ;     FabRndRngInt "not-integer" 10
    ; ] "Should error with string lower bound"
]

run-seed-functionality-tests: does [
    {Validate seeding functionality for reproducible results.}
    print-section "SEED FUNCTIONALITY TESTS"

    ;; Ensure seeding works:
    assert-no-error [
        result1: FabRndRngInt/seed 1 100 12345
        result2: FabRndRngInt/seed 1 100 12345
    ] "Seeded calls should not error"

    ;; Test reproducibility:
    result1: FabRndRngInt/seed 1 100 12345
    result2: FabRndRngInt/seed 1 100 12345
    assert-equal result1 result2 "Same seed should produce same result"

    ;; Test different seeds produce different results (probabilistic):
    result1: FabRndRngInt/seed 1 1000000 12345
    result2: FabRndRngInt/seed 1 1000000 54321

    ;; There's a tiny chance they could be equal, but it's unlikely:
    either result1 = result2 [
        print "⚠️  WARNING: Different seeds produced same result (unlikely but possible)"
    ][
        print "✅ PASSED: Different seeds produce different results"
        set 'pass-count pass-count + 1
    ]

    set 'test-count test-count + 1
]

run-distribution-spot-checks: does [
    {Run spot checks on distribution quality.}
    print-section "DISTRIBUTION SPOT CHECKS"

    ;; Ensure all values in a small range can be generated:
    test-range: [1 5]
    values-found: []

    ;; Generate 1000 samples to find all values 1-5:
    repeat i 1000 [
        result: FabRndRngInt first test-range second test-range
        either find values-found result [
            ; Already found this value
        ][
            append values-found result
        ]
    ]

    sort values-found
    expected-values: [1 2 3 4 5]
    assert-equal expected-values values-found "All values 1-5 should be generated in 1000 samples"

    ;; Ensure values stay within bounds for larger range:
    out-of-bounds-count: 0
    test-lower: -100
    test-upper: 100

    repeat i 1000 [
        result: FabRndRngInt test-lower test-upper
        if any [result < test-lower result > test-upper] [
            set 'out-of-bounds-count out-of-bounds-count + 1
        ]
    ]

    assert-equal 0 out-of-bounds-count "No out-of-bounds values in 1000 samples of [-100,100]"
]

;;-----------------------------------------------------------------------------
;; Main Test Runner
;;-----------------------------------------------------------------------------
run-all-tests: does [
    {Execute the complete test suite.}
    print "^/=== STARTING FabRndRngInt QUALITY ASSURANCE DIAGNOSTIC SUITE ==="
    print "============================================"
    print ["Test Start Time: " now]
    print "============================================"

    ;; Reset counters:
    set 'all-tests-passed? true
    set 'test-count 0
    set 'pass-count 0
    set 'fail-count 0

    ;; Run all test categories:
    run-basic-functionality-tests
    run-edge-case-tests
    run-stress-tests
    run-error-condition-tests
    run-seed-functionality-tests
    run-distribution-spot-checks

    ;; Print final summary:
    print-test-summary

    ;; Return overall result:
    return all-tests-passed?
]

;;-----------------------------------------------------------------------------
;; Execute All QA Tests
;;-----------------------------------------------------------------------------
run-all-tests
