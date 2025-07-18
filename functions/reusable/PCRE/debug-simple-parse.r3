REBOL [
    Title: "Debug Simple Parse Test"
    Date: 17-Jul-2025
    File: %debug-simple-parse.r3
    Author: "Kiro AI Assistant"
]

;; Load the RegExp engine
do %regexp-engine.r3

print "^/=== DEBUGGING SIMPLE PARSE BEHAVIOR ==="

;; Test basic digit matching
print "^/--- Testing basic digit patterns ---"
print ["Testing '5' against '\d': " mold RegExp "5" "\d"]
print ["Testing '123' against '\d+': " mold RegExp "123" "\d+"]
print ["Testing 'abc' against '\d': " mold RegExp "abc" "\d"]

;; Test word character matching
print "^/--- Testing word character patterns ---"
print ["Testing 'a' against '\w': " mold RegExp "a" "\w"]
print ["Testing 'abc' against '\w+': " mold RegExp "abc" "\w+"]

;; Test negated patterns
print "^/--- Testing negated patterns ---"
print ["Testing 'a' against '\D': " mold RegExp "a" "\D"]
print ["Testing 'abc' against '\D+': " mold RegExp "abc" "\D+"]

;; Test what the patterns actually translate to
print "^/--- Debugging pattern translation ---"
print ["TranslateRegExp '\d': " mold TranslateRegExp "\d"]
print ["TranslateRegExp '\D': " mold TranslateRegExp "\D"]
print ["TranslateRegExp '\w': " mold TranslateRegExp "\w"]
print ["TranslateRegExp '\W': " mold TranslateRegExp "\W"]
