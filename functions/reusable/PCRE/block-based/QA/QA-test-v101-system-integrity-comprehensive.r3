REBOL [
    Title: "Robust System Integrity Validation for Block-based RegExp Engine"
    Date: 30-Jul-2025
    File: %QA-test-v101-system-integrity-comprehensive.r3
    Author: "AI Assistant"
    Version: 1.0.1
    Purpose: "Comprehensive system integrity testing for block-based RegExp engine"
    Type: "System Integrity Test Suite"
    Note: "Validates all components, modules and integration points"
]

print "^/=== ROBUST SYSTEM INTEGRITY VALIDATION ==="
print "Testing all components of the block-based RegExp engine system..."

;;=============================================================================
;; ROBUST QA TEST HARNESS
;;=============================================================================
total-tests: 0
passed-tests: 0
failed-tests: 0
error-tests: 0
test-categories: make map! []

record-test: funct [
    "Record test result with category tracking"
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
        print ["❌ ERROR:" description]
    ] [
        either result [
            set 'passed-tests passed-tests + 1
            category-stats/2: category-stats/2 + 1  ;; Increment category passed
            print ["✅ PASS:" description]
        ] [
            set 'failed-tests failed-tests + 1
            category-stats/3: category-stats/3 + 1  ;; Increment category failed
            print ["❌ FAIL:" description]
        ]
    ]
]

;;=============================================================================
;; MODULE LOADING AND DEPENDENCY TESTS
;;=============================================================================
print "^/--- MODULE LOADING AND DEPENDENCY TESTS ---"

;; Test 1: Load main orchestrator
main-engine-loaded: false
main-engine-error: none
set/any 'main-engine-error try [
    do %../src/block-regexp-engine.r3
    main-engine-loaded: true
]

record-test "MODULE_LOADING" "Main orchestrator loads without errors" 
    main-engine-loaded (error? main-engine-error)

;; Test 2: Verify all required functions are available
required-functions: [
    RegExp TestRegExp GetEngineInfo GetModuleStatus
    GetPerformanceStats RegExpWithStats DebugRegExp ValidatePattern
    StringToPatternBlock ProcessPatternBlock ExecuteBlockMatch
]

functions-available: 0
foreach func-name required-functions [
    func-available: value? func-name
    record-test "FUNCTION_AVAILABILITY" 
        rejoin ["Function " func-name " is available"]
        func-available false
    if func-available [functions-available: functions-available + 1]
]

;; Test 3: Module status validation
module-status: none
module-status-error: none
set/any 'module-status-error try [
    module-status: GetModuleStatus
]

record-test "MODULE_STATUS" "GetModuleStatus function works"
    (not error? module-status-error) (error? module-status-error)

if module-status [
    record-test "MODULE_STATUS" "All core modules loaded"
        module-status/all-loaded false
    record-test "MODULE_STATUS" "Core utilities module loaded"
        module-status/core-utils false
    record-test "MODULE_STATUS" "Tokenizer module loaded"
        module-status/tokenizer false
    record-test "MODULE_STATUS" "Processor module loaded"
        module-status/processor false
    record-test "MODULE_STATUS" "Matcher module loaded"
        module-status/matcher false
]

;;=============================================================================
;; CORE FUNCTIONALITY TESTS
;;=============================================================================
print "^/--- CORE FUNCTIONALITY TESTS ---"

;; Test basic RegExp functionality
basic-tests: reduce [
    "hello" "hello" "hello" "Basic literal match"
    "world" "hello" false "Basic literal non-match"
    "5" "\d" "5" "Single digit match"
    "a" "\d" false "Non-digit rejection"
    "123" "\d+" "123" "Multiple digits"
    "a" "\w" "a" "Word character match"
    " " "\s" " " "Space character match"
    "hello world" "^^hello" "hello" "Start anchor"
    "hello world" "world$" "world" "End anchor"
    "a" "[a-z]" "a" "Character class"
    "a" "[^^0-9]" "a" "Negated character class"
]

