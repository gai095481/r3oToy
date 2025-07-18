REBOL [
    Title: "Comprehensive Verification Test Suite - Battle-Tested QA Harness"
    Date: 17-Jul-2025
    File: %test-comprehensive-verification.r3
    Author: "Kiro AI Assistant"
    Purpose: "Comprehensive verification test suite using battle-tested QA harness for backslash escaping fixes"
]

;; Load the RegExp engine
do %regexp-engine.r3

;;=============================================================================
;; BATTLE-TESTED QA HARNESS
;;=============================================================================
;; This proven QA harness provides visual confirmation of test results
;; with clear PASSED/FAILED indicators and comprehensive test summaries

all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: funct [
    "Compare two values and output a formatted PASSED or FAILED message."
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
] [
    set 'test-count test-count + 1
    either equal? expected actual [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ] [
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description
            "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    "Output the final summary of the entire test run."
    print "^/============================================"
    print "=== COMPREHENSIVE VERIFICATION TEST SUMMARY ==="
    print "============================================"
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - BACKSLASH ESCAPING VERIFICATION COMPLETE"
    ] [
        print "❌ SOME TESTS FAILED - BACKSLASH ESCAPING NEEDS REVIEW"
    ]
    print "============================================^/"
]

;;=============================================================================
;; POSITIVE ESCAPE SEQUENCES TESTS (\d, \w, \s)
;;=============================================================================

test-positive-escape-sequences: does [
    "Test all positive escape sequences with visual confirmation"
    
    print "^/=== TESTING POSITIVE ESCAPE SEQUENCES ==="
    
    ;; Test \d (digit) patterns
    print "^/--- Testing \d (digit) patterns ---"
    assert-equal "5" RegExp "5" "\d" "\d should match single digit '5'"
    assert-equal "123" RegExp "123" "\d+" "\d+ should match multiple digits '123'"
    assert-equal "7" RegExp "abc7def" "\d" "\d should match digit '7' within text"
    assert-equal false RegExp "abc" "\d" "\d should not match non-digit text 'abc'"
    assert-equal false RegExp "" "\d" "\d should not match empty string"
    
    ;; Test \w (word character) patterns  
    print "^/--- Testing \w (word character) patterns ---"
    assert-equal "a" RegExp "a" "\w" "\w should match single letter 'a'"
    assert-equal "A" RegExp "A" "\w" "\w should match uppercase letter 'A'"
    assert-equal "5" RegExp "5" "\w" "\w should match digit '5' as word character"
    assert-equal "_" RegExp "_" "\w" "\w should match underscore '_' as word character"
    assert-equal "abc123_" RegExp "abc123_" "\w+" "\w+ should match word characters 'abc123_'"
    assert-equal false RegExp "!@#" "\w" "\w should not match special characters '!@#'"
    assert-equal false RegExp " " "\w" "\w should not match whitespace ' '"
    
    ;; Test \s (whitespace) patterns
    print "^/--- Testing \s (whitespace) patterns ---"
    assert-equal " " RegExp " " "\s" "\s should match space character ' '"
    assert-equal "^-" RegExp "^-" "\s" "\s should match tab character"
    assert-equal "^/" RegExp "^/" "\s" "\s should match newline character"
    assert-equal "   " RegExp "   " "\s+" "\s+ should match multiple spaces '   '"
    assert-equal false RegExp "a" "\s" "\s should not match non-whitespace 'a'"
    assert-equal false RegExp "123" "\s" "\s should not match digits '123'"
]

;;=============================================================================
;; NEGATED ESCAPE SEQUENCES TESTS (\D, \W, \S)
;;=============================================================================

