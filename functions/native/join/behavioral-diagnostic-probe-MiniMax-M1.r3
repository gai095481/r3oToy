Rebol [
    Title: "Diagnostic Probe for JOIN Function"
    Purpose: "Systematically test JOIN's behavior across various inputs."
]

;;----------------------------------------------------------------------------
;; Battle-Tested QA Harness
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

; Probing Basic Behavior
; Hypothesis 1: JOIN appends evaluated rest to a copied series if value is a series.
print ["^/=== Probing Basic Series Behavior ==="]

; Define test values first
b-value: 'b  ; Define the word 'b

block-base: [a]
block-rest: [b-value]  ; Use the defined word
assert-equal [a b] join block-base block-rest "Block series concatenation"

string-base: "a"
string-rest: "b"
assert-equal "ab" join string-base string-rest "String series concatenation"

; Hypothesis 2: Non-series values are converted to strings before appending
print ["^/=== Probing Non-Series Value Handling ==="]

int-base: 123
int-rest: 456
assert-equal "123456" join int-base int-rest "Integer to string conversion"

none-base: none
none-rest: "abc"
assert-equal "noneabc" join none-base none-rest "None to string conversion"

; Probing Rest Parameter Evaluation
print ["^/=== Probing Rest Parameter Evaluation ==="]

word-rest: "c"
assert-equal "abc" join "ab" word-rest "Word evaluation in rest position"

block-eval-rest: [123]
assert-equal "ab123" join "ab" block-eval-rest "Block evaluation in rest position"

func-eval-rest: to-string 123
assert-equal "ab123" join "ab" func-eval-rest "Function evaluation in rest position"

; Probing Edge Cases
print ["^/=== Probing Edge Cases ==="]

; Define 'a' to fix undefined variable error
a: 'a

; Empty series handling
empty-block: []
assert-equal [a] join empty-block [a] "Empty block base value"

empty-string: ""
assert-equal "a" join empty-string "a" "Empty string base value"

; Empty rest handling
assert-equal [a] join [a] [] "Empty block rest"

assert-equal "a" join "a" [] "Empty block rest with string base"

; Complex rest structures - Updated expected value
multi-element-rest: [1 "b" #c]
assert-equal "a1bc" join "a" multi-element-rest "Multi-element rest block (values converted to strings)"

; Binary series handling
binary-base: to-binary "a"
binary-rest: to-binary "b"
assert-equal "ab" to-string join binary-base binary-rest "Binary series concatenation"

; Probing Invalid Inputs - Updated expected values based on actual form output
print ["^/=== Probing Invalid Input Handling ==="]

func-base: func [] []
assert-equal "make function! [[][]]" join :func-base [] "Function as base value (form of function)"

func-rest: func [] []
assert-equal "amake function! [[][]]" join "a" :func-rest "Function in rest position (form of function)"

print-test-summary
