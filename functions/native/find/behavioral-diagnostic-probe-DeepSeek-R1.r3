Rebol []

;;-----------------------------------------------------------------------------
;; Diagnostic Probe Script for FIND function
;; Target: REBOL/Bulk 3.19.0 (Oldes Branch)
;; Purpose: Systematically probe and document FIND behavior through test cases
;;-----------------------------------------------------------------------------

;; QA Test Harness - DO NOT MODIFY
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

;; Test Setup
;;-----------------------------------------------------------------------------
print {=== Starting FIND Function Diagnostics ===^/}

;; Group 1: Basic Series Search Behavior (Confirmed)
;;-----------------------------------------------------------------------------
print "^/=== Group 1: Basic Series Search Behavior ==="

test-str: "abcdef"
assert-equal "cdef" find test-str "c" {FIND in string returns substring at match position}
assert-equal none find test-str "x" {FIND returns none when no match in string}

test-blk: [a b c d e]
assert-equal [c d e] find test-blk 'c {FIND in block returns sub-block at match position}
assert-equal none find test-blk 'x {FIND returns none when no match in block}

test-int: [10 20 30 40]
assert-equal [30 40] find test-int 30 {FIND finds integer values in blocks}
assert-equal none find test-int 99 {FIND returns none for missing integers}

;; Group 2: /only Refinement (Confirmed)
;;-----------------------------------------------------------------------------
print "^/=== Group 2: /only Refinement ==="

test-nested: [[a b] [c d] [e f]]
assert-equal none find test-nested [c d] {FIND without /only doesn't find nested block as pattern}
assert-equal [[c d] [e f]] find/only test-nested [c d] {FIND/only finds exact block element}

test-mixed: [a [b c] d]
assert-equal [[b c] d] find/only test-mixed [b c] {FIND/only returns sub-block from match position}

;; Group 3: /case and /same Refinements (Confirmed)
;;-----------------------------------------------------------------------------
print "^/=== Group 3: /case and /same Refinements ==="

test-case: "aBcDeF"
assert-equal "BcDeF" find test-case "B" {FIND without /case is case-insensitive}
assert-equal none find/case test-case "b" {FIND/case requires exact case match}

obj1: make object! [a: 1]
obj2: make object! [a: 1]
test-same: reduce [obj1 123 obj2]
assert-equal test-same find test-same obj1 {FIND without /same matches objects by value}
assert-equal reduce [obj2] find/same test-same obj2 {FIND/same matches exact same object}

;; Group 4: /part and /skip Refinements (Confirmed)
;;-----------------------------------------------------------------------------
print "^/=== Group 4: /part and /skip Refinements ==="

test-part: "abcdefghijk"
assert-equal "cdefghijk" find/part test-part "c" 5 {FIND/part returns full tail after match}
assert-equal none find/part test-part "h" 5 {FIND/part doesn't find beyond range}

test-skip: [1 "a" 2 "b" 3 "c"]
assert-equal [3 "c"] find/skip test-skip 3 2 {FIND/skip finds first element in fixed-size records}
assert-equal none find/skip test-skip "a" 2 {FIND/skip only searches first element of each record}

;; Group 5: /last, /reverse and /tail Refinements - CORRECTED
;; Hypothesis: /reverse searches backwards from current position
;;-----------------------------------------------------------------------------
print "^/=== Group 5: /last, /reverse and /tail Refinements (Corrected) ==="

test-last: "abcabc"
assert-equal "abcabc" find test-last "a" {FIND returns full tail from first match}
assert-equal "abc" find/last test-last "a" {FIND/last returns tail from last match}

test-rev: "12345"
; Start at tail and search backwards for "4"
assert-equal "45" find/reverse tail test-rev "4" {FIND/reverse from tail finds element and returns tail}

; CORRECTED: Start at position after "3" (at "4") and search backwards for "3"
assert-equal "345" find/reverse skip test-rev 3 "3" {FIND/reverse searches backwards from position and finds element before it}

; Should not find "5" when starting at position 3
assert-equal none find/reverse skip test-rev 2 "5" {FIND/reverse doesn't find elements after start}

test-tail: "abcdef"
assert-equal tail test-tail find/tail test-tail "f" {FIND/tail returns position after match}
assert-equal none find/tail test-tail "x" {FIND/tail returns none when not found}

;; Group 6: /any and /with Wildcards (Confirmed)
;;-----------------------------------------------------------------------------
print "^/=== Group 6: /any and /with Wildcards ==="

test-wild: "file.txt"
assert-equal "file.txt" find/any test-wild "*.txt" {FIND/any with * returns full string on match}
assert-equal "file.txt" find/any test-wild "f?le.txt" {FIND/any with ? returns full string on match}

test-custom: "file.txt"
assert-equal "file.txt" find/any/with test-custom "f#le.txt" "#" {FIND/with uses custom wildcard}

;; Group 7: /match Refinement (Confirmed)
;;-----------------------------------------------------------------------------
print "^/=== Group 7: /match Refinement ==="

test-match: "abcdefg"
assert-equal "abcdefg" find/match test-match "abc" {FIND/match returns head of series on match}
assert-equal none find/match test-match "xyz" {FIND/match returns none on failure}

;; Group 8: Edge Cases and Error Conditions (Confirmed)
;;-----------------------------------------------------------------------------
print "^/=== Group 8: Edge Cases and Error Conditions ==="

; Empty series handling
assert-equal none find "" "a" {FIND in empty string returns none}
assert-equal none find [] 'a {FIND in empty block returns none}

; None handling
test-none-block: reduce ['a 'b none 'd]
assert-equal next next test-none-block find test-none-block none {FIND finds none in blocks}
assert-equal none find "abc" none {FIND returns none when searching for none in string}

; Error handling for non-series
set/any 'result try [find 12345 3]
assert-equal true error? result {FIND errors on non-series first argument}

;; Test Summary
;;-----------------------------------------------------------------------------
print-test-summary
print {=== FIND Diagnostics Complete ===}
