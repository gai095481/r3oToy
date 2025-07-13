Rebol []

;;-----------------------------
;; A Battle-Tested QA Harness
;;------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
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
    {Output the final summary of the entire test run.}
    print "^/============================================"
    print ["=== TEST SUMMARY ==="]
    print ["Total Assertions: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED"
    ][
        print "❌ SOME TESTS FAILED"
    ]
    print "============================================^/"
]

print "^/====================================================="
print "=== CHARSET & PROTECT FUNCTIONALITY VERIFICATION ==="
print "=====================================================^/"

;; --- Define the baseline correct data for comparison ---
PUNCTUATION_STRING: {~`!@#$%&*()_+-={}[]|\:;'<>?,./^^"}
EXPECTED_CHARSET: charset PUNCTUATION_STRING

;;-----------------------------------------------------------------------------
;; SECTION 1: Verify `charset` Works with String Literals
;;-----------------------------------------------------------------------------
print "^/--- SECTION 1: `charset` with String Literals ---"

;; Test that `charset` correctly handles string literals
literal-charset: charset {"!@#$%"}
expected-literal: charset {"!@#$%"}

assert-equal bitset! type? literal-charset "`charset` with string literal should return bitset!"
assert-equal expected-literal literal-charset "`charset` with string literal should produce correct bitset"

;;-----------------------------------------------------------------------------
;; SECTION 2: Verify `charset` Works with Variables
;;-----------------------------------------------------------------------------
print "^/--- SECTION 2: `charset` with Variables ---"

;; Test that `charset` works consistently with variables
string-from-variable: PUNCTUATION_STRING
variable-charset: charset string-from-variable

assert-equal bitset! type? variable-charset "`charset` with variable should return bitset!"
assert-equal EXPECTED_CHARSET variable-charset "`charset` with variable should produce correct bitset"

;;-----------------------------------------------------------------------------
;; SECTION 3: Verify `protect` Works on Bitsets
;;-----------------------------------------------------------------------------
print "^/--- SECTION 3: `protect` Functionality ---"

;; Test that `protect` correctly handles bitsets
test-charset: charset {"!@#$%"}
original-charset: copy test-charset
protected-charset: protect test-charset

assert-equal bitset! type? protected-charset "`protect` on bitset should return bitset!"
assert-equal original-charset protected-charset "`protect` should not corrupt bitset data"

;; Test that protection actually works
protection-works: error? try [clear test-charset]
assert-equal true protection-works "Protected bitset should be immutable"

;;-----------------------------------------------------------------------------
;; SECTION 4: Verify Word Protection
;;-----------------------------------------------------------------------------
print "^/--- SECTION 4: Word Protection ---"

;; Test word protection functionality
test-constant: charset PUNCTUATION_STRING
protect 'test-constant

word-protected: error? try [test-constant: "replacement"]
assert-equal true word-protected "Protected word should prevent reassignment"

;; Verify the constant still works correctly
assert-equal EXPECTED_CHARSET test-constant "Protected constant should retain correct value"

;;-----------------------------------------------------------------------------
;; SECTION 5: Comprehensive Integration Test
;;-----------------------------------------------------------------------------
print "^/--- SECTION 5: Integration Test ---"

;; Create a protected charset constant using the most direct approach
PUNCT_CHARSET: protect charset {~`!@#$%&*()_+-={}[]|\:;'<>?,./^^"}
protect 'PUNCT_CHARSET

;; Test the final constant
assert-equal bitset! type? PUNCT_CHARSET "Final constant should be bitset!"
assert-equal EXPECTED_CHARSET PUNCT_CHARSET "Final constant should have correct data"

;; Test both value and word protection
value-protected: error? try [clear PUNCT_CHARSET]
word-protected: error? try [PUNCT_CHARSET: "foo"]

assert-equal true value-protected "Final constant value should be protected"
assert-equal true word-protected "Final constant word should be protected"

print "^/=== TESTING COMPLETE ===^/"
print-test-summary
