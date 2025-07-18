REBOL [
    Title: "Debug Test Final Replacement"
    Date: 17-Jul-2025
    File: %debug-test-final-replacement.r3
    Author: "Kiro AI Assistant"
]

;; Load the RegExp engine
do %regexp-engine.r3

print "^/=== DEBUGGING TEST FINAL REPLACEMENT ==="

;; Test the current RegExp function behavior
test-cases: [
    "hello" "hello" "exact match"
    "hello world" "hello" "partial match at start"
    "hello world" "world" "partial match at end"
    "hello world" "hello.*world" "wildcard pattern"
    "hello world" "h.llo" "dot in middle"
    "123abc" "\d+" "digits at start"
    "abc123" "\D+" "non-digits at start"
]

foreach [test-string pattern description] test-cases [
    print ["^/--- Testing:" description "---"]
    print ["String: " mold test-string]
    print ["Pattern: " mold pattern]
    
    ;; Test RegExp result
    result: RegExp test-string pattern
    print ["RegExp result: " mold result]
    
    ;; Test TestRegExp result
    test-result: TestRegExp test-string pattern
    print ["TestRegExp result: " mold test-result]
    
    ;; Check translation
    translated: TranslateRegExp pattern
    print ["Translated: " mold translated]
    
    ;; Test the exact parse logic used in RegExp
    if translated [
        parse-test: none
        set/any 'parse-test try [
            parse test-string compose [copy matched (translated) to end]
        ]
        print ["Direct parse test: " mold parse-test]
        if parse-test [
            print ["  Matched portion: " mold matched]
        ]
    ]
]

;; Test the specific failing wildcard case in detail
print "^/=== DETAILED WILDCARD ANALYSIS ==="
wildcard-string: "hello world"
wildcard-pattern: "hello.*world"

print ["String: " mold wildcard-string]
print ["Pattern: " mold wildcard-pattern]

wildcard-translated: TranslateRegExp wildcard-pattern
print ["Translated: " mold wildcard-translated]

if wildcard-translated [
    ;; Test the exact parse rule
    parse-result: none
    set/any 'parse-result try [
        parse wildcard-string compose [copy matched (wildcard-translated) to end]
    ]
    print ["Parse result: " mold parse-result]
    if parse-result [
        print ["Matched: " mold matched]
    ]
    
    ;; Test without the 'to end' part
    parse-result2: none
    set/any 'parse-result2 try [
        parse wildcard-string wildcard-translated
    ]
    print ["Parse without 'to end': " mold parse-result2]
]