test-negated-escape-sequences: does [
    "Test all negated escape sequences with visual confirmation"
    
    print "^/=== TESTING NEGATED ESCAPE SEQUENCES ==="
    
    ;; Test \D (non-digit) patterns
    print "^/--- Testing \D (non-digit) patterns ---"
    assert-equal "a" RegExp "a" "\D" "\D should match non-digit 'a'"
    assert-equal "Z" RegExp "Z" "\D" "\D should match non-digit 'Z'"
    assert-equal "!" RegExp "!" "\D" "\D should match special character '!'"
    assert-equal " " RegExp " " "\D" "\D should match whitespace ' '"
    assert-equal "abc" RegExp "abc" "\D+" "\D+ should match multiple non-digits 'abc'"
    assert-equal "hello!" RegExp "hello!" "\D+" "\D+ should match text with special char 'hello!'"
    assert-equal false RegExp "5" "\D" "\D should not match digit '5'"
    assert-equal false RegExp "123" "\D+" "\D+ should not match digits '123'"
    
    ;; Test \W (non-word character) patterns
    print "^/--- Testing \W (non-word character) patterns ---"
    assert-equal "!" RegExp "!" "\W" "\W should match non-word character '!'"
    assert-equal "@" RegExp "@" "\W" "\W should match non-word character '@'"
    assert-equal "#" RegExp "#" "\W" "\W should match non-word character '#'"
    assert-equal " " RegExp " " "\W" "\W should match whitespace ' '"
    assert-equal "!@#" RegExp "!@#" "\W+" "\W+ should match multiple non-word characters '!@#'"
    assert-equal ".,;" RegExp ".,;" "\W+" "\W+ should match punctuation '.,;'"
    assert-equal false RegExp "a" "\W" "\W should not match word character 'a'"
    assert-equal false RegExp "A" "\W" "\W should not match word character 'A'"
    assert-equal false RegExp "5" "\W" "\W should not match digit '5'"
    assert-equal false RegExp "_" "\W" "\W should not match underscore '_'"
    assert-equal false RegExp "abc123_" "\W+" "\W+ should not match word characters 'abc123_'"
    
    ;; Test \S (non-whitespace) patterns
    print "^/--- Testing \S (non-whitespace) patterns ---"
    assert-equal "a" RegExp "a" "\S" "\S should match non-whitespace character 'a'"
    assert-equal "5" RegExp "5" "\S" "\S should match non-whitespace character '5'"
    assert-equal "!" RegExp "!" "\S" "\S should match non-whitespace character '!'"
    assert-equal "abc" RegExp "abc" "\S+" "\S+ should match multiple non-whitespace characters 'abc'"
    assert-equal "hello123!" RegExp "hello123!" "\S+" "\S+ should match mixed non-whitespace 'hello123!'"
    assert-equal false RegExp " " "\S" "\S should not match space character ' '"
    assert-equal false RegExp "^-" "\S" "\S should not match tab character"
    assert-equal false RegExp "^/" "\S" "\S should not match newline character"
    assert-equal false RegExp "   " "\S+" "\S+ should not match whitespace characters '   '"
]

;;=============================================================================
;; QUANTIFIER COMBINATIONS TESTS
;;=============================================================================

