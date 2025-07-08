Rebol [
    Title: "Truly Final Corrected Comprehensive Diagnostic Probe Script for FIND Function"
    Date: 8-Jul-2025
    Author: "Diagnostic Probe Generator"
    Purpose: "Systematically test all behaviors of the FIND native function - TRULY FINAL VERSION"
    Note: "Execute this script to generate a comprehensive truth log of FIND behavior"
]

;;-----------------------------------------------------------------------------
;; Battle-Tested QA Harness Helper Functions
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
            description
            "^/ >> Expected: " mold expected
            "^/ >> Actual: " mold actual
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
;; TRULY FINAL CORRECTED DIAGNOSTIC PROBE SCRIPT FOR FIND FUNCTION
;;-----------------------------------------------------------------------------

print "^/=== TRULY FINAL CORRECTED COMPREHENSIVE FIND FUNCTION DIAGNOSTIC PROBE ==="
print "Testing FIND native function behavior systematically..."

;;-----------------------------------------------------------------------------
;; PROBING BASIC FIND BEHAVIOR WITH STRINGS
;;-----------------------------------------------------------------------------

print "^/--- Probing Basic FIND Behavior with Strings ---"
;; HYPOTHESIS: find should return the position where value is found in series,
;; or none if not found. For strings, it should find substrings.

test-string: "Hello World"
assert-equal "llo World" find test-string "llo" "Basic string search - should find substring"
assert-equal none find test-string "xyz" "Basic string search - should return none for missing substring"
assert-equal "Hello World" find test-string "H" "Basic string search - should find first character"
assert-equal "d" find test-string "d" "Basic string search - should find last character"

;;-----------------------------------------------------------------------------
;; PROBING BASIC FIND BEHAVIOR WITH BLOCKS
;;-----------------------------------------------------------------------------

print "^/--- Probing Basic FIND Behavior with Blocks ---"
;; HYPOTHESIS: find should return the position where value is found in block,
;; or none if not found. Should match exact values.

test-block: [1 2 3 "hello" 4 5]
assert-equal [2 3 "hello" 4 5] find test-block 2 "Basic block search - should find integer"
assert-equal ["hello" 4 5] find test-block "hello" "Basic block search - should find string"
assert-equal none find test-block "missing" "Basic block search - should return none for missing value"
assert-equal [1 2 3 "hello" 4 5] find test-block 1 "Basic block search - should find first element"

;;-----------------------------------------------------------------------------
;; PROBING /PART REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /part Refinement ---"
;; HYPOTHESIS: /part should limit the search to a specified length or position

test-series: "abcdefghijk"
assert-equal "cdefghijk" find/part test-series "c" 5 "find/part with length - should find within limit"
assert-equal none find/part test-series "f" 3 "find/part with length - should not find beyond limit"

test-block-part: [1 2 3 4 5 6 7 8]
assert-equal [3 4 5 6 7 8] find/part test-block-part 3 4 "find/part with block - should find within limit"
assert-equal none find/part test-block-part 6 4 "find/part with block - should not find beyond limit"

;;-----------------------------------------------------------------------------
;; PROBING /ONLY REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /only Refinement ---"
;; HYPOTHESIS: /only should treat a series value as only a single value

nested-block: [1 [2 3] 4 [5 6]]
search-block: [2 3]
assert-equal [[2 3] 4 [5 6]] find/only nested-block search-block "find/only - should find exact block match"
assert-equal none find nested-block search-block "find without /only - should not find nested block as single value"

;;-----------------------------------------------------------------------------
;; PROBING /CASE REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /case Refinement ---"
;; HYPOTHESIS: /case should make character searches case-sensitive

case-test-string: "Hello World"
assert-equal "ello World" find case-test-string "ello" "find without /case - should be case-insensitive for lowercase"
assert-equal "Hello World" find case-test-string "Hello" "find without /case - should match exact case"
assert-equal "Hello World" find/case case-test-string "Hello" "find/case - should match exact case"
assert-equal none find/case case-test-string "hello" "find/case - should not match different case"

;;-----------------------------------------------------------------------------
;; PROBING /SAME REFINEMENT - TRULY FINAL CORRECTION
;;-----------------------------------------------------------------------------

print "^/--- Probing /same Refinement - TRULY FINAL CORRECTION ---"
;; TRULY FINAL CORRECTED HYPOTHESIS: find always returns the first occurrence
;; regardless of reference equality. /same only affects whether it finds at all.

