Rebol [
    Title: "Fixed PUT Function Diagnostic Probe Script"
    Date: 9-Jul-2025
    Author: "Claude 4 Sonnet fixed by Lutra AI"
    Purpose: "Comprehensive diagnostic tests for the PUT function based on actual behavior"
]

;;-----------------------------------------------------------------------------
;; Battle-Tested QA Harness Helper Functions
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
            description
            "^/ >> Expected: " mold expected
            "^/ >> Actual: " mold actual
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
;; PUT Function Diagnostic Probe Script
;;-----------------------------------------------------------------------------
print "^/🔍 PUT Function Diagnostic Probe Script"
print "=========================================="

;;-----------------------------------------------------------------------------
;; Section 1: Basic PUT Behavior with Blocks
;;-----------------------------------------------------------------------------
print "^/📋 Section 1: Basic PUT Behavior with Blocks"
print "----------------------------------------------"

; Test basic PUT with existing keys
test-block: [key1 "value1" key2 "value2"]
result1: put test-block 'key1 "new-value1"
assert-equal "new-value1" result1 "PUT should return the new value inserted"
assert-equal [key1 "new-value1" key2 "value2"] test-block "PUT should modify the original block in place"

; Test PUT with string keys
test-block2: ["name" "John" "age" 30]
result2: put test-block2 "name" "Jane"
assert-equal "Jane" result2 "PUT should return new value with string key"
assert-equal ["name" "Jane" "age" 30] test-block2 "PUT should modify block with string key"

; Test PUT with integer keys - CORRECTED: PUT with integer keys appends, doesn't replace at index
test-block3: [10 20 30 40]
result3: put test-block3 2 99
assert-equal 99 result3 "PUT should return new value with integer key"
; FIXED: PUT with integer key appends key-value pair, doesn't replace at index
assert-equal [10 20 30 40 2 99] test-block3 "PUT with integer key appends key-value pair"

;;-----------------------------------------------------------------------------
;; Section 2: PUT with New Keys
;;-----------------------------------------------------------------------------
print "^/🆕 Section 2: PUT with New Keys"
print "--------------------------------"

test-block4: [existing-key "existing-value"]
result4: put test-block4 'new-key "new-value"
assert-equal "new-value" result4 "PUT should return new value for new key"
assert-equal [existing-key "existing-value" new-key "new-value"] test-block4 "PUT should append new key-value pair"

test-block5: ["old" "data"]
result5: put test-block5 "fresh" "content"
assert-equal "content" result5 "PUT should return new value for new string key"
assert-equal ["old" "data" "fresh" "content"] test-block5 "PUT should append new string key-value pair"

;;-----------------------------------------------------------------------------
;; Section 3: PUT with Maps
;;-----------------------------------------------------------------------------
print "^/🗺️ Section 3: PUT with Maps"
print "----------------------------"

test-map: make map! [key1 "value1" key2 "value2"]
result6: put test-map 'key1 "updated-value1"
assert-equal "updated-value1" result6 "PUT should return new value in map"
assert-equal "updated-value1" select test-map 'key1 "PUT should modify map value"

result7: put test-map 'key3 "value3"
assert-equal "value3" result7 "PUT should return new value for new map key"
assert-equal "value3" select test-map 'key3 "PUT should add new key to map"

;;-----------------------------------------------------------------------------
;; Section 4: PUT with Objects
;;-----------------------------------------------------------------------------
print "^/🎯 Section 4: PUT with Objects"
print "-------------------------------"

test-obj: make object! [field1: "value1" field2: "value2"]
result8: put test-obj 'field1 "new-value1"
assert-equal "new-value1" result8 "PUT should return new value for object field"
assert-equal "new-value1" test-obj/field1 "PUT should modify object field"

;;-----------------------------------------------------------------------------
;; Section 5: PUT /case Refinement
;;-----------------------------------------------------------------------------
print "^/🔠 Section 5: PUT /case Refinement"
print "----------------------------------"

test-case-block: ["Key" "value1" "KEY" "value2"]
result9: put/case test-case-block "Key" "new-value"
assert-equal "new-value" result9 "PUT/case should return new value"
assert-equal ["Key" "new-value" "KEY" "value2"] test-case-block "PUT/case should be case-sensitive"

test-case-block2: ["Key" "value1" "KEY" "value2"]
result10: put test-case-block2 "key" "updated"
assert-equal "updated" result10 "PUT without /case should return new value"
assert-equal ["Key" "updated" "KEY" "value2"] test-case-block2 "PUT without /case should be case-insensitive"

;;-----------------------------------------------------------------------------
;; Section 6: PUT /skip Refinement - CORRECTED
;;-----------------------------------------------------------------------------
print "^/⏭️ Section 6: PUT /skip Refinement"
print "----------------------------------"

