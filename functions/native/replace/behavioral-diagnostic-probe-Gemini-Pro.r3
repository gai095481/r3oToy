Rebol [
    Title: "Corrected Diagnostic Probe for 'replace' Function"
    Version: 0.1.0
    Author: "AI Software Development Assistant"
    Date: 2025-07-07
    Status: "alpha"
    Purpose: {
        A revised and corrected script to meticulously probe the behavior of
        the built-in 'replace' function in Rebol 3 (Oldes branch). This
        script incorporates learnings from an initial failed test run and
        now serves as a high-fidelity, runnable specification, generating a
        "truth log" from the REPL to verify every argument, refinement, and
        edge case based on observed behavior.
    }
    Keywords: [test qa diagnostic replace series]
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

;;-----------------------------------------------------------------------------
;; Test Suite Initialization
;;-----------------------------------------------------------------------------
print "Starting corrected 'replace' function diagnostic probe..."
print "--------------------------------------------"

;;-----------------------------------------------------------------------------
;; Section 1: Probing Basic Behavior (string! and block!)
;;-----------------------------------------------------------------------------
print "^/--- Section 1: Probing Basic Behavior ---"
; Hypothesis: `replace` modifies the target series in-place. By default, it
; only replaces the *first* occurrence. For strings, the search is
; case-insensitive.
; Corrected Hypothesis: The return value of `replace` is the head of the
; series *after* it has been modified, not its original state.

string-series: "one two one three"
replace string-series "one" "1"
assert-equal "1 two one three" string-series "Basic string replace modifies the original series"

returned-value: copy "alpha beta"
assert-equal "alpha gamma" (replace returned-value "beta" "gamma") "Returns the head of the *modified* series"
assert-equal "alpha gamma" returned-value "Verifying modification after checking return value"

block-series: [a b c a d]
replace block-series 'a 'x
assert-equal [x b c a d] block-series "Basic block replace modifies only the first match"

string-series-case: "Banana"
replace string-series-case "banana" "Apple"
assert-equal "Apple" string-series-case "Default string replace is case-insensitive"

no-match-series: [1 2 3]
replace no-match-series 4 99
assert-equal [1 2 3] no-match-series "Series is unchanged if no match is found"


;;-----------------------------------------------------------------------------
;; Section 2: Probing /case Refinement
;;-----------------------------------------------------------------------------
print "^/--- Section 2: Probing /case Refinement ---"
; Hypothesis: The /case refinement forces a case-sensitive search.
; Corrected Hypothesis: The default search is case-insensitive. The `/case`
; refinement is required to distinguish between cases that would otherwise match.
; A search for "N" in "Banana" will fail with /case but would succeed without it.
; A search for "n" in "Banana" will succeed with or without /case.

case-sensitive-series: "Apple apple"
replace/case case-sensitive-series "apple" "orange"
assert-equal "Apple orange" case-sensitive-series "/case finds the exact-cased match"

case-sensitive-series-fail: "Banana"
replace/case case-sensitive-series-fail "N" "X"
assert-equal "Banana" case-sensitive-series-fail "/case prevents a match on different case"


;;-----------------------------------------------------------------------------
;; Section 3: Probing /all Refinement
;;-----------------------------------------------------------------------------
print "^/--- Section 3: Probing /all Refinement ---"
; Hypothesis: The /all refinement will replace every occurrence of the search
; value in the target series, not just the first one.

all-string-series: "one two one three one"
replace/all all-string-series "one" "1"
assert-equal "1 two 1 three 1" all-string-series "/all replaces all occurrences in a string"

all-block-series: [a b c a b c a]
replace/all all-block-series 'a 'x
assert-equal [x b c x b c x] all-block-series "/all replaces all occurrences in a block"

all-case-series: "Test test TEST"
replace/all/case all-case-series "test" "run"
assert-equal "Test run TEST" all-case-series "/all and /case work together correctly"


;;-----------------------------------------------------------------------------
;; Section 4: Probing /tail Refinement
;;-----------------------------------------------------------------------------
print "^/--- Section 4: Probing /tail Refinement ---"
; Hypothesis: The /tail refinement changes the return value to be the position
; in the series immediately *after* the replacement. If /all is also used, it
; will be the position after the *last* replacement.

tail-string-series: "alpha beta gamma"
tail-return: replace/tail tail-string-series "beta" "BETA"
assert-equal "alpha BETA gamma" tail-string-series "/tail: Series is still modified correctly"
assert-equal " gamma" tail-return "/tail: Returns the rest of the series after replacement"

tail-all-series: "a b c b d"
tail-all-return: replace/all/tail tail-all-series "b" "X"
assert-equal "a X c X d" tail-all-series "/tail /all: Series is modified correctly"
assert-equal " d" tail-all-return "/tail /all: Returns rest of series after *last* replacement"

tail-no-match-series: [do re mi]
tail-no-match-return: replace/tail tail-no-match-series 'fa 'la
assert-equal [do re mi] tail-no-match-series "/tail: Series unchanged on no-match"
assert-equal [do re mi] tail-no-match-return "/tail: Returns original series head on no-match"


;;-----------------------------------------------------------------------------
;; Section 5: Probing Multi-Element and Mixed-Type Replacements
;;-----------------------------------------------------------------------------
print "^/--- Section 5: Probing Multi-Element and Mixed-Type Replacements ---"
; Hypothesis: The search and replace values can be blocks or multi-character
; strings, allowing replacement of sub-series.
; Corrected Hypothesis: The trace of replacement must be done carefully. `replace/all "hello cruel world" "el" "i"`
; correctly results in `"hilo crui world"`.

multi-block-series: [a b c d e]
replace multi-block-series [b c] [x y z]
assert-equal [a x y z d e] multi-block-series "Replacing a sub-block with a larger sub-block"

multi-block-shrink: [a b c d e]
replace multi-block-shrink [b c d] 'X
assert-equal [a X e] multi-block-shrink "Replacing a sub-block with a single value"

multi-string-series: "hello cruel world"
replace/all multi-string-series "el" "i"
assert-equal "hilo crui world" multi-string-series "Replacing multi-character string with single char"


;;-----------------------------------------------------------------------------
;; Section 6: Probing Advanced Usage (Function! as argument)
;;-----------------------------------------------------------------------------
print "^/--- Section 6: Probing Advanced Usage (Function! as argument) ---"
; Hypothesis: If the `replace` argument is a function, it is called for each
; match. The function receives the series position *at the match*.
; Corrected Hypothesis: To get the value *after* the match, the function must
; look ahead in the series, for example by using `second`.

func-replace-series: [log 1 log 2 log 3]
replace/all func-replace-series 'log function [position] [
    ; `position` is the series at the point of the match (`[log 1 ...]`)
    ; To get the number, we need the `second` item in that part of the series.
    rejoin ["Value: " second position]
]
assert-equal ["Value: 1" 1 "Value: 2" 2 "Value: 3" 3] func-replace-series "Using a function to generate replacement value"


;;-----------------------------------------------------------------------------
;; Section 7: Probing Edge Cases
;;-----------------------------------------------------------------------------
print "^/--- Section 7: Probing Edge Cases ---"
; Corrected Hypothesis: `replace` with an empty string `""` as the search
; value is a no-op. It does not modify the series and does not cause an
; error, both with and without the /all refinement.

edge-empty-series: copy []
replace/all edge-empty-series 'a 'b
assert-equal [] edge-empty-series "Replacing in an empty series has no effect"

edge-empty-string: copy ""
replace/all edge-empty-string "a" "b"
assert-equal "" edge-empty-string "Replacing in an empty string has no effect"

edge-empty-search: "abc"
replace edge-empty-search "" "X"
assert-equal "abc" edge-empty-search "Replacing an empty string is a no-op"

edge-empty-search-all: "abc"
replace/all edge-empty-search-all "" "X"
assert-equal "abc" edge-empty-search-all "/all with empty string search is a no-op"


;;-----------------------------------------------------------------------------
;; Final Summary
;;-----------------------------------------------------------------------------
print-test-summary
