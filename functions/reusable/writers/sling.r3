REBOL [
    Title: "The `sling` Super-Setter Function"
    Version: 0.1.1
    Author: "AI Assistant & Human Orchestrator"
    Date: 19-Jun-2025
    Status: "Four Phase 3 QA tests are failing."
    File: %sling.r3
    Purpose: {
        A self-contained script to rigorously test and implement the
        `sling` function, a robust tool for modifying Rebol data structures.
    }
    Note: "Adheres to the r3oTop project development ruleset."
    Keywords: [set place put poke modify write robust qa test function helper block map object]
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
grab: function [
    data [any-type!] "The data structure to access (`block!`, `map!` or `none!`)."
    key [any-word! string! integer! decimal! block!] "The index, key or path to retrieve."
    /path "Treat the `key` as a path (a block of keys/indices)."
    /default "Provide a default value if the retrieval fails."
    default-value [any-type!] "The value to return on failure."
][
    {Safely retrieve a value from a `block!` or `map!`, with optional path traversal.
    RETURNS: [any-type!] "The retrieved value, default value or `none`"
    ERRORS: None. This function is designed to never error, returningnoneor a default value on failure.}

    if path [
        if any [not block? key empty? key] [
            return either default [default-value] [none]
        ]

        current: data

        foreach step key [
            if not any [block? :current map? :current] [
                current: none
                break
            ]

            current: grab current step

            if none? :current [break]
        ]

        return either all [none? :current default] [default-value] [current]
    ]

    if not any [block? data map? data none? data] [return either default [default-value] [none]]
    if none? data [return either default [default-value] [none]]

    if block? data [
        if integer? key [
            ;; For integers, we must normalize the result of `pick`:
            value: pick data key

            if none? value [return either default [default-value] [none]]
            case [
                all [word? value value = 'none] [return none]
                all [word? value value = 'true] [return true]
                all [word? value value = 'false] [return false]
            ]

            return value
        ]

        if decimal? key [
            ;; Decimal keys are not valid for block indexing - return default/none:
            return either default [default-value] [none]
        ]

        ;; Block keys in non-path mode are invalid - return default or none
        if block? key [
            return either default [default-value] [none]
        ]

        ;; This is the sophisticated parsing and evaluation logic for word/string keys:
        position: find data to-set-word key

        if position [
            value-expression: copy next position
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

            if not empty? value-expression [
                ;; This is the "Try / Fallback" pattern:
                ;; First, ATTEMPT to evaluate the expression.
                result: try [do value-expression]

                ;; Check if the attempt failed (e.g., context error on an alias):
                if error? result [
                    ;; The 'do' failed.  Fall back to the safe 'select' logic, to get the next literal value:
                    return select data to-set-word key
                ]

                ;; The 'do' succeeded. Return the evaluated result:
                return result
            ]
        ]

        return either default [default-value] [none]
    ]

    if map? data [
        if find data key [
            value: select data key
            case [
                all [word? value value = 'none] [return none]
                all [word? value value = 'true] [return true]
                all [word? value value = 'false] [return false]
            ]

            return value
        ]

        return either default [default-value] [none]
    ]
]

;;-----------------------------------------------------------------------------
grab-item: function [
    "USE: Find a record in system-items by its key and grab its associated value."
    key-string [string!] "The key to match (e.g., 'system/version')."
    index [integer!] "The index of the value to grab from the matching record (1, 2, or 3)."
][
    foreach record system-items [
        ;; Ensure the first item in the record matches our key:
        if key-string = first record [
            ;; Use `grab` to safely get the indexed item from the record:
            return grab record index
        ]
    ]
    return none ;; Return `none` if no record was found.
]

;;-----------------------------------------------------------------------------
sling: function [
    {Safely and robustly sets or creates a value within a block, map, or object.}
    data [block! map! object! none!] "The data structure to modify (modified in place)."
    key [any-word! integer! decimal! block!] "Index, key, or path specification."
    value [any-type!] "The value to set."
    /path "Treat key as a path for nested structure navigation."
    /create "Allow creation of new keys if they don't exist."
][
    either path [
        ; --- Revised Path Logic ---
        if not block? key [return data]
        if empty? key [return data]
        
        container: data
        path-to-walk: copy/part key (length? key) - 1
        
        foreach step path-to-walk [
            case [
                block? container [
                    either integer? step [
                        ; Positional access in blocks
                        unless all [step >= 1 step <= length? container] [
                            either create [
                                insert/dup tail container none step - length? container
                            ][
                                return data
                            ]
                        ]
                        container: container/:step
                    ][
                        ; Key-based access in blocks
                        pos: find container to-set-word step
                        either pos [
                            container: second pos
                        ][
                            either create [
                                repend container [to-set-word step make map! []]
                                container: select container step
                            ][
                                return data
                            ]
                        ]
                    ]
                ]
                map? container [
                    unless select container step [
                        either create [
                            put container step make map! []
                        ][
                            return data
                        ]
                    ]
                    container: select container step
                ]
                'else [return data]  ; Invalid container type
            ]
        ]
        
        ; Final setting operation - fully type-safe
        case [
            block? container [
                either integer? last key [
                    if all [last key >= 1 last key <= length? container] [
                        poke container last key value
                    ]
                ][
                    either find container to-set-word last key [
                        put container to-set-word last key value
                    ][
                        if create [append container reduce [to-set-word last key value]]
                    ]
                ]
            ]
            map? container [
                ; Clearer nested map handling that won't break existing cases
                case [
                    all [
                        find container last key
                        ; Ensure we update existing values
                        put container last key value
                        container  ; Return modified container
                    ]
                    create [
                        ; Special handling for different creation cases
                        case [
                            all [
                                block? key 
                                block? value
                                empty? value
                            ] [put container last key make map! []]
                            block? value [put container last key copy value]
                            'else [put container last key value]
                        ]
                        container  ; Return modified container
                    ]
                    'else [data]  ; Return original if nothing changed
                ]
            ]
        ]
        return data   
        
    ][
        ; --- Single-Level Logic (Optimized) ---
        if not any [block? data map? data] [return data]
        if block? data [
            if integer? key [
                if all [key >= 1 key <= (length? data)] [poke data key value]
                return data
            ]
            if word? key [
                either find data to-set-word key [
                    put data to-set-word key value
                ][
                    if create [append data reduce [to-set-word key value]]
                ]
                return data
            ]
            return data
        ]
        if map? data [
            if any [find data key create] [
                put data key value
            ]
            return data
        ]
        return data
    ]
]

;;-----------------------------------------------------------------------------
;;; Test Execution
;;-----------------------------------------------------------------------------

print "=== Starting QA tests for `sling` v0.2.1 ==="

print "^/--- `grab` Integrity Test (for sling) ---"

;; This data structure simulates the state inside the `sling` /path loop.
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

print "^/--- Phase 1: Simple Set Tests (Revised) ---"

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

print "^/--- Phase 2: /create Refinement Tests ---"

;; --- Block /create ---
test-block-create: [a: 1]
sling/create test-block-create 'b 2
assert-equal [a: 1 b: 2] test-block-create "Block/create: Should create a new key-value pair."

;; --- Map /create ---
test-map-create: make map! [a: 1]
sling/create test-map-create 'b 2
assert-equal 2 select test-map-create 'b "Map/create: Should create a new key-value pair."

;; --- Test without /create (should do nothing) ---
test-map-no-create: make map! [a: 1]
sling test-map-no-create 'b 2
assert-equal none select test-map-no-create 'b "Map/no-create: Should not create a key without the refinement."

print "^/--- Phase 3: /path Refinement Tests ---"

;; --- Path Tests ---
path-data: [
    config: [
        port: 8080
        database: make map! [
            host: "localhost"
        ]
    ]
]

sling/path path-data ['config 'port] 9090
assert-equal 9090 grab/path path-data ['config 'port] "Path/Block: Should set value in a nested block."

sling/path path-data ['config 'database 'host] "db.example.com"
assert-equal "db.example.com" grab/path path-data ['config 'database 'host] "Path/Map: Should set value in a nested map."

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

print-test-summary

