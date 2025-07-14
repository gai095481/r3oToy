Rebol [
    Title: "FORM Function Diagnostic Probe Script"
    Author: "Jules, AI Assistant"
    Date: 14-Jul-2025
    Purpose: "Comprehensive testing of the FORM function behavior in Rebol 3 Oldes"
    Note: "This script systematically tests the FORM function with various data types and edge cases."
]

;;-----------------------------
;; A Battle-Tested QA Harness
;;------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    either equal? expected actual [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {Output the final summary of the entire test run.}
    print "^/============================================"
    print ["=== TEST SUMMARY ==="]
    print "============================================"
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - FORM IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/============================================"
print "=== COMPREHENSIVE FORM FUNCTION PROBE ==="
print "============================================^/"

;;-----------------------------------------------------------------------------
;; SECTION 1: Probing Basic Scalar Data Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 1: Probing Basic Scalar Data Types ---^/"

;; HYPOTHESIS: form should convert basic scalar values to their string representation
;; without quotes or special formatting, providing human-readable output.

assert-equal "42" form 42 "form on positive integer"
assert-equal "-17" form -17 "form on negative integer"
assert-equal "0" form 0 "form on zero integer"
assert-equal "3.14159" form 3.14159 "form on positive decimal"
assert-equal "-2.718" form -2.718 "form on negative decimal"
assert-equal "0.0" form 0.0 "form on zero decimal"
assert-equal "true" form true "form on true logical"
assert-equal "false" form false "form on false logical"
assert-equal "A" form #"A" "form on character literal"
assert-equal " " form #" " "form on space character"
assert-equal "^/" form #"^/" "form on newline character"
assert-equal "none" form none "form on none value"

;;-----------------------------------------------------------------------------
;; SECTION 2: Probing String Data Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 2: Probing String Data Types ---^/"

;; HYPOTHESIS: form should return strings without quotes or escape sequences,
;; presenting the raw string content as human-readable text.

assert-equal "Hello World" form "Hello World" "form on basic string"
assert-equal "" form "" "form on empty string"
assert-equal "Line 1^/Line 2" form "Line 1^/Line 2" "form on string with newlines"
assert-equal {He said "Hello"} form {He said "Hello"} "form on string containing quotes"
assert-equal "Tab:^-End" form "Tab:^-End" "form on string with tab character"

;;-----------------------------------------------------------------------------
;; SECTION 3: Probing Block and Paren Data Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 3: Probing Block and Paren Data Types ---^/"

;; HYPOTHESIS: form should convert blocks and parens to space-separated string representation
;; without outer brackets, showing the contents in a readable format.

assert-equal "" form [] "form on empty block"
assert-equal "1 2 3 4 5" form [1 2 3 4 5] "form on block of integers"
assert-equal "42 hello true x" form [42 "hello" true #"x"] "form on block with mixed types"
assert-equal "1 2 3 4" form [1 [2 3] 4] "form on nested blocks"
assert-equal "first item second item" form ["first item" "second item"] "form on block with spaced strings"
assert-equal "1 2 3" form make paren! [1 2 3] "form on paren! behaves like a block"

;;-----------------------------------------------------------------------------
;; SECTION 4: Probing Word Data Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 4: Probing Word Data Types ---^/"

;; HYPOTHESIS: `form` on any word! type will produce the spelling of the word as a string, without special characters.
assert-equal "hello" form 'hello "form on word!"
assert-equal "hello-world" form 'hello-world "form on word! with hyphen"
assert-equal "item123" form 'item123 "form on word! with numbers"
assert-equal "literal-word" form to-lit-word 'literal-word "form on lit-word!"
assert-equal "setting-word" form to-set-word 'setting-word "form on set-word!"
assert-equal "getting-word" form to-get-word 'getting-word "form on get-word!"
assert-equal "refinement-word" form to-refinement 'refinement-word "form on refinement!"

;;-----------------------------------------------------------------------------
;; SECTION 5: Probing Path and Special Identifier Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 5: Probing Path and Special Identifier Types ---^/"

;; HYPOTHESIS: Paths and special identifier types are formed into their canonical string representation.
assert-equal "/path/to/file.txt" form %/path/to/file.txt "form on file! path"
assert-equal "obj/field/value" form 'obj/field/value "form on path!"
assert-equal "user@example.com" form user@example.com "form on email!"
assert-equal "http://www.rebol.com" form http://www.rebol.com "form on url!"
assert-equal "issue-123" form #issue-123 "form on issue!"
assert-equal "<html>" form <html> "form on tag!"

;;-----------------------------------------------------------------------------
;; SECTION 6: Probing Date, Time, Tuple, and Money Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 6: Probing Date, Time, Tuple, and Money Types ---^/"

;; HYPOTHESIS: These datatypes will be formed into their standard string representations.
assert-equal "13-Jul-2025" form 13-Jul-2025 "form on basic date"
assert-equal "13-Jul-2025/14:30:45" form 13-Jul-2025/14:30:45 "form on date with time"
assert-equal "14:30:45" form 14:30:45 "form on time value"
assert-equal "14:30:45.123" form 14:30:45.123 "form on time with milliseconds"
assert-equal "192.168.1.1" form 192.168.1.1 "form on tuple! (IP address)"
assert-equal "$12.34" form $12.34 "form on money!"

;;-----------------------------------------------------------------------------
;; SECTION 7: Probing Binary and Bitset Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 7: Probing Binary and Bitset Types ---^/"

;; HYPOTHESIS: `form` on binary data produces a raw hex string.
assert-equal "48656C6C6F" form #{48656C6C6F} "form on binary data"
assert-equal "" form #{} "form on empty binary!"

;; HYPOTHESIS: `form` on bitset will produce its internal hex representation.
bitset-data: charset "a-c123"
assert-equal "make bitset! #{00000000000470000000000050}" form bitset-data "form on bitset!"

;;-----------------------------------------------------------------------------
;; SECTION 8: Probing Function, Object, and Map Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 8: Probing Function, Object, and Map Types ---^/"

;; HYPOTHESIS: `form` on complex container types will produce their source or content representation.
test-function: function [arg] [arg + 1]
assert-equal "make function! [[arg^//local][arg + 1]]" form :test-function "form on function!"

test-object: make object! [name: "Test" value: 10]
assert-equal join "name: ^"Test^"" [newline "value: 10"] form test-object "form on object! produces contents"

test-map: make map! [name: "John" age: 30]
assert-equal join "name: ^"John^"" [newline "age: 30"] form test-map "form on map! produces contents"

;;-----------------------------------------------------------------------------
;; SECTION 9: Probing Series Position and Other Edge Cases
;;-----------------------------------------------------------------------------
print "^/--- SECTION 9: Probing Series Position and Other Edge Cases ---^/"

;; HYPOTHESIS: `form` on a series at a position other than the head will form from that position onward.
test-series-pos: next "Hello World"
assert-equal "ello World" form test-series-pos "form on string! at next position"
assert-equal "" form tail "Hello World" "form on string! at tail"

test-block-pos: next [1 2 3 4]
assert-equal "2 3 4" form test-block-pos "form on block! at next position"

;; HYPOTHESIS: `form` on `unset!` produces an empty string.
unset-val-word: 'my-unset-val
unset unset-val-word
assert-equal "" form get/any unset-val-word "form on unset!"

;; HYPOTHESIS: `form` on a `datatype!` produces its name.
assert-equal "string!" form string! "form on datatype!"

print "^/=== ALL FORM FUNCTION PROBES COMPLETED ===^/"
print-test-summary
