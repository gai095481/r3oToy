Rebol [
    Title: "`compose` Function Diagnostic Probe Script"
    Purpose: "Robust testing of compose function behavior and refinements"
    Author: "Claude 4 Sonnet fixed by Qwen 3 Coder"
    Date: 24-Jul-2025
    Version: 0.1.0
    Target: "REBOL/Bulk 3.19.0 (Oldes Branch)"
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
print "^/=== COMPOSE FUNCTION DIAGNOSTIC PROBE ==="
print "Testing REBOL/Bulk 3.19.0 (Oldes Branch)^/"
;;=============================================================================
;; SECTION 1: Probing Basic Compose Behavior
;;=============================================================================
print "--- SECTION 1: Basic Compose Behavior ---^/"
;; HYPOTHESIS: compose should evaluate parentheses and return a new block
;; with the evaluated results inserted where the parens were
basic-test-block: [a (1 + 1) b]
basic-result: compose basic-test-block
assert-equal [a 2 b] basic-result "Basic paren evaluation"
;; HYPOTHESIS: Multiple parentheses should all be evaluated
multi-paren-block: [(1 + 2) hello (3 * 4)]
multi-result: compose multi-paren-block
assert-equal [3 hello 12] multi-result "Multiple paren evaluation"
;; HYPOTHESIS: Empty parentheses should evaluate to unset and be omitted
empty-paren-block: [before () after]
empty-result: compose empty-paren-block
assert-equal [before after] empty-result "Empty parentheses handling"
;; HYPOTHESIS: Non-parenthetical content should remain unchanged
no-paren-block: [word "string" 42 [nested block]]
no-paren-result: compose no-paren-block
assert-equal [word "string" 42 [nested block]] no-paren-result "Non-paren content preservation"
;;=============================================================================
;; SECTION 2: Probing Data Type Handling
;;=============================================================================
print "^/--- SECTION 2: Data Type Handling ---^/"
;; HYPOTHESIS: Compose should work with various data types in parentheses
string-test: [prefix (rejoin ["dynamic" " string"]) suffix]
string-result: compose string-test
assert-equal [prefix "dynamic string" suffix] string-result "String concatenation in parens"
;; HYPOTHESIS (CORRECTED BASED ON OBSERVATION): Blocks returned from parentheses are spliced by default
block-eval-test: [start ([1 2 3]) end]
block-eval-result: compose block-eval-test
assert-equal [start 1 2 3 end] block-eval-result "Block returned from parens is spliced"
;; HYPOTHESIS: Function calls in parentheses should be evaluated
func-call-test: [result (length? "test")]
func-call-result: compose func-call-test
assert-equal [result 4] func-call-result "Function call in parens"
;; HYPOTHESIS: Variable references in parentheses should be evaluated
test-variable: "variable-value"
var-ref-test: [value (test-variable)]
var-ref-result: compose var-ref-test
assert-equal [value "variable-value"] var-ref-result "Variable reference in parens"
;;=============================================================================
;; SECTION 3: Probing /deep Refinement
;;=============================================================================
print "^/--- SECTION 3: /deep Refinement Behavior ---^/"
;; HYPOTHESIS: Without /deep, nested blocks should not have their parens evaluated
nested-block: [outer [inner (1 + 1)] (2 + 2)]
shallow-result: compose nested-block
assert-equal [outer [inner (1 + 1)] 4] shallow-result "Shallow compose - nested parens ignored"
;; HYPOTHESIS: With /deep, nested blocks should have their parens evaluated
deep-result: compose/deep nested-block
assert-equal [outer [inner 2] 4] deep-result "Deep compose - nested parens evaluated"
;; HYPOTHESIS: Multiple levels of nesting should work with /deep
deeply-nested: [level1 [level2 [level3 (3 * 3)] (2 * 2)] (1 * 1)]
deeply-nested-result: compose/deep deeply-nested
assert-equal [level1 [level2 [level3 9] 4] 1] deeply-nested-result "Multiple nesting levels with /deep"
;; HYPOTHESIS: Empty nested blocks should be preserved
empty-nested: [outer [] (5)]
empty-nested-result: compose/deep empty-nested
assert-equal [outer [] 5] empty-nested-result "Empty nested blocks preservation"
;;=============================================================================
;; SECTION 4: Probing /only Refinement
;;=============================================================================
print "^/--- SECTION 4: /only Refinement Behavior ---^/"
;; HYPOTHESIS: Without /only, blocks returned from parens are spliced
block-splice-test: [before ([1 2 3]) after]
normal-splice: compose block-splice-test
assert-equal [before 1 2 3 after] normal-splice "Normal block splicing"
;; HYPOTHESIS: With /only, blocks returned from parens are inserted as single values
only-test: [before ([1 2 3]) after]
only-result: compose/only only-test
assert-equal [before [1 2 3] after] only-result "Block insertion with /only"
;; HYPOTHESIS: /only should work with multiple blocks
multi-block-only: [start ([a b]) middle ([c d]) end]
multi-only-result: compose/only multi-block-only
assert-equal [start [a b] middle [c d] end] multi-only-result "Multiple blocks with /only"
;; HYPOTHESIS: /only with non-block values should behave normally
non-block-only: [value (42)]
non-block-only-result: compose/only non-block-only
assert-equal [value 42] non-block-only-result "Non-block values with /only"
;;=============================================================================
;; SECTION 5: Probing /into Refinement
;;=============================================================================
print "^/--- SECTION 5: /into Refinement Behavior ---^/"
;; HYPOTHESIS (CORRECTED BASED ON OBSERVATION): /into should PREPEND results to an existing block
target-block: [existing content]
into-source: [new (10 + 5) content]
into-result: compose/into into-source target-block
;; The into-result should be the same reference as target-block
;; compose/into PREPENDS the result to the target block
assert-equal [new 15 content existing content] target-block "/into prepends to target block"
;; HYPOTHESIS: /into with empty target should work
empty-target: []
empty-into-source: [first (1 + 1) second]
empty-into-result: compose/into empty-into-source empty-target
assert-equal [first 2 second] empty-target "/into with empty target"
;; HYPOTHESIS: /into should work with valid series targets (like block! or paren!)
;; Using a block! as target for paren! source is not standard. Let's test with a valid block target.
valid-target-block: []
paren-source-for-into: [(7 * 2)]
paren-into-result: compose/into paren-source-for-into valid-target-block
assert-equal [14] valid-target-block "/into with paren source into block target"
;;=============================================================================
;; SECTION 6: Probing Combined Refinements
;;=============================================================================
print "^/--- SECTION 6: Combined Refinements ---^/"
;; HYPOTHESIS: /deep and /only should work together
deep-only-test: [outer [inner ([a b])] ([c d])]
deep-only-result: compose/deep/only deep-only-test
assert-equal [outer [inner [a b]] [c d]] deep-only-result "/deep and /only combined"
;; HYPOTHESIS: /deep and /into should work together (prepends)
deep-into-target: [pre-existing]
deep-into-source: [top [nested (4 + 4)] (2 + 2)]
deep-into-result: compose/deep/into deep-into-source deep-into-target
assert-equal [top [nested 8] 4 pre-existing] deep-into-target "/deep and /into combined (prepends)"
;; HYPOTHESIS: All three refinements should work together (prepends)
all-refine-target: [start]
all-refine-source: [middle [deep ([x y])] ([z w])]
all-refine-result: compose/deep/only/into all-refine-source all-refine-target
assert-equal [middle [deep [x y]] [z w] start] all-refine-target "All refinements combined (prepends)"
;;=============================================================================
;; SECTION 7: Probing Edge Cases and Error Conditions
;;=============================================================================
print "^/--- SECTION 7: Edge Cases and Error Conditions ---^/"
;; HYPOTHESIS: Empty block should return empty block
empty-block-test: []
empty-block-result: compose empty-block-test
assert-equal [] empty-block-result "Empty block composition"
;; HYPOTHESIS: Block with only literals should be unchanged
literals-only: [word 42 "string"]
literals-result: compose literals-only
assert-equal [word 42 "string"] literals-result "Literals-only block"
;; HYPOTHESIS: Nested parentheses should be handled correctly
nested-parens-test: [result ((1 + 2) * 3)]
nested-parens-result: compose nested-parens-test
assert-equal [result 9] nested-parens-result "Nested parentheses evaluation"
;; HYPOTHESIS (CORRECTED BASED ON OBSERVATION): Parentheses returning none should be INCLUDED as a none! value, not omitted or the word 'none
none-paren-test: [before (if false [1]) after]
none-paren-result: compose none-paren-test
assert-equal [before #(none) after] none-paren-result "None-returning parentheses included as none! value"
;; HYPOTHESIS: Parentheses returning unset should be omitted
unset-paren-test: [before (print "") after]
unset-paren-result: compose unset-paren-test
assert-equal [before after] unset-paren-result "Unset-returning parentheses omitted"
;;=============================================================================
;; SECTION 8: Probing Non-Block Input Types
;;=============================================================================
print "^/--- SECTION 8: Non-Block Input Types ---^/"
;; HYPOTHESIS: String input should be treated as a single value
string-input: "not a block"
string-input-result: compose string-input
assert-equal "not a block" string-input-result "String input unchanged"
;; HYPOTHESIS: Integer input should be treated as a single value
integer-input: 42
integer-input-result: compose integer-input
assert-equal 42 integer-input-result "Integer input unchanged"
;; HYPOTHESIS: Paren input should be evaluated
paren-input: (5 + 3)
paren-input-result: compose paren-input
assert-equal 8 paren-input-result "Paren input evaluated"
;; HYPOTHESIS: None input should return none
none-input: none
none-input-result: compose none-input
assert-equal none none-input-result "None input unchanged"
;;=============================================================================
;; SECTION 9: Probing Complex Expressions in Parentheses
;;=============================================================================
print "^/--- SECTION 9: Complex Expressions ---^/"
;; HYPOTHESIS: Complex mathematical expressions should evaluate correctly
math-complex: [result (((2 + 3) * 4) - 1)]
math-result: compose math-complex
assert-equal [result 19] math-result "Complex math expression"
;; HYPOTHESIS: Conditional expressions should work in parentheses
conditional-test: [value (either true [100] [200])]
conditional-result: compose conditional-test
assert-equal [value 100] conditional-result "Conditional expression in parens"
;; HYPOTHESIS: Function definitions and calls should work
temp-func: function [x] [x * 2]
func-def-test: [doubled (temp-func 5)]
func-def-result: compose func-def-test
assert-equal [doubled 10] func-def-result "Function call in parens"
;; HYPOTHESIS: Series operations should work in parentheses
test-series: [a b c d]
series-op-test: [first-item (first test-series) last-item (last test-series)]
series-op-result: compose series-op-test
assert-equal [first-item a last-item d] series-op-result "Series operations in parens"
;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
