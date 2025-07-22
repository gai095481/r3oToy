Rebol []

;; Diagnostic Probe Script for COMBINE function
;; Target: REBOL/Bulk 3.19.0 (Oldes Branch)
;;
;; Corrected based on REPL test results
;; Key insights:
;; 1. Words are included by default (only get-words are dereferenced)
;; 2. Nested blocks are processed recursively by default
;; 3. /only refinement controls block insertion vs recursion

;;-----------------------------
;; Test Harness Functions
;;-----------------------------
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

;; Safe values for testing
none-val: none
func-val: :append

;; Create an unset value
unset-test-word: 'unset-word
unset 'unset-test-word

;;------------------------------------
;; Probe 1: Basic Combination Behavior
;;------------------------------------
print "=== Probing Basic Combination Behavior ==="

;; Hypothesis: Words are included as literals, get-words are dereferenced
test-block: [1 "two" none-val :third-value (4) :unset-test-word :func-val]
third-value: "three"

assert-equal "1twonone-valthree4" combine test-block "Words included, get-words dereferenced"

;; Hypothesis: Parens evaluate, functions ignored via get-word
assert-equal "6" combine [(2 * 3) :append] "Parens evaluated, functions ignored"

;;------------------------------------
;; Probe 2: /WITH Refinement (Delimiter)
;;------------------------------------
print "^/=== Probing /WITH Refinement ==="

;; Hypothesis: Delimiter inserted between all values including ignored types
assert-equal "a|none-val|b|c" combine/with [a none-val b c] "|" "Delimiter between all values"

;; Hypothesis: No leading/trailing delimiters
assert-equal "1,2" combine/with [1 2] "," "No extra delimiters"

;;------------------------------------
;; Probe 3: /INTO Refinement (Output)
;;------------------------------------
print "^/=== Probing /INTO Refinement ==="

;; Hypothesis: Appends values to existing series
target-str: make string! "Prefix: "
combine-result: combine/into [a b c] target-str
assert-equal "Prefix: abc" target-str "String appending"

;; Hypothesis: Includes all values in block output
target-blk: [x y]
combine/into [1 2 none-val] target-blk
assert-equal [x y 1 2 none-val] target-blk "All values included in block"

;;------------------------------------
;; Probe 4: /IGNORE Refinement (Filtering)
;;------------------------------------
print "^/=== Probing /IGNORE Refinement ==="

;; Hypothesis: Custom typeset overrides default ignored types
custom-ignore: make typeset! [integer! string!]
assert-equal "3.14" combine/ignore [1 "two" 3.14] custom-ignore "Custom ignore"

;; Hypothesis: Empty typeset includes all values
assert-equal "1a2" combine/ignore [1 "a" 2] make typeset! [] "No ignores"

;;------------------------------------
;; Probe 5: /ONLY Refinement (Block Handling)
;;------------------------------------
print "^/=== Probing /ONLY Refinement ==="

;; Hypothesis: Without /only, blocks are processed recursively
assert-equal "abc" combine [ [a] [b c] ] "Nested blocks processed recursively"

;; Hypothesis: With /only, blocks inserted as single values
target-blk2: [1 2]
combine/only/into [ [a b] c ] target-blk2
assert-equal [1 2 [a b] c] target-blk2 "/only block insertion"

;;------------------------------------
;; Probe 6: Edge Cases
;;------------------------------------
print "^/=== Probing Edge Cases ==="

;; Hypothesis: All-ignored input returns empty output
assert-equal "" combine/ignore [:none-val :unset-test-word :func-val] make typeset! [word! unset! none! any-function!] "All values ignored"

;; Hypothesis: Empty input returns empty output
assert-equal "" combine [] "Empty input block"


;; Print final test summary
print-test-summary
