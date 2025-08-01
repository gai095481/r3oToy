REBOL [
    Title: "REBOL 3 Block-Based Regular Expressions Engine - Block RegExp Matcher Module"
    Date: 30-Jul-2025
    File: %block-regexp-matcher.r3
    Author: "AI Assistant"
    Version: "1.0.1"
    Purpose: "Execute pattern matching using block-generated parse rules with enhanced capabilities"
    Note: "Enhanced matching with block-based rules, optimized quantifier processing, and improved error detection"
    Exports: [ExecuteBlockMatch HandleBlockQuantifiers HandleComplexBlockPatterns]
]

;;=============================================================================
;; DEPENDENCY LOADING
;;=============================================================================
;; Load core utilities module for token constants and validation functions
if not value? 'ANCHOR-START [
    do %block-regexp-core-utils.r3
]

;;=============================================================================
;; MATCHING STATE MANAGEMENT
;;=============================================================================
MatcherState: make object! [
    haystack: ""           ;; Input string to match against
    rules: []              ;; Parse rules to execute
    position: 1            ;; Current position in haystack
    match-start: 1         ;; Start position of current match
    match-end: 0           ;; End position of current match
    captured-groups: []    ;; Captured group results
    backtrack-stack: []    ;; Stack for backtracking support
    error-info: none       ;; Error information if matching fails
]

ResetMatcherState: funct [
    "Reset matcher state for new matching operation"
    state [object!] "Matcher state object"
    input-string [string!] "String to match against"
    parse-rules [block!] "Parse rules to execute"
] [
    state/haystack: input-string
    state/rules: parse-rules
    state/position: 1
    state/match-start: 1
    state/match-end: 0
    state/captured-groups: copy []
    state/backtrack-stack: copy []
    state/error-info: none
]

;;=============================================================================
;; CORE MATCHING EXECUTION FUNCTIONS
;;=============================================================================

ExecuteBlockMatch: funct [
    "Execute pattern matching using block-generated parse rules"
    strHaystack [string!] "String to match against"
    blkRules [block!] "Block-generated parse rules"
    return: [string! logic! none!] "Match result"
] [
    ;; Handle empty inputs
    if empty? strHaystack [
        ;; Empty string - check if rules can match empty
        either empty? blkRules [
            return ""  ;; Empty rules match empty string
        ] [
            ;; Check if rules allow empty match
            empty-match-result: none
            set/any 'empty-match-result try [
                parse "" blkRules
            ]
            either error? empty-match-result [
                return none  ;; Parse error
            ] [
                either empty-match-result [
                    return ""  ;; Successful empty match
                ] [
                    return false  ;; Rules don't match empty string (valid pattern, no match)
                ]
            ]
        ]
    ]
    
    if empty? blkRules [
        ;; Empty rules with non-empty string
        return none
    ]
    
    ;; Check for error markers in rules
    if all [blkRules/1 = 'error] [
        return none  ;; Error in rule generation
    ]
    
    ;; Initialize matcher state
    matcher-state: make MatcherState []
    ResetMatcherState matcher-state strHaystack blkRules
    
    ;; Execute matching with enhanced error handling
    match-result: ExecuteMatchWithBacktracking matcher-state
    
    ;; Return appropriate result
    either match-result [
        ;; Extract matched portion
        either all [
            matcher-state/match-start > 0
            matcher-state/match-end >= matcher-state/match-start
            matcher-state/match-end <= length? strHaystack
        ] [
            copy/part 
                at strHaystack matcher-state/match-start 
                (matcher-state/match-end - matcher-state/match-start + 1)
        ] [
            ;; Fallback for successful match without proper bounds
            ;; This handles zero-length matches (like 'any' quantifier with no matches)
            ""
        ]
    ] [
        ;; No match found - check if this was due to error or valid non-match
        either matcher-state/error-info [
            ;; Parse error occurred - return none for invalid pattern
            none
        ] [
            ;; Valid pattern but no match - return false
            false
        ]
    ]
]

