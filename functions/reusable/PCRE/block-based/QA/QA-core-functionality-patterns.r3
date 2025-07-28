REBOL [
    Title: "Diagnose Core Functionality Failures"
    Date: 27-Jul-2025
    Version: 1.0.0
    Author: "AI Assistant"
    Purpose: "Identify the 2 failing core functionality tests"
    Type: "Diagnostic Script"
]

;; Load the engine
do %../src/block-regexp-engine.r3

print "=== CORE FUNCTIONALITY FAILURES DIAGNOSIS ==="

;; Test the core functionality patterns from the test
core-tests: [
    "hello" "hello" "hello" "Basic literal match"
    "hello" "world" false "Basic literal non-match"
    "123" "\d" "1" "Single digit match"
    "abc" "\d" false "Non-digit rejection"
    "123456" "\d+" "123456" "Multiple digits"
    "hello123" "\w+" "hello123" "Word character match"
    "hello world" "\s" " " "Space character match"
    "hello" "^hello" "hello" "Start anchor"
    "hello" "hello$" "hello" "End anchor"
    "abc" "[abc]" "a" "Character class"
    "123" "[^0-9]" false "Negated character class"
]

foreach [haystack pattern expected description] core-tests [
    test-result: RegExp haystack pattern
    
    either equal? expected test-result [
        print ["✅ PASS:" description]
    ] [
        print ["❌ FAIL:" description]
        print ["  Expected:" mold expected]
        print ["  Actual:" mold test-result]
        print ["  Haystack:" mold haystack]
        print ["  Pattern:" mold pattern]
    ]
]