test-quantifier-combinations: does [
    "Test quantifier combinations with all escape sequences using QA harness"
    
    print "^/=== TESTING QUANTIFIER COMBINATIONS ==="
    
    ;; Test + quantifier (one or more)
    print "^/--- Testing + quantifier (one or more) ---"
    assert-equal "123" RegExp "123" "\d+" "\d+ should match one or more digits '123'"
    assert-equal "abc_123" RegExp "abc_123" "\w+" "\w+ should match one or more word chars 'abc_123'"
    assert-equal "   " RegExp "   " "\s+" "\s+ should match one or more spaces '   '"
    assert-equal "abc" RegExp "abc" "\D+" "\D+ should match one or more non-digits 'abc'"
    assert-equal "!@#" RegExp "!@#" "\W+" "\W+ should match one or more non-word chars '!@#'"
    assert-equal "hello" RegExp "hello" "\S+" "\S+ should match one or more non-whitespace 'hello'"
    
    ;; Test * quantifier (zero or more)
    print "^/--- Testing * quantifier (zero or more) ---"
    assert-equal "" RegExp "" "\d*" "\d* should match zero digits (empty string)"
    assert-equal "123" RegExp "123" "\d*" "\d* should match multiple digits '123'"
    assert-equal "" RegExp "" "\w*" "\w* should match zero word chars (empty string)"
    assert-equal "abc_123" RegExp "abc_123" "\w*" "\w* should match multiple word chars 'abc_123'"
    assert-equal "" RegExp "" "\s*" "\s* should match zero spaces (empty string)"
    assert-equal "   " RegExp "   " "\s*" "\s* should match multiple spaces '   '"
    
    ;; Test ? quantifier (zero or one)
    print "^/--- Testing ? quantifier (zero or one) ---"
    assert-equal "" RegExp "" "\d?" "\d? should match zero digits (empty string)"
    assert-equal "5" RegExp "5" "\d?" "\d? should match one digit '5'"
    assert-equal "" RegExp "" "\w?" "\w? should match zero word chars (empty string)"
    assert-equal "a" RegExp "a" "\w?" "\w? should match one word char 'a'"
    assert-equal "" RegExp "" "\s?" "\s? should match zero spaces (empty string)"
    assert-equal " " RegExp " " "\s?" "\s? should match one space ' '"
    
    ;; Test {n} exact quantifier
    print "^/--- Testing {n} exact quantifier ---"
    assert-equal "123" RegExp "123" "\d{3}" "\d{3} should match exactly 3 digits '123'"
    assert-equal false RegExp "12" "\d{3}" "\d{3} should not match 2 digits '12'"
    assert-equal false RegExp "1234" "\d{3}" "\d{3} should not match 4 digits '1234'"
    assert-equal "abc" RegExp "abc" "\w{3}" "\w{3} should match exactly 3 word chars 'abc'"
    assert-equal "   " RegExp "   " "\s{3}" "\s{3} should match exactly 3 spaces '   '"
    
    ;; Test {n,m} range quantifier
    print "^/--- Testing {n,m} range quantifier ---"
    assert-equal "12" RegExp "12" "\d{2,4}" "\d{2,4} should match 2 digits '12'"
    assert-equal "123" RegExp "123" "\d{2,4}" "\d{2,4} should match 3 digits '123'"
    assert-equal "1234" RegExp "1234" "\d{2,4}" "\d{2,4} should match 4 digits '1234'"
    assert-equal false RegExp "1" "\d{2,4}" "\d{2,4} should not match 1 digit '1'"
    assert-equal "ab" RegExp "ab" "\w{2,4}" "\w{2,4} should match 2 word chars 'ab'"
    assert-equal "abcd" RegExp "abcd" "\w{2,4}" "\w{2,4} should match 4 word chars 'abcd'"
]

;;=============================================================================
;; MIXED PATTERN TESTS
;;=============================================================================

