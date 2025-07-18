REBOL [
    Title: "Error Handling Tests for TranslateRegExp"
    Date: 17-Jul-2025
    Version: 0.1.0
    File: %test-error-handling.r3
    Author: "Claude 4 Sonnet"
]

;; Load the main regexp engine
do %regexp-engine.r3

;;=============================================================================
;; ERROR HANDLING TEST SUITE
;;=============================================================================
;; Test tracking variables
error-test-count: 0
error-pass-count: 0
error-fail-count: 0
error-all-passed?: true

;; Test helper function
test-error-handling: funct [
    "Test error handling with expected behavior"
    pattern [string!] "Pattern to test"
    expected-result [logic! none!] "Expected result: true=success, false=valid but no match, none=error"
    description [string!] "Test description"
] [
    error-test-count: error-test-count + 1
    
    ;; Test TranslateRegExp directly
    translation-result: TranslateRegExp pattern
    
    ;; Test the full RegExp function
    regexp-result: none
    set/any 'regexp-result try [
        RegExp "test" pattern
    ]
    
    ;; Determine actual behavior
    actual-behavior: either none? translation-result [
        none  ;; Translation failed
    ] [
        either error? regexp-result [
            none  ;; Execution error
        ] [
            either regexp-result [
                true  ;; Match found
            ] [
                false  ;; No match but valid pattern
            ]
        ]
    ]
    
    ;; Compare with expected
    either expected-result = actual-behavior [
        error-pass-count: error-pass-count + 1
        print ["✅ PASSED:" description]
        print ["   Pattern:" pattern "-> Expected:" mold expected-result "Got:" mold actual-behavior]
    ] [
        error-fail-count: error-fail-count + 1
        error-all-passed?: false
        print ["❌ FAILED:" description]
        print ["   Pattern:" pattern]
        print ["   Expected:" mold expected-result]
        print ["   Got:" mold actual-behavior]
        if translation-result [
            print ["   Translation result:" mold translation-result]
        ]
    ]
]

;; Run comprehensive error handling tests
RunErrorHandlingTests: does [
    print "^/=========================================="
    print "    ERROR HANDLING COMPREHENSIVE TESTS"
    print "=========================================="
    
    ;; Reset counters
    error-test-count: 0
    error-pass-count: 0
    error-fail-count: 0
    error-all-passed?: true
    
    print "^/--- MALFORMED PATTERN TESTS ---"
    
    ;; Test malformed character classes
    test-error-handling "[a-" none "Unclosed character class"
    test-error-handling "[" none "Incomplete character class start"
    test-error-handling "[]" none "Empty character class"
    test-error-handling "[a-z-]" none "Invalid range at end"
    test-error-handling "[-a-z]" none "Invalid range at start"
    
    print "^/--- INVALID QUANTIFIER TESTS ---"
    
    ;; Test invalid quantifiers
    test-error-handling "a{}" none "Empty quantifier"
    test-error-handling "a{,}" none "Invalid quantifier format"
    test-error-handling "a{2,1}" none "Invalid range (min > max)"
    test-error-handling "a{-1}" none "Negative quantifier"
    test-error-handling "a{abc}" none "Non-numeric quantifier"
    test-error-handling "a{1,abc}" none "Non-numeric max in range"
    test-error-handling "a{abc,5}" none "Non-numeric min in range"
    test-error-handling "a{99999}" none "Extremely large quantifier"
    
    ;; Test valid quantifiers (should work)
    test-error-handling "a{3}" false "Valid exact quantifier"
    test-error-handling "a{2,5}" false "Valid range quantifier"
    test-error-handling "a{0}" false "Zero quantifier"
    test-error-handling "a{0,3}" false "Zero to N quantifier"
    
    print "^/--- ESCAPE SEQUENCE TESTS ---"
    
    ;; Test invalid escape sequences (should be treated as literals)
    test-error-handling "\\q" false "Invalid escape sequence \\q"
    test-error-handling "\\x" false "Invalid escape sequence \\x"
    test-error-handling "\\z" false "Invalid escape sequence \\z"
    
    ;; Test valid escape sequences
    test-error-handling "\\d" false "Valid digit escape"
    test-error-handling "\\w" false "Valid word escape"
    test-error-handling "\\s" false "Valid whitespace escape"
    test-error-handling "\\." false "Valid dot escape"
    
    print "^/--- EDGE CASE TESTS ---"
    
    ;; Test empty pattern
    test-error-handling "" false "Empty pattern"
    
    ;; Test very complex but valid patterns
    test-error-handling "\\d+\\w*\\s?" false "Complex valid pattern"
    test-error-handling "[a-z]{2,5}\\d{3}" false "Mixed character class and escape"
    
    print "^/--- QUANTIFIER WITH ESCAPE SEQUENCE TESTS ---"
    
    ;; Test quantifiers with escape sequences
    test-error-handling "\\d{}" none "Empty quantifier with escape"
    test-error-handling "\\w{2,1}" none "Invalid range with escape"
    test-error-handling "\\s{-1}" none "Negative quantifier with escape"
    test-error-handling "\\d{abc}" none "Non-numeric quantifier with escape"
    
    ;; Valid quantifiers with escapes
    test-error-handling "\\d{3}" false "Valid quantifier with digit escape"
    test-error-handling "\\w{2,5}" false "Valid range with word escape"
    test-error-handling "\\s{0,3}" false "Valid range with whitespace escape"
    
    print "^/--- CHARACTER CLASS WITH QUANTIFIER TESTS ---"
    
    ;; Test character classes with invalid quantifiers
    test-error-handling "[a-z]{}" none "Character class with empty quantifier"
    test-error-handling "[0-9]{2,1}" none "Character class with invalid range"
    test-error-handling "[a-z]{abc}" none "Character class with non-numeric quantifier"
    
    ;; Valid character class quantifiers
    test-error-handling "[a-z]{3}" false "Character class with valid quantifier"
    test-error-handling "[0-9]{2,5}" false "Character class with valid range"
    
    ;; Display results
    print "^/=========================================="
    print "       ERROR HANDLING TEST SUMMARY"
    print "=========================================="
    print ["Total Error Tests:" error-test-count]
    print ["Passed:" error-pass-count]
    print ["Failed:" error-fail-count]
    
    if error-test-count > 0 [
        success-rate: round/to (error-pass-count * 100.0) / error-test-count 0.1
        print ["Success Rate:" success-rate "%"]
    ]
    
    prin lf
    either error-all-passed? [
        print "✅ ALL ERROR HANDLING TESTS PASSED!"
    ] [
        print "❌ SOME ERROR HANDLING TESTS FAILED"
    ]
    print "=========================================="
]

