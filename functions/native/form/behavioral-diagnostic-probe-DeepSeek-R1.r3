Rebol []

;; Diagnostic Probe Script for `form` function
;; Target: REBOL/Bulk 3.19.0 (Oldes Branch)
;; Purpose: Systematically probe behavior of `form` native function
;; Methodology: "Truth from the REPL" - all claims backed by executable tests

;;------------------------------
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

;;-------------------------------------
;; Diagnostic Tests for FORM function
;;-------------------------------------
print "=== STARTING FORM FUNCTION DIAGNOSTICS ==="

;; Hypothesis 1: Basic scalar types form to their expected string representations
print "^/=== Group 1: Basic Scalar Types ==="
assert-equal "123" form 123 "Integer forms to decimal digits"
assert-equal "3.14" form 3.14 "Decimal forms with point"
assert-equal "hello" form "hello" "String forms to itself"
assert-equal "a" form #"a" "Character forms to single character"
assert-equal "true" form true "TRUE logic forms to 'true'"
assert-equal "false" form false "FALSE logic forms to 'false'"
assert-equal "10:30:45" form 10:30:45 "Time forms to HH:MM:SS"
assert-equal "14-Jul-2025" form 2025-07-14 "Date forms to DD-Mon-YYYY format"

;; Hypothesis 2: Special values form to expected representations
print "^/=== Group 2: Special Values ==="
assert-equal "none" form none "NONE value forms to 'none'"
assert-equal "true" form on "ON forms to 'true'"
assert-equal "false" form off "OFF forms to 'false'"
assert-equal "none" form 'none "WORD! 'none forms to 'none'"

;; Hypothesis 3: Blocks form to space-delimited elements without brackets
print "^/=== Group 3: Block Values ==="
assert-equal "a b c" form [a b c] "Block of words forms to space-separated"
assert-equal "1 2 3" form [1 2 3] "Block of integers forms to space-separated"
assert-equal "apple 123 true" form ['apple 123 true] "Mixed block forms correctly"
assert-equal "10:30 14-Jul-2025" form [10:30 2025-07-14] "Block of temporal types"
assert-equal "hello world" form ["hello" "world"] "Block of strings forms concatenated"

;; Hypothesis 4: Edge cases and empty values form as expected
print "^/=== Group 4: Edge Cases ==="
assert-equal "" form "" "Empty string forms to empty string"
assert-equal "" form [] "Empty block forms to empty string"
assert-equal "0" form 0 "Zero integer forms to '0'"
assert-equal "0.0" form 0.0 "Zero decimal forms to '0.0'"
assert-equal "1234567890" form 1234567890 "Large integer forms correctly"
assert-equal "1.23456789" form 1.23456789 "High precision decimal forms correctly"
assert-equal "abc^/def" form "abc^/def" "String with newline preserves newline"

;; Hypothesis 5: Word-like values form to their string representation
print "^/=== Group 5: Word and Path Values ==="
; Safely construct word types to avoid syntax issues
test-word: to word! "word"
test-set-word: to set-word! "set-word"
test-lit-word: to lit-word! "lit-word"
test-get-word: to get-word! "get-word"
test-path: to path! "path/to/value"

assert-equal "word" form test-word "Word forms to string without colon"
assert-equal "set-word" form test-set-word "Set-word forms without colon"
assert-equal "lit-word" form test-lit-word "Lit-word forms without apostrophe"
assert-equal "get-word" form test-get-word "Get-word forms without colon"
assert-equal {#(path! ["path/to/value"])} form test-path "Path forms to molded representation"

;; Hypothesis 6: Complex types form to human-readable representations
print "^/=== Group 6: Complex Types ==="
assert-equal "10x20" form 10x20 "Pair forms to X-separated"
assert-equal "3" form (1 2 3) "Tuple forms to number of elements"
assert-equal "" form context [] "Object forms to empty string"
assert-equal "a: 1^/b: 2" form make map! [a 1 b 2] "Map forms to key-value pairs"
assert-equal "make function! [[][]]" form func [] [] "Function forms to constructor syntax"

;; Hypothesis 7: Datatypes form to their name
print "^/=== Group 7: Datatype Values ==="
assert-equal "integer!" form integer! "Datatype forms to type name"
assert-equal "block!" form block! "Block datatype forms correctly"
assert-equal "string!" form string! "String datatype forms correctly"

;; Hypothesis 8: Binary values form to hexadecimal representation
print "^/=== Group 8: Binary Values ==="
assert-equal "0102ABCD" form #{0102ABCD} "Binary forms to uppercase hex"
assert-equal "" form #{} "Empty binary forms to empty string"

;; Hypothesis 9: URL and email values form to their string representation
print "^/=== Group 9: Network Related Values ==="
assert-equal "http://example.com" form http://example.com "URL forms to string"
assert-equal "user@example.com" form user@example.com "Email forms to string"

;; Hypothesis 10: File and tag values form to their string representation
print "^/=== Group 10: File and Tag Values ==="
assert-equal "file.txt" form %file.txt "File forms to string without %"
assert-equal "<tag>" form <tag> "Tag forms with angle brackets"

;; Print final test summary
print-test-summary
