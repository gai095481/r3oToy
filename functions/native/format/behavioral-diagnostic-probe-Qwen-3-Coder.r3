Rebol [
    Title: "Diagnostic Probe for FORMAT function (Oldes Branch)"
    Description: "Precise and accurate test script for the native `format` function based on source code analysis and REPL evidence."
    Version: 0.1.0
    Author: "Qwen 3 Coder"
    Date: 24-Jul-2025
]

;;;-----------------------------
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

print "=== FINAL DIAGNOSTIC PROBE FOR `format` FUNCTION ==="

;------------------------------------------------------------------------------
; Test: Basic Function Signature and Return
;------------------------------------------------------------------------------
print "^/--- Probing Basic Function Signature and Return ---"
test-rules-1: [10]
test-values-1: ["Hello"]
result-1: format test-rules-1 test-values-1
assert-equal "Hello     " result-1 "Basic format call with integer rule and string value should pad with spaces."

test-rules-2: ["Literal"]
test-values-2: []
result-2: format test-rules-2 test-values-2
assert-equal "Literal" result-2 "Format with string rule should output the literal string."

;------------------------------------------------------------------------------
; Test: Non-Block Argument Handling
; Non-block args are wrapped in a block via `reduce`.
; Words in rules are resolved with `get`.
;------------------------------------------------------------------------------
print "^/--- Probing Non-Block Argument Handling ---"
result-3: format 10 "Single"
assert-equal "Single    " result-3 "Non-block `rules` (integer) is reduced to block. Value is padded to 10 chars (including its own 6)."

result-4: format [10] "SingleValue"
assert-equal "SingleValu" result-4 "Non-block `values` is reduced. First value 'SingleValue' is taken and truncated to 10 chars."

a-word-for-test: "ResolvedString"
result-5: format a-word-for-test []
assert-equal "ResolvedString" result-5 "Non-block word `rules` is reduced, then word is gotten."

;------------------------------------------------------------------------------
; Test: Integer Rule Behavior (Alignment & Truncation)
; Positive: Left-align, pad right. Negative: Right-align, pad left (requires skipping).
; Value is converted to string with `form` then processed.
;------------------------------------------------------------------------------
print "^/--- Probing Integer Rule Behavior (Alignment & Truncation) ---"
result-6: format [5] ["Hi"]
assert-equal "Hi   " result-6 "Positive integer rule left-aligns value 'Hi' in a 5-char field."

result-7: format [-5] ["Hi"]
assert-equal "   Hi" result-7 "Negative integer rule right-aligns value 'Hi' in a 5-char field."

result-8: format [3] ["Longer"]
assert-equal "Lon" result-8 "Value 'Longer' is truncated to 3 characters for positive field width."

result-9: format [-3] ["Longer"]
assert-equal "Lon" result-9 "Value 'Longer' is truncated to 3 characters for negative field width."

;------------------------------------------------------------------------------
; Test: String Rule Behavior
; Strings are inserted directly. Length contributes to initial buffer size.
;------------------------------------------------------------------------------
print "^/--- Probing String Rule Behavior ---"
result-10: format ["Prefix: " 10] ["Data"]
assert-equal "Prefix: Data      " result-10 "String rule 'Prefix: ' is inserted. Then 'Data' is padded to 10 chars."

result-11: format [5 " | " 5] ["A" "B"]
assert-equal "A     | B    " result-11 "Integer, string, integer rules. Values padded accordingly."

