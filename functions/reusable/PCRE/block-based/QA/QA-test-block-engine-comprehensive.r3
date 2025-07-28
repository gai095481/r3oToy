REBOL [
    Title: "Test Block-based RegExp Engine with Robust QA Test Suite"
    Date: 27-Jul-2025
    Version: 1.0.0
    Author: "AI Assistant"
    Purpose: "Test block-based engine against robust test suite"
    Type: "QA Test Script"
]

print "=== TESTING BLOCK ENGINE WITH COMPREHENSIVE SUITE ==="

;; Load the block-based engine instead of the regular engine
print "Loading block-based RegExp engine..."
do %../src/block-regexp-engine.r3

;; Now run a subset of the comprehensive tests to validate
print "^/Running key tests from comprehensive suite..."

;;=============================================================================
;; SIMPLIFIED QA HARNESS
;;=============================================================================
test-count: 0
pass-count: 0
fail-count: 0

test-regexp: funct [
    "Test RegExp function and report result"
    haystack [string!] "String to test"
    pattern [string!] "Pattern to match"
    expected [any-type!] "Expected result"
    description [string!] "Test description"
] [
    set 'test-count test-count + 1
    
    actual: none
    set/any 'actual try [
        RegExp haystack pattern
    ]
    
    either error? actual [
        print ["❌ ERROR:" description]
        set 'fail-count fail-count + 1
    ] [
        either equal? expected actual [
            print ["✅ PASS:" description]
            set 'pass-count pass-count + 1
        ] [
            print ["❌ FAIL:" description]
            set 'fail-count fail-count + 1
        ]
    ]
]

;;=============================================================================
;; KEY TESTS FROM COMPREHENSIVE SUITE
;;=============================================================================
print "^/--- Escape Sequence Tests ---"
test-regexp "5" "\d" "5" "\d matches single digit"
test-regexp "a" "\d" none "\d rejects non-digit"
test-regexp "123" "\d+" "123" "\d+ matches multiple digits"
test-regexp "a" "\w" "a" "\w matches letter"
test-regexp "_" "\w" "_" "\w matches underscore"
test-regexp "5" "\w" "5" "\w matches digit"
test-regexp " " "\s" " " "\s matches space"
test-regexp "^-" "\s" "^-" "\s matches tab"

print "^/--- Negated Escape Sequences ---"
test-regexp "a" "\D" "a" "\D matches non-digit"
test-regexp "5" "\D" none "\D rejects digit"
test-regexp "!" "\W" "!" "\W matches non-word"
test-regexp "a" "\W" none "\W rejects word char"
test-regexp "x" "\S" "x" "\S matches non-space"
test-regexp " " "\S" none "\S rejects space"

print "^/--- Quantifier Tests ---"
test-regexp "aaa" "a+" "aaa" "Plus quantifier"
test-regexp "" "a*" "" "Star quantifier empty"
test-regexp "aaa" "a*" "aaa" "Star quantifier multiple"
test-regexp "a" "a?" "a" "Optional present"
test-regexp "" "a?" "" "Optional absent"
test-regexp "aaa" "a{3}" "aaa" "Exact quantifier"
test-regexp "aa" "a{2,4}" "aa" "Range quantifier min"
test-regexp "aaaa" "a{2,4}" "aaaa" "Range quantifier max"

print "^/--- Anchor Tests ---"
test-regexp "hello world" "^^hello" "hello" "Start anchor"
test-regexp "say hello" "^^hello" none "Start anchor fail"
test-regexp "hello world" "world$" "world" "End anchor"
test-regexp "world hello" "world$" none "End anchor fail"

print "^/--- Character Classes ---"
test-regexp "a" "[a-z]" "a" "Character class range"
test-regexp "5" "[0-9]" "5" "Digit character class"
test-regexp "a" "[^^0-9]" "a" "Negated character class"
test-regexp "5" "[^^0-9]" none "Negated class rejection"

print "^/--- Complex Patterns ---"
test-regexp "test@example.com" "\w+@\w+\.\w+" "test@example.com" "Email pattern"
test-regexp "abc 123" "\w+\s\d+" "abc 123" "Word space digit"

print "^/--- Error Handling ---"
test-regexp "test" "[a-" none "Invalid character class"
test-regexp "test" "a{" none "Invalid quantifier"

print "^/=== COMPREHENSIVE TEST RESULTS ==="
print ["Total Tests:" test-count]
print ["Passed:" pass-count]
print ["Failed:" fail-count]

success-rate: either test-count > 0 [
    to integer! (pass-count * 100) / test-count
] [0]

print ["Success Rate:" success-rate "%"]

either success-rate >= 95 [
    print "✅ SUCCESS RATE REQUIREMENT MET: 95%+ achieved"
    print "Block-based RegExp engine meets robust test requirements!"
] [
    print "❌ SUCCESS RATE BELOW TARGET"
]

print "^/=== ROBUST QA TEST COMPLETE ==="
