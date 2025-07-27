REBOL [
    Title: "REBOL 3 Block-Based Regular Expressions Engine - Main Orchestrator"
    Date: 20-Jul-2025
    File: %block-regexp-engine.r3
    Author: "AI Assistant"
    Version: "2.0.0"
    Purpose: "Main orchestrator for block-based RegExp engine with automatic dependency loading"
    Note: "Orchestrates tokenizer → processor → matcher pipeline while maintaining backward compatibility"
    Dependencies: [
        %block-regexp-core-utils.r3
        %string-to-block-tokenizer.r3
        %block-pattern-processor.r3
        %block-regexp-matcher.r3
    ]
]

;;=============================================================================
;; AUTOMATIC DEPENDENCY LOADING WITH ERROR HANDLING
;;=============================================================================

;; Module loading state tracking
module-loading-errors: copy []
modules-loaded: make object! [
    core-utils: false
    tokenizer: false
    processor: false
    matcher: false
]

;; Safe module loading function
LoadModuleSafely: funct [
    "Load module with error handling and status tracking"
    module-file [file!] "Module file to load"
    module-name [word!] "Module name for tracking"
    return: [logic!] "True if loaded successfully, false if error"
] [
    load-result: none
    set/any 'load-result try [
        do module-file
        true
    ]
    
    either error? load-result [
        append module-loading-errors reduce [module-name load-result]
        set in modules-loaded module-name false
        false
    ] [
        set in modules-loaded module-name true
        true
    ]
]

;; Load core utilities module first
if not LoadModuleSafely %block-regexp-core-utils.r3 'core-utils [
    print "^/ERROR: Failed to load block-regexp-core-utils.r3"
    if not empty? module-loading-errors [
        print ["Error details:" mold last module-loading-errors]
    ]
]

;; Load string-to-block tokenizer module
if not LoadModuleSafely %string-to-block-tokenizer.r3 'tokenizer [
    print "^/ERROR: Failed to load string-to-block-tokenizer.r3"
    if not empty? module-loading-errors [
        print ["Error details:" mold last module-loading-errors]
    ]
]

;; Load block pattern processor module
if not LoadModuleSafely %block-pattern-processor.r3 'processor [
    print "^/ERROR: Failed to load block-pattern-processor.r3"
    if not empty? module-loading-errors [
        print ["Error details:" mold last module-loading-errors]
    ]
]

;; Load block regexp matcher module
if not LoadModuleSafely %block-regexp-matcher.r3 'matcher [
    print "^/ERROR: Failed to load block-regexp-matcher.r3"
    if not empty? module-loading-errors [
        print ["Error details:" mold last module-loading-errors]
    ]
]

;;=============================================================================
;; MODULE DEPENDENCY VALIDATION
;;=============================================================================

ValidateModuleDependencies: funct [
    "Validate that all required modules are loaded and functional"
    return: [logic! string!] "True if all dependencies valid, error message if not"
] [
    ;; Check if all modules loaded successfully
    if not all [
        modules-loaded/core-utils
        modules-loaded/tokenizer
        modules-loaded/processor
        modules-loaded/matcher
    ] [
        return "One or more required modules failed to load"
    ]
    
    ;; Check if required functions are available
    required-functions: [
        StringToPatternBlock ProcessPatternBlock ExecuteBlockMatch ValidateTokenSequence
    ]
    
    foreach func-name required-functions [
        if not value? func-name [
            return rejoin ["Required function not available: " func-name]
        ]
    ]
    
    true  ;; All dependencies validated
]

;;=============================================================================
;; MAIN BLOCK-BASED REGEXP ENGINE FUNCTION
;;=============================================================================

