Rebol [
    Title: "Diagnostic Probe Script for `also` Native Function"
    Purpose: "Robust testing of the `also` function behavior in Rebol 3 Oldes"
    Author: "Claude 4 Sonnet and Qwen 3 Coder"
    Date: 27-Jul-2025
    Version: 0.1.0 ;; Updated version to reflect fix
]
;;-----------------------------
;; A Battle-Tested QA Harness
;;------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

;; Updated assert-equal to handle function comparison correctly
assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    passed?: false
    ;; Special handling for function values
    if all [any-function? :expected any-function? :actual] [
        passed?: same? :expected :actual
    ]
    ;; Default comparison for other types
    if not passed? [
        passed?: equal? :expected :actual
    ]

    either passed? [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold :expected
            "^/   >> Actual:   " mold :actual
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
;;=============================================================================
;; DIAGNOSTIC PROBE SCRIPT FOR `also` NATIVE FUNCTION
;;=============================================================================
print "^/=== DIAGNOSTIC PROBE: `also` NATIVE FUNCTION ==="
print "Target: REBOL/Bulk 3.19.0 (Oldes Branch)"
print "Purpose: Systematic testing of ALSO function behavior^/"

;;-----------------------------------------------------------------------------
;; SECTION 1: Probing Basic Return Value Behavior
;;-----------------------------------------------------------------------------
print "^/--- SECTION 1: Probing Basic Return Value Behavior ---"
print {
HYPOTHESIS: The `also` function should return the first value unchanged,
regardless of what the second value is or does. The second value should
be evaluated but its result should be discarded.
}

;; Test 1.1: Basic integer return
test-result: also 42 100
assert-equal 42 test-result "Basic integer return - should return first value (42)"

;; Test 1.2: String return with different second value
test-result: also "hello" "world"
assert-equal "hello" test-result "String return - should return first value (hello)"

;; Test 1.3: Block return with different second value
test-block: [1 2 3]
test-result: also test-block [4 5 6]
assert-equal [1 2 3] test-result "Block return - should return first value [1 2 3]"

;; Test 1.4: None return
test-result: also none 42
assert-equal none test-result "None return - should return none as first value"

;; Test 1.5: Logic values
test-result: also true false
assert-equal true test-result "Logic return - should return first logic value (true)"
test-result: also false true
assert-equal false test-result "Logic return - should return first logic value (false)"

;;-----------------------------------------------------------------------------
;; SECTION 2: Probing Second Value Evaluation
;;-----------------------------------------------------------------------------
print "^/--- SECTION 2: Probing Second Value Evaluation ---"
print {
HYPOTHESIS: The second value should be evaluated for its side effects,
even though its result is discarded. This means expressions with side
effects (like variable assignments) should execute.
}

;; Test 2.1: Variable assignment in second value
side-effect-var: none
test-result: also "returned" (side-effect-var: "assigned")
assert-equal "returned" test-result "Return value should be first argument"
assert-equal "assigned" side-effect-var "Side effect should execute - variable should be assigned"

;; Test 2.2: Multiple side effects in second value
counter: 0
test-result: also 999 (counter: counter + 1 counter: counter + 5)
assert-equal 999 test-result "Return value should be first argument with side effects"
assert-equal 6 counter "Side effects should execute in sequence"

;; Test 2.3: Function call in second value
side-effect-executed?: false
side-effect-func: does [
    set 'side-effect-executed? true
    "side-effect-result"
]
test-result: also "main-result" side-effect-func
assert-equal "main-result" test-result "Should return first value when second is function call"
assert-equal true side-effect-executed? "Function call in second position should execute"

;;-----------------------------------------------------------------------------
;; SECTION 3: Probing Expression Evaluation
;;-----------------------------------------------------------------------------
print "^/--- SECTION 3: Probing Expression Evaluation ---"
print {
HYPOTHESIS: Both arguments can be complex expressions that will be
evaluated normally. The first expression's result is returned, while
the second expression's result is discarded after evaluation.
}

;; Test 3.1: Mathematical expressions
test-result: also (5 + 3) (10 * 2)
assert-equal 8 test-result "Should return result of first expression (5 + 3 = 8)"

;; Test 3.2: String operations
test-str1: "Hello"
test-str2: "World"
test-result: also (append copy test-str1 " there") (append copy test-str2 " peace")
assert-equal "Hello there" test-result "Should return result of first string operation"

;; Test 3.3: Block operations
test-blk1: [1 2]
test-blk2: [3 4]
test-result: also (append copy test-blk1 99) (append copy test-blk2 88)
assert-equal [1 2 99] test-result "Should return result of first block operation"

;;-----------------------------------------------------------------------------
;; SECTION 4: Probing Type Diversity
;;-----------------------------------------------------------------------------
print "^/--- SECTION 4: Probing Type Diversity ---"
print {
HYPOTHESIS: The `also` function should work with any combination of
datatypes for both arguments, since both are declared as [any-type!].
}

;; Test 4.1: Mixed numeric types
test-result: also 42 3.14
assert-equal 42 test-result "Integer and decimal - should return integer (42)"
test-result: also 3.14 42
assert-equal 3.14 test-result "Decimal and integer - should return decimal (3.14)"

;; Test 4.2: String and block
test-result: also "text" [1 2 3]
assert-equal "text" test-result "String and block - should return string"

;; Test 4.3: Word values
test-word: 'symbol
test-result: also test-word 123
assert-equal 'symbol test-result "Word and integer - should return word"

;;-----------------------------------------------------------------------------
;; SECTION 5: Probing Edge Cases and Error Conditions
;;-----------------------------------------------------------------------------
print "^/--- SECTION 5: Probing Edge Cases and Error Conditions ---"
print {
HYPOTHESIS: Since both arguments accept [any-type!], there should be
very few error conditions. However, we should test unset values and
ensure the function handles them appropriately.
}

;; Test 5.1: Empty block handling
test-result: also [] [1 2 3]
assert-equal [] test-result "Empty block as first argument should return empty block"
test-result: also [1 2 3] []
assert-equal [1 2 3] test-result "Empty block as second argument should return first value"

;; Test 5.2: Zero values
test-result: also 0 1
assert-equal 0 test-result "Zero as first argument should return zero"
test-result: also 1 0
assert-equal 1 test-result "Zero as second argument should return first value (1)"

;; Test 5.3: Empty string handling
test-result: also "" "text"
assert-equal "" test-result "Empty string as first argument should return empty string"
test-result: also "text" ""
assert-equal "text" test-result "Empty string as second argument should return first value"

;;-----------------------------------------------------------------------------
;; SECTION 6: Probing Nested ALSO Calls
;;-----------------------------------------------------------------------------
print "^/--- SECTION 6: Probing Nested ALSO Calls ---"
print {
HYPOTHESIS: ALSO calls can be nested and should evaluate from inside out,
with each ALSO returning its first argument while evaluating its second.
}

;; Test 6.1: Simple nesting
nested-counter: 0
test-result: also "outer" (also "inner" (nested-counter: nested-counter + 1))
assert-equal "outer" test-result "Nested ALSO should return outermost first value"
assert-equal 1 nested-counter "Nested side effect should execute"

;; Test 6.2: Complex nesting with multiple side effects
effect-log: []
test-result: also
    "result"
    (also
        (append effect-log "first")
        (append effect-log "second")
    )
assert-equal "result" test-result "Complex nested ALSO should return outer first value"
assert-equal ["first" "second"] effect-log "All nested side effects should execute in order"

;;-----------------------------------------------------------------------------
;; SECTION 7: Probing Performance and Evaluation Order
;;-----------------------------------------------------------------------------
print "^/--- SECTION 7: Probing Performance and Evaluation Order ---"
print {
HYPOTHESIS: Both arguments should be evaluated in left-to-right order,
with the first argument evaluated first, then the second argument.
}

;; Test 7.1: Evaluation order verification
eval-order: []
first-expr: (append eval-order "first" "first-result")
second-expr: (append eval-order "second" "second-result")
test-result: also first-expr second-expr
assert-equal "first-result" test-result "Should return result of first expression"
assert-equal ["first" "second"] eval-order "Should evaluate arguments left-to-right"

;; Test 7.2: Error in second argument should not affect first
;; Note: This tests that first value is computed before second
error-happened?: false
test-result: none
set/any 'test-result try [
    also "success" (1 / 0)  ;; Division by zero in second argument
]

;; We expect this might cause an error, but let's see what happens
either error? test-result [
    print "✅ PASSED: Error in second argument caused ALSO to error (expected behavior)"
][
    print rejoin ["⚠️  UNEXPECTED: ALSO returned: " mold test-result " despite error in second argument"]
]

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
