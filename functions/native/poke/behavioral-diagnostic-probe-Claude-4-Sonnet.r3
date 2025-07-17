Rebol [
    Title: "Diagnostic Probe Script for POKE Function"
    Purpose: "Comprehensive testing of poke function behavior across all supported data types"
    Author: "AI Assistant"
    Date: 17-Jul-2025
    Version: 1.0.0
]

print "^/=== DIAGNOSTIC PROBE: POKE FUNCTION ==="
print "Target: REBOL/Bulk 3.19.0 (Oldes Branch)"
print "Purpose: Systematically test poke behavior across all supported data types^/"

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
        print "✅ ALL TESTS PASSED - POKE IS STABLE"
    ][
        print "⚠️  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; SECTION 1: PROBING BASIC POKE BEHAVIOR WITH BLOCKS
;;=============================================================================

print "^/--- SECTION 1: PROBING BASIC POKE BEHAVIOR WITH BLOCKS ---"

;; HYPOTHESIS: poke should replace elements in blocks at 1-based indices
;; and return the new value that was inserted

test-block: [a b c d e]
original-block: copy test-block
result: poke test-block 3 'X
assert-equal 'X result "poke should return the new value"
assert-equal [a b X d e] test-block "poke should modify block in place at index 3"

;; HYPOTHESIS: poke should work with index 1 (first element)
test-block: [a b c]
result: poke test-block 1 'FIRST
assert-equal 'FIRST result "poke at index 1 should return new value"
assert-equal [FIRST b c] test-block "poke should replace first element"

;; HYPOTHESIS: poke should work with last valid index
test-block: [a b c]
result: poke test-block 3 'LAST
assert-equal 'LAST result "poke at last index should return new value"
assert-equal [a b LAST] test-block "poke should replace last element"

;; HYPOTHESIS: poke with different value types should work
test-block: [a b c]
result: poke test-block 2 42
assert-equal 42 result "poke with integer should return the integer"
assert-equal [a 42 c] test-block "poke should accept integer values"

test-block: [a b c]
result: poke test-block 2 "string"
assert-equal "string" result "poke with string should return the string"
assert-equal [a "string" c] test-block "poke should accept string values"

test-block: [a b c]
result: poke test-block 2 [nested block]
assert-equal [nested block] result "poke with block should return the block"
assert-equal [a [nested block] c] test-block "poke should accept block values"

;;=============================================================================
;; SECTION 2: PROBING POKE BEHAVIOR WITH STRINGS
;;=============================================================================

print "^/--- SECTION 2: PROBING POKE BEHAVIOR WITH STRINGS ---"

;; HYPOTHESIS: poke should replace characters in strings at 1-based indices
;; and return the new character that was inserted

test-string: "hello"
result: poke test-string 3 #"X"
assert-equal #"X" result "poke on string should return the new character"
assert-equal "heXlo" test-string "poke should modify string in place"

;; HYPOTHESIS: poke should work with first character
test-string: "hello"
result: poke test-string 1 #"H"
assert-equal #"H" result "poke at string index 1 should return new char"
assert-equal "Hello" test-string "poke should replace first character"

;; HYPOTHESIS: poke should work with last character
test-string: "hello"
result: poke test-string 5 #"!"
assert-equal #"!" result "poke at string last index should return new char"
assert-equal "hell!" test-string "poke should replace last character"

;; HYPOTHESIS: poke should accept integer values for characters (ASCII codes)
test-string: "hello"
result: poke test-string 3 65  ; ASCII code for 'A'
assert-equal 65 result "poke with ASCII code should return the integer"
assert-equal "heAlo" test-string "poke should convert ASCII code to character"

;;=============================================================================
;; SECTION 3: PROBING POKE BEHAVIOR WITH MAPS
;;=============================================================================

print "^/--- SECTION 3: PROBING POKE BEHAVIOR WITH MAPS ---"

;; HYPOTHESIS: poke should set/replace key-value pairs in maps
;; using the key as the index and return the new value

test-map: make map! [name: "John" age: 30]
result: poke test-map 'name "Jane"
assert-equal "Jane" result "poke on map should return the new value"
assert-equal "Jane" select test-map 'name "poke should update existing key in map"

;; HYPOTHESIS: poke should add new key-value pairs to maps
test-map: make map! [name: "John"]
result: poke test-map 'city "New York"
assert-equal "New York" result "poke with new key should return the value"
assert-equal "New York" select test-map 'city "poke should add new key to map"

;; HYPOTHESIS: poke should work with string keys in maps
test-map: make map! ["name" "John"]
result: poke test-map "name" "Jane"
assert-equal "Jane" result "poke with string key should return the value"
assert-equal "Jane" select test-map "name" "poke should work with string keys"

;; HYPOTHESIS: poke should work with integer keys in maps
test-map: make map! [1 "first" 2 "second"]
result: poke test-map 1 "updated"
assert-equal "updated" result "poke with integer key should return the value"
assert-equal "updated" select test-map 1 "poke should work with integer keys"

;;=============================================================================
;; SECTION 4: PROBING POKE BEHAVIOR WITH BINARY DATA
;;=============================================================================

print "^/--- SECTION 4: PROBING POKE BEHAVIOR WITH BINARY DATA ---"

;; HYPOTHESIS: poke should replace bytes in binary data at 1-based indices
;; and return the new byte value

test-binary: #{48656C6C6F}  ; "Hello" in hex
result: poke test-binary 3 108  ; 'l' in decimal (0x6C)
assert-equal 108 result "poke on binary should return the new byte value"
assert-equal #{48656C6C6F} test-binary "poke should modify binary in place"

;; HYPOTHESIS: poke should work with first byte
test-binary: #{48656C6C6F}  ; "Hello"
result: poke test-binary 1 72  ; 'H' in decimal (0x48)
assert-equal 72 result "poke at binary index 1 should return new byte"
assert-equal #{48656C6C6F} test-binary "poke should replace first byte"

;; HYPOTHESIS: poke should work with byte values (0-255 integers only)
test-binary: #{48656C6C6F}
result: poke test-binary 2 101  ; 'e' in decimal (0x65)
assert-equal 101 result "poke with integer byte should return the integer"
assert-equal #{48656C6C6F} test-binary "poke should accept integer byte values (0-255)"

;;=============================================================================
;; SECTION 5: PROBING POKE EDGE CASES AND ERROR CONDITIONS
;;=============================================================================

print "^/--- SECTION 5: PROBING POKE EDGE CASES AND ERROR CONDITIONS ---"

;; HYPOTHESIS: poke with index 0 should cause an error
test-block: [a b c]
set/any 'error-result try [poke test-block 0 'X]
assert-equal true error? error-result "poke with index 0 should cause an error"

