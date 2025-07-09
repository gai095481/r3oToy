Rebol []

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

; Probing Basic Behavior with Block Series
;
; Hypothesis: PUT replaces the value following a key in a block and returns the new value.
test-block-initial: [a 1 b 2]
test-block-basic: copy test-block-initial
assert-equal 3 put test-block-basic 'a 3 "Basic PUT returns new value"
assert-equal [a 3 b 2] test-block-basic "Block is modified after PUT"

; Probing /case Refinement
;
; Hypothesis: /case makes key lookup case-sensitive.

; Test 1: Uppercase key exists
test-block-case1-initial: [A 1 a 2]
test-block-case1: copy test-block-case1-initial
assert-equal 3 put/case test-block-case1 'A 3 "PUT /case with uppercase key replaces value"
assert-equal [A 3 a 2] test-block-case1 "Block modified"

; Test 2: Lowercase key exists
test-block-case2-initial: [A 1 a 2]
test-block-case2: copy test-block-case2-initial
assert-equal 4 put/case test-block-case2 'a 4 "PUT /case with lowercase key replaces value"
assert-equal [A 1 a 4] test-block-case2 "Block modified"

; Probing /skip Refinement
;
; Hypothesis: /skip treats the series as fixed-size records.

; Test 1: /skip with size 2
test-block-skip-initial: [k1 v1 k2 v2]
test-block-skip: copy test-block-skip-initial
assert-equal 100 put/skip test-block-skip 'k2 100 2 "PUT /skip 2 replaces value in record"
assert-equal [k1 v1 k2 100] test-block-skip "Block modified with /skip 2"

; Test 2: /skip with size 3
test-block-skip3-initial: [k1 v1 extra k2 v2 extra]
test-block-skip3: copy test-block-skip3-initial
assert-equal 200 put/skip test-block-skip3 'k2 200 3 "PUT /skip 3 replaces value in record"
assert-equal [k1 v1 extra k2 200 extra] test-block-skip3 "Block modified with /skip 3"

; Probing Object Series
;
; Hypothesis: PUT on an object sets the object's field.
test-object-initial: make object! [a: 1 b: 2]
test-object: copy test-object-initial
assert-equal 3 put test-object 'a 3 "PUT on object returns new value"
assert-equal 3 test-object/a "Object's field is updated"

; Probing Edge Cases
;
; Hypothesis: PUT appends key-value if key not found in block.
test-block-empty-initial: []
test-block-empty: copy test-block-empty-initial
assert-equal 10 put test-block-empty 'a 10 "PUT on empty block adds key-value"
assert-equal [a 10] test-block-empty "Empty block becomes [a 10]"

; Hypothesis: PUT adds new key-value when key is not present.
test-block-missing-initial: [a 1]
test-block-missing: copy test-block-missing-initial
assert-equal 2 put test-block-missing 'b 2 "PUT adds new key-value when key not found"
assert-equal [a 1 b 2] test-block-missing "Block appended with new key-value"

; Hypothesis: PUT can set value to zero.
test-block-zero-initial: [a 5]
test-block-zero: copy test-block-zero-initial
assert-equal 0 put test-block-zero 'a 0 "PUT can set value to zero"
assert-equal [a 0] test-block-zero "Block has a 0"

; Print test summary
print-test-summary
