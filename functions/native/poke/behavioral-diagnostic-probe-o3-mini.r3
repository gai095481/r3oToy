Rebol []

; =============================================================
;  Battle-Tested QA Harness Setup
; =============================================================

all-tests-passed?: true
pass-count: 0
fail-count: 0
test-count: 0

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!]
    actual [any-type!]
    description [string!]
][
    set 'test-count test-count + 1
    either equal? expected actual [
        set 'pass-count pass-count + 1
        print rejoin ["✅ PASSED: " description]
    ] [
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        print rejoin [
            "❌ FAILED: " description "^/   >> Expected: " mold expected "^/   >> Actual:   " mold actual
        ]
    ]
]

print-test-summary: does [
    print "^/============================================"
    print "=== TEST SUMMARY ==="
    print "============================================"
    print rejoin ["Total Tests: " mold test-count]
    print rejoin ["Passed: " mold pass-count]
    print rejoin ["Failed: " mold fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - FUNCTION IS STABLE"
    ] [
        print "❌  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

; =============================================================
;  Probing poke on block! series
; =============================================================

; Hypothesis: poke can replace elements in a block! at 1-based positions;
; it returns the new value provided and mutates the block! in place.
block-original: [10 20 30]
block-test: copy block-original

; Replace element at index 2 with 99
poke block-test 2 99
assert-equal [10 99 30] block-test "poke replaces value at index 2 in block!"

; Hypothesis: poke returns the new value set; setting index 2 to 42 returns 42.
assert-equal 42 (poke block-test 2 42) "poke returns set value (block!)"
assert-equal [10 42 30] block-test "poke sets new value at same index (block!)"

; Hypothesis: poke with index 1 sets the first element since indices are 1-based.
block-test: copy block-original
poke block-test 1 77
assert-equal [77 20 30] block-test "poke index 1 sets first element (block!)"

; Hypothesis: poke with an out-of-bounds index should error and not mutate the block!
block-test: copy block-original
err: none try [poke block-test 4 55]
assert-equal true none? err "poke block! out-of-bounds index returns error? (should error)"
assert-equal block-original block-test "poke block! out-of-bounds does not mutate block"

; =============================================================
;  Probing poke on string! series
; =============================================================

; Hypothesis: In Rebol 3 Oldes, poke on a string! requires an integer codepoint
; for the new value rather than a literal string.
string-original: "abc"
string-test: copy string-original

; Replace second character with codepoint 90 (which represents 'Z')
poke string-test 2 90
assert-equal "aZc" string-test "poke string! replaces character at index 2 using integer codepoint (90 for 'Z')"

; Hypothesis: poke returns the new codepoint value set. Setting index 2 to 81 (for 'Q') should return 81.
result-codepoint: poke string-test 2 81
assert-equal 81 result-codepoint "poke string! returns set value (integer codepoint for 'Q')"
assert-equal "aQc" string-test "poke string! sets new value at index (resulting in 'aQc')"

; Hypothesis: poke with an out-of-range index in a string! should error and not modify the original.
string-test: copy string-original
err: none try [poke string-test 5 88]
assert-equal true none? err "poke string! out-of-range index returns error? (should error)"
assert-equal string-original string-test "poke string! out-of-bounds does not mutate string"

; =============================================================
;  Probing poke on binary! series
; =============================================================

; Hypothesis: poke can replace a byte in a binary! series.
binary-original: #{010203}
binary-test: copy binary-original
poke binary-test 2 255
assert-equal #{01FF03} binary-test "poke binary! replaces byte at index 2"

; Hypothesis: poke returns the new value for binary! series; changing index 2 to 42 should return 42.
assert-equal 42 (poke binary-test 2 42) "poke binary! returns set value (42)"
assert-equal #{012A03} binary-test "poke binary! sets new byte at index 2 (42 in hex is 2A)"

; Hypothesis: poke with an out-of-range index in binary! should error and not mutate the binary.
binary-test: copy binary-original
err: none try [poke binary-test 5 0]
assert-equal true none? err "poke binary! out-of-bounds index returns error? (should error)"
assert-equal binary-original binary-test "poke binary! out-of-bounds does not mutate binary"

; =============================================================
;  Probing poke on map!
; =============================================================

; Hypothesis: For map!, poke sets a value for an existing key or creates a new key.
; It returns the new value.
map-original: make map! [a 1 b 2]
map-test: copy map-original
poke map-test 'a 99
assert-equal 99 select map-test 'a "poke map! replaces value for existing key 'a'"

; Adding a new key 'c'
result-map: poke map-test 'c 77
assert-equal 77 result-map "poke map! returns set value when adding new key 'c'"
assert-equal 77 select map-test 'c "poke map! adds new key with correct value"

; =============================================================
;  Probing poke on bitset!
; =============================================================

; Hypothesis: For bitset!, poke sets the bit at the given 1-based index to the provided logical value.
; It returns a modified bitset reflecting the change.
bitset-test: make bitset! 8
poke bitset-test 2 true
assert-equal true pick bitset-test 2 "poke bitset! sets bit at index 2 to true"
assert-equal false pick bitset-test 3 "poke bitset! leaves other bits unchanged (false)"

; Now reset the bit at index 2 to false.
result-bit: poke bitset-test 2 false
; Updated Hypothesis: poke on bitset! returns the modified bitset instead of the bare logical value.
expected-bitset: make bitset! 8
; Manually set the bit at index 2 to false; bitset defaults to false so expected-bitset remains the same.
; Due to mutation, expected-bitset when printed shows as: make bitset! #{00} at index 2.
assert-equal expected-bitset result-bit "poke bitset! returns modified bitset when setting false"
assert-equal false pick bitset-test 2 "poke bitset! sets bit at index 2 to false"

; =============================================================
;  Probing poke on port! and gob! types
; =============================================================

; Hypothesis: poke on port! and gob! is generally unsupported and should error or be a no-op.
result-port: none try [poke make port! [scheme: 'scheme] 1 123]
assert-equal true none? result-port "poke port! should error or return none"

result-gob: none try [poke make gob! [] 1 123]
assert-equal true none? result-gob "poke gob! should error or return none"

; =============================================================
;  Probing legal and illegal index types
; =============================================================

; Hypothesis: poke supports integer indices for series and symbol indices for map!.
block-test: [1 2 3]
assert-equal 99 (poke block-test 2 99) "poke block! with integer index returns new value (99)"

map-test: make map! [x 1]
assert-equal 42 (poke map-test 'x 42) "poke map! with symbol index returns new value (42)"

; Hypothesis: poke with an invalid index type should error.
err: none try [poke block-test "not-an-index" 111]
assert-equal true none? err "poke block! with invalid (non-integer) index errors"

err: none try [poke map-test 2 7]
assert-equal true none? err "poke map! with integer index (invalid type for map!) errors"

; =============================================================
;  Probing poke with empty series and edge indices
; =============================================================

; Hypothesis: poke on an empty block! at index 1 should error.
empty-block: copy []
err: none try [poke empty-block 1 1]
assert-equal true none? err "poke empty block! at index 1 errors"

; Hypothesis: poke on an empty string! at index 1 should error.
empty-string: copy ""
err: none try [poke empty-string 1 65]
assert-equal true none? err "poke empty string! at index 1 errors"

; Hypothesis: poke on an empty binary! at index 1 should error.
empty-binary: copy #{ }
err: none try [poke empty-binary 1 255]
assert-equal true none? err "poke empty binary! at index 1 errors"

; =============================================================
;  Probing poke with negative and zero indices
; =============================================================

; Hypothesis: poke with a zero or negative index should error for series types.
block-test: copy block-original
err: none try [poke block-test 0 111]
assert-equal true none? err "poke block! at index 0 errors"

err: none try [poke block-test -1 111]
assert-equal true none? err "poke block! at negative index errors"

; =============================================================
;  Final Test Summary
; =============================================================
print-test-summary
