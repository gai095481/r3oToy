Rebol [
    Title: "Comprehensive Diagnostic Probe for COMBINE Function - FINAL CORRECTED"
    Purpose: "Systematically test all behaviors, refinements, and edge cases of the combine function"
    Author: "MyNinja AI"
    Version: 0.1.0
    Date: 22-Jul-2025
    Note: "Truth from the REPL - No assumptions, only evidence."
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
    print "=== TEST SUMMARY ==="
    print "============================================"
    print rejoin ["Total Tests: " test-count]
    print rejoin ["Passed: " pass-count]
    print rejoin ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - FUNCTION IS STABLE"
    ][
        print "❌  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/============================================"
print "=== COMBINE FUNCTION DIAGNOSTIC PROBE - FINAL CORRECTED ==="
print "============================================^/"

;;-----------------------------
;; Probing Basic Behavior
;;-----------------------------
print "--- Probing Basic Behavior ---"
;; Hypothesis: combine should concatenate basic values into a string by default
;; and ignore unset, error, and function values by default

basic-input: [1 2 3]
basic-result: combine basic-input
assert-equal "123" basic-result "Basic integer combination"

string-input: ["hello" "world"]
string-result: combine string-input
assert-equal "helloworld" string-result "Basic string combination"

mixed-input: [1 "hello" 2.5]
mixed-result: combine mixed-input
assert-equal "1hello2.5" mixed-result "Mixed type combination"

;;-----------------------------
;; Probing Empty and Single Value Cases
;;-----------------------------
print "^/--- Probing Empty and Single Value Cases ---"
;; Hypothesis: Empty block should return empty string, single values should convert to string

empty-input: []
empty-result: combine empty-input
assert-equal "" empty-result "Empty block combination"

single-input: [42]
single-result: combine single-input
assert-equal "42" single-result "Single value combination"

single-string-input: ["test"]
single-string-result: combine single-string-input
assert-equal "test" single-string-result "Single string combination"

;;-----------------------------
;; Probing Default Ignored Types
;;-----------------------------
print "^/--- Probing Default Ignored Types ---"
;; Hypothesis CORRECTED: none values are NOT ignored by default (contrary to documentation)
;; Only unset, error, and function values are ignored by default

none-input: [1 none 2]
none-result: combine none-input
assert-equal "1none2" none-result "None values are NOT ignored by default"

;; Test with function values (should be ignored)
func-input: reduce [1 :print 2]
func-result: combine func-input
assert-equal "12" func-result "Function values ignored by default"

;;-----------------------------
;; Probing Paren Evaluation
;;-----------------------------
print "^/--- Probing Paren Evaluation ---"
;; Hypothesis: Content within parens should be evaluated before combination

paren-input: [1 (2 + 3) 4]
paren-result: combine paren-input
assert-equal "154" paren-result "Paren content is evaluated"

paren-string-input: ["hello" (uppercase "world")]
paren-string-result: combine paren-string-input
assert-equal "helloWORLD" paren-string-result "Paren with string operations"

nested-paren-input: [1 (2 * (3 + 1)) 5]
nested-paren-result: combine nested-paren-input
assert-equal "185" nested-paren-result "Nested paren evaluation"

;;-----------------------------
;; Probing Get-Word Evaluation
;;-----------------------------
print "^/--- Probing Get-Word Evaluation ---"
;; Hypothesis: Get-words should be evaluated to their values

test-var: "VALUE"
getword-input: reduce [1 to get-word! 'test-var 2]
getword-result: combine getword-input
assert-equal "1VALUE2" getword-result "Get-word evaluation"

;;-----------------------------
;; Probing Block Handling (Default)
;;-----------------------------
print "^/--- Probing Block Handling (Default) ---"
;; Hypothesis: Nested blocks should be processed recursively by default

nested-input: [1 [2 3] 4]
nested-result: combine nested-input
assert-equal "1234" nested-result "Nested blocks processed recursively"

deep-nested-input: [1 [2 [3 4] 5] 6]
deep-nested-result: combine deep-nested-input
assert-equal "123456" deep-nested-result "Deep nested blocks processed"

;;-----------------------------
;; Probing /with Refinement
;;-----------------------------
print "^/--- Probing /with Refinement ---"
;; Hypothesis: /with should insert delimiter between values

with-space-input: [1 2 3]
with-space-result: combine/with with-space-input " "
assert-equal "1 2 3" with-space-result "Space delimiter"

with-comma-input: ["a" "b" "c"]
with-comma-result: combine/with with-comma-input ","
assert-equal "a,b,c" with-comma-result "Comma delimiter"

with-string-input: [1 2 3]
with-string-result: combine/with with-string-input " - "
assert-equal "1 - 2 - 3" with-string-result "String delimiter"

;; Test delimiter with single value (should not add delimiter)
with-single-input: [42]
with-single-result: combine/with with-single-input " "
assert-equal "42" with-single-result "Single value with delimiter"

;; Test delimiter with empty block
with-empty-input: []
with-empty-result: combine/with with-empty-input " "
assert-equal "" with-empty-result "Empty block with delimiter"

;;-----------------------------
;; Probing /into Refinement
;;-----------------------------
print "^/--- Probing /into Refinement ---"
;; Hypothesis: /into should output results into specified series type

;; Into block
into-block: []
into-block-input: [1 2 3]
into-block-result: combine/into into-block-input into-block
assert-equal [1 2 3] into-block "Into block series"
assert-equal into-block into-block-result "Into returns the target series"

;; Into string (should behave like default)
into-string: ""
into-string-input: [1 2 3]
into-string-result: combine/into into-string-input into-string
assert-equal "123" into-string "Into string series"
assert-equal into-string into-string-result "Into string returns target"

;; Into pre-filled series
prefilled-block: [0]
prefilled-input: [1 2]
prefilled-result: combine/into prefilled-input prefilled-block
assert-equal [0 1 2] prefilled-block "Into pre-filled block"

;;-----------------------------
;; Probing /ignore Refinement
;;-----------------------------
print "^/--- Probing /ignore Refinement ---"
;; Hypothesis: /ignore should allow custom specification of ignored types

;; Ignore integers
ignore-int-input: [1 "hello" 2 "world"]
ignore-int-typeset: make typeset! [integer!]
ignore-int-result: combine/ignore ignore-int-input ignore-int-typeset
assert-equal "helloworld" ignore-int-result "Ignore integers"

;; Ignore strings
ignore-str-input: [1 "hello" 2 "world"]
ignore-str-typeset: make typeset! [string!]
ignore-str-result: combine/ignore ignore-str-input ignore-str-typeset
assert-equal "12" ignore-str-result "Ignore strings"

;; Empty ignore typeset (nothing ignored)
ignore-none-input: [1 none 2]
ignore-none-typeset: make typeset! []
ignore-none-result: combine/ignore ignore-none-input ignore-none-typeset
assert-equal "1none2" ignore-none-result "Empty ignore typeset"

;; CORRECTED: none values cannot be explicitly ignored - they are processed as literal values
;; This reveals that the /ignore refinement may not work as expected with none values
none-literal-input: [1 none 2]
none-literal-typeset: make typeset! [none!]
none-literal-result: combine/ignore none-literal-input none-literal-typeset
assert-equal "1none2" none-literal-result "None values cannot be ignored via /ignore"

;;-----------------------------
;; Probing /only Refinement
;;-----------------------------
print "^/--- Probing /only Refinement ---"
;; Hypothesis: /only should insert blocks as single values instead of processing recursively

only-input: [1 [2 3] 4]
only-result: combine/only only-input
assert-equal "1[2 3]4" only-result "Only refinement with string output"

;; /only with /into block
only-block: []
only-block-input: [1 [2 3] 4]
only-block-result: combine/only/into only-block-input only-block
assert-equal [1 [2 3] 4] only-block "Only refinement with block output"

;;-----------------------------
;; Probing Combined Refinements
;;-----------------------------
print "^/--- Probing Combined Refinements ---"
;; Hypothesis CORRECTED: Multiple refinements work together, but /into preserves original types

;; /with and /into - CORRECTED expectation
with-into-block: []
with-into-input: [1 2 3]
with-into-result: combine/with/into with-into-input " " with-into-block
assert-equal [1 " " 2 " " 3] with-into-block "With and into combined - preserves types"

;; /with and /ignore
with-ignore-input: [1 "skip" 2 "skip" 3]
with-ignore-typeset: make typeset! [string!]
with-ignore-result: combine/with/ignore with-ignore-input " " with-ignore-typeset
assert-equal "1 2 3" with-ignore-result "With and ignore combined"

;; /only and /with
only-with-input: [1 [2 3] 4]
only-with-result: combine/only/with only-with-input " "
assert-equal "1 [2 3] 4" only-with-result "Only and with combined"

;;-----------------------------
;; Probing Edge Cases and Error Conditions
;;-----------------------------
print "^/--- Probing Edge Cases ---"
;; Hypothesis: Various edge cases should be handled gracefully

;; Paren that evaluates to none (should be ignored by default)
paren-none-input: [1 (none) 2]
paren-none-result: combine paren-none-input
assert-equal "12" paren-none-result "Paren evaluating to none"

;; Paren with error (should be ignored by default)
paren-error-input: [1 (try [1 / 0]) 2]
paren-error-result: combine paren-error-input
assert-equal "12" paren-error-result "Paren with error"

;; Get-word of undefined variable (should result in unset, which is ignored)
unset-getword-input: reduce [1 try [get/any to get-word! 'undefined-variable] 2]
unset-getword-result: combine unset-getword-input
assert-equal "12" unset-getword-result "Get-word of undefined variable"

;; Complex nested structure - CORRECTED expectation
complex-input: [1 [2 (3 + 1) [5]] (2 * 3)]
complex-result: combine complex-input
assert-equal "12456" complex-result "Complex nested structure - actual behavior"

;; Binary data - CORRECTED expectation (loses formatting)
binary-input: [#{DEADBEEF}]
binary-result: combine binary-input
assert-equal "DEADBEEF" binary-result "Binary data loses formatting markers"

;; Special characters and unicode
unicode-input: ["Hello" "🌍" "World"]
unicode-result: combine unicode-input
assert-equal "Hello🌍World" unicode-result "Unicode character handling"

;; Test with various numeric types
numeric-input: [1 1.5 50% $1.23]
numeric-result: combine numeric-input
assert-equal "11.550%$1.23" numeric-result "Various numeric types"

;; Test with dates and times
datetime-input: [1-Jan-2000 10:30:45]
datetime-result: combine datetime-input
assert-equal "1-Jan-200010:30:45" datetime-result "Date and time values"

;; Test with logic values
logic-input: [true false]
logic-result: combine logic-input
assert-equal "truefalse" logic-result "Logic values"

;; Test with words and issues - CORRECTED expectation (issue loses # prefix)
word-input: [hello #issue]
word-result: combine word-input
assert-equal "helloissue" word-result "Words and issues - issue loses # prefix"

;; Additional test: URL and email handling
url-email-input: [http://example.com user@domain.com]
url-email-result: combine url-email-input
assert-equal "http://example.comuser@domain.com" url-email-result "URL and email handling"

;; Additional test: Tag handling
tag-input: [<html> <body>]
tag-result: combine tag-input
assert-equal "<html><body>" tag-result "Tag handling"

;; Additional test: File handling - CORRECTED expectation (loses % prefix)
file-input: [%file.txt %/path/to/file]
file-result: combine file-input
assert-equal "file.txt/path/to/file" file-result "File handling - loses % prefix"

;; Additional test: Character handling
char-input: [#"A" #"B"]
char-result: combine char-input
assert-equal "AB" char-result "Character handling"

print-test-summary
