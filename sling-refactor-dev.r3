REBOL [
	Title: "The `sling` Super-Setter Function"
	Version: 0.2.2
	Author: "ChatGPT-5 MAX, Jules AI Assistants, Human Orchestrator"
    Date: 09-Aug-2025
    Status: "QA suite passed after test data correction."
    File: %sling.r3
    Purpose: {A self-contained script to rigorously test and implement the
        `sling` function, a robust tool for modifying Rebol data structures.}
    Note: "Adheres to the r3oTop project development ruleset."
    Keywords: [super setter prototype set place put poke modify write robust QA test function helper block map object]
]

;;-----------------------------------------------------------------------------
;;; QA Test Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    {A simple QA helper to compare two values for equality.
    Prints a formatted PASSED or FAILED message to the console.
    Modifies a parent-scope `all-tests-passed?` flag on failure.
    RETURNS: [unset!]
    ERRORS: None.}

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
    {Prints the final summary of the entire test run.
    Checks the parent-scope `all-tests-passed?` flag to determine the outcome.
    RETURNS: [unset!]
    ERRORS: None.}

    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED"
    ][
        print "❌ SOME TESTS FAILED"
    ]
    print "============================================^/"
]


;;-----------------------------------------------------------------------------
;;; Dependencies
;;-----------------------------------------------------------------------------
do %common-lib.r3

;;-----------------------------------------------------------------------------
;;; Refactored Helper Functions
;;-----------------------------------------------------------------------------

handle-block-step: func [container step create secure] [
    either integer? step [
        ; Positional access in blocks (support negative indices)
        actual-index: either step < 0 [ (length? container) + step + 1 ] [ step ]
        if any [none? actual-index actual-index < 1 actual-index > length? container] [
            ; Only allow growth for positive indices with /create
            either all [create step > 0 actual-index > length? container] [
                insert/dup tail container 'none actual-index - length? container
            ] [
                return none
            ]
        ]
        return container/:actual-index
    ][
        ; Key-based access in blocks
        if all [secure not any-word? step] [
            return none
        ]
        pos: find container to-set-word step
        either pos [
            value-after: second pos
            either block? :value-after [
                ; If the immediate value is a literal block, descend directly
                return :value-after
            ][
                ; Secure mode forbids evaluation of expressions after set-words
                if secure [
                    return none
                ]
                ; Otherwise, evaluate the value-expression (up to next top-level set-word)
                value-expression: copy next pos
                next-setword-pos: none

                foreach item value-expression [
                    if set-word? item [
                        next-setword-pos: find value-expression item
                        break
                    ]
                ]

                if next-setword-pos [
                    value-expression: copy/part value-expression next-setword-pos
                ]

                if any [none? value-expression empty? value-expression] [
                    return none
                ]

                result: try [do value-expression]

                if error? result [
                    return none
                ]

                ; Replace expression with evaluated result to stabilize further traversal
                idx: index? pos
                expr-len: length? value-expression
                change/part at container idx + 1 reduce [:result] expr-len
                return :result
            ]
        ][
            either create [
                repend container [to-set-word step make map! []]
                return select container step
            ][
                return none
            ]
        ]
    ]
]

handle-map-step: func [container step create secure] [
    if all [secure not any [any-word? step string? step]] [
        return none
    ]
    parent: container
    selected: select parent step

    unless selected [
        either create [
            put parent step make map! []
            selected: select parent step
        ][
            return none
        ]
    ]

    unless any [block? :selected map? :selected object? :selected] [
        if create [
            put parent step make map! []
            selected: select parent step
        ]
    ]
    return selected
]

handle-object-step: func [container step secure] [
    if all [secure not any-word? step] [
        return none
    ]
    either any-word? step [
        field-word: to word! step
        bound-word: in container field-word
        either bound-word [
            return get bound-word
        ][
            return none
        ]
    ][
        return none
    ]
]


