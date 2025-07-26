REBOL [
    Title: "QA Test - Block-Based RegExp Engine Integration"
    Date: 20-Jul-2025
    File: %qa-test-block-engine-integration.r3
    Author: "Kiro AI Assistant"
    Version: "1.0.0"
    Purpose: "Test integration of block-based RegExp engine with existing test patterns"
    Type: "QA Test Script"
    Note: "Validates 95%+ success rate requirement and backward compatibility"
]

print "^/=== BLOCK-BASED REGEXP ENGINE INTEGRATION TEST ==="

;; Load the block-based engine
print "Loading block-based RegExp engine..."
do %src/block-regexp-engine.r3

print "^/Engine loaded. Testing integration..."

;;=============================================================================
;; SIMPLE QA HARNESS FOR INTEGRATION TESTING
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
        print ["❌ ERROR:" description "- Exception occurred:" mold actual]
        set 'fail-count fail-count + 1
    ] [
        either equal? expected actual [
            print ["✅ PASS:" description]
            set 'pass-count pass-count + 1
        ] [
            print ["❌ FAIL:" description]
            print ["   Expected:" mold expected]
            print ["   Actual:  " mold actual]
            set 'fail-count fail-count + 1
        ]
    ]
]

;;=============================================================================
;; CORE INTEGRATION TESTS
;;=============================================================================
print "^/--- Basic Functionality Tests ---"

;; Test basic literal matching
test-regexp "hello" "hello" "hello" "Basic literal match"
test-regexp "world" "hello" none "Basic literal non-match"

;; Test digit escape sequences
test-regexp "5" "\d" "5" "Single digit match with \d"
test-regexp "a" "\d" none "Non-digit rejection with \d"
test-regexp "123" "\d+" "123" "Multiple digits with \d+"

;; Test word escape sequences
test-regexp "a" "\w" "a" "Single word character with \w"
test-regexp "_" "\w" "_" "Underscore with \w"
test-regexp "!" "\w" none "Non-word character rejection with \w"

;; Test space escape sequences
test-regexp " " "\s" " " "Space character with \s"
test-regexp "^-" "\s" "^-" "Tab character with \s"
test-regexp "a" "\s" none "Non-space character rejection with \s"

print "^/--- Quantifier Tests ---"

;; Test quantifiers
test-regexp "aaa" "a+" "aaa" "Plus quantifier"
test-regexp "" "a*" "" "Star quantifier with empty string"
test-regexp "a" "a?" "a" "Optional quantifier present"
test-regexp "" "a?" "" "Optional quantifier absent"

;; Test exact quantifiers
test-regexp "aaa" "a{3}" "aaa" "Exact quantifier {3}"
test-regexp "aa" "a{3}" none "Exact quantifier {3} insufficient"

;; Test range quantifiers
test-regexp "aa" "a{2,4}" "aa" "Range quantifier {2,4} minimum"
test-regexp "aaaa" "a{2,4}" "aaaa" "Range quantifier {2,4} maximum"

print "^/--- Anchor Tests (Critical for Block-Based Engine) ---"

;; Test start anchor (this is the key improvement)
test-regexp "hello world" "^^hello" "hello" "Start anchor ^^hello"
test-regexp "say hello" "^^hello" none "Start anchor ^^hello non-match"

;; Test end anchor
test-regexp "hello world" "world$" "world" "End anchor world$"
test-regexp "world hello" "world$" none "End anchor world$ non-match"

print "^/--- Character Class Tests ---"

;; Test character classes
test-regexp "a" "[a-z]" "a" "Character class [a-z]"
test-regexp "A" "[a-z]" none "Character class [a-z] case sensitive"
test-regexp "5" "[0-9]" "5" "Character class [0-9]"

;; Test negated character classes
test-regexp "a" "[^^0-9]" "a" "Negated character class [^^0-9]"
test-regexp "5" "[^^0-9]" none "Negated character class [^^0-9] rejection"

print "^/--- Complex Pattern Tests ---"

;; Test complex patterns
test-regexp "abc 123" "\w+\s\d+" "abc 123" "Mixed word, space, and digit pattern"
test-regexp "test@example.com" "\w+@\w+\.\w+" "test@example.com" "Email-like pattern"

print "^/--- Error Handling Tests ---"

;; Test error conditions
test-regexp "test" "[a-" none "Invalid character class"
test-regexp "test" "a{" none "Invalid quantifier"
test-regexp "test" "" none "Empty pattern"

;;=============================================================================
;; RESULTS SUMMARY
;;=============================================================================
print "^/=== QA INTEGRATION TEST RESULTS ==="
print ["Total Tests:" test-count]
print ["Passed:" pass-count]
print ["Failed:" fail-count]

success-rate: either test-count > 0 [
    to integer! (pass-count * 100) / test-count
] [0]

print ["Success Rate:" success-rate "%"]

either success-rate >= 95 [
    print "✅ SUCCESS RATE REQUIREMENT MET: 95%+ achieved"
    print "Block-based RegExp engine integration successful!"
] [
    either success-rate >= 90 [
        print "⚠️  SUCCESS RATE CLOSE: 90-94% achieved"
        print "Minor improvements may be needed"
    ] [
        print "❌ SUCCESS RATE BELOW TARGET: <90% achieved"
        print "Significant improvements required"
    ]
]

print "^/=== QA INTEGRATION TEST COMPLETE ==="
