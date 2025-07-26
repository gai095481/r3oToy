REBOL [
    Title: "REBOL 3 Regular Expressions Engine - Test Wrapper Module"
    Date: 20-Jul-2025
    File: %regexp-test-wrapper.r3
    Author: "Enhanced by Kiro AI Assistant"
    Version: "2.0.0"
    Purpose: "Testing utilities and wrapper functions for RegExp engine"
    Note: "Extracted from monolithic regexp-engine.r3 for better maintainability"
]

;;=============================================================================
;; LOAD DEPENDENCIES
;;=============================================================================

;; Load the modular RegExp engine (which loads all dependencies)
do %regexp-engine-modular.r3

;;=============================================================================
;; BASIC TEST WRAPPER FUNCTION
;;=============================================================================

TestRegExp: funct [
    "Test the regular expression engine - returns true/false for match success"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    return: [logic!] "True if pattern matches, false otherwise"
][
    match-result: RegExp strHaystack strRegExp
    
    ;; Return logic! value (true/false) for successful matches only
    ;; true = successful match (string returned)
    ;; false = no match (false returned) or error (none returned)
    string? match-result
]

;;=============================================================================
;; ENHANCED TESTING UTILITIES
;;=============================================================================

TestRegExpDetailed: funct [
    "Test RegExp with detailed result information"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    return: [object!] "Detailed test result object"
][
    result: make object! [
        haystack: strHaystack
        pattern: strRegExp
        match-result: none
        match-found: false
        match-string: none
        result-type: none
        error-occurred: false
        error-details: none
    ]
    
    ;; Execute the RegExp function with error handling
    set/any 'result/match-result try [
        RegExp strHaystack strRegExp
    ]
    
    ;; Analyze the result
    either error? result/match-result [
        result/error-occurred: true
        result/error-details: result/match-result
        result/result-type: 'error
    ] [
        result/result-type: type? result/match-result
        either string? result/match-result [
            result/match-found: true
            result/match-string: result/match-result
        ] [
            result/match-found: false
        ]
    ]
    
    result
]

RunTestSuite: funct [
    "Run a test suite with multiple test cases"
    test-cases [block!] "Block of test cases in format [haystack pattern description ...]"
    return: [object!] "Test suite results"
][
    results: make object! [
        total-tests: 0
        passed-tests: 0
        failed-tests: 0
        error-tests: 0
        test-details: copy []
        success-rate: 0
    ]
    
    ;; Calculate total tests
    results/total-tests: (length? test-cases) / 3
    
    ;; Run each test
    repeat i results/total-tests [
        haystack: test-cases/(i * 3 - 2)
        pattern: test-cases/(i * 3 - 1)
        description: test-cases/(i * 3)
        
        ;; Run detailed test
        test-result: TestRegExpDetailed haystack pattern
        ;; Add description to the result object
        test-result: make test-result [description: description]
        
        ;; Categorize result
        either test-result/error-occurred [
            results/error-tests: results/error-tests + 1
        ] [
            either test-result/match-found [
                results/passed-tests: results/passed-tests + 1
            ] [
                results/failed-tests: results/failed-tests + 1
            ]
        ]
        
        ;; Store test details
        append results/test-details test-result
    ]
    
    ;; Calculate success rate
    if results/total-tests > 0 [
        results/success-rate: to integer! (results/passed-tests * 100) / results/total-tests
    ]
    
    results
]

PrintTestResults: funct [
    "Print formatted test results from RunTestSuite"
    results [object!] "Results object from RunTestSuite"
][
    print "^/=== TEST SUITE RESULTS ==="
    print ["Total tests:" results/total-tests]
    print ["Passed:" results/passed-tests]
    print ["Failed:" results/failed-tests]
    print ["Errors:" results/error-tests]
    print ["Success rate:" results/success-rate "%"]
    
    print "^/=== DETAILED RESULTS ==="
    foreach test-detail results/test-details [
        status: either test-detail/error-occurred [
            "ERROR"
        ] [
            either test-detail/match-found ["PASS"] ["FAIL"]
        ]
        
        print ["  " status ":" test-detail/description]
        print ["    Input: '" test-detail/haystack "' with pattern '" test-detail/pattern "'"]
        
        either test-detail/error-occurred [
            print ["    Error:" test-detail/error-details]
        ] [
            either test-detail/match-found [
                print ["    Match: '" test-detail/match-string "'"]
            ] [
                print ["    Result: No match (" test-detail/result-type ")"]
            ]
        ]
        print ""
    ]
]

;;=============================================================================
;; COMPATIBILITY TESTING UTILITIES
;;=============================================================================

TestBackwardCompatibility: funct [
    "Test that modular engine maintains backward compatibility"
    return: [logic!] "True if all compatibility tests pass"
][
    compatibility-tests: [
        "123" "\d{3}" "exact quantifier match"
        "12" "\d{3}" "exact quantifier too short"
        "abc123" "\w+\d+" "mixed pattern"
        "hello" "hello" "literal match"
        "test" "\d+" "no match case"
    ]
    
    results: RunTestSuite compatibility-tests
    
    print "^/=== BACKWARD COMPATIBILITY TEST ==="
    PrintTestResults results
    
    ;; Return true if success rate is high and no errors
    all [
        results/success-rate >= 80
        results/error-tests = 0
    ]
]

;;=============================================================================
;; PERFORMANCE TESTING UTILITIES
;;=============================================================================

BenchmarkRegExp: funct [
    "Benchmark RegExp performance with timing"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    iterations [integer!] "Number of iterations to run"
    return: [object!] "Benchmark results"
][
    benchmark: make object! [
        pattern: strRegExp
        haystack: strHaystack
        iterations: iterations
        total-time: 0
        average-time: 0
        successful-matches: 0
        errors: 0
    ]
    
    ;; Run benchmark
    start-time: now/precise
    
    repeat i iterations [
        result: none
        set/any 'result try [
            RegExp strHaystack strRegExp
        ]
        
        either error? result [
            benchmark/errors: benchmark/errors + 1
        ] [
            if string? result [
                benchmark/successful-matches: benchmark/successful-matches + 1
            ]
        ]
    ]
    
    end-time: now/precise
    benchmark/total-time: to decimal! difference end-time start-time
    benchmark/average-time: benchmark/total-time / iterations
    
    benchmark
]

PrintBenchmarkResults: funct [
    "Print formatted benchmark results"
    benchmark [object!] "Benchmark results from BenchmarkRegExp"
][
    print "^/=== BENCHMARK RESULTS ==="
    print ["Pattern:" benchmark/pattern]
    print ["Haystack:" benchmark/haystack]
    print ["Iterations:" benchmark/iterations]
    print ["Total time:" benchmark/total-time "seconds"]
    print ["Average time:" benchmark/average-time "seconds per match"]
    print ["Successful matches:" benchmark/successful-matches]
    print ["Errors:" benchmark/errors]
    
    if all [benchmark/iterations benchmark/iterations > 0] [
        success-rate: to integer! (benchmark/successful-matches * 100) / benchmark/iterations
        print ["Success rate:" success-rate "%"]
    ]
]
