REBOL [
    Title: "QA Test - String-to-Block Tokenizer Module"
    Date: 20-Jul-2025
    File: %qa-test-string-to-block-tokenizer.r3
    Author: "Kiro AI Assistant"
    Purpose: "Robust testing of string-to-block tokenizer functionality"
    Type: "QA Test Script"
    Note: "Tests tokenization accuracy, edge cases and semantic correctness"
]

;;=============================================================================
;; LOAD DEPENDENCIES
;;=============================================================================
do %src/string-to-block-tokenizer.r3

;;=============================================================================
;; TEST UTILITIES
;;=============================================================================
test-count: 0
pass-count: 0
fail-count: 0
all-tests-passed: true

assert-equal: funct [
    "Assert that expected equals actual with detailed reporting"
    expected [any-type!] "Expected value"
    actual [any-type!] "Actual value"
    description [string!] "Test description"
    current-test-count [integer!] "Current test count"
    current-pass-count [integer!] "Current pass count"
    current-fail-count [integer!] "Current fail count"
    current-all-passed [logic!] "Current all passed status"
    return: [block!] "Updated [test-count pass-count fail-count all-passed]"
] [
    current-test-count: current-test-count + 1
    
    either equal? expected actual [
        current-pass-count: current-pass-count + 1
        print ["  PASS:" description]
    ] [
        current-fail-count: current-fail-count + 1
        current-all-passed: false
        print ["  FAIL:" description]
        print ["    Expected:" mold expected]
        print ["    Actual:  " mold actual]
    ]
    
    reduce [current-test-count current-pass-count current-fail-count current-all-passed]
]

;;=============================================================================
;; BASIC TOKENIZATION TESTS
;;=============================================================================
print "^/=========================================="
print "STRING-TO-BLOCK TOKENIZER - COMPREHENSIVE QA TESTS"
print "=========================================="
print "^/--- Basic Anchor Tests ---"

;; Test anchor-start tokenization
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [anchor-start] StringToPatternBlock "^^" "anchor-start token" test-count pass-count fail-count all-tests-passed

;; Test anchor-end tokenization  
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [anchor-end] StringToPatternBlock "$" "anchor-end token" test-count pass-count fail-count all-tests-passed

;; Test combined anchors
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [anchor-start anchor-end] StringToPatternBlock "^^$" "combined anchors" test-count pass-count fail-count all-tests-passed

print "^/--- Character Class Tests ---"

;; Test digit class
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [digit-class] StringToPatternBlock "\d" "digit class token" test-count pass-count fail-count all-tests-passed

;; Test non-digit class
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [non-digit-class] StringToPatternBlock "\D" "non-digit class token" test-count pass-count fail-count all-tests-passed

;; Test word class
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [word-class] StringToPatternBlock "\w" "word class token" test-count pass-count fail-count all-tests-passed

;; Test non-word class
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [non-word-class] StringToPatternBlock "\W" "non-word class token" test-count pass-count fail-count all-tests-passed

;; Test space class
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [space-class] StringToPatternBlock "\s" "space class token" test-count pass-count fail-count all-tests-passed

;; Test non-space class
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [non-space-class] StringToPatternBlock "\S" "non-space class token" test-count pass-count fail-count all-tests-passed

print "^/--- Quantifier Tests ---"

;; Test plus quantifier
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [quantifier-plus] StringToPatternBlock "+" "plus quantifier token" test-count pass-count fail-count all-tests-passed

;; Test star quantifier
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [quantifier-star] StringToPatternBlock "*" "star quantifier token" test-count pass-count fail-count all-tests-passed

;; Test optional quantifier
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [quantifier-optional] StringToPatternBlock "?" "optional quantifier token" test-count pass-count fail-count all-tests-passed

;; Test exact quantifier
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[quantifier-exact 3]] StringToPatternBlock "{3}" "exact quantifier token" test-count pass-count fail-count all-tests-passed

