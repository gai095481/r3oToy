REBOL [
    Title: "TAKE - Happy Path Examples"
    Purpose: {Demonstrates basic, correct usage of TAKE function}
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
        print "✅ ALL HAPPY PATH EXAMPLES PASSED"
    ][
        print "❌ SOME HAPPY PATH EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Happy Path Examples
;;-----------------------------------------------------------------------------
print "===== STARTING HAPPY PATH EXAMPLES ====="

; Example 1: Basic element removal from block
print "^/=== Example 1: Basic Block Take ==="
blk: [apple banana cherry]
result: take blk
print ["Taken item:" mold result]
print ["Remaining:" mold blk]
assert-equal 'apple result "Should take first element 'apple"
assert-equal [banana cherry] blk "Should leave [banana cherry]"

; Example 2: Remove last element with /last
print "^/=== Example 2: /LAST Refinement ==="
blk: [x y z]
result: take/last blk
print ["Last item:" mold result]
print ["Remaining:" mold blk]
assert-equal 'z result "Should take last element 'z"
assert-equal [x y] blk "Should leave [x y]"

; Example 3: Remove multiple elements with /part
print "^/=== Example 3: /PART Refinement ==="
blk: [1 2 3 4 5]
result: take/part blk 2
print ["Taken items:" mold result]
print ["Remaining:" mold blk]
assert-equal [1 2] result "Should take first two elements"
assert-equal [3 4 5] blk "Should leave [3 4 5]"

; Example 4: Clear series with /all
print "^/=== Example 4: /ALL Refinement ==="
blk: [alpha beta gamma]
result: take/all blk
print ["All items:" mold result]
print ["Series now:" mold blk]
assert-equal [alpha beta gamma] result "Should return all elements"
assert-equal [] blk "Should leave empty block"

; Example 5: String handling basics
print "^/=== Example 5: String Handling ==="
str: "Documentation"
result: take str
print ["First character:" result]
print ["Remaining text:" str]
assert-equal #"D" result "Should take first character #D"
assert-equal "ocumentation" str "Should leave 'ocumentation'"

;;-----------------------------------------------------------------------------
;; Test Summary
;;-----------------------------------------------------------------------------
print-test-summary
