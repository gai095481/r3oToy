Rebol []

;;----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;----------------------------------------------------------------------------
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

;; Probing Basic Behavior
probe "=== Probing Basic Behavior ==="

; Hypothesis: Replace replaces the first occurrence in a string (case-insensitive by default)
test-target-string-1-1: "Hello"
replace test-target-string-1-1 "hello" "Hi"
assert-equal "Hi" test-target-string-1-1 "Replace first occurrence in string (case-insensitive)"

; Hypothesis: Replace works in blocks, replacing first occurrence
test-target-block-1-2: [a b c a]
replace test-target-block-1-2 'a 'x
assert-equal [x b c a] test-target-block-1-2 "Replace first occurrence in block"

;; Probing /all Refinement
probe "=== Probing /all Refinement ==="

; Hypothesis: /all replaces all occurrences in a string
test-target-string-2-1: "ababa"
replace/all test-target-string-2-1 "a" "x"
assert-equal "xbxbx" test-target-string-2-1 "Replace all occurrences in string"

; Hypothesis: /all replaces all occurrences in a block
test-target-block-2-2: [a a a]
replace/all test-target-block-2-2 'a 'x
assert-equal [x x x] test-target-block-2-2 "Replace all occurrences in block"

;; Probing /case Refinement
probe "=== Probing /case Refinement ==="

; Hypothesis: /case makes replacement case-sensitive (no match)
test-target-string-3-1: "Hello"
replace/case test-target-string-3-1 "hello" "Hi"
assert-equal "Hello" test-target-string-3-1 "Case-sensitive replacement (no match)"

; Hypothesis: /case allows case-sensitive replacement (match)
test-target-string-3-2: "Hello"
replace/case test-target-string-3-2 "Hello" "Hi"
assert-equal "Hi" test-target-string-3-2 "Case-sensitive replacement (match)"

;; Probing /tail Refinement
probe "=== Probing /tail Refinement ==="

; Hypothesis: /tail returns target after the replacement position
test-target-string-4-1: "abc"
result-tail-1: replace/tail test-target-string-4-1 "a" "x"
assert-equal "bc" result-tail-1 "Tail returns position after replacement"
assert-equal "xbc" test-target-string-4-1 "Original target modified"

; Hypothesis: /tail with /all returns position after last replacement
test-target-string-4-2: "ababa"
result-tail-2: replace/tail/all test-target-string-4-2 "a" "x"
assert-equal 6 index? result-tail-2 "Tail returns position after last replacement"

;; Probing Edge Cases
probe "=== Probing Edge Cases ==="

; Hypothesis: Target is an empty series
test-target-string-5-1: ""
replace test-target-string-5-1 "a" "x"
assert-equal "" test-target-string-5-1 "Empty target"

; Hypothesis: Search not found
test-target-string-5-2: "abc"
replace test-target-string-5-2 "d" "x"
assert-equal "abc" test-target-string-5-2 "Search not found"

; Hypothesis: Search is a bitset (corrected charset syntax)
test-target-string-5-4: "abc"
search-bitset-5-4: charset [#"a" #"b"]
replace test-target-string-5-4 search-bitset-5-4 "x"
assert-equal "xbc" test-target-string-5-4 "Replace using bitset"

;; Probing Function as Replace Value
probe "=== Probing Function as Replace Value ==="

; Hypothesis: Replace with function uses return value
test-target-string-6-1: "abcabc"
replace/all test-target-string-6-1 "a" func [pos] [uppercase copy/part pos 1]
assert-equal "AbcAbc" test-target-string-6-1 "Replace with function"

; Hypothesis: Function receives position and returns matched value's length
test-target-string-6-2: "ababa"
replace/all test-target-string-6-2 "a" func [pos] [length? copy/part pos 1]
assert-equal "1b1b1" test-target-string-6-2 "Function uses matched value"

;; Print summary
print-test-summary
