REBOL [
    Title: "QA Test - Block-Based RegExp Core Utilities"
    Date: 20-Jul-2025
    File: %qa-test-block-core-utils.r3
    Author: "Kiro AI Assistant"
    Version: "1.0.0"
    Purpose: "Test core utilities module for block-based RegExp engine in isolation"
    Type: "QA Test Script"
    Note: "Validates semantic token constants, character sets and validation functions"
]

;; Load the core utilities module
do %src/block-regexp-core-utils.r3

;;=============================================================================
;; TEST FRAMEWORK FUNCTIONS
;;=============================================================================
test-count: 0
pass-count: 0
fail-count: 0
all-tests-passed: true

assert-equal: funct [
    "Assert that expected equals actual with descriptive output"
    expected [any-type!] "Expected value"
    actual [any-type!] "Actual value"
    description [string!] "Test description"
    return: [logic!] "True if test passed"
] [
    set 'test-count (test-count + 1)
    
    either expected = actual [
        set 'pass-count (pass-count + 1)
        print ["  PASS:" description]
        true
    ] [
        set 'fail-count (fail-count + 1)
        set 'all-tests-passed false
        print ["  FAIL:" description]
        print ["    Expected:" mold expected]
        print ["    Actual:  " mold actual]
        false
    ]
]

assert-true: funct [
    "Assert that condition is true"
    condition [logic!] "Condition to test"
    description [string!] "Test description"
    return: [logic!] "True if test passed"
] [
    assert-equal true condition description
]

assert-false: funct [
    "Assert that condition is false"
    condition [logic!] "Condition to test"
    description [string!] "Test description"
    return: [logic!] "True if test passed"
] [
    assert-equal false condition description
]

;;=============================================================================
;; SEMANTIC TOKEN CONSTANTS TESTS
;;=============================================================================
print "^/=========================================="
print "BLOCK-BASED REGEXP CORE UTILITIES - QA TESTS"
print "=========================================="
print "^/--- Testing Semantic Token Constants ---"

;; Test basic token constants
assert-equal 'anchor-start ANCHOR-START "ANCHOR-START constant defined correctly"
assert-equal 'anchor-end ANCHOR-END "ANCHOR-END constant defined correctly"
assert-equal 'literal LITERAL "LITERAL constant defined correctly"
assert-equal 'wildcard WILDCARD "WILDCARD constant defined correctly"

;; Test character class token constants
assert-equal 'digit-class DIGIT-CLASS "DIGIT-CLASS constant defined correctly"
assert-equal 'word-class WORD-CLASS "WORD-CLASS constant defined correctly"
assert-equal 'space-class SPACE-CLASS "SPACE-CLASS constant defined correctly"
assert-equal 'non-digit-class NON-DIGIT-CLASS "NON-DIGIT-CLASS constant defined correctly"
assert-equal 'non-word-class NON-WORD-CLASS "NON-WORD-CLASS constant defined correctly"
assert-equal 'non-space-class NON-SPACE-CLASS "NON-SPACE-CLASS constant defined correctly"
assert-equal 'custom-class CUSTOM-CLASS "CUSTOM-CLASS constant defined correctly"

;; Test quantifier token constants
assert-equal 'quantifier-plus QUANTIFIER-PLUS "QUANTIFIER-PLUS constant defined correctly"
assert-equal 'quantifier-star QUANTIFIER-STAR "QUANTIFIER-STAR constant defined correctly"
assert-equal 'quantifier-optional QUANTIFIER-OPTIONAL "QUANTIFIER-OPTIONAL constant defined correctly"
assert-equal 'quantifier-exact QUANTIFIER-EXACT "QUANTIFIER-EXACT constant defined correctly"
assert-equal 'quantifier-range QUANTIFIER-RANGE "QUANTIFIER-RANGE constant defined correctly"

;; Test complex token constants
assert-equal 'group GROUP "GROUP constant defined correctly"
assert-equal 'alternation ALTERNATION "ALTERNATION constant defined correctly"
assert-equal 'escaped-char ESCAPED-CHAR "ESCAPED-CHAR constant defined correctly"

;;=============================================================================
;; CHARACTER SET CREATION TESTS
;;=============================================================================
print "^/--- Testing Enhanced Character Set Creation ---"

;; Test CreateTokenizedCharSet with string specifications
test-digit-set: CreateTokenizedCharSet "0-9"
assert-true bitset? test-digit-set "CreateTokenizedCharSet creates bitset from string"
assert-true find test-digit-set #"5" "CreateTokenizedCharSet digit set contains '5'"
assert-false find test-digit-set #"a" "CreateTokenizedCharSet digit set excludes 'a'"

;; Test CreateTokenizedCharSet with block token specifications
test-digit-token: CreateTokenizedCharSet [digit-class]
assert-true bitset? test-digit-token "CreateTokenizedCharSet creates bitset from digit-class token"
assert-true find test-digit-token #"7" "CreateTokenizedCharSet digit-class token contains '7'"

