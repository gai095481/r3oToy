REBOL [
    Title: "TAKE Function - Unintuitive Behaviors and Quirks"
    Date: now/date
    Author: "Jules (AI Agent)"
    Purpose: {
        Documents and explains some of the less obvious or potentially
        surprising behaviors of the TAKE function in Rebol.
        Understanding these quirks can help prevent bugs.
        Each example is verified using the assert-equal test harness.
    }
    File: %take_unintuitive_behavior_examples.r
    Version: 1.0.0
    License: Public Domain
]

;-----------------------------------------------------------------------------
; A Battle-Tested QA Harness (Provided by User)
;-----------------------------------------------------------------------------
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
        print "✅ ALL `take` UNINTUITIVE BEHAVIOR EXAMPLES PASSED"
    ][
        print "❌ SOME `take` UNINTUITIVE BEHAVIOR EXAMPLES FAILED"
    ]
    print "============================================^/"
]

; Placeholder for QA harness and examples
print "Starting Unintuitive Behavior Examples for TAKE function..."
print newline

; --- Quirk 1: `take` on an empty series returns `none`, not an error ---
print "--- Quirk 1: `take` on an empty series returns `none` ---"
; Some might expect an error when trying to take from an empty series.
; However, `take` consistently returns `none` in this situation.
empty-block: []
result-empty-block: take empty-block
assert-equal true (none? result-empty-block) "take on empty block returns none"
print ["Result of take []: " mold result-empty-block "^/"]

