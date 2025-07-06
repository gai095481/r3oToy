Rebol [
    Title: "Diagnostic Probe Script for split"
    Purpose: {Comprehensive behavioral probe for the split function.}
]

;;-----------------------------------------------------------------------------
;; Test Harness Functions (Provided)
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
;; Diagnostic Probe for SPLIT
;;-----------------------------------------------------------------------------
print "=== STARTING DIAGNOSTIC PROBE FOR SPLIT ==="

;;------------------------------------------------------------------------------
;; Hypothesis: Basic string splitting by character delimiter should produce blocks
;;             of substrings separated by the delimiter.
;;------------------------------------------------------------------------------
print "^/=== Probing Basic String Splitting ==="

test-str: "apple,banana,cherry"
assert-equal ["apple" "banana" "cherry"] split test-str #","
    "Char delimiter splits string"

test-str: "one;two;three"
assert-equal ["one" "two" "three"] split test-str ";"
    "String delimiter splits string"

test-str: "a|b|c"
assert-equal ["a" "b" "c"] split test-str "|"
    "Single-character string delimiter"

;;------------------------------------------------------------------------------
;; Hypothesis: Block splitting by integer size should create chunks of fixed length
;;             (without /parts refinement).
;;------------------------------------------------------------------------------
print "^/=== Probing Fixed-Size Splitting (Integer dlm) ==="

test-block: [1 2 3 4 5 6]
assert-equal [[1 2] [3 4] [5 6]] split test-block 2
    "Even-sized chunks from block"

test-str: "abcdef"
assert-equal ["ab" "cd" "ef"] split test-str 2
    "Even-sized chunks from string"

test-block: [a b c]
assert-equal [[a b] [c]] split test-block 2
    "Last chunk smaller than fixed size"

;;------------------------------------------------------------------------------
;; Hypothesis: /parts refinement with integer dlm splits series into exactly
;;             n pieces using floor division for piece sizes.
;;------------------------------------------------------------------------------
print "^/=== Probing /parts Refinement ==="

test-str: "RebolLanguage"
assert-equal ["Re" "bo" "lL" "an" "guage"] split/parts test-str 5
    "Split string into exactly 5 pieces using floor division"

test-block: [1 2 3 4]
assert-equal [[1] [2] [3 4]] split/parts test-block 3
    "Split block into exactly 3 pieces"

test-str: "abc"
assert-equal ["a" "b" "c"] split/parts test-str 3
    "Exact piece count matches series length"

;;------------------------------------------------------------------------------
;; Hypothesis: /at refinement splits series into exactly two parts at specified
;;             position (integer) or first delimiter occurrence (non-integer).
;;------------------------------------------------------------------------------
print "^/=== Probing /at Refinement ==="

test-str: "hello-world"
assert-equal ["hello" "world"] split/at test-str #"-"
    "/at with char delimiter"

test-block: [a b c d]
assert-equal [[a b] [c d]] split/at test-block 2
    "/at with integer position (1-based index)"

test-str: "nodelimiter"
assert-equal ["nodelimiter"] split/at test-str #"|"
    "/at with delimiter not found returns single element"

;;------------------------------------------------------------------------------
;; Hypothesis: Function delimiters should partition elements into two blocks:
;;             [elements where func returns truthy, elements where func returns falsey]
;;------------------------------------------------------------------------------
print "^/=== Probing Function Delimiter Behavior ==="

;; Non-recursive function definitions
even-pred: func [x] [0 = (x // 2)]  ; Avoids recursion
test-block: [11 20 31 40 51]        ; Mixed even/odd
assert-equal [[20 40] [11 31 51]] split test-block :even-pred
    "Function splits numbers by even? predicate without recursion"

digit-pred: func [c] [find "0123456789" c]  ; Returns series position or none
test-str: "a1b2c3"
assert-equal [[#"1" #"2" #"3"] [#"a" #"b" #"c"]] split test-str :digit-pred
    "Function splits chars by digit? predicate without recursion"

;;------------------------------------------------------------------------------
;; Hypothesis: Edge cases should handle empties, not-found, and invalid inputs
;;             according to observed behavior.
;;------------------------------------------------------------------------------
print "^/=== Probing Edge Cases (Corrected) ==="

;; Empty series handling
assert-equal [] split "" #"," "Empty string returns empty block"
assert-equal [] split [] 2 "Empty block returns empty block"

;; Delimiter not in series
assert-equal ["nodelims"] split "nodelims" #"," "Char delimiter not found"
assert-equal [[a b c]] split [a b c] ";" "String delimiter not found"

;; Zero and negative integers (expected errors)
;; Corrected error-test to return logic! instead of block
error-test: func [code] [
    error? try [do code]
]
assert-equal true error-test [split "test" 0] "dlm=0 should cause error"
assert-equal true error-test [split/parts [1 2 3] -1] "Negative /parts should error"

;; Splitting at position beyond length
assert-equal ["abc" ""] split/at "abc" 4 "Split beyond end produces empty tail"

;;------------------------------------------------------------------------------
;; Hypothesis: Bitset delimiters should split at any character in the set
;;------------------------------------------------------------------------------
print "^/=== Probing Bitset Delimiters ==="

vowels: charset "aeiou"
test-str: "hello world"
assert-equal ["h" "ll" " w" "rld"] split test-str vowels
    "Split at vowel characters using bitset"

;;------------------------------------------------------------------------------
;; Hypothesis: Final empty element should be added when delimiter ends the series
;;             except for /parts refinement which doesn't add empty blocks
;;------------------------------------------------------------------------------
print "^/=== Probing Trailing Delimiter Behavior (Corrected) ==="

test-str: "a,b,c,"
assert-equal ["a" "b" "c" ""] split test-str #","
    "Trailing comma produces trailing empty string"

test-block: [1 2 3 4]
assert-equal [[1] [2] [3 4]] split/parts test-block 3
    "/parts refinement does NOT add empty blocks for trailing elements"

;;------------------------------------------------------------------------------
;; Print final test summary
;;------------------------------------------------------------------------------
print-test-summary