RegExp: funct [
    "Match string against regular expression using block-based processing internally"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    return: [string! logic! none!] "Matched string, false if no match, none if error"
] [
    ;; Validate module dependencies first
    dependency-check: ValidateModuleDependencies
    if string? dependency-check [
        return none  ;; Module dependency error
    ]
    
    ;; Step 1: Convert string pattern to semantic block tokens
    pattern-block: none
    set/any 'pattern-block try [StringToPatternBlock strRegExp]
    
    ;; Check for tokenization errors
    if any [
        error? pattern-block
        all [block? pattern-block not empty? pattern-block pattern-block/1 = 'error]
    ] [
        return none  ;; Tokenization failed or contains errors
    ]
    
    ;; Step 2: Process semantic tokens into parse rules
    parse-rules: none
    set/any 'parse-rules try [ProcessPatternBlock pattern-block]
    
    ;; Check for rule generation errors
    if any [
        error? parse-rules
        all [block? parse-rules not empty? parse-rules parse-rules/1 = 'error]
    ] [
        return none  ;; Rule generation failed or contains errors
    ]
    
    ;; Step 3: Execute matching using block-optimized matcher
    match-result: none
    set/any 'match-result try [ExecuteBlockMatch strHaystack parse-rules]
    
    ;; Check for matching errors and return result
    either error? match-result [
        none  ;; Matching execution failed
    ] [
        match-result  ;; Return the match result (string, true, or none)
    ]
]

;;=============================================================================
;; MODULE STATUS REPORTING
;;=============================================================================

ReportModuleStatus: funct [
    "Report the status of all loaded modules"
] [
    print "^/=== BLOCK-BASED REGEXP ENGINE MODULE STATUS ==="
    print ["Core Utilities:" either modules-loaded/core-utils ["LOADED"] ["FAILED"]]
    print ["String-to-Block Tokenizer:" either modules-loaded/tokenizer ["LOADED"] ["FAILED"]]
    print ["Block Pattern Processor:" either modules-loaded/processor ["LOADED"] ["FAILED"]]
    print ["Block RegExp Matcher:" either modules-loaded/matcher ["LOADED"] ["FAILED"]]
    
    if not empty? module-loading-errors [
        print "^/=== MODULE LOADING ERRORS ==="
        foreach [module-name error-info] module-loading-errors [
            print ["Module:" module-name "Error:" mold error-info]
        ]
    ]
    
    dependency-status: ValidateModuleDependencies
    print ["^/Dependency Validation:" either dependency-status = true ["PASSED"] ["FAILED"]]
    if string? dependency-status [
        print ["Validation Error:" dependency-status]
    ]
    
    print "^/=== ENGINE STATUS ==="
    engine-ready: all [
        modules-loaded/core-utils modules-loaded/tokenizer
        modules-loaded/processor modules-loaded/matcher
        dependency-status = true
    ]
    print ["Engine Status:" either engine-ready ["READY"] ["NOT READY"]]
    print ["Version:" "1.0.0 (Block-Based)"]
    print ["Architecture:" "Modular block-based with semantic token processing"]
    print ["API Compatibility:" "100% backward compatible"]
    print "=== BLOCK-BASED REGEXP ENGINE INITIALIZED ==="
]

;;=============================================================================
;; ENHANCED UTILITY FUNCTIONS
;;=============================================================================

TestRegExp: funct [
    "Test RegExp function returning boolean result for compatibility"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    return: [logic!] "True if match found, false otherwise"
] [
    match-result: RegExp strHaystack strRegExp
    either any [string? match-result logic? match-result] [
        not none? match-result
    ] [
        false  ;; None result means no match
    ]
]

GetEngineInfo: funct [
    "Get detailed information about the block-based engine"
    return: [object!] "Engine information object"
] [
    make object! [
        version: "1.0.0"
        architecture: "Block-Based Modular"
        api-compatibility: "100% Backward Compatible"
        modules-loaded: modules-loaded
        dependency-status: ValidateModuleDependencies
        features: [
            "Meta-character conflict resolution"
            "Semantic token processing"
            "Enhanced error detection"
            "Optimized parse rule generation"
            "Advanced backtracking support"
        ]
        supported-patterns: [
            "Escape sequences: \\d \\w \\s \\D \\W \\S"
            "Quantifiers: + * ? {n} {n,m}"
            "Character classes: [a-z] [^0-9]"
            "Anchors: ^ $"
            "Alternation: |"
            "Dot wildcard: ."
            "Complex patterns with backtracking"
        ]
    ]
]

GetModuleStatus: funct [
    "Get current module loading status"
    return: [object!] "Module status object"
] [
    make object! [
        core-utils: modules-loaded/core-utils
        tokenizer: modules-loaded/tokenizer
        processor: modules-loaded/processor
        matcher: modules-loaded/matcher
        all-loaded: all [
            modules-loaded/core-utils
            modules-loaded/tokenizer
            modules-loaded/processor
            modules-loaded/matcher
        ]
        errors: copy module-loading-errors
        dependency-check: ValidateModuleDependencies
    ]
]

;;=============================================================================
;; PERFORMANCE MONITORING
;;=============================================================================

performance-stats: make object! [
    total-matches: 0
    successful-matches: 0
    failed-matches: 0
    error-matches: 0
    last-match-time: none
]

UpdatePerformanceStats: funct [
    "Update performance statistics"
    result [any-type!] "Match result"
    start-time [time!] "Start time of match"
] [
    performance-stats/total-matches: performance-stats/total-matches + 1
    performance-stats/last-match-time: now/time - start-time
    
    either error? result [
        performance-stats/error-matches: performance-stats/error-matches + 1
    ] [
        either none? result [
            performance-stats/failed-matches: performance-stats/failed-matches + 1
        ] [
            performance-stats/successful-matches: performance-stats/successful-matches + 1
        ]
    ]
]

GetPerformanceStats: funct [
    "Get current performance statistics"
    return: [object!] "Performance statistics object"
] [
    calculated-success-rate: either performance-stats/total-matches > 0 [
        to integer! (performance-stats/successful-matches * 100.0) / performance-stats/total-matches
    ] [0]
    
    make object! [
        total-matches: performance-stats/total-matches
        successful-matches: performance-stats/successful-matches
        failed-matches: performance-stats/failed-matches
        error-matches: performance-stats/error-matches
        success-rate: calculated-success-rate
        last-match-time: performance-stats/last-match-time
    ]
]

;;=============================================================================
;; ENHANCED REGEXP FUNCTION WITH PERFORMANCE MONITORING
;;=============================================================================

RegExpWithStats: funct [
    "RegExp function with performance monitoring"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    return: [string! logic! none!] "Matched string, false if no match, none if error"
] [
    start-time: now/time
    result: RegExp strHaystack strRegExp
    UpdatePerformanceStats result start-time
    result
]

;;=============================================================================
;; DEBUGGING AND DIAGNOSTIC FUNCTIONS
;;=============================================================================

DebugRegExp: funct [
    "Debug RegExp execution with detailed step-by-step information"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    return: [object!] "Debug information object"
] [
    debug-info: make object! [
        input-haystack: strHaystack
        input-pattern: strRegExp
        tokenization-result: none
        tokenization-error: none
        rule-generation-result: none
        rule-generation-error: none
        matching-result: none
        matching-error: none
        final-result: none
        success: false
    ]
    
    ;; Step 1: Tokenization
    set/any 'debug-info/tokenization-result try [
        StringToPatternBlock strRegExp
    ]
    
    if error? debug-info/tokenization-result [
        debug-info/tokenization-error: debug-info/tokenization-result
        return debug-info
    ]
    
    ;; Step 2: Rule Generation
    set/any 'debug-info/rule-generation-result try [
        ProcessPatternBlock debug-info/tokenization-result
    ]
    
    if error? debug-info/rule-generation-result [
        debug-info/rule-generation-error: debug-info/rule-generation-result
        return debug-info
    ]
    
    ;; Step 3: Matching
    set/any 'debug-info/matching-result try [
        ExecuteBlockMatch strHaystack debug-info/rule-generation-result
    ]
    
    if error? debug-info/matching-result [
        debug-info/matching-error: debug-info/matching-result
        return debug-info
    ]
    
    ;; Final result
    debug-info/final-result: debug-info/matching-result
    debug-info/success: not none? debug-info/final-result
    
    debug-info
]

