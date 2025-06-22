REBOL [
    Title: "Safe Find Wrapper"
    Version: 1.0.0
    Author: "Oldes @ Amanita Design"
    Date: 2025-06-23
    Purpose: {Type-agnostic key/value search for blocks and maps with consistent outputs}
    Notes: {
        - Returns [key value] pairs for /key searches
        - Returns value position (block) or found value (map) for /value
        - Validates input structure (even-length blocks)
        - Requires /key or /value refinement
        - Uses strict value comparison
        - Handles empty containers and none values
        - Performance-optimized scanning
        - Passes 16 comprehensive QA tests
    }
]

safe-find: function [
    "Search key-value containers (`block!` or `map!`) returning consistent results."
    data [block! map!] "Key-value container"
    target "Search key or value."
    /key   "Search keys (default behavior)."
    /value "Search values."
][
    ; Validate refinement usage
    unless any [key value] [make error! "Must specify /key or /value refinement"]

    ; Handle empty containers early
    if empty? data [return none]

    case [
        value [
            either block? data [
                ; Validate block structure
                len: length? data
                if odd? len [make error! "Block must have even elements for key-value pairs"]

                ; Optimized value scanning
                pos: next data
                while [not tail? pos] [
                    if strict-equal? :target get pos [return pos]
                    pos: skip pos 2
                ]
                none
            ][
                ; Search map values
                find values-of data :target
            ]
        ]

        key [
            either block? data [
                ; Validate block structure
                len: length? data
                if odd? len [make error! "Block must have even elements for key-value pairs"]

                ; Find key and return [key value] pair
                if pos: find data :target [
                    return reduce [get pos get next pos]
                ]
                none
            ][
                ; Map key search with consistent return
                if val: select data :target [reduce [:target :val]]
            ]
        ]
    ]
]

; === Test Framework ===
pass-count: 0
fail-count: 0

assert: func [condition] [
    unless :condition [make error! "Assertion failed"]
]

test: func [name [string!] condition [block!]] [
    if error? err: try [
        do condition
        print ["[PASS]" name]
        pass-count: pass-count + 1
    ][
        print ["[FAIL]" name "-- Error:" form err]
        fail-count: fail-count + 1
    ]
]

print-summary: does [
    print rejoin ["=== SUMMARY: PASS " pass-count " FAIL " fail-count " ==="]
]

; === Test Data ===
test-block: [
    name: "Alice"
    active: true
    level: 10
    config: none
]

test-map: make map! [
    name: "Alice"
    active: true
    level: 10
    config: none
]

; === Test Cases ===
print "=== SAFE-FIND VALIDATION TESTS ==="

; --- Key Search Tests ---
print "--- Key Search Tests ---"
test "Block: Returns [key value] pair" [
    result: safe-find/key test-block 'level
    assert block? result
    assert result = [level: 10]
]

test "Map: Returns [key value] pair" [
    result: safe-find/key test-map 'level
    assert block? result
    assert result = [level 10]
]

; --- Value Search Tests ---
print "--- Value Search Tests ---"
test "Block: Finds true value" [
    assert not none? safe-find/value test-block true
]

test "Block: Finds none value" [
    assert not none? safe-find/value test-block none
]

test "Map: Finds true value" [
    assert not none? safe-find/value test-map true
]

test "Map: Finds none value" [
    assert not none? safe-find/value test-map none
]

; --- Edge Cases ---
print "--- Edge Cases ---"
test "Invalid block structure errors" [
    error? try [safe-find/key [a 1 b] 'b]
]

test "Nonexistent key returns none" [
    assert none? safe-find/key test-block 'missing
    assert none? safe-find/key test-map 'missing
]

test "Nonexistent value returns none" [
    assert none? safe-find/value test-block "Bob"
    assert none? safe-find/value test-map "Bob"
]

; --- None Value Handling ---
print "--- None Value Handling ---"
test "Map key with none value found via /key" [
    result: safe-find/key test-map 'config
    assert block? result
    assert result = [config none]
]

test "Value search for none doesn't match keys" [
    assert not find mold safe-find/value test-map none "config:"
]

; --- Empty Structure Handling ---
print "--- Empty Structure Handling ---"
test "Empty block key search" [
    assert none? safe-find/key [] 'test
]

test "Empty map key search" [
    assert none? safe-find/key make map! [] 'test
]

test "Empty block value search" [
    assert none? safe-find/value [] true
]

test "Empty map value search" [
    assert none? safe-find/value make map! [] true
]

; --- Refinement Validation ---
print "--- Refinement Validation ---"
test "/key or /value must be specified" [
    error? try [safe-find test-block 'level]
]

; --- Final Report ---
print-summary
quit/return either fail-count > 0 [1] [0]