;; Test specific helper functions
TestHelperFunctions: does [
    print "^/=========================================="
    print "       HELPER FUNCTION TESTS"
    print "=========================================="
    
    helper-test-count: 0
    helper-pass-count: 0
    helper-fail-count: 0
    helper-all-passed?: true
    
    test-helper: funct [
        "Test helper function"
        test-func [function!] "Function to test"
        input [any-type!] "Input to test"
        expected [any-type!] "Expected result"
        description [string!] "Test description"
    ] [
        helper-test-count: helper-test-count + 1
        
        actual: test-func input
        
        either expected = actual [
            helper-pass-count: helper-pass-count + 1
            print ["✅ PASSED:" description]
        ] [
            helper-fail-count: helper-fail-count + 1
            helper-all-passed?: false
            print ["❌ FAILED:" description]
            print ["   Input:" mold input]
            print ["   Expected:" mold expected]
            print ["   Got:" mold actual]
        ]
    ]
    
    print "^/--- ValidateQuantifierRange Tests ---"
    
    ;; Test ValidateQuantifierRange function
    test-helper :ValidateQuantifierRange "3" true "Valid exact quantifier"
    test-helper :ValidateQuantifierRange "2,5" true "Valid range quantifier"
    test-helper :ValidateQuantifierRange "" false "Empty quantifier"
    test-helper :ValidateQuantifierRange "abc" false "Non-numeric quantifier"
    test-helper :ValidateQuantifierRange "2,1" false "Invalid range (min > max)"
    test-helper :ValidateQuantifierRange "-1" false "Negative quantifier"
    test-helper :ValidateQuantifierRange "99999" false "Very large quantifier"
    test-helper :ValidateQuantifierRange "0" true "Zero quantifier"
    test-helper :ValidateQuantifierRange "0,3" true "Zero to N range"
    
    print "^/--- ValidateCharacterClass Tests ---"
    
    ;; Test ValidateCharacterClass function
    test-helper :ValidateCharacterClass "a-z" true "Valid character range"
    test-helper :ValidateCharacterClass "0-9" true "Valid digit range"
    test-helper :ValidateCharacterClass "" false "Empty character class"
    test-helper :ValidateCharacterClass "a-" false "Incomplete range at end"
    test-helper :ValidateCharacterClass "-z" false "Incomplete range at start"
    test-helper :ValidateCharacterClass "^a-z" true "Valid negated class"
    test-helper :ValidateCharacterClass "abc" true "Valid literal characters"
    
    ;; Display helper function test results
    print "^/--- HELPER FUNCTION TEST SUMMARY ---"
    print ["Total Helper Tests:" helper-test-count]
    print ["Passed:" helper-pass-count]
    print ["Failed:" helper-fail-count]
    
    if helper-test-count > 0 [
        success-rate: round/to (helper-pass-count * 100.0) / helper-test-count 0.1
        print ["Success Rate:" success-rate "%"]
    ]
    
    prin lf
    either helper-all-passed? [
        print "✅ ALL HELPER FUNCTION TESTS PASSED!"
    ] [
        print "❌ SOME HELPER FUNCTION TESTS FAILED"
    ]
]

;; Main test execution
print "^/=========================================="
print "  COMPREHENSIVE ERROR HANDLING TESTING"
print "=========================================="

;; Run helper function tests first
TestHelperFunctions

;; Run main error handling tests
RunErrorHandlingTests

print "^/=========================================="
print "         ALL ERROR TESTING COMPLETE"
print "=========================================="
