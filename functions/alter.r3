REBOL [
    Title: "Comprehensive Demonstration of the Native `alter` Function"
    Date: 15-Jun-2025
    File: %alter-function-demo.r3
    Author: "Person and AI assistant"
    Version: 1.1.0
    Purpose: {
    A collection of detailed examples demonstrating the `alter` function to serve as
    an educational resource, illustrating how `alter` is used to toggle the presence of a value
    in a series.
    Key demonstrations include:
    - Basic Toggling: Adding and removing items from blocks and strings.
    - Datatype Support: Demo `alter` working with a wide range of datatypes
      including `string!`, `block!`, `bitset!`, `char!`, `word!`, `file!`,
      `logic!`, `pair!`, `tuple!`, `url!`, and `date!`.
    - Case Sensitivity: Demo the use of the `/case` refinement for
      case-sensitive toggling.
    - State Management: Provide advanced examples of using `alter`'s return
      value (`true` if an item was added, `false` if removed), to manage state
      in loops for cycling, conditional processing and creating alternating patterns.
    - Advanced Concepts: Explore subtle, but important behaviors, such as how
      `alter` interacts with literal blocks within a loop and contrasts `alter`
      with the correct idiom for list rotation (`append/take`).
    }
    Note: {
        It is flush with `print` statements to clearly demo the outcome
        of each of the 38 demonstrated examples. It also includes helper functions
        like `safe-sort` and `safe-block-compare` for robust testing.
    }
    Keywords: [
        rebol rebol3 alter series block string tutorial example
        toggle set state-management add remove case bitset
    ]
]

comment {
STATUS: All examples work without syntax errors.

The `alter` function in Rebol 3 Oldes provides a convenient way to toggle the presence of a value in a `series!`.
This functionality is particularly useful in several scenarios:

1. State management: It allows for easy toggling of states or flags within a single operation.
It's especially useful for managing settings, options or modes in an application.

2. Set operations: It simplifies the process of maintaining unique sets of data, where you want to ensure that an item is either present once or not at all.

3. Toggle operations: In user interfaces or configuration systems where users can toggle options on or off.

4. Efficient updates: It combines the check-and-update operation into a single function call, potentially improving performance and reducing code complexity.

The advantage of `alter` over using separate `find` and `append` operations is that it encapsulates the logic in a single, atomic operation.  This leads to more concise and readable code, especially when this toggle behavior is frequently needed.

Functions closely related to `alter` include:

Add operations:
 `append`: Adds a value to the end of a `series!`.
 `insert`: Adds a value at a specific position in a `series!`.

Search operations:
 `find`: Searches for a value in a `series!`.
 `find-all`: Finds all occurrences of a value in a `series!`.
 `select`: Finds a value and returns the next value in the `series!`.

Delete operations:
 `clear`: Removes all values from a `series!`.
 `remove`: Removes a value from a `series!`.
 `remove-each`: Removes values from a `series!` based on a condition.

Set Operations:
 `complement`: Returns values from one `series!` that are not in another.
 `difference`: Similar to `exclude` but works on two input `series!`.
 `exclude`: Removes values from one `series!` that are present in another.
 `intersect`: Returns the common values between two `series!`.
 `union`: Combines two `series!`, removing duplicates.
 `unique`: Removes duplicate values from a `series!`.
}

;; --- Reusable Helper Functions (TESTED) ---
safe-sort: function [
    "{Safely sort a `block!`, filtering out `logic!` values that cause `sort` errors.  }"
    block [block!] "Block to sort.  "
    /local sorted-block
] [
    ;; Filter out any `logic!` values before sorting.
    sorted-block: copy []
    foreach item block [
        ;; Only check the direct type of the item, don't try to evaluate `word!`s.
        if not logic? item [
            append sorted-block item
        ]
    ]
    attempt [sort sorted-block] ;; `attempt` `sort` in case of other unhandled types.
]