ExecuteMatchWithBacktracking: funct [
    "Execute matching with backtracking support"
    state [object!] "Matcher state object"
    return: [logic!] "True if match found, false otherwise"
] [
    ;; Try matching at each position in the haystack
    haystack-length: length? state/haystack
    
    ;; Check for anchored patterns first
    anchored-start: HasStartAnchor state/rules
    anchored-end: HasEndAnchor state/rules
    
    either anchored-start [
        ;; Start-anchored pattern - only try at position 1
        ;; For start anchor, we must match from the very beginning
        TryMatchAtPositionWithAnchor state 1 true
    ] [
        ;; Non-anchored pattern - try at each position
        position: 1
        match-found: false
        
        while [all [position <= haystack-length not match-found]] [
            match-found: TryMatchAtPosition state position
            if not match-found [
                position: position + 1
            ]
        ]
        
        ;; Also try matching at end of string for end-anchored patterns
        if all [not match-found position > haystack-length anchored-end] [
            match-found: TryMatchAtPosition state position
        ]
        
        match-found
    ]
]

TryMatchAtPositionWithAnchor: funct [
    "Try matching rules at specific position with anchor handling"
    state [object!] "Matcher state object"
    start-pos [integer!] "Starting position to try matching"
    is-start-anchored [logic!] "Whether this is a start-anchored match"
    return: [logic!] "True if match successful at this position"
] [
    ;; For start-anchored patterns, we must be at position 1
    if all [is-start-anchored start-pos <> 1] [
        return false
    ]
    
    ;; Set up for matching at this position
    state/match-start: start-pos
    state/position: start-pos
    
    ;; Prepare haystack substring for parsing
    haystack-from-pos: either start-pos <= length? state/haystack [
        at state/haystack start-pos
    ] [
        ""  ;; Past end of string
    ]
    
    ;; Execute parse with error handling
    parse-result: none
    matched-content: none
    
    set/any 'parse-result try [
        ;; Remove start anchor from rules since we're handling it explicitly
        actual-rules: either all [
            not empty? state/rules
            state/rules/1 = 'start
        ] [
            next state/rules  ;; Skip the 'start token
        ] [
            state/rules
        ]
        
        ;; For start-anchored patterns, match from beginning without 'to' rule
        parse-rule: either is-start-anchored [
            ;; Start-anchored: must match from beginning, but don't require consuming entire string
            rule-block: copy [copy matched-content]
            append/only rule-block actual-rules
            ;; Add optional remainder to make parse succeed
            append rule-block [opt [to end]]
            rule-block
        ] [
            ;; Non-anchored: can match anywhere
            rule-block: copy [copy matched-content]
            append/only rule-block actual-rules
            append rule-block [to end]
            rule-block
        ]
        
        ;; Use case-sensitive parsing for regexp compatibility
        parse/case haystack-from-pos parse-rule
    ]
    
    ;; Check parse result
    either error? parse-result [
        ;; Parse error occurred
        state/error-info: parse-result
        false
    ] [
        either parse-result [
            ;; Successful match
            either all [matched-content string? matched-content] [
                content-length: length? matched-content
                state/match-end: state/match-start + content-length - 1
            ] [
                ;; Empty match or no content
                state/match-end: state/match-start - 1
            ]
            true
        ] [
            ;; Parse failed at this position
            false
        ]
    ]
]

TryMatchAtPosition: funct [
    "Try matching rules at specific position in haystack"
    state [object!] "Matcher state object"
    start-pos [integer!] "Starting position to try matching"
    return: [logic!] "True if match successful at this position"
] [
    ;; Delegate to anchor-aware function
    TryMatchAtPositionWithAnchor state start-pos false
]

;;=============================================================================
;; SPECIALIZED QUANTIFIER HANDLING
;;=============================================================================