test-mixed-patterns: does [
    "Create mixed pattern tests combining multiple escape sequences with clear PASSED/FAILED indicators"
    
    print "^/=== TESTING MIXED PATTERN COMBINATIONS ==="
    
    ;; Test combinations of positive escape sequences
    print "^/--- Testing positive escape sequence combinations ---"
    assert-equal "abc123" RegExp "abc123" "\w+\d+" "\w+\d+ should match letters followed by digits 'abc123'"
    assert-equal "123abc" RegExp "123abc" "\d+\w+" "\d+\w+ should match digits followed by letters '123abc'"
    assert-equal "hello world" RegExp "hello world" "\w+\s\w+" "\w+\s\w+ should match word-space-word 'hello world'"
    assert-equal "a1 b2 c3" RegExp "a1 b2 c3" "\w\d\s\w\d\s\w\d" "\w\d\s\w\d\s\w\d should match alternating pattern 'a1 b2 c3'"
    assert-equal "test123 data" RegExp "test123 data" "\w+\d+\s\w+" "\w+\d+\s\w+ should match complex word pattern 'test123 data'"
    
    ;; Test combinations with negated escape sequences
    print "^/--- Testing negated escape sequence combinations ---"
    assert-equal "abc123" RegExp "abc123" "\D+\d+" "\D+\d+ should match non-digits followed by digits 'abc123'"
    assert-equal "123abc" RegExp "123abc" "\d+\D+" "\d+\D+ should match digits followed by non-digits '123abc'"
    assert-equal "hello!world" RegExp "hello!world" "\S+\W\S+" "\S+\W\S+ should match non-space, non-word, non-space 'hello!world'"
    assert-equal "word space" RegExp "word space" "\S+\s\S+" "\S+\s\S+ should match non-space, space, non-space 'word space'"
    
    ;; Test mixed positive and negated patterns
    print "^/--- Testing mixed positive and negated patterns ---"
    assert-equal "a1!b2" RegExp "a1!b2" "\w\d\W\w\d" "\w\d\W\w\d should match word-digit-nonword-word-digit 'a1!b2'"
    assert-equal "123 abc" RegExp "123 abc" "\d+\s\D+" "\d+\s\D+ should match digits-space-nondigits '123 abc'"
    assert-equal "hello 123" RegExp "hello 123" "\D+\s\d+" "\D+\s\d+ should match nondigits-space-digits 'hello 123'"
    assert-equal "word!123" RegExp "word!123" "\w+\W\d+" "\w+\W\d+ should match word-nonword-digits 'word!123'"
    
    ;; Test complex mixed patterns with quantifiers
    print "^/--- Testing complex mixed patterns with quantifiers ---"
    assert-equal "abc123def456" RegExp "abc123def456" "\D+\d+\D+\d+" "\D+\d+\D+\d+ should match alternating non-digits and digits"
    assert-equal "hello world 123" RegExp "hello world 123" "\S+\s\S+\s\d+" "\S+\s\S+\s\d+ should match word-space-word-space-digits"
    assert-equal "test_123!@#" RegExp "test_123!@#" "\w+\W+" "\w+ followed by \W+ should match word chars then non-word chars"
    assert-equal "a1 b2 c3 d4" RegExp "a1 b2 c3 d4" "(\w\d\s){3}\w\d" "Complex repeating pattern should match 'a1 b2 c3 d4'"
    
    ;; Test edge cases with mixed patterns
    print "^/--- Testing edge cases with mixed patterns ---"
    assert-equal "a" RegExp "a" "\D\d?" "\D\d? should match non-digit optionally followed by digit 'a'"
    assert-equal "a5" RegExp "a5" "\D\d?" "\D\d? should match non-digit optionally followed by digit 'a5'"
    assert-equal "!" RegExp "!" "\W\w*" "\W\w* should match non-word char optionally followed by word chars '!'"
    assert-equal "!abc" RegExp "!abc" "\W\w*" "\W\w* should match non-word char optionally followed by word chars '!abc'"
    assert-equal " " RegExp " " "\s\S*" "\s\S* should match space optionally followed by non-space chars ' '"
    assert-equal " hello" RegExp " hello" "\s\S*" "\s\S* should match space optionally followed by non-space chars ' hello'"
]

;;=============================================================================
;; COMPREHENSIVE TEST EXECUTION
;;=============================================================================

run-comprehensive-verification-tests: does [
    "Execute all comprehensive verification tests with battle-tested QA harness"
    
    print "^/=========================================="
    print "COMPREHENSIVE VERIFICATION TEST SUITE"
    print "Battle-Tested QA Harness for Backslash Escaping Fixes"
    print "=========================================="
    
    ;; Reset test counters
    all-tests-passed?: true
    test-count: 0
    pass-count: 0
    fail-count: 0
    
    ;; Execute all test suites
    test-positive-escape-sequences
    test-negated-escape-sequences
    test-quantifier-combinations
    test-mixed-patterns
    
    ;; Print comprehensive summary
    print-test-summary
    
    ;; Return overall test status
    all-tests-passed?
]

;; Execute the comprehensive verification test suite
print "^/Starting Comprehensive Verification Test Suite..."
test-result: run-comprehensive-verification-tests

either test-result [
    print "^/🎉 COMPREHENSIVE VERIFICATION COMPLETE - ALL TESTS PASSED!"
    print "Backslash escaping patterns are working correctly."
] [
    print "^/⚠️  COMPREHENSIVE VERIFICATION INCOMPLETE - SOME TESTS FAILED!"
    print "Review failed tests above for backslash escaping issues."
]