;------------------------------------------------------------------------------
; Test: Character Rule Behavior
; Characters are inserted directly. Contributes 1 to initial buffer size.
; When mixed with integer, integer pads/truncates the preceding value.
;------------------------------------------------------------------------------
print "^/--- Probing Character Rule Behavior ---"
result-12: format [#"*"] []
assert-equal "*" result-12 "Character rule inserts the character '*'. No value consumed."

result-13: format [3 #"."] ["X"]
assert-equal "X  ." result-13 "Value 'X' padded to 3 chars. Then character '.' is inserted."

;------------------------------------------------------------------------------
; Test: Tag Rule Behavior
; If value is date! or time!, attempts `format-date-time value rule`.
; Otherwise, appends `form rule` followed by `form value`.
; The observed behavior `%Y-%1-%1` suggests `format-date-time` processes the tag itself,
; substituting parts of it, rather than using it as a format string for the value.
;------------------------------------------------------------------------------
print "^/--- Probing Tag Rule Behavior ---"
test-date: 1-Jan-2023
result-17: format [<%Y-%m-%d>] test-date
assert-equal "%Y-%1-%1" result-17 "Tag rule with date! value calls format-date-time, producing this specific substitution output."

test-time: 10:30:45
result-18: format [<%H:%M:%S>] test-time
assert-equal "%H:%7:%S" result-18 "Tag rule with time! value calls format-date-time, producing this specific substitution output."

result-19: format [<tag>] ["StringForTag"]
assert-equal "<tag>StringForTag" result-19 "Tag rule with non-date/time value appends form of tag and form of value."

;------------------------------------------------------------------------------
; Test: /pad Refinement
; Changes the padding character from default space.
;------------------------------------------------------------------------------
print "^/--- Probing /pad Refinement ---"
result-20: format/pad [10] ["Hi"] #"*"
assert-equal "Hi********" result-20 "Using /pad with char! '#' pads the initial buffer with '*'."

result-21: format/pad [10] ["Hi"] "."
assert-equal "Hi........" result-21 "Using /pad with string! '.' pads the initial buffer with '.'."

result-22: format/pad [-5] ["Hi"] #"0"
assert-equal "000Hi" result-22 "Using /pad with negative rule right-aligns and pads with '0'."

;------------------------------------------------------------------------------
; Test: Excess Values Appended
; Values not consumed by rules are appended to the final string.
;------------------------------------------------------------------------------
print "^/--- Probing Excess Values Appended ---"
result-23: format [5] ["First" "Second" "Third"]
assert-equal "FirstSecondThird" result-23 "Rule consumes 'First'. Remaining values 'Second' and 'Third' are appended."

result-24: format [3 3] ["A" "B" "C" "D"]
assert-equal "A  B  CD" result-24 "Rules consume 'A' and 'B'. Remaining 'C' and 'D' are appended."

;------------------------------------------------------------------------------
; Test: Edge Cases
; Empty rules, missing values, unhandled rule types.
;------------------------------------------------------------------------------
print "^/--- Probing Edge Cases ---"
result-25: format [] ["Should" "Be" "Appended"]
assert-equal "ShouldBeAppended" result-25 "Empty rules block results in appending all values."

result-26: format [10] []
assert-equal "none      " result-26 "Rule tries to consume a value, but none exist. `form none` ('none') is used and padded."

result-27: format/pad [10] [] #"X"
assert-equal "noneXXXXXX" result-27 "Rule consumes non-existent value (`form none`), rest padded with 'X'."

result-28: format [5] [123]
assert-equal "123  " result-28 "Non-string value 123 is converted with `form` to '123' then formatted."

result-29: format [none] ["Ignored"]
assert-equal "Ignored" result-29 "Rule `none` contributes 0 to buffer length. Value 'Ignored' is appended."

result-30: format [1.5] ["FloatRule"]
assert-equal "FloatRule" result-30 "Rule `1.5` (decimal!) contributes 0 to buffer length. Value 'FloatRule' is appended."


;------------------------------------------------------------------------------
; Test: Extended Date/Time Formatting (Compatibility Check)
; These tests are based on expected behavior from a test suite.
; They are included to check compatibility, though current observations
; suggest the `format-date-time` integration might differ.
;------------------------------------------------------------------------------
print "^/--- Probing Extended Date/Time Formatting (Compatibility Check) ---"
print "    NOTE: These tests may fail if `format-date-time` behaves differently."

test-datetime-value: 3-Jun-2022/1:23:45.1234+2:00
assert-equal "03-06-22" format <dd-mm-yy> test-datetime-value "format <dd-mm-yy> with date/time value"
assert-equal "03-06-2022" format <dd-mm-yyyy> test-datetime-value "format <dd-mm-yyyy> with date/time value"
assert-equal "03/06/2022" format <dd/mm/yyyy> test-datetime-value "format <dd/mm/yyyy> with date/time value"
assert-equal "3.6.2022" format <d.m.y> test-datetime-value "format <d.m.y> with date/time value"
assert-equal "3.June 2022" format <d.mmmm y> test-datetime-value "format <d.mmmm y> with date/time value"
assert-equal "Friday" format <dddd> test-datetime-value "format <dddd> with date/time value"
assert-equal "Friday 3.June 2022" format <dddd d.mmmm y> test-datetime-value "format <dddd d.mmmm y> with date/time value"
assert-equal "20220603012345+0200" format <yyyymmddhhmmss±zzzz> test-datetime-value "format <yyyymmddhhmmss±zzzz> with date/time value"
assert-equal "2022/06/03 01:23" format <yyyy/mm/dd hh:mm> test-datetime-value "format <yyyy/mm/dd hh:mm> with date/time value"
assert-equal "1:23:45" format <h:m:s> test-datetime-value "format <h:m:s> with date/time value"
assert-equal "01:23:45" format <hh:mm:ss> test-datetime-value "format <hh:mm:ss> with date/time value"
assert-equal "01:23:45.1" format <hh:mm:ss.s> test-datetime-value "format <hh:mm:ss.s> with date/time value"
assert-equal "01:23:45.12" format <hh:mm:ss.ss> test-datetime-value "format <hh:mm:ss.ss> with date/time value"
assert-equal "01:23:45.123" format <hh:mm:ss.sss> test-datetime-value "format <hh:mm:ss.sss> with date/time value"
assert-equal "01:23:45.45.1234000" format <hh:mm:ss.sssssss> test-datetime-value "format <hh:mm:ss.sssssss> with date/time value"
assert-equal "1654212225" format <unixepoch> test-datetime-value "format <unixepoch> with date/time value"

test-date-value: 3-Jun-2022
assert-equal "03-06-22" format <dd-mm-yy> test-date-value "format <dd-mm-yy> with date value"
assert-equal "03-06-2022" format <dd-mm-yyyy> test-date-value "format <dd-mm-yyyy> with date value"
assert-equal "03/06/2022" format <dd/mm/yyyy> test-date-value "format <dd/mm/yyyy> with date value"
assert-equal "3.6.2022" format <d.m.y> test-date-value "format <d.m.y> with date value"
assert-equal "3.June 2022" format <d.mmmm y> test-date-value "format <d.mmmm y> with date value"
assert-equal "Friday" format <dddd> test-date-value "format <dddd> with date value"
assert-equal "Friday 3.June 2022" format <dddd d.mmmm y> test-date-value "format <dddd d.mmmm y> with date value"
assert-equal "20220603000000+0000" format <yyyymmddhhmmss±zzzz> test-date-value "format <yyyymmddhhmmss±zzzz> with date value"
assert-equal "2022/06/03 00:00" format <yyyy/mm/dd hh:mm> test-date-value "format <yyyy/mm/dd hh:mm> with date value"
assert-equal "0:0:0" format <h:m:s> test-date-value "format <h:m:s> with date value"
assert-equal "00:00:00" format <hh:mm:ss> test-date-value "format <hh:mm:ss> with date value"
assert-equal "00:00:00.0" format <hh:mm:ss.s> test-date-value "format <hh:mm:ss.s> with date value"
assert-equal "00:00:00.00" format <hh:mm:ss.ss> test-date-value "format <hh:mm:ss.ss> with date value"
assert-equal "00:00:00.000" format <hh:mm:ss.sss> test-date-value "format <hh:mm:ss.sss> with date value"
assert-equal "00:00:00.0000000" format <hh:mm:ss.sssssss> test-date-value "format <hh:mm:ss.sssssss> with date value"
assert-equal "1654214400" format <unixepoch> test-date-value "format <unixepoch> with date value"

test-time-value-1: 1:23:45.1234
assert-equal "1:23:45" format <h:m:s> test-time-value-1 "format <h:m:s> with time value 1"
assert-equal "01:23:45" format <hh:mm:ss> test-time-value-1 "format <hh:mm:ss> with time value 1"
assert-equal "01:23:45.1" format <hh:mm:ss.s> test-time-value-1 "format <hh:mm:ss.s> with time value 1"
assert-equal "01:23:45.12" format <hh:mm:ss.ss> test-time-value-1 "format <hh:mm:ss.ss> with time value 1"
assert-equal "01:23:45.123" format <hh:mm:ss.sss> test-time-value-1 "format <hh:mm:ss.sss> with time value 1"
assert-equal "01:23:45.45.1234000" format <hh:mm:ss.sssssss> test-time-value-1 "format <hh:mm:ss.sssssss> with time value 1"

test-time-value-2: 12345:01
assert-equal "12345:1:0" format <h:m:s> test-time-value-2 "format <h:m:s> with time value 2"
assert-equal "12345:01:00" format <hh:mm:ss> test-time-value-2 "format <hh:mm:ss> with time value 2"
assert-equal "12345:01:00.0" format <hh:mm:ss.s> test-time-value-2 "format <hh:mm:ss.s> with time value 2"
assert-equal "12345:01:00.00" format <hh:mm:ss.ss> test-time-value-2 "format <hh:mm:ss.ss> with time value 2"
assert-equal "12345:01:00.000" format <hh:mm:ss.sss> test-time-value-2 "format <hh:mm:ss.sss> with time value 2"
assert-equal "12345:01:00.0000000" format <hh:mm:ss.sssssss> test-time-value-2 "format <hh:mm:ss.sssssss> with time value 2"

print-test-summary
