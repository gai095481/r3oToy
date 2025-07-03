REBOL [
    Title: "Diagnostic Probe for AJOIN"
    Description: "Tests the behavior of the AJOIN function in Rebol 3 Oldes branch."
  Author: "Grok 3"
    Version: 0.1.0
    Date: 03-Jul-2025
]

all-tests-passed?: true

assert-equal: function [
    "Compare two values and output a PASSED or FAILED message."
    expected [any-type!] "The expected value."
    actual [any-type!] "The actual value."
    description [string!] "Test description."
][
    either equal? expected actual [
        print ["✅ PASSED:" description]
    ][
        set 'all-tests-passed? false
        print ["❌ FAILED:" description]
        print ["   >> Expected:" mold expected]
        print ["   >> Actual:  " mold actual]
    ]
]

print-test-summary: does [
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL AJOIN TESTS PASSED"
    ][
        print "❌ SOME AJOIN TESTS FAILED"
    ]
    print "============================================^/"
]

print "Probing basic behavior without refinements"
;; Converts values to strings with FORM and concatenates, ignoring NONE by default.
assert-equal "abc" ajoin ["a" "b" "c"] "Joining block of strings"
assert-equal "123" ajoin [1 2 3] "Joining block of integers"
assert-equal "truefalse" ajoin [true false] "Joining block of logic values"
assert-equal "$10.50$20.50" ajoin [$10.50 $20.50] "Joining block of money values"
assert-equal "a1bc" ajoin ["a" 1 none "b" none "c"] "Ignoring none values in mixed block"
assert-equal "/path/to/file" ajoin [%/path/ %to/ %file] "Joining block of file values"

print "^/Probing /with refinement"
;; Inserts delimiter (formed) between elements, ignoring NONE.
assert-equal "a,b,c" ajoin/with ["a" "b" "c"] "," "Joining strings with string delimiter"
assert-equal "1-2-3" ajoin/with [1 2 3] "-" "Joining integers with string delimiter"
assert-equal "a,1,b,c" ajoin/with ["a" 1 none "b" none "c"] "," "Ignoring none with string delimiter"
assert-equal "a1b1c" ajoin/with ["a" "b" "c"] 1 "Joining with integer delimiter (formed as '1')"
assert-equal "atruebtruec" ajoin/with ["a" "b" "c"] true "Joining with logic delimiter (formed as 'true')"

print "^/Probing /all refinement"
;; Includes NONE as 'none' in the output.
assert-equal "anonebnonec" ajoin/all ["a" none "b" none "c"] "Including none values without delimiter"
assert-equal "1nonetrue" ajoin/all [1 none true] "Including none in mixed types without delimiter"

print "^/Probing /with/all refinements combined"
;; Inserts delimiter between all elements, including NONE as 'none'.
assert-equal "a,none,b,none,c" ajoin/with/all ["a" none "b" none "c"] "," "Including none with string delimiter"
assert-equal "1-none-true" ajoin/with/all [1 none true] "-" "Including none in mixed types with delimiter"

print "^/Probing edge cases"
;; Handles special cases predictably.
assert-equal "" ajoin [] "Empty block"
assert-equal "" ajoin [none none] "Block with only none values (ignored by default)"
assert-equal "nonenone" ajoin/all [none none] "Block with only none values using /all"
assert-equal "a" ajoin ["a"] "Single-element block"
assert-equal "a" ajoin/with ["a"] "," "Single-element block with delimiter (delimiter not applied)"
assert-equal "ab cd" ajoin ["a" ["b" "c"] "d"] "Nested block (formed with spaces)"
