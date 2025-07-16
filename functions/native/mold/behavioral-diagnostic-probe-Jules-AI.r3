Rebol [
    Title: "MOLD Function Diagnostic Probe Script - Corrected"
    Author: "Jules, AI Assistant"
    Date: 15-Jul-2025
    Purpose: "Comprehensive testing of the MOLD function behavior in Rebol 3 Oldes"
    Note: "This script systematically tests the MOLD function with various data types and refinements, corrected according to REPL output."
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
    print ["=== TEST SUMMARY ==="]
    print "============================================"
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - MOLD IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/============================================"
print "=== COMPREHENSIVE MOLD FUNCTION PROBE ==="
print "============================================^/"

;;-----------------------------------------------------------------------------
;; SECTION 1: Probing Basic Data Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 1: Probing Basic Data Types ---^/"

;; HYPOTHESIS: `mold` on basic scalar types will produce their loadable string representation.
assert-equal "1024" mold 1024 "mold on integer!"
assert-equal "10.24" mold 10.24 "mold on decimal!"
assert-equal "#(true)" mold true "mold on logic! true"
assert-equal "#(false)" mold false "mold on logic! false"
assert-equal "#(none)" mold none "mold on none!"
assert-equal {#"A"} mold #"A" "mold on char!"
assert-equal {"Hello World"} mold "Hello World" "mold on string! adds quotes"
assert-equal "[a b c]" mold [a b c] "mold on block! adds brackets"

;;-----------------------------------------------------------------------------
;; SECTION 2: Probing Word and Path Types
;;-----------------------------------------------------------------------------
print "^/--- SECTION 2: Probing Word and Path Types ---^/"

;; HYPOTHESIS: `mold` on word and path types will produce their literal, loadable representation.
assert-equal "some-word" mold 'some-word "mold on word!"
assert-equal "'literal-word" mold to-lit-word 'literal-word "mold on lit-word!"
assert-equal "setting-word:" mold to-set-word 'setting-word "mold on set-word!"
assert-equal ":getting-word" mold to-get-word 'getting-word "mold on get-word!"
assert-equal "/refinement-word" mold to-refinement 'refinement-word "mold on refinement!"
assert-equal "obj/field/value" mold 'obj/field/value "mold on path!"
assert-equal "%path/to/file.txt" mold %path/to/file.txt "mold on file!"

;;-----------------------------------------------------------------------------
;; SECTION 3: Probing Special Datatypes
;;-----------------------------------------------------------------------------
print "^/--- SECTION 3: Probing Special Datatypes ---^/"

;; HYPOTHESIS: `mold` on special datatypes produces their literal, loadable representation.
assert-equal "15-Jul-2025/10:30:45" mold 15-Jul-2025/10:30:45 "mold on date!"
assert-equal "1.2.3.4" mold 1.2.3.4 "mold on tuple!"
assert-equal "$12.34" mold $12.34 "mold on money!"
assert-equal "user@example.com" mold user@example.com "mold on email!"
assert-equal "http://www.rebol.com" mold http://www.rebol.com "mold on url!"
assert-equal "<tag>" mold <tag> "mold on tag!"
assert-equal "#issue" mold #issue "mold on issue!"
assert-equal "#{DECAFBAD}" mold #{DECAFBAD} "mold on binary!"

;;-----------------------------------------------------------------------------
;; SECTION 4: Probing Refinements
;;-----------------------------------------------------------------------------
print "^/--- SECTION 4: Probing Refinements ---^/"

;; HYPOTHESIS: /only will mold the contents of a block without the outer brackets.
test-block-only: [a b [c d]]
assert-equal {a b [c d]} mold/only test-block-only "mold/only on a block"

;; HYPOTHESIS: /all will produce construction syntax for certain types.
test-obj-all: make object! [name: "Test"]
expected-obj-all: {#(object! [^/    name: "Test"^/])}
assert-equal expected-obj-all mold/all test-obj-all "mold/all on an object"

;; HYPOTHESIS: /flat will prevent indentation for complex types.
test-obj-flat: make object! [name: "Test" value: 10]
expected-obj-flat: {object! [name: "Test" value: 10]}
assert-equal join "#(" [expected-obj-flat ")"] mold/all/flat test-obj-flat "mold/all/flat on an object"

;; HYPOTHESIS: /part will limit the length of the molded output string.
test-series-part: [1 2 3 4 5 6 7 8 9 10]
assert-equal "[1 2 3 4 5" mold/part test-series-part 10 "mold/part on a block"
assert-equal {^"abcdefghi} mold/part "abcdefghijklmnopqrstuvwxyz" 10 "mold/part on a string"

;;-----------------------------------------------------------------------------
;; SECTION 5: Probing Edge Cases
;;-----------------------------------------------------------------------------
print "^/--- SECTION 5: Probing Edge Cases ---^/"

;; HYPOTHESIS: `mold` will handle empty values, unset, and complex structures correctly.
assert-equal {[]} mold [] "mold on an empty block"
assert-equal "#(unset!)" mold unset! "mold on an unset value"
add-one: function [arg] [arg + 1]
assert-equal {make function! [[arg^//local][arg + 1]]} mold :add-one "mold on a function"

;; HYPOTHESIS: `mold` will correctly escape characters in strings by using braces.
test-string-escape: rejoin ["a" #"^"" "b"]
expected-string-escape: {{a"b}}
assert-equal expected-string-escape mold test-string-escape "mold on string with quotes"

;; HYPOTHESIS: `mold` on a series not at its head will mold from the current position.
series-at-pos: next [a b c]
assert-equal "[b c]" mold series-at-pos "mold on a series at a specific position"

print "^/=== ALL MOLD FUNCTION PROBES COMPLETED ===^/"

print-test-summary
