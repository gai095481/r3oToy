Rebol [
    Title: "FORMAT Function Diagnostic Probe Script"
    Purpose: "Comprehensive testing of the FORMAT function behavior and refinements"
    Author: "Claude 4 Sonnet fixed by Gemini Pro AI Assistant"
    Date: 9-Jul-2025
    Version: 0.3.0
    Target: "REBOL/Bulk 3.19.0 (Oldes Branch)"
]

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
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
;; FORMAT Function Diagnostic Probe Script
;;-----------------------------------------------------------------------------
print "^/=========================================="
print "FORMAT Function Comprehensive Diagnostic"
print "=========================================="

;;-----------------------------------------------------------------------------
;; Section 1: Basic Format Function Structure and Type Checking
;;-----------------------------------------------------------------------------
print "^/--- Section 1: Basic Function Structure ---"

;; Hypothesis: FORMAT should be a function that accepts two arguments (rules and values)
;; and returns a formatted string according to the dialect specified in rules
print "^/Testing basic function properties..."

assert-equal function! type? :format "FORMAT should be a function! type"

;; Test basic invocation with minimal arguments
test-result: format [] []
assert-equal string! type? test-result "FORMAT should return a string! type"
assert-equal "" test-result "FORMAT with empty rules and values should return empty string"

;;-----------------------------------------------------------------------------
;; Section 2: Integer Rule Behavior (Positive and Negative Field Widths)
;;-----------------------------------------------------------------------------
print "^/--- Section 2: Integer Rule Behavior ---"

;; Hypothesis: Positive integers create LEFT-aligned fields.
;; Negative integers create RIGHT-aligned fields. (This is inverted from some other languages)
print "^/Testing integer field width formatting..."

test-result: format [5] ["hi"]
assert-equal "hi   " test-result "Positive integer (5) should LEFT-align with spaces"

test-result: format [-5] ["hi"]
assert-equal "   hi" test-result "Negative integer (-5) should RIGHT-align with spaces"

test-result: format [3] ["hello"]
assert-equal "hel" test-result "Field width smaller than content should truncate"

test-result: format [-3] ["hello"]
assert-equal "hel" test-result "Negative field width smaller than content should truncate"

;; Test with numbers that need string conversion
test-result: format [4] [123]
assert-equal "123 " test-result "Numbers with positive width (4) should be LEFT-aligned"

test-result: format [-4] [123]
assert-equal " 123" test-result "Numbers with negative width (-4) should be RIGHT-aligned"

;;-----------------------------------------------------------------------------
;; Section 3: String Rule Behavior (Literal Text Insertion)
;;-----------------------------------------------------------------------------
print "^/--- Section 3: String Rule Behavior ---"

;; Hypothesis: String rules insert literal text into the output between formatted values
print "^/Testing string literal insertion..."

test-result: format ["hello"] []
assert-equal "hello" test-result "String rules should insert literal text"

test-result: format ["x" "y" "z"] []
assert-equal "xyz" test-result "Multiple string rules should concatenate"

test-result: format [3 ":" -3] ["ab" "cd"]
assert-equal "ab : cd" test-result "String rules should work between integer field rules"

;;-----------------------------------------------------------------------------
;; Section 4: Character Rule Behavior
;;-----------------------------------------------------------------------------
print "^/--- Section 4: Character Rule Behavior ---"

;; Hypothesis: Character rules insert single characters into the output
print "^/Testing character insertion..."

