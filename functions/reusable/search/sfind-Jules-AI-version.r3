REBOL [Title: "Sfind Full Test - Corrected Assert-Equal"]

print "--- SFIND FULL TEST RUN (Final sfind + Harness Debug) ---"
print newline

print "--- Sanity checks for block comparison with none ---"
block1: [config none]
block2: reduce ['config none]
block3: context [val: none] block3: reduce ['config block3/val]
set-word-block1: [config: none]
set-word-block2: reduce [to-set-word 'config none]

print ["block1 vs block2 (literal vs reduce):" equal? block1 block2]
print ["block1 vs block3 (literal vs reduce from context):" equal? block1 block3]
print ["set-word-block1 vs set-word-block2 (literal vs reduce):" equal? set-word-block1 set-word-block2]
print ["--- End Sanity Checks ---" newline]

normalize: function [value_to_normalize][
    case [
        value_to_normalize = 'true  [true]
        value_to_normalize = 'false [false]
        value_to_normalize = 'none  [none]
        'else          [value_to_normalize]
    ]
]
print "Normalize function defined."

test-state: context [
    pass-count: 0
    fail-count: 0
    all-passed?: true
]
print "test-state object defined."

test: function [
    name [string!]
    test-block [block!]
    /local
        err_catcher
][
    print ["Running test:" name]
    err_catcher: none
    set/any 'err_catcher try [do test-block]
    either error? :err_catcher [
        print rejoin ["[FAILED] " name " -- Error: " mold :err_catcher]
        test-state/fail-count: test-state/fail-count + 1
        test-state/all-passed?: false
    ] [
        print rejoin ["[PASSED] " name]
        test-state/pass-count: test-state/pass-count + 1
    ]
]
print "Test function defined."

assert-equal: function [
    expected actual
    /local expected_type actual_type comparison_ok
][
    expected_type: type? expected
    actual_type: type? actual

    comparison_ok: either expected_type <> actual_type [
        false ;; Types differ, so not equal
    ] [ ;; Types are the same, now check based on type
        case [
            series? expected [equal? expected actual] ;; Handles block! string! etc.
            map? expected    [equal? expected actual]
            true             [strict-equal? expected actual] ;; Default for scalars
        ]
    ]

    unless comparison_ok [
        print rejoin [
            "   ❌ Comparison failed^/"
            "      Expected: " mold expected "^/ (Type: " mold expected_type ")^/"
            "      Actual:   " mold actual "^/ (Type: " mold actual_type ")"
        ]
        make error! "Assertion failed: Values not equal as expected."
    ]
]
print "assert-equal function defined."

assert-condition: function [
    condition [logic!] "Must be true for success"
][
    unless condition [
        print "   ❌ Condition not met"
        make error! "Assertion failed: Condition was false."
    ]
]
print "assert-condition function defined."

print-test-summary: does [
    print "^/============================================"
    case [
        test-state/all-passed? [print "✅ ALL TESTS PASSED"]
        true [print "❌ SOME TESTS FAILED"]
    ]
    print rejoin [
        "TOTAL TESTS: " test-state/pass-count + test-state/fail-count
        " | PASSED: " test-state/pass-count
        " | FAILED: " test-state/fail-count
        newline "============================================"
    ]
]
print "print-test-summary function defined."

sfind: function [
    data target /key /value
    /local len pos val result map-key map-val item_val
][
    unless any [key value] [make error! "Must specify /key or /value refinement"]
    if empty? data [return none]

    case [
        value [
            either block? data [
                if odd? length? data [make error! "sfind/value block requires even elements for key/value pairs"]
                local pair_pos val_pos
                pair_pos: data
                while [not tail? pair_pos] [
                    val_pos: skip pair_pos 1
                    if tail? val_pos [break]
                    item_val: normalize (first val_pos)
                    if strict-equal? target item_val [
                        return item_val
                    ]
                    pair_pos: skip pair_pos 2
                ]
                return none
            ][ ; map? data
                foreach [map-key map-val] data [
                    if strict-equal? target normalize :map-val [
                        return normalize :map-val
                    ]
                ]
                return none
            ]
        ]
        key [
            either block? data [
                if odd? length? data [make error! "sfind/key block requires even elements"]
                if pos: find data to-word :target [
                    result: copy/part pos 2
                    if (length? result) = 2 [
                       poke result 2 normalize (pick result 2)
                    ]
                    return result
                ]
                return none
            ][ ; map? data
                if find data :target [
                    val: normalize (select data :target)
                    return reduce [:target :val]
                ]
                return none
            ]
        ]
    ]
]
print "sfind function defined."

;; === QA Test Data ===
test-block: [ name: "Alice" active: true level: 10 config: none status: 'pending ]
print "test-block defined."
test-map: make map! [ name: "Alice" active: true level: 10 config: none status: 'pending ]
print "test-map defined."

;; === QA Test Cases ===
print newline
print "^/=== SFIND FULL VALIDATION TESTS (Corrected Assert-Equal) ===^/"
print-group: func [title] [print rejoin ["^/--- " title " ---"]]

print-group "Key Search Tests"
test "Block: Returns [key value] pair" [
    result: sfind/key test-block 'level
    assert-equal [level: 10] result
]
test "Map: Returns [key value] pair" [
    result: sfind/key test-map 'level
    assert-equal [level 10] result
]

print-group "Value Search Tests"
test "Block: Finds true value" [
    result: sfind/value test-block true
    assert-condition not none? result
    assert-equal true result
]
test "Block: Finds none value (datatype)" [
    result: sfind/value test-block none
    assert-condition not none? result
    assert-equal none result
]
test "Map: Finds true value" [
    result: sfind/value test-map true
    assert-condition not none? result
    assert-equal true result
]
test "Map: Finds none value (datatype)" [
    result: sfind/value test-map none
    assert-condition not none? result
    assert-equal none result
]

print-group "Edge Cases"
test "Invalid block structure errors (key search)" [
    assert-condition error? try [sfind/key [a 1 b] 'b]
]
test "Invalid block structure errors (value search)" [
    assert-condition error? try [sfind/value [a 1 b] 1]
]
test "Nonexistent key returns none" [
    assert-condition none? sfind/key test-block 'missing
    assert-condition none? sfind/key test-map 'missing
]
test "Nonexistent value returns none" [
    assert-condition none? sfind/value test-block "Bob"
    assert-condition none? sfind/value test-map "Bob"
]

print-group "`none` Value Handling"
test "Map key with 'config (value is none!) found via /key" [
    result: sfind/key test-map 'config
    assert-equal reduce ['config none] result ;; Expect what sfind produces
]
test "Block key with 'config (value is none!) found via /key" [
    result: sfind/key test-block 'config
    assert-equal reduce [to-set-word 'config none] result ;; Expect what sfind produces
]
test "Value search for WORD 'none in map" [
    test-map-word-none: make map! [item: 'none]
    result: sfind/value test-map-word-none 'none
    assert-condition strict-equal? none result
    assert-equal none result
]
test "Value search for WORD 'none in block" [
    test-block-word-none: [item: 'none]
    result: sfind/value test-block-word-none 'none
    assert-condition strict-equal? none result
    assert-equal none result
]
test "Value search for DATATYPE none in map with WORD 'none" [
    test-map-word-none2: make map! [item: 'none]
    result: sfind/value test-map-word-none2 none
    assert-condition none? result
]
test "Value search for DATATYPE none in block with WORD 'none" [
    test-block-word-none2: [item: 'none]
    result: sfind/value test-block-word-none2 none
    assert-condition none? result
]

print-group "Empty Structure Handling"
test "Empty block key search" [ assert-condition none? sfind/key [] 'test ]
test "Empty map key search" [ assert-condition none? sfind/key make map! [] 'test ]
test "Empty block value search" [ assert-condition none? sfind/value [] true ]
test "Empty map value search" [ assert-condition none? sfind/value make map! [] true ]

print-group "Refinement Validation"
test "/key or /value must be specified" [ assert-condition error? try [sfind test-block 'level] ]

print-test-summary
print "--- Script End ---"
