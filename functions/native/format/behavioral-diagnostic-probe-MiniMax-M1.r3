Rebol [
    Title: "FORMAT Function Diagnostic Probe Script"
    Purpose: "Comprehensive testing of the FORMAT function behavior and refinements"
    Author: "AI Assistant"
    Date: 9-Jul-2025
    Version: 1.0.0
    Target: "REBOL/Bulk 3.19.0 (Oldes Branch)"
]

;;----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;----------------------------------------------------------------------------
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

;;----------------------------------------------------------------------------
print "^/=========================================="
print "FORMAT Function Comprehensive Diagnostic"
print "=========================================="

;;----------------------------------------------------------------------------
print "^/--- Section 1: Basic Function Structure and Type Checking ---"

assert-equal function! type? :format "FORMAT should be a function! type"

test-result: format [] []
assert-equal string! type? test-result "FORMAT should return a string! type"
assert-equal "" test-result "FORMAT with empty rules and values should return empty string"

;;----------------------------------------------------------------------------
print "^/--- Section 2: Integer Rule Behavior (Positive and Negative Field Widths) ---"

test-result: format [5] ["hi"]
assert-equal "hi   " test-result "Positive integer should left-align with spaces"

test-result: format [-5] ["hi"]
assert-equal "   hi" test-result "Negative integer should right-align with spaces"

test-result: format [3] ["hello"]
assert-equal "hel" test-result "Field width smaller than content should truncate"

test-result: format [-3] ["hello"]
assert-equal "hel" test-result "Negative field width smaller than content should truncate"

test-result: format [4] [123]
assert-equal "123 " test-result "Numbers should be converted to strings and left-aligned"

test-result: format [-4] [123]
assert-equal " 123" test-result "Numbers with negative field width should right-align"

;;----------------------------------------------------------------------------
print "^/--- Section 3: String Rule Behavior (Literal Text Insertion) ---"

test-result: format ["hello"] []
assert-equal "hello" test-result "String rules should insert literal text"

test-result: format ["x" "y" "z"] []
assert-equal "xyz" test-result "Multiple string rules should concatenate"

;; Removed duplicate mixed rule test from Section 3

;;----------------------------------------------------------------------------
print "^/--- Section 4: Character Rule Behavior ---"

test-result: format [#"x"] []
assert-equal "x" test-result "Character rules should insert single characters"

test-result: format [#"a" #"b" #"c"] []
assert-equal "abc" test-result "Multiple character rules should concatenate"

test-result: format [3 #"-" -3] ["hi" "bye"]
assert-equal "hi -bye" test-result "Character rules should work between field formatting"

;;----------------------------------------------------------------------------
print "^/--- Section 5: Money Rule Behavior (ANSI Color Codes) ---"

test-result: format [$32] []
expected-ansi: "^[[32m"
assert-equal expected-ansi test-result "Money rules should generate ANSI color codes"

test-result: format [$91] []
expected-ansi: "^[[91m"
assert-equal expected-ansi test-result "Different money values should generate different ANSI codes"

;;----------------------------------------------------------------------------
;; Section 6: Tag Rule Behavior (Date/Time Formatting)
;;----------------------------------------------------------------------------
print "^/--- Section 6: Tag Rule Behavior ---"

test-result: format [<test>] ["hello"]
assert-equal "<test>hello" test-result "Tag rules with non-date values should insert literal tag"

test-date: 1-Jan-2025
test-result: format [<YYYY-MM-DD>] [test-date]
assert-equal string! type? test-result "Tag rules with date values should return formatted string"

test-time: 12:30:45
test-result: format [<HH:MM:SS>] [test-time]
assert-equal string! type? test-result "Tag rules with time values should return formatted string"

;;----------------------------------------------------------------------------
;; Section 7: /pad Refinement Behavior
;;----------------------------------------------------------------------------
print "^/--- Section 7: /pad Refinement Behavior ---"

test-result: format/pad [5] ["hi"] #"*"
assert-equal "hi***" test-result "/pad should use specified character instead of spaces"

test-result: format/pad [-5] ["hi"] #"."
assert-equal "...hi" test-result "/pad should work with negative field widths"

test-result: format/pad [3 3] ["a" "b"] #"0"
assert-equal "a00b00" test-result "/pad should apply to all integer field formatting"

;;----------------------------------------------------------------------------
;; Section 8: Mixed Rule Type Combinations
;;----------------------------------------------------------------------------
print "^/--- Section 8: Mixed Rule Type Combinations ---"

test-result: format [5 ": " -8 " [" -3 "]"] ["name" "value" 42]
assert-equal "name :    value [ 42]" test-result "Mixed rules should create complex formatting patterns"

test-result: format [$32 "Hello " -6 $0 "!"] ["World"]
assert-equal string! type? test-result "Mixed money and other rules should work together"

;;----------------------------------------------------------------------------
print "^/--- Section 9: Edge Cases and Error Conditions ---"

test-result: format [3] ["a" "b" "c"]
assert-equal "a  bc" test-result "Extra values should be appended to output"

test-result: format [0] ["hello"]
assert-equal "" test-result "Zero field width should result in empty field"

test-result: format [5] [""]
assert-equal "     " test-result "Empty string should pad to full field width"

test-result: format [4] [none]
assert-equal "none" test-result "None values should be converted to string 'none'"

test-result: format 5 ["test"]
assert-equal "test " test-result "Non-block rules should be reduced to block"

test-result: format [4] "test"
assert-equal "test" test-result "Non-block values should be reduced to block"

;;----------------------------------------------------------------------------
print "^/--- Section 10: Word Rule Behavior (Variable Resolution) ---"

field-width: 6
test-result: format [field-width] ["hello"]
assert-equal "hello " test-result "Word rules should resolve to their values"

separator: "|"
test-result: format [3 separator -3] ["ab" "cd"]
assert-equal "ab | cd" test-result "String word rules should resolve properly"

pad-char: #"="
test-result: format [pad-char 4 pad-char] ["hi"]
assert-equal "=hi  =" test-result "Character word rules should resolve properly"

;;----------------------------------------------------------------------------
print "^/--- Section 11: Complex Real-World Scenarios ---"

test-result: format [20 " = " 9] ["database_host" "localhost"]
assert-equal "database_host        = localhost" test-result "Configuration formatting should work"

print "^/--- End of Diagnostic Tests ---"
print-test-summary