; FIXED: PUT/skip operates on records - corrected the expected behavior
test-skip-block: [
    "record1" "field1" "value1"
    "record2" "field2" "value2"
    "record3" "field3" "value3"
]
result11: put/skip test-skip-block "field2" "new-value2" 3
assert-equal "new-value2" result11 "PUT/skip should return new value"
; FIXED: PUT/skip appends at end when key not found in records
expected-skip-result: [
    "record1" "field1" "value1"
    "record2" "field2" "value2"
    "record3" "field3" "value3" "field2" "new-value2"
]
assert-equal expected-skip-result test-skip-block "PUT/skip appends when key not found in records"

;;-----------------------------------------------------------------------------
;; Section 7: PUT Edge Cases - CORRECTED
;;-----------------------------------------------------------------------------
print "^/⚠️ Section 7: PUT Edge Cases"
print "-----------------------------"

empty-block: []
result12: put empty-block 'key "value"
assert-equal "value" result12 "PUT should return value when adding to empty block"
assert-equal [key "value"] empty-block "PUT should add to empty block"

test-none-block: [key1 "value1"]
result13: put test-none-block 'key2 none
assert-equal none result13 "PUT should return none when inserting none"
; FIXED: none values are serialized as #(none) in Rebol 3
assert-equal [key1 "value1" key2 #(none)] test-none-block "PUT handles none values as #(none)"

test-block-value: [key1 "value1"]
test-nested-block: [a b c]
result14: put test-block-value 'key2 test-nested-block
assert-equal test-nested-block result14 "PUT should return block value"
assert-equal [key1 "value1" key2 [a b c]] test-block-value "PUT should handle block values"

;;-----------------------------------------------------------------------------
;; Section 8: PUT with Different Value Types
;;-----------------------------------------------------------------------------
print "^/🔢 Section 8: PUT with Different Value Types"
print "---------------------------------------------"

test-types-block: []
put test-types-block 'int-key 42
put test-types-block 'decimal-key 3.14
put test-types-block 'logic-key true
put test-types-block 'word-key 'symbol

assert-equal 42 select test-types-block 'int-key "PUT should handle integer values"
assert-equal 3.14 select test-types-block 'decimal-key "PUT should handle decimal values"
assert-equal true select test-types-block 'logic-key "PUT should handle logic values"
assert-equal 'symbol select test-types-block 'word-key "PUT should handle word values"

;;-----------------------------------------------------------------------------
;; Section 9: PUT Return Value Consistency
;;-----------------------------------------------------------------------------
print "^/🔄 Section 9: PUT Return Value Consistency"
print "------------------------------------------"

test-consistency-block: []
test-value: "test-string"
result15: put test-consistency-block 'key test-value
assert-equal test-value result15 "PUT should return exact value inserted"

test-series-value: [1 2 3]
result16: put test-consistency-block 'series-key test-series-value
assert-equal test-series-value result16 "PUT should return same reference for series values"

test-block-ref: [x y z]
result17: put test-consistency-block 'block-key test-block-ref
assert-equal test-block-ref result17 "PUT should return exact block reference"
assert-equal same? test-block-ref result17 true "PUT should return same block reference"

;;-----------------------------------------------------------------------------
;; Section 10: PUT with Index-Based Access - CORRECTED
;;-----------------------------------------------------------------------------
print "^/📍 Section 10: PUT with Index-Based Access"
print "------------------------------------------"

test-index-block: ["first" "second" "third" "fourth"]
result18: put test-index-block 3 "THIRD"
assert-equal "THIRD" result18 "PUT should return new value at index"
; FIXED: PUT with integer index appends key-value pair, doesn't replace at index
assert-equal ["first" "second" "third" "fourth" 3 "THIRD"] test-index-block "PUT with integer index appends key-value pair"

; Test extending series - CORRECTED
test-extend-block: ["a" "b"]
result19: put test-extend-block 5 "e"
assert-equal "e" result19 "PUT should return value when extending series"
; FIXED: PUT doesn't extend series with none padding, just appends key-value
assert-equal ["a" "b" 5 "e"] test-extend-block "PUT appends key-value pair, doesn't extend with padding"

;;-----------------------------------------------------------------------------
;; Final Test Summary
;;-----------------------------------------------------------------------------
print-test-summary

;;-----------------------------------------------------------------------------
;; PUT Function Behavior Summary
;;-----------------------------------------------------------------------------
print "^/📝 PUT Function Behavior Summary:"
print "=================================="
print "1. PUT returns the value that was inserted"
print "2. PUT modifies the original series in place"
print "3. PUT with word/string keys works as key-value replacement/addition"
print "4. PUT with integer keys APPENDS key-value pairs (doesn't replace at index)"
print "5. PUT with maps and objects works as expected for field updates"
print "6. PUT/case performs case-sensitive key matching"
print "7. PUT/skip works with record-based data structures"
print "8. PUT serializes none values as #(none) in Rebol 3"
print "9. PUT doesn't extend series with padding - appends key-value pairs"
print "10. PUT maintains reference integrity for inserted values"
