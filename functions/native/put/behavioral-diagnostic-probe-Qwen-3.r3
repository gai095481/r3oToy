Rebol [
    Title: "Diagnostic Probe Script for `put` Function"
    Date: 2025-07-09
    Author: "Qwen 3 Ai"
    Purpose: {Systematically test the behavior of the `put` function in Rebol 3 Oldes branch (3.19.0)}
]

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
        print "✅ ALL TEST CASE EXAMPLES PASSED."
    ][
        print "❌ SOME TEST CASE EXAMPLES FAILED."
    ]
    print "============================================^/"
]

print "^/=== DIAGNOSTIC PROBE SCRIPT FOR `PUT` FUNCTION ==="
print "Target: REBOL/Bulk 3.19.0 (Oldes Branch) 2025-07-09"

;; =============================================================================
;; HYPOTHESIS: Basic Behavior with Block Series
;; -----------------------------------------------------------------------------
block1: [a 10 b 20]
result1: put block1 'a 100
assert-equal result1 100 "Return value matches input value"
assert-equal block1 [a 100 b 20] "Replaces value after first key occurrence"

block2: [a 10 a 20]
result2: put block2 'a 100
assert-equal result2 100 "Return value remains consistent"
assert-equal block2 [a 100 a 20] "Only first key occurrence modified"

block3: [a 10]
result3: put block3 'b 20
assert-equal result3 20 "Handles non-existent key"
assert-equal block3 [a 10 b 20] "Appends key+value when not found"

;; =============================================================================
;; HYPOTHESIS: Map Series Behavior
;; -----------------------------------------------------------------------------
map1: make map! [a 1 b 2]
result4: put map1 'a 100
assert-equal result4 100 "Return value consistency with maps"
assert-equal map1 make map! [a 100 b 2] "Direct key-value replacement"

result5: put map1 'c 3
assert-equal result5 3 "Handles non-existent keys"
assert-equal map1 make map! [a 100 b 2 c 3] "Adds new key-value pairs"

;; =============================================================================
;; HYPOTHESIS: Case-Sensitive Behavior (/case refinement)
;; -----------------------------------------------------------------------------
block4: ["Key" 1]
result6: put/case block4 "key" 2
assert-equal result6 2 "Return value with /case refinement"
assert-equal block4 ["Key" 1 "key" 2] "Case-insensitive key remains unchanged"

map2: make map! ["Key" 1]
put/case map2 "key" 2
assert-equal select/case map2 "Key" 1 "Original key remains intact"
assert-equal select/case map2 "key" 2 "New key added with /case refinement"

;; =============================================================================
;; HYPOTHESIS: Record-Based Behavior (/skip refinement)
;; -----------------------------------------------------------------------------
block5: [a 1 b 2 c 3]
result7: put/skip block5 'b 20 2
assert-equal result7 20 "Return value with /skip"
assert-equal block5 [a 1 b 20 c 3] "Modifies value within specified record size"

block6: [a 1 b 2 c 3 d 4]
result8: put/skip block6 'c 30 2
assert-equal result8 30 "Complex record size handling"
assert-equal block6 [a 1 b 2 c 30 d 4] "Modifies correct record position"

;; =============================================================================
;; HYPOTHESIS: Edge Case Handling
;; -----------------------------------------------------------------------------
empty-block: []
result9: put empty-block 'key 1
assert-equal result9 1 "Empty block handling"
assert-equal empty-block ['key 1] "Initial key-value insertion"

empty-map: make map! []
result10: put empty-map 'key 1
assert-equal result10 1 "Empty map initialization"
assert-equal empty-map make map! [key 1] "Map creation from empty state"

;; =============================================================================
;; FINAL VERIFICATION
;; =============================================================================
print-test-summary
