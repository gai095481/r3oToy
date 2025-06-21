REBOL [
    Title: "The `grab` Function: A Generic Field and Key-Value Getter"
    Version: 0.2.2
    Author: "Multiple AI Assistants & Human Orchestrator"
    Date: 19-Jun-2025
    Status: "Release Candidate"
    File: %grab.r3
    Purpose: {
        A self-contained script to rigorously test, document and
        provide a reference implementation of the 'grab' function.
        It serves as the golden retriever of block fields and map values,
        offering safe, robust access to nested data structures.
    }
    Note: "Adheres to a custom Rebol 3 Oldes Development ruleset as defined by the r3oTop repo."
    Keywords: [field key get grab retrieve access read robust QA test function helper block map safety path]
]

;;-----------------------------------------------------------------------------
all-tests-passed?: true

;;-----------------------------------------------------------------------------
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

;;-----------------------------------------------------------------------------
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
;; IMPORTANT: Multiple expilcit return statements to avoid "fall-through" bugs
;; as documented in the tutorial: "explicit-returns verses fall through bug.md".
;; Refactoring this function to reduce the number of explict returns will
;; mostly result in a difficult to troubleshot and resolve defect.
;;-----------------------------------------------------------------------------
;; This function takes a data structure, a key and optional refinements.
;; Its logic is divided into two main modes: path traversal and single-level lookup.
;;
;; Check if the `/path` refinement is specified.
;; If `/path` is specified:
;;  First, it validates the `key`.  If the `key` is not a `block!` or is empty, the path is invalid.
;;  If the path is invalid, it returns the `default-value` if provided, otherwise `none`.
;;  If the path is valid, it iterates through each `step` in the path `key`.
;;   At each step, it recursively calls `grab` on the current data segment.
;;   If any step returns `none`, the traversal loop breaks immediately.
;;   If the current data segment is not a `block!` or `map!`, the path has reached a dead end and the loop breaks.
;;  After the loop, it returns the final value found or the `default-value` if the traversal failed and `/default` was used.
;;
;; If `/path` is NOT specified, it proceeds to single-level lookup:
;;  First, it validates the `data` input.  If it is not a `block!`, `map!` or `none!` then the lookup fails.
;;  If `data` is a `block!`:
;;   It checks the `key` type. `block!` and `decimal!` keys are invalid for block lookups and cause a failure.
;;   If the `key` is an `integer!`, it uses `pick` to get the value.  It then normalizes the result to convert any `word!` representations of `true`, `false` or `none` into their proper datatypes.
;;   If the `key` is a `word!`, it begins the sophisticated parsing logic.
;;    It first tries to evaluate the value as an expression (e.g., for `make map! [...]`).
;;    If evaluation fails (e.g., for a simple literal or a context-dependent alias), it safely falls back to selecting just the next literal value.
;;  If `data` is a `map!`:
;;   It uses `find` to check for the key's existence.
;;   If found, it uses `select` to get the value.
;;   It then normalizes the result, converting the special `word!`s (`'true`, `'false`, `'none`) that `select` returns for those values into their proper datatypes.
;; In any failure case during single-level lookup, it returns the `default-value` if provided, otherwise `none`.
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
;;; Full QA Test Suite
;;-----------------------------------------------------------------------------
print "=== Starting QA tests for `grab` ==="

print "^/--- Core Functionality Tests (Happy Path) ---"
core-data-block: [10 "hello" true 3.14]
assert-equal 10 grab core-data-block 1 "Core: Should get the first element."
assert-equal "hello" grab core-data-block 2 "Core: Should get a middle element."
assert-equal 3.14 grab core-data-block 4 "Core: Should get the last element."

print "^/--- Invalid Input Tests ---"
assert-equal none grab none 1 "Invalid Input: Should return none for a none block."
assert-equal "default" grab/default none 1 "default" "Invalid Input: Should return default for a none block."

print "^/--- Out-of-Bounds Index Tests ---"
assert-equal none grab core-data-block 0 "Out-of-Bounds: Should return none for index 0."
assert-equal none grab core-data-block -1 "Out-of-Bounds: Should return none for a negative index."
assert-equal none grab core-data-block 5 "Out-of-Bounds: Should return none for an index greater than length."
assert-equal "default" grab/default core-data-block 5 "default" "Out-of-Bounds: Should return default for an index greater than length."
assert-equal "default" grab/default core-data-block 0 "default" "Out-of-Bounds: Should return default for index 0."

