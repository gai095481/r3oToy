Rebol []

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
    print "=== TEST SUMMARY ==="
    print "============================================"
    print rejoin ["Total Tests: " test-count]
    print rejoin ["Passed: " pass-count]
    print rejoin ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - FUNCTION IS STABLE"
    ][
        print "❌  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

; Probing basic swap between two blocks at initial positions.
block1: [a b c]
block2: [1 2 3]
swap block1 block2
assert-equal [1 b c] block1 "Swap two blocks at initial positions - block1 modified"
assert-equal [a 2 3] block2 "Swap two blocks at initial positions - block2 modified"

; Probing swap when series2 is at position2.
block1a: [a b c]
block2a: [1 2 3]
block2a: next block2a  ; position2
swap block1a block2a
assert-equal [2 b c] block1a "Swap elements when series2 is at position2 - block1 modified"
assert-equal [a 3] block2a "Swap elements when series2 is at position2 - block2 modified"

; Probing swap within the same series.
s3: [a b c]
s1-3: s3
s2-3: s3
s2-3: next s2-3  ; position2
swap s1-3 s2-3
assert-equal [b a c] s3 "Swap within same series"

; Probing swap between block and string.
block4: [x y z]
str4: "abc"
either error? try [swap str4 block4][
    error-occurred-4: true
][
    error-occurred-4: false
]
assert-equal true error-occurred-4 "Swap between block and string should error"

; Probing swap with single-element series.
s1-5: [a]
s2-5: [1]
swap s1-5 s2-5
assert-equal [1] s1-5 "Swap single-element series: s1 modified"
assert-equal [a] s2-5 "Swap single-element series: s2 modified"

; Probing edge case: swap with empty series does not error.
empty-block-6: []
s3-6: [1]
either error? try [swap empty-block-6 s3-6][
    error-occurred-6: true
][
    error-occurred-6: false
]
assert-equal false error-occurred-6 "Swap with empty series does not error"

; Probing invalid input: swap with numbers.
either error? try [swap 1 2][
    error-occurred-7: true
][
    error-occurred-7: false
]
assert-equal true error-occurred-7 "Swap with invalid input (numbers) should error"

print-test-summary
