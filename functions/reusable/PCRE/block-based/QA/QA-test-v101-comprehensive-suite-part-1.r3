REBOL [
    Title: "Unified Comprehensive QA Test Suite - Part 1"
    Date: 30-Jul-2025
    Author: "AI Assistant"
    Purpose: "Consolidated comprehensive QA testing for block-based RegExp engine - Core Tests"
    Type: "QA Test Script"
    Version: 1.0.1
    Note: "Part 1: Core functionality, basic patterns, character classes and quantifiers"
]

print "^/=========================================="
print "UNIFIED COMPREHENSIVE QA TEST SUITE - PART 1"
print "=========================================="

;;=============================================================================
;; LOAD ENGINE AND DEPENDENCIES
;;=============================================================================
print "Loading block-based RegExp engine..."
do %../src/block-regexp-engine.r3

;;=============================================================================
;; ROBUST QA TEST FRAMEWORK
;;=============================================================================
total-tests: 0
passed-tests: 0
failed-tests: 0
error-tests: 0
test-categories: make map! []

record-test: funct [
    "Record test result with comprehensive category tracking"
    category [string!] "Test category"
    description [string!] "Test description"
    result [logic!] "Test result (true = pass, false = fail)"
    error-occurred [logic!] "Whether an error occurred"
] [
    set 'total-tests total-tests + 1
    
    ;; Initialize category if not exists
    if not select test-categories category [
        test-categories/:category: reduce [0 0 0 0]  ;; [total passed failed errors]
    ]
    
    category-stats: select test-categories category
    category-stats/1: category-stats/1 + 1  ;; Increment total
    
    either error-occurred [
        set 'error-tests error-tests + 1
        category-stats/4: category-stats/4 + 1  ;; Increment category errors
        set 'failed-tests failed-tests + 1
        print ["❌ ERROR:" description]
    ] [
        either result [
            set 'passed-tests passed-tests + 1
            category-stats/2: category-stats/2 + 1  ;; Increment category passed
            print ["✅ PASSED:" description]
        ] [
            set 'failed-tests failed-tests + 1
            category-stats/3: category-stats/3 + 1  ;; Increment category failed
            print ["❌ FAILED:" description]
        ]
    ]
]

test-regexp: funct [
    "Test RegExp function with comprehensive error handling"
    haystack [string!] "String to test"
    pattern [string!] "Pattern to match"
    expected [any-type!] "Expected result"
    description [string!] "Test description"
    category [string!] "Test category"
] [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test category description false true
    ] [
        record-test category description (equal? expected test-result) false
    ]
]

;;=============================================================================
;; MODULE LOADING AND DEPENDENCY TESTS
;;=============================================================================
print "^/--- MODULE LOADING AND DEPENDENCY TESTS ---"

;; Test required functions availability
required-functions: [
    RegExp TestRegExp GetEngineInfo GetModuleStatus
    GetPerformanceStats RegExpWithStats DebugRegExp ValidatePattern
    StringToPatternBlock ProcessPatternBlock ExecuteBlockMatch
]

foreach func-name required-functions [
    func-available: value? func-name
    record-test "MODULE_LOADING" 
        rejoin ["Function " func-name " is available"]
        func-available false
]

;; Test module status
module-status: none
module-status-error: none
set/any 'module-status-error try [
    module-status: GetModuleStatus
]

record-test "MODULE_LOADING" "GetModuleStatus function works"
    (not error? module-status-error) (error? module-status-error)

if module-status [
    record-test "MODULE_LOADING" "All core modules loaded"
        module-status/all-loaded false
    record-test "MODULE_LOADING" "Core utilities module loaded"
        module-status/core-utils false
    record-test "MODULE_LOADING" "Tokenizer module loaded"
        module-status/tokenizer false
    record-test "MODULE_LOADING" "Processor module loaded"
        module-status/processor false
    record-test "MODULE_LOADING" "Matcher module loaded"
        module-status/matcher false
]

;;=============================================================================
;; BASIC LITERAL MATCHING TESTS
;;=============================================================================
print "^/--- BASIC LITERAL MATCHING TESTS ---"

test-regexp "hello" "hello" "hello" "Basic literal match" "BASIC_LITERALS"
test-regexp "world" "hello" false "Basic literal non-match" "BASIC_LITERALS"
test-regexp "test" "test" "test" "Exact literal match" "BASIC_LITERALS"
test-regexp "testing" "test" "test" "Literal match at start" "BASIC_LITERALS"
test-regexp "contest" "test" "test" "Literal match in middle" "BASIC_LITERALS"
test-regexp "hello world" "hello" "hello" "Literal match with continuation" "BASIC_LITERALS"
test-regexp "HELLO" "hello" false "Case sensitive literal match" "BASIC_LITERALS"

