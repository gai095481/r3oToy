REBOL [
    Title: "Toggler - User-Friendly Wrapper for `alter`"
    Author: "Lutra AI and User Collaboration"
    Date: 28-May-2025
    Version: 0.1.0
    Purpose: {Provide a safer and more intuitive wrapper around the native `alter`
              function, abstracting some of its complexities for novice programmers.}
]

;;-----------------------------------------------------------------------------
;; LESSONS INCORPORATED INTO `toggler`:
;;-----------------------------------------------------------------------------
;; - `alter` modifies series in-place: `toggler` copies by default.
;; - `alter`'s return (`true` if added, `false` if removed) can be non-intuitive
;;   for simply checking presence after toggle: `toggler` can return the modified
;;   series and/or a status word.
;; - Case sensitivity: `toggler` makes this an explicit option.
;; - Potential for errors if `series` is not a valid type for `alter`: `toggler`
;;   includes basic type checking.
;; - Clarity for novice users is prioritized over mimicking `alter`'s exact signature
;;   where it might be confusing.
;;-----------------------------------------------------------------------------
print "^/--- `toggler` Function Definition and Examples ---"

toggler: function [
    {Safely toggle the presence of a value in a series.
     RETURN a block: [modified-series action-taken (word!: 'added or 'removed)]
     By default, operates on a copy of the input series.}
    target-series [series! port! bitset!] "The target series."
    value-to-toggle [any-type!] "The value to add or remove."
    /case-sensitive "Perform a case-sensitive toggle (for strings/chars)."
    /in-place "Modify the original `target-series` directly (USE WITH CAUTION)."
][
    ;; --- Input Validation & Series Handling ---
    ;; Datatype checking is handled by the function spec [series! port! bitset!]

    ;; Check if case-sensitive is appropriate for this type:
    if case-sensitive [
        if not any [
            string? target-series
            all [bitset? target-series char? value-to-toggle]
        ][
            print ["Warning: /case-sensitive used with non-string/non-bitset-char series type:" type? target-series]
        ]
    ]

    ;; Prepare working series (copy or use original)
    working-series: either in-place [target-series][copy target-series]

    ;; --- Perform the Alter Operation ---
    error-object: try [
        result-of-alter: either case-sensitive [
            alter/case working-series value-to-toggle
        ][
            alter working-series value-to-toggle
        ]
    ]

    if error? :error-object [
        return error-object  ;; Propagate the error
    ]

    ;; --- Determine Action and Prepare Return ---
    action-taken: either result-of-alter ['added]['removed]

    return reduce [working-series action-taken]
]

;; --- Test Data ---
test-block: ["apple" "banana" "CHERRY"]
test-string: "abcdef"
test-bitset: make bitset! "ace"

print [newline "--- `toggler` Basic Usage Tests ---"]

;; Test 1: Add to block (default: copy, case-insensitive)
print "^/Test 1: Add to block"
result1: toggler copy test-block "grape"
print ["Original block (should be unchanged):" mold test-block]
print ["Toggler result: [series action] ->" mold result1]
print ["Modified series:" mold result1/1]
print ["Action taken:" result1/2]
print ["Expected action: added. Test:" either result1/2 = 'added ["✅ PASSED"] ["❌ FAILED"]]
print ["Expected series contains 'grape':" either find result1/1 "grape" ["✅ PASSED"] ["❌ FAILED"]]

;; Test 2: Remove from block (default: copy, case-insensitive for string)
print "^/Test 2: Remove from block (case-insensitive)"
result2: toggler copy test-block "cherry" ; "cherry" should match "CHERRY"
print ["Original block:" mold test-block]
print ["Toggler result:" mold result2]
print ["Modified series:" mold result2/1]
print ["Action taken:" result2/2]
print ["Expected action: removed. Test:" either result2/2 = 'removed ["✅ PASSED"] ["❌ FAILED"]]
print ["Expected series does not contain 'CHERRY':" either not find result2/1 "CHERRY" ["✅ PASSED"] ["❌ FAILED"]]

;; Test 3: Remove from block (case-sensitive, item NOT removed)
print "^/Test 3: Attempt remove with /case-sensitive (should add instead)"
result3: toggler/case-sensitive copy test-block "cherry" ; "cherry" will NOT match "CHERRY"
print ["Original block:" mold test-block]
print ["Toggler result:" mold result3]
print ["Action taken:" result3/2]
print ["Expected action: added. Test:" either result3/2 = 'added ["✅ PASSED"] ["❌ FAILED"]] ; Because "cherry" was not found case-sensitively, it's added.
print ["Expected series still contains 'CHERRY' AND 'cherry':" either all [find result3/1 "CHERRY" find result3/1 "cherry"] ["✅ PASSED"] ["❌ FAILED"]]

;; Test 4: Remove from block (case-sensitive, item IS removed)
print "^/Test 4: Remove with /case-sensitive (match)"
result4: toggler/case-sensitive copy test-block "CHERRY"
print ["Original block:" mold test-block]
print ["Toggler result:" mold result4]
print ["Action taken:" result4/2]
print ["Expected action: removed. Test:" either result4/2 = 'removed ["✅ PASSED"] ["❌ FAILED"]]
print ["Expected series no longer contains 'CHERRY':" either not find result4/1 "CHERRY" ["✅ PASSED"] ["❌ FAILED"]]

;; Test 5: Add to string (in-place)
print "^/Test 5: Add to string (in-place)"
working-string: copy test-string
print ["String before (in-place):" mold working-string]
result5: toggler/in-place working-string #"g"
print ["String after (in-place, should be modified):" mold working-string]
print ["Toggler result series (same object as working-string):" mold result5/1]
print ["Action taken:" result5/2]
print ["Expected action: added. Test:" either result5/2 = 'added ["✅ PASSED"] ["❌ FAILED"]]
print ["Expected string content:" either result5/1 = "abcdefg" ["✅ PASSED"] ["❌ FAILED"]]

;; Test 6: Remove from bitset
print "^/Test 6: Remove from bitset"
result6: toggler copy test-bitset #"c"
print ["Original bitset:" mold test-bitset]
print ["Toggler result:" mold result6]
print ["Action taken:" result6/2]
expected-bitset-after-remove: make bitset! "ae"
print ["Expected action: removed. Test:" either result6/2 = 'removed ["✅ PASSED"] ["❌ FAILED"]]
print ["Expected bitset content:" either result6/1 = expected-bitset-after-remove ["✅ PASSED"] ["❌ FAILED"]]

;; Test 7: Error handling - invalid series type
print "^/Test 7: Error handling (invalid series type)"
error-result: try [toggler 123 "value"]
print ["Result of toggler with invalid series:" mold error-result]
print ["Test (is error?):" either error? error-result ["✅ PASSED"] ["❌ FAILED"]]

if error? error-result [
    print ["Error ID:" error-result/id "Message:" error-result/arg1]
]
