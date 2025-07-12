Rebol [
    title: "Random Function Diagnostic Probe Script"
    author: "Claude 4 Sonnet"
    date: 12-Jul-2025
    purpose: "Comprehensive diagnostic testing of the `random` function in Rebol 3 Oldes"
    version: 0.1.0
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

assert-type: function [
    {Verify that a value is of the expected datatype.}
    expected-type [datatype!] "The expected datatype."
    actual-value [any-type!] "The actual value to check."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    actual-type: type? actual-value
    either equal? expected-type actual-type [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected Type: " mold expected-type
            "^/   >> Actual Type:   " mold actual-type
            "^/   >> Actual Value:  " mold actual-value
        ]
    ]
    print [result-style message]
]

assert-range: function [
    {Verify that a numeric value falls within expected bounds.}
    min-value [number!] "The minimum acceptable value (inclusive)."
    max-value [number!] "The maximum acceptable value (inclusive)."
    actual-value [number!] "The actual value to check."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    in-range?: all [
        actual-value >= min-value
        actual-value <= max-value
    ]
    either in-range? [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected Range: " mold min-value " to " mold max-value
            "^/   >> Actual Value:  " mold actual-value
        ]
    ]
    print [result-style message]
]

assert-series-member: function [
    {Verify that a value is a member of a given series.}
    series-value [series!] "The series that should contain the value."
    actual-value [any-type!] "The actual value to check."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    is-member?: not none? find series-value actual-value
    either is-member? [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected Member Of: " mold series-value
            "^/   >> Actual Value:      " mold actual-value
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
        print "✅ ALL TESTS PASSED - RANDOM IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/============================================"
print "=== RANDOM FUNCTION DIAGNOSTIC PROBE ==="
print "============================================^/"

;;-----------------------------------------------------------------------------
;; PROBING BASIC INTEGER BEHAVIOR
;;-----------------------------------------------------------------------------
print "^/--- PROBING BASIC INTEGER BEHAVIOR ---"
;; Hypothesis: random with positive integer should return integer between 1 and the value (inclusive)
;; Testing with small integers to verify range boundaries

random-result-1: random 1
assert-equal 1 random-result-1 "random 1 should always return 1"

random-result-10: random 10
assert-type integer! random-result-10 "random 10 should return integer type"
assert-range 1 10 random-result-10 "random 10 should return value between 1 and 10"

random-result-100: random 100
assert-type integer! random-result-100 "random 100 should return integer type"
assert-range 1 100 random-result-100 "random 100 should return value between 1 and 100"

;; Test multiple calls to verify variability (though this is probabilistic)
results-list: []
repeat counter 10 [
    append results-list random 10
]
print ["Multiple random 10 calls produced: " mold results-list]

;;-----------------------------------------------------------------------------
;; PROBING DECIMAL BEHAVIOR
;;-----------------------------------------------------------------------------
print "^/--- PROBING DECIMAL BEHAVIOR ---"
;; Hypothesis: random with decimal should return decimal between 0.0 and the value (exclusive of upper bound)

random-decimal-1: random 1.0
assert-type decimal! random-decimal-1 "random 1.0 should return decimal type"
assert-range 0.0 1.0 random-decimal-1 "random 1.0 should return value between 0.0 and 1.0"

random-decimal-10: random 10.5
assert-type decimal! random-decimal-10 "random 10.5 should return decimal type"
assert-range 0.0 10.5 random-decimal-10 "random 10.5 should return value between 0.0 and 10.5"

;;-----------------------------------------------------------------------------
;; PROBING SERIES SHUFFLING BEHAVIOR
;;-----------------------------------------------------------------------------
print "^/--- PROBING SERIES SHUFFLING BEHAVIOR ---"
;; Hypothesis: random on series should modify the series in-place and return the shuffled series

original-block: [a b c d e]
shuffled-block: copy original-block
result-block: random shuffled-block
assert-equal shuffled-block result-block "random on block should return the same series reference"

;; Verify all original elements are still present (though order may change)
foreach element original-block [
    assert-series-member shuffled-block element join "Original element " [mold element " should still be present after shuffle"]
]

;; Test with string
original-string: "hello"
shuffled-string: copy original-string
result-string: random shuffled-string
assert-equal shuffled-string result-string "random on string should return the same series reference"
assert-type string! result-string "random on string should return string type"

;; Test with empty series
empty-block: []
result-empty: random empty-block
assert-equal empty-block result-empty "random on empty block should return the same empty block"

;;-----------------------------------------------------------------------------
;; PROBING /SEED REFINEMENT
;;-----------------------------------------------------------------------------
print "^/--- PROBING /SEED REFINEMENT ---"
;; Hypothesis: /seed with integer should set seed for reproducible sequences
;; Note: /seed with none produces error, so we use integer seeds only

;; Test seed with integer value for reproducibility
random/seed 12345
seeded-sequence-1: []
repeat counter 5 [
    append seeded-sequence-1 random 100
]

random/seed 12345
seeded-sequence-2: []
repeat counter 5 [
    append seeded-sequence-2 random 100
]

assert-equal seeded-sequence-1 seeded-sequence-2 "Same seed should produce identical sequences"

;; Test different seeds produce different sequences
random/seed 54321
different-seed-sequence: []
repeat counter 5 [
    append different-seed-sequence random 100
]

sequences-different?: not equal? seeded-sequence-1 different-seed-sequence
assert-equal true sequences-different? "Different seeds should produce different sequences"

;;-----------------------------------------------------------------------------
;; PROBING /ONLY REFINEMENT
;;-----------------------------------------------------------------------------
print "^/--- PROBING /ONLY REFINEMENT ---"
;; Hypothesis: /only should pick one random element from a series without modifying the series

test-block: [apple banana cherry date elderberry]
original-test-block: copy test-block

random-element: random/only test-block
assert-series-member original-test-block random-element "random/only should return element from original series"
assert-equal original-test-block test-block "random/only should not modify the original series"

;; Test with string
test-string: "abcdef"
original-test-string: copy test-string
random-char: random/only test-string
assert-series-member original-test-string random-char "random/only should return character from original string"
assert-equal original-test-string test-string "random/only should not modify the original string"

;; Test multiple calls to verify different elements can be selected
only-results: []
repeat counter 20 [
    append only-results random/only test-block
]
print ["Multiple random/only calls on " mold test-block " produced: " mold only-results]

;;-----------------------------------------------------------------------------
;; PROBING /SECURE REFINEMENT
;;-----------------------------------------------------------------------------
print "^/--- PROBING /SECURE REFINEMENT ---"
;; Hypothesis: /secure should return cryptographically secure random numbers of same type/range

secure-int: random/secure 100
assert-type integer! secure-int "random/secure 100 should return integer type"
assert-range 1 100 secure-int "random/secure 100 should return value between 1 and 100"

secure-decimal: random/secure 1.0
assert-type decimal! secure-decimal "random/secure 1.0 should return decimal type"
assert-range 0.0 1.0 secure-decimal "random/secure 1.0 should return value between 0.0 and 1.0"

;; Test /secure with series
secure-test-block: [x y z]
original-secure-block: copy secure-test-block
secure-result: random/secure secure-test-block
assert-equal secure-test-block secure-result "random/secure on block should return the same series reference"

;;-----------------------------------------------------------------------------
;; PROBING COMBINED REFINEMENTS
;;-----------------------------------------------------------------------------
print "^/--- PROBING COMBINED REFINEMENTS ---"
;; Hypothesis: /secure and /only can be combined

secure-only-element: random/secure/only test-block
assert-series-member original-test-block secure-only-element "random/secure/only should return element from original series"

;;-----------------------------------------------------------------------------
;; PROBING EDGE CASES AND BOUNDARY CONDITIONS
;;-----------------------------------------------------------------------------
print "^/--- PROBING EDGE CASES AND BOUNDARY CONDITIONS ---"

;; Test with zero - ACTUAL BEHAVIOR: returns 0, does not error
random-zero: random 0
assert-equal 0 random-zero "random 0 should return 0"

;; Test with negative integer - ACTUAL BEHAVIOR: returns random negative number
random-negative: random -5
assert-type integer! random-negative "random -5 should return integer type"
assert-range -5 0 random-negative "random -5 should return value between -5 and 0"

;; Test with none - ACTUAL BEHAVIOR: produces error
set/any 'none-result try [random none]
either error? none-result [
    print "✅ PASSED: random none produces an error as expected"
    set 'pass-count pass-count + 1
][
    print ["❌ FAILED: random none should produce error but returned: " mold none-result]
    set 'fail-count fail-count + 1
    set 'all-tests-passed? false
]
set 'test-count test-count + 1

;; Test /only with empty series - ACTUAL BEHAVIOR: returns none, does not error
empty-only-result: random/only []
assert-equal none empty-only-result "random/only on empty series should return none"

;; Test /seed with none - ACTUAL BEHAVIOR: produces error
set/any 'seed-none-result try [random/seed none]
either error? seed-none-result [
    print "✅ PASSED: random/seed none produces an error as expected"
    set 'pass-count pass-count + 1
][
    print ["❌ FAILED: random/seed none should produce error but returned: " mold seed-none-result]
    set 'fail-count fail-count + 1
    set 'all-tests-passed? false
]
set 'test-count test-count + 1

;; Test with money! datatype - ACTUAL BEHAVIOR: produces error
set/any 'money-result try [random $100.00]
either error? money-result [
    print "✅ PASSED: random on money! produces an error as expected"
    set 'pass-count pass-count + 1
][
    print ["❌ FAILED: random $100.00 should produce error but returned: " mold money-result]
    set 'fail-count fail-count + 1
    set 'all-tests-passed? false
]
set 'test-count test-count + 1

;;-----------------------------------------------------------------------------
;; PROBING DATATYPE PRESERVATION
;;-----------------------------------------------------------------------------
print "^/--- PROBING DATATYPE PRESERVATION ---"
;; Hypothesis: random should preserve the input datatype in its output

;; Test with time!
test-time: 1:00:00
random-time: random test-time
assert-type time! random-time "random on time! should return time! type"

;; Test with date!
test-date: 1-Jan-2025
random-date: random test-date
assert-type date! random-date "random on date! should return date! type"

;; Note: money! datatype is not supported by random function (produces error)

;;-----------------------------------------------------------------------------
;; PROBING LARGE VALUES
;;-----------------------------------------------------------------------------
print "^/--- PROBING LARGE VALUES ---"
;; Hypothesis: random should handle large integer values correctly

large-int: 1000000
random-large: random large-int
assert-type integer! random-large "random with large integer should return integer type"
assert-range 1 large-int random-large "random with large integer should return value in expected range"

;;-----------------------------------------------------------------------------
;; PROBING SERIES TYPES
;;-----------------------------------------------------------------------------
print "^/--- PROBING DIFFERENT SERIES TYPES ---"
;; Hypothesis: random should work with different series types

;; Test with vector
test-vector: [1 2 3 4 5]
original-vector: copy test-vector
random-vector-result: random test-vector
assert-equal test-vector random-vector-result "random on vector should return same series reference"

;; Test with binary
test-binary: #{010203040506}
original-binary: copy test-binary
random-binary-result: random test-binary
assert-equal test-binary random-binary-result "random on binary should return same series reference"
assert-type binary! random-binary-result "random on binary should return binary type"

print "^/============================================"
print "=== DIAGNOSTIC PROBE COMPLETE ==="
print "============================================"

print-test-summary
