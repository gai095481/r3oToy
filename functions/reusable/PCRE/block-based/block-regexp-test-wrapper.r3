REBOL [
    Title: "REBOL 3 Block-Based Regular Expressions Engine - Test Wrapper Module"
    Date: 20-Jul-2025
    File: %block-regexp-test-wrapper.r3
    Author: "AI Assistant"
    Version: "2.0.0"
    Purpose: "Comprehensive test wrapper with enhanced block validation and performance comparison"
    Note: "Provides testing utilities, benchmarking, and validation for block-based RegExp engine"
    Exports: [TestBlockRegExp BenchmarkBlockVsString ValidateBlockTokens]
    Dependencies: [
        %block-regexp-engine.r3
    ]
]

;;=============================================================================
;; AUTOMATIC DEPENDENCY LOADING
;;=============================================================================
;; Load main block-based engine module
engine-loaded: false
engine-error: none
set/any 'engine-error try [
    do %block-regexp-engine.r3
    engine-loaded: true
]

if not engine-loaded [
    print "^/ERROR: Failed to load block-regexp-engine.r3"
    if error? engine-error [
        print ["Error details:" mold engine-error]
    ]
    exit
]

;;=============================================================================
;; ENHANCED BLOCK VALIDATION TESTING
;;=============================================================================

TestBlockRegExp: funct [
    "Enhanced RegExp testing with block validation and detailed reporting"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    return: [object!] "Detailed test result object"
] [
    ;; Initialize result object
    test-result: make object! [
        haystack: strHaystack
        pattern: strRegExp
        match-result: none
        match-found: false
        execution-time: none
        tokenization-successful: false
        rule-generation-successful: false
        matching-successful: false
        tokens: none
        rules: none
        error-occurred: false
        error-message: none
        result-type: none
        performance-stats: none
    ]
    
    ;; Record start time
    start-time: now/time
    
    ;; Execute RegExp with comprehensive error handling
    regexp-error: none
    set/any 'regexp-error try [
        test-result/match-result: RegExp strHaystack strRegExp
    ]
    
    ;; Record execution time
    test-result/execution-time: now/time - start-time
    
    ;; Analyze results
    either error? regexp-error [
        test-result/error-occurred: true
        test-result/error-message: mold regexp-error
        test-result/result-type: 'error
    ] [
        test-result/match-found: not none? test-result/match-result
        test-result/result-type: either none? test-result/match-result [
            'no-match
        ] [
            either string? test-result/match-result [
                'string-match
            ] [
                'boolean-match
            ]
        ]
    ]
    
    ;; Get detailed pipeline information using debug function
    debug-info: none
    debug-error: none
    set/any 'debug-error try [
        debug-info: DebugRegExp strHaystack strRegExp
    ]
    
    if not error? debug-error [
        test-result/tokenization-successful: not error? debug-info/tokenization-result
        test-result/rule-generation-successful: not error? debug-info/rule-generation-result
        test-result/matching-successful: not error? debug-info/matching-result
        test-result/tokens: debug-info/tokenization-result
        test-result/rules: debug-info/rule-generation-result
    ]
    
    ;; Get performance statistics
    perf-error: none
    set/any 'perf-error try [
        test-result/performance-stats: GetPerformanceStats
    ]
    
    test-result
]

;;=============================================================================
;; PERFORMANCE BENCHMARKING
;;=============================================================================

