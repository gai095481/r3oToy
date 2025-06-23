REBOL [
    Title: "TAKE Function Validation Probe"
    Purpose: {Validates TAKE behavior using QA test harness}
]

;;-----------------------------------------------------------------------------
;; Battle-Tested QA Harness
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

;;-----------------------------------------------------------------------------
;; TAKE Validation Tests
;;-----------------------------------------------------------------------------
print "===== STARTING TAKE VALIDATION ====="

; Test 1: Basic block behavior
blk: [apple banana cherry]
result: take blk
assert-equal 'apple result "Basic block: return value"
assert-equal [banana cherry] blk "Basic block: modified series"

; Test 2: Basic string behavior
str: "Rebol"
result: take str
assert-equal #"R" result "Basic string: return value"
assert-equal "ebol" str "Basic string: modified series"

; Test 3: Empty block handling
empty-blk: copy []
result: take empty-blk
assert-equal none result "Empty block: return value"
assert-equal [] empty-blk "Empty block: modified series"

; Test 4: /LAST with block
blk: [x y z]
result: take/last blk
assert-equal 'z result "/LAST block: return value"
assert-equal [x y] blk "/LAST block: modified series"

; Test 5: /LAST with string
str: "Hello"
result: take/last str
assert-equal #"o" result "/LAST string: return value"
assert-equal "Hell" str "/LAST string: modified series"

; Test 6: /PART with count
blk: [1 2 3 4 5]
result: take/part blk 2
assert-equal [1 2] result "/PART count: return value"
assert-equal [3 4 5] blk "/PART count: modified series"

; Test 7: /PART with position marker
str: "documentation"
mark: find str "c"  ; Position at "cumentation"
result: take/part str mark
assert-equal "do" result "/PART marker: return value"
assert-equal "cumentation" str "/PART marker: modified series"

; Test 8: /PART with /LAST
blk: [a b c d e]
result: take/part/last blk 2
assert-equal [d e] result "/PART/LAST: return value"
assert-equal [a b c] blk "/PART/LAST: modified series"

; Test 9: /DEEP nested block
blk: [outer [inner value] end]
result: take/deep next blk
assert-equal [inner value] result "/DEEP: return value"
assert-equal [outer end] blk "/DEEP: modified series"

; Test 10: /ALL with block
blk: [alpha beta gamma]
result: take/all blk
assert-equal [alpha beta gamma] result "/ALL block: return value"
assert-equal [] blk "/ALL block: modified series"

; Test 11: /ALL with string
str: "text"
result: take/all str
assert-equal "text" result "/ALL string: return value"
assert-equal "" str "/ALL string: modified series"

; Test 12: Take from none
result: take none
assert-equal none result "Take none: return value"

; Test 13: Over-length take
blk: [single]
result: take/part blk 3
assert-equal [single] result "Over-length take: return value"
assert-equal [] blk "Over-length take: modified series"

; Test 14: Modified series view
orig: [1 2 3 4]
view: next orig  ; [2 3 4]
result: take view
assert-equal 2 result "Modified view: return value"
assert-equal [1 3 4] orig "Modified view: original series"

;;-----------------------------------------------------------------------------
;; Test Summary
;;-----------------------------------------------------------------------------
print-test-summary
