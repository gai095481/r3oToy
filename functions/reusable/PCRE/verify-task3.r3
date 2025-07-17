REBOL [
    Title: "Task 3 Verification - Error Handling in TranslateRegExp"
    Date: 17-Jul-2025
    Version: 0.1.0
    File: %verify-task3.r3
    Author: "Claude 4 Sonnet"
]

;; Load the main regexp engine
do %regexp-engine.r3

;;=============================================================================
;; TASK 3 VERIFICATION TESTS
;;=============================================================================

print "^/=========================================="
print "    TASK 3: ERROR HANDLING VERIFICATION"
print "=========================================="

;; Test tracking
test-count: 0
pass-count: 0
fail-count: 0

test-error-case: func [
    "Test an error case and verify it returns none"
    pattern [string!] "Pattern to test"
    description [string!] "Test description"
    /local result
] [
    test-count: test-count + 1
    result: TranslateRegExp pattern
    
    either none? result [
        pass-count: pass-count + 1
        print ["✅ PASS:" description "- Pattern:" pattern "-> none"]
    ] [
        fail-count: fail-count + 1
        print ["❌ FAIL:" description "- Pattern:" pattern "-> Expected: none, Got:" mold result]
    ]
]

test-valid-case: func [
    "Test a valid case and verify it returns a block"
    pattern [string!] "Pattern to test"
    description [string!] "Test description"
    /local result
] [
    test-count: test-count + 1
    result: TranslateRegExp pattern
    
    either block? result [
        pass-count: pass-count + 1
        print ["✅ PASS:" description "- Pattern:" pattern "-> block"]
    ] [
        fail-count: fail-count + 1
        print ["❌ FAIL:" description "- Pattern:" pattern "-> Expected: block, Got:" mold result]
    ]
]

print "^/--- MALFORMED PATTERN TESTS ---"

;; Test malformed character classes
test-error-case "[a-" "Unclosed character class"
test-error-case "[" "Incomplete character class"
test-error-case "[]" "Empty character class"

print "^/--- INVALID QUANTIFIER TESTS ---"

;; Test invalid quantifiers
test-error-case "a{}" "Empty quantifier"
test-error-case "a{,}" "Invalid quantifier format"
test-error-case "a{2,1}" "Invalid range (min > max)"
test-error-case "a{-1}" "Negative quantifier"
test-error-case "a{abc}" "Non-numeric quantifier"
test-error-case "\d{}" "Empty quantifier with escape"
test-error-case "\w{2,1}" "Invalid range with escape"
test-error-case "[a-z]{}" "Character class with empty quantifier"

print "^/--- VALID PATTERN TESTS ---"

;; Test valid patterns
test-valid-case "a{3}" "Valid exact quantifier"
test-valid-case "a{2,5}" "Valid range quantifier"
test-valid-case "\d+" "Valid escape with quantifier"
test-valid-case "\w*" "Valid word escape with quantifier"
test-valid-case "\s?" "Valid whitespace escape with quantifier"
test-valid-case "[a-z]" "Valid character class"
test-valid-case "[0-9]{3}" "Valid character class with quantifier"
test-valid-case "" "Empty pattern"

print "^/--- REGEXP FUNCTION ERROR HANDLING TESTS ---"

;; Test RegExp function error handling
regexp-test-count: 0
regexp-pass-count: 0
regexp-fail-count: 0

test-regexp-error: func [
    "Test RegExp function error handling"
    input [string!] "Input string"
    pattern [string!] "Pattern to test"
    expected [word! logic! none!] "Expected result type"
    description [string!] "Test description"
    /local result result-type
] [
    regexp-test-count: regexp-test-count + 1
    result: RegExp input pattern
    
    result-type: either none? result [
        none
    ] [
        either string? result [
            'string
        ] [
            either result = false [
                false
            ] [
                'other
            ]
        ]
    ]
    
    either expected = result-type [
        regexp-pass-count: regexp-pass-count + 1
        print ["✅ PASS:" description "- Result type:" mold result-type]
    ] [
        regexp-fail-count: regexp-fail-count + 1
        print ["❌ FAIL:" description "- Expected:" mold expected "Got:" mold result-type]
    ]
]

;; Test error cases return none
test-regexp-error "test" "[a-" none "Malformed character class returns none"
test-regexp-error "test" "a{}" none "Invalid quantifier returns none"
test-regexp-error "test" "a{2,1}" none "Invalid range returns none"

;; Test valid cases with matches return string
test-regexp-error "abc" "[a-z]+" 'string "Valid pattern with match returns string"
test-regexp-error "123" "\d+" 'string "Valid escape pattern with match returns string"

;; Test valid cases with no matches return false
test-regexp-error "123" "[a-z]+" false "Valid pattern with no match returns false"
test-regexp-error "abc" "\d+" false "Valid escape pattern with no match returns false"

print "^/--- EDGE CASE TESTS ---"

;; Test edge cases
test-valid-case "\q" "Invalid escape sequence (treated as literal)"
test-valid-case "\x" "Invalid escape sequence (treated as literal)"
test-valid-case "\." "Valid dot escape"

print "^/=========================================="
print "           TASK 3 TEST SUMMARY"
print "=========================================="

total-tests: test-count + regexp-test-count
total-passed: pass-count + regexp-pass-count
total-failed: fail-count + regexp-fail-count

print ["TranslateRegExp Tests:" test-count "(" pass-count "passed," fail-count "failed)"]
print ["RegExp Function Tests:" regexp-test-count "(" regexp-pass-count "passed," regexp-fail-count "failed)"]
print ["Total Tests:" total-tests]
print ["Total Passed:" total-passed]
print ["Total Failed:" total-failed]

if total-tests > 0 [
    success-rate: round/to (total-passed * 100.0) / total-tests 0.1
    print ["Success Rate:" success-rate "%"]
]

prin lf
either total-failed = 0 [
    print "✅ ALL TASK 3 TESTS PASSED!"
    print "✅ COMPREHENSIVE ERROR HANDLING IMPLEMENTED SUCCESSFULLY"
] [
    print "❌ SOME TASK 3 TESTS FAILED"
]
print "=========================================="
