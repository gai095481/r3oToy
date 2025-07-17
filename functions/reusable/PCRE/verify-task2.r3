REBOL [
    Title: "Verify Task 2 Requirements"
]

do %regexp-engine.r3

print "=== TASK 2 VERIFICATION ==="
print "Verifying all requirements for Task 2: Enhance quantifier handling for escape sequences"
print ""

;; Test counters
test-count: 0
pass-count: 0
fail-count: 0
all-tests-passed?: true

;; Helper function for testing
test-quantifier: funct [
    "Test a quantifier pattern and report results"
    input [string!] "Input string to test"
    pattern [string!] "Regex pattern to test"
    expected [logic!] "Expected result"
    description [string!] "Test description"
    requirement [string!] "Requirement reference"
    return: [block!] "Updated [test-count pass-count fail-count all-tests-passed]"
] [
    new-test-count: test-count + 1
    actual: TestRegExp input pattern
    
    either actual = expected [
        new-pass-count: pass-count + 1
        new-fail-count: fail-count
        new-all-passed: all-tests-passed?
        print ["✅ PASSED:" description "(" requirement ")"]
    ] [
        new-pass-count: pass-count
        new-fail-count: fail-count + 1
        new-all-passed: false
        print ["❌ FAILED:" description "(" requirement ")"]
        print ["   Expected:" expected "Actual:" actual]
    ]
    
    reduce [new-test-count new-pass-count new-fail-count new-all-passed]
]

;; REQUIREMENT 2.1: Fix `+` quantifier application to escape sequences (some charset)
print "--- REQUIREMENT 2.1: + quantifier (some charset) ---"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "123" "\d+" true "\\d+ matches one or more digits" "Req 2.1"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "" "\d+" false "\\d+ rejects empty string" "Req 2.1"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "abc" "\w+" true "\\w+ matches one or more word chars" "Req 2.1"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "   " "\s+" true "\\s+ matches one or more whitespace" "Req 2.1"

;; REQUIREMENT 2.2: Fix `*` quantifier application to escape sequences (any charset)
print "^/--- REQUIREMENT 2.2: * quantifier (any charset) ---"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "123" "\d*" true "\\d* matches zero or more digits" "Req 2.2"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "" "\d*" true "\\d* matches empty string" "Req 2.2"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "abc" "\w*" true "\\w* matches zero or more word chars" "Req 2.2"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "   " "\s*" true "\\s* matches zero or more whitespace" "Req 2.2"

;; REQUIREMENT 2.3: Fix `?` quantifier application to escape sequences (opt charset)
print "^/--- REQUIREMENT 2.3: ? quantifier (opt charset) ---"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "1" "\d?" true "\\d? matches zero or one digit" "Req 2.3"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "" "\d?" true "\\d? matches empty string" "Req 2.3"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "a" "\w?" true "\\w? matches zero or one word char" "Req 2.3"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier " " "\s?" true "\\s? matches zero or one whitespace" "Req 2.3"

;; REQUIREMENT 2.4: Fix `{n}` exact count quantifier for escape sequences
print "^/--- REQUIREMENT 2.4: {n} exact count quantifier ---"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "123" "\d{3}" true "\\d{3} matches exactly 3 digits" "Req 2.4"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "12" "\d{3}" false "\\d{3} rejects 2 digits" "Req 2.4"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "abc" "\w{3}" true "\\w{3} matches exactly 3 word chars" "Req 2.4"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "   " "\s{3}" true "\\s{3} matches exactly 3 whitespace" "Req 2.4"

;; REQUIREMENT 2.5: Fix `{n,m}` range quantifier for escape sequences
print "^/--- REQUIREMENT 2.5: {n,m} range quantifier ---"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "123" "\d{2,4}" true "\\d{2,4} matches 3 digits (in range)" "Req 2.5"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "1" "\d{2,4}" false "\\d{2,4} rejects 1 digit (below range)" "Req 2.5"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "12345" "\d{2,4}" false "\\d{2,4} rejects 5 digits (above range)" "Req 2.5"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "abc" "\w{2,4}" true "\\w{2,4} matches 3 word chars (in range)" "Req 2.5"

;; Additional comprehensive tests
print "^/--- COMPREHENSIVE QUANTIFIER TESTS ---"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "a1b2c3" "\w+" true "Mixed word characters with +" "Comprehensive"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "hello world" "\w+\s+\w+" true "Word chars + whitespace + word chars" "Comprehensive"
set [test-count pass-count fail-count all-tests-passed?] test-quantifier "123-456-7890" "\d{3}-\d{3}-\d{4}" true "Phone number pattern" "Comprehensive"

;; Test parse rule generation
print "^/--- PARSE RULE GENERATION VERIFICATION ---"
print ["\\d+ generates rules:" mold TranslateRegExp "\d+"]
print ["\\d* generates rules:" mold TranslateRegExp "\d*"]
print ["\\d? generates rules:" mold TranslateRegExp "\d?"]
print ["\\d{3} generates rules:" mold TranslateRegExp "\d{3}"]
print ["\\d{2,5} generates rules:" mold TranslateRegExp "\d{2,5}"]

;; Final summary
print "^/--- TASK 2 COMPLETION SUMMARY ---"
print ""
print "=========================================="
print "           TEST SUMMARY"
print "=========================================="
print ["Total Tests: " test-count]
print ["Passed:      " pass-count]
print ["Failed:      " fail-count]
either test-count > 0 [
    success-rate: round/to (pass-count * 100.0) / test-count 0.1
    print ["Success Rate:" success-rate "%"]
] [
    print "Success Rate: N/A (no tests run)"
]
prin lf
either all-tests-passed? [
    print "✅ ALL TESTS PASSED!"
] [
    print "❌ SOME TESTS FAILED"
]
print "=========================================="

either all-tests-passed? [
    print "^/✅ TASK 2 SUCCESSFULLY COMPLETED!"
    print "All quantifier handling requirements have been implemented:"
    print "  ✓ + quantifier (some charset) working correctly"
    print "  ✓ * quantifier (any charset) working correctly"
    print "  ✓ ? quantifier (opt charset) working correctly"
    print "  ✓ {n} exact count quantifier working correctly"
    print "  ✓ {n,m} range quantifier working correctly"
] [
    print "^/❌ TASK 2 INCOMPLETE - Some tests failed"
]