;;=============================================================================
;; CHARACTER CLASS TESTS
;;=============================================================================
print "^/--- CHARACTER CLASS TESTS ---"

;; Digit character class tests
test-regexp "5" "\d" "5" "Single digit match with \\d" "CHAR_CLASSES"
test-regexp "0" "\d" "0" "Zero digit match with \\d" "CHAR_CLASSES"
test-regexp "9" "\d" "9" "Nine digit match with \\d" "CHAR_CLASSES"
test-regexp "a" "\d" false "Non-digit rejection with \\d" "CHAR_CLASSES"
test-regexp "!" "\d" false "Symbol rejection with \\d" "CHAR_CLASSES"
test-regexp " " "\d" false "Space rejection with \\d" "CHAR_CLASSES"

;; Non-digit character class tests
test-regexp "a" "\D" "a" "Letter matches \\D" "CHAR_CLASSES"
test-regexp "!" "\D" "!" "Symbol matches \\D" "CHAR_CLASSES"
test-regexp " " "\D" " " "Space matches \\D" "CHAR_CLASSES"
test-regexp "5" "\D" false "Digit rejection with \\D" "CHAR_CLASSES"
test-regexp "0" "\D" false "Zero rejection with \\D" "CHAR_CLASSES"

;; Word character class tests
test-regexp "a" "\w" "a" "Lowercase letter with \\w" "CHAR_CLASSES"
test-regexp "A" "\w" "A" "Uppercase letter with \\w" "CHAR_CLASSES"
test-regexp "5" "\w" "5" "Digit with \\w" "CHAR_CLASSES"
test-regexp "_" "\w" "_" "Underscore with \\w" "CHAR_CLASSES"
test-regexp "!" "\w" false "Symbol rejection with \\w" "CHAR_CLASSES"
test-regexp " " "\w" false "Space rejection with \\w" "CHAR_CLASSES"
test-regexp "-" "\w" false "Hyphen rejection with \\w" "CHAR_CLASSES"

;; Non-word character class tests
test-regexp "!" "\W" "!" "Symbol matches \\W" "CHAR_CLASSES"
test-regexp " " "\W" " " "Space matches \\W" "CHAR_CLASSES"
test-regexp "-" "\W" "-" "Hyphen matches \\W" "CHAR_CLASSES"
test-regexp "a" "\W" false "Letter rejection with \\W" "CHAR_CLASSES"
test-regexp "5" "\W" false "Digit rejection with \\W" "CHAR_CLASSES"
test-regexp "_" "\W" false "Underscore rejection with \\W" "CHAR_CLASSES"

;; Space character class tests
test-regexp " " "\s" " " "Space character with \\s" "CHAR_CLASSES"
test-regexp "^-" "\s" "^-" "Tab character with \\s" "CHAR_CLASSES"
test-regexp "^/" "\s" "^/" "Newline character with \\s" "CHAR_CLASSES"
test-regexp "a" "\s" false "Letter rejection with \\s" "CHAR_CLASSES"
test-regexp "5" "\s" false "Digit rejection with \\s" "CHAR_CLASSES"
test-regexp "_" "\s" false "Underscore rejection with \\s" "CHAR_CLASSES"

;; Non-space character class tests
test-regexp "a" "\S" "a" "Letter matches \\S" "CHAR_CLASSES"
test-regexp "5" "\S" "5" "Digit matches \\S" "CHAR_CLASSES"
test-regexp "_" "\S" "_" "Underscore matches \\S" "CHAR_CLASSES"
test-regexp "!" "\S" "!" "Symbol matches \\S" "CHAR_CLASSES"
test-regexp " " "\S" false "Space rejection with \\S" "CHAR_CLASSES"
test-regexp "^-" "\S" false "Tab rejection with \\S" "CHAR_CLASSES"

;;=============================================================================
;; CUSTOM CHARACTER CLASS TESTS
;;=============================================================================
print "^/--- CUSTOM CHARACTER CLASS TESTS ---"

;; Basic character classes
test-regexp "a" "[a-z]" "a" "Lowercase range [a-z]" "CUSTOM_CLASSES"
test-regexp "z" "[a-z]" "z" "Lowercase range boundary [a-z]" "CUSTOM_CLASSES"
test-regexp "A" "[a-z]" false "Uppercase rejection [a-z]" "CUSTOM_CLASSES"
test-regexp "5" "[0-9]" "5" "Digit range [0-9]" "CUSTOM_CLASSES"
test-regexp "0" "[0-9]" "0" "Digit range boundary [0-9]" "CUSTOM_CLASSES"
test-regexp "a" "[0-9]" false "Letter rejection [0-9]" "CUSTOM_CLASSES"

