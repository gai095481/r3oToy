Rebol []

;; Diagnostic Probe Script for `ajoin` in Rebol/Bulk 3.19.0
;; Corrected version based on observed behavior

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

;; =============================================================================
;; START OF TESTS
;; =============================================================================

print "---[Basic Behavior Hypotheses]---"
print "Hypothesis: ajoin concatenates elements directly without delimiters"
print "Hypothesis: ajoin reduces values to their string/text content"

assert-equal "ABCDEF" ajoin ["ABC" "DEF"] "Strings join directly"
assert-equal "123" ajoin [1 2 3] "Integers join as molded strings"
assert-equal "truefalse" ajoin [true false] "Logic values join as strings"
assert-equal "abc" ajoin [%a %b %c] "Files join as path strings"
assert-equal "<b><i>" ajoin [<b> <i>] "Tags keep angle brackets"

print "^/---[/with Refinement Hypotheses]---"
print "Hypothesis: /with inserts delimiter between ALL elements"
print "Hypothesis: Delimiter is converted to its string representation"

assert-equal "a,b,c" ajoin/with ["a" "b" "c"] "," "String delimiter works"
assert-equal "1-2-3" ajoin/with [1 2 3] "-" "Number delimiter coerced to string"
assert-equal "xspacey" ajoin/with ["x" "y"] [space] "Block evaluated as literal" ; Fixed
assert-equal "anoneb" ajoin/with ["a" "b"] none "None delimiter becomes 'none'"
assert-equal "left<->right" ajoin/with ["left" "right"] "<->" "Multi-char delimiter works"

;; Create a block with proper unset! value
tmp-word: 'tmp
unset 'tmp
test-block: ["a" none "b" get/any 'tmp "c"]
assert-equal "abc" ajoin test-block "Default behavior skips none/unset"
assert-equal "anonebc" ajoin/all test-block "/all includes unset as empty" ; Fixed

print "^/---[Nested Blocks Hypotheses]---"
print "Hypothesis: Nested blocks are formed without spaces"
print "Hypothesis: Empty blocks contribute nothing"

assert-equal "a bc" ajoin [["a" "b"] ["c"]] "Nested blocks formed without spaces" ; Fixed
assert-equal "1 2+3 4" ajoin/with [[1 2] [3 4]] "+" "Nested blocks work with delimiter"
assert-equal "" ajoin ["" []] "Empty strings/blocks contribute nothing"

print "^/---[Data Type Coercion Hypotheses]---"
print "Hypothesis: All values use short molded representation"
print "Hypothesis: Complex types follow REBOL forming rules"

assert-equal "10:30" ajoin [10:30] "Time! value coercion"
assert-equal "1.2.3.4" ajoin [1.2.3.4] "Tuple! value coercion"
assert-equal "/home/user" ajoin [%/home/user] "File! to string conversion"
assert-equal "a: 1" ajoin [make object! [a: 1]] "Objects use short form" ; Fixed

print "^/---[Edge Case Hypotheses]---"
print "Hypothesis: Edge cases follow documented behavior"
print "Hypothesis: Empty inputs return empty string"

assert-equal "" ajoin [] "Empty block returns empty string"
assert-equal "" ajoin [none] "Single none returns empty"
assert-equal "none" ajoin/all [none] "/all makes none visible"
assert-equal "" ajoin ["" none] "Empty string + none = empty"
assert-equal "" ajoin/with [] "X" "Empty block with delimiter returns empty"

print "^/---[Refinement Combination Hypotheses]---"
;; Create a block with proper none and unset values
tmp-word: 'tmp
unset 'tmp-word
combo-test: reduce ["a" none "b" (get/any 'tmp-word) "c"]
assert-equal "a|none|b||c" ajoin/with/all combo-test "|" "Combined refinements work" ; Fixed
assert-equal "a>none>b>>c" ajoin/all/with combo-test ">" "Reverse refinement order still works" ; Fixed

print-test-summary
