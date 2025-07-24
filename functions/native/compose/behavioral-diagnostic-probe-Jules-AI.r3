Rebol [
    Title: "Diagnostic Probe for COMPOSE Function"
    Author: "Jules, AI Engineer"
    Date: 24-Jul-2025
    Purpose: {
        A comprehensive, runnable script to meticulously probe the behavior
        of the Rebol 3 Oldes branch `compose` native, including all its
        refinements and edge cases. This script serves as an evidence-gathering
        tool to create a "truth log" from the REPL.
    }
]

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
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
;;-----------------------------------------------------------------------------

;;;============================================================================
;;; SECTION 1: PROBING BASIC BEHAVIOR
;;;============================================================================
print "^/--- SECTION 1: PROBING BASIC BEHAVIOR ---"
; Hypothesis: `compose` evaluates code inside parens `()` and returns a
; block containing the results. Non-paren elements are included as-is.

basic-value: 10
assert-equal [1 2 3] compose [(1) (1 + 1) (1 + 2)] "Simple arithmetic expressions"
assert-equal [10 "hello" #c] compose [(basic-value) ("hello") (#c)] "Evaluation of different data types"
assert-equal [a 2 c] compose [a (1 + 1) c] "Mixing literals and evaluated expressions"
assert-equal [10 20 30] compose [(basic-value) (basic-value * 2) (basic-value * 3)] "Using a variable in expressions"
assert-equal [#(true) #(false)] compose [(1 = 1) (1 = 2)] "Evaluation of logic expressions"


;;;============================================================================
;;; SECTION 2: PROBING THE /DEEP REFINEMENT
;;;============================================================================
print "^/--- SECTION 2: PROBING THE /DEEP REFINEMENT ---"
; Hypothesis: `compose/deep` will recursively evaluate parens inside nested
; blocks. Standard `compose` will only evaluate at the top level.

nested-block: [a [b (1 + 2)] c]
assert-equal [a [b (1 + 2)] c] compose nested-block "Standard compose does not recurse into nested blocks"

deep-nested-block: [a [b (1 + 2) [d (3 + 4)]] c]
assert-equal [a [b 3 [d 7]] c] compose/deep deep-nested-block "/deep recursively evaluates all nested parens"

very-deep-block: [1 [2 [3 [4 (5 + 5)]]]]
assert-equal [1 [2 [3 [4 10]]]] compose/deep very-deep-block "/deep handles multiple levels of nesting"


;;;============================================================================
;;; SECTION 3: PROBING THE /ONLY REFINEMENT
;;;============================================================================
print "^/--- SECTION 3: PROBING THE /ONLY REFINEMENT ---"
; Hypothesis: `compose/only` will cause expressions that evaluate to a block
; to be inserted as a single block value, rather than splicing their contents.

block-to-insert: [x y z]
assert-equal [a x y z b] compose [a (block-to-insert) b] "Default compose splices block contents"
assert-equal [a [x y z] b] compose/only [a (block-to-insert) b] "/only inserts the block as a single item"

; Test /only with /deep
deep-block-to-insert: [1 [2 (block-to-insert)] 3]
assert-equal [1 [2 x y z] 3] compose/deep [1 [2 (block-to-insert)] 3] "/deep without /only still splices nested blocks"
assert-equal [1 [2 [x y z]] 3] compose/deep/only [1 [2 (block-to-insert)] 3] "/deep with /only inserts nested blocks as single items"


;;;============================================================================
;;; SECTION 4: PROBING THE /INTO REFINEMENT (CORRECTED)
;;;============================================================================
print "^/--- SECTION 4: PROBING THE /INTO REFINEMENT (CORRECTED) ---"
; Hypothesis: `compose/into` will PREPEND the results of the composition
; into a specified target block, modifying it in place. The function returns
; the state of the target block BEFORE the modification.

target-block-one: [a b]
original-state-one: copy target-block-one
return-val-one: compose/into [c (1 + 2) d] target-block-one
assert-equal [c 3 d a b] target-block-one "/into PREPENDS composed elements to the target block"
assert-equal original-state-one return-val-one "/into returns the ORIGINAL state of the target block"


target-block-two: [x]
original-state-two: copy target-block-two
return-val-two: compose/deep/into [y [z (99 + 1)]] target-block-two
assert-equal [y [z 100] x] target-block-two "/into with /deep also PREPENDS elements"
assert-equal original-state-two return-val-two "/into with /deep also returns the ORIGINAL state"


;;;============================================================================
;;; SECTION 5: PROBING EDGE CASES & UNEXPECTED INPUT
;;;============================================================================
print "^/--- SECTION 5: PROBING EDGE CASES & UNEXPECTED INPUT ---"
; Hypothesis 1: Composing an empty block results in an empty block.
assert-equal [] compose [] "Composing an empty block"

; Hypothesis 2: Composing a block with no parens returns an identical block.
no-parens-block: [a b "hello" 100]
assert-equal no-parens-block compose no-parens-block "Composing a block with no parens"

; Hypothesis 3: `compose` is defined for `any-type!`. We must probe its
; behavior with non-block inputs. The expected behavior is unclear. It might
; error, or it might return the input unchanged. Let's assume it returns
; the input as-is if no composition is possible.
assert-equal "a string" compose "a string" "Probing compose with a string"
assert-equal 12345 compose 12345 "Probing compose with an integer"
assert-equal #z compose #z "Probing compose with a char"
assert-equal none compose none "Probing compose with none"

; Hypothesis 4: A paren can be the only element in the block.
assert-equal [100] compose [(10 * 10)] "A single paren in a block"

; Hypothesis 5: A paren can evaluate to `none` and `none` can be composed.
assert-equal [a #(none) b] compose [a (if false [c]) b] "A paren evaluating to none is inserted"

; Hypothesis 6: Test composing just `none`
assert-equal [#(none)] compose [(none)] "Composing a block containing just `none`"

;;;============================================================================
;;; SCRIPT EXECUTION SUMMARY
;;;============================================================================
print-test-summary