;; Test range quantifier
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[quantifier-range 2 5]] StringToPatternBlock "{2,5}" "range quantifier token" test-count pass-count fail-count all-tests-passed

print "^/--- Custom Character Class Tests ---"

;; Test normal custom class
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[custom-class normal "a-z"]] StringToPatternBlock "[a-z]" "normal custom class" test-count pass-count fail-count all-tests-passed

;; Test negated custom class
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[custom-class negated "0-9"]] StringToPatternBlock "[^^0-9]" "negated custom class" test-count pass-count fail-count all-tests-passed

print "^/--- Literal and Wildcard Tests ---"

;; Test wildcard
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [wildcard] StringToPatternBlock "." "wildcard token" test-count pass-count fail-count all-tests-passed

;; Test literal characters
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[literal #"h"] [literal #"e"] [literal #"l"] [literal #"l"] [literal #"o"]] StringToPatternBlock "hello" "literal characters" test-count pass-count fail-count all-tests-passed

print "^/--- Escape Sequence Tests ---"

;; Test escaped literal
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[escaped-char #"."]] StringToPatternBlock "\." "escaped dot" test-count pass-count fail-count all-tests-passed

;; Test escaped newline
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[escaped-char #"^/"]] StringToPatternBlock "\n" "escaped newline" test-count pass-count fail-count all-tests-passed

;; Test escaped tab
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[escaped-char #"^-"]] StringToPatternBlock "\t" "escaped tab" test-count pass-count fail-count all-tests-passed

print "^/--- Group and Alternation Tests ---"

;; Test group open
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[group open]] StringToPatternBlock "(" "group open token" test-count pass-count fail-count all-tests-passed

;; Test group close
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[group close]] StringToPatternBlock ")" "group close token" test-count pass-count fail-count all-tests-passed

;; Test alternation
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [alternation] StringToPatternBlock "|" "alternation token" test-count pass-count fail-count all-tests-passed

print "^/--- Complex Pattern Tests ---"

;; Test anchor with digit class and quantifier
expected-tokens: [anchor-start digit-class quantifier-plus]
set [test-count pass-count fail-count all-tests-passed]
    assert-equal expected-tokens StringToPatternBlock "^^\d+" "anchor + digit + plus" test-count pass-count fail-count all-tests-passed

;; Test word class with exact quantifier
expected-tokens: [word-class [quantifier-exact 3]]
set [test-count pass-count fail-count all-tests-passed]
    assert-equal expected-tokens StringToPatternBlock "\w{3}" "word class + exact quantifier" test-count pass-count fail-count all-tests-passed

;; Test complex pattern with groups
expected-tokens: [[group open] [literal #"a"] [literal #"b"] [group close] quantifier-star]
set [test-count pass-count fail-count all-tests-passed]
    assert-equal expected-tokens StringToPatternBlock "(ab)*" "grouped pattern with star" test-count pass-count fail-count all-tests-passed

;; Test alternation with character classes
expected-tokens: [digit-class alternation word-class]
set [test-count pass-count fail-count all-tests-passed]
    assert-equal expected-tokens StringToPatternBlock "\d|\w" "digit or word alternation" test-count pass-count fail-count all-tests-passed

;; Test negated character class with quantifier
expected-tokens: [[custom-class negated "a-z"] quantifier-plus]
set [test-count pass-count fail-count all-tests-passed]
    assert-equal expected-tokens StringToPatternBlock "[^^a-z]+" "negated class + plus" test-count pass-count fail-count all-tests-passed

print "^/--- Edge Case Tests ---"

;; Test empty pattern
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [] StringToPatternBlock "" "empty pattern" test-count pass-count fail-count all-tests-passed

;; Test single character
set [test-count pass-count fail-count all-tests-passed]
    assert-equal [[literal #"x"]] StringToPatternBlock "x" "single character" test-count pass-count fail-count all-tests-passed

;; Test anchor context sensitivity (^ not at start should be literal)
expected-tokens: [[literal #"a"] [literal #"^^"] [literal #"b"]]
set [test-count pass-count fail-count all-tests-passed]
    assert-equal expected-tokens StringToPatternBlock "a^^b" "caret not at start" test-count pass-count fail-count all-tests-passed

;; Test anchor context sensitivity ($ not at end should be literal)
expected-tokens: [[literal #"a"] [literal #"$"] [literal #"b"]]
set [test-count pass-count fail-count all-tests-passed]
    assert-equal expected-tokens StringToPatternBlock "a$b" "dollar not at end" test-count pass-count fail-count all-tests-passed

print "^/--- Error Handling Tests ---"

;; Test invalid quantifier range
result: StringToPatternBlock "{5,2}"  ;; Invalid: min > max
set [test-count pass-count fail-count all-tests-passed]
    assert-equal 'error result/1 "invalid quantifier range error" test-count pass-count fail-count all-tests-passed

;; Test unclosed character class
result: StringToPatternBlock "[a-z"  ;; Missing closing bracket
set [test-count pass-count fail-count all-tests-passed]
    assert-equal 'error result/1 "unclosed character class error" test-count pass-count fail-count all-tests-passed

;; Test unclosed quantifier range
result: StringToPatternBlock "{3"  ;; Missing closing brace
set [test-count pass-count fail-count all-tests-passed]
    assert-equal 'error result/1 "unclosed quantifier range error" test-count pass-count fail-count all-tests-passed

print "^/--- Performance and Stress Tests ---"

;; Test long literal string
long-pattern: ""
repeat i 50 [append long-pattern "a"]
result: StringToPatternBlock long-pattern
set [test-count pass-count fail-count all-tests-passed]
    assert-equal 50 length? result "long literal pattern length" test-count pass-count fail-count all-tests-passed

;; Test complex nested pattern
complex-pattern: "^^(\d{2,4}[a-zA-Z]+\s*)+$"
result: StringToPatternBlock complex-pattern
set [test-count pass-count fail-count all-tests-passed]
    assert-equal logic! type? ((length? result) > 10) "complex pattern tokenization" test-count pass-count fail-count all-tests-passed

;;=============================================================================
;; UTILITY FUNCTION TESTS
;;=============================================================================
print "^/--- Utility Function Tests ---"

;; Test TokensToString function
tokens: [anchor-start digit-class quantifier-plus anchor-end]
reconstructed: TokensToString tokens
set [test-count pass-count fail-count all-tests-passed]
    assert-equal "^^\d+$" reconstructed "tokens to string conversion" test-count pass-count fail-count all-tests-passed

;; Test PreprocessMetaCharacters function
preprocessed: PreprocessMetaCharacters "^^\d+$"
set [test-count pass-count fail-count all-tests-passed]
    assert-equal "^^\d+$" preprocessed "meta-character preprocessing" test-count pass-count fail-count all-tests-passed

;;=============================================================================
;; TEST SUMMARY
;;=============================================================================
print "^/=========================================="
print "STRING-TO-BLOCK TOKENIZER - TEST SUMMARY"
print "=========================================="

print ["Total Tests Executed:" test-count]
print ["Tests Passed:" pass-count]
print ["Tests Failed:" fail-count]

if test-count > 0 [
    success-rate: to integer! (pass-count * 100) / test-count
    print ["Overall Success Rate:" success-rate "%"]
    
    reliability-score: either success-rate >= 95 ["EXCELLENT"] [
        either success-rate >= 90 ["VERY GOOD"] [
            either success-rate >= 80 ["GOOD"] ["NEEDS IMPROVEMENT"]
        ]
    ]
    print ["Test Reliability:" reliability-score]
]

print ["All Tests Passed:" either all-tests-passed ["YES"] ["NO"]]

either all-tests-passed [
    print "^/✅ STRING-TO-BLOCK TOKENIZER MODULE VALIDATION COMPLETE"
    print "All tokenization functionality working correctly!"
] [
    print "^/❌ TOKENIZER ISSUES DETECTED"
    print "Review failed tests and fix implementation issues."
]

print "^/=========================================="
