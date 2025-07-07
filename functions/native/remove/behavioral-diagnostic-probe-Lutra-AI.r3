REBOL [
    Title: "REMOVE Function Diagnostic Script"
    Description: "Testing of REMOVE function with corrected expectations"
    Date: 7-Jul-2025
    Version: 0.1.0
]

print "=== REMOVE Function Diagnostic Script (Corrected) ==="
print ["Testing REBOL/Bulk version:" system/version]
print ""

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

print "=== BASIC REMOVE TESTS ==="

; Test 1: Remove from string at current position
; CORRECTED: remove removes from current position to end, not just one character
original-str: "Hello World"
str1: copy original-str
str1: skip str1 5  ; Position at space
result1: remove str1
assert-equal "World" result1 "Remove from string at position 5 (removes from position to end)"

; Test 2: Remove from block at current position
original-block: [1 2 3 4 5]
block1: copy original-block
block1: skip block1 2  ; Position at 3
result2: remove block1
assert-equal [4 5] result2 "Remove single element from block"

; Test 3: Remove from empty series
empty-block: []
result3: remove copy empty-block
assert-equal [] result3 "Remove from empty block"

; Test 4: Remove from series at tail
; CORRECTED: remove from tail returns empty series
tail-block: copy [1 2 3]
tail-block: tail tail-block
result4: remove tail-block
assert-equal [] result4 "Remove from series at tail (returns empty series)"

; Test 5: Remove from string at beginning
str-begin: "Hello World"
result5: remove str-begin
assert-equal "ello World" result5 "Remove from string at beginning"

; Test 6: Remove from block at beginning
block-begin: [a b c d e]
result6: remove block-begin
assert-equal [b c d e] result6 "Remove from block at beginning"

print "=== REMOVE/PART TESTS ==="

; Test 7: Remove/part with number
original-str2: "Hello World"
str2: copy original-str2
result7: remove/part str2 5
assert-equal " World" result7 "Remove/part 5 characters"

; Test 8: Remove/part with series position
original-block2: [a b c d e f]
block2: copy original-block2
block2: skip block2 1  ; Position at 'b'
end-pos: skip block2 3  ; Position at 'e'
result8: remove/part block2 end-pos
assert-equal [e f] result8 "Remove/part to position"

; Test 9: Remove/part larger than series
original-block3: [1 2 3]
block3: copy original-block3
result9: remove/part block3 10
assert-equal [] result9 "Remove/part beyond series length"

; Test 10: Remove/part with zero
original-str3: "Hello"
str3: copy original-str3
result10: remove/part str3 0
assert-equal "Hello" result10 "Remove/part with zero (no change)"

print "=== REMOVE/KEY TESTS ==="

; Test 11: Remove/key from map
original-map: make map! [name "John" age 30 city "NYC"]
map1: copy original-map
result11: remove/key map1 'name
expected-map: make map! [age 30 city "NYC"]
assert-equal expected-map result11 "Remove/key existing key from map"

; Test 12: Remove/key non-existent key
original-map2: make map! [a 1 b 2]
map2: copy original-map2
result12: remove/key map2 'c
expected-map2: make map! [a 1 b 2]
assert-equal expected-map2 result12 "Remove/key non-existent key"

; Test 13: Remove/key with string key
original-map3: make map! ["hello" "world" "foo" "bar"]
map3: copy original-map3
result13: remove/key map3 "hello"
expected-map3: make map! ["foo" "bar"]
assert-equal expected-map3 result13 "Remove/key with string key"

; Test 14: Remove/key with integer key
original-map4: make map! [1 "one" 2 "two" 3 "three"]
map4: copy original-map4
result14: remove/key map4 2
expected-map4: make map! [1 "one" 3 "three"]
assert-equal expected-map4 result14 "Remove/key with integer key"

print "=== EDGE CASES AND ERROR CONDITIONS ==="

; Test 15: Remove from different series types
print "Testing different series types:"

; String
str-test: "ABCDE"
str-test: skip str-test 2  ; Position at C
result15: remove str-test
assert-equal "DE" result15 "Remove from string (different series type)"

; Binary
bin-test: #{0102030405}
bin-test: skip bin-test 2  ; Position at 03
result16: remove bin-test
assert-equal #{0405} result16 "Remove from binary"

; Test 16: Remove with none value
result17: remove none
assert-equal none result17 "Remove with none value"

print "=== MEMORY AND REFERENCE TESTS ==="

; Test 17: Multiple references to same series
shared-block: [a b c d e]
ref1: shared-block
ref2: skip shared-block 2  ; Position at c
print ["Before remove - ref1:" mold ref1 "ref2:" mold ref2]
result18: remove ref2
print ["After remove - ref1:" mold ref1 "ref2:" mold ref2]
assert-equal [a b d e] ref1 "Shared reference test - original modified"
assert-equal [d e] result18 "Shared reference test - remove result"

print "=== POSITION BEHAVIOR TESTS ==="

; Test 19: Remove returns series at same position
test-block: [a b c d e]
pos: skip test-block 2  ; Position at c
result19: remove pos
assert-equal [d e] result19 "Remove returns series at same position"

; Test 20: Remove/part returns series at same position
test-block2: [a b c d e f]
pos2: skip test-block2 1  ; Position at b
result20: remove/part pos2 2
assert-equal [d e f] result20 "Remove/part returns series at same position"

print "=== BOUNDARY CONDITION TESTS ==="

; Test 21: Remove from single element series
single-elem: [only]
result21: remove single-elem
assert-equal [] result21 "Remove from single element series"

; Test 22: Remove/part from single element
single-elem2: [only]
result22: remove/part single-elem2 1
assert-equal [] result22 "Remove/part from single element"

; Test 23: Remove from series with one element at tail
one-elem: [x]
one-elem: tail one-elem
result23: remove one-elem
assert-equal [] result23 "Remove from tail of single element series"

print "=== TYPE VALIDATION TESTS ==="

; Test 24: Remove with different map value types
mixed-map: make map! [
    string-key "value"
    42 "number-key"
    true "boolean-key"
    [a b] "block-key"
]
result24: remove/key mixed-map 42
expected-mixed: make map! [
    string-key "value"
    true "boolean-key"
    [a b] "block-key"
]
assert-equal expected-mixed result24 "Remove/key with mixed value types"

print "=== PERFORMANCE NOTES ==="
print "Performance testing with large series:"
large-block: copy []
loop 1000 [append large-block random 1000]
start-time: now/time/precise
remove/part large-block 500
end-time: now/time/precise
print ["Removed 500 elements in:" (end-time - start-time) "seconds"]
assert-equal 500 length? large-block "Large series removal performance test"

print-test-summary
print "=== BEHAVIOR SUMMARY ==="
print "Key findings about REMOVE function:"
print "1. REMOVE without /part removes from current position to end"
print "2. REMOVE from tail position returns empty series"
print "3. REMOVE returns the series at the same position after removal"
print "4. REMOVE/part removes specified number of elements or to position"
print "5. REMOVE/key works with maps and various key types"
print "6. REMOVE modifies the original series and affects all references"
print "7. REMOVE handles edge cases gracefully (empty series, beyond bounds)"

print "=== DIAGNOSTIC COMPLETE ==="