test-result: format [#"x"] []
assert-equal "x" test-result "Character rules should insert single characters"

test-result: format [#"a" #"b" #"c"] []
assert-equal "abc" test-result "Multiple character rules should concatenate"

test-result: format [3 #"-" -3] ["hi" "bye"]
assert-equal "hi -bye" test-result "Character rules should work between field formatting"

;;-----------------------------------------------------------------------------
;; Section 5: Money Rule Behavior (ANSI Color Codes)
;;-----------------------------------------------------------------------------
print "^/--- Section 5: Money Rule Behavior ---"

;; Hypothesis: Money rules generate ANSI color escape sequences ending in 'm'
print "^/Testing money rule ANSI color generation..."

test-result: format [$32] []
expected-ansi: "^[[32m"
assert-equal expected-ansi test-result "Money rules should generate ANSI color codes ending in 'm'"

test-result: format [$91] []
expected-ansi: "^[[91m"
assert-equal expected-ansi test-result "Different money values should generate different ANSI codes"

;;-----------------------------------------------------------------------------
;; Section 6: Tag Rule Behavior (Date/Time Formatting)
;;-----------------------------------------------------------------------------
print "^/--- Section 6: Tag Rule Behavior ---"

;; Hypothesis: The REPL reveals that date/time formatting is extremely limited.
;; Specifiers like YYYY, DD, HH, SS are treated as LITERALS. Only MM (month) seems to work as a specifier.
print "^/Testing tag rule behavior..."

;; Test with a word value - tag is inserted literally, and the word is appended.
test-date-word: 'test-date-word
test-result: format [<YYYY-MM-DD>] [test-date-word]
assert-equal "<YYYY-MM-DD>test-date-word" test-result "Tag with word value should treat tag as literal and append word"

;; Test with date! value - reveals only MM is processed as a specifier.
test-result: format [<YYYY-MM-DD>] [1-Jan-2025]
assert-equal "YYYY-01-DD" test-result "Tag with date! value only formats MM, treating YYYY and DD as literals"

;; Test with time! value - reveals that HH, MI, and SS are not valid specifiers and produce odd output.
test-result: format [<HH:MI:SS>] [12:30:45]
assert-equal "HH:7I:SS" test-result "Tag with time! shows that HH, MI, SS specifiers do not work as expected"

;;-----------------------------------------------------------------------------
;; Section 7: /pad Refinement Behavior
;;-----------------------------------------------------------------------------
print "^/--- Section 7: /pad Refinement Behavior ---"

;; Hypothesis: /pad refinement changes the padding character, respecting the inverted alignment rules.
print "^/Testing /pad refinement..."

test-result: format/pad [5] ["hi"] #"*"
assert-equal "hi***" test-result "/pad with positive width (5) should LEFT-align"

test-result: format/pad [-5] ["hi"] #"."
assert-equal "...hi" test-result "/pad with negative width (-5) should RIGHT-align"

test-result: format/pad [3 3] ["a" "b"] #"0"
assert-equal "a00b00" test-result "/pad should apply to all integer field formatting"

;;-----------------------------------------------------------------------------
;; Section 8: Mixed Rule Type Combinations
;;-----------------------------------------------------------------------------
print "^/--- Section 8: Mixed Rule Type Combinations ---"

;; Hypothesis: Different rule types can be combined in complex formatting patterns
print "^/Testing mixed rule combinations..."

test-result: format [5 ": " -8 " [" 3 "]"] ["name" "value" 42]
assert-equal "name :    value [42 ]" test-result "Mixed rules should create complex formatting patterns"

test-result: format [$32 "Hello " -6 $0 "!"] ["World"]
assert-equal "^[[32mHello  World^[[0m!" test-result "Mixed money and other rules should work together"

;;-----------------------------------------------------------------------------
;; Section 9: Edge Cases and Error Conditions
;;-----------------------------------------------------------------------------
print "^/--- Section 9: Edge Cases and Error Conditions ---"

;; Hypothesis: Various edge cases should be handled gracefully
print "^/Testing edge cases..."

;; Test with more values than rules. Unconsumed values are appended without formatting.
test-result: format [3] ["a" "b" "c"]
assert-equal "a  bc" test-result "Extra values should be appended to output without formatting"

;; Test with zero field width
test-result: format [0] ["hello"]
assert-equal "" test-result "Zero field width should result in empty field"

;; Test with empty string value
test-result: format [5] [""]
assert-equal "     " test-result "Empty string should pad to full field width"

;; Test with none values
test-result: format [-4] [none]
assert-equal "none" test-result "None values should be converted to string 'none'"

;; Test rules as non-block (should be reduced to block)
test-result: format 5 ["test"]
assert-equal "test " test-result "Non-block positive rule should left-align"

;; Test values as non-block (should be reduced to block)
test-result: format [4] "test"
assert-equal "test" test-result "Non-block values should be reduced to block"

;;-----------------------------------------------------------------------------
;; Section 10: Word Rule Behavior (Variable Resolution)
;;-----------------------------------------------------------------------------
print "^/--- Section 10: Word Rule Behavior ---"

;; Hypothesis: Word rules should resolve to their values before processing
print "^/Testing word rule resolution..."

field-width: 6
test-result: format [field-width] ["hello"]
assert-equal "hello " test-result "Word rule (6) should resolve and left-align"

separator: "|"
test-result: format [3 separator -3] ["ab" "cd"]
assert-equal "ab | cd" test-result "String word rules should resolve properly"

pad-rule: -4
test-result: format [pad-rule] ["hi"]
assert-equal "  hi" test-result "Integer word rule should resolve and right-align"

;;-----------------------------------------------------------------------------
;; Section 11: Complex Real-World Scenarios
;;-----------------------------------------------------------------------------
print "^/--- Section 11: Complex Real-World Scenarios ---"

;; Hypothesis: FORMAT should handle realistic formatting scenarios, acknowledging the revealed limitations.
print "^/Testing realistic formatting scenarios..."

;; Table-like formatting
test-result: format [10 " | " -15 " | " 8] ["Name" "Description" "Value"]
assert-equal "Name       |     Description | Value   " test-result "Table header formatting should work"

;; Log entry formatting -- Asserting the actual, buggy behavior of the time tag.
test-result: format ["[" <HH:MI:SS> "] " -8 ": "] [12:34:56 "INFO" "System started"]
assert-equal "[HH:7I:SS]     INFO: System started" test-result "Log entry demonstrates the tag rule's idiosyncratic behavior"

;; Configuration file formatting
test-result: format [-20 " = "] ["database_host" "localhost"]
assert-equal "       database_host = localhost" test-result "Configuration formatting should work (with observed padding)"

print "^/--- End of Diagnostic Tests ---"
print-test-summary
