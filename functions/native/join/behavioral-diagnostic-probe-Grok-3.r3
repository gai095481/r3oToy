Rebol [
    Title: "Diagnostic Probe for the JOIN Function"
    Purpose: "Systematically test the behavior of the JOIN function in Rebol 3 Oldes branch."
    Version: 0.1.0
    Date: 6-Jul-2025
]

;; Battle-Tested QA Harness
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

;; Probing Basic Behavior with block!
; Hypothesis: When value is a block! and rest is a single value, join appends the value to a copy of the block.
assert-equal [1 2 3] (join [1 2] 3) "Joining block with single integer"

; Hypothesis: When value is a block! and rest is a block!, join appends all elements of rest to a copy of value.
assert-equal [1 2 3 4] (join [1 2] [3 4]) "Joining block with another block"

;; Probing Basic Behavior with string!
; Hypothesis: When value is a string! and rest is a string!, join concatenates the strings.
assert-equal "hello world" (join "hello " "world") "Joining strings"

; Hypothesis: When value is a string! and rest is a block!, join appends the string representations of the block elements without spaces.
assert-equal "test" (join "t" ["e" "s" "t"]) "Joining string with block of strings"

;; Probing Behavior with file!
; Hypothesis: When value is a file! and rest is a string!, join appends the string to the file name.
assert-equal %file.txt (join %file ".txt") "Joining file with string"

;; Probing Behavior with url!
; Hypothesis: When value is a url! and rest is a block!, join appends the block elements to the url, converting types as needed.
assert-equal http://www.rebol.com/index.html (join http:// ["www.rebol.com/" %index.html]) "Joining url with block containing string and file"

;; Probing Behavior with Scalar Types
; Hypothesis: When value is an integer! and rest is a string!, join converts the integer to a string and appends rest.
assert-equal "123abc" (join 123 "abc") "Joining integer with string"

; Hypothesis: When value is a logic! and rest is a logic!, join converts both to strings and concatenates them.
assert-equal "truefalse" (join true false) "Joining logic values"

; Hypothesis: When value is a word! and rest is a string!, join forms the word to a string and appends rest.
assert-equal "hello world" (join 'hello " world") "Joining word with string"

;; Probing Edge Cases
; Hypothesis: Joining an empty block with a single value appends the value to a new block.
assert-equal [3] (join [] 3) "Joining empty block with integer"

; Hypothesis: Joining a block with an empty block returns a copy of the original block.
assert-equal [1 2] (join [1 2] []) "Joining block with empty block"

; Hypothesis: Joining a string with an empty string returns the original string.
assert-equal "hello" (join "hello" "") "Joining string with empty string"

; Hypothesis: Joining an empty string with a block concatenates the block elements to an empty string.
assert-equal "abc" (join "" ["a" "b" "c"]) "Joining empty string with block of strings"

;; Probing Behavior with Evaluated Blocks
; Hypothesis: When rest is a block containing defined words, join reduces the block, evaluating the words, and appends the results.
a-value: 2
b-value: 3
assert-equal [1 2 3] (join [1] [a-value b-value]) "Joining block with block of defined words"

;; Probing Error Cases
; Hypothesis: Joining with a block containing undefined words causes an error, which we catch and verify.
; Note: This test checks for error handling by attempting to join with undefined words.
error-result: try [join [1] [undefined-word]]
assert-equal true (error? error-result) "Joining block with block containing undefined word causes error"

;; Print Test Summary
print-test-summary
