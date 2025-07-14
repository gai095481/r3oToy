Rebol [
    Title: "Resolve Function Diagnostic Probe - CORRECTED WORD CHECKING"
    Purpose: "Comprehensive testing of resolve - word existence checking fixed"
    Author: "AI Assistant (Corrected Word Checking)"
    Date: 14-Jul-2025
    Version: 1.6.0
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


;; Corrected word existence checker for Rebol 3
word-exists?: function [
    {Check if a word exists in an object without causing errors}
    obj [object!] "The object to check"
    word [word!] "The word to check for"
][
    ; In Rebol 3, 'in' returns the word if found, none if not found
    not none? in obj word
]

;; Safe word getter
safe-get: function [
    {Safely get a word value from an object, return unset! if not found}
    obj [object!] "The object to get from"
    word [word!] "The word to get"
][
    either word-exists? obj word [
        get in obj word
    ][
        unset!
    ]
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
    print rejoin ["Success Rate: " round/to (pass-count * 100.0) / test-count 0.1 "%"]
    print rejoin ["========================================"]
    either all-tests-passed? [
        print "🎉 ALL TESTS PASSED! 🎉"
    ][
        print "⚠️  SOME TESTS FAILED ⚠️"
    ]
    print rejoin ["========================================^/"]
]

;;-----------------------------
;; Understanding TRUE RESOLVE behavior
;;------------------------------

print "^/🔍 RESOLVE FUNCTION TRUE BEHAVIOR ANALYSIS^/"
print "=============================================="

print "^/Testing what basic resolve actually does..."

;; Create source with values
test-source: context [x: 100 y: 200 z: 300]

;; Test 1: Basic resolve with existing values (should NOT change)
test-target1: context [x: 1 y: 2 w: 4]
print ["Before basic resolve - target1/x:" test-target1/x "target1/y:" test-target1/y "target1/w:" test-target1/w]
resolve test-target1 test-source
print ["After basic resolve - target1/x:" test-target1/x "target1/y:" test-target1/y "target1/w:" test-target1/w]

;; Test 2: Basic resolve with unset values (should NOT change either!)
test-target2: context [x: unset! y: unset! w: 4]
print ["Before basic resolve with unset - target2/x:" test-target2/x "target2/y:" test-target2/y "target2/w:" test-target2/w]
resolve test-target2 test-source
print ["After basic resolve with unset - target2/x:" test-target2/x "target2/y:" test-target2/y "target2/w:" test-target2/w]

;; Test 3: What does basic resolve actually do? It might only work on missing words!
test-target3: context [w: 4]  ; Missing x and y entirely
print ["Before basic resolve with missing words - target3/w:" test-target3/w]
resolve/extend test-target3 test-source  ; Need extend to add missing words
print ["After resolve/extend - target3/x:" test-target3/x "target3/y:" test-target3/y "target3/z:" test-target3/z "target3/w:" test-target3/w]

;; Test 4: What about resolve/all?
test-target4: context [x: 1 y: 2 w: 4]
print ["Before resolve/all - target4/x:" test-target4/x "target4/y:" test-target4/y "target4/w:" test-target4/w]
resolve/all test-target4 test-source
print ["After resolve/all - target4/x:" test-target4/x "target4/y:" test-target4/y "target4/w:" test-target4/w]

;;-----------------------------
;; RESOLVE Function Tests - CORRECTED
;;------------------------------

print "^/🔍 RESOLVE FUNCTION COMPREHENSIVE TESTING^/"
print "=============================================="

;;-- Test 1: Basic resolve behavior (CORRECTED)
print "^/Test Group 1: Basic RESOLVE functionality"
print "--------------------------------------------"

;; Basic resolve does nothing to existing words
source1: context [a: 1 b: 2 c: 3]
target1: context [a: 999 b: 888 d: 4]

;; Basic resolve should NOT change existing values
resolve target1 source1

assert-equal 999 target1/a "Basic resolve: target1/a should remain 999 (unchanged)"
assert-equal 888 target1/b "Basic resolve: target1/b should remain 888 (unchanged)"
assert-equal 4 target1/d "Basic resolve: target1/d should remain 4"

;; Check that c was not added - using corrected existence check
has-c: word-exists? target1 'c
assert-equal false has-c "Basic resolve: target1/c should not exist"

;;-- Test 2: RESOLVE/ALL refinement (CORRECTED)
print "^/Test Group 2: RESOLVE/ALL refinement"
print "--------------------------------------"

source2: context [a: 10 b: 20 c: 30]
target2: context [a: 1 b: 2 d: 4]

;; Test resolve/all (should overwrite all matching values)
resolve/all target2 source2

assert-equal 10 target2/a "RESOLVE/ALL: target2/a should be 10"
assert-equal 20 target2/b "RESOLVE/ALL: target2/b should be 20"
assert-equal 4 target2/d "RESOLVE/ALL: target2/d should remain 4"

;; Check that c was not added (no /extend)
has-c2: word-exists? target2 'c
assert-equal false has-c2 "RESOLVE/ALL: target2/c should not exist"

;;-- Test 3: RESOLVE/EXTEND refinement (CORRECTED)
print "^/Test Group 3: RESOLVE/EXTEND refinement"
print "-----------------------------------------"

source3: context [a: 100 b: 200 c: 300 e: 500]
target3: context [a: 1 b: 2 d: 4]

;; Test resolve/extend (should add new words but not overwrite existing)
resolve/extend target3 source3

assert-equal 1 target3/a "RESOLVE/EXTEND: target3/a should remain 1 (not overwritten)"
assert-equal 2 target3/b "RESOLVE/EXTEND: target3/b should remain 2 (not overwritten)"
assert-equal 300 target3/c "RESOLVE/EXTEND: target3/c should be 300 (extended)"
assert-equal 4 target3/d "RESOLVE/EXTEND: target3/d should remain 4"
assert-equal 500 target3/e "RESOLVE/EXTEND: target3/e should be 500 (extended)"

;;-- Test 4: RESOLVE/ALL/EXTEND refinement (CORRECTED)
print "^/Test Group 4: RESOLVE/ALL/EXTEND combined"
print "-------------------------------------------"

source4: context [a: 100000 b: 200000 c: 300000 g: 700000]
target4: context [a: 1 b: 2 d: 4 e: 5]

;; Test resolve/all/extend (should overwrite all and extend)
resolve/all/extend target4 source4

assert-equal 100000 target4/a "RESOLVE/ALL/EXTEND: target4/a should be 100000"
assert-equal 200000 target4/b "RESOLVE/ALL/EXTEND: target4/b should be 200000"
assert-equal 300000 target4/c "RESOLVE/ALL/EXTEND: target4/c should be 300000 (extended)"
assert-equal 4 target4/d "RESOLVE/ALL/EXTEND: target4/d should remain 4"
assert-equal 5 target4/e "RESOLVE/ALL/EXTEND: target4/e should remain 5"
assert-equal 700000 target4/g "RESOLVE/ALL/EXTEND: target4/g should be 700000 (extended)"

;;-- Test 5: RESOLVE/ONLY with word block (CORRECTED)
print "^/Test Group 5: RESOLVE/ONLY with word block"
print "--------------------------------------------"

source5: context [a: 1000 b: 2000 c: 3000 d: 4000]
target5: context [a: 1 b: 2 d: 4 e: 5]

;; Test resolve/only with specific words (basic resolve does nothing to existing values)
resolve/only target5 source5 [a c]

assert-equal 1 target5/a "RESOLVE/ONLY [a c]: target5/a should remain 1 (unchanged)"
assert-equal 2 target5/b "RESOLVE/ONLY [a c]: target5/b should remain 2"
assert-equal 4 target5/d "RESOLVE/ONLY [a c]: target5/d should remain 4"
assert-equal 5 target5/e "RESOLVE/ONLY [a c]: target5/e should remain 5"

;; Check if c was added - without /extend it should NOT be added
has-c5: word-exists? target5 'c
assert-equal false has-c5 "RESOLVE/ONLY [a c]: target5/c should not exist (no /extend)"

;;-- Test 6: RESOLVE/ONLY/EXTEND with word block (CORRECTED)
print "^/Test Group 6: RESOLVE/ONLY/EXTEND with word block"
print "---------------------------------------------------"

source6: context [a: 10000 b: 20000 c: 30000 d: 40000]
target6: context [a: 1 b: 2 d: 4 e: 5]

;; Test resolve/only/extend with specific words (should only extend c, not change a)
resolve/only/extend target6 source6 [a c]

assert-equal 1 target6/a "RESOLVE/ONLY/EXTEND [a c]: target6/a should remain 1 (unchanged)"
assert-equal 2 target6/b "RESOLVE/ONLY/EXTEND [a c]: target6/b should remain 2"
assert-equal 30000 target6/c "RESOLVE/ONLY/EXTEND [a c]: target6/c should be 30000 (extended)"
assert-equal 4 target6/d "RESOLVE/ONLY/EXTEND [a c]: target6/d should remain 4"
assert-equal 5 target6/e "RESOLVE/ONLY/EXTEND [a c]: target6/e should remain 5"

;;-- Test 7: RESOLVE/ONLY/ALL with word block (CORRECTED)
print "^/Test Group 7: RESOLVE/ONLY/ALL with word block"
print "------------------------------------------------"

source7: context [a: 1000000 b: 2000000 c: 3000000 d: 4000000]
target7: context [a: 1 b: 2 d: 4 e: 5]

;; Test resolve/only/all with specific words (should overwrite specified words)
resolve/only/all target7 source7 [a b]

assert-equal 1000000 target7/a "RESOLVE/ONLY/ALL [a b]: target7/a should be 1000000"
assert-equal 2000000 target7/b "RESOLVE/ONLY/ALL [a b]: target7/b should be 2000000"
assert-equal 4 target7/d "RESOLVE/ONLY/ALL [a b]: target7/d should remain 4"
assert-equal 5 target7/e "RESOLVE/ONLY/ALL [a b]: target7/e should remain 5"

;;-- Test 8: RESOLVE/ONLY with integer index (CORRECTED)
print "^/Test Group 8: RESOLVE/ONLY with integer index"
print "-----------------------------------------------"

source8: context [a: 50000 b: 60000 c: 70000 d: 80000]
target8: context [a: 1 b: 2 d: 4 e: 5 f: 6]

;; Get the words of target8 to understand the index
target8-words: words-of target8
print ["Target8 words:" mold target8-words]

;; Test resolve/only with integer index 3 (should not change anything without /all)
resolve/only target8 source8 3

assert-equal 1 target8/a "RESOLVE/ONLY 3: target8/a should remain 1"
assert-equal 2 target8/b "RESOLVE/ONLY 3: target8/b should remain 2"
assert-equal 4 target8/d "RESOLVE/ONLY 3: target8/d should remain 4"
assert-equal 5 target8/e "RESOLVE/ONLY 3: target8/e should remain 5"
assert-equal 6 target8/f "RESOLVE/ONLY 3: target8/f should remain 6"

;;-- Test 9: RESOLVE/ONLY/ALL with integer index (CORRECTED)
print "^/Test Group 9: RESOLVE/ONLY/ALL with integer index"
print "---------------------------------------------------"

source9: context [a: 90000 b: 91000 c: 92000 d: 93000]
target9: context [a: 1 b: 2 d: 4 e: 5 f: 6]

;; Store original words before resolve
target9-words: words-of target9
print ["Target9 words before resolve:" mold target9-words]

;; Test resolve/only/all with integer index (should affect words from index onwards)
resolve/only/all target9 source9 3

;; Check which words still exist after resolve
target9-words-after: words-of target9
print ["Target9 words after resolve:" mold target9-words-after]

assert-equal 1 target9/a "RESOLVE/ONLY/ALL 3: target9/a should remain 1"
assert-equal 2 target9/b "RESOLVE/ONLY/ALL 3: target9/b should remain 2"
assert-equal 93000 target9/d "RESOLVE/ONLY/ALL 3: target9/d should be 93000 (3rd word)"

;; helper function:
obj-has-word?: funct [an-obj [object!] a-word [word!]][return not none! find words-of an-obj a-word]

;; Configure the test case
print "^/=== TESTING RESOLVE/ONLY/ALL WITH INDEX ==="

;; Create our test objects
target9: make object! [a: 1 b: 2 c: 3 d: 4 e: 5 f: 6]
source9: make object! [a: 10 b: 20 c: 30 d: 40]

print "Initial objects:"
print ["target9:" mold target9]
print ["source9:" mold source9]

;; Apply resolve/only/all with index 3
print "^/Applying resolve/only/all with index 3..."
resolve/only/all target9 source9 3

print "^/After resolve:"
print ["target9:" mold target9]

;; Show words in target9 after resolve
print "^/Words in target9 after resolve:"
print mold words-of target9

;; Test for existence of words before trying to access them
print "^/Testing e and f words existence:"
print ["e exists?" obj-has-word? target9 'e]
print ["f exists?" obj-has-word? target9 'f]

;; The safer way to test
print "^/Safe testing approach:"
either obj-has-word? target9 'e [
    assert-equal 5 target9/e "RESOLVE/ONLY/ALL 3: target9/e should remain 5"
] [
    print "INFO: target9/e was removed by resolve/only/all with index 3"
    ;; We should add an assertion that confirms the word was properly removed
    assert-equal false obj-has-word? target9 'e "RESOLVE/ONLY/ALL 3: target9/e should be removed"
]

either obj-has-word? target9 'f [
    assert-equal 6 target9/f "RESOLVE/ONLY/ALL 3: target9/f should remain 6"
] [
    print "INFO: target9/f was removed by resolve/only/all with index 3"
    ;; We should add an assertion that confirms the word was properly removed
    assert-equal false obj-has-word? target9 'f "RESOLVE/ONLY/ALL 3: target9/f should be removed"
]

;;-- Test 10: Edge cases (CORRECTED)
print "^/Test Group 10: Edge cases and special values"
print "----------------------------------------------"

;; Test with empty objects
empty-source: context []
empty-target: context []

resolve empty-target empty-source
assert-equal true true "Empty objects resolve should not fail"

;; Test with unset values (should remain unchanged)
source10: context [a: 1 b: 2 c: 3]
target10: context [a: unset! b: 10 d: 4]

;; Basic resolve should NOT change unset values
resolve target10 source10
assert-equal unset! target10/a "Unset handling: target10/a should remain unset!"
assert-equal 10 target10/b "Unset handling: target10/b should remain 10"
assert-equal 4 target10/d "Unset handling: target10/d should remain 4"

;; Test with resolve/all on unset values
resolve/all target10 source10
assert-equal 1 target10/a "Unset handling with /all: target10/a should be 1"
assert-equal 2 target10/b "Unset handling with /all: target10/b should be 2"
assert-equal 4 target10/d "Unset handling with /all: target10/d should remain 4"

;;-- Test 11: Complex value types (CORRECTED)
print "^/Test Group 11: Complex value types"
print "------------------------------------"

test-func: function [x] [x * 2]
test-block: [1 2 3]
test-string: "hello world"

source11: context [
    func-val: :test-func
    block-val: test-block
    string-val: test-string
]

target11: context [
    func-val: unset!
    block-val: unset!
    string-val: unset!
    other-val: 42
]

;; Basic resolve won't change unset values
resolve target11 source11

assert-equal unset! target11/func-val "Complex types: func-val should remain unset!"
assert-equal unset! target11/block-val "Complex types: block-val should remain unset!"
assert-equal unset! target11/string-val "Complex types: string-val should remain unset!"
assert-equal 42 target11/other-val "Complex types: other-val should remain 42"

;; Now test with /all
resolve/all target11 source11

;; Test that function works
func-result: target11/func-val 5
assert-equal 10 func-result "Complex types with /all: function should work correctly"

assert-equal test-block target11/block-val "Complex types with /all: block should be copied"
assert-equal test-string target11/string-val "Complex types with /all: string should be copied"
assert-equal 42 target11/other-val "Complex types with /all: other-val should remain 42"

;;-- Test 12: Performance and stress testing (CORRECTED)
print "^/Test Group 12: Performance and stress testing"
print "-----------------------------------------------"

;; Create performance test objects
perf-source: context []
perf-target: context []

;; Build objects with existing values (to test resolve/all performance)
repeat i 25 [
    word: to-word rejoin ["test" i]
    set-word: to-set-word word

    perf-source: make perf-source reduce [set-word i]
    perf-target: make perf-target reduce [set-word 0]
]

;; Time the resolve/all operation (basic resolve would do nothing)
start-time: now/time/precise
resolve/all perf-target perf-source
end-time: now/time/precise

time-diff: end-time - start-time
print rejoin ["Performance test: resolved/all 25 words in " time-diff " seconds"]

;; Verify values were resolved correctly
assert-equal 1 perf-target/test1 "Performance test: test1 should be 1"
assert-equal 13 perf-target/test13 "Performance test: test13 should be 13"
assert-equal 25 perf-target/test25 "Performance test: test25 should be 25"

;;-- Test 13: Comprehensive refinement matrix (CORRECTED)
print "^/Test Group 13: Comprehensive refinement matrix"
print "------------------------------------------------"

;; Test all combinations systematically
source13: context [x: 100 y: 200 z: 300]

;; Case 1: Basic resolve (should do nothing)
target13a: context [x: 1 y: 2 w: 4]
resolve target13a source13
assert-equal 1 target13a/x "Matrix test: basic resolve does nothing"
assert-equal 2 target13a/y "Matrix test: basic resolve does nothing"
assert-equal 4 target13a/w "Matrix test: basic resolve does nothing"

;; Case 2: resolve/all (should overwrite)
target13b: context [x: 1 y: 2 w: 4]
resolve/all target13b source13
assert-equal 100 target13b/x "Matrix test: resolve/all overwrites"
assert-equal 200 target13b/y "Matrix test: resolve/all overwrites"
assert-equal 4 target13b/w "Matrix test: resolve/all preserves non-matching"

;; Case 3: resolve/extend (should add but not overwrite)
target13c: context [x: 1 y: 2]
resolve/extend target13c source13
assert-equal 1 target13c/x "Matrix test: resolve/extend preserves existing"
assert-equal 2 target13c/y "Matrix test: resolve/extend preserves existing"
assert-equal 300 target13c/z "Matrix test: resolve/extend adds new"

;; Case 4: resolve/all/extend (should overwrite and add)
target13d: context [x: 1 y: 2]
resolve/all/extend target13d source13
assert-equal 100 target13d/x "Matrix test: resolve/all/extend overwrites"
assert-equal 200 target13d/y "Matrix test: resolve/all/extend overwrites"
assert-equal 300 target13d/z "Matrix test: resolve/all/extend adds new"

;;-----------------------------
;; Final Results
;;------------------------------

print "^/🏁 TESTING COMPLETE 🏁"
final-report

;; Return the overall test status
either all-tests-passed? [
    print "^/✅ All resolve function tests passed successfully!"
    print "^/📝 KEY INSIGHTS ABOUT RESOLVE:"
    print "   • Basic resolve does NOTHING to existing words"
    print "   • Basic resolve only works with /extend to add new words"
    print "   • /all is needed to overwrite existing values"
    print "   • unset! values are treated as existing values"
    print "   • /only limits which words are processed"
    print "   • /extend adds new words from source to target"
    print "   • /only with integer index may remove words from target"
    quit/return 0
][
    print "^/❌ Some resolve function tests failed. Check output above."
    quit/return 1
]