empty-string: copy "" ; copy because take modifies
result-empty-string: take empty-string
assert-equal true (none? result-empty-string) "take on empty string returns none"
print ["Result of take """": " mold result-empty-string "^/"]

empty-binary: copy #{}
result-empty-binary: take empty-binary
assert-equal true (none? result-empty-binary) "take on empty binary returns none"
print ["Result of take #{}: " mold result-empty-binary "^/"]

; --- Quirk 2: `take/part` with a count of zero ---
print "--- Quirk 2: `take/part` with a count of zero ---"
; Using `take/part` with a count of 0 might seem like it would do nothing
; or error. Instead, it returns an empty series of the same type as the
; input series, and the original series remains unchanged.
block-data: copy [a b c]
original-block-mold: mold block-data
taken-zero-block: take/part block-data 0

assert-equal [] taken-zero-block "take/part block with 0 - result is empty block"
assert-equal [a b c] block-data "take/part block with 0 - original block unchanged"
print ["Original block: " original-block-mold
       ", After take/part 0, result: " mold taken-zero-block
       ", Original still: " mold block-data "^/"]

string-data: copy "hello"
original-string-mold: mold string-data
taken-zero-string: take/part string-data 0

assert-equal "" taken-zero-string "take/part string with 0 - result is empty string"
assert-equal "hello" string-data "take/part string with 0 - original string unchanged"
print ["Original string: " original-string-mold
       ", After take/part 0, result: " mold taken-zero-string
       ", Original still: " mold string-data "^/"]

; --- Quirk 3: `take/part` with a count larger than series length ---
print "--- Quirk 3: `take/part` with a count larger than series length ---"
; If the count for `take/part` exceeds the number of available elements,
; `take` will simply take all available elements from the current position
; to the end of the series. The original series is modified (emptied if taken from head).
block-overshoot: copy [1 2 3]
original-block-overshoot-mold: mold block-overshoot
count-too-large: (length? block-overshoot) + 5

taken-all-block: take/part block-overshoot count-too-large

assert-equal [1 2 3] taken-all-block "take/part count too large (block) - takes all available"
assert-equal [] block-overshoot "take/part count too large (block) - original is emptied"
print ["Original block: " original-block-overshoot-mold
       ", Count: " count-too-large
       ", Taken: " mold taken-all-block
       ", Original now: " mold block-overshoot "^/"]

string-overshoot: copy "abc"
original-string-overshoot-mold: mold string-overshoot
count-too-large-str: (length? string-overshoot) + 2

taken-all-string: take/part string-overshoot count-too-large-str
assert-equal "abc" taken-all-string "take/part count too large (string) - takes all available"
assert-equal "" string-overshoot "take/part count too large (string) - original is emptied"
print ["Original string: " original-string-overshoot-mold
       ", Count: " count-too-large-str
       ", Taken: " mold taken-all-string
       ", Original now: " mold string-overshoot "^/"]

; --- Quirk 4: `take/part` with a series position past the tail ---
print "--- Quirk 4: `take/part` with a series position past the tail ---"
; If `take/part` is given a series position that is beyond the actual
; tail of the series, it typically behaves as if you asked to take up to
; the very end of the series. It takes all elements from the head.
block-pos-tail: copy [x y z]
original-block-pos-mold: mold block-pos-tail

; Create a position clearly past the tail
pos-past-tail: tail block-pos-tail
pos-past-tail: next pos-past-tail ; one step past tail

taken-block-past-tail: take/part block-pos-tail pos-past-tail

assert-equal [x y z] taken-block-past-tail "take/part pos past tail (block) - takes all"
assert-equal [] block-pos-tail "take/part pos past tail (block) - original emptied"
print ["Original block: " original-block-pos-mold
       ", Taken with pos past tail: " mold taken-block-past-tail
       ", Original now: " mold block-pos-tail "^/"]

string-pos-tail: copy "end"
original-string-pos-mold: mold string-pos-tail
pos-past-tail-str: tail string-pos-tail
pos-past-tail-str: next pos-past-tail-str

taken-string-past-tail: take/part string-pos-tail pos-past-tail-str
assert-equal "end" taken-string-past-tail "take/part pos past tail (string) - takes all"
assert-equal "" string-pos-tail "take/part pos past tail (string) - original emptied"
print ["Original string: " original-string-pos-mold
       ", Taken with pos past tail: " mold taken-string-past-tail
       ", Original now: " mold string-pos-tail "^/"]

; --- Quirk 5: `take/part` (no /deep) and Shared Sub-series (Shallow Copy) ---
print "--- Quirk 5: `take/part` (no /deep) and Shared Sub-series (Shallow Copy) ---"
; When `take/part` (without /deep) copies a part of a series that contains
; sub-series (like a block within a block), it performs a shallow copy.
; This means the sub-series themselves are shared between the original (if still referenced)
; and the taken part. Modifying such a sub-series in the taken part can affect
; other references to it.
original-main-block: [10 [20 30] 40]
sub-block-reference: original-main-block/2 ; b: a/2 in description -> sub-block-reference now refers to [20 30]

; Take the first two elements, which includes the reference to the sub-block
taken-portion: take/part original-main-block 2
; taken-portion is now [10 [20 30]]
; original-main-block is now [40]
; sub-block-reference still points to the same block [20 30] that is now also in taken-portion/2

print ["Taken portion: " mold taken-portion]
print ["Sub-block reference before modification: " mold sub-block-reference]

; Modify the sub-block VIA the taken-portion
taken-portion/2/1: 999 ; Modifies taken-portion/2 to be [999 30]

assert-equal [999 30] taken-portion/2 "Shallow copy - modified sub-block in taken part"
assert-equal [999 30] sub-block-reference "Shallow copy - original sub-block reference is ALSO modified"
print ["Sub-block in taken portion after modification: " mold taken-portion/2]
print ["Original sub-block reference after modification (shows sharing): " mold sub-block-reference]
print ["Original main block after take and modification: " mold original-main-block "^/"]

; Contrast with /deep (briefly, as /deep is a feature, not a quirk itself)
original-main-block-deep: [100 [200 300] 400]
sub-block-reference-deep: original-main-block-deep/2

taken-portion-deep: take/part/deep original-main-block-deep 2
; taken-portion-deep is [100 [200 300]] but [200 300] is a new copy.
print ["Taken portion (deep): " mold taken-portion-deep]
print ["Sub-block reference (deep) before modification: " mold sub-block-reference-deep]

taken-portion-deep/2/1: 777 ; Modifies only the copy within taken-portion-deep

assert-equal [777 300] taken-portion-deep/2 "Deep copy - modified sub-block in taken part"
assert-equal [200 300] sub-block-reference-deep "Deep copy - original sub-block reference is NOT modified"
print ["Sub-block in deep taken portion after modification: " mold taken-portion-deep/2]
print ["Original sub-block reference (deep) after modification (shows no sharing): " mold sub-block-reference-deep "^/"]

; --- Quirk 6: `take/last` on an empty series returns `none` ---
print "--- Quirk 6: `take/last` on an empty series returns `none` ---"
; Similar to `take` on an empty series, `take/last` also returns `none`
; if the series is empty, rather than an error. This is consistent.
empty-block-for-last: []
result-last-empty-block: take/last empty-block-for-last
assert-equal true (none? result-last-empty-block) "take/last on empty block returns none"
print ["Result of take/last []: " mold result-last-empty-block "^/"]

empty-string-for-last: copy ""
result-last-empty-string: take/last empty-string-for-last
assert-equal true (none? result-last-empty-string) "take/last on empty string returns none"
print ["Result of take/last """": " mold result-last-empty-string "^/"]

; --- Final Summary ---
print-test-summary
