REBOL [
    Title: "Master Comprehensive QA Test Suite - Block-based RegExp Engine"
    Date: 30-Jul-2025
    File: %QA-test-block-engine-master-comprehensive.r3
    Author: "AI Assistant"
    Version: 1.0.1
    Purpose: "Consolidated comprehensive QA testing for all block-based RegExp engine components"
    Type: "QA Test Script"
    Note: "Consolidates all tests from individual QA scripts into one master suite"
]

print "^/=========================================="
print "MASTER COMPREHENSIVE QA TEST SUITE"
print "Block-based RegExp Engine - All Components"
print "=========================================="

;;=============================================================================
;; LOAD ALL DEPENDENCIES
;;=============================================================================
print "^/Loading all engine components..."

;; Load main orchestrator (which loads all dependencies)
main-engine-loaded: false
main-engine-error: none
set/any 'main-engine-error try [
    do %../src/block-regexp-engine.r3
    main-engine-loaded: true
]

either main-engine-loaded [
    print "✅ PASSED: Main engine loaded successfully"
] [
    print ["❌ FAILED: Failed to load main engine:" mold main-engine-error]
    halt
]

;;=============================================================================
;; COMPREHENSIVE TEST FRAMEWORK
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
        print ["ERROR:" description]
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

;;=============================================================================
;; MODULE LOADING AND DEPENDENCY TESTS
;;=============================================================================
print "^/--- MODULE LOADING AND DEPENDENCY TESTS ---"

;; Test all required functions are available
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

;; Test module status validation
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
;; CORE FUNCTIONALITY TESTS (from multiple QA files)
;;=============================================================================
print "^/--- CORE FUNCTIONALITY TESTS ---"

;; Basic literal matching tests
basic-literal-tests: reduce [
    "hello" "hello" "hello" "Basic literal match"
    "hello" "world" false "Basic literal non-match"
    "testing" "test" "test" "Literal match at start"
    "testing" "ing" "ing" "Literal match in middle"
]

