Rebol [
    Title: "Diagnostic Probe Script for REPLACE Function"
    Purpose: "Systematically test all behaviors of the native REPLACE function"
    Author: "Qwen 3 assisted by working scripts by other AI coders."
    Date: 7-Jul-2025
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

print "^/==== DIAGNOSTIC PROBE: REPLACE FUNCTION ===="
print "Systematically testing all behaviors of the native REPLACE function^/"

;;-----------------------------------------------------------------------------
;; Probing Basic String Replacement Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing Basic String Replacement ---"
test-string-1: "hello world hello"
result-1: replace test-string-1 "hello" "hi"
assert-equal "hi world hello" test-string-1 "Basic string replacement modifies target"
assert-equal "hi world hello" result-1 "Basic string replacement returns modified target"

test-string-2: "abc def abc"
result-2: replace test-string-2 "abc" "xyz"
assert-equal "xyz def abc" test-string-2 "First occurrence only replaced by default"
assert-equal "xyz def abc" result-2 "Return value matches modified target"

test-string-3: "no match here"
result-3: replace test-string-3 "xyz" "replacement"
assert-equal "no match here" test-string-3 "No replacement when search not found"
assert-equal "no match here" result-3 "Return value unchanged when no match"

;;-----------------------------------------------------------------------------
;; Probing /ALL Refinement Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing /ALL Refinement ---"
test-string-4: "hello world hello universe hello"
result-4: replace/all test-string-4 "hello" "hi"
assert-equal "hi world hi universe hi" test-string-4 "/all replaces all occurrences"
assert-equal "hi world hi universe hi" result-4 "/all returns modified target"

test-string-5: "aaa bbb aaa ccc aaa"
result-5: replace/all test-string-5 "aaa" "xxx"
assert-equal "xxx bbb xxx ccc xxx" test-string-5 "/all replaces multiple consecutive matches"
assert-equal "xxx bbb xxx ccc xxx" result-5 "/all return value correct"

test-string-6: "single occurrence"
result-6: replace/all test-string-6 "single" "multiple"
assert-equal "multiple occurrence" test-string-6 "/all works with single occurrence"
assert-equal "multiple occurrence" result-6 "/all single occurrence return value"

;;-----------------------------------------------------------------------------
;; Probing /CASE Refinement Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing /CASE Refinement ---"
test-string-7: "Hello World HELLO"
result-7: replace test-string-7 "hello" "hi"
assert-equal "hi World HELLO" test-string-7 "Default replacement is case-insensitive"
assert-equal "hi World HELLO" result-7 "Case-insensitive return value"

test-string-8: "Hello World HELLO"
result-8: replace/case test-string-8 "hello" "hi"
assert-equal "Hello World HELLO" test-string-8 "/case performs case-sensitive matching"
assert-equal "Hello World HELLO" result-8 "/case no match return value"

test-string-9: "Hello World HELLO"
result-9: replace/case test-string-9 "Hello" "hi"
assert-equal "hi World HELLO" test-string-9 "/case matches exact case"
assert-equal "hi World HELLO" result-9 "/case exact match return value"

;;-----------------------------------------------------------------------------
;; Probing /TAIL Refinement Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing /TAIL Refinement ---"
test-string-10: copy "hello world hello"
result-10: replace/tail test-string-10 "hello" "hi"
assert-equal "hi world hello" test-string-10 "/tail modifies target normally"
assert-equal " world hello" result-10 "/tail returns position after replacement"

test-string-11: copy "abc def abc"
result-11: replace/all/tail test-string-11 "abc" "xyz"
assert-equal "xyz def xyz" test-string-11 "/tail with /all modifies target"
assert-equal "" result-11 "/tail with /all returns end position"

test-string-12: copy "no match here"
result-12: replace/tail test-string-12 "xyz" "replacement"
assert-equal "no match here" test-string-12 "/tail with no match leaves target unchanged"
assert-equal "no match here" result-12 "/tail with no match returns original target"

;;-----------------------------------------------------------------------------
;; Probing Combined Refinements
;;-----------------------------------------------------------------------------
print "^/--- Probing Combined Refinements ---"
test-string-13: copy "Hello HELLO hello"
result-13: replace/all/case test-string-13 "hello" "hi"
assert-equal "Hello HELLO hi" test-string-13 "/all + /case replaces all case-sensitive matches"
assert-equal "Hello HELLO hi" result-13 "/all + /case return value"

test-string-14: copy "Hello HELLO hello world hello"
result-14: replace/all/case/tail test-string-14 "hello" "hi"
assert-equal "Hello HELLO hi world hi" test-string-14 "/all + /case + /tail modifies target"
assert-equal "" result-14 "/all + /case + /tail returns end position"

;;-----------------------------------------------------------------------------
;; Probing Block Replacement Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing Block Replacement ---"
test-block-1: [a b c a b c]
result-block-1: replace test-block-1 'a 'x
assert-equal [x b c a b c] test-block-1 "Block replacement modifies target"

test-block-2: [1 2 3 1 2 3]
result-block-2: replace/all test-block-2 1 99
assert-equal [99 2 3 99 2 3] test-block-2 "Block /all replacement"

test-block-3: [hello world hello]
result-block-3: replace/all test-block-3 'hello 'hi
assert-equal [hi world hi] test-block-3 "Block word replacement"

;;-----------------------------------------------------------------------------
;; Probing Multi-Element Block Search/Replace
;;-----------------------------------------------------------------------------
print "^/--- Probing Multi-Element Block Operations ---"
test-block-4: [a b c d a b e f]
result-block-4: replace test-block-4 [a b] [x y]
assert-equal [x y c d a b e f] test-block-4 "Multi-element block sequence replacement"

test-block-5: [a b c a b d a b e]
result-block-5: replace/all test-block-5 [a b] [x y]
assert-equal [x y c x y d x y e] test-block-5 "Multi-element /all replacement"

;;-----------------------------------------------------------------------------
;; Probing Type Conversion Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing Type Conversion ---"
test-string-15: "123 456 123"
result-15: replace test-string-15 123 "num"
assert-equal "num 456 123" test-string-15 "Integer search converted to string"

test-string-16: "word1 word2 word1"
result-16: replace test-string-16 'word1 "replacement"
assert-equal "replacement word2 word1" test-string-16 "Word search converted to string"

;;-----------------------------------------------------------------------------
;; Probing Edge Cases
;;-----------------------------------------------------------------------------
print "^/--- Probing Edge Cases ---"
test-string-17: ""
result-17: replace test-string-17 "anything" "something"
assert-equal "" test-string-17 "Empty string target unchanged"

test-string-18: "test"
result-18: replace test-string-18 "" "x"
assert-equal "test" test-string-18 "Empty search string no replacement"

test-string-19: "hello"
result-19: replace test-string-19 "hello" ""
assert-equal "" test-string-19 "Replacement with empty string"

test-block-6: []
result-block-6: replace test-block-6 'anything 'something
assert-equal [] test-block-6 "Empty block target unchanged"

;;-----------------------------------------------------------------------------
;; Probing Binary Series Behavior (Fixed)
;;-----------------------------------------------------------------------------
print "^/--- Probing Binary Series Behavior ---"
test-binary: copy #{010203}
replace test-binary #{02} #{04}
assert-equal #{010403} test-binary "Binary value replaced correctly"

;;-----------------------------------------------------------------------------
;; Probing Large Replacement Operations
;;-----------------------------------------------------------------------------
print "^/--- Probing Large Replacement Operations ---"
test-string-20: "small small small"
result-20: replace/all test-string-20 "small" "much larger replacement"
assert-equal "much larger replacement much larger replacement much larger replacement" test-string-20 "Large replacement text"

test-string-21: "very long replacement target string"
result-21: replace test-string-21 "very long replacement target string" "short"
assert-equal "short" test-string-21 "Replace entire string with shorter"

;;-----------------------------------------------------------------------------
;; Probing Function as Replacement Value
;;-----------------------------------------------------------------------------
print "^/--- Probing Function as Replacement Value ---"
counter: 0
increment-counter: does [counter: counter + 1 rejoin ["replacement" counter]]
test-string-22: "item item item"
result-22: replace/all test-string-22 "item" :increment-counter
assert-equal "replacement1 replacement2 replacement3" test-string-22 "Function called for each replacement"

print-test-summary