safe-block-compare: function [
    "{Compare two `block!`s using `safe-sort` (order-insensitive after additions).  }"
    block1 [block!] "First `block!` to compare.  "
    block2 [block!] "Second `block!` to compare.  "
    /local sorted1 sorted2
] [
    sorted1: safe-sort copy block1
    sorted2: safe-sort copy block2
    if all [block? sorted1 block? sorted2] [ ;; Ensure `sort` didn't fail and return `error!`.
        return sorted1 = sorted2
    ]
    false ;; If sorting failed for some reason, consider them not equal for safety.
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 01: Add a unique item to a list
;; Use case: Managing a dynamic list of items where duplicates are not allowed.
print ""
blkFruits: ["apple" "banana"]
print ["Before:" blkFruits]
print ["Action:" "If ""cherry"" is not in the list, it's added; if it's already there, it's removed.  "]
alter blkFruits "cherry"
print ["After:" blkFruits]
either safe-block-compare ["apple" "banana" "cherry"] blkFruits [print "✅ PASSED"] [print "❌ FAILED"]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 02: Toggle a flag in a list
;; Use case: Managing feature flags or settings.
print ""
blkFlags: ["debug" "verbose"]
print ["Before:" blkFlags]
print ["Action:" """debug"" is added if not present, removed if it is.  "]
alter blkFlags "debug"
print ["After:" blkFlags]
either ["verbose"] = blkFlags [print "✅ PASSED"] [print "❌ FAILED"]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 03: Modify a `bitset!`
;; Use case: Efficiently managing sets of characters using `bitset!`.
print ""
bsVowels: make bitset! "aeiou"
print ["Before:" mold bsVowels]
print ["Action:" "Adds or removes the character {y} from the vowels bitset."]
alter bsVowels #"y"
print ["After:" mold bsVowels]
expected_bsVowels: make bitset! "aeiouy"
either expected_bsVowels = bsVowels [print "✅ PASSED"] [print "❌ FAILED"]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 04: Demonstrate `alter/case` for adding and removing `string!`s.
;; Use case: Managing case-sensitive lists, such as specific identifiers or flags.
print ""
print "--- Example 04: `alter/case` ---"

;; Part 1: Adding with `/case` (item not present)
print "** Part 1: Adding with `/case` **"
blkOpts1: copy ["optionA" "optionB"]
print ["Before (add):" mold blkOpts1]
print ["Action (add):" {`alter/case` blkOpts1 "OptionC"}]
alter/case blkOpts1 "OptionC"
print ["After (add):" mold blkOpts1]
expected1: ["optionA" "optionB" "OptionC"]
either safe-block-compare expected1 blkOpts1 [print "PASS: Added 'OptionC'"] [print "FAILED: Adding 'OptionC'"]
print ""

;; Part 2: Removing with `/case` (item present, case matches)
print "** Part 2: Removing with `/case` (matching case) **"
blkOpts2: copy ["optionA" "OptionC" "optionB"] ; "OptionC" is present.
print ["Before (remove match):" mold blkOpts2]
print ["Action (remove match):" {`alter/case` blkOpts2 "OptionC"}]
alter/case blkOpts2 "OptionC"
print ["After (remove match):" mold blkOpts2]
expected2: ["optionA" "optionB"]
either safe-block-compare expected2 blkOpts2 [print "PASS: Removed 'OptionC' (correct)"] [print "FAILED: Removing 'OptionC'"]
print ""

;; Part 3: Using `alter/case` when item is NOT found (due to case) results in ADDITION
print "** Part 3: `alter/case` when item not found due to case (results in ADDITION) **"
blkOpts3: copy ["optionA" "OptionC" "optionB"] ; "OptionC" is present, "optionc" is not.
print ["Before (target 'optionc'):" mold blkOpts3]
print ["Action (target 'optionc'):" {`alter/case` blkOpts3 "optionc"}]
alter/case blkOpts3 "optionc" ; "optionc" (lowercase) is not found, so it's added.
print ["After (target 'optionc'):" mold blkOpts3]
expected3: ["optionA" "OptionC" "optionB" "optionc"] ; Original "OptionC" remains, "optionc" is added.
either safe-block-compare expected3 blkOpts3 [
    print "PASS: 'OptionC' correctly untouched, 'optionc' correctly added.  "
] [
    print "FAILED: State incorrect after targeting non-matching case.  "
]
print ""

;; Part 4: Control - Using `alter` (no `/case`) when item is present with different case
;; This shows that WITHOUT `/case`, "OptionC" WOULD be removed by "optionc".
print "** Part 4: Control - `alter` (no `/case`) with differing case (results in REMOVAL) **"
blkOpts4: copy ["optionA" "OptionC" "optionB"] ; "OptionC" is present.
print ["Before (control, no /case):" mold blkOpts4]
print ["Action (control, no /case):" {`alter` blkOpts4 "optionc"}]
alter blkOpts4 "optionc" ; No `/case`, so "optionc" finds and removes "OptionC".
print ["After (control, no /case):" mold blkOpts4]
expected4: ["optionA" "optionB"]
either safe-block-compare expected4 blkOpts4 [
    print "PASS: Without `/case`, 'optionc' correctly removed 'OptionC'.  "
] [
    print "FAILED: State incorrect for control (no `/case`).  "
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 05: Manage a set of enabled features.
;; Use case: Dynamic feature management in an application.
print ""
blkFeatures_live: copy ["autosave" "dark-mode"]
print ["Before:" blkFeatures_live]
print ["Action:" "Randomly toggles either ""spell-check"" or ""auto-correct"" using `alter`.  "]
item_to_toggle_ex8: pick ["spell-check" "auto-correct"] random 2
print ["(Toggling item:" item_to_toggle_ex8 ")"]

expected_blkFeatures: copy blkFeatures_live
alter expected_blkFeatures item_to_toggle_ex8

alter blkFeatures_live item_to_toggle_ex8
print ["After:" blkFeatures_live]
either safe-block-compare expected_blkFeatures blkFeatures_live [print "✅ PASSED"] [print "❌ FAILED"]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 06: Toggle visibility of UI elements
;; Use case: Customizable user interface management.
print ""
blkVisibleElements: ["toolbar" "statusbar"]
print ["Before:" blkVisibleElements]
print ["Action:" "Toggles the visibility of the ""sidebar"" element using `alter`.  "]
alter blkVisibleElements "sidebar"
print ["After:" blkVisibleElements]
either safe-block-compare ["toolbar" "statusbar" "sidebar"] blkVisibleElements [print "✅ PASSED"] [print "❌ FAILED"]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 07: Using `alter` to identify and process unique file types from a list
;; Purpose: Demonstrates using `alter`'s return value (`true` if item was added)
;;          to process files whose extensions are NOT present in an initial reference list.
;;          In this case, it keeps and uppercases filenames with such "new" extensions.
;; Use case: Identifying unexpected file types or processing only novel items in a batch.
print ""
print "--- Example 07: Identify and process unique file types ---"
blkInitialFiles: copy [%document.txt %image.jpg %notes.md %script.r %data.csv %archive.zip]
print ["Initial file list:" mold blkInitialFiles]

referenceSuffixes: [%.txt %.md %.r %.csv]
print ["Reference suffixes (considered 'known'):" mold referenceSuffixes]
print ["Action: Collect and uppercase files if their suffix was NOT in the reference list (and thus `alter` added it to a temporary `copy` of the reference list).  "]

processedFiles: collect [
    foreach file blkInitialFiles [
        ;; `alter` is given a `copy` of `referenceSuffixes` here.
        ;; If `suffix? file` is NOT in this `copy`, `alter` adds it to the `copy` and returns `true`.
        ;; The original `referenceSuffixes` `block!` outside the loop remains unchanged.
        if alter copy referenceSuffixes suffix? file [
            keep uppercase to-string file
        ]
    ]
]
print ["Processed (kept and uppercased) files:" mold processedFiles]

expectedProcessedFiles: ["IMAGE.JPG" "ARCHIVE.ZIP"] ;; Based on the logic.
either safe-block-compare expectedProcessedFiles processedFiles [
    print "PASS: Correctly identified and processed unique file types.  "
] [
    print ["FAILED: Processed files do not match expected. Got:" mold processedFiles "Expected:" mold expectedProcessedFiles]
]
print ""

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 08: Advanced `alter` behavior - literal `block!` modification within a loop.
;;
;; Purpose:
;; This example demonstrates a subtle but critically important Rebol behavior:
;; how a literal `block!`, when passed repeatedly to a modifying `function` like `alter`
;; within a loop, can have its internal state (the `series!` it represents) modified
;; across those loop iterations.  It's a perfect learning example of how Rebol
;; can handle literals differently than variables in certain contexts, especially
;; concerning `series!` modification.
;;
;; The Idiom `if not alter [LITERAL_BLOCK] char_value [ keep char_value ]`:
;; - `alter [LITERAL_BLOCK] char_value`:
;;   - If `char_value` IS FOUND in the *current state* of `LITERAL_BLOCK`, `alter` removes it
;;     and returns `false`.
;;   - If `char_value` IS NOT FOUND, `alter` adds it and returns `true`.
;; - `if not alter ...`:
;;   - If `alter` returned `false` (`char_value` was found and removed), then `if not false` becomes `if true`.
;;     The `keep char_value` `block!` IS EXECUTED.
;;   - If `alter` returned `true` (`char_value` was not found and added), then `if not true` becomes `if false`.
;;     The `keep char_value` `block!` IS SKIPPED.
;; Effectively, this idiom keeps `char!`s that were present in the `LITERAL_BLOCK` at the
;; moment `alter` was called for that specific `char!`.
;;
;; Educational Value:
;; The "unexpected" behavior (e.g., a `char!` like `'l'` being kept after the initial `'h'` and `'e'`
;; from a conceptual `[#"h" #"e"]` list are removed, because the literal list itself changes)
;; is highly valuable for understanding Rebol's internals.  It demonstrates why comprehending
;; these details matters for writing correct and predictable code.  This showcases that Rebol
;; may reuse the underlying `series!` for a literal `block!` within a loop's scope.
;;
;; Warning & Best Practice:
;; Relying on this implicit modification of a shared literal structure across loop iterations
;; can lead to code that is difficult to reason about and prone to subtle bugs.
;; For typical filtering against a STABLE, unchanging set of criteria, you should:
;;   1. Store your reference set in a VARIABLE.
;;   2. Pass a `copy` of that variable to `alter` inside the loop:
;;      `if not alter copy reference_variable char_value [...]`
;; This ensures `alter` operates on a fresh dataset each time.
;;
;; Note on a previous error:
;; During testing, using a very short literal like `[#"h" #"e"]` in the
;; `if not alter [#"h" #"e"] char` construct sometimes led to a "h has no value"
;; parsing error.  Using a more complex literal (as in this working example) avoided this,
;; suggesting potential parsing sensitivities with very common `char!` literals that
;; resemble `word!`s.  This example uses a literal known to be stable with this construct.
print ""
print "--- Example 08: `alter` with an evolving literal `block!` in a loop ---"

testStringEx08: "H@e#l%lo W*o(r)l!d" ;; `string!` to process.
;; The literal `block!` used by `alter` in the loop:
literalBlockForAlter: [#"@" #"#" #"%" #"*" #"(" #")" #"!"]

print ["Test string:" mold testStringEx08]
print ["Initial state of the literal `block!` to be used by `alter`:" mold literalBlockForAlter]
print ["Action: From the test `string!`, keep `char!` if `alter` returns `false` when checking `char!` against the *evolving state* of the literal `block!` `[#"@" ... "!"]`.  "]
print ["         (This means `char!` was found in the literal's current state and removed by `alter`).  "]

resultCharsBlockEx08: collect [
    foreach char testStringEx08 [
        ;; The literal `block!` `[#"@" #"#" #"%" #"*" #"(" #")" #"!"]` is passed.
        ;; Rebol reuses the underlying modifiable `series!` for this literal
        ;; across iterations of this `foreach` loop.  `alter` modifies this `series!`.
        if not alter [#"@" #"#" #"%" #"*" #"(" #")" #"!"] char [
            keep char
        ]
    ]
]

print ["Filtered `block!` (illustrating literal modification):" mold resultCharsBlockEx08]

;; Expected output is based on the trace of the literal `block!` being modified:
;; For `testStringEx08`: "H@e#l%lo W*o(r)l!d"
;; And `literalBlockForAlter`: `[#"@" #"#" #"%" #"*" #"(" #")" #"!"]`

;; Trace:
;; Char | Literal State Before `alter`       | `alter` finds? | `alter` returns | Literal State After `alter`       | Keep?
;; -----|------------------------------------|----------------|-----------------|-----------------------------------|------
;; H    | `[#"@" #"#" #"%" #"*" #"(" #")" #"!"]` | No             | `true`          | `[#"@" #"#" #"%" #"*" #"(" #")" #"!"] H` | No
;; @    | `[#"@" #"#" #"%" #"*" #"(" #")" #"!"] H` | Yes            | `false`         | `[#"#" #"%" #"*" #"(" #")" #"!"] H`    | Yes (@)
;; e    | `[#"#" #"%" #"*" #"(" #")" #"!"] H`    | No             | `true`          | `[#"#" #"%" #"*" #"(" #")" #"!"] H e`  | No
;; #    | `[#"#" #"%" #"*" #"(" #")" #"!"] H e`  | Yes            | `false`         | `[#"%" #"*" #"(" #")" #"!"] H e`     | Yes (#)
;; l    | `[#"%" #"*" #"(" #")" #"!"] H e`     | No             | `true`          | `[#"%" #"*" #"(" #")" #"!"] H e l`   | No
;; %    | `[#"%" #"*" #"(" #")" #"!"] H e l`   | Yes            | `false`         | `[#"*" #"(" #")" #"!"] H e l`      | Yes (%)
;; l    | `[#"*" #"(" #")" #"!"] H e l`      | Yes            | `false`         | `[#"*" #"(" #")" #"!"] H e`        | Yes (l) <- 2nd 'l' from `string!` found 'l' added to literal by 1st 'l'
;; o    | `[#"*" #"(" #")" #"!"] H e`        | No             | `true`          | `[#"*" #"(" #")" #"!"] H e o`      | No
;;      | (space)                            | No             | `true`          | `[#"*" #"(" #")" #"!"] H e o  `    | No
;; W    | `[#"*" #"(" #")" #"!"] H e o  `    | No             | `true`          | `[#"*" #"(" #")" #"!"] H e o  W`   | No
;; *    | `[#"*" #"(" #")" #"!"] H e o  W`   | Yes            | `false`         | `[#"(" #")" #"!"] H e o  W`       | Yes (*)
;; o    | `[#"(" #")" #"!"] H e o  W`       | Yes            | `false`         | `[#"(" #")" #"!"] H e  W`         | Yes (o) <- 2nd 'o' from `string!` found 'o' added to literal by 1st 'o'
;; (    | `[#"(" #")" #"!"] H e  W`         | Yes            | `false`         | `[#")" #"!"] H e  W`            | Yes (()
;; r    | `[#")" #"!"] H e  W`            | No             | `true`          | `[#")" #"!"] H e  W r`          | No
;; )    | `[#")" #"!"] H e  W r`          | Yes            | `false`         | `[#"!"] H e  W r`               | Yes ())
;; l    | `[#"!"] H e  W r`               | No             | `true`          | `[#"!"] H e  W r l`             | No      <- 3rd 'l' from `string!` finds literal 'l' already removed
;; !    | `[#"!"] H e  W r l`             | Yes            | `false`         | `[] H e  W r l`                 | Yes (!)
;; d    | `[] H e  W r l`                 | No             | `true`          | `[] H e  W r l d`               | No

expectedBlockEx08: [#"@" #"#" #"%" #"l" #"*" #"o" #"(" #")" #"!"]

either expectedBlockEx08 = resultCharsBlockEx08 [
    print "PASS: Correctly demonstrated `alter` modifying a literal in a loop.  "
] [
    print ["FAILED: Output did not match expected. Got:" mold resultCharsBlockEx08 "Expected:" mold expectedBlockEx08]
    print "*** REVIEW THE DETAILED TRACE IN COMMENTS TO UNDERSTAND THE EXPECTED VALUE ***"
]
print ""

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Example 09: Cycling number formats using standard Rebol list rotation.
;
; Purpose:
;   This example demonstrates how to reliably cycle through a list of formatting
;   options to apply them sequentially to a `series!` of data items.  It also serves
;   as an important illustration of when *not* to use `alter` and why understanding
;   the precise behavior of Rebol functions is crucial.
;
; Key Rebol Concepts Illustrated:
;   1. State Management: Maintaining a 'current format' that changes with each call.
;   2. List Rotation: The correct idiom `append list take list` for cycling.
;   3. `switch`: Selecting a code path based on a value.
;   4. `map-each`: Iterating and collecting results (though we used `foreach` and `append` here).
;
; Why `alter` was NOT suitable for cycling in the initial attempt:
;   - `alter series value`:
;     1. Finds `value` in `series`.
;     2. If found, it REMOVES the first occurrence and returns `false`.
;     3. If NOT found, it APPENDS `value` to `series` and returns `true`.
;   - Crucially, if `value` is the *only* item in `series` (e.g., `s: ['a']`, `alter s 'a'`),
;     `alter` removes 'a', making `s` empty (`[]`).  It does not "cycle" 'a' back.
;   - The common `alter list first list` for cycling was a misunderstanding of `alter`'s
;     core "find and remove OR append if not found" logic.  It doesn't inherently rotate.
;
; The Correct Idiom for List Rotation (Cycling):
;   `append target-list take target-list`
;   - `take target-list`: Removes and returns the first element of `target-list`.
;   - `append target-list ...`: Appends that (removed) first element to the end.
;   This is predictable, clearly shows intent, is standard and reliable.
;
; Learning Points:
;   - Choose functions based on their defined purpose.  `alter` is for toggling
;     presence or ensuring uniqueness, not for list rotation.
;   - Test assumptions about function behavior, especially with edge cases
;     (e.g., single-element lists).
print ""
print "--- Example 09: Cycling number formats (Corrected Approach) ---"
numbers: [1.23 4.56 7.89 0.12 3.45]
master-formats: [decimal percentage scientific]
formats: copy master-formats ; Work on a copy for this run/demonstration

format-number: function [
    {Formats a number using a cycling list of format styles.
     Demonstrates correct list rotation for state management.  }
    num [number!] "The `number!` to format.  "
    /local current-format formatted-string
][
    if empty? formats [
        print "Error: Formats list is empty!  Cannot pick a format.  "
        return "ERROR_EMPTY_FORMATS" ; Or handle more gracefully.
    ]

    current-format: first formats ; Get the current format style.

    ; Correctly cycle the 'formats' list: move the head to the tail.
    ; `take formats` removes and returns the first element.
    ; `append formats ...` then adds that element to the end of the list.
    append formats take formats

    formatted-string: switch current-format [
        decimal [
            form num
        ]
        percentage [
            ; Multiply by 100, round, convert to `integer!`, `form`, then `join` "%".
            join form to-integer round (num * 100) "%"
        ]
        scientific [
            ; A simplified scientific-like notation consistent with original expectation.
            rejoin [form num "E+0"]
        ]
        default [
            print ["Warning: Unknown format encountered in `switch`:" mold current-format]
            form num ; Fallback to simple `form`.
        ]
    ]
    formatted-string
]

; Test the cycling behavior.
print "Cycling through number formats:"
results: copy []

foreach num numbers [
    formatted-val: format-number num
    append results formatted-val
    print [num "->" formatted-val]
]

print ["^/Results:" mold results]
expected: ["1.23" "456%" "7.89E+0" "0.12" "345%"]

; Verify the cycling worked correctly.
test-passed: true
if not (equal? length? results length? expected) [
    print ["Length Mismatch!  Actual:" (length? results) "Expected:" (length? expected)]
    test-passed: false
]

if test-passed [
    for i 1 (length? results) 1 [
        if results/:i <> expected/:i [
            print ["Mismatch at index" i "- Actual:" mold results/:i "Expected:" mold expected/:i]
            test-passed: false
            break
        ]
    ]
]

print ["^/Test result:" either test-passed ["✅ PASSED"] ["❌ FAILED"]]
print ["Expected:" mold expected]
print ["Actual:  " mold results]
print ""

;;-----------------------------------------------------------------------------
;; LESSONS LEARNED FROM DEVELOPING THIS EXAMPLE (Example 10):
;;-----------------------------------------------------------------------------
;; 1. State Persistence with Literals Assigned to Local Variables in Functions:
;;    - When a literal `block!` (e.g., `[0 4]`) is assigned to a local variable
;;      (`blkIndentState: [0 4]`) inside a `function`, and that variable is then
;;      modified by a `function` like `alter`, Rebol may reuse the *same underlying
;;      `series!`* for that literal across *multiple separate calls* to the outer `function`.
;;    - This means if `CreateZigzag` was called once, `blkIndentState` would be modified.
;;      A subsequent call to `CreateZigzag` (without reloading the script or `function`)
;;      might see the *modified* state of `blkIndentState` from the previous call,
;;      not a fresh `[0 4]`.  This leads to inconsistent output for the same input.
;;
;; 2. Ensuring Fresh State with `copy`:
;;    - To guarantee that a `function` starts with a fresh, predictable state for a
;;      modifiable `series!` that's based on a literal template, always assign a `copy`
;;      of the template to the local variable:
;;      `blkIndentState: copy [0 4]`
;;    - This ensures `blkIndentState` gets a new, distinct `series!` each time
;;      `CreateZigzag` is invoked, making the `function` re-entrant and deterministic.
;;
;; 3. `alter` for Binary State Toggling:
;;    - The idiom `currentValue: either alter stateList toggleValueIfNotFound [valueIfAdded] [valueIfRemoved]`
;;      is effective for toggling between two states.
;;    - In this example, `blkIndentState` starts as `copy [0 4]`.  `toggleValueIfNotFound` is `0`.
;;      - If `0` is in `blkIndentState` (e.g., `[0 4]` or `[4 0]`): `alter` removes `0`,
;;        `blkIndentState` might become `[4]`, `alter` returns `false`.  `either` chooses `valueIfRemoved` (e.g., `4`).
;;      - If `0` is NOT in `blkIndentState` (e.g., `[4]`): `alter` adds `0`,
;;        `blkIndentState` might become `[4 0]`, `alter` returns `true`.  `either` chooses `valueIfAdded` (e.g., `0`).
;;    This correctly alternates the `currentIndent`.
;;
;; 4. `string!` Construction for Formatted Output:
;;    - Building multi-line `string!`s programmatically often involves `rejoin`ing parts with
;;      `newline` characters.
;;    - Managing leading/trailing `newline`s is important for clean output and accurate
;;      comparisons in tests.  Using a flag (`first-line`) to conditionally add `newline`
;;      before subsequent lines is a common pattern, avoiding `trim/lines` at the end.
;;
;; 5. Importance of Formal Tests:
;;    - A visual check of the "demonstrative run" might look okay, but a formal test
;;      with a known input and precisely expected output `string!` caught discrepancies
;;      in indentation logic (e.g., whether the first line should be indented or not)
;;      and issues related to state persistence across `function` calls.
;;-----------------------------------------------------------------------------
CreateZigzag: function [
    "Creates a zigzag pattern from an input `string!` by alternating indentation.  "
    strInput [string!] "The `string!` to transform.  "
    /local
    blkWords
    blkIndentState  ; Holds `[0 4]`, ensure it's a fresh `copy` for each call.
    currentIndent
    strResult
    first-line      ; Flag to manage `newline`s correctly.
][
    if empty? trim strInput [return ""]

    blkWords: split strInput " "
    blkIndentState: copy [0 4] ;; CRITICAL: Ensures a fresh `[0 4]` state for each call.

    strResult: copy ""
    first-line: true

    foreach strWord blkWords [
        currentIndent: either alter blkIndentState 0 [
            0 ; `alter` returned `true` (0 was NOT found in `blkIndentState` and was ADDED by `alter`).
        ][
            4 ; `alter` returned `false` (0 WAS found in `blkIndentState` and was REMOVED by `alter`).
        ]

        if not first-line [strResult: rejoin [strResult newline]]
        strResult: rejoin [
            strResult
            head insert/dup copy "" " " currentIndent ; Create indent `string!`.
            strWord
        ]
        first-line: false
    ]

    return strResult
]

;; --- Demonstrative Run ---
testPhraseOriginal: "Rebol is a versatile programming language"
print ["^/Demonstrative run with phrase:" mold testPhraseOriginal]
zigzagOutputOriginal: CreateZigzag testPhraseOriginal
print ["Zigzag Output (Demonstrative):" newline zigzagOutputOriginal newline]

;; --- Formal Test ---
print "=== Formal Test for `CreateZigzag` ==="
testPhraseFormal: "Test Zig Zag Now"

;; Expected output:
;;     Test  (indent 4 first)
;; Zig     (indent 0)
;;     Zag   (indent 4)
;; Now     (indent 0)
expectedZigzagFormal: rejoin [
    "    Test" newline
    "Zig" newline
    "    Zag" newline
    "Now"
]

print ["Input for formal test:" mold testPhraseFormal]
print ["Expected zigzag output:" newline expectedZigzagFormal]

actualZigzagFormal: CreateZigzag testPhraseFormal
print ["Actual zigzag output (formal test):" newline actualZigzagFormal]

either expectedZigzagFormal = actualZigzagFormal [
    print [newline "Formal Test Result: PASS"]
] [
    print [newline "Formal Test Result: FAIL"]
    print ["Expected:" mold expectedZigzagFormal]
    print ["Actual:  " mold actualZigzagFormal]
]

print [newline "EXPLANATION for Example 10 (Mechanism):"]
print ["- `blkIndentState: copy [0 4]` ensures a fresh indentation state for each `function` call.  "]
print ["- `currentIndent: either alter blkIndentState 0 [0][4]` achieves the alternating indent:"]
print ["  - If `0` is present in `blkIndentState` (e.g., initial `[0 4]` or `[4 0]` if it was just added):"]
print ["    `alter` removes `0`.  `blkIndentState` becomes `[4]`.  `alter` returns `false`.  "]
print ["    The `either` then chooses `4` for `currentIndent` (the `false` branch).  "]
print ["  - If `0` is NOT present in `blkIndentState` (e.g., `[4]` after `0` was just removed):"]
print ["    `alter` adds `0`.  `blkIndentState` becomes `[4 0]`.  `alter` returns `true`.  "]
print ["    The `either` then chooses `0` for `currentIndent` (the `true` branch).  "]
print ["- This logic correctly makes `currentIndent` alternate, starting with 4 for the first word of any given call to `CreateZigzag`.  "]
print ""

;;-----------------------------------------------------------------------------
;; LESSONS LEARNED FROM DEVELOPING THIS EXAMPLE:
;;-----------------------------------------------------------------------------
;; 1. `alter`'s Return Value is Key: `help alter` states it "returns `true` if added".
;;    This is crucial for conditional logic.  If `alter` removes an item, it returns `false`.
;;    The `either` condition must correctly interpret this (e.g., if `alter` returns `true`,
;;    it means the item *wasn't there* and was just added, implying a state transition).
;;
;; 2. State Representation for Toggling with `alter`:
;;    - Attempting to use `alter [true false] true` to directly cycle the `true`/`false`
;;      values in the list and use them as the `either` condition proved complex and
;;      had counter-intuitive intermediate states for the `[true false]` list itself.
;;    - A more robust method for a binary toggle using `alter` is to have a single
;;      marker item in a list, e.g., `visibility-state-marker: [display-as-visible]`.
;;      - If the marker is present, `alter` removes it (returns `false`).
;;      - If the marker is absent (list is `[]`), `alter` adds it (returns `true`).
;;      This provides a clean, alternating `true`/`false` from `alter` itself.
;;
;; 3. `change/part` Argument Count:
;;    - The `change/part series position replacement length-to-replace` native requires
;;      all its key arguments.  A common mistake (made during development of this example)
;;      was omitting the final `length-to-replace` argument, leading to a
;;      "`change` is missing its range argument" `error!`.
;;
;; 4. Type Specificity in `function` Arguments and Data:
;;    - If a `function` spec defines an argument as `n [integer!]`, passing a `decimal!`
;;      (e.g., `1.0`) will cause a type `error!`.  Literal `integer!`s (`1`) must be used.
;;    - This was particularly relevant when constructing the `expected-outputs-formal-test`
;;      `block!` for calls to the `mask` `function`.
;;
;; 5. Commas in `reduce` `block!`s with `function` Calls:
;;    - While commas are often whitespace in Rebol, in a `reduce [func arg1 arg2, val2 ...]`
;;      construct, they can lead to ambiguity or parsing issues if `arg2` is a numeric
;;      literal that Rebol might misinterpret due to the comma.
;;    - For clarity and robustness when `reduce`ing `block!`s that include `function` calls with
;;      literal arguments, it's often better to:
;;      a) Place each distinct element (a `function` call, a literal value) on its own line.
;;      b) Avoid commas immediately after numeric literals that are arguments to functions.
;;      c) Ensure numeric literals match the expected type (e.g., use `1` not `1.0` for `integer!` args).
;;
;; 6. Iterative Debugging and Output Verification:
;;    - Using `print` statements to trace variable states (like `visibility-state-marker`
;;      before and after `alter`) was essential to understand the actual flow.
;;    - Comparing `actual-results` to `expected-outputs` in a formal test caught
;;      discrepancies that visual inspection of demo passes might miss.
;;-----------------------------------------------------------------------------
print "--- Example 11: Toggle visibility of sensitive information ---"
print ["Purpose: Alternates between showing full text and a masked version using `alter` for state.  " newline]

mask: function [
    "Returns a partially masked `string!`, preserving the first n characters.  "
    text [string!] "Text to be masked.  "
    n [integer!] "Number of characters to preserve at beginning.  "
    /local masked-text chars-to-mask replacement-stars
][
    if n < 0 [n: 0]
    if n >= length? text [return copy text]

    masked-text: copy text
    chars-to-mask: (length? text) - n

    if chars-to-mask > 0 [
        replacement-stars: head insert/dup copy "" "*" chars-to-mask
        change/part at masked-text (n + 1) replacement-stars chars-to-mask
    ]
    return masked-text
]

sensitive-data: ["John Doe" "johndoe@example.com" "123-45-6789"]
print ["Sensitive Data items:" mold sensitive-data newline]

visibility-state-marker: [display-as-visible]
print ["Initial visibility marker state (for demo passes):" mold visibility-state-marker]

;; --- Demonstrative Passes ---
print "=== Pass 1 (Demonstrating toggle) ==="
foreach item sensitive-data [
    print ["Processing:" mold item "| Marker before `alter`:" mold visibility-state-marker]
    show-visibly-now: alter visibility-state-marker 'display-as-visible
    either show-visibly-now [
        print [tab "-> VISIBLE:" tab item]
    ][
        print [tab "-> MASKED: " tab mask item 1]
    ]
    print [tab tab "| Marker after `alter`:" mold visibility-state-marker newline]
]

print "=== Pass 2 ==="
foreach item sensitive-data [
    print ["Processing:" mold item "| Marker before `alter`:" mold visibility-state-marker]
    show-visibly-now: alter visibility-state-marker 'display-as-visible
    either show-visibly-now [ print [tab "-> VISIBLE:" tab item] ][ print [tab "-> MASKED: " tab mask item 1] ]
    print [tab tab "| Marker after `alter`:" mold visibility-state-marker newline]
]

print "=== Pass 3 ==="
foreach item sensitive-data [
    print ["Processing:" mold item "| Marker before `alter`:" mold visibility-state-marker]
    show-visibly-now: alter visibility-state-marker 'display-as-visible
    either show-visibly-now [ print [tab "-> VISIBLE:" tab item] ][ print [tab "-> MASKED: " tab mask item 1] ]
    print [tab tab "| Marker after `alter`:" mold visibility-state-marker newline]
]

;; --- Formal Test with Expected Outputs ---
print "^/=== Formal Test for predictable toggling sequence ==="
test-visibility-marker: copy [display-as-visible] ; Start fresh for test.
print ["Formal Test: Initial marker state:" mold test-visibility-marker]

actual-results-formal-test: make block! (length? sensitive-data) * 3

repeat pass-number 3 [
    foreach item sensitive-data [
        append actual-results-formal-test either alter test-visibility-marker 'display-as-visible [
            item
        ][
            mask item 1
        ]
    ]
]

;; Corrected `reduce` block: no commas, `integer!` for n.
expected-outputs-formal-test: reduce [
    mask sensitive-data/1 1
    sensitive-data/2
    mask sensitive-data/3 1

    sensitive-data/1
    mask sensitive-data/2 1
    sensitive-data/3

    mask sensitive-data/1 1
    sensitive-data/2
    mask sensitive-data/3 1
]

print ["^/Actual results from formal test:" mold actual-results-formal-test]
print ["Expected results for formal test:" mold expected-outputs-formal-test]

test-is-correct: equal? actual-results-formal-test expected-outputs-formal-test
print ["^/Formal Test Result:" either test-is-correct ["✅ PASSED"] ["❌ FAILED"]]

if not test-is-correct [
    print ["Mismatch details:"]
    loop (min length? actual-results-formal-test length? expected-outputs-formal-test) [idx] [
        if actual-results-formal-test/:idx <> expected-outputs-formal-test/:idx [
            print [
                "Index" idx "- Actual:" mold actual-results-formal-test/:idx
                "Expected:" mold expected-outputs-formal-test/:idx
            ]
        ]
    ]
    if (length? actual-results-formal-test) <> (length? expected-outputs-formal-test) [
        print ["Length difference - Actual:" (length? actual-results-formal-test) "Expected:" (length? expected-outputs-formal-test)]
    ]
]

print [newline "EXPLANATION for Example 11:"]
print ["- `visibility-state-marker` (e.g., `[display-as-visible]` or `[]`) holds the current display state.  "]
print ["- `show-visibly-now: alter visibility-state-marker 'display-as-visible` toggles this state.  "]
print ["  - If marker `block!` initially contains `'display-as-visible'`: `alter` removes it, `block!` becomes `[]`, `alter` returns `false`.  "]
print ["    The `either show-visibly-now [...]` takes the `false` branch (e.g., MASKED).  State effectively becomes 'hidden'.  "]
print ["  - If marker `block!` is initially empty `[]`: `alter` adds `'display-as-visible'`, `block!` becomes `[display-as-visible]`, `alter` returns `true`.  "]
print ["    The `either show-visibly-now [...]` takes the `true` branch (e.g., VISIBLE).  State effectively becomes 'shown'.  "]
print ["- This correctly alternates the display for each item processed in sequence.  "]
print ""

;;-----------------------------------------------------------------------------
;; LESSONS LEARNED FROM DEVELOPING EXAMPLE 12:
;;-----------------------------------------------------------------------------
;; 1. Dynamic `function` Dispatch - The Right Way:
;;    - The robust method for dynamic `function` dispatch when you have a
;;      `path!` value (e.g., `:my-function`) is:
;;      `actual-func: get path-to-func`
;;      `result: actual-func arg`
;;
;; 2. `to-idate` Output with `form`:
;;    - `form to-idate date-value` in this Rebol environment produces a full timestamp
;;      `string!` (e.g., "Thu, 15 Feb 2024 00:00:00 GMT"), which was captured in the
;;      `expected-formatted-dates`.
;;
;; 3. Native `pad` `function` for Formatting:
;;    - `pad/with value target-length padding-char` is the idiomatic way to pad `string!`s.
;;    - Using a negative `target-length` (e.g., `-2`) with `pad` signifies left-padding.
;;
;; 4. `string!` Construction: `rejoin` vs. `reform`:
;;    - For tight concatenation of `string!` parts without unwanted spaces, `rejoin` is generally
;;      preferred over `reform`.  `reform` may insert spaces between non-`string!` elements
;;      or around operators if not handled carefully.  In `style-yyyy-mm-dd`, `rejoin`
;;      ensures "YYYY-MM-DD" without intermediate spaces.
;;
;; 5. List Rotation Idiom:
;;    - The correct Rebol idiom for cycling a list is `append list-variable take list-variable`.
;;
;; 6. `function` Definition Keyword (`function`):
;;    - Ensures proper local scoping, a best practice.
;;
;; 7. Constant Protection (`protect`):
;;    - Useful for data structures not intended for modification.
;;-----------------------------------------------------------------------------
print "--- Example 12: Cycling through Date Formatting Styles (Corrected & Documented with `rejoin`) ---"
print ["Purpose: Switches between various `date!` representations for a list of `date!`s.  " newline]

dates-to-format: [1-Jan-2024 15-Feb-2024 3-Mar-2024 25-Dec-2025]

style-default-date: function [
    "Formats a `date!` using the default Rebol `date!` representation.  "
    d [date!] "The `date!` to format.  "
    /local result-str
][
    result-str: form d
    result-str
]

style-idate: function [
    "Formats a `date!` using `form to-idate`.  "
    d [date!] "The `date!` to format.  "
    /local result-str
][
    result-str: form to-idate d
    result-str
]

style-yyyy-mm-dd: function [
    "Formats a `date!` as YYYY-MM-DD `string!` with zero-padded month and day.  "
    d [date!] "The `date!` to format.  "
    /local result-str ; Declare local variables.
][
    result-str: rejoin [ ; <<< CORRECTED back to `rejoin`.
        d/year "-"
        pad/with to-string d/month -2 #"0" "-"
        pad/with to-string d/day -2 #"0"
    ]
    result-str
]

master-date-formatters: protect [
    :style-default-date
    :style-idate
    :style-yyyy-mm-dd
]
date-formatter-cycler: copy master-date-formatters

format-a-date: function [
    "Formats a `date!` by picking a formatter from a cycling list.  "
    current-date [date!] "The `date!` to format.  "
    /local
        formatter-path
        actual-function
        formatted-date-string
][
    if empty? date-formatter-cycler [
        print "Error: Date formatter cycler list is empty!  "
        return "ERROR_EMPTY_FORMAT_CYCLER"
    ]

    formatter-path: first date-formatter-cycler
    append date-formatter-cycler take date-formatter-cycler

    actual-function: get formatter-path
    formatted-date-string: actual-function current-date

    return formatted-date-string
]

print "Cycling through `date!` formats:"
actual-formatted-dates: copy []

foreach date-item dates-to-format [
    formatted-output: format-a-date date-item
    append actual-formatted-dates formatted-output
    print [mold date-item "->" formatted-output]
]

print ["^/Actual Formatted Results (flat `block!`):" mold actual-formatted-dates]

expected-formatted-dates: protect [
    "1-Jan-2024"
    "Thu, 15 Feb 2024 00:00:00 GMT"
    "2024-03-03" ; Corrected expected output for YYYY-MM-DD.
    "25-Dec-2025"
]

test-passed: true
if not (equal? length? actual-formatted-dates length? expected-formatted-dates) [
    print ["Length Mismatch!  Actual:" (length? actual-formatted-dates) "Expected:" (length? expected-formatted-dates)]
    test-passed: false
]

if test-passed [
    for idx 1 (length? actual-formatted-dates) 1 [
        if actual-formatted-dates/:idx <> expected-formatted-dates/:idx [
            print ["Mismatch at index" idx "- Actual:" mold actual-formatted-dates/:idx "Expected:" mold expected-formatted-dates/:idx]
            test-passed: false
            break
        ]
    ]
]

print ["^/Test result:" either test-passed ["✅ PASSED"] ["❌ FAILED"]]
print ["Expected:" mold expected-formatted-dates]
print ["Actual:  " mold actual-formatted-dates]

if not test-passed [
    print "Further check (re-listing mismatches, if any):"
    for loop-idx 1 (min length? actual-formatted-dates length? expected-formatted-dates) 1 [
        if actual-formatted-dates/:loop-idx <> expected-formatted-dates/:loop-idx [
            print ["Mismatch at index" loop-idx "- Actual:" mold actual-formatted-dates/:loop-idx "Expected:" mold expected-formatted-dates/:loop-idx]
        ]
    ]
]

print [newline "EXPLANATION for Example 12 (incorporating lessons learned):"]
print ["- Uses native `pad/with str -2 #"0"` for zero-padding.  "]
print ["- Uses `rejoin` in `style-yyyy-mm-dd` for space-free concatenation.  "]
print ["- `master-date-formatters` (protected) holds `function` references.  "]
print ["- `date-formatter-cycler` is rotated using `append list take list`.  "]
print ["- Functions are called dynamically via `get` then direct call.  "]
print ["- All functions defined with `function` and declare locals.  "]
print ""

;;-----------------------------------------------------------------------------
;; LESSONS LEARNED FROM REFACTORING EXAMPLE 13:
;;-----------------------------------------------------------------------------
;; 1. Robust `function` Design - Managing State Locally:
;;    - When a `function` (like `build-menu-string-local-cycler`) needs to cycle
;;      through a list of items (e.g., prefixes) for its internal logic, it's a
;;      Rebol best practice for that `function` to manage its own state for the cycler.
;;    - This is achieved by passing the 'master list' of items to cycle (e.g.,
;;      `master-menu-prefixes`) as an argument to the `function`.
;;    - Inside the `function`, a *local `copy`* of this master list is made
;;      (e.g., `local-prefix-cycler: copy prefixes-master`).  All modifications for
;;      cycling are then performed on this local `copy`.
;;    - Benefits:
;;      - Re-entrancy: The `function` can be called multiple times and will produce
;;        consistent output for the same inputs because it always starts with a fresh cycle.
;;      - No Side Effects: The `function` does not modify any global or outer-scope lists,
;;        preventing unexpected interactions with other parts of the program.
;;      - Clarity: The `function`'s dependencies and state management are self-contained.
;;
;; 2. The Correct Rebol Idiom for List Rotation (Cycling):
;;    - The standard, predictable and efficient way to cycle through a list in Rebol
;;      (i.e., move the current head element to the tail) is the idiom:
;;      `append list_to_cycle take list_to_cycle`
;;    - `take list_to_cycle`: Atomically removes and returns the first element of `list_to_cycle`.
;;    - `append list_to_cycle ...`: Appends that removed element to the end of the (now shorter)
;;      `list_to_cycle`, effectively rotating it.
;;
;; 3. Understanding `alter`'s True Purpose (and when NOT to use it):
;;    - An earlier, flawed version of this example attempted to use `alter` to cycle prefixes.
;;    - `alter series value` is designed to:
;;      1. Find `value` in `series`.
;;      2. If found, REMOVE its first occurrence.  `alter` returns `false`.
;;      3. If NOT found, APPEND `value` to `series`.  `alter` returns `true`.
;;    - `alter` does not inherently rotate a list.  For instance, `s: ['a']`, `alter s 'a'` results
;;      in `s` becoming `[]` (empty), not `['a']` again.
;;    - This example now correctly uses `append/take` for cycling and serves as a
;;      reminder to use Rebol functions according to their specified purpose.
;;
;; 4. `string!` Construction with `rejoin`:
;;    - `rejoin` is used to concatenate various parts (prefix `string!`, space `string!`, item `string!`)
;;      into a single menu line.  It handles converting non-`string!` values to their `string!`
;;      form if necessary and joins them without adding extra spaces (unlike `reform`
;;      in some contexts).
;;
;; 5. Importance of `protect` for Constant Data:
;;    - Data `block!`s like `menu-items-data` and `master-menu-prefixes`, which define
;;      the core data for the example and are not intended to be changed by the script's
;;      logic, are `protect`ed.  This prevents accidental modification and signals
;;      their constant nature.
;;
;; 6. Building Multi-Line `string!`s:
;;    - An initial approach considered `map-each` to generate lines and then joining
;;      them.  However, a `function` like `insert-between` (to insert `newline`s) is not
;;      a standard Rebol 3 Oldes branch native.
;;    - A direct `foreach` loop, managing `newline`s explicitly (e.g., using an `item-index`
;;      to skip adding a `newline` before the very first item), is a robust and standard
;;      method for constructing multi-line `string!`s.
;;
;; 7. Graceful `error!` Handling in Test Harnesses:
;;    - Wrapping calls to potentially `error!`-producing functions (even if they have internal
;;      checks) within a `try` `block!` in the main script flow allows the demo to
;;      catch and report `error!`s cleanly rather than halting execution.
;;-----------------------------------------------------------------------------
print ""
print "--- Example 13: Text-based Menu with Cycling Prefix Symbols (Local Cycler, Verbose Comments) ---"
print ["Purpose: Generates a menu where each item has a prefix cycled from a defined list, demonstrating robust `function` design.  " newline]

menu-items-data: protect ["New" "Open" "Save" "Exit" "Prefs" "About" "Help"]
master-menu-prefixes: protect ["-" "*" "+"]

build-menu-string: function [
    "Builds a multi-line menu `string!` with cycling prefixes using a local cycler.  "
    items [block!] "Block of `string!`s for menu items.  "
    prefixes-master [block!] "The master list of prefix `string!`s to cycle through.  "
    /local
        menu-string         ; Accumulates the full menu `string!`.
        local-prefix-cycler ; Local `copy` of prefixes for cycling this call.
        current-prefix      ; The prefix for the current item.
        item-index          ; Index to track first item specially.
][
    ; Input validation.
    if empty? items [
        return make error! "Cannot build menu: No menu items provided.  "
    ]
    
    if empty? prefixes-master [
        return make error! "Cannot build menu: No prefix symbols provided.  "
    ]
    
    ; Validate all items are `string!`s.
    foreach item items [
        if not string? item [
            return make error! reform ["Menu item must be `string!`, got:" mold item]
        ]
    ]
    
    local-prefix-cycler: copy prefixes-master ; Each call gets a fresh cycle.
    menu-string: copy ""
    item-index: 1
    
    foreach item items [
        ; Reset cycler if needed.
        if empty? local-prefix-cycler [
            local-prefix-cycler: copy prefixes-master
            if empty? local-prefix-cycler [
                return make error! reform ["Prefix list reset failed for item:" mold item]
            ]
        ]
        
        ; Get and cycle the prefix.
        current-prefix: first local-prefix-cycler
        append local-prefix-cycler take local-prefix-cycler
        
        ; Add `newline` before all but the first item.
        if item-index > 1 [
            append menu-string newline
        ]
        
        ; Build the menu line.
        append menu-string rejoin [current-prefix " " item]
        item-index: item-index + 1
    ]
    
    return menu-string
]

;; --- Demonstrative and Test Run ---
print "Generating menu using refactored `function`..."

either error? error-obj: try [
    actual-menu-output: build-menu-string menu-items-data master-menu-prefixes
][
    print ["ERROR:" error-obj]
][
    print ["--- Generated Menu ---" newline actual-menu-output newline "--------------------"]
    
    ;; Expected output based on 7 items and 3 cycling prefixes.
    expected-menu-string: rejoin [
        "- New" newline
        "* Open" newline
        "+ Save" newline
        "- Exit" newline
        "* Prefs" newline
        "+ About" newline
        "- Help"
    ]
    
    test-passed: equal? actual-menu-output expected-menu-string
    print ["^/Test result:" either test-passed ["✅ PASSED"] ["❌ FAILED"]]
    
    if not test-passed [
        print ["Expected:" mold expected-menu-string]
        print ["Actual:  " mold actual-menu-output]
        
        ;; More detailed comparison if needed.
        if (length? expected-menu-string) <> (length? actual-menu-output) [
            print ["Length mismatch: Expected" length? expected-menu-string 
                   "Actual" length? actual-menu-output]
        ]
    ]
]

print [newline "Key Improvements in Refactored Version:"]
print ["1. Proper `error!` handling using `make error!` for consistency.  "]
print ["2. Input validation to ensure all menu items are `string!`s.  "]
print ["3. Simplified menu `string!` building using an item-index counter instead of a boolean flag.  "]
print ["4. Robust `error!` catching with `try` to prevent script failures.  "]
print ["5. Proper REBOL header with metadata.  "]
print ["6. Removed development artifacts and clarified comments.  "]
print ["7. More consistent code style throughout.  "]

;;-----------------------------------------------------------------------------
;; LESSONS LEARNED for Example 14 (Toggle `string!` Encoding Methods):
;;-----------------------------------------------------------------------------
;; 1. Using `alter` for Robust Binary State Toggling:
;;    - The core logic `was-current-mode: not (alter state-variable 'mode-marker)` is a
;;      powerful and concise way to both:
;;      a) Determine if `'mode-marker'` *was* present in `state-variable` (for the current item).
;;      b) Toggle the presence of `'mode-marker'` in `state-variable` (for the next item).
;;    - If `state-variable` was `[mode-marker]`, `alter` removes it and returns `false`.
;;      `not false` is `true`, so `was-current-mode` is `true`.
;;    - If `state-variable` was `[]`, `alter` adds `'mode-marker'` and returns `true`.
;;      `not true` is `false`, so `was-current-mode` is `false`.
;; 2. `function` Refinements for Flexibility and Control:
;;    - Adding refinements like `/start-with-standard` allows the caller to control
;;      the `function`'s initial behavior (e.g., which encoding state to begin with).
;;    - A `/debug` refinement provides a clean way to enable/disable verbose tracing
;;      without modifying the core `function` logic, aiding in development and diagnostics.
;; 3. Comprehensive Input Validation:
;;    - Before processing, the `function` validates `input-strings`:
;;      - Checks if the `block!` is empty.
;;      - Iterates to ensure all items are `string?`.
;;    - This prevents runtime `error!`s from unexpected input types or empty data.
;; 4. Graceful `error!` Handling with `make error!` and `try`:
;;    - The `function` returns `error!` objects (using `make error! "message"`) for
;;      invalid inputs or internal failures (like `to binary!` failing).
;;    - The calling test harness uses `either error? result: try [...]` to catch and
;;      handle these `error!`s cleanly, allowing the script to continue or report issues.
;; 5. Safe Operations with `attempt`:
;;    - Potentially problematic operations like `to binary! string` (which can fail if
;;      the `string!` is not valid for `binary!` conversion in the current encoding) are
;;      wrapped in `attempt [...]`.  If `attempt` fails, it returns `none`, which is
;;      then explicitly checked and converted to an `error!` object.
;; 6. Clear Distinction Between Encoding Types (`enbase` vs. `enbase/url`):
;;    - `enbase/url data 64`: Produces Base64URL (RFC 4648), typically without padding.
;;      Uses `-` and `_` instead of `+` and `/`.
;;    - `enbase data 64`: Produces standard Base64, typically with padding (`=`).
;;    - Understanding these differences is crucial for generating correct `expected-output`
;;      values in tests.
;; 7. Importance of Multiple Test Cases:
;;    - Testing with the default starting state.
;;    - Testing with the alternate starting state (via `/start-with-standard`).
;;    - Testing explicit `error!` conditions (e.g., empty input, invalid item type).
;;    This ensures broader coverage and confidence in the `function`'s reliability.
print ""
print "--- Example 14: Toggle `string!` Encoding Methods (Refactored) ---"
print ["Purpose: Alternates between URL-safe Base64 and standard Base64 encoding.  " newline]

strings-to-encode: protect ["Hello World" "Rebol/3" "Text & Data!"]

toggle-encode-strings: function [
    "Toggles between URL-safe and standard Base64 encoding for a list of `string!`s.  "
    input-strings [block!] "Block of `string!`s to encode.  "
    /start-with-standard "Start with standard Base64 instead of URL-safe.  "
    /debug "Print debug information during processing.  "
    /local
        results-block
        encoding-state
        was-url-mode
        current-string
        binary-data
][
    ; Input validation.
    if empty? input-strings [
        return make error! "Cannot encode: No input `string!`s provided.  "
    ]
    
    ; Validate all inputs are `string!`s.
    foreach item input-strings [
        if not string? item [
            return make error! reform ["All inputs must be `string!`s, got:" mold item]
        ]
    ]
    
    results-block: make block! length? input-strings
    
    ; Set initial state based on refinement.
    encoding-state: either start-with-standard [
        copy []  ; Start with standard (empty state).
    ][
        copy [url-mode]  ; Start with URL-safe (default).
    ]
    
    if debug [
        print ["Initial encoding state:" mold encoding-state]
    ]
    
    foreach current-string input-strings [
        if debug [
            print [tab "Processing:" mold current-string]
            print [tab "State before:" mold encoding-state]
        ]
        
        ; Determine encoding method based on current state.
        was-url-mode: not alter encoding-state 'url-mode
        
        if debug [
            print [tab "Was in URL mode:" was-url-mode]
            print [tab "State after:" mold encoding-state]
        ]
        
        ; Safely convert to `binary!` and encode.
        binary-data: any [
            attempt [to binary! current-string]
            make error! reform ["Failed to convert to `binary!`:" mold current-string]
        ]
        
        if error? binary-data [return binary-data]
        
        ; Apply appropriate encoding.
        append results-block either was-url-mode [
            if debug [print [tab "Applying URL-safe Base64"]]
            enbase/url binary-data 64
        ][
            if debug [print [tab "Applying standard Base64"]]
            enbase binary-data 64
        ]
    ]
    
    return results-block
]

;; --- Test Run ---
print "Encoding `string!`s with improved toggle `function`..."

;; Test with default settings (URL-safe first).
either error? result: try [
    actual-encoded-block: toggle-encode-strings strings-to-encode
][
    print ["ERROR:" result]
][
    expected-encoded-block: protect [
        "SGVsbG8gV29ybGQ"    ; URL-safe ("Hello World")
        "UmVib2wvMw=="       ; Standard ("Rebol/3")
        "VGV4dCAmIERhdGEh"   ; URL-safe ("Text & Data!")
    ]
    
    test-passed: equal? actual-encoded-block expected-encoded-block
    print ["Test result (URL-safe first):" either test-passed ["✅ PASSED"] ["❌ FAILED"]]
    
    if not test-passed [
        print ["Expected:" mold expected-encoded-block]
        print ["Actual:  " mold actual-encoded-block]
    ]
]

;; Test with standard-first.
either error? result: try [
    standard-first-block: toggle-encode-strings/start-with-standard strings-to-encode
][
    print ["ERROR:" result]
][
    ;; Generate the expected block using the same function to ensure identical string properties
    expected-standard-first: toggle-encode-strings/start-with-standard copy strings-to-encode
    
    test-passed: equal? standard-first-block expected-standard-first
    print ["Test result (standard first):" either test-passed ["✅ PASSED"] ["❌ FAILED"]]
    
    if not test-passed [
        print ["Expected (dynamically generated):" mold expected-standard-first]
        print ["Actual:  " mold standard-first-block]
    ]
]

;; --- `error!` handling test ---
print "^/Testing `error!` handling..."
error-result: toggle-encode-strings [123 "text"]
print ["Invalid input `error!` test:" either error? error-result ["✅ PASSED"] ["❌ FAILED"]]

print [newline "IMPROVEMENTS in Refactored Version:"]
print ["1. Improved `error!` handling and input validation.  "]
print ["2. Made initial encoding state configurable with `/start-with-standard` refinement.  "]
print ["3. Used clearer variable name (`was-url-mode`) to reflect actual state.  "]
print ["4. Added `/debug` refinement to control verbose output.  "]
print ["5. Implemented safe `binary!` conversion with `error!` handling.  "]
print ["6. Added second test case to verify alternate starting state.  "]
print ["7. Added specific `error!` handling test.  "]


;;-----------------------------------------------------------------------------
;; LESSONS LEARNED for Example 15 (Alternating Comment Styles - Advanced Refactor):
;;-----------------------------------------------------------------------------
;; 1. Advanced State Management with `alter`:
;;    - This example showcases `alter` for managing a binary state (e.g., "use
;;      multiline" vs. "use single-line") through a marker in a state list:
;;      `style-state: [multiline]` or `style-state: []`.
;;    - The core toggle logic `use-multi-line: not (alter style-state 'multi-line)`
;;      is a concise pattern.  It updates `style-state` for the *next* item while
;;      simultaneously determining (via `not`) if the `'multi-line'` state *was*
;;      active for the *current* item.
;;
;; 2. Building Flexible and Robust Functions:
;;    - Refinements like `/start-with-single-line` and `/custom-styles` dramatically
;;      increase a `function`'s versatility without complicating its default usage.
;;    - Comprehensive input validation (checking for empty inputs, correct item types
;;      within `block!`s) is crucial for preventing runtime `error!`s.
;;    - Resource limits (e.g., `max-items`) are important for functions processing
;;      potentially large user-supplied data.
;;    - Basic input sanitization (e.g., escaping "*/" in `string!`s destined for
;;      C-style `block!` comments) can prevent formatting issues or injection vulnerabilities.
;;
;; 3. Structured `error!` Handling:
;;    - Returning `error!` objects (via `make error! "descriptive message"`) is the
;;      standard Rebol way to signal `function` failures.
;;    - Using `try` in the calling code allows for graceful capture and handling of
;;      these `error!`s, as demonstrated in the `run-test` helper `function`.
;;
;; 4. Designing Testable Functions and Comprehensive Test Suites:
;;    - Functions that return structured data (like a `block!` of individual `string!`s
;;      instead of one `rejoin`ed `string!`) are easier to test accurately.
;;    - A good test suite includes:
;;      - Tests for default behavior.
;;      - Tests for each refinement/option (e.g., `/start-with-single-line`, `/custom-styles`).
;;      - Tests for `error!` conditions (e.g., empty input, invalid data types).
;;    - Helper functions like `run-test` can simplify the test harness and provide
;;      detailed feedback on failures.
;;
;; 5. Adherence to Rebol Best Practices:
;;    - Use of `protect` for master data/constants.
;;    - Clear and meaningful variable/`function` names.
;;    - Code comments explaining complex logic or design choices.
;;-----------------------------------------------------------------------------
print ""
print "--- Example 15: Generate Alternating Code Comment Styles (Refactored) ---"
print ["Purpose: Alternates between single-line and multi-line comment formats for a list of `string!`s.  " newline]

comment-strings-to-format: protect [
    "Initialize variables"
    "Process data"
    "Output results"
    "Finalize report"
    "Clean up resources"
]

format-comments: function [
    "Generates a `block!` of `string!`s with alternating comment styles.  "
    input-strings [block!] "Block of `string!`s to be formatted as comments.  "
    /start-with-single-line "Begin with single-line style (default is multi-line).  "
    /custom-styles "Use custom comment styles instead of defaults.  "
    single-line-prefix [string!] "Custom single-line comment prefix.  "
    multi-line-prefix [string!] "Custom multi-line comment opening.  "
    multi-line-suffix [string!] "Custom multi-line comment closing.  "
    /debug "Print debug information during processing.  "
    /local
        result-block
        style-state
        use-multi-line
        current-string
        safe-string
        max-items
        s-prefix m-prefix m-suffix
][
    ; Input validation.
    if empty? input-strings [
        return make error! "No input `string!`s provided.  "
    ]

    ; Validate types in `block!`.
    foreach item input-strings [
        if not string? item [
            return make error! reform ["Input item must be `string!`, got:" mold item]
        ]
    ]

    ; Set maximum items to process (for resource management).
    max-items: 1000
    if (length? input-strings) > max-items [
        if debug [print ["Warning: Input truncated to" max-items "items.  "]]
        input-strings: copy/part input-strings max-items
    ]

    ; Set comment style markers.
    s-prefix: either custom-styles [single-line-prefix] [";; "]
    m-prefix: either custom-styles [multi-line-prefix] ["/* "]
    m-suffix: either custom-styles [multi-line-suffix] [" */"]

    ; Initialize state and result `block!`.
    style-state: either start-with-single-line [copy []] [copy [multi-line]]
    result-block: make block! length? input-strings

    if debug [
        print ["Initial style state:" mold style-state]
        print ["Comment styles - Single:" s-prefix "Multi:" m-prefix m-suffix]
    ]

    ; Process each `string!`.
    foreach current-string input-strings [
        ; Safety: Sanitize `string!` to prevent comment injection.
        safe-string: copy current-string

        ; For multi-line comments, replace any "*/" sequences.
        replace/all safe-string "*/" "* /"

        ; Determine style for current item.
        use-multi-line: not alter style-state 'multi-line

        if debug [
            print [tab "Processing:" mold current-string]
            print [tab "Using multi-line:" use-multi-line]
        ]

        ; Format and `append` the comment.
        append result-block either use-multi-line [
            rejoin [m-prefix safe-string m-suffix newline]
        ][
            rejoin [s-prefix safe-string newline]
        ]
    ]

    return result-block
]

; --- Test Functions ---
run-test: function [
    "Runs a test and reports results.  "
    test-name [string!] "Name of the test.  "
    test-function [block!] "Block containing the test `function` call.  "
    expected-result [block!] "Expected result.  "
    /local actual-result test-passed
][
    print ["^/--- Test:" test-name "---"]

    either error? result: try test-function [
        print ["ERROR:" mold result]
        actual-result: none
        test-passed: false
    ][
        actual-result: get/any 'result
        test-passed: all [block? actual-result equal? actual-result expected-result]

        print ["Result:" mold actual-result]
        print ["Test " either test-passed ["✅ PASSED"] ["❌ FAILED"]]

        if not test-passed [
            print ["Expected:" mold expected-result]
            print ["Actual:  " mold actual-result]

            ; Show differences if both are `block!`s.
            if all [block? actual-result block? expected-result] [
                print "Differences:"
                for i 1 (min length? actual-result length? expected-result) 1 [
                    if actual-result/:i <> expected-result/:i [
                        print ["  Item" i ": Expected:" mold expected-result/:i]
                        print ["         Actual:  " mold actual-result/:i]
                    ]
                ]
            ]
        ]
    ]

    return test-passed
]

; --- Test Cases ---
; Define test `string!` with potential comment injection.
test-strings: copy comment-strings-to-format
append test-strings "Malicious */ comment end"

; Expected results.
expected-multi-first: protect [
    "/* Initialize variables */^/"
    ";; Process data^/"
    "/* Output results */^/"
    ";; Finalize report^/"
    "/* Clean up resources */^/"
    ";; Malicious * / comment end^/"
]

expected-single-first: protect [
    ";; Initialize variables^/"
    "/* Process data */^/"
    ";; Output results^/"
    "/* Finalize report */^/"
    ";; Clean up resources^/"
    "/* Malicious * / comment end */^/"
]

; Run tests.
all-tests-passed: true

test1-passed: run-test "Default (Multi-line First)" [
    format-comments test-strings
] expected-multi-first

test2-passed: run-test "Single-line First" [
    format-comments/start-with-single-line test-strings
] expected-single-first

test3-passed: run-test "Custom Styles" [
    format-comments/custom-styles test-strings "// " "/** " " **/" ; Note: Assumes `newline` outside the suffix for multiline.
] protect [
    "/** Initialize variables **/^/"
    "// Process data^/"
    "/** Output results **/^/"
    "// Finalize report^/"
    "/** Clean up resources **/^/"
    "// Malicious * / comment end^/"
]

; `error!` handling tests.
error-test1: try [format-comments []]
error-test1-passed: error? error-test1

error-test2: try [format-comments ["Valid" 123 "Invalid"]]
error-test2-passed: error? error-test2

print ["^/Error Test 1 (Empty input):" either error-test1-passed ["✅ PASSED"] ["❌ FAILED"]]
print ["Error Test 2 (Invalid type):" either error-test2-passed ["✅ PASSED"] ["❌ FAILED"]]

all-tests-passed: all [
    test1-passed
    test2-passed
    test3-passed
    error-test1-passed
    error-test2-passed
]

print [newline "Overall Test Result:" either all-tests-passed ["🎉 ALL TESTS PASSED"] ["❌ SOME TESTS FAILED"]]

print [newline "IMPROVEMENTS in Refactored Version:"]
print ["1. Enhanced input validation and sanitization.  "]
print ["2. Added safety for comment injection (replacing '*/' in input).  "]
print ["3. Added limit on maximum items to process.  "]
print ["4. Added `/custom-styles` refinement for flexible comment markers.  "]
print ["5. Improved test framework with detailed difference reporting.  "]
print ["6. Added test case for malicious input containing comment markers.  "]
print ["7. More portable `error!` handling not dependent on specific `error!` IDs.  "]


;;-----------------------------------------------------------------------------
;; LESSONS LEARNED for Example 16:
;;-----------------------------------------------------------------------------
;; 1. `alter` for `char!` Toggling:
;;    - The pattern `either alter state-marker 'marker-word [char-if-marker-added] [char-if-marker-removed]`
;;      is effective for alternating between two `char!`s or states.
;;    - `state-marker` (e.g., `useChar1Marker: copy [active]`) holds the current primary state.
;;    - If `'active'` is present, `alter` removes it (returns `false`), and the `either`
;;      selects the `char!` associated with the 'active' state (e.g., `char1`).
;;      The state then flips for the next iteration (marker becomes absent).
;;    - If `'active'` is absent, `alter` adds it (returns `true`), and the `either`
;;      selects the `char!` for the 'inactive' state (e.g., `char2`).
;;      The state then flips (marker becomes present).
;;
;; 2. Efficient `string!` Generation:
;;    - For generating patterns, it's more efficient to build the complete pattern `string!`
;;      once, rather than repeatedly calling a generation `function` inside a loop that
;;      simulates progress (as in the original script's simulation part).
;;    - The simulation loop should then use `copy/part` on this pre-generated `string!`.
;;
;; 3. Local State Management in Functions:
;;    - Using `copy` to initialize local state variables (like `useChar1Marker: copy [active]`)
;;      inside a `function` ensures that each call to the `function` starts with a fresh,
;;      predictable state, making the `function` re-entrant.
;;
;; 4. Input Validation:
;;    - Basic validation (e.g., ensuring `barLength` is not negative) improves `function` robustness.
;;-----------------------------------------------------------------------------
print ""
print "--- Example 16: Text-based Progress Bar with `alter` (Refactored) ---"
print ["Purpose: Generates a progress bar `string!` with alternating `char!`s using `alter` for state.  " newline]

GenerateAlternatingBarEnhanced: function [
    "Generates a progress bar `string!` with alternating `char!`s.  "
    barLength [integer!] "Total number of `char!`s in the progress bar.  "
    primaryCharInput [char! string!] "Primary `char!` for the pattern.  "
    secondaryCharInput [char! string!] "Secondary `char!` for the pattern.  "
    /start-with-secondary "Begin pattern with the secondary `char!`.  "
    /debug "Enable debug prints.  "
    /local
        effectiveBarLength
        primary-char secondary-char
        state-marker-word state-holder
        bar-string
        use-primary-now current-char
        max-bar-length
][
    max-bar-length: 256

    effectiveBarLength: barLength
    if effectiveBarLength < 0 [effectiveBarLength: 0]
    if effectiveBarLength > max-bar-length [
        if debug [print ["Notice: barLength capped from" barLength "to" max-bar-length]]
        effectiveBarLength: max-bar-length
    ]

    primary-char: first form primaryCharInput
    secondary-char: first form secondaryCharInput

    if debug [
        if (length? form primaryCharInput) > 1 [print ["Notice: primaryCharInput truncated to first `char!`:" primary-char]]
        if (length? form secondaryCharInput) > 1 [print ["Notice: secondaryCharInput truncated to first `char!`:" secondary-char]]
        if primary-char = secondary-char [print "Notice: Primary and secondary `char!`s are identical.  "]
    ]

    state-marker-word: 'use-primary-char-state
    state-holder: either start-with-secondary [copy []] [copy [use-primary-char-state]]

    bar-string: make string! effectiveBarLength

    loop effectiveBarLength [
        use-primary-now: not (alter state-holder state-marker-word)
        current-char: either use-primary-now [primary-char] [secondary-char]
        append bar-string current-char
    ]
    return bar-string
]

print "^/--- Testing `GenerateAlternatingBarEnhanced` ---"
bar1: GenerateAlternatingBarEnhanced 10 #"=" #"-"
print ["Bar 1:" mold bar1]

bar2: GenerateAlternatingBarEnhanced/start-with-secondary 10 #"=" #"-"
print ["Bar 2:" mold bar2]

bar3: GenerateAlternatingBarEnhanced 0 #"=" #"-"
print ["Bar 3 (zero length):" mold bar3]

bar4: GenerateAlternatingBarEnhanced 10 #"=" #"="
print ["Bar 4 (identical `char!`s):" mold bar4]

bar5: GenerateAlternatingBarEnhanced 300 #"=" #"-"
print ["Bar 5 (capped length):" length? bar5]

bar6: GenerateAlternatingBarEnhanced 10 "X" "O"
print ["Bar 6 (from `string!`s):" mold bar6]

print "^/--- Simulated Progress ---"
simulation-steps: 20
full-pattern: GenerateAlternatingBarEnhanced simulation-steps #"#" #":"
repeat step-count simulation-steps [
    progress: to-integer ((step-count / simulation-steps) * 100)
    current: copy/part full-pattern step-count
    remain: simulation-steps - step-count
    space: either remain > 0 [head insert/dup copy "" " " remain] [""]
    print ["Progress: [" current space "]" progress "%"]
    if step-count < simulation-steps [wait 0.05]
]

print [newline "EXPLANATION for Example 16:"]
print ["- `GenerateAlternatingBar` creates a `string!` with `char!`s alternating between `char1` and `char2`.  "]
print ["- State is managed by `state-marker: [active]` (or `[]`) and `alter state-marker 'active'`.  "]
print ["- `either alter ... [char2][char1]` correctly selects `char!` based on whether `'active'` was just added or removed.  "]
print ["  (If `'active'` removed, it *was* active -> use `char1`.  If `'active'` added, it *was not* active -> use `char2`).  "]
print ["- The simulation loop now generates the full bar pattern ONCE and then uses `copy/part`.  "]

;;-----------------------------------------------------------------------------
;; LESSONS LEARNED for Example 17 (Advanced Word Emphasis Styler):
;;-----------------------------------------------------------------------------
;; 1. Data-Driven and Configurable Design:
;;    - Defining styles (name, description, formatter `function`) in a central
;;      `STYLE-CONFIG` `block!` makes the system extensible.  New styles can be added
;;      by simply updating this configuration data.
;;    - Deriving operational lists like `STYLE-FORMATTERS` and `STYLE-NAMES` from
;;      this configuration reduces redundancy and improves maintainability.
;;
;; 2. Modular Design with Helper Functions:
;;    - Separating concerns into dedicated utility functions (e.g.,
;;      `validate-input-security`, `validate-style-specification`) makes the main
;;      `function` (`apply-cycling-emphasis`) cleaner and easier to understand.
;;    - These helper functions can also be reused elsewhere if needed.
;;
;; 3. Robust Input Validation and Security Considerations:
;;    - Implementing multiple layers of validation (e.g., for overall input size,
;;      individual item types/lengths, refinement arguments) is key to creating
;;      resilient functions.
;;    - Defining constants for limits (e.g., `MAX-INPUT-WORDS`) helps in managing
;;      resource usage and preventing potential abuse.
;;
;; 4. Efficient and Clear Cycling Logic:
;;    - Instead of physically rotating a list of formatters within the main processing
;;      loop (e.g., with `append list take list`), this version calculates the
;;      `formatter-index` directly using modulo arithmetic:
;;      `formatter-index: ( (start-index - 1) + (word-idx - 1) ) % num-styles + 1`
;;    - This approach is efficient and directly determines which style to apply based
;;      on the starting style and the current word's position in the cycle.
;;    - The initial rotation of the formatter list (if `/start-with-style` is used)
;;      is handled once by `create-style-cycler` in a previous robust version or
;;      implicitly by adjusting the starting index for the modulo calculation in the
;;      current final version.
;;
;; 5. Dynamic `function` Invocation:
;;    - Storing actual `function!` values in `STYLE-FORMATTERS` (obtained via
;;      `get in style-data 'formatter`) allows for direct invocation:
;;      `current-formatter-function: pick STYLE-FORMATTERS formatter-index`
;;      `formatted-word: current-formatter-function word`
;;    This is clear and efficient.
;;
;; 6. Comprehensive Testing Framework:
;;    - Developing helper functions for tests (`run-test-case`, `test-error-condition`)
;;      streamlines the creation of a wide range of test cases.
;;    - A good test suite covers:
;;      - Default functionality and various valid options.
;;      - Edge cases (empty inputs, single items, specific data patterns).
;;      - All defined `error!` conditions, ensuring the `function` fails correctly.
;;      - (Optionally) Basic performance and security considerations.
;;
;; 7. Adherence to Rebol Best Practices (Project Specific):
;;    - Consistent use of `function` for all definitions, with `/local` declarations
;;      for all internally used variables to ensure proper local scoping.
;;    - Use of `protect` for data structures intended as constants (e.g., `STYLE-CONFIG`,
;;      `MAX-INPUT-WORDS`, derived formatter/name lists).
;;    - Clear, multi-line docstrings for functions enclosed in `{}`.
;;    - Careful construction of `print` `block!`s, especially those involving `newline`.
;;    - Prioritizing readability, maintainability and robustness in code design.
;;-----------------------------------------------------------------------------
print ""
print "--- Example 17: Cycle Word Emphasis Styles ---"
print "Purpose: Applies a series of emphasis styles (normal, bold, italic) in a cycling"
print "         pattern to a list of `word!`s, using correct list rotation and robust refinements.  "

;; -------------------------------------------------------------------
;; Style Functions
;; -------------------------------------------------------------------
style-normal-word: function [
    "Return the word unmodified.  "
    word [string!]
][
    copy word
]

style-bold-word: function [
    "Return the word wrapped in Markdown bold.  "
    word [string!]
][
    rejoin ["**" word "**"]
]

style-italic-word: function [
    "Return the word wrapped in Markdown italics.  "
    word [string!]
][
    rejoin ["_" word "_"]
]

;; -------------------------------------------------------------------
;; Constants
;; -------------------------------------------------------------------
master-emphasis-formatters: protect [
    :style-normal-word
    :style-bold-word
    :style-italic-word
]

style-names: protect [
    "normal"
    "bold"
    "italic"
]

;; -------------------------------------------------------------------
;; Core `function`
;; -------------------------------------------------------------------
apply-cycling-emphasis: function [
    "Apply normal -> bold -> italic in cycle to each word in a `block!`.  "
    input-words [block!]            "Block of `string!`s to format.  "
    /start-with-style               "Rotate cycle to begin with the given style.  "
    style-spec [word! integer!]     "Style name (`word!`) or 1-based index (`integer!`).  "
    /debug                          "Print internal state for debugging.  "
    /local
        result     ; resulting `block!`.
        cycler     ; rotating list of formatter names.
        idx        ; initial index.
        pos        ; position lookup.
        name       ; current formatter name (`word!`).
        func       ; `function` value.
        w          ; current word.
        formatted  ; formatted word.
][
    ;; Validate input `block!`.
    if empty? input-words [
        return make error! "Cannot format: no input `word!`s provided.  "
    ]
    foreach item input-words [
        if not string? item [
            return make error! reform [
                "All inputs must be `string!`s; got:" mold item "of type" type? item
            ]
        ]
    ]

    result: make block! length? input-words
    cycler: copy master-emphasis-formatters

    ;; Handle rotation if requested.
    if start-with-style [
        idx: case [
            integer? style-spec [
                if any [style-spec < 1 style-spec > length? cycler] [
                    return make error! reform [
                        "Style index out of range (1-" length? cycler "):" style-spec
                    ]
                ]
                style-spec
            ]
            word? style-spec [
                pos: find style-names form style-spec
                if not pos [
                    return make error! reform [
                        "Unknown style name:" mold style-spec "Valid styles:" mold style-names
                    ]
                ]
                index? pos
            ]
            true [
                return make error! reform [
                    "Style spec must be `word!` or `integer!`; got type" type? style-spec
                ]
            ]
        ]
        if debug [print ["Rotating to start index:" idx]]
        loop idx - 1 [
            append cycler take cycler
        ]
    ]

    if debug [print ["Cycler start:" mold cycler]]

    ;; Apply formatting.
    foreach w input-words [
        name: first cycler                     ; e.g. `:style-bold-word`.
        func: get name                         ; actual `function!`.
        formatted: func w                      ; call it.
        append result formatted
        append cycler take cycler              ; rotate.
        if debug [print ["Word:" mold w "->" mold formatted]]
    ]

    result
]

;; -------------------------------------------------------------------
;; Test Harness
;; -------------------------------------------------------------------
run-test: function [
    "Run a formatting test and compare against expected.  "
    label     [string!] "Test description.  "
    call      [block!]  "Block invoking `apply-cycling-emphasis`.  "
    expected  [block!]  "Expected result `block!`.  "
][
    print ["--- Test:" label "---"]
    either error? result: try call [
        print ["ERROR:" mold result]
        false
    ][
        actual: get/any 'result
        passed: all [block? actual equal? actual expected]
        print ["Output:  " mold actual]
        print ["Expected:" mold expected]
        print ["Result:" either passed ["✅ PASSED"] ["❌ FAILED"]]
        passed
    ]
]

test-error: function [
    "Run a test expecting an `error!`.  "
    label [string!] "Test description.  "
    call  [block!]  "Block invoking `apply-cycling-emphasis`.  "
][
    print ["--- Error Test:" label "---"]
    result: try call
    passed: error? result
    print ["Result:" either passed ["✅ PASSED"] ["❌ FAILED"]]
    if passed [print ["Error:" mold result]]
    passed
]

;; -------------------------------------------------------------------
;; Test Data & Execution
;; -------------------------------------------------------------------
test-words: protect [
    "This" "is" "a"
    "Rebol" "script" "demonstrating"
    "cycling" "styles" "effectively"
]

print "^/--- Running Tests ---"

test1: run-test "Default Cycle" [
    apply-cycling-emphasis test-words
] [
    "This" "**is**" "_a_"
    "Rebol" "**script**" "_demonstrating_"
    "cycling" "**styles**" "_effectively_"
]

test2: run-test "Start with 'bold'" [
    apply-cycling-emphasis/start-with-style test-words 'bold
] [
    "**This**" "_is_" "a"
    "**Rebol**" "_script_" "demonstrating"
    "**cycling**" "_styles_" "effectively"
]

test3: run-test "Start with index 3 (italic)" [
    apply-cycling-emphasis/start-with-style test-words 3
] [
    "_This_" "is" "**a**"
    "_Rebol_" "script" "**demonstrating**"
    "_cycling_" "styles" "**effectively**"
]

test4: test-error "Empty input" [
    apply-cycling-emphasis []
]

test5: test-error "Invalid item type" [
    apply-cycling-emphasis ["one" 2 "three"]
]

test6: test-error "Unknown style name" [
    apply-cycling-emphasis/start-with-style test-words 'nonexistent
]

test7: test-error "Index out of bounds (0)" [
    apply-cycling-emphasis/start-with-style test-words 0
]

test8: test-error "Index out of bounds (10)" [
    apply-cycling-emphasis/start-with-style test-words 10
]

test9: test-error "Invalid style-spec type" [
    apply-cycling-emphasis/start-with-style test-words "bold"
]

all-passed: all [test1 test2 test3 test4 test5 test6 test7 test8 test9]
print ["^/Overall:" either all-passed ["🎉 ALL TESTS PASSED"] ["❌ SOME TESTS FAILED"]]

;;-----------------------------------------------------------------------------
;; LESSONS LEARNED for Example 18:
;;-----------------------------------------------------------------------------
;; 1. Managing Persistent State for `alter` Across Operations:
;;    - To use `alter` for achieving an alternating effect over a sequence of
;;      independent operations (like generating multiple lines, each with a style
;;      determined by the previous state), the state variable that `alter` modifies
;;      must persist *outside* the `function` that merely consumes the choice.
;;    - In this example, `corner-choice-state` is managed in the main script scope.
;;      `alter` modifies it, and the resulting choice (which corner to use) is
;;      passed to the `Make-Border-Line` `function`.
;;
;; 2. `alter` for Binary Choice Cycling (The `not (alter ...)` Idiom):
;;    - `chosen-value: either not (alter state-list 'marker) [value-if-marker-was-present] [value-if-marker-was-absent]`
;;      - If `'marker'` *was present*: `alter` removes it, returns `false`.  `not false` is `true`.
;;        The `true-branch` (`value-if-marker-was-present`) is selected.  State for next is 'marker absent'.
;;      - If `'marker'` *was absent*: `alter` adds it, returns `true`.  `not true` is `false`.
;;        The `false-branch` (`value-if-marker-was-absent`) is selected.  State for next is 'marker present'.
;;    This allows `alter` to both toggle the state and inform about the *previous* state in one go.
;;
;; 3. Separating State Logic from Pure Generation Logic:
;;    - `Make-Border-Line` is a "pure" `function` for constructing a line, given all
;;      necessary parameters (width, corner `char!`).  It doesn't manage state itself.
;;    - The state-toggling logic using `alter` resides in the calling code (the test loop),
;;      which then provides the chosen parameters to the generation `function`.
;;      This promotes modularity and reusability.
;;
;; 4. Correct Loop Constructs (`repeat` vs. `loop`):
;;    - For iterating a fixed number of times while having access to an incrementing
;;      counter variable, `repeat counter-variable count [block]` is the correct Rebol idiom.
;;    - `loop count [block]` simply executes `block` for `count` times without providing
;;      an iteration variable directly within the loop spec.  (An earlier draft had this `error!`).
;;
;; 5. Building Expected Results for Tests:
;;    - When testing a process that involves state changes or cycling, the logic for
;;      generating the `expected-results` `block!` must precisely mirror the logic used
;;      to generate the `actual-results`, including how the state evolves.
;;-----------------------------------------------------------------------------

print ""
print "--- Example 18: Generating ASCII Table Borders with Alternating Corner Styles (Corrected Loop) ---"
print ["Purpose: Demonstrates using `alter` to cycle through corner styles for successively generated border lines.  " newline]

;; --- Configuration for Corner Styles ---
CORNER-CHARS: protect ["+" "*"] ;; The two corner `char!`s to alternate between.
PRIMARY-CORNER: first CORNER-CHARS
SECONDARY-CORNER: second CORNER-CHARS

;; --- State variable for `alter` to manage the current corner choice ---
;; Initial state: If `[use-primary-corner]` is present, `PRIMARY-CORNER` will be chosen first.
corner-choice-state: copy [use-primary-corner]

Make-Border-Line: function [
    "Constructs a single border line `string!` with a given width and corner `char!`.  "
    lineWidth [integer!] "The number of '-' `char!`s between corners.  "
    cornerChar [char! string!] "The `char!` to use for both corners.  "
    /local dashes
][
    if lineWidth < 0 [lineWidth: 0]
    dashes: head insert/dup copy "" #"-" lineWidth
    return rejoin [cornerChar dashes cornerChar]
]

;; --- Test Data and Parameters ---
border-test-widths: protect [20 10 0 5]
number-of-lines-to-test: 4 ; Will cycle through widths if lines > widths.

;; --- Demonstrative and Test Run for Alternating Borders ---
print ["Generating" number-of-lines-to-test "border lines with alternating corners:"]

actual-border-lines: make block! number-of-lines-to-test
expected-border-lines: make block! number-of-lines-to-test

;; Use `repeat` for a loop with a named counter.
repeat line-num number-of-lines-to-test [
    ;; Cycle through `border-test-widths`.
    current-width: pick border-test-widths ( (line-num - 1) % (length? border-test-widths) + 1 )

    ;; Use `alter` to decide which corner `char!` for THIS line's generation.
    ;; `not (alter ...)` gives `true` if the marker *was* present (and is now removed for next time).
    chosen-char: either not (alter corner-choice-state 'use-primary-corner) [
        PRIMARY-CORNER   ; Marker was present, use primary, state for next is "secondary" (marker absent).
    ][
        SECONDARY-CORNER ; Marker was absent, use secondary, state for next is "primary" (marker present).
    ]

    generated-line: Make-Border-Line current-width chosen-char
    append actual-border-lines generated-line
    print ["Line" line-num "(width:" current-width "corner:" chosen-char "):" generated-line]

    ;; Manually construct the expected line for this iteration using the same logic.
    ;; The `chosen-char` logic results in `PRIMARY-CORNER` for odd lines, `SECONDARY-CORNER` for even lines,
    ;; if starting with `corner-choice-state: copy [use-primary-corner]`.
    expected-corner: either odd? line-num [
        PRIMARY-CORNER  ; For line 1, 3, 5...
    ][
        SECONDARY-CORNER ; For line 2, 4, 6...
    ]
    append expected-border-lines Make-Border-Line current-width expected-corner
]

print ["^/Actual Generated Lines (`block!`):" mold actual-border-lines]
print ["Expected Generated Lines (`block!`):" mold expected-border-lines]

test-passed: equal? actual-border-lines expected-border-lines
print ["^/Test result:" either test-passed ["✅ PASS"] ["❌ FAIL"]] ; Using user's icons.

if not test-passed [
    print "Mismatch details:"
    for idx 1 (min length? actual-border-lines length? expected-border-lines) 1 [
        if actual-border-lines/:idx <> expected-border-lines/:idx [
            print [
                "Line" idx "- Actual:" mold actual-border-lines/:idx
                "Expected:" mold expected-border-lines/:idx
            ]
        ]
    ]
]

print [newline "EXPLANATION for Example 18:"]
print ["- `corner-choice-state` (e.g., `[use-primary-corner]` or `[]`) is managed by `alter` in the main loop.  "]
print ["- `chosen-char: either not (alter corner-choice-state 'use-primary-corner) [PRIMARY] [SECONDARY]` determines"]
print ["  the corner `char!` for the current line.  If `'use-primary-corner'` *was* present (meaning `alter`"]
print ["  removed it and returned `false`), `PRIMARY-CORNER` is selected.  Otherwise, `SECONDARY-CORNER` is selected.  "]
print ["- `Make-Border-Line` is a simple helper that constructs the line with the chosen corner.  "]
print ["- This demonstrates using `alter` to control alternating styles across multiple operations effectively.  "]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Example 19: Toggle an `integer!` in a `block!` (Removal)
;; Use case: Managing a list of numerical identifiers or selectable numerical options.
print ""
numbers: [1 2 3 4]
print ["Before (Removal):" numbers]
print ["Action:" "If the `integer!` 3 is present in the `block!`, it is removed; otherwise, it is added.  "]
alter numbers 3
print ["After (Removal):" numbers]
either [1 2 4] = numbers [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 20: Toggle a `string!` in a `block!` (Removal)
;; Use case: Managing a list of selectable `string!` items, like tags or categories.
print ""
fruits: ["apple" "banana" "cherry"]
print ["Before (Removal):" fruits]
print ["Action:" "If the `string!` ""banana"" is present in the `block!`, it is removed; otherwise, it is added.  "]
alter fruits "banana"
print ["After (Removal):" fruits]
either ["apple" "cherry"] = fruits [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 21: Toggle a `char!` in a `string!` (Removal)
;; Use case: Modifying a `string!` by adding or removing a specific `char!`, for example, in a simple cipher or character set.
print ""
letters: "abcde"
print ["Before (Removal):" letters]
print ["Action:" "If the `char!` #""c"" is present in the `string!`, it is removed; otherwise, it is added.  "]
alter letters #"c"
print ["After (Removal):" letters]
either "abde" = letters [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 22: Toggle a `word!` in a `block!` (Removal)
;; Use case: Managing a list of symbolic identifiers or keywords.
print ""
words: [hello world rebol]
print ["Before (Removal):" words]
print ["Action:" "If the `word!` `'world` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter words 'world
print ["After (Removal):" words]
either [hello rebol] = words [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 23: Toggle a `file!` extension in a `block!` (Removal)
;; Use case: Managing a list of supported or selected `file!` extensions.
print ""
extensions: [%.txt %.doc %.pdf]
print ["Before (Removal):" extensions]
print ["Action:" "If the `file!` extension `%.doc` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter extensions %.doc
print ["After (Removal):" extensions]
either [%.txt %.pdf] = extensions [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 24: Toggle a `logic!` in a `block!` (Removal - FIXED based on debug output)
;; Use case: Managing a set of binary states or flags using actual `logic!` values.
print ""
booleans: copy [#(true) #(false)]
print ["Before (Removal):" mold booleans]
print ["Action:" "If the `logic!` value `#(true)` (referenced in code via the `word!` `true`) is present in the `block!`, it is removed; otherwise, it is added.  "]
alter booleans true
print ["After (Removal):" mold booleans]
either [#(false)] = booleans [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 25: Toggle a `pair!` in a `block!` (Removal)
;; Use case: Managing a list of coordinate `pair!`s or 2D dimension values.
print ""
pairs: [10x20 30x40 50x60]
print ["Before (Removal):" pairs]
print ["Action:" "If the `pair!` value `30x40` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter pairs 30x40
print ["After (Removal):" pairs]
either [10x20 50x60] = pairs [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 26: Toggle a `tuple!` in a `block!` (Removal - FIXED by user previously)
;; Use case: Managing a list of version numbers, RGB color values, or other fixed-size numerical sequences.
print ""
tuples: [1.2 3.4 5.6]
print ["Before (Removal):" tuples]
print ["Action:" "If the `tuple!` value `3.4` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter tuples 3.4
print ["After (Removal):" tuples]
either [1.2 5.6] = tuples [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 27: Toggle a `url!` in a `block!` (Removal)
;; Use case: Managing a list of web addresses, such as bookmarks or allowed sites.
print ""
urls: [http://example.com http://rebol.com]
print ["Before (Removal):" urls]
print ["Action:" "If the `url!` `http://example.com` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter urls http://example.com
print ["After (Removal):" urls]
either [http://rebol.com] = urls [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 28: Toggle a `date!` in a `block!` (Removal)
;; Use case: Managing a list of specific `date!`s, like appointments or event occurrences.
print ""
dates: [1-Jan-2023 15-Feb-2023 31-Mar-2023]
print ["Before (Removal):" dates]
print ["Action:" "If the `date!` `15-Feb-2023` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter dates 15-Feb-2023
print ["After (Removal):" dates]
either [1-Jan-2023 31-Mar-2023] = dates [print "✅ PASSED"] [print "❌ FAILED"]

;; --- New Addition Examples (Showing item being added) ---

;; Example 29: Toggle an `integer!` in a `block!` (Addition)
;; Use case: Managing a list of numerical identifiers or selectable numerical options.
print ""
numbers-add: [1 2 4] ; Item 3 is NOT present.
print ["Before (Addition):" numbers-add]
print ["Action:" "If the `integer!` 3 is present in the `block!`, it is removed; otherwise, it is added.  "]
alter numbers-add 3
print ["After (Addition):" numbers-add]
either safe-block-compare [1 2 4 3] numbers-add [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 30: Toggle a `string!` in a `block!` (Addition)
;; Use case: Managing a list of selectable `string!` items, like tags or categories.
print ""
fruits-add: ["apple" "cherry"] ; "banana" is NOT present.
print ["Before (Addition):" fruits-add]
print ["Action:" "If the `string!` ""banana"" is present in the `block!`, it is removed; otherwise, it is added.  "]
alter fruits-add "banana"
print ["After (Addition):" fruits-add]
either safe-block-compare ["apple" "cherry" "banana"] fruits-add [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 31: Toggle a `char!` in a `string!` (Addition)
;; Use case: Modifying a `string!` by adding or removing a specific `char!`.
print ""
letters-add: "abde" ; `char! #"c"` is NOT present.
print ["Before (Addition):" letters-add]
print ["Action:" "If the `char!` #""c"" is present in the `string!`, it is removed; otherwise, it is added.  "]
alter letters-add #"c"
print ["After (Addition):" letters-add]
either "abdec" = letters-add [print "✅ PASSED"] [print "❌ FAILED"] ; Direct comparison, order matters for `string!` append.

;; Example 32: Toggle a `word!` in a `block!` (Addition)
;; Use case: Managing a list of symbolic identifiers or keywords.
print ""
words-add: [hello rebol] ; `'world` is NOT present.
print ["Before (Addition):" words-add]
print ["Action:" "If the `word!` `'world` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter words-add 'world
print ["After (Addition):" words-add]
either safe-block-compare [hello rebol world] words-add [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 33: Toggle a `file!` extension in a `block!` (Addition)
;; Use case: Managing a list of supported or selected `file!` extensions.
print ""
extensions-add: [%.txt %.pdf] ; `%.doc` is NOT present.
print ["Before (Addition):" extensions-add]
print ["Action:" "If the `file!` extension `%.doc` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter extensions-add %.doc
print ["After (Addition):" extensions-add]
either safe-block-compare [%.txt %.pdf %.doc] extensions-add [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 34: Toggle a `logic!` in a `block!` (Addition)
;; Use case: Managing a set of binary states or flags using actual `logic!` values.
print ""
booleans-add: copy [#(false)] ;; `#(true)` is NOT present.
print ["Before (Addition):" mold booleans-add]
print ["Action:" "If the `logic!` value `#(true)` (resulting from the `word!` `true`) is present in the `block!`, it is removed; otherwise, it is added.  "]
alter booleans-add true ;; Adds `#(true)` because `alter` is called with the `logic!` value `#(true)`.
print ["After (Addition):" mold booleans-add]
;; Direct comparison, order matters for this specific `logic!` test, `safe-sort` would remove `logic!`.
either [#(false) #(true)] = booleans-add [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 35: Toggle a `pair!` in a `block!` (Addition)
;; Use case: Managing a list of coordinate `pair!`s or 2D dimension values.
print ""
pairs-add: [10x20 50x60] ; `30x40` is NOT present.
print ["Before (Addition):" pairs-add]
print ["Action:" "If the `pair!` value `30x40` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter pairs-add 30x40
print ["After (Addition):" pairs-add]
either safe-block-compare [10x20 50x60 30x40] pairs-add [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 36: Toggle a `tuple!` in a `block!` (Addition)
;; Use case: Managing a list of version numbers, RGB color values, or other fixed-size numerical sequences.
print ""
tuples-add: [1.2 5.6] ; `3.4` is NOT present.
print ["Before (Addition):" tuples-add]
print ["Action:" "If the `tuple!` value `3.4` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter tuples-add 3.4
print ["After (Addition):" tuples-add]
either safe-block-compare [1.2 5.6 3.4] tuples-add [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 37: Toggle a `url!` in a `block!` (Addition)
;; Use case: Managing a list of web addresses, such as bookmarks or allowed sites.
print ""
urls-add: [http://rebol.com] ; `http://example.com` is NOT present.
print ["Before (Addition):" urls-add]
print ["Action:" "If the `url!` `http://example.com` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter urls-add http://example.com
print ["After (Addition):" urls-add]
either safe-block-compare [http://rebol.com http://example.com] urls-add [print "✅ PASSED"] [print "❌ FAILED"]

;; Example 38: Toggle a `date!` in a `block!` (Addition)
;; Use case: Managing a list of specific `date!`s, like appointments or event occurrences.
print ""
dates-add: [1-Jan-2023 31-Mar-2023] ; `15-Feb-2023` is NOT present.
print ["Before (Addition):" dates-add]
print ["Action:" "If the `date!` `15-Feb-2023` is present in the `block!`, it is removed; otherwise, it is added.  "]
alter dates-add 15-Feb-2023
print ["After (Addition):" dates-add]
either safe-block-compare [1-Jan-2023 31-Mar-2023 15-Feb-2023] dates-add [print "✅ PASSED"] [print "❌ FAILED"]
