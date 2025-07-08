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

;----------------------------------------------------------------------------
; Probing Basic Behavior
;----------------------------------------------------------------------------
; Hypothesis: FIND returns the subseries starting at the found value in a block.
block-series: [1 2 3 4]
expected-block-result: [2 3 4]
assert-equal expected-block-result find block-series 2 "Basic find in block returns subseries"

; Hypothesis: FIND returns the substring starting at the found character in a string.
string-series: "abcdef"
expected-string-result: "bcdef"
assert-equal expected-string-result find string-series #b "Basic find in string returns substring"

; Hypothesis: FIND returns none if value is not found.
not-found-series: [1 2 3]
assert-equal none find not-found-series 4 "Basic find not found returns none"

;----------------------------------------------------------------------------
; Probing /part Refinement
;----------------------------------------------------------------------------
; Hypothesis: /part with a number limits the search to that many elements from the start.
block-series: [1 2 3 4 5]
assert-equal none find/part block-series 3 2 "Find with /part limits search range"

; Hypothesis: /part with a number allows finding within the specified range.
assert-equal [3 4 5] find/part block-series 3 3 "Find with /part includes the element at range"

;----------------------------------------------------------------------------
; Probing /only Refinement
;----------------------------------------------------------------------------
; Hypothesis: /only treats the value as a single value even if it's a series.
block-series: [1 2 [3 4] 5]
value-block: [3 4]
expected-result: [[3 4] 5]
assert-equal expected-result find/only block-series value-block "Find with /only matches block element"

;----------------------------------------------------------------------------
; Probing /case Refinement
;----------------------------------------------------------------------------
; Hypothesis: Without /case, find is case-insensitive.
string-series: "Abc"
assert-equal "bc" find string-series "b" "Case-insensitive find finds lowercase in mixed case"

; Hypothesis: With /case, find is case-sensitive.
assert-equal none find/case string-series #a "Case-sensitive find does not find lowercase in uppercase start"

;----------------------------------------------------------------------------
; Probing /same Refinement
;----------------------------------------------------------------------------
; Hypothesis: /same uses same? comparator, requiring the same identity.
block1: [1 2]
block2: [1 2]
series: [block1]
; Without /same, equality is checked.
assert-equal [block1] find series 'block1 "Find without /same checks equality"

; With /same, same? is required.
assert-equal none find/same series [1 2] "Find with /same requires same identity"

;----------------------------------------------------------------------------
; Probing /any Refinement
;----------------------------------------------------------------------------
; Hypothesis: /any enables * and ? wildcards.
string-series: "abcdef"
pattern: "a*d"
assert-equal "abcdef" find/any string-series pattern "Find with /any matches wildcard pattern"

;----------------------------------------------------------------------------
; Probing /with Refinement
;----------------------------------------------------------------------------
; Hypothesis: /with allows custom wildcards (requires /any for wildcard matching).
string-series: "aXXXd"
wild-pattern: "a!d"
wild-string: "!"  ; * is represented by '!'
assert-equal "aXXXd" find/any/with string-series wild-pattern wild-string "Find with /any/with uses custom wildcard"

; Hypothesis: /skip treats the series as fixed-size records.
block-series: [1 2 3 4 5 6]
value: [3 4]
size: 2
expected-result: [3 4 5 6]
assert-equal expected-result find/skip block-series value size "Find with /skip matches record"

;----------------------------------------------------------------------------
; Probing /last Refinement
;----------------------------------------------------------------------------
; Hypothesis: /last searches backwards from the end.
string-series: "abcabc"
value: #a
expected-result: "abc"
assert-equal expected-result find/last string-series value "Find with /last finds last occurrence"

;----------------------------------------------------------------------------
; Probing /reverse Refinement
;----------------------------------------------------------------------------
; Hypothesis: /reverse searches backwards from the current position.
series: "abac"
; Navigate to position 3 (character 'a')
pos: find series #a  ; pos is "abac"
pos: next pos  ; pos is "bac"
pos: next pos  ; pos is "ac"
; Search backwards for #a from pos.
expected-result: "abac"
assert-equal expected-result find/reverse pos #a "Find with /reverse finds previous occurrence"

;----------------------------------------------------------------------------
; Probing /tail Refinement
;----------------------------------------------------------------------------
; Hypothesis: /tail returns the end of the series if found.
block-series: [1 2 3 4]
value: 2
expected-result: [3 4]
assert-equal expected-result find/tail block-series value "Find with /tail returns tail of found series"

;----------------------------------------------------------------------------
; Probing /match Refinement
;----------------------------------------------------------------------------
; Hypothesis: /match returns the head of the match.
block-series: [2 3 4]
value: 2
expected-result: [2 3 4]
assert-equal expected-result find/match block-series value "Find with /match returns head of match"

print-test-summary