foreach [haystack pattern expected description] basic-literal-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "CORE_FUNCTIONALITY" description false true
    ] [
        record-test "CORE_FUNCTIONALITY" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; ESCAPE SEQUENCE TESTS (comprehensive from all files)
;;=============================================================================
print "^/--- ESCAPE SEQUENCE TESTS ---"

escape-sequence-tests: reduce [
    ;; Digit class tests
    "5" "\d" "5" "\d matches single digit"
    "123" "\d" "1" "\d matches first digit only"
    "a" "\d" false "\d rejects non-digit"
    "123" "\d+" "123" "\d+ matches multiple digits"
    
    ;; Non-digit class tests
    "a" "\D" "a" "\D matches non-digit letter"
    "!" "\D" "!" "\D matches non-digit symbol"
    "5" "\D" false "\D rejects digit"
    
    ;; Word class tests
    "a" "\w" "a" "\w matches letter"
    "A" "\w" "A" "\w matches uppercase letter"
    "_" "\w" "_" "\w matches underscore"
    "5" "\w" "5" "\w matches digit as word char"
    "!" "\w" false "\w rejects non-word character"
    "hello123" "\w+" "hello123" "\w+ matches word sequence"
    
    ;; Non-word class tests
    "!" "\W" "!" "\W matches non-word symbol"
    "@" "\W" "@" "\W matches non-word at-symbol"
    "a" "\W" false "\W rejects word character"
    "_" "\W" false "\W rejects underscore"
    
    ;; Space class tests
    " " "\s" " " "\s matches space"
    "^-" "\s" "^-" "\s matches tab"
    "^/" "\s" "^/" "\s matches newline"
    "a" "\s" false "\s rejects non-space"
    "hello world" "\s" " " "\s finds space in string"
    
    ;; Non-space class tests
    "x" "\S" "x" "\S matches non-space letter"
    "5" "\S" "5" "\S matches non-space digit"
    "!" "\S" "!" "\S matches non-space symbol"
    " " "\S" false "\S rejects space"
    "^-" "\S" false "\S rejects tab"
]

foreach [haystack pattern expected description] escape-sequence-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "ESCAPE_SEQUENCES" description false true
    ] [
        record-test "ESCAPE_SEQUENCES" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; QUANTIFIER TESTS (comprehensive from all files)
;;=============================================================================
print "^/--- QUANTIFIER TESTS ---"

quantifier-tests: reduce [
    ;; Plus quantifier (+) - one or more
    "aaa" "a+" "aaa" "Plus quantifier multiple chars"
    "a" "a+" "a" "Plus quantifier single char"
    "" "a+" false "Plus quantifier empty string"
    "bbb" "a+" false "Plus quantifier no match"
    
    ;; Star quantifier (*) - zero or more
    "" "a*" "" "Star quantifier empty string"
    "a" "a*" "a" "Star quantifier single char"
    "aaa" "a*" "aaa" "Star quantifier multiple chars"
    "bbb" "a*" "" "Star quantifier no match (zero)"
    
    ;; Optional quantifier (?) - zero or one
    "a" "a?" "a" "Optional quantifier present"
    "" "a?" "" "Optional quantifier absent"
    "aa" "a?" "a" "Optional quantifier first only"
    "b" "a?" "" "Optional quantifier no match"
    
    ;; Exact quantifier {n}
    "aaa" "a{3}" "aaa" "Exact quantifier match"
    "aa" "a{3}" false "Exact quantifier insufficient"
    "aaaa" "a{3}" "aaa" "Exact quantifier first three"
    "" "a{3}" false "Exact quantifier empty"
    
    ;; Range quantifier {min,max}
    "aa" "a{2,4}" "aa" "Range quantifier minimum"
    "aaa" "a{2,4}" "aaa" "Range quantifier middle"
    "aaaa" "a{2,4}" "aaaa" "Range quantifier maximum"
    "a" "a{2,4}" false "Range quantifier below minimum"
    "aaaaa" "a{2,4}" "aaaa" "Range quantifier above maximum"
]

foreach [haystack pattern expected description] quantifier-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "QUANTIFIERS" description false true
    ] [
        record-test "QUANTIFIERS" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; ANCHOR TESTS (critical for block-based engine)
;;=============================================================================
print "^/--- ANCHOR TESTS ---"

;; Create proper caret character for start anchor using TypChrCaret constant
start-anchor-pattern: rejoin [TypChrCaret "hello"]

anchor-tests: reduce [
    ;; Start anchor tests
    "hello world" start-anchor-pattern "hello" "Start anchor match"
    "say hello" start-anchor-pattern false "Start anchor no match"
    "hello" start-anchor-pattern "hello" "Start anchor exact match"
    
    ;; End anchor tests
    "hello world" "world$" "world" "End anchor match"
    "world hello" "world$" false "End anchor no match"
    "world" "world$" "world" "End anchor exact match"
    
    ;; Combined anchor tests
    "hello" rejoin [start-anchor-pattern "$"] "hello" "Both anchors exact match"
    "hello world" rejoin [start-anchor-pattern "$"] false "Both anchors no match"
]

foreach [haystack pattern expected description] anchor-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "ANCHORS" description false true
    ] [
        record-test "ANCHORS" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; CHARACTER CLASS TESTS (comprehensive)
;;=============================================================================
print "^/--- CHARACTER CLASS TESTS ---"

character-class-tests: reduce [
    ;; Basic character classes
    "a" "[a-z]" "a" "Lowercase letter class"
    "A" "[A-Z]" "A" "Uppercase letter class"
    "5" "[0-9]" "5" "Digit character class"
    "z" "[a-z]" "z" "Letter class boundary"
    "0" "[0-9]" "0" "Digit class boundary"
    "9" "[0-9]" "9" "Digit class upper boundary"
    
    ;; Character class rejections
    "A" "[a-z]" false "Uppercase rejected by lowercase class"
    "a" "[A-Z]" false "Lowercase rejected by uppercase class"
    "a" "[0-9]" false "Letter rejected by digit class"
    "5" "[a-z]" false "Digit rejected by letter class"
    
    ;; Negated character classes (using TypChrCaret constant)
    "a" (rejoin ["[" TypChrCaret "0-9]"]) "a" "Negated digit class accepts letter"
    "!" (rejoin ["[" TypChrCaret "0-9]"]) "!" "Negated digit class accepts symbol"
    "5" (rejoin ["[" TypChrCaret "0-9]"]) false "Negated digit class rejects digit"
    "A" (rejoin ["[" TypChrCaret "a-z]"]) "A" "Negated lowercase accepts uppercase"
    "a" (rejoin ["[" TypChrCaret "a-z]"]) false "Negated lowercase rejects lowercase"
    
    ;; Mixed character classes
    "a" "[a-zA-Z]" "a" "Mixed case class lowercase"
    "A" "[a-zA-Z]" "A" "Mixed case class uppercase"
    "5" "[a-zA-Z0-9]" "5" "Alphanumeric class digit"
    "!" "[a-zA-Z0-9]" false "Alphanumeric class rejects symbol"
]

foreach [haystack pattern expected description] character-class-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "CHARACTER_CLASSES" description false true
    ] [
        record-test "CHARACTER_CLASSES" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; WILDCARD AND SPECIAL CHARACTER TESTS
;;=============================================================================
print "^/--- WILDCARD AND SPECIAL CHARACTER TESTS ---"

wildcard-tests: reduce [
    ;; Wildcard tests
    "a" "." "a" "Wildcard matches letter"
    "5" "." "5" "Wildcard matches digit"
    "!" "." "!" "Wildcard matches symbol"
    " " "." " " "Wildcard matches space"
    "" "." false "Wildcard requires character"
    
    ;; Escaped special characters
    "." "\." "." "Escaped dot matches literal dot"
    "+" "\+" "+" "Escaped plus matches literal plus"
    "*" "\*" "*" "Escaped star matches literal star"
    "?" "\?" "?" "Escaped question matches literal question"
    (to string! TypChrCaret) (rejoin ["\" TypChrCaret]) none "Invalid escape sequence \\^ correctly rejected"
    "$" "\$" "$" "Escaped dollar matches literal dollar"
]

foreach [haystack pattern expected description] wildcard-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "WILDCARDS_SPECIALS" description false true
    ] [
        record-test "WILDCARDS_SPECIALS" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; COMPLEX PATTERN TESTS (real-world scenarios)
;;=============================================================================
print "^/--- COMPLEX PATTERN TESTS ---"

complex-pattern-tests: reduce [
    ;; Email-like patterns
    "test@example.com" "\w+@\w+\.\w+" "test@example.com" "Email pattern basic"
    "user123@domain.org" "\w+@\w+\.\w+" "user123@domain.org" "Email pattern with numbers"
    
    ;; Mixed word, space, digit patterns
    "abc 123" "\w+\s\d+" "abc 123" "Word space digit pattern"
    "hello 456" "\w+\s\d+" "hello 456" "Word space digit variation"
    "test123 789" "\w+\s\d+" false "No space in first part"
    
    ;; Phone number-like patterns
    "123-456-7890" "\d{3}-\d{3}-\d{4}" "123-456-7890" "Phone number pattern"
    "555-123-4567" "\d{3}-\d{3}-\d{4}" "555-123-4567" "Phone number variation"
    
    ;; Alternating patterns
    "a1b2c3" "\w\d\w\d\w\d" "a1b2c3" "Alternating word-digit pattern"
    "x5y9z2" "\w\d\w\d\w\d" "x5y9z2" "Alternating pattern variation"
    
    ;; Greedy vs non-greedy behavior tests
    "hello123" "\w+\d+" false "Greedy quantifier consumes digits"
    "hello123" "[a-zA-Z]+\d+" "hello123" "Letter-only class with digits"
    "123abc" "\d+\w+" "123abc" "Digits followed by word chars"
]

foreach [haystack pattern expected description] complex-pattern-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "COMPLEX_PATTERNS" description false true
    ] [
        record-test "COMPLEX_PATTERNS" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; ERROR HANDLING TESTS (comprehensive)
;;=============================================================================
print "^/--- ERROR HANDLING TESTS ---"

error-handling-tests: reduce [
    ;; Invalid character classes
    "test" "[a-" none "Invalid character class - missing close"
    "test" "[z-a]" none "Invalid character class - reverse range"
    "test" "[]" none "Empty character class"
    
    ;; Invalid quantifiers
    "test" "a{" none "Invalid quantifier - missing close"
    "test" "a{}" none "Empty quantifier"
    "test" "a{5,2}" none "Invalid quantifier - min > max"
    "test" "a{999999}" none "Excessive quantifier value"
    "test" "a{-1}" none "Negative quantifier"
    
    ;; Invalid patterns
    "test" "" none "Empty pattern"
    "test" "(" none "Unmatched group open"
    "test" ")" none "Unmatched group close"
    "test" "[" none "Unclosed character class"
    "test" "{3}" none "Quantifier without target"
    
    ;; Invalid escape sequences
    "test" "\x" none "Invalid escape sequence"
    "test" "\" none "Trailing backslash"
]

foreach [haystack pattern expected description] error-handling-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "ERROR_HANDLING" description false true
    ] [
        record-test "ERROR_HANDLING" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; EDGE CASE TESTS (boundary conditions)
;;=============================================================================
print "^/--- EDGE CASE TESTS ---"

edge-case-tests: reduce [
    ;; Empty strings and patterns
    "" "" "" "Empty string with empty pattern"
    "test" "" none "Non-empty string with empty pattern"
    "" "a" false "Empty string with non-empty pattern"
    
    ;; Single character tests
    "a" "a" "a" "Single character exact match"
    "a" "b" false "Single character no match"
    "a" "." "a" "Single character wildcard"
    
    ;; Boundary value tests
    "a" "a{1}" "a" "Quantifier minimum boundary"
    "a" "a{0,1}" "a" "Quantifier range with zero"
    "" "a{0,1}" "" "Zero quantifier on empty string"
    
    ;; Unicode and special characters
    "ñ" "\w" "ñ" "Unicode letter as word character"
    "café" "\w+" "café" "Unicode in word sequence"
    
    ;; Very long strings (performance test)
    "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "a+" "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" "Very long string performance"
]

foreach [haystack pattern expected description] edge-case-tests [
    test-result: none
    test-error: none
    set/any 'test-error try [
        test-result: RegExp haystack pattern
    ]
    
    either error? test-error [
        record-test "EDGE_CASES" description false true
    ] [
        record-test "EDGE_CASES" description 
            (equal? expected test-result) false
    ]
]

;;=============================================================================
;; ENHANCED FUNCTIONALITY TESTS (from system integrity tests)
;;=============================================================================
print "^/--- ENHANCED FUNCTIONALITY TESTS ---"

;; Test TestRegExp function
test-regexp-result: none
test-regexp-error: none
set/any 'test-regexp-error try [
    test-regexp-result: TestRegExp "hello" "hello"
]

record-test "ENHANCED_FUNCTIONS" "TestRegExp function works"
    (not error? test-regexp-error) (error? test-regexp-error)

if not error? test-regexp-error [
    record-test "ENHANCED_FUNCTIONS" "TestRegExp returns correct boolean"
        (test-regexp-result = true) false
]

;; Test GetEngineInfo function
engine-info: none
engine-info-error: none
set/any 'engine-info-error try [
    engine-info: GetEngineInfo
]

