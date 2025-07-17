REBOL [
    Title: "Task 4 Verification - RegExp Return Value Semantics"
    Date: 17-Jul-2025
    Version: 0.1.0
    File: %verify-task4.r3
]

do %regexp-engine.r3

;;=============================================================================
;; TASK 4 VERIFICATION TESTS
;;=============================================================================
;; Testing proper return value semantics for RegExp function:
;; - Return matched string when pattern matches
;; - Return false when pattern is valid but doesn't match input
;; - Return none when there's a parsing error or invalid pattern

print "^/*** TASK 4 VERIFICATION: RegExp Return Value Semantics ***"

;; Test tracking variables
task4-test-count: 0
task4-pass-count: 0
task4-fail-count: 0
task4-all-tests-passed: true

;; Helper function for testing return values - following coding standards
test-return-value: funct [
    "Test RegExp return value and type with proper state management"
    input [string!] "Input string"
    pattern [string!] "Regex pattern"
    expected-type [word!] "Expected return type: 'string, 'logic, or 'none"
    expected-value [any-type!] "Expected return value"
    description [string!] "Test description"
    current-test-count [integer!] "Current test count"
    current-pass-count [integer!] "Current pass count"
    current-fail-count [integer!] "Current fail count"
    current-all-tests-passed [logic!] "Current all tests passed status"
    return: [block!] "Updated [test-count pass-count fail-count all-tests-passed]"
] [
    updated-test-count: current-test-count + 1
    
    result: RegExp input pattern
    result-type: type? result
    
    ;; Check both type and value
    type-match: either expected-type = 'none [
        none? result
    ] [
        switch expected-type [
            'string [result-type = string!]
            'logic [result-type = logic!]
            'integer [result-type = integer!]
            'block [result-type = block!]
        ]
    ]
    
    value-match: either expected-type = 'none [
        none? result
    ] [
        equal? result expected-value
    ]
    
    either all [type-match value-match] [
        updated-pass-count: current-pass-count + 1
        updated-fail-count: current-fail-count
        updated-all-tests-passed: current-all-tests-passed
        print ["✅ PASS:" description]
        print ["   Result:" mold result "(" result-type ")"]
    ] [
        updated-pass-count: current-pass-count
        updated-fail-count: current-fail-count + 1
        updated-all-tests-passed: false
        print ["❌ FAIL:" description]
        print ["   Expected:" mold expected-value "(" expected-type ")"]
        print ["   Actual:  " mold result "(" result-type ")"]
    ]
    prin lf
    
    reduce [updated-test-count updated-pass-count updated-fail-count updated-all-tests-passed]
]

;;=============================================================================
;; TEST CASE 1: Return matched string when pattern matches
;;=============================================================================
print "--- Test Case 1: Return matched string when pattern matches ---"

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "hello" "hello" 'string "hello" 
        "Simple literal match should return matched string"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "123" "\d+" 'string "123"
        "Digit pattern match should return matched string"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "abc123def" "\d+" 'logic false
        "Partial match should return false (current implementation matches entire string)"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "hello world" "hello.*" 'string "hello world"
        "Wildcard pattern match should return matched string"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

;;=============================================================================
;; TEST CASE 2: Return false when pattern is valid but doesn't match
;;=============================================================================
print "--- Test Case 2: Return false when pattern is valid but doesn't match ---"

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "hello" "world" 'logic false
        "Non-matching literal should return false"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "abc" "\d+" 'logic false
        "Non-matching digit pattern should return false"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "hello" "^world" 'logic false
        "Non-matching anchor pattern should return false"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "123" "[a-z]+" 'logic false
        "Non-matching character class should return false"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

;;=============================================================================
;; TEST CASE 3: Return none when there's a parsing error or invalid pattern
;;=============================================================================
print "--- Test Case 3: Return none when there's a parsing error or invalid pattern ---"

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "hello" "[a-" 'none none
        "Unclosed character class should return none"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "hello" "a{2,1}" 'none none
        "Invalid quantifier range should return none"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "hello" "a{abc}" 'none none
        "Invalid quantifier specification should return none"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "hello" "\q" 'none none
        "Invalid escape sequence should return none (graceful degradation)"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

;;=============================================================================
;; TEST CASE 4: Edge cases and boundary conditions
;;=============================================================================
print "--- Test Case 4: Edge cases and boundary conditions ---"

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "" "" 'string ""
        "Empty pattern with empty string should return empty string"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "test" "" 'logic false
        "Empty pattern with non-empty string should return false"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

set [task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed]
    test-return-value "" "a" 'logic false
        "Non-empty pattern with empty string should return false"
        task4-test-count task4-pass-count task4-fail-count task4-all-tests-passed

;;=============================================================================
;; PRINT TEST SUMMARY
;;=============================================================================
print "^/=========================================="
print "         TASK 4 TEST SUMMARY"
print "=========================================="
print ["Total Tests:  " task4-test-count]
print ["Passed:       " task4-pass-count]
print ["Failed:       " task4-fail-count]

either task4-test-count > 0 [
    success-rate: round/to (task4-pass-count * 100.0) / task4-test-count 0.1
    print ["Success Rate: " success-rate "%"]
] [
    print "Success Rate: N/A (no tests run)"
]

prin lf
either task4-all-tests-passed [
    print "✅ ALL TESTS PASSED! Task 4 implementation is correct."
] [
    print "❌ SOME TESTS FAILED - Task 4 needs fixes."
]
print "=========================================="

;; Return overall success status
task4-all-tests-passed