;; HYPOTHESIS: poke with negative index should cause an error
test-block: [a b c]
set/any 'error-result try [poke test-block -1 'X]
assert-equal true error? error-result "poke with negative index should cause an error"

;; HYPOTHESIS: poke with index beyond series length should cause an error
test-block: [a b c]
set/any 'error-result try [poke test-block 5 'X]
assert-equal true error? error-result "poke beyond series length should cause an error"

;; HYPOTHESIS: poke with none as value should work (setting to none)
test-block: [a b c]
result: poke test-block 2 none
assert-equal none result "poke with none value should return none"
assert-equal [a #(none) c] test-block "poke should accept none as value"

;; HYPOTHESIS: poke with empty block should cause an error
empty-block: []
set/any 'error-result try [poke empty-block 1 'X]
assert-equal true error? error-result "poke on empty block should cause an error"

;; HYPOTHESIS: poke should reject binary values as invalid arguments
test-binary: #{48656C6C6F}
set/any 'error-result try [poke test-binary 2 #{65}]
assert-equal true error? error-result "poke with binary value should cause an error"

;;=============================================================================
;; SECTION 6: PROBING POKE BEHAVIOR WITH DIFFERENT INDEX TYPES
;;=============================================================================

print "^/--- SECTION 6: PROBING POKE BEHAVIOR WITH DIFFERENT INDEX TYPES ---"

;; HYPOTHESIS: poke with empty string should cause an error
empty-string: ""
set/any 'error-result try [poke empty-string 1 #"X"]
assert-equal true error? error-result "poke on empty string should cause an error"

;; HYPOTHESIS: poke should work with decimal indices (truncated to integers)
test-block: [a b c d]
result: poke test-block 2.7 'X
assert-equal 'X result "poke with decimal index should return the value"
assert-equal [a X c d] test-block "poke should truncate decimal index to integer"

;; HYPOTHESIS: poke should work with logic values as indices for maps
test-map: make map! [true: "yes" false: "no"]
result: poke test-map true "YES"
assert-equal "YES" result "poke with logic key should return the value"
assert-equal "YES" select test-map true "poke should work with logic keys"

;; HYPOTHESIS: poke with word as index should work for maps
test-map: make map! []
result: poke test-map 'test-key "test-value"
assert-equal "test-value" result "poke with word index should return the value"
assert-equal "test-value" select test-map 'test-key "poke should work with word indices"

;;=============================================================================
;; SECTION 7: PROBING POKE RETURN VALUE CONSISTENCY
;;=============================================================================

print "^/--- SECTION 7: PROBING POKE RETURN VALUE CONSISTENCY ---"

;; HYPOTHESIS: poke should always return the exact value that was assigned
;; regardless of data type conversions that might occur internally

test-block: [a b c]
test-value: 'special-symbol
result: poke test-block 2 test-value
assert-equal true same? result test-value "poke should return the exact same value reference"

test-string: "hello"
test-char: #"X"
result: poke test-string 3 test-char
assert-equal true same? result test-char "poke should return the exact same character reference"

test-map: make map! [key: "value"]
test-new-value: "new-value"
result: poke test-map 'key test-new-value
assert-equal true same? result test-new-value "poke should return the exact same value reference for maps"

;;=============================================================================
;; SECTION 8: PROBING POKE MODIFICATION BEHAVIOR
;;=============================================================================

print "^/--- SECTION 8: PROBING POKE MODIFICATION BEHAVIOR ---"

;; HYPOTHESIS: poke should work with series that are references to the same data
block-one: [a b c]
block-two: block-one
poke block-one 1 'CHANGED
assert-equal [CHANGED b c] block-two "poke should affect all references to the same series"

;; HYPOTHESIS: poke should work with series at different positions
test-block: [a b c d e]
block-at-position: next test-block  ; starts at 'b
result: poke block-at-position 1 'REPLACED  ; should replace 'b
assert-equal 'REPLACED result "poke on positioned series should return the value"
assert-equal [a REPLACED c d e] test-block "poke should work relative to series position"

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
prin lf
print-test-summary
