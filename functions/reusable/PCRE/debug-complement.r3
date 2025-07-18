REBOL [
    Title: "Debug Complement Function"
    Date: 17-Jul-2025
    File: %debug-complement.r3
    Author: "Kiro AI Assistant"
]

;; Load the RegExp engine
do %regexp-engine.r3

print "^/=== DEBUGGING COMPLEMENT FUNCTION ==="

;; Test MakeCharSet function directly
print "^/--- Testing MakeCharSet function ---"
digit-charset: MakeCharSet "0-9"
print ["Digit charset: " mold digit-charset]

word-charset: MakeCharSet "0-9A-Za-z_"
print ["Word charset: " mold word-charset]

;; Test complement function directly
print "^/--- Testing complement function ---"
non-digit-charset: complement digit-charset
print ["Non-digit charset: " mold non-digit-charset]

non-word-charset: complement word-charset
print ["Non-word charset: " mold non-word-charset]

;; Test if complement is working correctly
print "^/--- Testing complement behavior ---"
print ["Does digit charset match '5'?: " find digit-charset #"5"]
print ["Does non-digit charset match '5'?: " find non-digit-charset #"5"]
print ["Does non-digit charset match 'a'?: " find non-digit-charset #"a"]

print ["Does word charset match 'a'?: " find word-charset #"a"]
print ["Does non-word charset match 'a'?: " find non-word-charset #"a"]
print ["Does non-word charset match '!'?: " find non-word-charset #"!"]

;; Test parse behavior directly
print "^/--- Testing parse behavior with charsets ---"
print ["Parse '5' with digit charset: " parse "5" [digit-charset]]
print ["Parse '5' with non-digit charset: " parse "5" [non-digit-charset]]
print ["Parse 'a' with non-digit charset: " parse "a" [non-digit-charset]]

print ["Parse 'a' with word charset: " parse "a" [word-charset]]
print ["Parse 'a' with non-word charset: " parse "a" [non-word-charset]]
print ["Parse '!' with non-word charset: " parse "!" [non-word-charset]]
