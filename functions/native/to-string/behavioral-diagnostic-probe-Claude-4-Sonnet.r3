Rebol [
    Title: "`to-string` Function Diagnostic Probe"
    Purpose: "Robust testing of `to-string` behavior across most datatypes."
    Author: "Claude 4 Sonnet"
    Version: 0.1.0
    Date: 19-Jul-2025
    Target: "REBOL/Bulk 3.19.0 (Oldes Branch)"
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

;;============================================================================
;; DIAGNOSTIC PROBE: `to-string` Function Robust Diagnostic Testing
;;============================================================================
print "^/=== DIAGNOSTIC PROBE: `to-string` Function ==="
print "Testing conversion behavior across most Rebol datatypes...^/"

;;-----------------------------
;; Probing Basic String Behavior
;;-----------------------------
print "--- Probing Basic String Behavior ---"
;; Hypothesis: `to-string` on `string!` values should return the same string unchanged:
test-string: "hello world"
assert-equal "hello world" to-string test-string "Basic string conversion should be identity."

;; Hypothesis: Empty strings should remain empty
assert-equal "" to-string "" "Empty string conversion should be identity"

;; Hypothesis: Multi-line strings should preserve newlines
multi-line: "line1^/line2^/line3"
assert-equal "line1^/line2^/line3" to-string multi-line "Multi-line string should preserve newlines"

;;-----------------------------
;; Probing Integer Conversion
;;-----------------------------
print "^/--- Probing Integer Conversion ---"
;; Hypothesis: Positive integers should convert to their decimal string representation
test-positive: 42
assert-equal "42" to-string test-positive "Positive integer should convert to decimal string"

;; Hypothesis: Zero should convert to "0"
assert-equal "0" to-string 0 "Zero should convert to string '0'"

;; Hypothesis: Negative integers should include the minus sign
test-negative: -123
assert-equal "-123" to-string test-negative "Negative integer should include minus sign"

;; Hypothesis: Large integers should convert properly
test-large: 999999999
assert-equal "999999999" to-string test-large "Large integer should convert correctly"

;;-----------------------------
;; Probing Decimal/Float Conversion
;;-----------------------------
print "^/--- Probing Decimal/Float Conversion ---"
;; Hypothesis: Simple decimals should convert with decimal point
test-decimal: 3.14
decimal-result: to-string test-decimal
print rejoin ["Decimal 3.14 converts to: " decimal-result]

;; Hypothesis: Zero decimal should be "0.0" or similar
zero-decimal: 0.0
zero-decimal-result: to-string zero-decimal
print rejoin ["Zero decimal converts to: " zero-decimal-result]

;; Hypothesis: Negative decimals should include minus sign
negative-decimal: -2.5
negative-decimal-result: to-string negative-decimal
print rejoin ["Negative decimal -2.5 converts to: " negative-decimal-result]

;;-----------------------------
;; Probing `logic!` Values
;;-----------------------------
print "^/--- Probing `logic!` Values ---"
;; Hypothesis: true should convert to "true"
assert-equal "true" to-string true "Logic true should convert to `true`"

;; Hypothesis: false should convert to "false"
assert-equal "false" to-string false "Logic false should convert to `false`"

;;-----------------------------
;; Probing `none!` Value
;;-----------------------------
print "^/--- Probing `none!` Value ---"
;; Hypothesis: `none` should error:
print "Testing `none` value handling..."
set/any 'none-result try [to-string to-string none]
either error? none-result [
    print "✓ to-string correctly errors on `none!` values"
][
    print rejoin ["`none` value converts to: " none-result]
]

;;-----------------------------
;; Probing `word!` Types
;;-----------------------------
print "^/--- Probing `word!` datatypes ---"
;; Hypothesis: Regular words should convert to their string representation
test-word: 'hello
assert-equal "hello" to-string test-word "Word should convert to its string representation"

;; Hypothesis: Set-words should convert without the colon
test-set-word: to set-word! 'hello
set-word-result: to-string test-set-word
print rejoin ["Set-word hello: converts to: " set-word-result]

;; Hypothesis: Get-words should convert without the colon prefix
test-get-word: to get-word! 'hello
get-word-result: to-string test-get-word
print rejoin ["Get-word :hello converts to: " get-word-result]

;; Hypothesis: Lit-words should convert without the quote prefix
test-lit-word: to lit-word! 'hello
lit-word-result: to-string test-lit-word
print rejoin ["Lit-word 'hello converts to: " lit-word-result]

;;-----------------------------
;; Probing `block!` Conversion
;;-----------------------------
print "^/--- Probing `block!` Conversion ---"
;; Hypothesis: Empty blocks should convert to "[]"
empty-block: []
empty-block-result: to-string empty-block
print rejoin ["Empty block converts to: " empty-block-result]

;; Hypothesis: Simple blocks should show their molded form
simple-block: [1 2 3]
simple-block-result: to-string simple-block
print rejoin ["Simple block [1 2 3] converts to: " simple-block-result]

;; Hypothesis: Nested blocks should preserve structure
nested-block: [a [b c] d]
nested-block-result: to-string nested-block
print rejoin ["Nested block [a [b c] d] converts to: " nested-block-result]

;; Hypothesis: Blocks with strings should preserve quotes
block-with-strings: ["hello" "world"]
block-strings-result: to-string block-with-strings
print rejoin ["Block with strings converts to: " block-strings-result]

;;-----------------------------
;; Probing `date!` and `time!` Values
;;-----------------------------
print "^/--- Probing `date!` and `time!` Values ---"
;; Hypothesis: Dates should convert to standard date format
test-date: 1-Jan-2025
date-result: to-string test-date
print rejoin ["Date 1-Jan-2025 converts to: " date-result]

;; Hypothesis: Time values should convert to time format
test-time: 12:30:45
time-result: to-string test-time
print rejoin ["Time 12:30:45 converts to: " time-result]

;;-----------------------------
;; Probing Character Conversion
;;-----------------------------
print "^/--- Probing Character Conversion ---"
;; Hypothesis: Characters should convert to single character strings
test-char: #"A"
char-result: to-string test-char
print rejoin ["Character #""A"" converts to: " char-result]

;; Hypothesis: Special characters should be preserved
newline-char: #"^/"
newline-char-result: to-string newline-char
print rejoin ["Newline character converts to: " newline-char-result]

;;-----------------------------
;; Probing `url!` and `email!` Types
;;-----------------------------
print "^/--- Probing `url!` and `email!` datatypes ---"
;; Hypothesis: URLs should convert to their string representation
test-url: http://www.rebol.com
url-result: to-string test-url
print rejoin ["URL converts to: " url-result]

;; Hypothesis: Email addresses should convert to string form
test-email: user@domain.com
email-result: to-string test-email
print rejoin ["Email converts to: " email-result]

;;-----------------------------
;; Probing `file!` and `path!` Types
;;-----------------------------
print "^/--- Probing `file!` and `path!` datatypes ---"
;; Hypothesis: File paths should convert to their string representation
test-file: %/home/user/file.txt
file-result: to-string test-file
print rejoin ["File path converts to: " file-result]

;; Hypothesis: Refinement paths should convert appropriately
test-refinement: /some/path
refinement-result: to-string test-refinement
print rejoin ["Refinement path converts to: " refinement-result]

;;-----------------------------
;; Probing `issue!` Type
;;-----------------------------
print "^/--- Probing `issue!` Type ---"
;; Hypothesis: Issues should convert without the # prefix
test-issue: #issue-123
issue-result: to-string test-issue
print rejoin ["Issue #issue-123 converts to: " issue-result]

;;-----------------------------
;; Probing `tag!` Type
;;-----------------------------
print "^/--- Probing `tag!` Type ---"
;; Hypothesis: Tags should convert to their string representation including brackets
test-tag: <html>
tag-result: to-string test-tag
print rejoin ["Tag <html> converts to: " tag-result]

;;-----------------------------
;; Probing Function! and Native! Types
;;-----------------------------
;; Hypothesis: Native functions should have identifiable string representation
native-result: to-string :print
print rejoin ["Native function :print converts to: " native-result]

;;-----------------------------
;; Probing Error Conditions
;;-----------------------------
print "^/--- Probing Error Conditions ---"
;; Hypothesis: to-string should handle unset! values gracefully or error
; Using `try` to catch any potential errors
print "Testing `unset!` value handling..."
set/any 'unset-result try [to-string ()]
either error? unset-result [
    print "✓ to-string correctly errors on `unset!` values"
][
    print rejoin ["An `unset!` value converts to: " unset-result]
]

;;-----------------------------
;; Probing Binary! Type
;;-----------------------------
print "^/--- Probing Binary! Type ---"
;; Hypothesis: Binary values should convert to a string representation
test-binary: #{DEADBEEF}
binary-result: to-string test-binary
print rejoin ["Binary #{DEADBEEF} converts to: " binary-result]

;; Hypothesis: Empty binary should have predictable conversion
empty-binary: #{}
empty-binary-result: to-string empty-binary
print rejoin ["Empty binary converts to: " empty-binary-result]

;;-----------------------------
;; Probing Special String Cases
;;-----------------------------
print "^/--- Probing Special String Cases ---"
;; Hypothesis: Strings with embedded quotes should be handled correctly
quoted-string: {He said "Hello"}
quoted-result: to-string quoted-string
print rejoin ["String with quotes converts to: " quoted-result]

;; Hypothesis: Strings with special characters should preserve them
special-chars: "Tab:^-NewLine:^/CarriageReturn:^M"
special-result: to-string special-chars
print rejoin ["String with special chars converts to: " special-result]

;;-----------------------------
;; Final Summary
;;-----------------------------
print-test-summary
