Rebol []

;-----------------------------
; A Battle-Tested QA Harness
;------------------------------
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

; --- Test Cases ---

; Hypothesis: Swapping the first elements of two blocks will exchange their values.
first-block: [1 2 3]
second-block: [a b c]
swap first-block second-block
assert-equal [a 2 3] first-block "Swap first element of two blocks"
assert-equal [1 b c] second-block "Swap first element of two blocks"

; Hypothesis: Swapping elements within the same block will exchange their values.
same-block: [1 2 3 4 5]
swap same-block at same-block 3
assert-equal [3 2 1 4 5] same-block "Swap within the same block"

; Hypothesis: Swapping elements in strings works as expected.
first-string: "hello"
second-string: "world"
swap first-string second-string
assert-equal "wello" first-string "Swap first char of two strings"
assert-equal "horld" second-string "Swap first char of two strings"

; Hypothesis: Attempting to swap elements of different data types will not error, but will produce a predictable result.
error-block: [1 2 3]
error-string: "abc"
swap error-block error-string
assert-equal [#"a" 2 3] error-block "Swap between block and string"
assert-equal "1bc" error-string "Swap between string and block"


; Hypothesis: Swapping the tail of a series with another series.
tail-block1: [1 2 3]
tail-block2: [a b c]
swap tail tail-block1 tail-block2
assert-equal [1 2] tail-block1 "Swap tail of block1"
assert-equal [a b c 3] tail-block2 "Swap tail of block2"

; Hypothesis: Swapping an empty block with another block.
empty-block1: []
empty-block2: [a b c]
swap empty-block1 empty-block2
assert-equal [[a b c]] empty-block1 "Swap empty block with another"
assert-equal [] empty-block2 "Swap empty block with another"

print-test-summary
