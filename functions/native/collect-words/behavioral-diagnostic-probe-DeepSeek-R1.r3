Rebol [
    Title: "Diagnostic Probe Script for COLLECT-WORDS"
    Purpose: {Systematically tests behavior of COLLECT-WORDS and its refinements}
]

;;-----------------------------
;; Battle-Tested QA Harness
;;-----------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare two values and output formatted PASSED/FAILED message.}
    expected [any-type!] "Expected value."
    actual [any-type!] "Actual value."
    description [string!] "Test description."
][
    set 'test-count test-count + 1
    either equal? expected actual [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    print "^/============================================"
    print "=== TEST SUMMARY ==="
    print "============================================"
    print rejoin ["Total Tests: " test-count]
    print rejoin ["Passed: " pass-count]
    print rejoin ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - FUNCTION IS STABLE"
    ][
        print "❌ SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;; Helper converts words to comparable string representations
words-to-sorted-strings: function [
    {Convert block of words to sorted block of string representations.}
    blk [block!] "Block of words to convert"
][
    sorted-strings: sort collect [
        foreach item blk [keep mold item]
    ]
    return sorted-strings
]

;;------------------------------------------------------------------------------
;; Diagnostic Probe Tests for COLLECT-WORDS
;;------------------------------------------------------------------------------

print "=== STARTING COLLECT-WORDS DIAGNOSTIC PROBE ==="

;;
;; SECTION 1: Basic Behavior (No Refinements)
;;
print "^/=== Probing Basic Behavior ==="

comment {
    Hypothesis: COLLECT-WORDS collects all word-like types (word!, set-word!,
    get-word!, etc.), normalizes them to word!, and uses case-insensitive
    uniqueness with first occurrence casing preserved.
}
test-block-1: [a a]
expected-1: [a]
actual-1: collect-words test-block-1
assert-equal
    words-to-sorted-strings expected-1
    words-to-sorted-strings actual-1
    "Duplicates removed (case-insensitive)"

test-block-2: [a: b a]
expected-2: [a b]
actual-2: collect-words test-block-2
assert-equal
    words-to-sorted-strings expected-2
    words-to-sorted-strings actual-2
    "Set-words normalized to words"

test-block-3: [a A]
expected-3: [a]
actual-3: collect-words test-block-3
assert-equal
    words-to-sorted-strings expected-3
    words-to-sorted-strings actual-3
    "Case-insensitive uniqueness (first occurrence kept)"

test-block-3b: [A a]
expected-3b: [A]
actual-3b: collect-words test-block-3b
assert-equal
    words-to-sorted-strings expected-3b
    words-to-sorted-strings actual-3b
    "Case-insensitive uniqueness (first occurrence casing)"

;;
;; SECTION 2: /deep Refinement
;;
print "^/=== Probing /deep Refinement ==="

comment {
    Hypothesis: /deep collects from nested blocks, normalizing all word-like
    types to word!.
}
test-block-4: [a [b]]
expected-shallow: [a]
expected-deep: [a b]
actual-shallow: collect-words test-block-4
actual-deep: collect-words/deep test-block-4
assert-equal
    words-to-sorted-strings expected-shallow
    words-to-sorted-strings actual-shallow
    "Without /deep: ignores nested blocks"
assert-equal
    words-to-sorted-strings expected-deep
    words-to-sorted-strings actual-deep
    "With /deep: collects from nested blocks"

test-block-5: [a [b [c]]]
expected-deep-recursive: [a b c]
actual-deep-recursive: collect-words/deep test-block-5
assert-equal
    words-to-sorted-strings expected-deep-recursive
    words-to-sorted-strings actual-deep-recursive
    "/deep traverses multiple nesting levels"

;;
;; SECTION 3: /set Refinement
;;
print "^/=== Probing /set Refinement ==="

comment {
    Hypothesis: /set collects set-words but normalizes them to word! in result.
}
test-block-6: [a: b c:]
expected-set: [a c]
actual-set: collect-words/set test-block-6
assert-equal
    words-to-sorted-strings expected-set
    words-to-sorted-strings actual-set
    "/set collects set-words (normalized to words)"

test-block-7: [a: [b:]]
expected-set-shallow: [a]
expected-set-deep: [a b]
actual-set-shallow: collect-words/set test-block-7
actual-set-deep: collect-words/deep/set test-block-7
assert-equal
    words-to-sorted-strings expected-set-shallow
    words-to-sorted-strings actual-set-shallow
    "/set without /deep ignores nested set-words"
assert-equal
    words-to-sorted-strings expected-set-deep
    words-to-sorted-strings actual-set-deep
    "/set with /deep collects nested set-words (normalized)"

;;
;; SECTION 4: /ignore Refinement
;;
print "^/=== Probing /ignore Refinement ==="

comment {
    Hypothesis: /ignore removes matches by normalized word spelling
    (case-insensitive) regardless of original type.
}
test-block-8: [a b c]
ignore-block: [b]
expected-ignore: [a c]
actual-ignore: collect-words/ignore test-block-8 ignore-block
assert-equal
    words-to-sorted-strings expected-ignore
    words-to-sorted-strings actual-ignore
    "Ignores words in block (case-insensitive)"

ignore-obj: object [b: none]
actual-ignore-obj: collect-words/ignore test-block-8 ignore-obj
assert-equal
    words-to-sorted-strings expected-ignore
    words-to-sorted-strings actual-ignore-obj
    "Ignores words from object context"

test-block-9: [a]
actual-ignore-none: collect-words/ignore test-block-9 none
assert-equal
    words-to-sorted-strings test-block-9
    words-to-sorted-strings actual-ignore-none
    "/ignore none ignores nothing"

test-block-10: [a b a:] ; a: normalizes to a
ignore-a: [a]
expected-ignore-type: [b]
actual-ignore-type: collect-words/ignore test-block-10 ignore-a
assert-equal
    words-to-sorted-strings expected-ignore-type
    words-to-sorted-strings actual-ignore-type
    "Ignores by normalized spelling regardless of source type"

;;
;; SECTION 5: /as Refinement
;;
print "^/=== Probing /as Refinement ==="

comment {
    Hypothesis: /as converts normalized words to specified type.
}
test-block-11: [a: b]
expected-as-word: [a b]
actual-as-word: collect-words/as test-block-11 word!
assert-equal
    words-to-sorted-strings expected-as-word
    words-to-sorted-strings actual-as-word
    "/as word! returns words"

test-block-12: [a b]
expected-as-setword: [a: b:]
actual-as-setword: collect-words/as test-block-12 set-word!
assert-equal
    words-to-sorted-strings expected-as-setword
    words-to-sorted-strings actual-as-setword
    "/as set-word! converts to set-words"

test-block-13: [a: b]
expected-set-as-word: [a]
actual-set-as-word: collect-words/set/as test-block-13 word!
assert-equal
    words-to-sorted-strings expected-set-as-word
    words-to-sorted-strings actual-set-as-word
    "/set then /as: filter then convert"

;;
;; SECTION 6: Edge Cases
;;
print "^/=== Probing Edge Cases ==="

comment {
    Hypothesis: Collects all word-like types (get-words, lit-words, issues)
    and normalizes them to word!. Only true non-word values are ignored.
}
test-block-14: []
expected-empty: []
actual-empty: collect-words test-block-14
assert-equal
    words-to-sorted-strings expected-empty
    words-to-sorted-strings actual-empty
    "Empty block returns empty block"

;; Issue values are collected as words
test-block-15: [1 "two" :three]  ; Contains get-word (:three)
expected-get-word: [three]       ; Normalized to word 'three
actual-get-word: collect-words test-block-15
assert-equal
    words-to-sorted-strings expected-get-word
    words-to-sorted-strings actual-get-word
    "Collects get-words and normalizes to words"

;; Issue values are collected as words
test-block-15b: [#issue #123]
expected-issue: [issue 123]
actual-issue: collect-words test-block-15b
assert-equal
    words-to-sorted-strings expected-issue
    words-to-sorted-strings actual-issue
    "Collects issue values as words"

;; True non-word values are ignored
test-block-15c: [1 "string" %file.txt]
expected-non-word: []
actual-non-word: collect-words test-block-15c
assert-equal
    words-to-sorted-strings expected-non-word
    words-to-sorted-strings actual-non-word
    "True non-word values are ignored"

test-block-16: [a b]
ignore-unused: [c d]
expected-unused-ignore: [a b]
actual-unused-ignore: collect-words/ignore test-block-16 ignore-unused
assert-equal
    words-to-sorted-strings expected-unused-ignore
    words-to-sorted-strings actual-unused-ignore
    "Unused ignore words have no effect"

;;
;; SECTION 7: Combined Refinements
;;
print "^/=== Probing Combined Refinements ==="

comment {
    Hypothesis: Refinements compose as:
    1. Traverse with /deep
    2. Filter by /set (if present)
    3. Normalize to word!
    4. Apply /ignore
    5. Convert with /as
}
test-block-17: [a: [b: c] d: [e]]
ignore-combo: object [b: none] ; Ignores 'b
expected-combo: [a: d:] ; After /as set-word!
actual-combo: collect-words/deep/set/ignore/as test-block-17 ignore-combo set-word!
assert-equal
    words-to-sorted-strings expected-combo
    words-to-sorted-strings actual-combo
    "Combined: /deep/set/ignore/as"

;;------------------------------------------------------------------------------
;; Final Test Summary
;;------------------------------------------------------------------------------
print-test-summary
