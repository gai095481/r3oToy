REBOL [
    Title: "Debug Block Engine Anchor Issue"
    Date: 27-Jul-2025
    Version: 1.0.0
    Author: "AI Assistant"
    Purpose: "Debug start anchor functionality in block-based engine"
    Type: "Diagnostic Script"
]

print "=== DEBUGGING BLOCK ENGINE ANCHOR ISSUE ==="

;; Load the block-based engine
do %../src/block-regexp-engine.r3

print "^/--- Testing Start Anchor Step by Step ---"

test-string: "hello world"
test-pattern: "^hello"

print ["Test string:" mold test-string]
print ["Test pattern:" mold test-pattern]

;; Step 1: Test tokenization
print "^/Step 1: Tokenization"
tokens: StringToPatternBlock test-pattern
print ["Tokens:" mold tokens]

;; Step 2: Test rule processing
print "^/Step 2: Rule Processing"
rules: ProcessPatternBlock tokens
print ["Rules:" mold rules]

;; Step 3: Test matching
print "^/Step 3: Matching"
match-result: ExecuteBlockMatch test-string rules
print ["Match result:" mold match-result]

;; Step 4: Test full RegExp
print "^/Step 4: Full RegExp"
regexp-result: RegExp test-string test-pattern
print ["RegExp result:" mold regexp-result]

;; Compare with simple literal
print "^/--- Comparison with Simple Literal ---"
simple-result: RegExp test-string "hello"
print ["Simple 'hello' result:" mold simple-result]
