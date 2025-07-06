Rebol [
    Title: "JOIN Function Diagnostic Probe"
    Author: "Expert Rebol Engineer"
    Date: 2025-07-07
]

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
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

print "=== 🧪 JOIN Function Diagnostic Probe ===^/"

; Probing Basic Behavior
; Hypothesis: JOIN appends rest to value as elements, respecting series types.
; Test block + block, string + string, block + single value.

case_1_value: [1 2]
case_1_rest: [3 4]
case_1_result: join case_1_value case_1_rest
assert-equal [1 2 3 4] case_1_result "JOIN block! + block! produces merged block!"

case_2_value: "ab"
case_2_rest: "cd"
case_2_result: join case_2_value case_2_rest
assert-equal "abcd" case_2_result "JOIN string! + string! produces concatenated string!"

case_3_value: [a b]
case_3_rest: 'c ; Fixed: Use quoted word instead of undefined variable
case_3_result: join case_3_value case_3_rest
assert-equal [a b c] case_3_result "JOIN block! + single value appends as element"

; Probing Non-Series Value Handling
; Hypothesis: Non-series values are converted to strings and concatenated.

case_4_value: 123
case_4_rest: "45"
case_4_result: join case_4_value case_4_rest
assert-equal "12345" case_4_result "JOIN integer + string produces concatenated string!"

case_5_value: true
case_5_rest: "suffix"
case_5_result: join case_5_value case_5_rest
assert-equal "truesuffix" case_5_result "JOIN logic! + string concatenates"

; Probing Rest as Block of Values
; Hypothesis: When rest is a block, all elements are appended as individual elements.

case_6_value: [1]
case_6_rest: [2 3]
case_6_result: join case_6_value case_6_rest
assert-equal [1 2 3] case_6_result "JOIN block! + [block!...] appends each element"

; Probing Edge Cases
; Hypothesis: JOIN handles empty series and edge types correctly.

case_7_value: ""
case_7_rest: "end"
case_7_result: join case_7_value case_7_rest
assert-equal "end" case_7_result "JOIN empty string! + string! produces rest"

case_8_value: []
case_8_rest: ['item] ; Fixed: Use quoted word to avoid evaluation
case_8_result: join case_8_value case_8_rest
assert-equal ['item] case_8_result "JOIN empty block! + block! produces rest"

case_9_value: 0
case_9_rest: "zero"
case_9_result: join case_9_value case_9_rest
assert-equal "0zero" case_9_result "JOIN zero integer + string concatenates"

case_10_value: "a"
case_10_rest: none
case_10_result: join case_10_value case_10_rest
assert-equal "anone" case_10_result "JOIN string! + none forms and appends"

; Probing Binary! Type Behavior
; Hypothesis: JOIN handles binary values by appending bytes.

case_11_value: #{00}
case_11_rest: #{FF}
case_11_result: join case_11_value case_11_rest
assert-equal #{00FF} case_11_result "JOIN binary! + binary! appends bytes"

print-test-summary
