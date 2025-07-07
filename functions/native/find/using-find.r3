
REBOL [
    Title: "Understanding Rebol's `find` Function"
    Author: "Jules AI (based on your probes and feedback)"
    Date: 20-Jun-2025
    Purpose: {
        A demonstration script to explore the behavior of the `find`
        function in Rebol 3 (Oldes branch, REBOL/Bulk 3.19.0),
        highlighting its happy paths, quirks and common pitfalls
        for novice programmers.
    }
    Note: "Adheres to the r3oTop project development ruleset where applicable."
]

print "--- Exploring the Rebol `find` Function ---"
prin lf

;;-----------------------------------------------------------------------------
;; Setup: Sample Data Structures
;; We'll use a block with set-words (acting like an object/struct)
;; and a map (Rebol's associative array / dictionary).
;;-----------------------------------------------------------------------------
test-block: [
    name: "Alice"
    active: true
    level: 10
    config: none ;; 'none' is a word here, representing the concept of no value
]

test-map: make map! [
    name: "Alice"
    active: true
    level: 10
    config: none ;; 'none' is a word here in the map definition
]

print "Our sample block:"
probe test-block
prin lf

print "Our sample map:"
probe test-map
prin lf

;;-----------------------------------------------------------------------------
;;; 1. Happy Path: Finding Existing Keys
;;-----------------------------------------------------------------------------
print "--- 1. Happy Path: Finding Existing Keys ---"
prin lf

;; --- A. Finding a key in a BLOCK ---
print "--- A. Finding a key in a BLOCK ---"
print {^/When `find` searches a block for a 'word (like 'level), it looks for that word as a key (a set-word!).}
print {If found, `find` returns a new series (a block!) starting from that key-value pair.}

result-block-level: find test-block 'level
print "Finding 'level in test-block:"
probe result-block-level

print {^/This returned series is a "handle". You can use `second` on this handle to get the value associated with 'level.}
print "Value of 'level (using `second` on the result):"
probe second result-block-level
prin lf

;; --- B. Finding a key in a MAP ---
print "--- B. Finding a key in a MAP ---"
print {^/When `find` searches a map for a 'word (like 'active), it also looks for that word as a key.}
print {If found, `find` returns JUST THE KEY ITSELF (as a set-word!). It does NOT return a series handle like it does for blocks.}

result-map-active: find test-map 'active
print "Finding 'active in test-map:"
probe result-map-active

print {^/This result (`active:`) only tells you the key exists. You CANNOT use `second` on it directly to get the value.}
print ";; probe second result-map-active ;; <-- This would cause an ERROR!"
print {To get the value from a map after confirming the key exists, you typically use `select`.}
print "Value of 'active (using `select` on the original map):"
probe select test-map 'active
prin lf