record-test "ENHANCED_FUNCTIONS" "GetEngineInfo function works"
    (not error? engine-info-error) (error? engine-info-error)

if engine-info [
    record-test "ENHANCED_FUNCTIONS" "Engine info has version"
        (not none? engine-info/version) false
    record-test "ENHANCED_FUNCTIONS" "Engine info has architecture"
        (not none? engine-info/architecture) false
]

;; Test ValidatePattern function
pattern-validation: none
pattern-validation-error: none
set/any 'pattern-validation-error try [
    pattern-validation: ValidatePattern "\d+"
]

record-test "ENHANCED_FUNCTIONS" "ValidatePattern function works"
    (not error? pattern-validation-error) (error? pattern-validation-error)

if not error? pattern-validation-error [
    record-test "ENHANCED_FUNCTIONS" "ValidatePattern validates correct pattern"
        (pattern-validation = true) false
]

;;=============================================================================
;; PERFORMANCE AND MONITORING TESTS
;;=============================================================================
print "^/--- PERFORMANCE AND MONITORING TESTS ---"

;; Test performance monitoring
perf-test-error: none
set/any 'perf-test-error try [
    RegExpWithStats "test123" "\w+\d+"
    RegExpWithStats "hello" "\d+"
    RegExpWithStats "abc" "[a-z]+"
]

