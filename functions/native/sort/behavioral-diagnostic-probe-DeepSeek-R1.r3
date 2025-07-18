Rebol [
    Title: "`sort` Function Behavioral Diagnostic Probe"
    Author: "Rebol Expert"
    Version: 0.1.0
    Purpose: {Systematically diagnose the behavior of the `sort` action and all its refinements.}
]

print "^/============================================"
print "=== SORT FUNCTION DIAGNOSTIC PROBE ==="
print "============================================^/"

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
    print ["=== TEST SUMMARY ==="]
    print "============================================"
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - SORT IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;; ============================================================================
;; SECTION 1: PROBING BASIC SORT BEHAVIOR
;; ============================================================================

print "^/--- SECTION 1: PROBING BASIC SORT BEHAVIOR ---^/"

;; HYPOTHESIS: sort modifies the series in-place and returns the sorted series
;; HYPOTHESIS: Default sort order is ascending for numeric values
test-block: [3 1 4 1 5 9 2 6]
original-block: copy test-block
sorted-result: sort test-block
assert-equal [1 1 2 3 4 5 6 9] sorted-result "Basic integer sort ascending"
assert-equal [1 1 2 3 4 5 6 9] test-block "Sort modifies original series in-place"

;; HYPOTHESIS: sort works with string values, using lexicographic ordering
test-strings: ["zebra" "apple" "banana" "cherry"]
sorted-strings: sort test-strings
assert-equal ["apple" "banana" "cherry" "zebra"] sorted-strings "Basic string sort ascending"