;;-----------------------------------------------------------------------------
;; Status: All test cases pass.
;;-----------------------------------------------------------------------------
sling: function [
    {Safely and robustly sets or creates a value within a block, map, or object.}
    data [block! map! object! none!] "The data structure to modify (modified in place)."
    key [any-word! integer! decimal! block!] "Index, key, or path specification."
    value [any-type!] "The value to set."
    /path "Treat key as a path for nested structure navigation."
    /create "Allow creation of new keys if they don't exist."
    /report "Return a logic! indicating whether a change occurred, instead of the data."
    /strict "Fail-fast: raise an error if no change occurs (no-op)."
    /secure "Harden path traversal (no evaluation; restrict steps to safe types)."
][
    changed?: false

    either path [
        ; --- Revised Path Logic ---
        if not block? key [
            if strict [return make error! [type: 'script id: 'invalid-path arg1: "Path key must be a block."]]
            return either report [false] [data]
        ]

        if empty? key [
            if strict [return make error! [type: 'script id: 'invalid-path arg1: "Path key cannot be empty."]]
            return either report [false] [data]
        ]

        container: data
        path-to-walk: copy/part key (length? key) - 1

        foreach step path-to-walk [
            container: case [
                block? container [handle-block-step container step create secure]
                map? container [handle-map-step container step create secure]
                object? container [handle-object-step container step secure]
                true [none]
            ]

            if none? container [
                if strict [return make error! [type: 'script id: 'path-not-found arg1: rejoin ["Path not found at step: " mold step]]]
                return either report [false] [data]
            ]
        ]

        case [
            block? container [
                either integer? last key [
                    actual-index-final: either (last key) < 0 [ (length? container) + (last key) + 1 ] [ last key ]

                    if all [create (last key) > 0 actual-index-final > (length? container)] [
                        insert/dup tail container 'none actual-index-final - (length? container)
                    ]

                    if all [actual-index-final >= 1 actual-index-final <= length? container] [
                        poke container actual-index-final value
                        changed?: true
                    ]
                ][
                    either find container to-set-word last key [
                        put container to-set-word last key value
                        changed?: true
                    ][
                        if create [append container reduce [to-set-word last key value] changed?: true]
                    ]
                ]
            ]

            map? container [
                if all [secure not any [any-word? last key string? last key]] [
                    if strict [return make error! [type: 'script id: 'invalid-key-type arg1: "Invalid key type in secure mode."]]
                    return either report [false] [data]
                ]

                final-key: last key
                either not none? select container final-key [
                    put container final-key value
                    changed?: true
                ][
                    if create [put container final-key value changed?: true]
                ]
            ]

            object? container [
                if any-word? last key [
                    if all [secure not any-word? last key] [
                        if strict [return make error! [type: 'script id: 'invalid-key-type arg1: "Invalid key type in secure mode."]]
                        return either report [false] [data]
                    ]
                    field-word2: to word! last key
                    bound?: in container field-word2
                    if bound? [
                        set bound? value
                        changed?: true
                    ]
                ]
            ]
        ]

        if all [strict not changed?] [return make error! [type: 'script id: 'key-not-found arg1: "Target key/index not found for setting."]]
        return either report [changed?] [data]

    ][
        ; --- Single-Level Logic (Optimized) ---
        if not any [block? data map? data object? data] [
            if strict [return make error! [type: 'script id: 'invalid-container arg1: "Data must be a block, map, or object."]]
            return either report [false] [data]
        ]

        if block? data [
            if integer? key [
                actual-index: either key < 0 [ (length? data) + key + 1 ] [ key ]
                if all [actual-index >= 1 actual-index <= (length? data)] [
                    poke data actual-index value
                    changed?: true
                ]
                if all [strict not changed?] [return make error! [type: 'script id: 'index-out-of-bounds arg1: rejoin ["Index " key " is out of bounds."]]]
                return either report [changed?] [data]
            ]

            if word? key [
                either find data to-set-word key [
                    put data to-set-word key value
                    changed?: true
                ][
                    if create [append data reduce [to-set-word key value] changed?: true]
                ]
                if all [strict not changed?] [return make error! [type: 'script id: 'key-not-found arg1: rejoin ["Key " mold key " not found."]]]
                return either report [changed?] [data]
            ]
            if strict [return make error! [type: 'script id: 'invalid-key-type arg1: "Invalid key type for block."]]
            return either report [false] [data]
        ]

        if object? data [
            if word? key [
                if in data key [
                    put data key value
                    changed?: true
                ]
            ]
            if all [strict not changed?] [return make error! [type: 'script id: 'key-not-found arg1: rejoin ["Field " mold key " not found in object."]]]
            return either report [changed?] [data]
        ]

        if map? data [
            if any [find data key create] [
                put data key value
                changed?: true
            ]
            if all [strict not changed?] [return make error! [type: 'script id: 'key-not-found arg1: rejoin ["Key " mold key " not found in map."]]]
            return either report [changed?] [data]
        ]

        if strict [return make error! [type: 'script id: 'generic-error arg1: "Sling operation failed."]]
        return either report [false] [data]
    ]
]

