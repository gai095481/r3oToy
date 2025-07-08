Rebol [
    Title: "Diagnostic Probe for FIND Function"
    Date: 2025-07-09
    Author: "Grok 3 AI Assistant"
    Version: 0.1.2
]

;; Test Harness Functions
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

;; Probing Basic Behavior
print "Probing Basic Behavior"
;; Hypothesis: FIND returns the series at the position where the value is found, or none if not found.
test-series: [1 2 3 4 5]
search-value: 3
expected-result: [3 4 5]
assert-equal expected-result (find test-series search-value) "Finding existing value in block"

search-value: 6
expected-result: none
assert-equal expected-result (find test-series search-value) "Finding non-existing value in block"

test-string: "hello"
search-char: #"l"
expected-result: "llo"
assert-equal expected-result (find test-string search-char) "Finding character in string"

search-substring: "ell"
expected-result: "ello"
assert-equal expected-result (find test-string search-substring) "Finding substring in string"

;; Probing /part Refinement
print "^/Probing /part Refinement"
;; Hypothesis: /part limits the search to the first 'range' elements of the series.
test-series: [1 2 3 4 5]
search-value: 4
range: 3
expected-result: none
assert-equal expected-result (find/part test-series search-value range) "Finding with /part in block (value outside range)"

search-value: 2
expected-result: skip test-series 1  ; [2 3 4 5]
assert-equal expected-result (find/part test-series search-value range) "Finding with /part in block (value within range)"

;; Probing /only Refinement
print "^/Probing /only Refinement"
;; Hypothesis: /only treats a series value as a single element, not a subsequence.
test-series: [[1 2] [3 4] [5 6]]
search-block: [3 4]
expected-result: skip test-series 1  ; [[3 4] [5 6]]
assert-equal expected-result (find/only test-series search-block) "Finding sub-block with /only"

test-series: [1 2 3 4 5]
search-block: [2 3]
expected-result: [2 3 4 5]
assert-equal expected-result (find test-series search-block) "Finding non-element sub-block without /only"

;; Probing /case Refinement
print "^/Probing /case Refinement"
;; Hypothesis: /case enforces case-sensitive search in strings.
test-string: "Hello"
search-char: #"h"
expected-result: none
assert-equal expected-result (find/case test-string search-char) "Finding lowercase in mixed case string with /case"

search-char: #"H"
expected-result: "Hello"
assert-equal expected-result (find/case test-string search-char) "Finding uppercase with /case"

;; Probing /same Refinement
print "^/Probing /same Refinement"
;; Hypothesis: /same uses 'same?' for strict comparison.
test-series: [1 1.0 "1"]
search-value: 1
expected-result: [1 1.0 "1"]
assert-equal expected-result (find/same test-series search-value) "Finding integer with /same"

;; Probing /any and /with Refinements
print "^/Probing /any and /with Refinements"
;; Hypothesis: /any enables * and ? wildcards; /with customizes them.
test-string: "abcde"
pattern: "a*c"
expected-result: "abcde"
assert-equal expected-result (find/any test-string pattern) "Finding with wildcard *"

pattern: "b?d"
expected-result: "bcde"
assert-equal expected-result (find/any test-string pattern) "Finding with wildcard ?"

wild: "*?"
pattern: "a*c"
expected-result: "abcde"
assert-equal expected-result (find/any/with test-string pattern wild) "Finding with custom wildcards *"

;; Probing /skip Refinement
print "^/Probing /skip Refinement"
;; Hypothesis: /skip searches every 'size' elements.
test-series: [1 "a" 2 "b" 3 "c"]
search-value: 2
size: 2
expected-result: skip test-series 2  ; [2 "b" 3 "c"]
assert-equal expected-result (find/skip test-series search-value size) "Finding value at skip position"

search-value: "b"
expected-result: none
assert-equal expected-result (find/skip test-series search-value size) "Not finding value not at skip position"

;; Probing /last Refinement
print "^/Probing /last Refinement"
;; Hypothesis: /last searches backwards for the last occurrence.
test-series: [1 2 3 2 1]
search-value: 2
expected-result: skip test-series 3  ; [2 1]
assert-equal expected-result (find/last test-series search-value) "Finding last occurrence in block"

;; Probing /reverse Refinement
print "^/Probing /reverse Refinement"
;; Hypothesis: /reverse searches backwards from the current position.
test-series: [1 2 3 2 1]
search-value: 2
expected-result: none
assert-equal expected-result (find/reverse test-series search-value) "Finding with /reverse from start"

;; Probing /tail Refinement
print "^/Probing /tail Refinement"
;; Hypothesis: /tail returns the position after the found value.
test-series: [1 2 3]
search-value: 2
expected-result: [3]
assert-equal expected-result (find/tail test-series search-value) "Finding and returning position after value"

;; Probing /match Refinement
print "^/Probing /match Refinement"
;; Hypothesis: /match checks if the series starts with the value.
test-series: [1 2 3]
search-value: 1
expected-result: [1 2 3]
assert-equal expected-result (find/match test-series search-value) "Finding with /match at start"

search-value: 2
expected-result: none
assert-equal expected-result (find/match test-series search-value) "Not finding with /match not at start"

;; Probing Edge Cases
print "^/Probing Edge Cases"
;; Hypothesis: FIND handles edge cases gracefully.
test-series: []
search-value: 1
expected-result: none
assert-equal expected-result (find test-series search-value) "Finding in empty block"

test-series: [1]
search-value: 1
expected-result: [1]
assert-equal expected-result (find test-series search-value) "Finding in single-element block"

test-series: [1 none 3]
search-value: none
expected-result: none
assert-equal expected-result (find test-series search-value) "Finding none in block (note: may not work as expected in some Rebol versions)"

test-series: none
search-value: 1
expected-result: none
assert-equal expected-result (find test-series search-value) "Finding in none series"

print-test-summary
