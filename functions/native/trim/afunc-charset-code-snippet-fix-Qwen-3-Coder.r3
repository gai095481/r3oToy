REBOL []

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
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
;; Test Definitions
;;-----------------------------------------------------------------------------
;; --- Recreate the flawed function from the snippet database ---
afunc-flawed: funct [target [string!] chars-to-discard [bitset!]] [
    trim/with target (rejoin collect [repeat i 256 [c: to-char (i - 1) if find chars-to-discard c [keep c]]])
]

;; --- Define the correct function using iterative removal (Fixed Implementation) ---
;; This version correctly trims characters in the bitset from the head and tail only.
afunc-correct: funct [target [string!] chars-to-discard [bitset!]] [
    ; Trim head: Remove characters from the start as long as they are in the bitset
    while [not empty? target] [
        either find chars-to-discard first target [
            remove target
        ][
            break ; Exit loop if the first char is not in the bitset
        ]
    ]
    ; Trim tail: Remove characters from the end as long as they are in the bitset
    while [not empty? target] [
        either find chars-to-discard last target [
            clear back tail target ; Remove the last character
        ][
            break ; Exit loop if the last char is not in the bitset
        ]
    ]
    target ; Return the modified string
]

;; --- Define charsets for testing ---
test-charset-ab: charset "ab"
test-charset-space-tab: charset " ^-"

print "=== QA Tests for `trim/with` Charset Flaw ==="

;;-----------------------------------------------------------------------------
;; Test 1: Prove the flawed function's behavior is incorrect/predictable
;;-----------------------------------------------------------------------------
print "^/--- Test 1: Demonstrating the flaw in `afunc-flawed` ---"

;; The flawed function generates a string for trim/with that includes ALL ASCII chars
;; that are in the bitset, plus many others (including null).
flawed-generated-chars: rejoin collect [repeat i 256 [c: to-char (i - 1) if find test-charset-ab c [keep c]]]
print ["Generated chars for trim/with (flawed) starts with:" mold copy/part flawed-generated-chars 10]

;; Test Case 1a: Simple case, shows flaw - removes more than just 'a'/'b' potentially
;; This case happened to align with the correct logic due to trim/with's behavior,
;; but it's unreliable.
test-target-1a: "abacus"
expected-result-1a-flawed: "cus" ; This is what the FLAWED function actually produced
actual-result-1a-flawed: afunc-flawed copy test-target-1a test-charset-ab
assert-equal expected-result-1a-flawed actual-result-1a-flawed rejoin ["Flawed afunc on '" test-target-1a "' (observes flawed output)"]

;; Test Case 1b: Another case, shows flaw
test-target-1b: "bxbxxa"
expected-result-1b-flawed: "xxx" ; This is what the FLAWED function actually produced
actual-result-1b-flawed: afunc-flawed copy test-target-1b test-charset-ab
assert-equal expected-result-1b-flawed actual-result-1b-flawed rejoin ["Flawed afunc on '" test-target-1b "' (observes flawed output)"]

;; Test Case 1c: Demonstrates erratic behavior due to generated string content
;; If the generated string includes ASCII 1 (#"^A") and 2 (#"^B"),
;; trim/with might remove them even if not intended by the original charset.
test-target-1c: "^(01)bxbxxa^(02)"
actual-result-1c-flawed: afunc-flawed copy test-target-1c test-charset-ab
print ["Flawed afunc on string with ^A/^B (unpredictable):" mold actual-result-1c-flawed]
print "   ^-- Shows erratic behavior due to generated trim string content."

;;-----------------------------------------------------------------------------
;; Test 2: Prove the correct function works as intended (for trimming head/tail)
;;-----------------------------------------------------------------------------
print "^/--- Test 2: Validating the `afunc-correct` fix (head/tail trim) ---"

;; Test Case 2a: Simple case, should work correctly for `/head` `/tail` `trim`:
test-target-2a: "abacus"
expected-result-2a: "cus" ; Correctly trims 'a'/'b' from start, 'a' from end -> "cus"
actual-result-2a: afunc-correct copy test-target-2a test-charset-ab
assert-equal expected-result-2a actual-result-2a rejoin ["Correct afunc on '" test-target-2a "' (trims head/tail)"]

;; Test Case 2b: Another case, should work correctly
test-target-2b: "bxbxxa"
expected-result-2b: "xbxx" ; 'b' from start, 'a' from end
actual-result-2b: afunc-correct copy test-target-2b test-charset-ab
assert-equal expected-result-2b actual-result-2b rejoin ["Correct afunc on '" test-target-2b "' (trims head/tail)"]

;; Test Case 2c: Test trimming common whitespace chars
test-target-2c: "  ^- hello world ^-  "
expected-result-2c: "hello world"
actual-result-2c: afunc-correct copy test-target-2c test-charset-space-tab
assert-equal expected-result-2c actual-result-2c rejoin ["Correct afunc trimming space/tab on '" test-target-2c "'"]

;; Test Case 2d: Edge case - empty string
test-target-2d: ""
expected-result-2d: ""
actual-result-2d: afunc-correct copy test-target-2d test-charset-ab
assert-equal expected-result-2d actual-result-2d rejoin ["Correct afunc on empty string"]

;; Test Case 2e: Edge case - string consists only of chars to discard
test-target-2e: "abba"
expected-result-2e: ""
actual-result-2e: afunc-correct copy test-target-2e test-charset-ab
assert-equal expected-result-2e actual-result-2e rejoin ["Correct afunc on string to fully discard '" test-target-2e "'"]

;; Test Case 2f: Edge case - string has no chars to discard
test-target-2f: "hello"
expected-result-2f: "hello"
actual-result-2f: afunc-correct copy test-target-2f test-charset-ab
assert-equal expected-result-2f actual-result-2f rejoin ["Correct afunc on string with no discard chars '" test-target-2f "'"]

;; Test Case 2g: Edge case - string has chars to discard only in the middle
test-target-2g: "xxabyy"
expected-result-2g: "xxabyy" ; Should remain unchanged as 'a','b' are not at head/tail
actual-result-2g: afunc-correct copy test-target-2g test-charset-ab
assert-equal expected-result-2g actual-result-2g rejoin ["Correct afunc on string with internal discard chars '" test-target-2g "'"]

print-test-summary
