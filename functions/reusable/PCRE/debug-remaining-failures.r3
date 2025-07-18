REBOL [
    Title: "Debug Remaining Failures"
    Date: 17-Jul-2025
    File: %debug-remaining-failures.r3
    Author: "Kiro AI Assistant"
]

;; Load the RegExp engine
do %regexp-engine.r3

print "^/=== DEBUGGING REMAINING FAILURES ==="

;; Test the specific failing patterns
failing-patterns: [
    "abc123" "\w+\d+" "letters followed by digits"
    "test123 data" "\w+\d+\s\w+" "complex word pattern"
    "hello!world" "\S+\W\S+" "non-space, non-word, non-space"
    "hello 123" "\D+\s\d+" "nondigits-space-digits"
    "a1 b2 c3 d4" "(\w\d\s){3}\w\d" "complex repeating pattern"
]

foreach [test-string pattern description] failing-patterns [
    print ["^/--- Testing:" description "---"]
    print ["String: " mold test-string]
    print ["Pattern: " mold pattern]
    
    ;; Check translation
    translated: TranslateRegExp pattern
    print ["Translated: " mold translated]
    
    ;; Test result
    result: RegExp test-string pattern
    print ["Result: " mold result]
    
    ;; Test if it's a partial match issue
    if translated [
        parse-result: parse test-string translated
        print ["Direct parse result: " parse-result]
    ]
]
