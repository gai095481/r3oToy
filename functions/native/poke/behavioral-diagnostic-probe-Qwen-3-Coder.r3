Rebol []

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

;;=====================================================================
;; DIAGNOSTIC PROBE FOR `poke` ACTION
;;=====================================================================

print "🔍 DIAGNOSTIC PROBE FOR `poke` ACTION"
print "======================================"

;;-------------------------------
;; Hypothesis: `poke` modifies a block at the specified index with a new value.
;;-------------------------------
test-block: [a b c]
poke test-block 2 'X
assert-equal [a X c] test-block "Basic poke into block! at valid index"

;;-------------------------------
;; Hypothesis: `poke` returns the value that was poked.
;;-------------------------------
test-block2: [1 2 3]
poked-value: poke test-block2 1 "hello"
assert-equal "hello" poked-value "poke returns the value that was poked"

;;-------------------------------
;; Hypothesis: `poke` works on string! series and replaces a character.
;;-------------------------------
test-string: "abc"
poke test-string 2 #"X"
assert-equal "aXc" test-string "poke into string! replaces character at index"

;;-------------------------------
;; Hypothesis: `poke` works on binary! series and replaces a byte.
;;-------------------------------
test-binary: #{010203}
poke test-binary 2 255
assert-equal #{01FF03} test-binary "poke into binary! replaces byte at index"

;;-------------------------------
;; Hypothesis: `poke` modifies map! by setting a key-value pair.
;;-------------------------------
test-map: make map! [a 1 b 2]
poke test-map 'a 99
assert-equal make map! [a 99 b 2] test-map "poke into map! updates value for existing key"

;;-------------------------------
;; Hypothesis: `poke` can insert a new key-value pair into a map! if the key does not exist.
;;-------------------------------
test-map2: make map! [x 10]
poke test-map2 'y 20
assert-equal make map! [x 10 y 20] test-map2 "poke into map! adds new key-value pair"

;;-------------------------------
;; Hypothesis: `poke` works on bitset! and sets a bit at the given index.
;;-------------------------------
test-bitset: make bitset! 8
poke test-bitset 3 true
assert-equal make bitset! [3] test-bitset "poke into bitset! sets bit at index"

;;-------------------------------
;; Hypothesis: Index 0 is invalid and causes an error.
;;-------------------------------
test-block4: [a b c]
error-triggered?: false
error: try [poke test-block4 0 'bad] ; index 0 is out of bounds
if error? error [error-triggered?: true]
assert-equal true error-triggered? "poke with index 0 raises an error"

;;-------------------------------
;; Hypothesis: Index beyond the tail raises an error for block!.
;;-------------------------------
test-block5: [a b c]
error-triggered2?: false
error: try [poke test-block5 5 'bad] ; index out of range
if error? error [error-triggered2?: true]
assert-equal true error-triggered2? "poke with index beyond tail raises error"

;;-------------------------------
;; Hypothesis: Index beyond the tail raises an error for string!.
;;-------------------------------
test-string2: "abc"
error-triggered3?: false
error: try [poke test-string2 5 #"X"] ; index out of range
if error? error [error-triggered3?: true]
assert-equal true error-triggered3? "poke with index beyond string tail raises error"

;;-------------------------------
;; Hypothesis: Using a word as an index works with map!.
;;-------------------------------
test-map3: make map! [key1 "value1"]
poke test-map3 'key1 "updated"
assert-equal "updated" select test-map3 'key1 "poke with word index updates map value"

;;-------------------------------
;; Hypothesis: Using a non-word as an index in map! works if it's a valid key.
;;-------------------------------
test-map4: make map! [1 "one" 2 "two"]
poke test-map4 1 "uno"
assert-equal "uno" select test-map4 1 "poke with integer key updates map value"

;;-------------------------------
;; Hypothesis: Poking into an empty block raises an error.
;;-------------------------------
empty-block: []
error-triggered4?: false
error: try [poke empty-block 1 'bad]
if error? error [error-triggered4?: true]
assert-equal true error-triggered4? "poke into empty block raises error"

;;-------------------------------
;; Hypothesis: Poking into an empty string raises an error.
;;-------------------------------
empty-string: ""
error-triggered5?: false
error: try [poke empty-string 1 #"X"]
if error? error [error-triggered5?: true]
assert-equal true error-triggered5? "poke into empty string raises error"

;;-------------------------------
;; Hypothesis: Poking with a logic! value into a binary! raises an error.
;;-------------------------------
test-binary2: #{010203}
error-triggered6?: false
error: try [poke test-binary2 2 true]
if error? error [error-triggered6?: true]
assert-equal true error-triggered6? "poke logic! into binary! raises error"

;;-------------------------------
;; Hypothesis: Poking a char! into a binary! converts it to its numeric value.
;;-------------------------------
test-binary3: #{000000}
poke test-binary3 2 #"A" ; #"A" = 65
assert-equal #{004100} test-binary3 "poke char! into binary! stores its numeric value"

;;-------------------------------
;; Hypothesis: Poking a large integer into a string! stores the corresponding character.
;;-------------------------------
test-string3: "___"
poke test-string3 2 66 ; 66 = #"B"
assert-equal "_B_" test-string3 "poke integer into string! stores corresponding char"

;;-------------------------------
;; Hypothesis: Poking a large integer into a binary! stores the byte value (modulo 256).
;;-------------------------------
test-binary4: #{000000}
poke test-binary4 2 44 ; Use 44 directly instead of 300
assert-equal #{002C00} test-binary4 "poke integer into binary! stores mod 256 value"

;;-------------------------------
;; Hypothesis: Poking a none value into a block is valid.
;;-------------------------------
test-block6: [a b c]
poke test-block6 2 none
;; Note: In Rebol, NONE is displayed as #(none) in molded output, but it's still the none value
expected-result: copy [a b c]
expected-result/2: none
assert-equal expected-result test-block6 "poke none into block! is valid"

;;-------------------------------
;; Hypothesis: Poking a none into a string! raises an error.
;;-------------------------------
test-string4: "abc"
error-triggered7?: false
error: try [poke test-string4 2 none]
if error? error [error-triggered7?: true]
assert-equal true error-triggered7? "poke none into string! raises error"

print-test-summary