print "^/--- Default Value Edge Case Tests ---"
assert-equal "fallback" grab/default core-data-block 99 "fallback" "Default: Should return the provided default value on failure."
assert-equal none grab/default core-data-block 99 none "Default: Should return `none` when it is explicitly provided as the default."
assert-equal true grab/default core-data-block 99 true "Default: Should handle a `true` logical as a default value."

print "^/--- Enhanced Edge Case Tests ---"
empty-data-block: []
assert-equal none grab empty-data-block 1 "Edge Case: Should return none for empty block access."
assert-equal "empty-default" grab/default empty-data-block 1 "empty-default" "Edge Case: Should return default for empty block access."

print "^/--- `/path` Refinement Support Tests ---"
path-data: make map! [
    config: [
        user: "test-user"
        port: 8080
        database: make map! [
            host: "localhost"
            type: "mysql"
        ]
        alias: user
    ]
    api-key: "xyz-123"
    flags: none
]

assert-equal 8080 (grab/path path-data ['config 'port]) "path!: Should get a value from a nested block."
assert-equal "localhost" (grab/path path-data ['config 'database 'host]) "path!: Should get a value from a deeply nested map."
assert-equal none (grab/path path-data ['config 'database 'password]) "path!: Should return none if path fails."
assert-equal "not-found" (grab/path/default path-data ['config 10 'password] "not-found") "path!: Should return default if path fails."
assert-equal "xyz-123" (grab/path path-data ['api-key]) "path!: Should work with a single-element path."
assert-equal none (grab/path path-data ['flags 'some-child]) "path!: Should fail gracefully if an intermediate value is none."
assert-equal none (grab/path path-data []) "path!: Should return none for an empty path."
assert-equal "invalid" (grab/path/default path-data "not-a-block" "invalid") "path!: Should return default if key is not a block."
;assert-equal "test-user" (grab/path path-data ['config 'alias]) "path!: Should handle word-based aliasing in blocks."

print "^/--- `map!` Support Tests (Core) ---"
test-map: make map! [name "Alice" age 30 active true]
assert-equal "Alice" grab test-map 'name "Map: Should get value by word key."
assert-equal 30 grab test-map 'age "Map: Should get integer value from map."
assert-equal true grab test-map 'active "Map: Should get logical value from map."
assert-equal none grab test-map 'missing "Map: Should return none for missing key."
assert-equal "default" grab/default test-map 'missing "default" "Map: Should return default for missing key."

print "^/--- Missing `map!` Support Tests (Core) ---"
test-map: make map! [name "Alice" age 30 active true]
assert-equal "Alice" grab test-map 'name "Map: Should get value by word key."
assert-equal 30 grab test-map 'age "Map: Should get integer value from map."
assert-equal true grab test-map 'active "Map: Should get logical value from map."
assert-equal none grab test-map 'missing "Map: Should return none for missing key."
assert-equal "default" grab/default test-map 'missing "default" "Map: Should return default for missing key."

print "^/--- WORD-BASED BLOCK ACCESS TESTS ---"
test-block: [name "Bob" age 25 city "Boston"]
assert-equal "Bob" grab test-block 'name "Block Word: Should get value by word key."
assert-equal 25 grab test-block 'age "Block Word: Should get integer value by word."
assert-equal "Boston" grab test-block 'city "Block Word: Should get string value by word."
assert-equal none grab test-block 'missing "Block Word: Should return none for missing word."
assert-equal "not-found" grab/default test-block 'missing "not-found" "Block Word: Should return default for missing word."

print "^/--- MIXED BLOCK ACCESS TESTS ---"
mixed-block: [42 "hello" true none [nested] make map! [key "value"]]
assert-equal 42 grab mixed-block 1 "Mixed: Should get integer at index 1."
assert-equal "hello" grab mixed-block 2 "Mixed: Should get string at index 2."
assert-equal true grab mixed-block 3 "Mixed: Should get logical at index 3."
assert-equal none grab mixed-block 4 "Mixed: Should get none value at index 4."
assert-equal [nested] grab mixed-block 5 "Mixed: Should get block at index 5."

print "^/--- LARGE INDEX TESTS ---"
assert-equal none grab [1 2 3] 1000 "Large Index: Should return none for very large index."
assert-equal none grab [1 2 3] -1000 "Large Index: Should return none for very negative index."
assert-equal "big-default" grab/default [1 2 3] 999 "big-default" "Large Index: Should return default for large index."

print "^/--- PATH WITH WORDS TESTS ---"
nested-word-structure: [user [name "Charlie" profile [email "charlie@test.com" settings [theme "dark"]]]]
assert-equal "Charlie" grab/path nested-word-structure ['user 'name] "Path Word: Should navigate using word path."
assert-equal "charlie@test.com" grab/path nested-word-structure ['user 'profile 'email] "Path Word: Should navigate deep word path."
assert-equal "dark" grab/path nested-word-structure ['user 'profile 'settings 'theme] "Path Word: Should navigate very deep word path."
assert-equal none grab/path nested-word-structure ['user 'missing] "Path Word: Should return none for missing word in path."

print "^/--- MIXED DATA TYPE TESTS ---"
mixed-path-structure: [[name "David"] [data [items ["first" "second" "third"]]]]
assert-equal "David" grab/path mixed-path-structure [1 'name] "Mixed Path: Should handle integer then word."
assert-equal "second" grab/path mixed-path-structure [2 'data 'items 2] "Mixed Path: Should handle word then integer."
assert-equal none grab/path mixed-path-structure [1 'missing] "Mixed Path: Should return none for missing mixed path."

print "^/--- EMPTY VALUE TESTS ---"
empty-values: ["" 0 false none]
assert-equal "" grab empty-values 1 "Empty: Should get empty string."
assert-equal 0 grab empty-values 2 "Empty: Should get zero integer."
assert-equal false grab empty-values 3 "Empty: Should get false logical."
assert-equal none grab empty-values 4 "Empty: Should get none value."

print "^/--- SINGLE ELEMENT TESTS ---"
single-block: [42]
single-map: make map! [only "value"]
assert-equal 42 grab single-block 1 "Single: Should get value from single-element block."
assert-equal none grab single-block 2 "Single: Should return none for index beyond single element."
assert-equal "value" grab single-map 'only "Single Map: Should get value from single-key map."

print "^/--- PATH EDGE CASES ---"
assert-equal none grab/path [] [] "Path Edge: Should return none for empty block with empty path."
assert-equal "empty-default" grab/path/default [] [] "empty-default" "Path Edge: Should return default for empty block with empty path."

deeply-nested: [[[[["deep-value"]]]]]
assert-equal "deep-value" grab/path deeply-nested [1 1 1 1 1] "Deep Path: Should navigate very deep structure."
assert-equal none grab/path deeply-nested [1 1 1 1 2] "Deep Path: Should return none for invalid deep path."

print "^/--- NESTED MAP TESTS ---"
map-in-block: [make map! [id 1 name "Alice"] make map! [id 2 name "Bob"]]
;assert-equal 1 grab/path map-in-block [1 'id] "Nested Map: Should access map within block."           ;; CURRENTLY UNSUPPORTED.
;assert-equal "Bob" grab/path map-in-block [2 'name] "Nested Map: Should access second map in block."  ;; CURRENTLY UNSUPPORTED.

block-in-map: make map! [users [["Alice" 30] ["Bob" 25]] settings [theme "light"]]
assert-equal "Alice" grab/path block-in-map ['users 1 1] "Map Block: Should access block within map."
assert-equal 25 grab/path block-in-map ['users 2 2] "Map Block: Should access nested values in map block."

print "^/--- INVALID FIELD TYPE TESTS ---"
assert-equal none grab [1 2 3] "invalid-field-type" "Invalid Field: Should return `none` for string field on block."
assert-equal none grab [1 2 3] 3.14 "Invalid Field: Should return `none` for decimal field."
assert-equal "type-default" grab/default [1 2 3] [invalid] "type-default" "Invalid Field: Should return the default for block field on non-path call."

print-test-summary