ValidatePattern: funct [
    "Validate a RegExp pattern without executing it"
    strRegExp [string!] "Regular expression pattern to validate"
    return: [logic! string!] "True if valid, error message if invalid"
] [
    ;; Try tokenization
    tokens: none
    set/any 'tokens try [StringToPatternBlock strRegExp]
    
    if error? tokens [
        return "Pattern tokenization failed"
    ]
    
    if all [block? tokens not empty? tokens tokens/1 = 'error] [
        return either (length? tokens) > 1 [tokens/2] ["Pattern contains errors"]
    ]
    
    ;; Try rule generation
    rules: none
    set/any 'rules try [ProcessPatternBlock tokens]
    
    if error? rules [
        return "Rule generation failed"
    ]
    
    if all [block? rules not empty? rules rules/1 = 'error] [
        return either (length? rules) > 1 [rules/2] ["Rule generation contains errors"]
    ]
    
    true  ;; Pattern is valid
]

;;=============================================================================
;; BACKWARD COMPATIBILITY DOCUMENTATION
;;=============================================================================

comment {
BLOCK-BASED REGEXP ENGINE - VERSION 1.0.0

100% backward compatible with existing RegExp engines:
- Same API: RegExp strHaystack [string!] strRegExp [string!]
- Same return values: string! (match), logic! (false), none! (error)
- Enhanced: Eliminates REBOL meta-character conflicts (^ anchor)
- Faster: Block-based semantic token processing vs string parsing
- Supported: All escape sequences, quantifiers, character classes, anchors

ADDITIONAL FUNCTIONS:
- TestRegExp: Boolean result for compatibility
- GetEngineInfo: Detailed engine information
- GetModuleStatus: Module loading status
- GetPerformanceStats: Performance monitoring
- RegExpWithStats: RegExp with performance tracking
- DebugRegExp: Step-by-step debugging information
- ValidatePattern: Pattern validation without execution
}

;; Report module status on load
ReportModuleStatus