test-word-token: CreateTokenizedCharSet [word-class]
assert-true bitset? test-word-token "CreateTokenizedCharSet creates bitset from word-class token"
assert-true find test-word-token #"A" "CreateTokenizedCharSet word-class token contains 'A'"
assert-true find test-word-token #"_" "CreateTokenizedCharSet word-class token contains '_'"

test-custom-token: CreateTokenizedCharSet [custom-class normal "a-z"]
assert-true bitset? test-custom-token "CreateTokenizedCharSet creates bitset from custom-class token"
assert-true find test-custom-token #"m" "CreateTokenizedCharSet custom-class token contains 'm'"
assert-false find test-custom-token #"5" "CreateTokenizedCharSet custom-class token excludes '5'"

;; Test pre-built character sets are still available
assert-true bitset? digit-charset "Pre-built digit-charset is available"
assert-true bitset? word-charset "Pre-built word-charset is available"
assert-true bitset? space-charset "Pre-built space-charset is available"
assert-true bitset? non-digit-charset "Pre-built non-digit-charset is available"
assert-true bitset? non-word-charset "Pre-built non-word-charset is available"
assert-true bitset? non-space-charset "Pre-built non-space-charset is available"

;;=============================================================================
;; TOKEN TYPE VALIDATION TESTS
;;=============================================================================
print "^/--- Testing Token Type Validation ---"

;; Test valid token types
assert-true ValidateTokenType 'anchor-start "ValidateTokenType accepts anchor-start"
assert-true ValidateTokenType 'digit-class "ValidateTokenType accepts digit-class"
assert-true ValidateTokenType 'quantifier-plus "ValidateTokenType accepts quantifier-plus"
assert-true ValidateTokenType 'custom-class "ValidateTokenType accepts custom-class"
assert-true ValidateTokenType 'group "ValidateTokenType accepts group"
assert-true ValidateTokenType 'escaped-char "ValidateTokenType accepts escaped-char"

;; Test invalid token types
assert-false ValidateTokenType 'invalid-token "ValidateTokenType rejects invalid-token"
assert-false ValidateTokenType 'unknown-type "ValidateTokenType rejects unknown-type"
assert-false ValidateTokenType 'bad-token "ValidateTokenType rejects bad-token"

;;=============================================================================
;; TOKEN SEQUENCE VALIDATION TESTS
;;=============================================================================
print "^/--- Testing Token Sequence Validation ---"

;; Test valid simple token sequences
valid-result1: ValidateTokenSequence [anchor-start literal digit-class quantifier-plus]
assert-true logic? valid-result1 "ValidateTokenSequence returns logic for valid sequence"
assert-true valid-result1 "ValidateTokenSequence accepts valid simple token sequence"

valid-result2: ValidateTokenSequence [word-class quantifier-star space-class digit-class]
assert-true valid-result2 "ValidateTokenSequence accepts another valid simple sequence"

;; Test valid compound token sequences
valid-compound: ValidateTokenSequence [
    anchor-start 
    [quantifier-exact 3] 
    digit-class 
    [custom-class normal "a-z"]
    quantifier-plus
]
assert-true valid-compound "ValidateTokenSequence accepts valid compound token sequence"

;; Test valid group token sequences
valid-groups: ValidateTokenSequence [
    [group open]
    digit-class
    quantifier-plus
    [group close]
    literal
]
assert-true valid-groups "ValidateTokenSequence accepts valid group sequence"

;; Test invalid token sequences
empty-result: ValidateTokenSequence []
assert-true string? empty-result "ValidateTokenSequence returns error string for empty sequence"
assert-equal "Empty token sequence" empty-result "ValidateTokenSequence reports empty sequence error"

;; Test invalid compound token structure
invalid-compound: ValidateTokenSequence [[quantifier-exact]]
assert-true string? invalid-compound "ValidateTokenSequence returns error for invalid compound token"

;; Test unmatched groups
unmatched-groups: ValidateTokenSequence [[group open] digit-class]
assert-true string? unmatched-groups "ValidateTokenSequence returns error for unmatched groups"

;; Test invalid quantifier range
invalid-range: ValidateTokenSequence [[quantifier-range 5 3]]
assert-true string? invalid-range "ValidateTokenSequence returns error for invalid quantifier range"

;;=============================================================================
;; LEGACY FUNCTION COMPATIBILITY TESTS
;;=============================================================================
print "^/--- Testing Legacy Function Compatibility ---"

