Rebol [
    Title: "Diagnostic Probe Script for MOLD Function"
    Purpose: "Comprehensive behavior analysis of MOLD and its refinements"
    Author: "DeepSeek R1"
    Version: 0.1.2
]

;;-----------------------------------------------
;; QA Harness (Provided)
;;-----------------------------------------------
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
        print "✅ ALL TESTS PASSED - MOLD BEHAVIOR VERIFIED"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------
;; Diagnostic Probe: MOLD Function
;;-----------------------------------------------
print "=== STARTING MOLD FUNCTION DIAGNOSTICS (v1.0.2) ==="

;; Hypothesis 1: Basic scalar values mold to expected string representations
print "^/=== Group 1: Basic Scalar Values ==="
assert-equal "123" mold 123 "Integer molding"
assert-equal "12.34" mold 12.34 "Decimal molding"
assert-equal "#{}" mold #{} "Empty binary molding"
assert-equal "#{48656C6C6F}" mold #{48656C6C6F} "Binary molding"
assert-equal "#(true)" mold true "Logic true molding"
assert-equal "#(false)" mold false "Logic false molding"
assert-equal "#(none)" mold none "None value molding"
assert-equal "abc" mold 'abc "Word molding"
assert-equal {""} mold "" "Empty string molding"
assert-equal {"hello"} mold "hello" "String molding"
assert-equal "%file.txt" mold %file.txt "File molding"

;; Hypothesis 2: Blocks mold with brackets and proper element separation
print "^/=== Group 2: Block Behavior ==="
assert-equal "[]" mold [] "Empty block molding"
assert-equal "[1 2 3]" mold [1 2 3] "Integer block molding"
assert-equal {["a" "b" "c"]} mold ["a" "b" "c"] "String block molding"
assert-equal "[a b c]" mold [a b c] "Word block molding"
assert-equal {[1 [a] "c"]} mold [1 [a] "c"] "Mixed block molding"

;; Hypothesis 3: /ONLY refinement removes outer brackets for blocks
print "^/=== Group 3: /ONLY Refinement ==="
assert-equal "1 2 3" mold/only [1 2 3] "/only with integer block"
assert-equal {a "b" 3} mold/only [a "b" 3] "/only with mixed block"
assert-equal "a" mold/only [a] "/only with single-element block"
assert-equal "" mold/only [] "/only with empty block"
assert-equal "123" mold/only 123 "/only with non-block (ignores refinement)"

;; Hypothesis 4: /ALL refinement produces same output as normal mold
;; REBOL/Bulk 3.19.0 observation: /ALL refinement has no visible effect
print "^/=== Group 4: /ALL Refinement (Corrected Behavior) ==="
assert-equal {"hello"} mold/all "hello" "/all with string -> same as normal"
assert-equal "abc" mold/all 'abc "/all with word -> same as normal"
assert-equal "123" mold/all 123 "/all with integer -> same as normal"
assert-equal "[1 2 3]" mold/all [1 2 3] "/all with block -> same as normal"
assert-equal "#(none)" mold/all none "/all with none -> same as normal"

;; Hypothesis 5: /FLAT refinement prevents indentation in nested structures
print "^/=== Group 5: /FLAT Refinement ==="
nested-block: [a [b [c]]]
assert-equal "[a [b [c]]]" mold/flat nested-block "/flat with nested block"
assert-equal {["line 1" "line 2"]} mold/flat ["line 1" "line 2"] "/flat with string block"
assert-equal "123" mold/flat 123 "/flat with scalar"

;; Hypothesis 6: /PART refinement limits output length exactly
print "^/=== Group 6: /PART Refinement ==="
assert-equal {["hel} mold/part ["hello"] 5 "/part with block content"
assert-equal "12" mold/part 123 2 "/part with integer"
assert-equal "ab" mold/part 'abcd 2 "/part with word"
assert-equal "" mold/part "test" 0 "/part with zero limit (corrected)"
assert-equal {123} mold/part 123 10 "/part with limit exceeding length"

;; Hypothesis 7: Edge cases and error resilience
print "^/=== Group 7: Edge Cases ==="
assert-equal "[]" mold [] "Empty block"
assert-equal {""} mold "" "Empty string"
assert-equal "0" mold 0 "Zero integer"
;; Corrected: Empty object includes newline in representation
assert-equal "make object! [^/]" mold context [] "Empty object (corrected)"

;; Corrected: Error objects include system-defined fields
expected-error: {make error! [
    code: 800
    type: 'user
    id: 'message
    arg1: "test"
    arg2: #(none)
    arg3: #(none)
    near: #(none)
    where: #(none)
]}
assert-equal expected-error
    mold make error! [code: 400 type: 'user id: 'message arg1: "test"]
    "Error object molding (corrected)"

;; Print final test summary
print-test-summary