BenchmarkBlockVsString: funct [
    "Comprehensive performance comparison between block-based and string-based processing"
    test-patterns [block!] "Block of [haystack pattern description] test cases"
    iterations [integer!] "Number of iterations for each test"
    return: [object!] "Benchmark results object"
] [
    ;; Initialize benchmark results
    benchmark-results: make object! [
        total-tests: 0
        iterations-per-test: iterations
        block-engine-times: copy []
        string-engine-times: copy []
        block-total-time: 0:00:00
        string-total-time: 0:00:00
        block-average-time: 0:00:00
        string-average-time: 0:00:00
        performance-improvement: 0.0
        block-successes: 0
        string-successes: 0
        block-failures: 0
        string-failures: 0
        test-details: copy []
    ]
    
    ;; Load string-based engine for comparison (if available)
    string-engine-available: false
    string-engine-error: none
    set/any 'string-engine-error try [
        ;; Try to load a string-based engine for comparison
        ;; This would be the original regexp-engine.r3 if available
        if exists? %src/regexp-engine.r3 [
            ;; Save current RegExp function
            block-regexp: :RegExp
            
            ;; Load string-based engine
            do %src/regexp-engine.r3
            string-regexp: :RegExp
            
            ;; Restore block-based RegExp
            RegExp: :block-regexp
            string-engine-available: true
        ]
    ]
    
    ;; Process each test pattern
    foreach [haystack pattern description] test-patterns [
        benchmark-results/total-tests: benchmark-results/total-tests + 1
        
        ;; Initialize test detail record
        test-detail: make object! [
            description: description
            haystack: haystack
            pattern: pattern
            block-time: 0:00:00
            string-time: 0:00:00
            block-result: none
            string-result: none
            block-success: false
            string-success: false
            improvement-factor: 0.0
        ]
        
        ;; Benchmark block-based engine
        block-start: now/time
        block-error: none
        repeat i iterations [
            set/any 'block-error try [
                test-detail/block-result: RegExp haystack pattern
            ]
        ]
        test-detail/block-time: now/time - block-start
        test-detail/block-success: not error? block-error
        
        either test-detail/block-success [
            benchmark-results/block-successes: benchmark-results/block-successes + 1
        ] [
            benchmark-results/block-failures: benchmark-results/block-failures + 1
        ]
        
        ;; Benchmark string-based engine (if available)
        if string-engine-available [
            string-start: now/time
            string-error: none
            repeat i iterations [
                set/any 'string-error try [
                    test-detail/string-result: string-regexp haystack pattern
                ]
            ]
            test-detail/string-time: now/time - string-start
            test-detail/string-success: not error? string-error
            
            if test-detail/string-success [
                benchmark-results/string-successes: benchmark-results/string-successes + 1
            ] else [
                benchmark-results/string-failures: benchmark-results/string-failures + 1
            ]
            
            ;; Calculate improvement factor
            if test-detail/string-time > 0:00:00 [
                string-seconds: (test-detail/string-time/hour * 3600) + 
                               (test-detail/string-time/minute * 60) + 
                               test-detail/string-time/second
                block-seconds: (test-detail/block-time/hour * 3600) + 
                              (test-detail/block-time/minute * 60) + 
                              test-detail/block-time/second
                
                if block-seconds > 0 [
                    test-detail/improvement-factor: string-seconds / block-seconds
                ]
            ]
        ] else [
            ;; No string engine available - use block engine time as baseline
            test-detail/string-time: test-detail/block-time
            test-detail/string-result: test-detail/block-result
            test-detail/string-success: test-detail/block-success
            test-detail/improvement-factor: 1.0
        ]
        
        ;; Add to benchmark results
        append benchmark-results/block-engine-times test-detail/block-time
        append benchmark-results/string-engine-times test-detail/string-time
        benchmark-results/block-total-time: benchmark-results/block-total-time + test-detail/block-time
        benchmark-results/string-total-time: benchmark-results/string-total-time + test-detail/string-time
        append benchmark-results/test-details test-detail
    ]
    
    ;; Calculate averages
    if benchmark-results/total-tests > 0 [
        total-block-seconds: (benchmark-results/block-total-time/hour * 3600) + 
                            (benchmark-results/block-total-time/minute * 60) + 
                            benchmark-results/block-total-time/second
        total-string-seconds: (benchmark-results/string-total-time/hour * 3600) + 
                             (benchmark-results/string-total-time/minute * 60) + 
                             benchmark-results/string-total-time/second
        
        avg-block-seconds: total-block-seconds / benchmark-results/total-tests
        avg-string-seconds: total-string-seconds / benchmark-results/total-tests
        
        benchmark-results/block-average-time: to time! avg-block-seconds
        benchmark-results/string-average-time: to time! avg-string-seconds
        
        ;; Calculate overall performance improvement
        if avg-block-seconds > 0 [
            benchmark-results/performance-improvement: avg-string-seconds / avg-block-seconds
        ]
    ]
    
    benchmark-results
]

;;=============================================================================
;; BLOCK TOKEN VALIDATION
;;=============================================================================