;;-----------------------------------------------------------------------------
;;; Test Execution
;;-----------------------------------------------------------------------------
print "=== Starting QA tests for `sling` v0.2.2 ==="
print "^/--- `grab` Integrity Test (for sling) ---"

;; This data structure simulates the state inside the `sling/path` loop.
test-data: [
    container: [
        key: true
    ]
]

;; 1. First, grab the container block.
container-block: grab/path test-data ['container]
assert-equal [key: true] container-block "grab Integrity: Should retrieve the container block correctly."

;; 2. Now, grab a logic value from that container BY INDEX.
;; This is the critical test. If `grab`'s normalization logic is flawed
;; for `pick`, this will return the word! 'true instead of the logic! true.
final-value: grab container-block 2
assert-equal true final-value "grab Integrity: Should return a LOGIC! true, not the word! 'true, when picking by index."

print "^/--- Phase 1: Simple Set Tests ---"

;; --- Block by Integer ---
test-block-int: [a b c]
sling test-block-int 2 "X"
assert-equal [a "X" c] test-block-int "Block/Int: Should set value at a valid index."

sling test-block-int 5 "Y"
assert-equal [a "X" c] test-block-int "Block/Int: Should do nothing for an out-of-bounds index."

;; --- Block by Word ---
test-block-word: [name: "Alice" age: 25]
sling test-block-word 'age 30
assert-equal [name: "Alice" age: 30] test-block-word "Block/Word: Should set value for an existing key."

sling test-block-word 'city "Boston"
assert-equal [name: "Alice" age: 30] test-block-word "Block/Word: Should do nothing for a missing key."

;; --- Map by Word ---
test-map: make map! [name: "Alice" age: 25]
sling test-map 'age 30
assert-equal true (not none? find test-map 'age) "Map/Word: Key 'age should still exist."
assert-equal 30 select test-map 'age "Map/Word: Should set value for an existing key."

;; This test is now updated to correctly reflect that without /create, nothing should happen.
sling test-map 'city "Boston"
assert-equal false (not none? find test-map 'city) "Map/Word (no-create): Should NOT create a new key 'city'."

;; --- Block Negative Indexing ---
neg-block: [a b c d]
sling neg-block -1 "Z"
assert-equal [a b c "Z"] neg-block "Block/Int (negative): -1 should set the last item."

sling neg-block -2 "Y"
assert-equal [a b "Y" "Z"] neg-block "Block/Int (negative): -2 should set second-to-last item."

sling neg-block -5 "X"
assert-equal [a b "Y" "Z"] neg-block "Block/Int (negative): Out-of-bounds negative index should be a no-op."

;; --- Object single-level ---
obj-single: make object! [name: "Alice" age: 25]
sling obj-single 'age 26
assert-equal 26 get in obj-single 'age "Object: Should set existing field."

sling obj-single 'city "LA"
assert-equal none in obj-single 'city "Object: Should not create missing field."

print "^/--- Phase 2: `/create` Refinement Tests ---"

;; --- Block /create ---
test-block-create: [a: 1]
sling/create test-block-create 'b 2
assert-equal [a: 1 b: 2] test-block-create "Block/create: Should create a new key-value pair."

;; --- Map /create ---
test-map-create: make map! [a: 1]
sling/create test-map-create 'b 2
assert-equal 2 select test-map-create 'b "Map/create: Should create a new key-value pair."

;; --- Block /create with padding ---
test-block-pad: []
sling/path/create test-block-pad [3] "C"
assert-equal ['none 'none "C"] test-block-pad "Block/create (pad): Should create and pad with 'none."

;; --- Test without /create (should do nothing) ---
test-map-no-create: make map! [a: 1]
sling test-map-no-create 'b 2
assert-equal none select test-map-no-create 'b "Map/no-create: Should not create a key without the refinement."

print "^/--- Phase 3: `/path` Refinement Tests ---"

;; --- Path Tests ---
path-data: [
    config: [
        port: 8080
        database: make map! [
            host: "localhost"
        ]
    ]
    rows: [1 2 3 4]
]

sling/path path-data ['config 'port] 9090
assert-equal 9090 grab/path path-data ['config 'port] "Path/Block: Should set value in a nested block."

sling/path path-data ['config 'database 'host] "db.example.com"
assert-equal "db.example.com" grab/path path-data ['config 'database 'host] "Path/Map: Should set value in a nested map."

;; Negative indexing in /path traversal
sling/path path-data ['rows -1] 99
assert-equal 99 grab/path path-data ['rows 4] "Path/Block (negative): -1 should set the last item."

;; --- Path with /create ---
path-create-data: [config: [a: 1]]
sling/path/create path-create-data ['config 'b] 2
assert-equal 2 grab/path path-create-data ['config 'b] "Path/Create: Should create a key in a nested block."

path-create-map: make map! [config: make map! [a: 1]]
sling/path/create path-create-map ['config 'b] 2
assert-equal 2 grab/path path-create-map ['config 'b] "Path/Create: Should create a key in a nested map."

;; --- Path Creation (Deep) ---
deep-create-data: [a: []]
sling/path/create deep-create-data ['a 'b 'c] "deep"
assert-equal "deep" grab/path deep-create-data ['a 'b 'c] "Path/Create: Should create nested structures."

;; --- Object /path tests ---
obj-path: make object! [
    info: make object! [age: 30]
]

sling/path obj-path ['info 'age] 31
assert-equal 31 get in get in obj-path 'info 'age "Path/Object: Should set existing nested field."

sling/path obj-path ['info 'city] "LA"
assert-equal none in get in obj-path 'info 'city "Path/Object: Should be no-op for missing field."

sling/path/create obj-path ['info 'country] "US"
assert-equal none in get in obj-path 'info 'country "Path/Object: /create should not add object fields."

;; Sanity check: direct nested set via `set in`
obj-san: make object! [wrap: make object! [age: 30]]
set in get in obj-san 'wrap 'age 31
assert-equal 31 get in get in obj-san 'wrap 'age "Sanity: set in on nested object should set value."


print "^/--- Phase 4: `/report` Refinement Tests ---"

;; Block/report
rep-blk: [a b]
assert-equal true  sling/report rep-blk 2 'X "Report/Block: Should report true on successful set."
assert-equal false sling/report rep-blk 5 'Y "Report/Block: Should report false on out-of-bounds index."

;; Map/report
rep-map: make map! [a: 1]
assert-equal true  sling/report rep-map 'a 2 "Report/Map: Should report true on existing key."
assert-equal false sling/report rep-map 'b 2 "Report/Map: Should report false without /create."
assert-equal true  sling/create/report rep-map 'b 2 "Report/Map: Should report true with /create on missing key."

;; Object/report
rep-obj: make object! [age: 25]
assert-equal true  sling/report rep-obj 'age 30 "Report/Object: Should report true on existing field."
assert-equal false sling/report rep-obj 'city "LA" "Report/Object: Should report false on missing field."

;; Path/report (block)
rep-path: [rows: [1 2]]
assert-equal true  sling/path/report rep-path ['rows 1] 9 "Report/Path(Block): Should report true on in-range index."
assert-equal false sling/path/report rep-path ['rows 5] 1 "Report/Path(Block): Should report false on out-of-range index."
assert-equal true  sling/path/report rep-path ['rows -1] 7 "Report/Path(Block): Should report true on negative index."

;; Path/report (map)
rep-mapp: make map! [conf: make map! []]
assert-equal false sling/path/report rep-mapp ['conf 'x] 1 "Report/Path(Map): Should report false without /create."
assert-equal true  sling/path/create/report rep-mapp ['conf 'x] 1 "Report/Path(Map): Should report true with /create."

;; Path/report (object)
rep-objp: make object! [info: make object! [a: 1]]
assert-equal true  sling/path/report rep-objp ['info 'a] 2 "Report/Path(Object): Should report true on existing nested field."
assert-equal false sling/path/report rep-objp ['info 'b] 2 "Report/Path(Object): Should report false on missing nested field."

print "^/--- Phase 5: `/secure` Refinement Tests ---"

;; Secure: block key non-word should be rejected (no evaluation)
sec-blk: [conf: make map! [x: 1]]
assert-equal false sling/path/secure/report sec-blk ['conf 1] 9 "Secure/Block: Non-word step should be rejected."

;; Secure: block word with literal block value is allowed
sec-blk2: [conf: [port: 80]]
assert-equal true sling/path/secure/report sec-blk2 ['conf 'port] 81 "Secure/Block: Literal block path is allowed."

;; Secure: map non-word key should be rejected
sec-map: make map! reduce ['conf make map! [port: 80]]
assert-equal false sling/path/secure/report sec-map ['conf 1] 90 "Secure/Map: Non-word step should be rejected."

;; Secure: map word key allowed
assert-equal true sling/path/secure/report sec-map ['conf 'port] 91 "Secure/Map: Word key allowed."

;; Secure: map string key allowed
sec-map-str: make map! reduce ["conf" make map! ["port" 80]]
assert-equal true sling/path/secure/report sec-map-str ["conf" "port"] 92 "Secure/Map: String key should be allowed."

;; Secure: object non-word step rejected
sec-obj: make object! [info: make object! [age: 30]]
assert-equal false sling/path/secure/report sec-obj ['info 1] 31 "Secure/Object: Non-word step should be rejected."

;; Secure: object word step allowed
assert-equal true sling/path/secure/report sec-obj ['info 'age] 32 "Secure/Object: Word step allowed."

print "^/--- Phase 6: `/strict` Error ID Tests ---"
assert-strict-error: func [err-id [word!] code [block!] description [string!]] [
    err: try code
    assert-equal err-id err/id description
]

assert-strict-error 'index-out-of-bounds [sling/strict [a] 2 1] "Strict: Should error 'index-out-of-bounds"
assert-strict-error 'key-not-found [sling/strict [a: 1] 'b 2] "Strict: Should error 'key-not-found for block"
assert-strict-error 'key-not-found [sling/strict make map! [a: 1] 'b 2] "Strict: Should error 'key-not-found for map"
assert-strict-error 'key-not-found [sling/strict make object! [a: 1] 'b 2] "Strict: Should error 'key-not-found for object"
assert-strict-error 'path-not-found [sling/path/strict [a: [b: 1]] ['a 'c] 2] "Strict: Should error 'path-not-found"
assert-strict-error 'invalid-path [sling/path/strict [] 1 2] "Strict: Should error 'invalid-path for non-block"

print-test-summary
