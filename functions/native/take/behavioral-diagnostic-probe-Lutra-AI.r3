REBOL []
print "=== DIAGNOSTIC PROBE SCRIPT FOR 'TAKE' FUNCTION ==="
print "=== Using Battle-Tested QA Harness ==="
print ""

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
        print "✅ ALL `take` EXAMPLES PASSED"
    ][
        print "❌ SOME `take` EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; SECTION 1: Probing basic TAKE behavior with different series types
;;=============================================================================
print "--- SECTION 1: Probing basic TAKE behavior ---"
print "HYPOTHESIS: TAKE removes and returns first element from series"
print ""

;; Test 1.1: TAKE from block
test-block: [1 2 3 4 5]
original-block: copy test-block
result: take test-block
assert-equal 1 result "TAKE from [1 2 3 4 5] should return 1"
assert-equal [2 3 4 5] test-block "Block after TAKE should be [2 3 4 5]"

;; Test 1.2: TAKE from string
test-string: "hello"
result: take test-string
assert-equal #"h" result "TAKE from 'hello' should return #'h'"
assert-equal "ello" test-string "String after TAKE should be 'ello'"

;; Test 1.3: TAKE from binary
test-binary: #{DEADBEEF}
result: take test-binary
assert-equal 222 result "TAKE from #{DEADBEEF} should return 222 (0xDE as integer)"
assert-equal #{ADBEEF} test-binary "Binary after TAKE should be #{ADBEEF}"

;;=============================================================================
;; SECTION 2: Probing /PART refinement behavior
;;=============================================================================
print "^/--- SECTION 2: Probing /PART refinement ---"
print "HYPOTHESIS: /PART takes specified number of elements"
print ""

;; Test 2.1: /PART with number
test-block: [a b c d e f]
result: take/part test-block 3
assert-equal [a b c] result "take/part [a b c d e f] 3 should return [a b c]"
assert-equal [d e f] test-block "Block after take/part 3 should be [d e f]"

;; Test 2.2: /PART with series position
test-block: [1 2 3 4 5]
result: take/part test-block at test-block 4
assert-equal [1 2 3] result "take/part with series position should take [1 2 3]"
assert-equal [4 5] test-block "Block after should be [4 5]"

;; Test 2.3: /PART with zero
test-block: [a b c]
original-block: copy test-block
result: take/part test-block 0
assert-equal [] result "take/part with 0 should return empty block"
assert-equal original-block test-block "Original block should be unchanged"

;;=============================================================================
;; SECTION 3: Probing /LAST refinement behavior
;;=============================================================================
print "^/--- SECTION 3: Probing /LAST refinement ---"
print "HYPOTHESIS: /LAST takes from tail end of series"
print ""

;; Test 3.1: /LAST with block
test-block: [a b c d e]
result: take/last test-block
assert-equal 'e result "take/last [a b c d e] should return e"
assert-equal [a b c d] test-block "Block after take/last should be [a b c d]"

;; Test 3.2: /LAST with string
test-string: "world"
result: take/last test-string
assert-equal #"d" result "take/last 'world' should return #'d'"
assert-equal "worl" test-string "String after take/last should be 'worl'"

;;=============================================================================
;; SECTION 4: Probing /ALL refinement behavior
;;=============================================================================
print "^/--- SECTION 4: Probing /ALL refinement ---"
print "HYPOTHESIS: /ALL copies all content and clears original"
print ""

;; Test 4.1: /ALL with block
test-block: [1 2 3 4]
result: take/all test-block
assert-equal [1 2 3 4] result "take/all should return copy of all elements"
assert-equal [] test-block "Original block should be empty after take/all"

;; Test 4.2: /ALL with string
test-string: "test"
result: take/all test-string
assert-equal "test" result "take/all string should return copy of string"
assert-equal "" test-string "Original string should be empty after take/all"

;;=============================================================================
;; SECTION 5: Probing /DEEP refinement behavior
;;=============================================================================
print "^/--- SECTION 5: Probing /DEEP refinement ---"
print "HYPOTHESIS: /DEEP makes deep copy of taken elements"
print ""

;; Test 5.1: /DEEP with nested blocks
test-block: [[a b] [c d] [e f]]
result: take/deep test-block
assert-equal [a b] result "take/deep should return first nested block"
assert-equal [[c d] [e f]] test-block "Remaining should be [[c d] [e f]]"

;;=============================================================================
;; SECTION 6: Probing refinement combinations
;;=============================================================================
print "^/--- SECTION 6: Probing refinement combinations ---"
print "HYPOTHESIS: Multiple refinements work together logically"
print ""

;; Test 6.1: /PART /LAST combination
test-block: [1 2 3 4 5 6]
result: take/part/last test-block 2
assert-equal [5 6] result "take/part/last should take last 2 elements"
assert-equal [1 2 3 4] test-block "Remaining should be [1 2 3 4]"

;; Test 6.2: /PART /DEEP combination
test-block: [[a] [b] [c] [d]]
result: take/part/deep test-block 2
assert-equal [[a] [b]] result "take/part/deep should take first 2 with deep copy"
assert-equal [[c] [d]] test-block "Remaining should be [[c] [d]]"

;;=============================================================================
;; SECTION 7: Probing edge cases and error conditions
;;=============================================================================
print "^/--- SECTION 7: Probing edge cases ---"
print "HYPOTHESIS: TAKE handles edge cases gracefully"
print ""

;; Test 7.1: Empty block
test-block: []
result: take test-block
assert-equal none result "take from empty block should return none"
assert-equal [] test-block "Empty block should remain empty"

;; Test 7.2: Empty string
test-string: ""
result: take test-string
assert-equal none result "take from empty string should return none"
assert-equal "" test-string "Empty string should remain empty"

;; Test 7.3: Single element
test-block: [only]
result: take test-block
assert-equal 'only result "take from single element should return that element"
assert-equal [] test-block "Single element block should become empty"

;;=============================================================================
;; SECTION 8: Probing series positioning behavior
;;=============================================================================
print "^/--- SECTION 8: Probing positioned series ---"
print "HYPOTHESIS: TAKE works from current position in series"
print ""

;; Test 8.1: Positioned series
original: [a b c d e]
positioned: skip original 2  ; position at 'c'
result: take positioned
assert-equal 'c result "take from positioned series should take current element"
assert-equal [a b d e] original "Original series should have element removed"

;;=============================================================================
;; SECTION 9: Probing return types
;;=============================================================================
print "^/--- SECTION 9: Probing return types ---"
print "HYPOTHESIS: TAKE returns appropriate types based on series content"
print ""

;; Test 9.1: Integer from block
test-block: [42 13 7]
result: take test-block
assert-equal 42 result "take should return actual integer value"
assert-equal integer! type? result "return type should be integer!"

;; Test 9.2: Character from string
test-string: "abc"
result: take test-string
assert-equal #"a" result "take from string should return character"
assert-equal char! type? result "return type should be char!"

;; Print final summary
print-test-summary