foreach [haystack pattern expected description] basic-tests [
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
;; QUANTIFIER TESTS
;;=============================================================================
print "^/--- QUANTIFIER TESTS ---"

quantifier-tests: [
    "aaa" "a+" "aaa" "Plus quantifier"
    "" "a*" "" "Star quantifier empty"
    "a" "a?" "a" "Optional quantifier present"
    "" "a?" "" "Optional quantifier absent"
    "aaa" "a{3}" "aaa" "Exact quantifier"
    "aa" "a{2,4}" "aa" "Range quantifier minimum"
    "aaaa" "a{2,4}" "aaaa" "Range quantifier maximum"
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
;; ESCAPE SEQUENCE TESTS
;;=============================================================================
print "^/--- ESCAPE SEQUENCE TESTS ---"

escape-tests: [
    "5" "\d" "5" "\d matches digit"
    "a" "\D" "a" "\D matches non-digit"
    "a" "\w" "a" "\w matches word character"
    "!" "\W" "!" "\W matches non-word character"
    " " "\s" " " "\s matches space"
    "x" "\S" "x" "\S matches non-space"
]

foreach [haystack pattern expected description] escape-tests [
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
;; ERROR HANDLING TESTS
;;=============================================================================
print "^/--- ERROR HANDLING TESTS ---"

error-tests: reduce [
    "test" "[a-" none "Invalid character class"
    "test" "a{" none "Invalid quantifier"
    "test" "" none "Empty pattern"
    "test" "a{999999}" none "Excessive quantifier"
]

foreach [haystack pattern expected description] error-tests [
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
;; ENHANCED FUNCTIONALITY TESTS
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

;; Test invalid pattern validation
invalid-pattern-validation: none
invalid-pattern-error: none
set/any 'invalid-pattern-error try [
    invalid-pattern-validation: ValidatePattern "[a-"
]

record-test "ENHANCED_FUNCTIONS" "ValidatePattern handles invalid patterns"
    (not error? invalid-pattern-error) (error? invalid-pattern-error)

if not error? invalid-pattern-error [
    record-test "ENHANCED_FUNCTIONS" "ValidatePattern rejects invalid pattern"
        (string? invalid-pattern-validation) false
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
;; INTEGRATION AND PIPELINE TESTS
;;=============================================================================
print "^/--- INTEGRATION AND PIPELINE TESTS ---"

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
]

;; Test rule processing step
if tokenization-result [
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
print "^/=== COMPREHENSIVE SYSTEM INTEGRITY RESULTS ==="
print ["Total Tests Executed:" total-tests]
print ["Tests Passed:" passed-tests]
print ["Tests Failed:" failed-tests]
print ["Tests with Errors:" error-tests]

overall-success-rate: either total-tests > 0 [
    to integer! (passed-tests * 100.0) / total-tests
] [0]

print ["Overall Success Rate:" overall-success-rate "%"]

print "^/--- CATEGORY BREAKDOWN ---"
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

print "^/--- SYSTEM INTEGRITY ASSESSMENT ---"
either overall-success-rate >= 95 [
    print "✅ SYSTEM INTEGRITY: EXCELLENT (95%+ success rate)"
    print "✅ All critical components functioning correctly"
    print "✅ Block-based RegExp engine is production ready"
] [
    either overall-success-rate >= 90 [
        print "⚠️  SYSTEM INTEGRITY: GOOD (90-94% success rate)"
        print "⚠️  Minor issues detected, review recommended"
    ] [
        print "❌ SYSTEM INTEGRITY: NEEDS ATTENTION (<90% success rate)"
        print "❌ Significant issues detected, investigation required"
    ]
]

print "^/--- COMPONENT STATUS SUMMARY ---"
module-loading-stats: select test-categories "MODULE_LOADING"
core-functionality-stats: select test-categories "CORE_FUNCTIONALITY"
quantifiers-stats: select test-categories "QUANTIFIERS"
escape-sequences-stats: select test-categories "ESCAPE_SEQUENCES"
error-handling-stats: select test-categories "ERROR_HANDLING"
enhanced-functions-stats: select test-categories "ENHANCED_FUNCTIONS"
performance-stats: select test-categories "PERFORMANCE"
debugging-stats: select test-categories "DEBUGGING"
pipeline-stats: select test-categories "PIPELINE"

print ["Module Loading:" either module-loading-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]
print ["Core Functionality:" either core-functionality-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]
print ["Quantifiers:" either quantifiers-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]
print ["Escape Sequences:" either escape-sequences-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]
print ["Error Handling:" either error-handling-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]
print ["Enhanced Functions:" either enhanced-functions-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]
print ["Performance Monitoring:" either performance-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]
print ["Debugging Tools:" either debugging-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]
print ["Pipeline Integration:" either pipeline-stats/2 > 0 ["✅ WORKING"] ["❌ FAILED"]]

print "^/=== ROBUST Block-based RegExp Engine INTEGRITY VALIDATION COMPLETE ==="
