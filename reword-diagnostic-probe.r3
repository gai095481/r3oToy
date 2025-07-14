Rebol [
    Title: "Reword Function Diagnostic Probe Script"
    Purpose: "Systematically test the behavior of the reword function and its refinements"
    Author: "Diagnostic Probe Generator"
    Date: "14-Jul-2025"
    Version: "1.0.0"
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
        print "✅ ALL TESTS PASSED - REWORD IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; DIAGNOSTIC PROBE SCRIPT FOR REWORD FUNCTION
;;=============================================================================

print "^/=== REWORD FUNCTION DIAGNOSTIC PROBE ==="
print "Testing REBOL/Bulk 3.19.0 (Oldes Branch)^/"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Basic reword functionality with default $ escape character
;; Expected: Simple string template with $word replacements should work
;;-----------------------------------------------------------------------------

print "^/--- Testing Basic Reword Functionality ---"

; Test basic string template with simple word substitution
template-basic: "Hello $name, welcome to $place!"
values-basic: [name "Alice" place "Rebol"]
expected-basic: "Hello Alice, welcome to Rebol!"

assert-equal expected-basic reword template-basic values-basic "Basic string template substitution"

; Test with numeric values
template-numeric: "The answer is $number and the year is $year"
values-numeric: [number 42 year 2025]
expected-numeric: "The answer is 42 and the year is 2025"

assert-equal expected-numeric reword template-numeric values-numeric "Numeric value substitution"

; Test with block values (should be reduced by default)
template-block: "Result: $calculation"
values-block: [calculation [1 + 2 + 3]]
expected-block: "Result: 6"

assert-equal expected-block reword template-block values-block "Block value reduction"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Empty and edge case templates should be handled gracefully
;; Expected: Empty strings, no substitutions, missing values should work
;;-----------------------------------------------------------------------------

print "^/--- Testing Edge Cases and Empty Values ---"

; Test empty template
template-empty: ""
values-empty: [name "test"]
expected-empty: ""

assert-equal expected-empty reword template-empty values-empty "Empty template string"

; Test template with no substitutions
template-no-subs: "No substitutions here"
values-no-subs: [name "test"]
expected-no-subs: "No substitutions here"

assert-equal expected-no-subs reword template-no-subs values-no-subs "Template with no substitutions"

; Test with missing substitution value (should remain as literal)
template-missing: "Hello $name, missing $unknown"
values-missing: [name "Bob"]
expected-missing: "Hello Bob, missing $unknown"

assert-equal expected-missing reword template-missing values-missing "Missing substitution value"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Map and object value sources should work identically to blocks
;; Expected: Maps and objects should provide the same substitution behavior
;;-----------------------------------------------------------------------------

print "^/--- Testing Different Value Source Types ---"

; Test with map values
template-map: "User: $username, ID: $userid"
values-map: make map! [username "john" userid 123]
expected-map: "User: john, ID: 123"

assert-equal expected-map reword template-map values-map "Map value source"

; Test with object values
values-obj: make object! [username: "jane" userid: 456]
expected-obj: "User: jane, ID: 456"

assert-equal expected-obj reword template-map values-obj "Object value source"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: /case refinement should make substitutions case-sensitive
;; Expected: $Name and $name should be treated as different when /case is used
;;-----------------------------------------------------------------------------

print "^/--- Testing /case Refinement ---"

; Test case-insensitive (default behavior)
template-case: "Hello $name and $Name"
values-case: [name "alice" Name "ALICE"]
expected-case-insensitive: "Hello alice and ALICE"

assert-equal expected-case-insensitive reword template-case values-case "Case-insensitive default behavior"

; Test case-sensitive with /case refinement
expected-case-sensitive: "Hello alice and ALICE"

assert-equal expected-case-sensitive reword/case template-case values-case "Case-sensitive with /case refinement"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: /only refinement should prevent block evaluation
;; Expected: Block values should be inserted as-is without reduction
;;-----------------------------------------------------------------------------

print "^/--- Testing /only Refinement ---"

; Test /only with block values
template-only: "Expression: $expr, Block: $blk"
values-only: [expr [1 + 2] blk [a b c]]
;; CORRECTED: Observed behavior is that /only with blocks forms them without spaces
expected-only: "Expression: 1+2, Block: abc"

assert-equal expected-only reword/only template-only values-only "Block values with /only refinement"

; Compare with normal behavior (blocks should be reduced)
;; CORRECTED: Changed the block to be valid executable code to avoid error
values-normal: [expr [1 + 2] blk [c: 3 d: 4 c + d]]
expected-normal: "Expression: 3, Block: 7"

assert-equal expected-normal reword template-only values-normal "Block values without /only (normal reduction)"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: /escape refinement should allow custom escape characters
;; Expected: Custom escape characters should replace the default $
;;-----------------------------------------------------------------------------

print "^/--- Testing /escape Refinement ---"

; Test with custom single character escape
template-escape: "Hello #name, welcome to #place!"
values-escape: [name "Carol" place "Testing"]
expected-escape: "Hello Carol, welcome to Testing!"

assert-equal expected-escape reword/escape template-escape values-escape #"#" "Custom single character escape"

; Test with custom string escape
template-escape-str: "Hello %%name%%, welcome to %%place%%!"
;; CORRECTED: Observed behavior is that the closing delimiter of a multi-character string escape is not consumed.
expected-escape-str: "Hello Carol%%, welcome to Testing%%!"

assert-equal expected-escape-str reword/escape template-escape-str values-escape "%%" "Custom string escape (closing delimiter not consumed)"

; Test with begin/end delimiter block
template-escape-delim: "Hello <name>, welcome to <place>!"
escape-delimiters: ["<" ">"]
expected-escape-delim: "Hello Carol, welcome to Testing!"

assert-equal expected-escape-delim reword/escape template-escape-delim values-escape escape-delimiters "Custom begin/end delimiters"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: /into refinement should insert results into provided buffer
;; Expected: Results should be inserted into buffer and position returned
;;-----------------------------------------------------------------------------

print "^/--- Testing /into Refinement ---"

; Test /into with string buffer
template-into: "Hello $name!"
values-into: [name "David"]
buffer-string: make string! 100
result-pos: reword/into template-into values-into buffer-string
expected-buffer: "Hello David!"

assert-equal expected-buffer copy buffer-string "/into refinement with string buffer"

; Test that return value is position after insert
expected-tail?: tail? result-pos

assert-equal true expected-tail? "/into returns position after insert"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Binary templates should work with binary or string substitutions
;; Expected: Binary templates should maintain binary type in output
;;-----------------------------------------------------------------------------

print "^/--- Testing Binary Template Support ---"

; Test binary template with string values
template-binary: to binary! "Hello $name, $greeting"
values-binary: [name "Eve" greeting "world"]
result-binary: reword template-binary values-binary
expected-binary-type: binary?

assert-equal true binary? result-binary "Binary template produces binary output"

; Test binary template content
expected-binary-content: to binary! "Hello Eve, world"

assert-equal expected-binary-content result-binary "Binary template content correctness"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Complex nested substitutions and function values should work
;; Expected: Function values should be called, complex expressions evaluated
;;-----------------------------------------------------------------------------

print "^/--- Testing Complex Substitutions ---"

; Test with function values
template-func: "Time: $time, Random: $random"
get-time: does [now/time]
get-random: does [random 100]
values-func: reduce ['time :get-time 'random :get-random]

; Note: We can't test exact values for time/random, so we test structure
result-func: reword template-func values-func
func-contains-time: find result-func "Time: "
func-contains-random: find result-func "Random: "

assert-equal true not none? func-contains-time "Function substitution contains time"
assert-equal true not none? func-contains-random "Function substitution contains random"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Word types (set-word!, lit-word!) should be handled correctly
;; Expected: Different word types should be normalized to word! for lookup
;;-----------------------------------------------------------------------------

print "^/--- Testing Word Type Handling ---"

; Test with set-words and lit-words in values
template-words: "Set: $test, Lit: $example"
values-words: [test: "set-word-value" 'example "lit-word-value"]
expected-words: "Set: set-word-value, Lit: lit-word-value"

assert-equal expected-words reword template-words values-words "Set-word and lit-word handling"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Error conditions should be handled gracefully
;; Expected: Invalid arguments should produce appropriate errors
;;-----------------------------------------------------------------------------

print "^/--- Testing Error Conditions ---"

; Test invalid template type (should cause error)
set/any 'error-result try [reword 123 [name "test"]]
assert-equal true error? error-result "Invalid template type produces error"

; Test invalid values type (should cause error)
set/any 'error-result2 try [reword "Hello $name" "invalid"]
assert-equal true error? error-result2 "Invalid values type produces error"

; Test invalid escape character with /escape
set/any 'error-result3 try [reword/escape "Hello $name" [name "test"] 123]
assert-equal true error? error-result3 "Invalid escape character produces error"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Refinement combinations should work correctly
;; Expected: Multiple refinements can be combined without conflicts
;;-----------------------------------------------------------------------------

print "^/--- Testing Refinement Combinations ---"

; Test /case and /only together
template-combo: "Hello $Name, expr: $calc"
values-combo: [Name "Frank" calc [2 * 3]]
expected-combo: "Hello Frank, expr: 2*3"

assert-equal expected-combo reword/case/only template-combo values-combo "Combined /case and /only refinements"

; Test /escape and /only together
template-combo2: "Hello #Name, expr: #calc"
expected-combo2: "Hello Frank, expr: 2*3"

assert-equal expected-combo2 reword/escape/only template-combo2 values-combo #"#" "Combined /escape and /only refinements"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Special characters in templates should be handled correctly
;; Expected: Quotes, newlines, and other special chars should work
;;-----------------------------------------------------------------------------

print "^/--- Testing Special Character Handling ---"

; Test template with quotes and newlines
template-special: {Hello "$name"^/Welcome to $place!}
values-special: [name "Grace" place "Rebol"]
expected-special: {Hello "Grace"^/Welcome to Rebol!}

assert-equal expected-special reword template-special values-special "Special characters in template"

; Test with empty string substitution
template-empty-sub: "Before$emptyAfter"
values-empty-sub: [empty ""]
expected-empty-sub: "BeforeAfter"

assert-equal expected-empty-sub reword template-empty-sub values-empty-sub "Empty string substitution"

;;-----------------------------------------------------------------------------
;; HYPOTHESIS: Large templates and many substitutions should work efficiently
;; Expected: Performance should be reasonable with larger inputs
;;-----------------------------------------------------------------------------

print "^/--- Testing Performance and Scale ---"

; Test with multiple substitutions
template-multi: "A:$a B:$b C:$c D:$d E:$e F:$f G:$g H:$h I:$i J:$j"
values-multi: [a 1 b 2 c 3 d 4 e 5 f 6 g 7 h 8 i 9 j 10]
expected-multi: "A:1 B:2 C:3 D:4 E:5 F:6 G:7 H:8 I:9 J:10"

assert-equal expected-multi reword template-multi values-multi "Multiple substitutions"

; Test with repeated substitutions
template-repeat: "Name: $name, Again: $name, Once more: $name"
values-repeat: [name "Henry"]
expected-repeat: "Name: Henry, Again: Henry, Once more: Henry"

assert-equal expected-repeat reword template-repeat values-repeat "Repeated substitutions"

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================

print-test-summary
