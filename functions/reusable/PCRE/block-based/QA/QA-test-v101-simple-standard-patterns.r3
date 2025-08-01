REBOL [
    Title: "Simple Standard Patterns Test"
    Date: 30-Jul-2025
    Author: "AI Assistant"
    Purpose: "Test block-based RegExp engine against a few standard test patterns manually"
    Type: "QA Test Script"
    Version: 1.0.1
    Note: "Simplified version to test the concept with manual test cases"
]

print "^/=========================================="
print "SIMPLE STANDARD PATTERNS TEST"
print "=========================================="

;;=============================================================================
;; LOAD ENGINE AND INITIALIZE
;;=============================================================================
print "Loading block-based RegExp engine..."
do %../src/block-regexp-engine.r3

;; Test counters
total-tests: 0
passed-tests: 0
failed-tests: 0
skipped-tests: 0

;; Test categories
test-categories: make map! []

;;=============================================================================
;; HELPER FUNCTIONS
;;=============================================================================
;; Record test result
record-test: funct [
    "Record a test result"
    pattern [string!] "Pattern tested"
    test-string [string!] "String tested"
    expected [string!] "Expected result (y/n/c)"
    actual [any-type!] "Actual result"
    category [string!] "Test category"
] [
    set 'total-tests total-tests + 1
    
    ;; Initialize category if needed
    if not select test-categories category [
        test-categories/:category: reduce [0 0 0 0]  ;; [total passed failed skipped]
    ]
    
    category-stats: select test-categories category
    category-stats/1: category-stats/1 + 1
    
    ;; Determine result
    either expected = "y" [
        ;; Expected match
        either any [string? actual logic? actual] [
            either actual [
                set 'passed-tests passed-tests + 1
                category-stats/2: category-stats/2 + 1
                print ["✅ PASSED:" pattern "matched" mold test-string]
            ] [
                set 'failed-tests failed-tests + 1
                category-stats/3: category-stats/3 + 1
                print ["❌ FAILED:" pattern "should match" mold test-string "but didn't"]
            ]
        ] [
            set 'failed-tests failed-tests + 1
            category-stats/3: category-stats/3 + 1
            print ["❌ FAILED:" pattern "unexpected result type:" type? actual]
        ]
    ] [
        either expected = "n" [
            ;; Expected no match
            either any [actual = false none? actual] [
                set 'passed-tests passed-tests + 1
                category-stats/2: category-stats/2 + 1
                print ["✅ PASSED:" pattern "correctly didn't match" mold test-string]
            ] [
                set 'failed-tests failed-tests + 1
                category-stats/3: category-stats/3 + 1
                print ["❌ FAILED:" pattern "shouldn't match" mold test-string "but did"]
            ]
        ] [
            ;; Skip unknown expectations
            set 'skipped-tests skipped-tests + 1
            category-stats/4: category-stats/4 + 1
            print ["⚠️  SKIP:" pattern "- Unknown expected result:" expected]
        ]
    ]
]

;; Test a pattern
test-pattern: funct [
    "Test a pattern against our engine"
    pattern [string!] "Pattern to test"
    test-string [string!] "String to test"
    expected [string!] "Expected result"
    category [string!] "Test category"
] [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp test-string pattern
    ]
    
    either error? test-error [
        print ["❌ ERROR:" pattern "on" mold test-string "- Engine error"]
        set 'failed-tests failed-tests + 1
    ] [
        record-test pattern test-string expected test-result category
    ]
]

;; Test a pattern with /caret refinement
test-pattern-caret: funct [
    "Test a pattern with /caret refinement against our engine"
    pattern [string!] "Pattern to test"
    test-string [string!] "String to test"
    expected [string!] "Expected result"
    category [string!] "Test category"
] [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp/caret test-string pattern
    ]
    
    either error? test-error [
        print ["❌ ERROR: /caret" pattern "on" mold test-string "- Engine error"]
        set 'failed-tests failed-tests + 1
    ] [
        record-test rejoin ["/caret " pattern] test-string expected test-result category
    ]
]

;;=============================================================================
;; MANUAL TEST CASES FROM STANDARD PATTERNS
;;=============================================================================

print "^/--- BASIC LITERAL TESTS ---"
test-pattern "abc" "abc" "y" "BASIC_LITERAL"
test-pattern "abc" "xbc" "n" "BASIC_LITERAL"
test-pattern "abc" "axc" "n" "BASIC_LITERAL"
test-pattern "abc" "abx" "n" "BASIC_LITERAL"
test-pattern "abc" "xabcy" "y" "BASIC_LITERAL"