ValidateBlockTokens: funct [
    "Comprehensive validation of block token sequences and semantic accuracy"
    strRegExp [string!] "Regular expression pattern to validate"
    return: [object!] "Validation result object"
] [
    ;; Initialize validation result
    validation-result: make object! [
        pattern: strRegExp
        tokenization-successful: false
        tokens: none
        token-count: 0
        token-types: copy []
        semantic-accuracy: 'unknown
        validation-errors: copy []
        rule-generation-successful: false
        rules: none
        rule-count: 0
        overall-valid: false
        performance-metrics: none
    ]
    
    ;; Step 1: Tokenization validation
    tokenization-error: none
    set/any 'tokenization-error try [
        validation-result/tokens: StringToPatternBlock strRegExp
    ]
    
    either error? tokenization-error [
        append validation-result/validation-errors "Tokenization failed with error"
        validation-result/tokenization-successful: false
    ] [
        validation-result/tokenization-successful: true
        
        ;; Check for error tokens
        if all [
            block? validation-result/tokens
            not empty? validation-result/tokens
            validation-result/tokens/1 = 'error
        ] [
            append validation-result/validation-errors "Tokenization produced error token"
            validation-result/tokenization-successful: false
        ]
    ]
    
    ;; Analyze tokens if tokenization was successful
    if validation-result/tokenization-successful [
        validation-result/token-count: length? validation-result/tokens
        
        ;; Extract token types
        foreach token validation-result/tokens [
            token-type: either block? token [
                either empty? token ['empty-token] [token/1]
            ] [
                token
            ]
            
            if not find validation-result/token-types token-type [
                append validation-result/token-types token-type
            ]
        ]
        
        ;; Validate token sequence using core utilities
        sequence-validation: none
        sequence-error: none
        set/any 'sequence-error try [
            sequence-validation: ValidateTokenSequence validation-result/tokens
        ]
        
        either error? sequence-error [
            append validation-result/validation-errors "Token sequence validation failed"
        ] [
            either sequence-validation = true [
                validation-result/semantic-accuracy: 'valid
            ] [
                validation-result/semantic-accuracy: 'invalid
                append validation-result/validation-errors sequence-validation
            ]
        ]
    ]
    
    ;; Step 2: Rule generation validation
    if validation-result/tokenization-successful [
        rule-generation-error: none
        set/any 'rule-generation-error try [
            validation-result/rules: ProcessPatternBlock validation-result/tokens
        ]
        
        either error? rule-generation-error [
            append validation-result/validation-errors "Rule generation failed with error"
            validation-result/rule-generation-successful: false
        ] [
            validation-result/rule-generation-successful: true
            
            ;; Check for error markers in rules
            if all [
                block? validation-result/rules
                not empty? validation-result/rules
                validation-result/rules/1 = 'error
            ] [
                append validation-result/validation-errors "Rule generation produced error marker"
                validation-result/rule-generation-successful: false
            ] else [
                validation-result/rule-count: length? validation-result/rules
            ]
        ]
    ]
    
    ;; Step 3: Performance metrics
    perf-start: now/time
    test-match: none
    perf-error: none
    set/any 'perf-error try [
        test-match: RegExp "test" strRegExp
    ]
    perf-time: now/time - perf-start
    
    validation-result/performance-metrics: make object! [
        validation-time: perf-time
        test-match-successful: not error? perf-error
        test-match-result: test-match
    ]
    
    ;; Overall validation assessment
    validation-result/overall-valid: all [
        validation-result/tokenization-successful
        validation-result/semantic-accuracy = 'valid
        validation-result/rule-generation-successful
        empty? validation-result/validation-errors
    ]
    
    validation-result
]

;;=============================================================================
;; UTILITY FUNCTIONS FOR TESTING
;;=============================================================================

PrintTestResult: funct [
    "Print formatted test result from TestBlockRegExp"
    test-result [object!] "Test result object"
] [
    print ["^/=== TEST RESULT FOR:" test-result/pattern "==="]
    print ["Haystack:" mold test-result/haystack]
    print ["Pattern:" mold test-result/pattern]
    print ["Match Found:" test-result/match-found]
    print ["Match Result:" mold test-result/match-result]
    print ["Result Type:" test-result/result-type]
    print ["Execution Time:" test-result/execution-time]
    
    if test-result/error-occurred [
        print ["ERROR:" test-result/error-message]
    ]
    
    print ["Tokenization Successful:" test-result/tokenization-successful]
    print ["Rule Generation Successful:" test-result/rule-generation-successful]
    print ["Matching Successful:" test-result/matching-successful]
    
    if test-result/tokens [
        print ["Token Count:" length? test-result/tokens]
    ]
    
    if test-result/rules [
        print ["Rule Count:" length? test-result/rules]
    ]
]