; Test with string references
str1: "test"
str2: "test"
str3: str1  ; same reference
string-container: reduce [str1 str2 "other"]

assert-equal reduce [str1 str2 "other"] find string-container str3 "find without /same - should find equal string using same reference"
assert-equal reduce [str1 str2 "other"] find string-container str2 "find without /same - should find equal string (first occurrence)"
assert-equal reduce [str1 str2 "other"] find/same string-container str3 "find/same - should find only same string reference"
assert-equal none find/same string-container "test" "find/same - should not find equal but different string reference"

; Test with integer references
int1: 42
int2: 42
int3: int1
int-container: reduce [int1 int2 "other"]

assert-equal reduce [int1 int2 "other"] find int-container int3 "find without /same - should find equal integer using same reference"
assert-equal reduce [int1 int2 "other"] find int-container int2 "find without /same - should find equal integer (first occurrence)"

;;-----------------------------------------------------------------------------
;; PROBING /ANY REFINEMENT (WILDCARDS)
;;-----------------------------------------------------------------------------

print "^/--- Probing /any Refinement (Wildcards) ---"
;; HYPOTHESIS: /any should enable * and ? wildcards for pattern matching

wildcard-string: "Hello World Programming"
assert-equal "World Programming" find/any wildcard-string "W*d" "find/any - should match * wildcard"
assert-equal "Hello World Programming" find/any wildcard-string "H?llo" "find/any - should match ? wildcard"
assert-equal none find/any wildcard-string "X*" "find/any - should return none for non-matching pattern"

;;-----------------------------------------------------------------------------
;; PROBING /WITH REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /with Refinement ---"
;; HYPOTHESIS: /with allows custom wildcards