print "^/--- QUANTIFIER TESTS ---"
test-pattern "ab*c" "abc" "y" "QUANTIFIERS"
test-pattern "ab*c" "ac" "y" "QUANTIFIERS"
test-pattern "ab*c" "abbc" "y" "QUANTIFIERS"
test-pattern "ab+c" "abc" "y" "QUANTIFIERS"
test-pattern "ab+c" "ac" "n" "QUANTIFIERS"
test-pattern "ab?c" "abc" "y" "QUANTIFIERS"
test-pattern "ab?c" "ac" "y" "QUANTIFIERS"

print "^/--- CHARACTER CLASS TESTS ---"
test-pattern "a.c" "abc" "y" "CHAR_CLASSES"
test-pattern "a.c" "axc" "y" "CHAR_CLASSES"
test-pattern "[abc]" "a" "y" "CHAR_CLASSES"
test-pattern "[abc]" "b" "y" "CHAR_CLASSES"
test-pattern "[abc]" "d" "n" "CHAR_CLASSES"
test-pattern "[!abc]" "d" "y" "CHAR_CLASSES"
test-pattern "[!abc]" "a" "n" "CHAR_CLASSES"

print "^/--- ANCHOR TESTS ---"
;; Note: Using alternative syntax - /caret refinement instead of ^ character
;; This avoids REBOL caret character interpretation issues
test-pattern-caret "abc" "abc" "y" "ANCHORS"
test-pattern-caret "abc" "xabc" "n" "ANCHORS"
test-pattern "abc$" "abc" "y" "ANCHORS"
test-pattern "abc$" "abcx" "n" "ANCHORS"
test-pattern-caret "abc" "abc" "y" "ANCHORS"
test-pattern-caret "abc" "abcc" "y" "ANCHORS"  ;; Corrected: ^abc should match "abcc"

print "^/--- ESCAPE SEQUENCE TESTS ---"
test-pattern "\." "." "y" "ESCAPES"
test-pattern "\+" "+" "y" "ESCAPES"
test-pattern "\*" "*" "y" "ESCAPES"
test-pattern "\?" "?" "y" "ESCAPES"

print "^/--- DIGIT AND WORD CLASS TESTS ---"
test-pattern "\d" "5" "y" "CHAR_CLASSES"
test-pattern "\d" "a" "n" "CHAR_CLASSES"
test-pattern "\w" "a" "y" "CHAR_CLASSES"
test-pattern "\w" "5" "y" "CHAR_CLASSES"
test-pattern "\w" "-" "n" "CHAR_CLASSES"
test-pattern "\s" " " "y" "CHAR_CLASSES"
test-pattern "\s" "a" "n" "CHAR_CLASSES"

;;=============================================================================
;; RESULTS SUMMARY
;;=============================================================================

print "^/=========================================="
print "SIMPLE STANDARD PATTERNS TEST RESULTS"
print "=========================================="

print ["Total Tests Executed:" total-tests]
print ["Tests Passed:" passed-tests]
print ["Tests Failed:" failed-tests]
print ["Tests Skipped:" skipped-tests]

success-rate: either total-tests > 0 [
    to integer! (passed-tests * 100.0) / total-tests
] [0]

print ["Overall Success Rate:" success-rate "%"]

print "^/--- CATEGORY BREAKDOWN ---"
foreach [category stats] test-categories [
    total: stats/1
    passed: stats/2
    failed: stats/3
    skipped: stats/4
    
    category-success: either (total - skipped) > 0 [
        to integer! (passed * 100.0) / (total - skipped)
    ] [0]
    
    print [category ":" total "total," passed "passed," failed "failed," skipped "skipped," category-success "% success"]
]

print "^/--- COMPATIBILITY ASSESSMENT ---"
testable-patterns: total-tests - skipped-tests
compatibility-rate: either testable-patterns > 0 [
    to integer! (passed-tests * 100.0) / testable-patterns
] [0]

print ["Testable Patterns:" testable-patterns]
print ["Engine Compatibility Rate:" compatibility-rate "%"]

either compatibility-rate >= 80 [
    print "^/✅✅ EXCELLENT: High compatibility with standard RegExp patterns"
] [
    either compatibility-rate >= 60 [
        print "^/✅ GOOD: Solid compatibility with core RegExp features"
    ] [
        either compatibility-rate >= 40 [
            print "^/⚠️  FAIR: Basic RegExp support, missing some standard features"
        ] [
            print "^/❌ NEEDS WORK: Limited RegExp compatibility, significant gaps"
        ]
    ]
]

print "^/=========================================="
print "SIMPLE STANDARD PATTERNS TEST COMPLETE"
print "=========================================="
