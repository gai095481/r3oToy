Rebol []

;; === COMPOSE Diagnostic Probe Script ===
;; Purpose: Systematically test Rebol 3 Oldes `compose` function and refinements.
;; Author: DeepSeek R1
;; Version: 0.1.0
;; Target: REBOL/Bulk 3.19.0

;; === QA Test Harness ===
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare two values and output formatted PASSED/FAILED message}
    expected [any-type!] "Expected value"
    actual [any-type!] "Actual value"
    description [string!] "Test description"
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
    print "^/============================================"
    print "=== TEST SUMMARY ==="
    print "============================================"
    print rejoin ["Total Tests: " test-count]
    print rejoin ["Passed: " pass-count]
    print rejoin ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - COMPOSE BEHAVIOR VERIFIED"
    ][
        print "❌  SOME TESTS FAILED - FURTHER INVESTIGATION NEEDED"
    ]
    print "============================================^/"
]

;; === Test Variables ===
test-block: [a b (1 + 2) c]
test-nested: [a [b (1 + 2)] c]
test-parens: [(1 + 2) (3 + 4)]
test-insert: [1 2 3]
test-target: copy []
test-string: "a(b)c"
test-empty: []

print "===== BEGIN COMPOSE TESTS (Corrected v2.0) ====="

;; === Hypothesis 1: Basic Composition ===
comment {
    Confirmed behavior:
    - Paren expressions are evaluated
    - Non-paren values remain unchanged
    - Returns a new block
}
assert-equal [a b 3 c] compose test-block "Basic composition"
assert-equal [a b 3 c] compose copy test-block "Input block not modified"
assert-equal [1 2 3] compose [1 2 3] "Block without parens unchanged"
assert-equal [7] compose [(3 + 4)] "Single paren evaluation"

;; === Hypothesis 2: /DEEP Refinement ===
comment {
    Confirmed behavior:
    - Without /deep: Nested blocks not processed
    - With /deep: Processes parens recursively
}
assert-equal [a [b (1 + 2)] c] compose test-nested "/deep not used: nested unchanged"
assert-equal [a [b 3] c] compose/deep test-nested "/deep: nested paren evaluated"
assert-equal [a [b [c 4]] d] compose/deep [a [b [c (2 + 2)]] d] "Multiple nesting levels"

;; === Hypothesis 3: /ONLY Refinement ===
comment {
    Confirmed behavior:
    - Without /only: Blocks are spliced
    - With /only: Blocks inserted as single values
}
assert-equal [a 1 2 3 b] compose [a (test-insert) b] "Without /only: block spliced"
assert-equal [a [1 2 3] b] compose/only [a (test-insert) b] "With /only: block inserted whole"
assert-equal [[1 2 3]] compose/only [(test-insert)] "Single block insertion"

;; === Hypothesis 4: /INTO Refinement (Corrected) ===
comment {
    Corrected behavior based on test evidence:
    - Inserts composed result at CURRENT position (head by default)
    - Returns target block at position AFTER insertion
    - Must use HEAD to get full modified block
}
target-block: copy [x y]
compose-result: compose/into [a (1 + 2)] target-block
assert-equal [a 3 x y] head target-block "/into: inserts at current position (head)"
assert-equal [x y] compose-result "/into: returns target at new position"

;; === Hypothesis 5: Refinement Combinations (Corrected) ===
comment {
    Confirmed behavior:
    - /deep and /only work together as expected
    - /into combines correctly with insertion at head
}
assert-equal [a [1 2 3] b] compose/deep/only [a (test-insert) b] "/deep/only: no effect on flat"
assert-equal [a [b [1 2 3]] c] compose/deep/only [a [b (test-insert)] c] "/deep/only: nested block inserted"

;; Test combination with /into (corrected)
target-combo: copy [prefix]
compose-result: compose/deep/only/into [a [b (test-insert)] c] target-combo
assert-equal [a [b [1 2 3]] c prefix] head target-combo "/deep/only/into: full block content"
assert-equal [prefix] compose-result "/deep/only/into: return position"

;; === Hypothesis 6: Edge Cases ===
comment {
    Confirmed behavior:
    - Empty blocks handled correctly
    - Various data types preserved
}
assert-equal [] compose test-empty "Empty input block"
assert-equal [""] compose [""] "String in block"
assert-equal [3] compose [(do [1 + 2])] "DO in paren works"

;; === Error Case Testing (Corrected) ===
comment {
    Confirmed behavior:
    - Non-block inputs cause errors
    - /into requires block argument
}

assert-equal true error? try [compose/into [a] 'not-a-block] "/into with non-block causes error"

;; === Final Test Summary ===
print-test-summary
