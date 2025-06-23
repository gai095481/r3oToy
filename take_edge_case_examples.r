REBOL [
    Title: "TAKE Function - Edge Case Examples"
    Date: now/date
    Author: "Jules (AI Agent)"
    Purpose: {
        Tests and documents the behavior of the TAKE function with unusual,
        boundary, or potentially problematic (but valid or invalid) inputs.
        This helps understand its robustness and error handling.
        Each example is verified using the assert-equal test harness.
    }
    File: %take_edge_case_examples.r
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
        print "✅ ALL `take` EDGE CASE EXAMPLES PASSED"
    ][
        print "❌ SOME `take` EDGE CASE EXAMPLES FAILED"
    ]
    print "============================================^/"
]

; Placeholder for QA harness and examples
print "Starting Edge Case Examples for TAKE function..."
print newline

; --- Edge Case 1: `take` variations on various empty series types ---
print "--- Edge Case 1: `take` variations on various empty series types ---"
; This re-confirms behavior already noted in "Unintuitive Behaviors" for script completeness.
; `take` and `take/last` on empty series should yield `none`.
; `take/part` on empty series should yield an empty series of the same type.

; Test `take`
empty-block1: []
assert-equal true (none? take empty-block1) "take on []"
empty-string1: copy ""
assert-equal true (none? take empty-string1) "take on empty string"
empty-binary1: copy #{}
assert-equal true (none? take empty-binary1) "take on #{}"
print "Verified: `take` on empty block, string, binary returns none.^/"

; Test `take/last`
empty-block2: []
assert-equal true (none? take/last empty-block2) "take/last on []"
empty-string2: copy ""
assert-equal true (none? take/last empty-string2) "take/last on empty string"
empty-binary2: copy #{}
assert-equal true (none? take/last empty-binary2) "take/last on #{}"
print "Verified: `take/last` on empty block, string, binary returns none.^/"

; Test `take/part` with count 0
empty-block3: []
taken-part-b0: take/part empty-block3 0
assert-equal [] taken-part-b0 "take/part [] 0 - result"
assert-equal true (block? taken-part-b0) "take/part [] 0 - type is block"
assert-equal [] empty-block3 "take/part [] 0 - original unchanged"

empty-string3: copy ""
taken-part-s0: take/part empty-string3 0
assert-equal "" taken-part-s0 "take/part on empty string with count 0 - result"
assert-equal true (string? taken-part-s0) "take/part on empty string with count 0 - type is string"
assert-equal "" empty-string3 "take/part on empty string with count 0 - original unchanged"
print "Verified: `take/part series 0` on empty series returns empty series of same type, original unchanged.^/"

; Test `take/part` with count 1 (or any positive count)
empty-block4: []
taken-part-b1: take/part empty-block4 1
assert-equal [] taken-part-b1 "take/part [] 1 - result"
assert-equal true (block? taken-part-b1) "take/part [] 1 - type is block"
assert-equal [] empty-block4 "take/part [] 1 - original unchanged"

empty-string4: copy ""
taken-part-s1: take/part empty-string4 1
assert-equal "" taken-part-s1 "take/part on empty string with count 1 - result"
assert-equal true (string? taken-part-s1) "take/part on empty string with count 1 - type is string"
assert-equal "" empty-string4 "take/part on empty string with count 1 - original unchanged"
print "Verified: `take/part series count` on empty series (count > 0) returns empty series of same type, original unchanged.^/"

; --- Edge Case 2: `take/part` with a negative count ---
print "--- Edge Case 2: `take/part` with a negative count ---"
; Observed behavior: `take/part` with a negative count returns an empty
; series of the same type and does NOT modify the original series.
data-neg-count: copy [1 2 3]
original-neg-count-mold: mold data-neg-count
taken-neg: take/part data-neg-count -2

assert-equal [] taken-neg "take/part with negative count returns empty block"
assert-equal true (block? taken-neg) "take/part with negative count result type is block"
assert-equal [1 2 3] data-neg-count "take/part with negative count does not change original"
print ["Original: " original-neg-count-mold ", After take/part -2, Taken: " mold taken-neg ", Original still: " mold data-neg-count "^/"]