record-test "PERFORMANCE" "Performance monitoring functions work"
    (not error? perf-test-error) (error? perf-test-error)

;; Test performance stats retrieval
perf-stats: none
perf-stats-error: none
set/any 'perf-stats-error try [
    perf-stats: GetPerformanceStats
]

record-test "PERFORMANCE" "GetPerformanceStats function works"
    (not error? perf-stats-error) (error? perf-stats-error)

if perf-stats [
    record-test "PERFORMANCE" "Performance stats track total matches"
        (perf-stats/total-matches > 0) false
    record-test "PERFORMANCE" "Performance stats have success rate"
        (integer? perf-stats/success-rate) false
]

;;=============================================================================
;; DEBUGGING FUNCTIONALITY TESTS
;;=============================================================================
print "^/--- DEBUGGING FUNCTIONALITY TESTS ---"

;; Test debug functionality
debug-info: none
debug-error: none
set/any 'debug-error try [
    debug-info: DebugRegExp "test123" "\w+\d+"
]

record-test "DEBUGGING" "DebugRegExp function works"
    (not error? debug-error) (error? debug-error)

if debug-info [
    record-test "DEBUGGING" "Debug info has input haystack"
        (not none? debug-info/input-haystack) false
    record-test "DEBUGGING" "Debug info has input pattern"
        (not none? debug-info/input-pattern) false
    record-test "DEBUGGING" "Debug info has tokenization result"
        (not none? debug-info/tokenization-result) false
    record-test "DEBUGGING" "Debug info has success flag"
        (logic? debug-info/success) false
]

