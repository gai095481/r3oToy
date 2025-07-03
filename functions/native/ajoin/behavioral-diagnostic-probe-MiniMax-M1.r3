Rebol []

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
        print "✅ ALL `ajoin` EXAMPLES PASSED"
    ][
        print "❌ SOME `ajoin` EXAMPLES FAILED"
    ]
    print "============================================^/"
]

; Start of tests
print "=== Probing ajoin Function ==="

; Probing Basic Behavior
print "^/=== Probing Basic Behavior ==="
; Hypothesis: ajoin concatenates elements of the block into a string, ignoring none and unset.

; Test 1: Basic string concatenation
assert-equal "ABCDEF" ajoin ["ABC" "DEF"] "Basic string concatenation"

; Test 2: Numbers and strings
assert-equal "1apple3.14" ajoin [1 "apple" 3.14] "Numbers and strings"

; Test 3: Ignore none by default
assert-equal "x" ajoin [none "x"] "Ignore none"

; Test 4: Reduction of expressions
assert-equal "3" ajoin [1 + 2] "Reduction of expressions"

; Probing /with Refinement
print "^/=== Probing /with Refinement ==="
; Hypothesis: /with adds a delimiter between elements.

; Test 5: Delimiter between strings
assert-equal "a-b" ajoin/with ["a" "b"] "-" "With delimiter strings"

; Test 6: Delimiter between numbers and strings
assert-equal "1, 2, 3" ajoin/with [1 2 3] ", " "With delimiter numbers and strings"

; Test 7: Delimiter is a character
assert-equal "a|b" ajoin/with ["a" "b"] #"|" "With character delimiter"

; Probing /all Refinement
print "^/=== Probing /all Refinement ==="
; Hypothesis: /all includes none and unset as their string representations.

; Test 8: Include none with /all
assert-equal "nonex" ajoin/all [none "x"] "Include none with /all"

; Probing Edge Cases
print "^/=== Probing Edge Cases ==="
; Hypothesis: ajoin handles edge cases like empty block, all invalid elements.

; Test 9: Empty block returns empty string
assert-equal "" ajoin [] "Empty block"

; Test 10: All elements are none (without /all)
assert-equal "" ajoin [none none] "All nones default"

; Test 11: All elements are none with /all
assert-equal "nonenone" ajoin/all [none none] "All nones with /all"

; Test 12: Block with sub-block (ajoin recursively processes sub-blocks)
sub-block: [1 2]
assert-equal "1 2" ajoin [sub-block] "Sub-block processed recursively"

; Probing Data Types
print "^/=== Probing Data Types ==="
; Hypothesis: ajoin converts various data types to their string representations.

; Test 13: Character
assert-equal "A" ajoin [#"A"] "Character type"

; Test 14: Tag
assert-equal "<ABC>" ajoin [<ABC>] "Tag type"

; Test 15: Date
date-value: 2025-07-03
date-string: mold date-value
assert-equal date-string ajoin [date-value] "Date type"

; Test 16: Logic values
assert-equal "true" ajoin [true] "True value"
assert-equal "false" ajoin [false] "False value"

; Test 17: File path
assert-equal "/home/user/file.txt" ajoin [%/home/user/file.txt] "File type"

; Probing Error Conditions
print "^/=== Probing Error Conditions ==="
; Hypothesis: ajoin requires a block argument.

; Test 18: Non-block argument throws error
assert-equal true error? try [ajoin "string"] "Non-block argument errors"

; Print test summary
print-test-summary