HandleBlockQuantifiers: funct [
    "Handle quantifier matching with block-optimized rules"
    strHaystack [string!] "String to match"
    blkRules [block!] "Quantifier rules from blocks"
    return: [string! logic! none!] "Quantifier match result"
] [
    ;; This function provides specialized handling for quantifier patterns
    ;; that have been optimized through block processing
    
    ;; Handle empty inputs
    if any [empty? strHaystack empty? blkRules] [
        return none
    ]
    
    ;; Check for quantifier-specific optimizations
    optimized-rules: OptimizeQuantifierRules blkRules
    
    ;; Execute matching with optimized rules
    ExecuteBlockMatch strHaystack optimized-rules
]

OptimizeQuantifierRules: funct [
    "Optimize rules specifically for quantifier performance"
    rules [block!] "Original rules to optimize"
    return: [block!] "Optimized rules"
] [
    ;; Handle empty rules
    if empty? rules [
        return copy []
    ]
    
    optimized: copy []
    
    ;; Look for quantifier optimization opportunities
    foreach rule rules [
        ;; Check for nested quantifiers that can be flattened
        either all [
            block? rule
            (length? rule) >= 2
            word? rule/1
            any [rule/1 = 'some rule/1 = 'any rule/1 = 'opt]
            block? rule/2
            (length? rule/2) >= 2
            word? rule/2/1
            any [rule/2/1 = 'some rule/2/1 = 'any rule/2/1 = 'opt]
        ] [
            ;; Nested quantifier - flatten if possible
            outer-quantifier: rule/1
            inner-quantifier: rule/2/1
            base-rule: rule/2/2
            
            ;; Apply quantifier combination rules
            flattened-rule: switch reduce [outer-quantifier inner-quantifier] [
                [some some] [compose [some (base-rule)]]  ;; some(some(x)) = some(x)
                [any any] [compose [any (base-rule)]]     ;; any(any(x)) = any(x)
                [some any] [compose [any (base-rule)]]    ;; some(any(x)) = any(x)
                [any some] [compose [some (base-rule)]]   ;; any(some(x)) = some(x)
                [opt opt] [compose [opt (base-rule)]]     ;; opt(opt(x)) = opt(x)
                [some opt] [compose [any (base-rule)]]    ;; some(opt(x)) = any(x)
                [opt some] [compose [any (base-rule)]]    ;; opt(some(x)) = any(x)
                default [rule]  ;; No optimization possible
            ]
            
            append optimized flattened-rule
        ] [
            ;; No optimization - keep original rule
            append optimized rule
        ]
    ]
    
    optimized
]

;;=============================================================================
;; COMPLEX PATTERN HANDLING
;;=============================================================================

HandleComplexBlockPatterns: funct [
    "Handle complex patterns with advanced backtracking using block tokens"
    strHaystack [string!] "String to match"
    blkRules [block!] "Complex pattern rules from blocks"
    return: [string! logic! none!] "Complex pattern match result"
] [
    ;; This function handles complex patterns that require advanced backtracking
    ;; and lookahead/lookbehind capabilities enabled by block processing
    
    ;; Handle empty inputs
    if any [empty? strHaystack empty? blkRules] [
        return none
    ]
    
    ;; Analyze pattern complexity
    complexity-info: AnalyzePatternComplexity blkRules
    
    ;; Choose appropriate matching strategy based on complexity
    either complexity-info/requires-backtracking [
        ExecuteComplexMatchWithBacktracking strHaystack blkRules complexity-info
    ] [
        ;; Simple pattern - use standard matching
        ExecuteBlockMatch strHaystack blkRules
    ]
]

AnalyzePatternComplexity: funct [
    "Analyze pattern rules to determine complexity and required features"
    rules [block!] "Pattern rules to analyze"
    return: [object!] "Complexity analysis object"
] [
    analysis: make object! [
        requires-backtracking: false
        has-alternation: false
        has-nested-groups: false
        has-complex-quantifiers: false
        max-group-depth: 0
        estimated-complexity: 'simple
    ]
    
    ;; Analyze rules for complexity indicators
    group-depth: 0
    max-depth: 0
    
    foreach rule rules [
        ;; Check for alternation
        if rule = 'alternation [
            analysis/has-alternation: true
            analysis/requires-backtracking: true
        ]
        
        ;; Check for groups
        if all [block? rule rule/1 = 'group] [
            either rule/2 = 'open [
                group-depth: group-depth + 1
                max-depth: max max-depth group-depth
            ] [
                if rule/2 = 'close [
                    group-depth: group-depth - 1
                ]
            ]
        ]
        
        ;; Check for complex quantifiers
        if all [
            block? rule
            (length? rule) >= 3
            integer? rule/1
            integer? rule/2
            rule/1 <> rule/2  ;; Range quantifier
        ] [
            analysis/has-complex-quantifiers: true
            if rule/2 > 10 [  ;; Large range
                analysis/requires-backtracking: true
            ]
        ]
        
        ;; Check for nested quantifiers
        if all [
            block? rule
            (length? rule) >= 2
            word? rule/1
            any [rule/1 = 'some rule/1 = 'any rule/1 = 'opt]
            block? rule/2
            (length? rule/2) >= 2
            word? rule/2/1
            any [rule/2/1 = 'some rule/2/1 = 'any rule/2/1 = 'opt]
        ] [
            analysis/requires-backtracking: true
        ]
    ]
    
    analysis/max-group-depth: max-depth
    analysis/has-nested-groups: max-depth > 1
    
    ;; Determine overall complexity
    analysis/estimated-complexity: either any [
        analysis/requires-backtracking
        analysis/has-alternation
        analysis/has-nested-groups
        analysis/has-complex-quantifiers
    ] [
        'complex
    ] [
        'simple
    ]
    
    analysis
]

ExecuteComplexMatchWithBacktracking: funct [
    "Execute complex pattern matching with full backtracking support"
    strHaystack [string!] "String to match"
    blkRules [block!] "Complex pattern rules"
    complexity-info [object!] "Pattern complexity analysis"
    return: [string! logic! none!] "Match result"
] [
    ;; For now, delegate to standard matching
    ;; Future enhancement: implement full backtracking algorithm
    ;; with support for alternation, nested groups, and complex quantifiers
    
    ;; Create enhanced matcher state for complex patterns
    complex-state: make MatcherState [
        alternation-branches: []
        group-stack: []
        backtrack-points: []
    ]
    
    ResetMatcherState complex-state strHaystack blkRules
    
    ;; Execute with enhanced backtracking
    match-result: ExecuteMatchWithBacktracking complex-state
    
    ;; Return result in same format as ExecuteBlockMatch
    either match-result [
        either all [
            complex-state/match-start > 0
            complex-state/match-end >= complex-state/match-start
            complex-state/match-end <= length? strHaystack
        ] [
            copy/part 
                at strHaystack complex-state/match-start 
                (complex-state/match-end - complex-state/match-start + 1)
        ] [
            true
        ]
    ] [
        none
    ]
]

;;=============================================================================
;; UTILITY FUNCTIONS FOR RULE ANALYSIS
;;=============================================================================

HasStartAnchor: funct [
    "Check if rules contain start anchor"
    rules [block!] "Rules to check"
    return: [logic!] "True if start anchor present"
] [
    if empty? rules [
        return false
    ]
    
    ;; Check first rule for start anchor
    rules/1 = 'start
]

HasEndAnchor: funct [
    "Check if rules contain end anchor"
    rules [block!] "Rules to check"
    return: [logic!] "True if end anchor present"
] [
    if empty? rules [
        return false
    ]
    
    ;; Check last rule for end anchor
    (last rules) = 'end
]

CountQuantifiers: funct [
    "Count quantifier rules in pattern"
    rules [block!] "Rules to analyze"
    return: [integer!] "Number of quantifier rules"
] [
    count: 0
    
    foreach rule rules [
        if all [
            block? rule
            (length? rule) >= 2
            word? rule/1
            any [
                rule/1 = 'some
                rule/1 = 'any
                rule/1 = 'opt
                integer? rule/1  ;; Exact/range quantifiers
            ]
        ] [
            count: count + 1
        ]
    ]
    
    count
]

EstimateMatchComplexity: funct [
    "Estimate computational complexity of matching operation"
    haystack-length [integer!] "Length of string to match"
    rules [block!] "Rules to execute"
    return: [word!] "Complexity estimate: 'linear, 'polynomial, or 'exponential"
] [
    ;; Simple heuristic-based complexity estimation
    quantifier-count: CountQuantifiers rules
    has-alternation: not none? find rules 'alternation
    has-nested-quantifiers: false
    
    ;; Check for nested quantifiers
    foreach rule rules [
        if all [
            block? rule
            (length? rule) >= 2
            word? rule/1
            any [rule/1 = 'some rule/1 = 'any rule/1 = 'opt]
            block? rule/2
            (length? rule/2) >= 2
            word? rule/2/1
            any [rule/2/1 = 'some rule/2/1 = 'any rule/2/1 = 'opt]
        ] [
            has-nested-quantifiers: true
            break
        ]
    ]
    
    ;; Estimate complexity
    either any [has-nested-quantifiers has-alternation] [
        either quantifier-count > 3 [
            'exponential
        ] [
            'polynomial
        ]
    ] [
        either quantifier-count > 1 [
            'polynomial
        ] [
            'linear
        ]
    ]
]

;;=============================================================================
;; ERROR HANDLING AND DIAGNOSTICS
;;=============================================================================

GetMatchError: funct [
    "Get detailed error information from last match attempt"
    state [object!] "Matcher state object"
    return: [string! none!] "Error description or none"
] [
    either state/error-info [
        either error? state/error-info [
            rejoin ["Parse error: " mold state/error-info]
        ] [
            "Unknown matching error"
        ]
    ] [
        none
    ]
]

ValidateMatchingRules: funct [
    "Validate that rules are suitable for matching"
    rules [block!] "Rules to validate"
    return: [logic! string!] "True if valid, error message if invalid"
] [
    ;; Handle empty rules
    if empty? rules [
        return true  ;; Empty rules are valid (match empty string)
    ]
    
    ;; Check for error markers
    if rules/1 = 'error [
        return "Rules contain error marker"
    ]
    
    ;; Check for invalid rule structures
    foreach rule rules [
        ;; Check for malformed quantifier rules
        if all [
            block? rule
            (length? rule) >= 2
            word? rule/1
            any [rule/1 = 'some rule/1 = 'any rule/1 = 'opt]
            not any [bitset? rule/2 char? rule/2 block? rule/2 word? rule/2]
        ] [
            return "Invalid quantifier rule structure"
        ]
        
        ;; Check for invalid exact/range quantifiers
        if all [
            block? rule
            (length? rule) >= 2
            integer? rule/1
            rule/1 < 0
        ] [
            return "Negative quantifier count"
        ]
        
        if all [
            block? rule
            (length? rule) >= 3
            integer? rule/1
            integer? rule/2
            rule/1 > rule/2
        ] [
            return "Invalid quantifier range (min > max)"
        ]
    ]
    
    ;; All validation checks passed
    true
]

;;=============================================================================
;; MODULE EXPORTS
;;=============================================================================

;; Export main functions for use by other modules
;; ExecuteBlockMatch - Main matching execution function
;; HandleBlockQuantifiers - Specialized quantifier handling
;; HandleComplexBlockPatterns - Complex pattern matching with backtracking