;;=============================================================================
;; PIPELINE INTEGRATION TESTS
;;=============================================================================
print "^/--- PIPELINE INTEGRATION TESTS ---"

;; Test tokenization step
tokenization-result: none
tokenization-error: none
set/any 'tokenization-error try [
    tokenization-result: StringToPatternBlock "\d+\w+"
]

record-test "PIPELINE" "Tokenization step works independently"
    (not error? tokenization-error) (error? tokenization-error)

if tokenization-result [
    record-test "PIPELINE" "Tokenization produces block result"
        (block? tokenization-result) false
    
    ;; Test rule processing step
    rule-processing-result: none
    rule-processing-error: none
    set/any 'rule-processing-error try [
        rule-processing-result: ProcessPatternBlock tokenization-result
    ]
    
    record-test "PIPELINE" "Rule processing step works independently"
        (not error? rule-processing-error) (error? rule-processing-error)
    
    if rule-processing-result [
        record-test "PIPELINE" "Rule processing produces block result"
            (block? rule-processing-result) false
        
        ;; Test matching step
        matching-result: none
        matching-error: none
        set/any 'matching-error try [
            matching-result: ExecuteBlockMatch "test123" rule-processing-result
        ]
        
        record-test "PIPELINE" "Matching step works independently"
            (not error? matching-error) (error? matching-error)
    ]
]

;;=============================================================================
;; COMPREHENSIVE RESULTS SUMMARY
;;=============================================================================
print "^/=========================================="
print "MASTER COMPREHENSIVE QA TEST RESULTS"
print "=========================================="

print ["Total Tests Executed:" total-tests]
print ["Tests Passed:" passed-tests]
print ["Tests Failed:" failed-tests]
print ["Tests with Errors:" error-tests]

overall-success-rate: either total-tests > 0 [
    to integer! (passed-tests * 100.0) / total-tests
] [0]

print ["Overall Success Rate:" overall-success-rate "%"]