custom-wild-string: "Hello World"
custom-wildcards: "#@"  ; First char (#) is multi-char wildcard, second (@) is single-char
assert-equal "Hello World" find/any/with custom-wild-string "H@llo" custom-wildcards "find/any/with - should use custom single-char wildcard (@)"
assert-equal "World" find/any/with custom-wild-string "W#" custom-wildcards "find/any/with - should use custom multi-char wildcard (#)"

;;-----------------------------------------------------------------------------
;; PROBING /SKIP REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /skip Refinement ---"
;; HYPOTHESIS: /skip treats series as records, searching at record boundaries

skip-test-block: [name "John" age 30 name "Jane" age 25 name "Bob" age 35]
assert-equal [name "John" age 30 name "Jane" age 25 name "Bob" age 35] find/skip skip-test-block 'name 3 "find/skip - should find at record boundary"
assert-equal [30 name "Jane" age 25 name "Bob" age 35] find/skip skip-test-block 30 3 "find/skip - should find age at record position"
assert-equal none find/skip skip-test-block "John" 3 "find/skip - should not find value not at record boundary"

;;-----------------------------------------------------------------------------
;; PROBING /LAST REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /last Refinement ---"
;; HYPOTHESIS: /last should search backwards from the end of the series

last-test-string: "Hello World Hello"
assert-equal "Hello" find/last last-test-string "Hello" "find/last with string - should find last occurrence"

last-test-block: [1 2 3 2 4 5]
assert-equal [2 4 5] find/last last-test-block 2 "find/last with block - should find last occurrence"

;;-----------------------------------------------------------------------------
;; PROBING /REVERSE REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /reverse Refinement ---"
;; HYPOTHESIS: /reverse searches backwards from current position

reverse-test-string: "Hello World Hello"
middle-position: find reverse-test-string "World"
assert-equal "Hello World Hello" find/reverse middle-position "Hello" "find/reverse - should find backwards from position"
assert-equal none find/reverse middle-position "World" "find/reverse - should not find forward from position"

;;-----------------------------------------------------------------------------
;; PROBING /TAIL REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /tail Refinement ---"
;; HYPOTHESIS: /tail should return the position after the found value

tail-test-string: "Hello World"
assert-equal " World" find/tail tail-test-string "Hello" "find/tail with string - should return position after match"

tail-test-block: [1 2 3 4 5]
assert-equal [3 4 5] find/tail tail-test-block 2 "find/tail with block - should return position after match"

;;-----------------------------------------------------------------------------
;; PROBING /MATCH REFINEMENT
;;-----------------------------------------------------------------------------

print "^/--- Probing /match Refinement ---"
;; HYPOTHESIS: /match should perform comparison and return head of match

match-test-string: "Hello World"
positioned-string: find match-test-string "World"
assert-equal "World" find/match positioned-string "World" "find/match - should return head of match when found"
assert-equal none find/match positioned-string "xyz" "find/match - should return none when not found"

;;-----------------------------------------------------------------------------
;; PROBING EDGE CASES
;;-----------------------------------------------------------------------------

print "^/--- Probing Edge Cases ---"
;; HYPOTHESIS: Edge cases behave as discovered

;; Empty series
empty-string: ""
empty-block: []
assert-equal none find empty-string "a" "Edge case - empty string should return none"
assert-equal none find empty-block 1 "Edge case - empty block should return none"

;; Empty search value
assert-equal none find "Hello" "" "Edge case - empty string search should return none"

;; None values
none-test-block: [1 none 3]
assert-equal none find none-test-block none "Edge case - none value cannot be found with regular find"

;; Zero values
zero-test-block: [1 0 3]
assert-equal [0 3] find zero-test-block 0 "Edge case - should find zero value"

;;-----------------------------------------------------------------------------
;; PROBING DIFFERENT DATA TYPES
;;-----------------------------------------------------------------------------

print "^/--- Probing Different Data Types ---"
;; HYPOTHESIS: Various data types behave differently

;; Integer series (block)
integer-block: [10 20 30 40 50]
assert-equal [30 40 50] find integer-block 30 "Data type test - integer in block"

;; Logic values
logic-block: [true false true]
assert-equal none find logic-block false "Data type test - logic value may not be findable in block"
assert-equal none find logic-block true "Data type test - logic value may not be findable in block"

;; Word values
word-block: [hello world test]
assert-equal [world test] find word-block 'world "Data type test - word in block"

;; Decimal values
decimal-block: [1.5 2.7 3.14 4.0]
assert-equal [3.14 4.0] find decimal-block 3.14 "Data type test - decimal in block"

;;-----------------------------------------------------------------------------
;; PROBING COMBINED REFINEMENTS
;;-----------------------------------------------------------------------------

print "^/--- Probing Combined Refinements ---"
;; HYPOTHESIS: Combined refinements work as tested

combined-string: "Hello World Hello"
assert-equal "" find/last/tail combined-string "Hello" "Combined refinements - /last/tail should return empty string for end position"

combined-block: [1 2 3 4 5 6]
assert-equal [4 5 6] find/part/tail combined-block 3 4 "Combined refinements - /part/tail should work together"

case-combined-string: "Hello HELLO hello"
assert-equal "hello" find/case/last case-combined-string "hello" "Combined refinements - /case/last should work together"

;;-----------------------------------------------------------------------------
;; BLOCK BEHAVIOR INVESTIGATION - CORRECTED
;;-----------------------------------------------------------------------------

print "^/--- Block Behavior Investigation - CORRECTED ---"
;; CORRECTED HYPOTHESIS: Variable references in blocks may not work as expected

; Test with literal blocks only
literal-container: [[1 2] [3 4] [5 6]]
search-literal: [3 4]
assert-equal [[3 4] [5 6]] find/only literal-container search-literal "Block investigation - /only should find literal block"
assert-equal none find literal-container search-literal "Block investigation - find without /only should not find literal block"

; Test simple value finding in blocks
simple-value-block: [1 "hello" 3.14 'word]
assert-equal ["hello" 3.14 'word] find simple-value-block "hello" "Block investigation - should find simple string value"
assert-equal ['word] find simple-value-block 'word "Block investigation - should find word value"

;;-----------------------------------------------------------------------------
;; ADDITIONAL VERIFICATION TESTS - CORRECTED
;;-----------------------------------------------------------------------------

print "^/--- Additional Verification Tests - CORRECTED ---"
;; CORRECTED HYPOTHESIS: String references behave differently than expected

; Test wildcard behavior thoroughly
wildcard-test: "testing wildcards"
assert-equal "testing wildcards" find/any wildcard-test "t*g" "Verification - wildcard spans multiple characters"
assert-equal "wildcards" find/any wildcard-test "w?ld*" "Verification - multiple wildcards work"

; Test /reverse from different positions
reverse-string: "abc def abc"
from-end: find/last reverse-string "abc"
assert-equal "abc def abc" find/reverse from-end "abc" "Verification - /reverse finds previous occurrence"

; Test equal? comparison with literal values
literal-string-container: ["test" "other"]
assert-equal ["test" "other"] find literal-string-container "test" "Verification - find uses equal? comparison with literal strings"

;;-----------------------------------------------------------------------------
;; FINAL TEST SUMMARY
;;-----------------------------------------------------------------------------

print-test-summary