;; Mixed character classes
test-regexp "a" "[a-zA-Z]" "a" "Mixed case range [a-zA-Z]" "CUSTOM_CLASSES"
test-regexp "Z" "[a-zA-Z]" "Z" "Mixed case range boundary [a-zA-Z]" "CUSTOM_CLASSES"
test-regexp "5" "[a-zA-Z0-9]" "5" "Alphanumeric class [a-zA-Z0-9]" "CUSTOM_CLASSES"
test-regexp "_" "[a-zA-Z0-9_]" "_" "Alphanumeric with underscore" "CUSTOM_CLASSES"

;; Negated character classes
test-regexp "a" "[^^0-9]" "a" "Negated digit class [^^0-9]" "CUSTOM_CLASSES"
test-regexp "!" "[^^0-9]" "!" "Negated digit class symbol [^^0-9]" "CUSTOM_CLASSES"
test-regexp "5" "[^^0-9]" false "Negated digit class rejection [^^0-9]" "CUSTOM_CLASSES"
test-regexp "A" "[^^a-z]" "A" "Negated lowercase [^^a-z]" "CUSTOM_CLASSES"
test-regexp "5" "[^^a-z]" "5" "Negated lowercase digit [^^a-z]" "CUSTOM_CLASSES"
test-regexp "a" "[^^a-z]" false "Negated lowercase rejection [^^a-z]" "CUSTOM_CLASSES"

;;=============================================================================
;; QUANTIFIER TESTS
;;=============================================================================
print "^/--- QUANTIFIER TESTS ---"

;; Plus quantifier (+) tests
test-regexp "a" "a+" "a" "Plus quantifier single match" "QUANTIFIERS"
test-regexp "aa" "a+" "aa" "Plus quantifier double match" "QUANTIFIERS"
test-regexp "aaa" "a+" "aaa" "Plus quantifier triple match" "QUANTIFIERS"
test-regexp "aaabbb" "a+" "aaa" "Plus quantifier with continuation" "QUANTIFIERS"
test-regexp "bbb" "a+" false "Plus quantifier no match" "QUANTIFIERS"
test-regexp "123" "\d+" "123" "Plus quantifier with digits" "QUANTIFIERS"
test-regexp "abc123" "\d+" "123" "Plus quantifier digits in middle" "QUANTIFIERS"

;; Star quantifier (*) tests
test-regexp "" "a*" "" "Star quantifier empty match" "QUANTIFIERS"
test-regexp "a" "a*" "a" "Star quantifier single match" "QUANTIFIERS"
test-regexp "aaa" "a*" "aaa" "Star quantifier multiple match" "QUANTIFIERS"
test-regexp "bbb" "a*" "" "Star quantifier zero match" "QUANTIFIERS"
test-regexp "aaabbb" "a*" "aaa" "Star quantifier with continuation" "QUANTIFIERS"
test-regexp "123abc" "\d*" "123" "Star quantifier with digits" "QUANTIFIERS"

;; Optional quantifier (?) tests
test-regexp "a" "a?" "a" "Optional quantifier present" "QUANTIFIERS"
test-regexp "" "a?" "" "Optional quantifier absent" "QUANTIFIERS"
test-regexp "ab" "a?" "a" "Optional quantifier with continuation" "QUANTIFIERS"
test-regexp "b" "a?" "" "Optional quantifier not present" "QUANTIFIERS"
test-regexp "5abc" "\d?" "5" "Optional quantifier digit present" "QUANTIFIERS"
test-regexp "abc" "\d?" "" "Optional quantifier digit absent" "QUANTIFIERS"

;; Exact quantifier {n} tests
test-regexp "aaa" "a{3}" "aaa" "Exact quantifier {3} match" "QUANTIFIERS"
test-regexp "aa" "a{3}" false "Exact quantifier {3} insufficient" "QUANTIFIERS"
test-regexp "aaaa" "a{3}" "aaa" "Exact quantifier {3} with extra" "QUANTIFIERS"
test-regexp "123" "\d{3}" "123" "Exact quantifier digits {3}" "QUANTIFIERS"
test-regexp "12" "\d{3}" false "Exact quantifier digits {3} insufficient" "QUANTIFIERS"

