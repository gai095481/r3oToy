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
;; SECTION 1: Probing Basic Data Types
;;-----------------------------------------------------------------------------
print "^/=== SECTION 1: Probing Basic Data Types ===^/"

;; HYPOTHESIS: `form` on basic scalar types will produce their direct string representation.
assert-equal "Hello World" form "Hello World" "form on string! should return the string itself"
assert-equal "1024" form 1024 "form on integer! should produce its string representation"
assert-equal "10.24" form 10.24 "form on decimal! should produce its string representation"
assert-equal "true" form true "form on logic! 'true' should produce 'true'"
assert-equal "false" form false "form on logic! 'false' should produce 'false'"
assert-equal "none" form none "form on none! should produce 'none'"
assert-equal "A" form #"A" "form on char! should produce the character as a string"

;;-----------------------------------------------------------------------------
;; SECTION 2: Probing Word Types
;;-----------------------------------------------------------------------------
print "^/=== SECTION 2: Probing Word Types ===^/"

;; HYPOTHESIS: `form` on any word! type will produce the spelling of the word as a string.
test-word: 'some-word
assert-equal "some-word" form test-word "form on word! should produce its spelling"

test-lit-word: to-lit-word 'literal-word
assert-equal "literal-word" form test-lit-word "form on lit-word! should produce its spelling"

test-set-word: to-set-word 'setting-word
assert-equal "setting-word:" form test-set-word "form on set-word! should produce its spelling with a colon"

test-get-word: to-get-word 'getting-word
assert-equal ":getting-word" form test-get-word "form on get-word! should produce its spelling with a leading colon"

test-refinement: to-refinement 'refinement-word
assert-equal "/refinement-word" form test-refinement "form on refinement! should produce its spelling with a slash"

;;-----------------------------------------------------------------------------
;; SECTION 3: Probing Series Types (block!, paren!, path!)
;;-----------------------------------------------------------------------------
print "^/=== SECTION 3: Probing Series Types ===^/"

;; HYPOTHESIS: `form` on series will produce a space-delimited string of the `form`ed elements within the series.
assert-equal "1 abc true" form [1 "abc" true] "form on block! should create a space-delimited string"
assert-equal "a b c" form [a b c] "form on block! of words should form the words"
assert-equal "1 2 3" form make paren! [1 2 3] "form on paren! should behave like block!"

;; HYPOTHESIS: Nested blocks will be recursively formed with space delimiters.
assert-equal "a 1 2 3 b" form ['a [1 2 3] 'b] "form on a nested block should recursively form with spaces"

;; HYPOTHESIS: Paths will be formed into their canonical string representation.
assert-equal "path/to/my/file.txt" form %path/to/my/file.txt "form on file! path should produce string version"
assert-equal "obj/field/value" form 'obj/field/value "form on path! should produce string version"

;;-----------------------------------------------------------------------------
;; SECTION 4: Probing Special Datatypes
;;-----------------------------------------------------------------------------
print "^/=== SECTION 4: Probing Special Datatypes ===^/"

;; HYPOTHESIS: `form` on special datatypes will produce their standard string representation.
test-date: 14-Jul-2025/10:20:30
assert-equal "14-Jul-2025/10:20:30" form test-date "form on date! should produce a standard date/time string"

assert-equal "1.2.3" form 1.2.3 "form on tuple! should produce a dot-delimited string"
assert-equal "$12.34" form $12.34 "form on money! should produce its currency representation"
assert-equal "user@example.com" form user@example.com "form on email! should produce its string representation"
assert-equal "http://www.rebol.com" form http://www.rebol.com "form on url! should produce its string representation"
assert-equal "<tag>" form <tag> "form on tag! should produce its string representation"

;; HYPOTHESIS: `form` on binary data will produce a URL-encoded-style string.
binary-data: #{DECAFBAD}
assert-equal "%DE%CA%FB%AD" form binary-data "form on binary! should produce a URL-encoded style string"

;; HYPOTHESIS: `form` on bitset will produce a readable representation.
bitset-data: charset "a-c123"
assert-equal "make bitset! #{414243B1B2B3}" form bitset-data "form on bitset! should produce its construction representation"

;;-----------------------------------------------------------------------------
;; SECTION 5: Probing Function and Object Types
;;-----------------------------------------------------------------------------
print "^/=== SECTION 5: Probing Function and Object Types ===^/"

;; HYPOTHESIS: `form` on functions and objects will produce a string indicating their type and structure.
test-function: function [arg] [arg + 1]
assert-equal "make function! [[arg] [arg + 1]]" form :test-function "form on function! should produce its source representation"

test-object: make object! [name: "Test" value: 10]
assert-equal "make object! [^/    name: ^"Test^"^/    value: 10^/]" form test-object "form on object! should produce its source representation"

;;-----------------------------------------------------------------------------
;; SECTION 6: Probing Edge Cases
;;-----------------------------------------------------------------------------
print "^/=== SECTION 6: Probing Edge Cases ===^/"

;; HYPOTHESIS: `form` should handle empty values gracefully.
assert-equal "" form "" "form on an empty string should be an empty string"
assert-equal "" form [] "form on an empty block should be an empty string"
assert-equal "" form #{} "form on an empty binary should be an empty string"

;; HYPOTHESIS: `form` should handle `unset!` values.
unset-val-word: 'my-unset-val
unset unset-val-word
assert-equal "" form get/any unset-val-word "form on unset! should produce an empty string"

;; HYPOTHESIS: `form` on a block containing `none` and `unset`.
mixed-existence-block: reduce ["a" none "b" (get/any unset-val-word) "c"]
assert-equal "a none b  c" form mixed-existence-block "form on block with none and unset should form them accordingly"

;; HYPOTHESIS: `form` on a `map!` should show its contents.
test-map: make map! [a 1 b 2]
assert-equal "make map! [^/    a: 1^/    b: 2^/]" form test-map "form on map! should produce its source representation"


print "^/=== ALL FORM FUNCTION PROBES COMPLETED ===^/"

print-test-summary