;; Test ValidateQuantifierRange function
assert-true ValidateQuantifierRange "3" "ValidateQuantifierRange accepts exact quantifier"
assert-true ValidateQuantifierRange "2,5" "ValidateQuantifierRange accepts range quantifier"
assert-false ValidateQuantifierRange "" "ValidateQuantifierRange rejects empty string"
assert-false ValidateQuantifierRange "abc" "ValidateQuantifierRange rejects non-numeric"
assert-false ValidateQuantifierRange "5,3" "ValidateQuantifierRange rejects reverse range"

;; Test ValidateCharacterClass function
assert-true ValidateCharacterClass "a-z" "ValidateCharacterClass accepts valid range"
assert-true ValidateCharacterClass "^a-z" "ValidateCharacterClass accepts negated class"
assert-false ValidateCharacterClass "" "ValidateCharacterClass rejects empty class"
assert-false ValidateCharacterClass "z-a" "ValidateCharacterClass rejects reverse range"

;; Test ProcessQuantifierSafely function
safe-result1: ProcessQuantifierSafely "3" digit-charset
assert-true block? safe-result1 "ProcessQuantifierSafely returns block for valid quantifier"
assert-equal 2 length? safe-result1 "ProcessQuantifierSafely returns correct structure for exact quantifier"

safe-result2: ProcessQuantifierSafely "2,4" word-charset
assert-true block? safe-result2 "ProcessQuantifierSafely returns block for valid range quantifier"
assert-equal 3 length? safe-result2 "ProcessQuantifierSafely returns correct structure for range quantifier"

safe-result3: ProcessQuantifierSafely "invalid" digit-charset
assert-equal none safe-result3 "ProcessQuantifierSafely returns none for invalid quantifier"

;; Test MakeCharSet function (legacy compatibility)
legacy-charset: MakeCharSet "0-9a-f"
assert-true bitset? legacy-charset "MakeCharSet creates bitset"
assert-true find legacy-charset #"5" "MakeCharSet includes digits"
assert-true find legacy-charset #"c" "MakeCharSet includes hex letters"
assert-false find legacy-charset #"z" "MakeCharSet excludes non-specified characters"

;;=============================================================================
;; INTEGRATION TESTS
;;=============================================================================
print "^/--- Testing Integration Scenarios ---"

;; Test realistic token sequence for email pattern
email-tokens: [
    anchor-start
    [custom-class normal "a-zA-Z0-9._%+-"]
    quantifier-plus
    literal
    [custom-class normal "a-zA-Z0-9.-"]
    quantifier-plus
    literal
    [custom-class normal "a-zA-Z"]
    [quantifier-range 2 4]
    anchor-end
]
email-validation: ValidateTokenSequence email-tokens
assert-true email-validation "ValidateTokenSequence accepts realistic email pattern tokens"

;; Test phone number pattern tokens
phone-tokens: [
    anchor-start
    [escaped-char #"+"]
    quantifier-optional
    digit-class
    quantifier-optional
    [escaped-char #"-"]
    quantifier-optional
    digit-class
    [quantifier-exact 3]
    [escaped-char #"-"]
    quantifier-optional
    digit-class
    [quantifier-exact 3]
    [escaped-char #"-"]
    quantifier-optional
    digit-class
    [quantifier-exact 4]
    anchor-end
]
phone-validation: ValidateTokenSequence phone-tokens
assert-true phone-validation "ValidateTokenSequence accepts realistic phone pattern tokens"

;; Test grouped pattern with alternation
grouped-tokens: [
    [group open]
    digit-class
    quantifier-plus
    alternation
    word-class
    quantifier-plus
    [group close]
    space-class
    quantifier-optional
]
grouped-validation: ValidateTokenSequence grouped-tokens
assert-true grouped-validation "ValidateTokenSequence accepts grouped pattern with alternation"

;;=============================================================================
;; TEST RESULTS SUMMARY
;;=============================================================================
print "^/=========================================="
print "BLOCK-BASED CORE UTILITIES - TEST SUMMARY"
print "=========================================="
print ["Total Tests Executed:" test-count]
print ["Tests Passed:" pass-count]
print ["Tests Failed:" fail-count]

if test-count > 0 [
    success-rate: to integer! (pass-count * 100) / test-count
    print ["Success Rate:" success-rate "%"]
    
    quality-rating: either success-rate >= 95 ["EXCELLENT"] [
        either success-rate >= 90 ["VERY GOOD"] [
            either success-rate >= 80 ["GOOD"] ["NEEDS IMPROVEMENT"]
        ]
    ]
    print ["Quality Rating:" quality-rating]
]

print ["All Tests Passed:" either all-tests-passed ["YES"] ["NO"]]

either all-tests-passed [
    print "^/✅ BLOCK-BASED CORE UTILITIES MODULE: PRODUCTION READY"
    print "All semantic token constants, character sets, and validation functions working correctly."
] [
    print "^/❌ BLOCK-BASED CORE UTILITIES MODULE: ISSUES DETECTED"
    print "Some tests failed - review implementation before proceeding."
]

print "^/=========================================="