; --- Edge Case 3: `take/part` with a non-integer count ---
print "--- Edge Case 3: `take/part` with a non-integer count ---"

; Test with decimal count - Observed behavior: decimal is truncated.
data-decimal-count: copy [a b c d e]
original-decimal-count-mold: mold data-decimal-count
taken-decimal: take/part data-decimal-count 2.5

assert-equal [a b] taken-decimal "take/part with 2.5 takes 2 items (decimal truncated)"
assert-equal [c d e] data-decimal-count "take/part with 2.5 modifies original based on truncated count"
print ["Original: " original-decimal-count-mold ", After take/part 2.5, Taken: " mold taken-decimal ", Original now: " mold data-decimal-count "^/"]

; Test with string count (This correctly errors as per previous test run)
data-string-count: copy [x y z]
error-obj-string: none
set/any 'error-obj-string try [take/part data-string-count "2"]

assert-equal true error? error-obj-string "take/part with string count results in an error"
print ["Result of take/part [x y z] ""2"": ERROR? -> " mold error? error-obj-string]
if error? error-obj-string [print ["Error (string): " mold error-obj-string]]
print "Verified: `take/part` with a string count raises an error.^/"

; --- Edge Case 4: `take/part` with invalid type for range argument ---
print "--- Edge Case 4: `take/part` with invalid type for range argument ---"
; The `range` argument for `take/part` expects a number (count), a series (position), or a pair (index/count).
; Providing other types like a word! or time! should result in an error.

; Test with word! as range
data-word-range: copy [a b c]
error-obj-word-range: none
set/any 'error-obj-word-range try [take/part data-word-range 'some-word]

assert-equal true error? error-obj-word-range "take/part with word! range results in an error"
print ["Result of take/part data 'some-word: ERROR? -> " mold error? error-obj-word-range]
if error? error-obj-word-range [print ["Error (word! range): " mold error-obj-word-range]]

; Test with time! as range
data-time-range: copy [x y z]
error-obj-time-range: none
set/any 'error-obj-time-range try [take/part data-time-range now/time]

assert-equal true error? error-obj-time-range "take/part with time! range results in an error"
print ["Result of take/part data now/time: ERROR? -> " mold error? error-obj-time-range]
if error? error-obj-time-range [print ["Error (time! range): " mold error-obj-time-range]]
print "Verified: `take/part` with an invalid type for the range argument raises an error.^/"

; --- Edge Case 5: `take` on a series containing `none` values ---
print "--- Edge Case 5: `take` on a series containing `none` values ---"
; `none` is a valid value within a series and can be `take`n like any other element.
data-with-none: copy ['first-item none 'third-item]
original-data-none-mold: mold data-with-none

val1: take data-with-none
assert-equal 'first-item val1 "take from series with none - first item"
print ["After first take, series: " mold data-with-none ", Taken: " mold val1]

val2: take data-with-none
assert-equal none val2 "take from series with none - second item is none"
print ["After second take, series: " mold data-with-none ", Taken: " mold val2 "(none)"]

val3: take data-with-none
assert-equal 'third-item val3 "take from series with none - third item"
print ["After third take, series: " mold data-with-none ", Taken: " mold val3]

assert-equal [] data-with-none "Series with none should be empty after all takes"
print ["Final series state: " mold data-with-none "^/"]

; --- Edge Case 6: `take/part/deep` on a series with no sub-series ---
print "--- Edge Case 6: `take/part/deep` on a series with no sub-series ---"
; If `/deep` is used with `take/part` on a series that contains no further
; nested series (e.g., a flat block of words or numbers), it behaves identically
; to `take/part` without `/deep`. The `/deep` refinement only has an effect
; when there are sub-series to be deeply copied.

; Test with `take/part/deep` on a flat block
flat-block: copy [one two three four]
original-flat-block-mold: mold flat-block
taken-flat-deep: take/part/deep flat-block 2