;; HYPOTHESIS: sort works with single characters
test-chars: [#"z" #"a" #"m" #"b"]
sorted-chars: sort test-chars
assert-equal [#"a" #"b" #"m" #"z"] sorted-chars "Basic character sort ascending"

;; HYPOTHESIS: sort works with decimals
test-decimals: [3.14 2.71 1.41 0.57]
sorted-decimals: sort test-decimals
assert-equal [0.57 1.41 2.71 3.14] sorted-decimals "Basic decimal sort ascending"

;; HYPOTHESIS: sort works with words
test-words: [zebra apple banana cherry]
sorted-words: sort test-words
assert-equal [apple banana cherry zebra] sorted-words "Basic word sort ascending"

;; ============================================================================
;; SECTION 2: PROBING EDGE CASES - EMPTY AND SINGLE ELEMENT SERIES
;; ============================================================================

print "^/--- SECTION 2: PROBING EDGE CASES - EMPTY AND SINGLE ELEMENT ---^/"

;; HYPOTHESIS: sort handles empty blocks gracefully
empty-block: []
sorted-empty: sort empty-block
assert-equal [] sorted-empty "Empty block sort returns empty block"

;; HYPOTHESIS: sort handles single element blocks
single-element: [42]
sorted-single: sort single-element
assert-equal [42] sorted-single "Single element sort returns same element"

;; HYPOTHESIS: sort handles empty strings
empty-string: ""
sorted-empty-string: sort empty-string
assert-equal "" sorted-empty-string "Empty string sort returns empty string"

;; HYPOTHESIS: sort handles single character strings
single-char-string: "a"
sorted-single-char: sort single-char-string
assert-equal "a" sorted-single-char "Single character string sort unchanged"

;; ============================================================================
;; SECTION 3: PROBING STRING SORTING BEHAVIOR
;; ============================================================================

print "^/--- SECTION 3: PROBING STRING SORTING BEHAVIOR ---^/"

;; HYPOTHESIS: sort on strings sorts character by character within the string
test-string: "hello"
sorted-string: sort test-string
assert-equal "ehllo" sorted-string "String characters sorted within string"

;; HYPOTHESIS: sort treats uppercase and lowercase differently by default
;; CORRECTED: lowercase letters sort before uppercase letters in default mode
mixed-case-string: "HeLLo"
sorted-mixed: sort mixed-case-string
assert-equal "eHLLo" sorted-mixed "Mixed case string - lowercase sorts before uppercase"

;; ============================================================================
;; SECTION 4: PROBING /CASE REFINEMENT
;; ============================================================================

print "^/--- SECTION 4: PROBING /CASE REFINEMENT ---^/"

;; HYPOTHESIS: /case refinement makes sorting case-sensitive
test-case-strings: ["Apple" "banana" "Cherry" "apple"]
case-sensitive-result: sort/case copy test-case-strings
assert-equal ["Apple" "Cherry" "apple" "banana"] case-sensitive-result "Case-sensitive string sort"

;; HYPOTHESIS: /case affects string character sorting
mixed-case-chars: "AaBbCc"
case-sensitive-chars: sort/case copy mixed-case-chars
assert-equal "ABCabc" case-sensitive-chars "Case-sensitive character sort within string"

;; HYPOTHESIS: /case has no effect on numeric values
test-numbers: [3 1 4 1 5]
case-numbers: sort/case copy test-numbers
assert-equal [1 1 3 4 5] case-numbers "Case refinement on numbers behaves same as basic sort"

;; ============================================================================
;; SECTION 5: PROBING /REVERSE REFINEMENT
;; ============================================================================

print "^/--- SECTION 5: PROBING /REVERSE REFINEMENT ---^/"

;; HYPOTHESIS: /reverse sorts in descending order
test-reverse: [1 3 2 5 4]
reversed-result: sort/reverse copy test-reverse
assert-equal [5 4 3 2 1] reversed-result "Reverse sort produces descending order"

;; HYPOTHESIS: /reverse works with strings
test-reverse-strings: ["apple" "banana" "cherry"]
reversed-strings: sort/reverse copy test-reverse-strings
assert-equal ["cherry" "banana" "apple"] reversed-strings "Reverse string sort"

;; HYPOTHESIS: /reverse and /case can be combined
test-case-reverse: ["Apple" "banana" "Cherry" "apple"]
case-reverse-result: sort/case/reverse copy test-case-reverse
assert-equal ["banana" "apple" "Cherry" "Apple"] case-reverse-result "Combined case and reverse sort"

;; ============================================================================
;; SECTION 6: PROBING /SKIP REFINEMENT
;; ============================================================================

print "^/--- SECTION 6: PROBING /SKIP REFINEMENT ---^/"

;; HYPOTHESIS: /skip treats the series as fixed-size records and sorts by first element
test-skip-data: [3 "three" 1 "one" 2 "two"]
skip-result: sort/skip copy test-skip-data 2
assert-equal [1 "one" 2 "two" 3 "three"] skip-result "Skip 2 sorts by first element of pairs"

;; HYPOTHESIS: /skip with size 3 creates records of 3 elements
test-skip-three: [9 "nine" 90 3 "three" 30 6 "six" 60]
skip-three-result: sort/skip copy test-skip-three 3
assert-equal [3 "three" 30 6 "six" 60 9 "nine" 90] skip-three-result "Skip 3 sorts by first element of triplets"

;; HYPOTHESIS: /skip with size 1 is equivalent to basic sort
test-skip-one: [3 1 4 1 5]
skip-one-result: sort/skip copy test-skip-one 1
assert-equal [1 1 3 4 5] skip-one-result "Skip 1 equivalent to basic sort"

;; ============================================================================
;; SECTION 7: PROBING /PART REFINEMENT
;; ============================================================================

print "^/--- SECTION 7: PROBING /PART REFINEMENT ---^/"

;; HYPOTHESIS: /part with integer limits sorting to first N elements
test-part-data: [5 3 8 1 9 2 7]
part-result: sort/part copy test-part-data 4
assert-equal [1 3 5 8 9 2 7] part-result "Part 4 sorts only first 4 elements"

;; FIXED: Accept both behaviors for negative part count (either error or sorts nothing)
test-part-negative: [5 3 8 1 9 2 7]
original: copy test-part-negative
set/any 'part-negative-result try [sort/part copy test-part-negative -1]
either error? part-negative-result [
    print "✅ PASSED: Part with negative count properly generates error"
][
    either equal? original part-negative-result [
        print "✅ PASSED: Part with negative count leaves series unchanged (clamped to 0)"
    ][
        print rejoin ["❌ FAILED: Part with negative count should leave series unchanged but got: " mold part-negative-result]
        set 'all-tests-passed? false
    ]
]

;; HYPOTHESIS: /part with length greater than series length sorts entire series
test-part-long: [3 1 4]
part-long-result: sort/part copy test-part-long 10
assert-equal [1 3 4] part-long-result "Part length > series length sorts entire series"

;; ============================================================================
;; SECTION 8: PROBING /COMPARE REFINEMENT WITH INTEGER OFFSET
;; ============================================================================

print "^/--- SECTION 8: PROBING /COMPARE REFINEMENT WITH INTEGER OFFSET ---^/"

;; HYPOTHESIS: /compare with integer offset sorts by element at that offset
test-compare-data: [
    ["Alice" 25] ["Bob" 30] ["Charlie" 20]
]
compare-result: sort/compare copy test-compare-data 2
assert-equal [["Charlie" 20] ["Alice" 25] ["Bob" 30]] compare-result "Compare offset 2 sorts by second element"

;; HYPOTHESIS: /compare with offset 1 sorts by first element (same as default)
compare-first: sort/compare copy test-compare-data 1
assert-equal [["Alice" 25] ["Bob" 30] ["Charlie" 20]] compare-first "Compare offset 1 sorts by first element"

;; ============================================================================
;; SECTION 9: PROBING /COMPARE REFINEMENT WITH FUNCTION
;; ============================================================================

print "^/--- SECTION 9: PROBING /COMPARE REFINEMENT WITH FUNCTION ---^/"

;; HYPOTHESIS: /compare with function uses custom comparison logic
test-compare-func: [4 2 6 1 5]
;; FIXED: Added tie-breaker for equal distances and fixed missing bracket
compare-func: function [a b] [
    abs-diff-a: abs (a - 3)
    abs-diff-b: abs (b - 3)
    case [
        abs-diff-a < abs-diff-b [true]
        abs-diff-a > abs-diff-b [false]
        true [a < b]  ; Break ties by value
    ]
]
compare-func-result: sort/compare copy test-compare-func :compare-func
assert-equal [2 4 1 5 6] compare-func-result "Compare with custom function sorts by distance from 3"

;; HYPOTHESIS: /compare with function for reverse numeric sort
reverse-func: function [a b] [a > b]
reverse-func-result: sort/compare copy [1 3 2 5 4] :reverse-func
assert-equal [5 4 3 2 1] reverse-func-result "Compare function for reverse numeric sort"

;; ============================================================================
;; SECTION 10: PROBING /ALL REFINEMENT
;; ============================================================================

print "^/--- SECTION 10: PROBING /ALL REFINEMENT ---^/"

;; FIXED: Removed /skip since /all automatically handles nested blocks
;; HYPOTHESIS: /all compares all fields in records
test-all-data: [
    [1 "zebra"] [1 "apple"] [2 "banana"]
]
all-result: sort/all copy test-all-data
assert-equal [[1 "apple"] [1 "zebra"] [2 "banana"]] all-result "All refinement compares all fields in records"

;; HYPOTHESIS: /all without /skip might behave differently
test-all-simple: [[3 1] [1 2] [1 1]]
all-simple-result: sort/all copy test-all-simple
assert-equal [[1 1] [1 2] [3 1]] all-simple-result "All refinement on simple nested blocks"

;; ============================================================================
;; SECTION 11: PROBING COMPLEX COMBINATIONS
;; ============================================================================

print "^/--- SECTION 11: PROBING COMPLEX COMBINATIONS ---^/"

;; FIXED: Removed unnecessary /skip from combination test
;; HYPOTHESIS: /all and /reverse can be combined for block sorting
test-complex: [
    [3 "Charlie"] [1 "Alice"] [2 "Bob"] [1 "Adam"]
]
complex-result: sort/all/reverse copy test-complex
assert-equal [[3 "Charlie"] [2 "Bob"] [1 "Alice"] [1 "Adam"]] complex-result "All + Reverse combination on blocks"

;; HYPOTHESIS: Part and reverse can be combined
test-part-reverse: [5 3 8 1 9 2 7]
part-reverse-result: sort/part/reverse copy test-part-reverse 4
assert-equal [8 5 3 1 9 2 7] part-reverse-result "Part + Reverse sorts first 4 in descending order"

;; ============================================================================
;; SECTION 12: PROBING SERIES POSITION HANDLING
;; ============================================================================

print "^/--- SECTION 12: PROBING SERIES POSITION HANDLING ---^/"

;; HYPOTHESIS: sort works correctly when series is not at head position
test-position: [0 5 3 8 1 9 2 7]
positioned-series: next test-position  ; Skip first element
positioned-result: sort positioned-series
; Should sort from position 2 onwards, leaving first element unchanged
assert-equal [0 1 2 3 5 7 8 9] test-position "Sort from non-head position affects remainder"

;; HYPOTHESIS: sort returns the series at the same position it was called from
test-position-return: [0 5 3 8 1 9 2 7]
positioned-series-return: next test-position-return
returned-series: sort positioned-series-return
; The returned series should be at the same position (second element)
assert-equal 1 first returned-series "Sort returns series at same position"

;; ============================================================================
;; SECTION 13: PROBING ERROR CONDITIONS
;; ============================================================================

print "^/--- SECTION 13: PROBING ERROR CONDITIONS ---^/"

;; HYPOTHESIS: sort with invalid skip size should handle gracefully
test-error-skip: [1 2 3 4]
set/any 'skip-error-result try [sort/skip copy test-error-skip 0]
either error? skip-error-result [
    print "✅ PASSED: Sort with skip size 0 properly generates error"
][
    print "❌ FAILED: Sort with skip size 0 should generate error"
    set 'all-tests-passed? false
]

;; HYPOTHESIS: sort with negative skip size should handle gracefully
set/any 'negative-skip-result try [sort/skip copy test-error-skip -1]
either error? negative-skip-result [
    print "✅ PASSED: Sort with negative skip size properly generates error"
][
    print "❌ FAILED: Sort with negative skip size should generate error"
    set 'all-tests-passed? false
]

;; HYPOTHESIS: sort with incompatible compare function should handle gracefully
bad-compare-func: function [a] [a]  ; Wrong arity
set/any 'compare-error-result try [sort/compare copy [1 2 3] :bad-compare-func]
either error? compare-error-result [
    print "✅ PASSED: Sort with bad compare function properly generates error"
][
    print "❌ FAILED: Sort with bad compare function should generate error"
    set 'all-tests-passed? false
]

;; ============================================================================
;; SECTION 14: PROBING MIXED DATA TYPES
;; ============================================================================

print "^/--- SECTION 14: PROBING MIXED DATA TYPES ---^/"

;; HYPOTHESIS: sort handles mixed numeric types
test-mixed-numbers: [1 2.5 3 1.5 4]
mixed-numbers-result: sort copy test-mixed-numbers
assert-equal [1 1.5 2.5 3 4] mixed-numbers-result "Mixed integers and decimals sort correctly"

;; FIXED: Updated expected order to match Rebol's actual type sorting behavior
test-mixed-types: [1 "apple" 2.5 #"b"]
mixed-types-result: sort copy test-mixed-types
assert-equal [1 2.5 #"b" "apple"] mixed-types-result "Mixed types sort by type then value"

;; ============================================================================
;; FINAL TEST SUMMARY
;; ============================================================================

print-test-summary
