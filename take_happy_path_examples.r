REBOL [
    Title: "TAKE Function - Happy Path Examples"
    Date: now/date
    Author: "Jules (AI Agent)"
    Purpose: {
        Demonstrates common, simple, and correct uses of the TAKE function.
        This script is intended for Rebol developers looking to understand
        the basic operations of TAKE through clear, runnable examples.
        Each example is verified using the assert-equal test harness.
    }
    File: %take_happy_path_examples.r
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
        print "✅ ALL `take` HAPPY PATH EXAMPLES PASSED"
    ][
        print "❌ SOME `take` HAPPY PATH EXAMPLES FAILED"
    ]
    print "============================================^/"
]

; Script content will be added in subsequent steps.
print "Starting Happy Path Examples for TAKE function..."
print newline

; --- Example 1: Basic Take from Block ---
print "--- Example 1: Basic Take from Block ---"
; `take` on a block removes the first element and returns it.
; The original block is modified in place.
block1: [apple banana cherry]
original-block1-mold: mold block1 ; For verification message if needed
taken-fruit: take block1
modified-block1: copy block1 ; copy to assert against its current state

assert-equal 'apple taken-fruit "Basic take from block - returned value"
assert-equal [banana cherry] modified-block1 "Basic take from block - modified block"
print ["Original block: " original-block1-mold " -> After take: " mold modified-block1 "^/"]

; --- Example 2: Basic Take from String ---
print "--- Example 2: Basic Take from String ---"
; `take` on a string removes the first character and returns it.
; The original string is modified in place.
string1: "Hello"
original-string1-mold: mold string1
taken-char: take string1
modified-string1: copy string1

assert-equal #"H" taken-char "Basic take from string - returned character"
assert-equal "ello" modified-string1 "Basic take from string - modified string"
print ["Original string: " original-string1-mold " -> After take: " mold modified-string1 "^/"]

; --- Example 3: `take/last` from Block ---
print "--- Example 3: `take/last` from Block ---"
; `take/last` removes the last element from a series and returns it.
; The original block is modified in place.
block2: [10 20 30 40]
original-block2-mold: mold block2
taken-number: take/last block2
modified-block2: copy block2

assert-equal 40 taken-number "take/last from block - returned value"
assert-equal [10 20 30] modified-block2 "take/last from block - modified block"
print ["Original block: " original-block2-mold " -> After take/last: " mold modified-block2 "^/"]

; --- Example 4: `take/part` a Specific Number of Elements from a Block ---
print "--- Example 4: `take/part` a Specific Number of Elements from a Block ---"
; `take/part` with a number removes that many elements from the beginning
; of the series and returns them as a new series of the same type.
; The original block is modified in place.
block3: [a b c d e]
original-block3-mold: mold block3
num-to-take: 2
taken-part: take/part block3 num-to-take
modified-block3: copy block3

assert-equal [a b] taken-part "take/part count from block - returned part"
assert-equal [c d e] modified-block3 "take/part count from block - modified block"
print ["Original block: " original-block3-mold " -> After take/part " num-to-take ": " mold modified-block3 "^/"]

; --- Example 5: `take/all` from a String ---
print "--- Example 5: `take/all` from a String ---"
; `take/all` removes all elements from the series, returns them as a new
; series of the same type, and clears the original series (makes it empty).
string2: "Rebol"
original-string2-mold: mold string2
taken-all-string: take/all string2
modified-string2: copy string2

assert-equal "Rebol" taken-all-string "take/all from string - returned string"
assert-equal "" modified-string2 "take/all from string - modified (empty) string"
print ["Original string: " original-string2-mold " -> After take/all: " mold modified-string2 "^/"]

; --- Final Summary ---
print-test-summary
