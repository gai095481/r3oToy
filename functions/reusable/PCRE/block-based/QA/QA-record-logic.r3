REBOL [
    Title: "Diagnose Test Record Logic"
    Date: 27-Jul-2025
    Version: 1.0.0
    Author: "AI Assistant"
    Purpose: "Debug the record-test function and error handling test logic"
    Type: "Diagnostic Script"
]

;; Load the engine
do %../src/block-regexp-engine.r3

;; Copy the record-test function from the test file
total-tests: 0
passed-tests: 0
failed-tests: 0
test-categories: make map! []

record-test: funct [
    "Record test result with category tracking"
    category [string!] "Test category"
    description [string!] "Test description"
    result [logic!] "Test result (true = pass, false = fail)"
    error-occurred [logic!] "Whether an error occurred"
] [
    set 'total-tests total-tests + 1
    
    ;; Initialize category if not exists
    if not select test-categories category [
        test-categories/:category: reduce [0 0 0 0]  ;; [total passed failed errors]
    ]
    
    category-stats: select test-categories category
    category-stats/1: category-stats/1 + 1  ;; Increment total
    
    either error-occurred [
        category-stats/4: category-stats/4 + 1  ;; Increment errors
        set 'failed-tests failed-tests + 1
        print ["❌ ERROR:" description]
    ] [
        either result [
            category-stats/2: category-stats/2 + 1  ;; Increment passed
            set 'passed-tests passed-tests + 1
            print ["✅ PASS:" description]
        ] [
            category-stats/3: category-stats/3 + 1  ;; Increment failed
            set 'failed-tests failed-tests + 1
            print ["❌ FAIL:" description]
        ]
    ]
]

print "=== TEST RECORD LOGIC DIAGNOSIS ==="

;; Test the exact error handling logic from the test
error-tests: reduce [
    "test" "[a-" none "Invalid character class"
    "test" "a{" none "Invalid quantifier"
    "test" "" none "Empty pattern"
    "test" "a{999999}" none "Excessive quantifier"
]

foreach [haystack pattern expected description] error-tests [
    print ["^/Testing:" description]
    print ["  Haystack:" mold haystack]
    print ["  Pattern:" mold pattern]
    print ["  Expected:" mold expected]
    
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    print ["  Actual result:" mold test-result]
    print ["  Error occurred?:" error? test-error]
    print ["  equal? expected test-result:" equal? expected test-result]
    
    either error? test-error [
        print "  -> Recording as ERROR (test-error occurred)"
        record-test "ERROR_HANDLING" description false true
    ] [
        comparison-result: (equal? expected test-result)
        print ["  -> Recording as comparison result:" comparison-result]
        record-test "ERROR_HANDLING" description comparison-result false
    ]
]

print "^/=== FINAL RESULTS ==="
print ["Total tests:" total-tests]
print ["Passed tests:" passed-tests]
print ["Failed tests:" failed-tests]
