Rebol []

;;-----------------------------------------------------------------------------
;; Test Harness Functions
;;-----------------------------------------------------------------------------
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
        print "✅ ALL TEST CASE EXAMPLES PASSED."
    ][
        print "❌ SOME TEST CASE EXAMPLES FAILED."
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Diagnostic Probe for REPLACE
;;-----------------------------------------------------------------------------

print "=== Starting Diagnostic Probe for REPLACE ==="

;; === Group 1: Basic Behavior (Single Replacement) ===

comment {
    Verified Behavior:
    - Modifies series in place
    - Replaces first occurrence of 'search' with 'replace'
    - Returns head of modified series
    - Works on strings, binaries, and blocks
    - Function replacements called with match position
}

;-- String! target
test-str: "apple banana apple"
result-str: replace test-str "apple" "orange"
assert-equal "orange banana apple" test-str  "String: Modifies in place"
assert-equal "orange banana apple" result-str "String: Returns modified head"

;-- Binary! target
test-bin: to binary! #{01020301}
result-bin: replace test-bin #{02} #{FF}
assert-equal #{01FF0301} test-bin "Binary: Modifies in place"
assert-equal #{01FF0301} result-bin "Binary: Returns modified head"

;-- Block! target
test-blk: [a b c b]
result-blk: replace test-blk 'b 'x
assert-equal [a x c b] test-blk "Block: Modifies in place"
assert-equal [a x c b] result-blk "Block: Returns modified head"

;-- Block! target with sequence search
test-seq: [a b c b]
replace test-seq [b c] [x y]
assert-equal [a x y b] test-seq "Block: Replaces element sequence"

;-- Function! as replacement
test-func: "abc"
f: func [s][uppercase first s] ; Takes match position, returns char
replace test-func "b" :f
assert-equal "aBc" test-func "Function: Called with match position"

;; === Group 2: /all Refinement (Global Replacement) ===

comment {
    Verified Behavior:
    - Replaces every non-overlapping occurrence
    - Returns head of modified series
}

;-- String! with /all
test-str-all: "apple banana apple"
result-str-all: replace/all test-str-all "apple" "orange"
assert-equal "orange banana orange" test-str-all "String/all: Global replace"
assert-equal "orange banana orange" result-str-all "String/all: Returns head"

;-- Block! with /all
test-blk-all: [a b c b]
result-blk-all: replace/all test-blk-all 'b 'x
assert-equal [a x c x] test-blk-all "Block/all: Global replace"
assert-equal [a x c x] result-blk-all "Block/all: Returns head"

;-- Binary! with /all
test-bin-all: to binary! #{01020101}
result-bin-all: replace/all test-bin-all #{01} #{FF}
assert-equal #{FF02FFFF} test-bin-all "Binary/all: Global replace"
assert-equal #{FF02FFFF} result-bin-all "Binary/all: Returns head"

;; === Group 3: /case Refinement (Case-Sensitive) ===

comment {
    Verified Behavior:
    - /case makes search case-sensitive
    - Default behavior is case-insensitive for strings
}

;-- Case-sensitive replacement
test-case: "Apple apple"
replace/case test-case "Apple" "Orange"
assert-equal "Orange apple" test-case "/case: Case-sensitive match"

;-- Case-insensitive (default)
test-nocase: "Apple apple"
replace test-nocase "apple" "Orange"
assert-equal "Orange apple" test-nocase "Default: Case-insensitive match"

;; === Group 4: /tail Refinement (Tail Return) ===

comment {
    Verified Behavior:
    - /tail returns position after last replacement
    - Returns head if no replacement occurs
    - Does not affect modification behavior
}

;-- Basic /tail with replacement
test-tail: "abcde"
tail-pos: replace/tail test-tail "c" "X"
assert-equal "abXde" test-tail "/tail: Modifies correctly"
assert-equal "de" copy tail-pos "/tail: Returns position after last replacement"

;-- /tail with no replacement
test-tail-notfound: "abcde"
tail-pos-notfound: replace/tail test-tail-notfound "z" "X"
assert-equal "abcde" test-tail-notfound "/tail (no match): Unmodified"
assert-equal head test-tail-notfound tail-pos-notfound "/tail (no match): Returns head"

;-- /tail with /all
test-tail-all: "a1a2a3"
tail-pos-all: replace/all/tail test-tail-all "a" "X"
assert-equal "X1X2X3" test-tail-all "/all/tail: Modifies all"
assert-equal "3" copy tail-pos-all "/all/tail: Returns after last replacement"

;; === Group 5: Edge Cases & Special Inputs ===

comment {
    Verified Behavior:
    - Leaves series unchanged when search not found
    - Handles empty series correctly
    - Empty search pattern does nothing
    - Bitset search requires /all for global replacement
    - Integer in binary searches converts to char
    - Zero-length replacement removes match
    - Block replacement always splices
}

;-- Search not found
test-notfound-str: "abc"
result-notfound: replace test-notfound-str "x" "y"
assert-equal "abc" test-notfound-str "Not found: Leaves series unchanged"
assert-equal "abc" result-notfound "Not found: Returns original head"

;-- Empty target series
test-empty: ""
result-empty: replace test-empty "a" "b"
assert-equal "" test-empty "Empty target: Unchanged"
assert-equal "" result-empty "Empty target: Returns empty"

;-- Empty search pattern
test-emptypat: "abc"
result-emptypat: replace test-emptypat "" "X"
assert-equal "abc" test-emptypat "Empty pattern: No replacement"
assert-equal "abc" result-emptypat "Empty pattern: Returns unchanged"

;-- Bitset! search
test-bitset: "a1b2c3"
replace/all test-bitset charset [#"0" - #"9"] "X"
assert-equal "aXbXcX" test-bitset "Bitset: Replaces all with /all"

;-- Integer in binary
test-bin-int: to binary! #{414243}  ; "ABC"
replace test-bin-int 65 #{39}       ; 65 = 'A' -> replace with 0x39 ('9')
assert-equal #{394243} test-bin-int "Binary: Integer search converts to char"

;-- Zero-length replacement
test-zeroreplace: "abc"
replace test-zeroreplace "b" ""
assert-equal "ac" test-zeroreplace "Zero-length replacement: Removes match"

;-- Block replacement (splicing behavior)
test-blk-replace: [a b c]
replace test-blk-replace 'b [x y]
assert-equal [a x y c] test-blk-replace "Block replacement: Always splices"

;; === Print Test Summary ===
print-test-summary
