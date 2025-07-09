Rebol [
    Title: "FORMAT Function Diagnostic Probe Script"
    Purpose: "Comprehensive testing of the FORMAT function behavior and refinements"
    Author: "AI Assistant"
    Date: 9-Jul-2025
    Version: 0.1.0
    Target: "REBOL/Bulk 3.19.0 (Oldes Branch)"
]

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: func [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    either equal? expected actual [
        result-style: "✅ PASSED:"
        message: description
    ][
        all-tests-passed?: false
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print rejoin [result-style " " message]
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
print "^/=========================================="
print "FORMAT Function Comprehensive Diagnostic"
print "=========================================="


;;-----------------------------------------------------------------------------
print "^/--- Section 1: Basic Function Structure and Type Checking ---"
print "^/Testing basic function properties..."

assert-equal function! type? :format "FORMAT should be a function! type"

test-result: format [] []
assert-equal string! type? test-result "FORMAT should return a string! type"
assert-equal "" test-result "FORMAT with empty rules and values should return empty string"

;;-----------------------------------------------------------------------------
print "^/--- Section 2: Integer Rule Behavior ---"
print "^/Testing integer field width formatting..."

test-result: format [5] ["hi"]
assert-equal "hi   " test-result "Positive integer field width pads on right"

test-result: format [-5] ["hi"]
assert-equal "   hi" test-result "Negative integer field width pads on left"

test-result: format [3] ["hello"]
assert-equal "hel" test-result "Field width smaller than content should truncate"

test-result: format [-3] ["hello"]
assert-equal "hel" test-result "Negative field width smaller than content should truncate"

test-result: format [4] [123]
assert-equal "123 " test-result "Numbers with positive field width pad on right"

test-result: format [-4] [123]
assert-equal " 123" test-result "Numbers with negative field width pad on left"

;;-----------------------------------------------------------------------------
print "^/--- Section 3: String Rule Behavior ---"
print "^/Testing string literal insertion..."

test-result: format ["hello"] []
assert-equal "hello" test-result "String rules should insert literal text"

test-result: format ["x" "y" "z"] []
assert-equal "xyz" test-result "Multiple string rules should concatenate"

test-result: format [3 ":" -3] ["ab" "cd"]
assert-equal "ab : cd" test-result "String rules should work between integer field rules"

;;-----------------------------------------------------------------------------
print "^/--- Section 4: Character Rule Behavior ---"
print "^/Testing character insertion..."

test-result: format [#"x"] []
assert-equal "x" test-result "Character rules should insert single characters"

test-result: format [#"a" #"b" #"c"] []
assert-equal "abc" test-result "Multiple character rules should concatenate"

test-result: format [3 #"-" -3] ["hi" "bye"]
assert-equal "hi -bye" test-result "Character rules should work between field formatting"

;;-----------------------------------------------------------------------------
print "^/--- Section 5: Money Rule Behavior ---"
print "^/Testing money rule ANSI color generation..."

test-result: format [$32] []
assert-equal "^[[32m" test-result "Money rules should generate ANSI color codes"

test-result: format [$91] []
assert-equal "^[[91m" test-result "Different money values should generate different ANSI codes"

;;-----------------------------------------------------------------------------
print "^/--- Section 6: Tag Rule Behavior ---"
print "^/Testing tag rule behavior..."

test-result: format [<test>] ["hello"]
assert-equal "<test>hello" test-result "Tag rules with non-date values should insert literal tag and append unconsumed values"

test-date: 1-Jan-2025
test-result: format [<YYYY-MM-DD>] [test-date]
assert-equal string! type? test-result "Tag rules with date values should return formatted string"

test-time: 12:30:45
test-result: format [<HH:MM:SS>] [test-time]
assert-equal string! type? test-result "Tag rules with time values should return formatted string"

;;-----------------------------------------------------------------------------
print "^/--- Section 7: /pad Refinement Behavior ---"
print "^/Testing /pad refinement..."

test-result: format/pad [5] ["hi"] #"*"
assert-equal "hi***" test-result "/pad should use specified character for positive field widths (right pad)"

test-result: format/pad [-5] ["hi"] #"."
assert-equal "...hi" test-result "/pad should work with negative field widths (left pad)"

test-result: format/pad [3 3] ["a" "b"] #"0"
assert-equal "a00b00" test-result "/pad should apply to all integer field formatting"

;;-----------------------------------------------------------------------------
print "^/--- Section 8: Mixed Rule Type Combinations ---"
print "^/Testing mixed rule combinations..."

test-result: format [5 ": " -8 " [" 3 "]"] ["name" "value" 42]
assert-equal "name :    value [42 ]" test-result "Mixed rules should create complex formatting patterns"

test-result: format [$32 "Hello " -6 $0 "!"] ["World"]
assert-equal string! type? test-result "Mixed money and other rules should work together"

;;-----------------------------------------------------------------------------
print "^/--- Section 9: Edge Cases and Error Conditions ---"
print "^/Testing edge cases..."

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

;;-----------------------------------------------------------------------------
print "^/--- Section 10: Word Rule Behavior ---"
print "^/Testing word rule resolution..."

field-width: 6
test-result: format [field-width] ["hello"]
assert-equal "hello " test-result "Word rules should resolve to their values"

separator: "|"
test-result: format [3 separator -3] ["ab" "cd"]
assert-equal "ab | cd" test-result "String word rules should resolve properly"

pad-char: #"="
test-result: format [pad-char 4 pad-char] ["hi"]
assert-equal "=hi  =" test-result "Character word rules should resolve properly"

;;-----------------------------------------------------------------------------
print "^/--- Section 11: Complex Real-World Scenarios ---"
print "^/Testing realistic formatting scenarios..."

test-result: format [10 " | " -15 " | " 8] ["Name" "Description" "Value"]
assert-equal "Name       |     Description | Value   " test-result "Table header formatting should work"

test-result: format ["[" <HH:MM:SS> "] " -8 ": " 0] [12:34:56 "INFO" "System started"]
assert-equal string! type? test-result "Log entry formatting should work"

test-result: format [-20 " = " 0] ["database_host" "localhost"]
assert-equal "       database_host = " test-result "Configuration formatting should work"

;;-----------------------------------------------------------------------------
print "^/--- End of Diagnostic Tests ---"
print-test-summary
