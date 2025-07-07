REBOL [
    Title: "Diagnostic Script for 'remove' Function"
    Version: 0.1.1
    Author: "AI Software Development Assistant"
    Date: 7-Jul-2025
    Status: {validated}
    Purpose: {
        A comprehensive diagnostic script to test the behavior of the
        `remove` function and its refinements (/part, /key) in
        REBOL/Bulk 3.19.0. It covers blocks, maps, and strings.
    }
    Note: {
        Version 1.1.0 corrected test expectations for blocks and maps based on
        observed interpreter behavior. Version 1.2.0 added a robust testing
        section for STRING! manipulation, demonstrating several practical,
        real-world use cases. The script is now considered complete and validated.
    }
    Keywords: [test qa diagnostic core remove string block map]
]

; -- Test State
all-passed: true

; -- QA Helper Function
assert-equal: function [
    {Compares an actual value against an expected value and prints the result.}
    label [string!] {A description of what is being tested.}
    actual [any-type!] {The value produced by the code under test.}
    expected [any-type!] {The value that the code is expected to produce.}
][
    prin [label "... "]
    either (equal? actual expected) [
        print "[✅ PASSED]"
    ][
        set 'all-passed false
        print ["^/[❌ FAILED]"
            "^/  Expected: " mold expected
            "^/    Actual: " mold actual
            "^/"
        ]
    ]
]

; --- Start of Tests ---
print "--- Testing basic REMOVE on a BLOCK! ---"

data: [a b c d e]
remove (at data 3) ; Remove 'c'
assert-equal
    "Basic remove: Series should be modified correctly"
    data
    [a b d e]

data: [a b c d e]
return-val: remove (at data 3)
assert-equal
    "Basic remove: Return value should be series at next position"
    return-val
    [d e]

print "^/--- Testing REMOVE/PART on a BLOCK! ---"

data: [a b c d e f g]
remove/part (at data 3) 3 ; Remove 'c', 'd', 'e'
assert-equal
    "remove/part number!: Series should have 3 elements removed"
    data
    [a b f g]

data: [a b c d e f g]
return-val: remove/part (at data 3) 3
assert-equal
    "remove/part number!: Return value should be series at next position"
    return-val
    [f g]

data: [a b c]
remove/part (at data 2) 10 ; Remove more than exists
assert-equal
    "remove/part number!: Removing more elements than available"
    data
    [a]

data: [a b c d e f g]
remove/part (at data 2) (find data 'e) ; Remove from 'b' up to (but not including) 'e'
assert-equal
    "remove/part series!: Series should be removed up to the target element"
    data
    [a e f g]

data: [a b c d e f g]
return-val: remove/part (at data 2) (find data 'e)
assert-equal
    "remove/part series!: Return value should be the target element's position"
    return-val
    [e f g]

data: [a b c d e]
pos: at data 4     ; position of 'd'
end-pos: at data 2 ; position of 'b'
remove/part pos end-pos
assert-equal
    "remove/part series!: Reversed range removes between pointers"
    data
    [a d e]


print "^/--- Testing REMOVE/KEY on a MAP! ---"

data-map: make map! [a 1 b 2 c 3]
remove/key data-map 'b
assert-equal
    "remove/key: Key 'b' should be removed (select returns none)"
    (select data-map 'b)
    none

assert-equal
    "remove/key: Map should now have 2 items"
    (length? data-map)
    2

data-map: make map! [a 1 b 2 c 3]
return-val: remove/key data-map 'b
assert-equal
    "remove/key: Return value should be the map itself"
    return-val
    data-map

data-map: make map! [a 1 b 2 c 3]
remove/key data-map 'z ; Key does not exist
assert-equal
    "remove/key: Removing a non-existent key should not change length"
    (length? data-map)
    3

print "^/--- Testing REMOVE on STRINGS! ---"

data-string: copy "abcdef"
remove (at data-string 3)
assert-equal
    "String remove: Removing a single character 'c'"
    data-string
    "abdef"

data-string: copy "abcdef"
return-val: remove (at data-string 3)
assert-equal
    "String remove: Return value is the rest of the string"
    return-val
    "def"

data-string: copy "Remove the middle part"
remove/part (find data-string "the") 11 ; "the middle " is 11 chars
assert-equal
    "String remove/part num!: Removing a substring by length"
    data-string
    "Remove part"

data-string: copy "Strip [this-tag] out"
start-pos: find data-string "["
end-pos: find data-string "]"
remove/part start-pos (next end-pos) ; Use 'next' to include the closing bracket
assert-equal
    "String remove/part series!: Removing a bracketed substring"
    data-string
    "Strip  out"

data-string: copy {First line^/Second line to remove^/Third line}
start-pos: find data-string "Second"
end-pos: find data-string "Third"
remove/part start-pos end-pos ; Removes up to the start of "Third"
assert-equal
    "String remove/part series!: Removing a full line from multi-line string"
    data-string
    "First line^/Third line"

data-string: copy "Keep this: discard the rest"
pos: find data-string "discard"
remove/part pos (length? pos)
assert-equal
    "String remove/part: Removing from a point to the end of the string"
    data-string
    "Keep this: "


; --- Final Report ---
print ""
print "--- Test Suite Complete ---"
either all-passed [
    print "[✅ ALL TESTS PASSED]"
][
    print "[❌ SOME TESTS FAILED]"
]
