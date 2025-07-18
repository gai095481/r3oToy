REBOL [
    Title: "Debug Dot Pattern"
    Date: 17-Jul-2025
    File: %debug-dot-pattern.r3
    Author: "Kiro AI Assistant"
]

;; Load the RegExp engine
do %regexp-engine.r3

print "^/=== DEBUGGING DOT PATTERN ==="

;; Test different dot patterns
dot-tests: [
    "." "single dot"
    ".*" "dot star"
    ".+" "dot plus"
    "h.llo" "dot in middle"
    "hello.*world" "dot star between words"
]

foreach [pattern description] dot-tests [
    print ["^/--- Testing:" description "---"]
    print ["Pattern: " mold pattern]
    
    ;; Check translation
    translated: TranslateRegExp pattern
    print ["Translated: " mold translated]
    
    ;; Test with various strings
    test-strings: ["a" "hello" "hello world" "hello\nworld"]
    foreach test-string test-strings [
        result: RegExp test-string pattern
        print ["  '" test-string "' -> " mold result]
    ]
]

;; Let's specifically debug the failing wildcard case
print "^/--- Debugging Specific Wildcard Case ---"
wildcard-pattern: "hello.*world"
test-string: "hello world"

print ["Pattern: " mold wildcard-pattern]
print ["String: " mold test-string]

translated: TranslateRegExp wildcard-pattern
print ["Translated: " mold translated]

;; Let's manually test what the translation should be
print "^/--- Manual Translation Test ---"
expected-translation: reduce [
    #"h" #"e" #"l" #"l" #"o"
    'any complement charset "^/"
    #"w" #"o" #"r" #"l" #"d"
]
print ["Expected translation: " mold expected-translation]

;; Test the expected translation
manual-result: parse test-string expected-translation
print ["Manual parse result: " manual-result]

;; Let's also test what complement charset "^/" actually contains
newline-complement: complement charset "^/"
print ["Newline complement charset: " mold newline-complement]
print ["Does it match space?: " find newline-complement #" "]
print ["Does it match 'a'?: " find newline-complement #"a"]
print ["Does it match newline?: " find newline-complement #"^/"]
