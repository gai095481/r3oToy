Rebol []

;;----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;----------------------------------------------------------------------------
all-tests-passed?: true
assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
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
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL TEST CASE EXAMPLES PASSED."
    ][
        print "❌ SOME TEST CASE EXAMPLES FAILED."
    ]
    print "============================================^/"
]

;; Probe Basic Behavior with String Delimiters:
;; Hypothesis: Splitting a string with a string delimiter splits at each occurrence.
assert-equal ["a" "b" "c"] split "a,b,c" "," "Split string with comma delimiter."

;; Hypothesis: Splitting a block with a value delimiter splits at each occurrence.
assert-equal [[1 2] [3 4]] split [1 2 3 4] 2 "Split block with value 2 delimiter."

;; Probe `/parts` Refinement:
;; Hypothesis: Using /parts with integer splits into specified number of parts.
assert-equal ["ab" "cd"] split/parts "abcd" 2 "Split into 2 parts."

;; Hypothesis: Splitting uneven length with /parts results in last part being remainder.
assert-equal ["a" "b" "cde"] split/parts "abcde" 3 "Split into 3 parts with uneven division."

;; Probe `/at` Refinement:
;; Hypothesis: /at with integer splits at specified position.
assert-equal ["ab" "cd"] split/at "abcd" 2 "Split at position 2."

;; Hypothesis: /at with delimiter splits at first occurrence.
assert-equal ["ab" "d"] split/at "abcd" "c" "Split at first occurrence of 'c'."

;; Probing Function as a Delimiter:
;; Hypothesis: Function returning true/false splits into two blocks.
func-test: function [x] [x > 2]
assert-equal [[3 4] [1 2]] split [1 2 3 4] :func-test "Split using function delimiter."

;; Probe Edge Cases:
;; Hypothesis: Splitting empty series returns empty block.
assert-equal [] split [] 1 "Split empty series."

;; Hypothesis: Splitting where delimiter is not present returns entire series as single element.
assert-equal ["abc"] split "abc" "x" "Delimiter not found."

;; Hypothesis: Splitting with delimiter at end adds fill value.
assert-equal ["ab" "c" ""] split "ab,c," "," "Split with delimiter at end adds fill."

;; Probe Other Data Types for Delimiter:
;; Hypothesis: Bitset delimiter splits at matching characters.
bitset-test: make bitset! [#"a" #"b"]
;; Create expected result dynamically to avoid parser issues:
expected-bitset-result: reduce ["" "" "c"]
assert-equal expected-bitset-result split "abc" bitset-test "Split with bitset delimiter."

print-test-summary
