Rebol [
    Title: "Resolve /only with Integer Diagnostic Script"
    Purpose: "Isolate and test the specific behavior of resolve/only/all with an integer index."
    Author: "AI Assistant"
    Date: 14-Jul-2025
    Version: 1.0.0
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
        message: rejoin [description " | Expected: " mold expected " | Actual: " mold actual]
    ]
    print rejoin [result-style " " message]
]

final-report: function [
    {Generate a summary report of all the test results.}
][
    print rejoin ["^/========================================"]
    print rejoin ["TEST SUMMARY REPORT"]
    print rejoin ["========================================"]
    print rejoin ["Total Tests: " test-count]
    print rejoin ["Passed: " pass-count]
    print rejoin ["Failed: " fail-count]
    if test-count > 0 [
        print rejoin ["Success Rate: " round/to (pass-count * 100.0) / test-count 0.1 "%"]
    ]
    print rejoin ["========================================"]
    either all-tests-passed? [
        print "🎉 ALL TESTS PASSED! 🎉"
    ][
        print "⚠️  SOME TESTS FAILED ⚠️"
    ]
    print rejoin ["========================================^/"]
]

;;-----------------------------
;; Test Script
;;------------------------------

print "^/🔍 Isolating RESOLVE/ONLY/ALL with integer index quirk^/"
print "=============================================="

;;-- Test Setup from original script's Group 9
source9: context [a: 90000 b: 91000 c: 92000 d: 93000]
target9: context [a: 1 b: 2 d: 4 e: 5 f: 6]

print ["Target9 words before resolve:" mold words-of target9]

;; Perform the operation
resolve/only/all target9 source9 3

print ["Target9 words after resolve:" mold words-of target9]


;;-- Verification Tests
print "^/--- Verifying state after `resolve/only/all` ---"

;; HYPOTHESIS: Words before the index are unaffected.
assert-equal 1 target9/a "Word 'a' (before index 3) should be unchanged"
assert-equal 2 target9/b "Word 'b' (before index 3) should be unchanged"

;; HYPOTHESIS: The word at the index is resolved if it exists in the source.
assert-equal 93000 target9/d "Word 'd' (at index 3) should be overwritten by source"

;; HYPOTHESIS: Words in the target that are AFTER the start index and do NOT exist
;; in the source object are made UNSET.
assert-equal true unset? get in target9 'e "Word 'e' (after index, not in source) should now be unset"
assert-equal true unset? get in target9 'f "Word 'f' (after index, not in source) should now be unset"


;;-----------------------------
;; Final Results
;;------------------------------

print "^/🏁 TESTING COMPLETE 🏁"
final-report