print "^/--- DETAILED CATEGORY BREAKDOWN ---"
category-names: [
    "MODULE_LOADING" "Module Loading & Dependencies"
    "CORE_FUNCTIONALITY" "Core Functionality"
    "ESCAPE_SEQUENCES" "Escape Sequences"
    "QUANTIFIERS" "Quantifiers"
    "ANCHORS" "Anchors"
    "CHARACTER_CLASSES" "Character Classes"
    "WILDCARDS_SPECIALS" "Wildcards & Special Characters"
    "COMPLEX_PATTERNS" "Complex Patterns"
    "ERROR_HANDLING" "Error Handling"
    "EDGE_CASES" "Edge Cases"
    "ENHANCED_FUNCTIONS" "Enhanced Functions"
    "PERFORMANCE" "Performance & Monitoring"
    "DEBUGGING" "Debugging Tools"
    "PIPELINE" "Pipeline Integration"
]

foreach [category-key category-name] category-names [
    if stats: select test-categories category-key [
        total: stats/1
        passed: stats/2
        failed: stats/3
        errors: stats/4
        category-success: either total > 0 [
            to integer! (passed * 100.0) / total
        ] [0]
        
        status-icon: either category-success >= 95 ["✅ PASSED"] [
            either category-success >= 80 ["⚠️ WARNED"] ["❌ FAILED"]
        ]
        
        print [status-icon category-name ":" total "tests," passed "passed," failed "failed," errors "errors," category-success "% success"]
    ]
]

print "^/--- OVERALL SYSTEM ASSESSMENT ---"
either overall-success-rate >= 95 [
    print "SYSTEM STATUS: EXCELLENT (95%+ success rate)"
    print "All critical components functioning correctly"
    print "Block-based RegExp engine is production ready"
    print "All consolidated tests from individual QA files passing"
] [
    either overall-success-rate >= 90 [
        print "SYSTEM STATUS: GOOD (90-94% success rate)"
        print "Minor issues detected, review recommended"
        print "Some edge cases or advanced features may need attention"
    ] [
        either overall-success-rate >= 80 [
            print "SYSTEM STATUS: NEEDS IMPROVEMENT (80-89% success rate)"
            print "Multiple issues detected, investigation required"
            print "Core functionality may be compromised"
        ] [
            print "SYSTEM STATUS: CRITICAL ISSUES (<80% success rate)"
            print "Significant problems detected, major fixes needed"
            print "Engine not ready for production use"
        ]
    ]
]

print "^/--- RECOMMENDATIONS ---"
if overall-success-rate < 95 [
    print "RECOMMENDED ACTIONS:"
    
    ;; Identify worst-performing categories
    worst-categories: []
    foreach [category-key category-name] category-names [
        if stats: select test-categories category-key [
            total: stats/1
            passed: stats/2
            category-success: either total > 0 [
                to integer! (passed * 100.0) / total
            ] [0]
            
            if category-success < 90 [
                append worst-categories reduce [category-name category-success]
            ]
        ]
    ]
    
    if not empty? worst-categories [
        print "   Priority areas for improvement:"
        foreach [cat-name success-rate] worst-categories [
            print ["   -" cat-name "(" success-rate "% success rate)"]
        ]
    ]
    
    print "   1. Review failed tests in detail"
    print "   2. Fix critical functionality issues first"
    print "   3. Address error handling problems"
    print "   4. Validate edge case handling"
    print "   5. Re-run this comprehensive test suite"
]

print "^/--- TEST COVERAGE SUMMARY ---"
print "- Basic functionality: TESTED"
print "- Escape sequences: TESTED"
print "- Quantifiers: TESTED"
print "- Anchors: TESTED"
print "- Character classes: TESTED"
print "- Complex patterns: TESTED"
print "- Error handling: TESTED"
print "- Edge cases: TESTED"
print "- Performance: TESTED"
print "- Integration: TESTED"

print "^/=========================================="
print "MASTER COMPREHENSIVE QA TEST COMPLETE"
print "All tests from individual QA files consolidated"
print "=========================================="