;; Range quantifier {n,m} tests
test-regexp "aa" "a{2,4}" "aa" "Range quantifier {2,4} minimum" "QUANTIFIERS"
test-regexp "aaa" "a{2,4}" "aaa" "Range quantifier {2,4} middle" "QUANTIFIERS"
test-regexp "aaaa" "a{2,4}" "aaaa" "Range quantifier {2,4} maximum" "QUANTIFIERS"
test-regexp "a" "a{2,4}" false "Range quantifier {2,4} insufficient" "QUANTIFIERS"
test-regexp "aaaaa" "a{2,4}" "aaaa" "Range quantifier {2,4} with extra" "QUANTIFIERS"
test-regexp "12" "\d{1,3}" "12" "Range quantifier digits {1,3}" "QUANTIFIERS"

;;=============================================================================
;; WILDCARD TESTS
;;=============================================================================
print "^/--- WILDCARD TESTS ---"

test-regexp "a" "." "a" "Wildcard matches letter" "WILDCARDS"
test-regexp "5" "." "5" "Wildcard matches digit" "WILDCARDS"
test-regexp "!" "." "!" "Wildcard matches symbol" "WILDCARDS"
test-regexp " " "." " " "Wildcard matches space" "WILDCARDS"
test-regexp "abc" "a.c" "abc" "Wildcard in pattern" "WILDCARDS"
test-regexp "a5c" "a.c" "a5c" "Wildcard matches digit in pattern" "WILDCARDS"
test-regexp "a!c" "a.c" "a!c" "Wildcard matches symbol in pattern" "WILDCARDS"

;;=============================================================================
;; ANCHOR TESTS (CRITICAL FOR BLOCK-BASED ENGINE)
;;=============================================================================
print "^/--- ANCHOR TESTS ---"

;; Start anchor tests
test-regexp "hello world" "^^hello" "hello" "Start anchor ^^hello match" "ANCHORS"
test-regexp "say hello" "^^hello" false "Start anchor ^^hello non-match" "ANCHORS"
test-regexp "hello" "^^hello" "hello" "Start anchor exact match" "ANCHORS"
test-regexp "hello123" "^^hello" "hello" "Start anchor with continuation" "ANCHORS"
test-regexp "123hello" "^^hello" false "Start anchor middle rejection" "ANCHORS"
test-regexp "test123" "^^test" "test" "Start anchor with digits" "ANCHORS"

;; End anchor tests
test-regexp "hello world" "world$" "world" "End anchor world$ match" "ANCHORS"
test-regexp "world hello" "world$" false "End anchor world$ non-match" "ANCHORS"
test-regexp "world" "world$" "world" "End anchor exact match" "ANCHORS"
test-regexp "123world" "world$" "world" "End anchor with prefix" "ANCHORS"
test-regexp "world123" "world$" false "End anchor middle rejection" "ANCHORS"
test-regexp "test123" "123$" "123" "End anchor with digits" "ANCHORS"

;; Combined anchor tests
test-regexp "hello" "^^hello$" "hello" "Combined anchors exact match" "ANCHORS"
test-regexp "hello world" "^^hello$" false "Combined anchors partial rejection" "ANCHORS"
test-regexp "say hello" "^^hello$" false "Combined anchors prefix rejection" "ANCHORS"
test-regexp "hello!" "^^hello$" false "Combined anchors suffix rejection" "ANCHORS"

;;=============================================================================
;; PART 1 RESULTS SUMMARY
;;=============================================================================
print "^/=========================================="
print "PART 1 TEST RESULTS SUMMARY"
print "=========================================="

print ["Total Tests Executed:" total-tests]
print ["Tests Passed:" passed-tests]
print ["Tests Failed:" failed-tests]
print ["Tests with Errors:" error-tests]

part1-success-rate: either total-tests > 0 [
    to integer! (passed-tests * 100.0) / total-tests
] [0]

print ["Part 1 Success Rate:" part1-success-rate "%"]

print "^/--- PART 1 CATEGORY BREAKDOWN ---"
foreach [category stats] test-categories [
    total: stats/1
    passed: stats/2
    failed: stats/3
    errors: stats/4
    category-success: either total > 0 [
        to integer! (passed * 100.0) / total
    ] [0]
    
    print [category ":" total "tests," passed "passed," failed "failed," errors "errors," category-success "% success"]
]

either part1-success-rate >= 95 [
    print "^/✅ PART 1: EXCELLENT PERFORMANCE (95%+ success rate)"
] [
    either part1-success-rate >= 90 [
        print "^/⚠️ PART 1: GOOD PERFORMANCE (90-94% success rate)"
    ] [
        print "^/❌ PART 1: NEEDS ATTENTION (<90% success rate)"
    ]
]

print "^/=========================================="
print "PART 1 COMPLETED - PROCEED TO RUN PART 2"
print "=========================================="