PrintBenchmarkResults: funct [
    "Print formatted benchmark results from BenchmarkBlockVsString"
    benchmark-results [object!] "Benchmark results object"
] [
    print "^/=== PERFORMANCE BENCHMARK RESULTS ==="
    print ["Total Tests:" benchmark-results/total-tests]
    print ["Iterations per Test:" benchmark-results/iterations-per-test]
    print ["Block Engine Successes:" benchmark-results/block-successes]
    print ["Block Engine Failures:" benchmark-results/block-failures]
    print ["String Engine Successes:" benchmark-results/string-successes]
    print ["String Engine Failures:" benchmark-results/string-failures]
    
    print "^/--- TIMING RESULTS ---"
    print ["Block Engine Total Time:" benchmark-results/block-total-time]
    print ["String Engine Total Time:" benchmark-results/string-total-time]
    print ["Block Engine Average Time:" benchmark-results/block-average-time]
    print ["String Engine Average Time:" benchmark-results/string-average-time]
    print ["Performance Improvement Factor:" benchmark-results/performance-improvement]
    
    if benchmark-results/performance-improvement > 1.0 [
        print ["✅ Block engine is" benchmark-results/performance-improvement "times faster"]
    ] else [
        print ["⚠️  Block engine performance needs optimization"]
    ]
]

PrintValidationResult: funct [
    "Print formatted validation result from ValidateBlockTokens"
    validation-result [object!] "Validation result object"
] [
    print ["^/=== TOKEN VALIDATION RESULT FOR:" validation-result/pattern "==="]
    print ["Tokenization Successful:" validation-result/tokenization-successful]
    print ["Token Count:" validation-result/token-count]
    print ["Token Types:" mold validation-result/token-types]
    print ["Semantic Accuracy:" validation-result/semantic-accuracy]
    print ["Rule Generation Successful:" validation-result/rule-generation-successful]
    print ["Rule Count:" validation-result/rule-count]
    print ["Overall Valid:" validation-result/overall-valid]
    
    if not empty? validation-result/validation-errors [
        print "^/--- VALIDATION ERRORS ---"
        foreach error validation-result/validation-errors [
            print ["  ERROR:" error]
        ]
    ]
    
    if validation-result/performance-metrics [
        print ["Validation Time:" validation-result/performance-metrics/validation-time]
        print ["Test Match Successful:" validation-result/performance-metrics/test-match-successful]
    ]
]

;;=============================================================================
;; MODULE STATUS REPORTING
;;=============================================================================

ReportTestWrapperStatus: funct [
    "Report the status of the test wrapper module"
] [
    print "^/=== BLOCK REGEXP TEST WRAPPER MODULE STATUS ==="
    print ["Main Engine Loaded:" either engine-loaded ["✅ LOADED"] ["❌ FAILED"]]
    
    if not engine-loaded [
        print ["Engine Loading Error:" mold engine-error]
    ]
    
    ;; Test function availability
    functions-available: [
        TestBlockRegExp BenchmarkBlockVsString ValidateBlockTokens
        PrintTestResult PrintBenchmarkResults PrintValidationResult
    ]
    
    print "^/--- FUNCTION AVAILABILITY ---"
    foreach func-name functions-available [
        func-available: value? func-name
        print [func-name ":" either func-available ["✅ AVAILABLE"] ["❌ MISSING"]]
    ]
    
    print "^/--- MODULE CAPABILITIES ---"
    print "✅ Enhanced block validation testing"
    print "✅ Performance benchmarking (block vs string)"
    print "✅ Comprehensive token sequence validation"
    print "✅ Detailed test result reporting"
    print "✅ Error analysis and diagnostics"
    
    print "^/=== TEST WRAPPER MODULE READY ==="
]

;;=============================================================================
;; BACKWARD COMPATIBILITY DOCUMENTATION
;;=============================================================================

comment {
BLOCK REGEXP TEST WRAPPER MODULE - VERSION 1.0.0

Enhanced testing utilities for block-based RegExp engine:

MAIN FUNCTIONS:
- TestBlockRegExp: Enhanced testing with detailed pipeline analysis
- BenchmarkBlockVsString: Performance comparison between engines
- ValidateBlockTokens: Comprehensive token sequence validation

UTILITY FUNCTIONS:
- PrintTestResult: Formatted test result display
- PrintBenchmarkResults: Formatted benchmark result display
- PrintValidationResult: Formatted validation result display

FEATURES:
- Detailed error analysis and reporting
- Performance metrics and timing analysis
- Token-level validation and semantic accuracy checking
- Pipeline step-by-step analysis (tokenization → rules → matching)
- Comprehensive benchmark comparison capabilities
}

;; Report module status on load
ReportTestWrapperStatus