assert-equal [one two] taken-flat-deep "take/part/deep on flat block - taken part"
assert-equal [three four] flat-block "take/part/deep on flat block - original modified"
print ["Original flat block: " original-flat-block-mold
       ", After take/part/deep 2: " mold taken-flat-deep
       ", Original now: " mold flat-block "^/"]

; Test with `take/part/deep` on a simple string (strings are inherently flat)
simple-string: copy "abcdef"
original-simple-string-mold: mold simple-string
taken-string-deep: take/part/deep simple-string 3

assert-equal "abc" taken-string-deep "take/part/deep on simple string - taken part"
assert-equal "def" simple-string "take/part/deep on simple string - original modified"
print ["Original simple string: " original-simple-string-mold
       ", After take/part/deep 3: " mold taken-string-deep
       ", Original now: " mold simple-string "^/"]
print "Verified: `/deep` has no different effect than non-deep `take/part` if no sub-series exist in the taken portion.^/"

; --- Edge Case 7: `take` on other specific datatypes (URL!, EMAIL!, TAG!) ---
print "--- Edge Case 7: `take` on other specific datatypes ---"
; `take`'s argument is specified as [series! port! gob! none!].
; URL! is a series. EMAIL! and TAG! are not series in the same way.

; Test with URL! (is a series, specifically any-string!)
url-val: copy http://example.com/path
original-url-mold: mold url-val
taken-url-char: take url-val
assert-equal #"h" taken-url-char "take on URL! - first char"
; Removed complex/failing URL assertion. The string check below is better.
print ["Original URL: " original-url-mold ", Taken char: " mold taken-url-char ", Remaining: " mold url-val "^/"]
; Let's re-verify the remaining part as string for clarity:
temp-url: copy http://example.com/path
take temp-url
assert-equal "ttp://example.com/path" to-string temp-url "take on URL! - remaining URL as string"


; Test with EMAIL!
email-val: copy user@example.com
original-email-mold: mold email-val
taken-from-email: take email-val

assert-equal #"u" taken-from-email "take on EMAIL! - first char"
assert-equal to-email "ser@example.com" email-val "take on EMAIL! - remaining email"
print ["Original email: " original-email-mold ", Taken char: " mold taken-from-email ", Remaining: " mold email-val]


; Test with TAG!
tag-val: copy <MyTag>
original-tag-mold: mold tag-val
taken-from-tag: take tag-val

assert-equal #"M" taken-from-tag "take on TAG! - first char"
assert-equal to-tag "yTag" tag-val "take on TAG! - remaining tag"
print ["Original tag: " original-tag-mold ", Taken char: " mold taken-from-tag ", Remaining: " mold tag-val]
print "Verified: `take` works on URL!, EMAIL!, and TAG! types as string-like series.^/"

; --- Edge Case 8: `take/all` on an already empty series ---
print "--- Edge Case 8: `take/all` on an already empty series ---"
; If `take/all` is used on a series that is already empty,
; it should return an empty series of the same type, and the original
; series remains empty. No error should occur.

; Empty block
empty-block-all: []
taken-empty-block-all: take/all empty-block-all
assert-equal [] taken-empty-block-all "take/all on empty block - taken part is empty"
assert-equal true (block? taken-empty-block-all) "take/all on empty block - type is block"
assert-equal [] empty-block-all "take/all on empty block - original remains empty"
print ["Result of take/all []: " mold taken-empty-block-all ", Original: " mold empty-block-all]

; Empty string
empty-string-all: copy ""
taken-empty-string-all: take/all empty-string-all
assert-equal "" taken-empty-string-all "take/all on empty string - taken part is empty"
assert-equal true (string? taken-empty-string-all) "take/all on empty string - type is string"
assert-equal "" empty-string-all "take/all on empty string - original remains empty"
print ["Result of take/all """": " mold taken-empty-string-all ", Original: " mold empty-string-all "^/"]
print "Verified: `take/all` on an already empty series returns an empty series of the same type and leaves the original empty.^/"

; --- Final Summary ---
print-test-summary
