REBOL [
    Title: "QA Test - Block-based RegExp Matcher Comprehensive"
    Date: 20-Jul-2025
    Version: 2.0.0
    Author: "AI Assistant"
    Purpose: "Comprehensive quality assurance testing for block regexp matcher"
    Type: "QA Test"
]

;; Load the matcher module
do %src/block-regexp-matcher.r3

print "^/=== COMPREHENSIVE BLOCK REGEXP MATCHER QA TEST ==="

;; Test counters - ensure proper initialization
test-count: 0
pass-count: 0
fail-count: 0

;; Verify initialization
print ["Initial test-count:" test-count]
print ["Initial pass-count:" pass-count]
print ["Initial fail-count:" fail-count]

;; Helper function for test assertions
assert-equal: funct [
    expected [any-type!] "Expected result"
    actual [any-type!] "Actual result"
    description [string!] "Test description"
    current-test-count [integer!] "Current test count"
    current-pass-count [integer!] "Current pass count"
    current-fail-count [integer!] "Current fail count"
    return: [block!] "Updated [test-count pass-count fail-count]"
] [
    ;; Increment test count
    current-test-count: current-test-count + 1
    
    either expected = actual [
        current-pass-count: current-pass-count + 1
        print ["  PASS:" description]
    ] [
        current-fail-count: current-fail-count + 1
        print ["  FAIL:" description]
        print ["    Expected:" mold expected]
        print ["    Actual:  " mold actual]
    ]
    
    ;; Return updated counters
    reduce [current-test-count current-pass-count current-fail-count]
]

;; Test 1: Basic literal matching
print "^/--- Test 1: Basic Literal Matching ---"
set [test-count pass-count fail-count] 
    assert-equal "hello" ExecuteBlockMatch "hello world" [#"h" #"e" #"l" #"l" #"o"] "Simple literal match" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal "test" ExecuteBlockMatch "testing" [#"t" #"e" #"s" #"t"] "Literal match at start" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal "ing" ExecuteBlockMatch "testing" [#"i" #"n" #"g"] "Literal match in middle" test-count pass-count fail-count

;; Test 2: Character class matching
print "^/--- Test 2: Character Class Matching ---"
set [test-count pass-count fail-count] 
    assert-equal "123" ExecuteBlockMatch "123abc" [digit-charset digit-charset digit-charset] "Three digits" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal "ab" ExecuteBlockMatch "abc123" [word-charset word-charset] "Two word chars" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal " " ExecuteBlockMatch "hello world" [space-charset] "Single space" test-count pass-count fail-count

;; Test 3: Quantifier matching
print "^/--- Test 3: Quantifier Matching ---"
set [test-count pass-count fail-count] 
    assert-equal "123" ExecuteBlockMatch "123abc" [some digit-charset] "Some digits" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal "" ExecuteBlockMatch "abc123" [any digit-charset] "Any digits (zero match)" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal "a" ExecuteBlockMatch "abc" [opt word-charset] "Optional word char" test-count pass-count fail-count

;; Test 4: Anchor matching
print "^/--- Test 4: Anchor Matching ---"
set [test-count pass-count fail-count] 
    assert-equal "hello" ExecuteBlockMatch "hello world" ['start #"h" #"e" #"l" #"l" #"o"] "Start anchor match" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal none ExecuteBlockMatch "say hello" ['start #"h" #"e" #"l" #"l" #"o"] "Start anchor no match" test-count pass-count fail-count

;; Test 5: Mixed patterns
print "^/--- Test 5: Mixed Patterns ---"
set [test-count pass-count fail-count] 
    assert-equal "h123" ExecuteBlockMatch "h123abc" [#"h" some digit-charset] "Literal + quantifier" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal "a1b" ExecuteBlockMatch "a1b2c" [word-charset digit-charset word-charset] "Mixed char classes" test-count pass-count fail-count

;; Test 6: Edge cases
print "^/--- Test 6: Edge Cases ---"
set [test-count pass-count fail-count] 
    assert-equal "" ExecuteBlockMatch "" [] "Empty string, empty rules" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal none ExecuteBlockMatch "test" [] "Non-empty string, empty rules" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal none ExecuteBlockMatch "" [#"a"] "Empty string, non-empty rules" test-count pass-count fail-count

;; Test 7: Error handling
print "^/--- Test 7: Error Handling ---"
set [test-count pass-count fail-count] 
    assert-equal none ExecuteBlockMatch "test" ['error "Test error"] "Error rules" test-count pass-count fail-count

;; Test 8: Complex character sets
print "^/--- Test 8: Complex Character Sets ---"
set [test-count pass-count fail-count] 
    assert-equal "ABC" ExecuteBlockMatch "ABC123" [non-digit-charset non-digit-charset non-digit-charset] "Non-digits" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal "___" ExecuteBlockMatch "___123" [non-space-charset non-space-charset non-space-charset] "Non-spaces" test-count pass-count fail-count

;; Test 9: Quantifier edge cases
print "^/--- Test 9: Quantifier Edge Cases ---"
set [test-count pass-count fail-count] 
    assert-equal "aaa" ExecuteBlockMatch "aaabbb" [some #"a"] "Some specific char" test-count pass-count fail-count
set [test-count pass-count fail-count] 
    assert-equal "" ExecuteBlockMatch "bbbccc" [any #"a"] "Any specific char (no match)" test-count pass-count fail-count

;; Test 10: Performance with longer strings
print "^/--- Test 10: Performance Test ---"
long-string: ""
repeat i 1000 [append long-string "a"]
append long-string "target"
append long-string "suffix"
set [test-count pass-count fail-count] 
    assert-equal "target" ExecuteBlockMatch long-string [#"t" #"a" #"r" #"g" #"e" #"t"] "Long string performance" test-count pass-count fail-count

;; Print test summary
print "^/=== TEST SUMMARY ==="
print ["Total Tests:" test-count]
print ["Passed:" pass-count]
print ["Failed:" fail-count]
success-rate: either test-count > 0 [
    to integer! (pass-count * 100) / test-count
] [0]
print ["Success Rate:" success-rate "%"]

either fail-count = 0 [
    print "^/🎉 ALL TESTS PASSED! Block RegExp Matcher is working correctly."
] [
    print "^/❌ Some tests failed. Review the failures above."
]

print "^/=== COMPREHENSIVE QA TEST COMPLETE ==="