;;-----------------------------------------------------------------------------
;;; 2. Happy Path: Key Not Found
;;-----------------------------------------------------------------------------
print "--- 2. Happy Path: Key Not Found ---"
prin lf
print {If `find` does not locate the item (e.g., a key that doesn't exist), it returns `none` (shown as `#(none)`).}

result-block-missing: find test-block 'missing-key
print "Finding 'missing-key in test-block:"
probe result-block-missing

result-map-missing: find test-map 'missing-key
print "Finding 'missing-key in test-map:"
probe result-map-missing
prin lf

;;-----------------------------------------------------------------------------
;;; 3. Quirk 1: "Key-Only Search" in Associative Structures (Blocks with set-words, Maps)
;;-----------------------------------------------------------------------------
print "--- 3. Quirk 1: Key-Only Search in Associative Structures ---"
prin lf
print {A major behavior to understand: `find` primarily looks for KEYS when searching blocks-with-set-words or maps.}
print {It does NOT search for the VALUES associated with those keys if you pass the value directly to `find`.}

print "--- C. Attempting to find the LOGIC value `true` in test-block ---"
result-block-true: find test-block true
print "Finding the value `true` in test-block:"
probe result-block-true
print {Result is `#(none)` because `true` is a VALUE of the key 'active, not a key itself, nor a standalone item in the block's top level.}
prin lf

print "--- D. Attempting to find the LOGIC value `true` in test-map ---"
result-map-true: find test-map true
print "Finding the value `true` in test-map:"
probe result-map-true
print {Result is `#(none)` for the same reason: `find` isn't looking at the map's values when searching for `true` directly.}
prin lf

print "--- E. Attempting to find the value `none` in test-block ---"
;; Note: our test-block has 'config: none'. 'none' here is a word.
;; If we search for the actual `none!` datatype:
result-block-none-val: find test-block none
print "Finding the `none!` DATATYPE in test-block (where config: 'none):"
probe result-block-none-val
print {Result is `#(none)`. Again, `find` doesn't look for this `none!` datatype in the value positions.}
print {If you wanted to find the WORD 'none, you would search for `'none` (a lit-word).}
probe find test-block 'config ;; This finds the key 'config
probe second (find test-block 'config) ;; This is the word 'none
prin lf

print "--- F. Attempting to find the value `none` in test-map ---"
result-map-none-val: find test-map none
print "Finding the `none!` DATATYPE in test-map (where config: 'none):"
probe result-map-none-val
print {Result is `#(none)` for the same reasons as the block.}
prin lf

print {IMPORTANT: This "Key-Only Search" behavior is why you CANNOT use `find data value` to check if a certain value exists within these types of structures.}
print {You would need to iterate through the structure and check values manually, or use a more specialized search function.}
print {This is a primary reason for creating wrapper functions around `find`.}
prin lf

;;-----------------------------------------------------------------------------
;;; 4. Quirk 2: "Inconsistent Handle" - Return type of `find` for block vs. map
;;-----------------------------------------------------------------------------
print "--- 4. Quirk 2: Inconsistent Handle (Return type for block vs. map) ---"
prin lf
print {As shown in section 1, the result of `find` when a key is found is different:}
print "- For BLOCKS (with set-words): `find` returns a SERIES starting at the key."
print "  Example for 'level in block: " probe find test-block 'level
print "- For MAPS: `find` returns just the KEY itself (as a set-word!)."
print "  Example for 'level in map:   " probe find test-map 'level
prin lf

print {This inconsistency is crucial because it dictates how you access the actual value:}
print "- Block: `value: second (find test-block 'key)` -- This works."
print "- Map:   `value: second (find test-map 'key)` -- THIS WOULD ERROR! (Key is not a series)."
print "         You must use `value: select test-map 'key` for maps after `find` confirms existence."
prin lf
print {This difference means any generic code trying to use `find` and then get the value needs to check the type of the data structure first and branch its logic, for example:}
print reform [
    "either block? data ["
    "    print {Value from block: } probe second (find data 'key)"
    "] ["
    "    print {Value from map: } probe select data 'key"
    "]"
]
print {This is another strong reason for using or creating wrapper functions that provide a consistent way to get values after a find.}
prin lf

;;-----------------------------------------------------------------------------
;;; 5. Limitation: No Deep Search
;;-----------------------------------------------------------------------------
print "--- 5. Limitation: No Deep Search ---"
prin lf
print {`find` operates on the top level of a series. It does not automatically search into nested structures.}
nested-block: [ a b [c d [e]] f ]
print "Our nested block:"
probe nested-block
print "Trying to find 'e (which is deeply nested):"
probe find nested-block 'e
print {Result is `#(none)` because 'e is not at the top level.}
prin lf

;;-----------------------------------------------------------------------------
;;; 6. A Note on `pick` and `select` (related to `find`'s purpose)
;;-----------------------------------------------------------------------------
print "--- 6. A Note on `pick` and `select` (and value normalization) ---"
prin lf
print {While `find` helps locate keys or check existence, `pick` (for blocks by index) and `select` (for blocks/maps by key) retrieve values.}
print {As per the Rebol Ruleset, `pick` and `select` can return `word!` versions of true, false, or none.}
print {It's essential to NORMALIZE these results if the actual datatype matters.}

normalize_value_demo: function [value_to_normalize] [ ;; Renamed param to avoid conflict with global 'value' if script were part of larger system
    print rejoin ["Original value: " mold value_to_normalize ", type: " mold type? value_to_normalize]
    local normalized ;; Explicitly declare local
    normalized: case [
        value_to_normalize = 'true  [true]
        value_to_normalize = 'false [false]
        value_to_normalize = 'none  [none]
        'else          [value_to_normalize]
    ]
    print rejoin ["Normalized value: " mold normalized ", type: " mold type? normalized]
    return normalized
]

print "^/Demonstrating normalization for 'active (true) from test-block:"
val-active-block: second (find test-block 'active) ;; `find` gives [active: true ...], `second` gives 'true (word!)
normalized-active: normalize_value_demo val-active-block 
prin lf

print "Demonstrating normalization for 'config (none) from test-map:"
val-config-map: select test-map 'config ;; `select` gives 'none (word!)
normalized-config: normalize_value_demo val-config-map
prin lf

print "--- End of `find` Demonstrations (part 1) ---"


print "^/=== `find` Demonstrations: The Definitive Guide (part 2) ==="

; --- Test Data ---
test-block: [ name: "Alice" active: true level: 10 config: none ]
test-map: make map! test-block
print ["^/Test Block:" mold test-block]
print ["Test Map:" mold test-map]

;-----------------------------------------------------------------------------
;;; 1. Happy Path: Finding Existing Keys
;-----------------------------------------------------------------------------
print "^/--- 1. Happy Path: Finding Existing Keys ---"

;; --- A. Finding a key in a BLOCK ---
print "^/--- A. Finding a key in a BLOCK ---"
print {^/When `find` searches a block for a 'word (like 'level), it looks for that word as a key (a set-word!).}
print {If found, `find` returns a new series (a block!) starting from that key-value pair.}

result-block-level: find test-block 'level
print "Finding 'level in test-block:"
probe result-block-level

print {^/This returned series is a "handle". You can use `second` on this handle to get the value associated with 'level.}
print "Value of 'level (using `second` on the result):"
probe second result-block-level
prin lf

;; --- B. Finding a key in a MAP ---
print "--- B. Finding a key in a MAP ---"
print {^/When `find` searches a map for a 'word (like 'active), it also looks for that word as a key.}
print {If found, `find` returns JUST THE KEY ITSELF (as a set-word!). It does NOT return a series handle like it does for blocks.}

result-map-active: find test-map 'active
print "Finding 'active in test-map:"
probe result-map-active

print {^/This result (`active:`) only tells you the key exists. You CANNOT use `second` on it directly to get the value.}
print ";; probe second result-map-active ;; <-- This would cause an ERROR!"
print {To get the value from a map after confirming the key exists, you typically use `select`.}
print "Value of 'active (using `select` on the original map):"
probe select test-map 'active
prin lf

;-----------------------------------------------------------------------------
;;; 2. Happy Path: Key Not Found
;-----------------------------------------------------------------------------
print "--- 2. Happy Path: Key Not Found ---"
print {^/If `find` does not locate the item (e.g., a key that doesn't exist), it returns `none` (shown as `#(none)`).}

result-block-missing: find test-block 'missing-key
print "Finding 'missing-key in test-block:"
probe result-block-missing

result-map-missing: find test-map 'missing-key
print "Finding 'missing-key in test-map:"
probe result-map-missing
prin lf

;-----------------------------------------------------------------------------
;;; 3. Quirk 1: "Key-Only Search" in Associative Structures
;-----------------------------------------------------------------------------
print "--- 3. Quirk 1: Key-Only Search in Associative Structures ---"
print {^/A major behavior to understand: `find` primarily looks for KEYS when searching blocks-with-set-words or maps.}
print {It does NOT search for the VALUES associated with those keys if you pass the value directly to `find`.}

print "^/--- C. Attempting to find the LOGIC value `true` in test-block ---"
result-block-true: find test-block true
print "Finding the value `true` in test-block:"
probe result-block-true
print {Result is `#(none)` because `true` is a VALUE of the key 'active, not a key itself.}
prin lf

print "--- D. Attempting to find the `none!` DATATYPE in test-map ---"
result-map-none-val: find test-map none
print "Finding the `none!` DATATYPE in test-map:"
probe result-map-none-val
print {Result is `#(none)`. Again, `find` doesn't look for this `none!` datatype in the value positions.}
print {This "Key-Only Search" behavior is a primary reason for creating wrapper functions.}
prin lf

;-----------------------------------------------------------------------------
;;; 4. Quirk 2: "Inconsistent Handle" - Return type of `find`
;-----------------------------------------------------------------------------
print "--- 4. Quirk 2: Inconsistent Handle (Return type for block vs. map) ---"
print {^/As shown in section 1, the result of `find` when a key is found is different:}
print "- For BLOCKS (with set-words): `find` returns a SERIES starting at the key."
print "  Example for 'level in block: " probe find test-block 'level
print "- For MAPS: `find` returns just the KEY itself (as a set-word!)."
print "  Example for 'level in map:   " probe find test-map 'level
print {^/This inconsistency is crucial because any generic code trying to use `find` needs to branch its logic based on the data type.}
prin lf

;-----------------------------------------------------------------------------
;;; 5. A Note on `pick` and `select` (and value normalization)
;-----------------------------------------------------------------------------
print "--- 5. A Note on `pick` and `select` (and value normalization) ---"
print {^/While `find` locates keys, `select` retrieves values. As per our ruleset, `select` can return `word!` versions of true, false, or none.}

normalize_value_demo: function [value_to_normalize] [
    print rejoin ["Original value: " mold value_to_normalize ", type: " mold type? value_to_normalize]
    normalized: case [
        value_to_normalize = 'true  [true]
        value_to_normalize = 'false [false]
        value_to_normalize = 'none  [none]
        'else          [value_to_normalize]
    ]
    print rejoin ["Normalized value: " mold normalized ", type: " mold type? normalized]
    return normalized
]

print "^/Demonstrating normalization for 'config (none) from test-map:"
val-config-map: select test-map 'config
normalized-config: normalize_value_demo val-config-map
prin lf

print "--- End of `find` Demonstrations (part 2) ---"
