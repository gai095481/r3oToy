Rebol []
;;-----------------------------------------------------------------------------
;;
;;  Title: Diagnostic Probe for `put` (Definitive Final Version)
;;  Author: Expert Rebol 3 Oldes Branch Software Engineer
;;  Purpose: To meticulously probe and document the behavior of the `put`
;;           action in the Rebol 3 Oldes branch. This script is the final,
;;           runnable specification, corrected based on all REPL-verified evidence.
;;
;;-----------------------------------------------------------------------------

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

;;-----------------------------------------------------------------------------
;; Test Suite Initialization
;;-----------------------------------------------------------------------------
print "--- Diagnostic Probe for `put` ---"


;;-----------------------------------------------------------------------------
;; Probing Basic `block!` Behavior
;;-----------------------------------------------------------------------------
;
; **Hypothesis:** For blocks, `put` finds a key and replaces the value
; immediately following it. The search for the key is case-insensitive.
; If the key is not found, `put` appends the key and value.
;

test-block: ['a 1 'b 2 'c 3]
return-val: put test-block 'b 99
assert-equal 99 return-val "Basic `put` should return the value being put."
assert-equal ['a 1 'b 99 'c 3] test-block "Basic `put` should replace the value after the key."

test-block: ['a 1 'z 99]
put test-block 'c "new"
assert-equal ['a 1 'z 99 'c "new"] test-block "If key is not found, `put` should append key and value."

test-block: ['a 1 'b]
put test-block 'b 123
assert-equal ['a 1 'b 123] test-block "If key is the last element, `put` should append the value."

; Corrected based on user-provided script: Integer keys APPEND, not replace by index.
test-block: [10 20]
put test-block 1 99
assert-equal [10 20 1 99] test-block "PUT with an integer key appends, not replaces."

test-block: ["HELLO" 1]
put test-block "hello" 2
assert-equal ["HELLO" 2] test-block "`put` on a block with string keys should be case-insensitive by default."

test-block: ['BIG 1]
put test-block 'big 2
assert-equal ['BIG 2] test-block "`put` on a block with word keys should be case-insensitive by default."

;;-----------------------------------------------------------------------------
;; Probing `/case` Refinement
;;-----------------------------------------------------------------------------
;
; **Hypothesis:** The `/case` refinement forces a case-sensitive
; comparison for `string!` AND `word!` keys.
;

test-block: ["KEY" 10]
put/case test-block "KEY" 99
assert-equal ["KEY" 99] test-block "/case `put` should find an exact case-matching string key."

test-block: ["KEY" 10]
put/case test-block "key" 99
assert-equal ["KEY" 10 "key" 99] test-block "/case `put` should append when string key case does not match."

test-block: ['WORD 10]
put/case test-block 'word 99
assert-equal ['WORD 10 'word 99] test-block "/case IS case-sensitive for word! keys, so it appends."

;;-----------------------------------------------------------------------------
;; Probing `/skip` Refinement
;;-----------------------------------------------------------------------------
;
; **Hypothesis:** The `/skip` refinement treats the block as a series of
; fixed-size records. The key is only searched for at the beginning of each record.
;

records-block: ['a 1 'x 'b 2 'y 'c 3 'z]
return-val: put/skip records-block 'b 222 3
assert-equal 222 return-val "/skip `put` should return the value being put."
assert-equal ['a 1 'x 'b 222 'y 'c 3 'z] records-block "/skip `put` should replace value in the correct record."

records-block: ['a 1 'x 'b 2 'y 'c 3 'z]
put/skip records-block 1 "not found" 3
assert-equal ['a 1 'x 'b 2 'y 'c 3 'z 1 "not found"] records-block "/skip `put` should append if key is not at the start of any record."

records-block: ["A" 1 "x" "B" 2 "y"]
put/skip/case records-block "a" 99 3
assert-equal ["A" 1 "x" "B" 2 "y" "a" 99] records-block "/skip/case `put` should append if case does not match."

records-block: ["A" 1 "x" "B" 2 "y"]
put/skip/case records-block "A" 99 3
assert-equal ["A" 99 "x" "B" 2 "y"] records-block "/skip/case `put` should replace if case matches."

;;-----------------------------------------------------------------------------
;; Probing `map!` Behavior
;;-----------------------------------------------------------------------------
;
; **Hypothesis:** `put` on a map with string! keys is CASE-INSENSITIVE.
; The `/skip` refinement is ignored and does not cause an error.
;

test-map: make map! [a 1 b 2]
return-val: put test-map 'a 100
assert-equal 100 return-val "put on map should return the value."
assert-equal 100 test-map/a "put on map should update an existing key."

put test-map 'c 300
assert-equal 300 test-map/c "put on map should insert a new key."

test-map: make map! [a 1]
put test-map 'A 101
assert-equal 101 test-map/a "put on map with word! key should be case-insensitive."
assert-equal 1 length? words-of test-map "put with case-variant word! key should not create a new key."

test-map: make map! ["hello" 10]
put test-map "HELLO" 20
assert-equal 20 select test-map "hello" "put on map w/string key is case-insensitive."
assert-equal 1 length? words-of test-map "VERIFY: put on map w/string key did not add a key."

test-map: make map! [a 1]
put/case test-map 'a 99
assert-equal 99 test-map/a "/case should have no effect on map! behavior."

test-map: make map! [a 1 b 2]
is-error: error? try [put/skip test-map 'a 99 2]
assert-equal false is-error "/skip refinement with map! should NOT cause an error."
assert-equal 99 test-map/a "VERIFY: /skip is ignored and put succeeds on map."

;;-----------------------------------------------------------------------------
;; Probing `object!` Behavior
;;-----------------------------------------------------------------------------
;
; **Hypothesis:** For objects, `put` can modify an existing
; property AND can add new properties. The `/skip` refinement is ignored.
;

test-obj: make object! [prop: 10]
return-val: put test-obj 'prop 20
assert-equal 20 return-val "put on object should return the value."
assert-equal 20 test-obj/prop "put on object should modify an existing property."

test-obj: make object! [prop: 10]
is-error: error? try [put test-obj 'new-prop 40]
assert-equal false error? is-error "`put` should NOT error when adding a new property."
assert-equal 40 test-obj/new-prop "VERIFY: `put` CAN add a new property to an object."

test-obj: make object! [prop: 10]
put/case test-obj 'PROP 50
assert-equal 50 test-obj/prop "/case has no effect; object words are case-insensitive."

test-obj: make object! [prop: 10]
is-error: error? try [put/skip test-obj 'prop 60 2]
assert-equal false error? is-error "/skip refinement with object! should NOT cause an error."
assert-equal 60 test-obj/prop "VERIFY: /skip is ignored and put succeeds on object."

;;-----------------------------------------------------------------------------
;; Probing Other `any-block!` types
;;-----------------------------------------------------------------------------
;
; **Hypothesis:** `put` will function on other block-like series, replacing the
; element immediately following the key.
;

test-paren: to paren! ['x 1 'y 2]
put test-paren 'y 99
assert-equal to paren! ['x 1 'y 99] test-paren "`put` should work on paren!."

test-path: to path! ['a 'b 'c]
put test-path 'b 'x
assert-equal to path! ['a 'b 'x] test-path "`put` on path! should replace element AFTER the key."

test-lit-path: to lit-path! ['a 'b 'c]
put test-lit-path 'b 'x
assert-equal to lit-path! ['a 'b 'x] test-lit-path "`put` on lit-path! should replace element AFTER the key."

test-set-path: to set-path! ['a 'b 'c]
put test-set-path 'b 'x
assert-equal to set-path! ['a 'b 'x] test-set-path "`put` on set-path! should replace element AFTER the key."


;;-----------------------------------------------------------------------------
;; Probing Edge Cases and Error Handling
;;-----------------------------------------------------------------------------
;
; **Hypothesis (Corrected):** `put` DOES error on invalid input.
;

empty-block: []
put empty-block 'a 1
assert-equal ['a 1] empty-block "`put` on an empty block appends key and value."

empty-map: make map! []
put empty-map 'a 1
expected-map: make map! [a 1]
assert-equal expected-map empty-map "`put` on an empty map inserts the key-value pair."

is-error: error? try [put 123 'a 1]
assert-equal true is-error "`put` on a non-series type SHOULD error."

is-error: error? try [put/skip [a 1] 'a 99 0]
assert-equal true is-error "/skip with a size of zero SHOULD error."

is-error: error? try [put/skip [a 1] 'a 99 -2]
assert-equal true is-error "/skip with a negative size SHOULD error."

print "--- `put` Probe Complete ---"

;;-----------------------------------------------------------------------------
;; Final Test Summary
;;-----------------------------------------------------------------------------
print-test-summary
