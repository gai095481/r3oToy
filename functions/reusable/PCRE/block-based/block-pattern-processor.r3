REBOL [
    Title: "REBOL 3 Block-Based Regular Expressions Engine - Block Pattern Processor Module"
    Date: 20-Jul-2025
    File: %block-pattern-processor.r3
    Author: "AI Assistant"
    Version: "2.0.0"
    Purpose: "Process semantic block tokens into optimized parse rules for block-based RegExp engine"
    Note: "Converts semantic tokens to parse rules without meta-character conflicts, with optimization"
    Exports: [ProcessPatternBlock GenerateParseRules OptimizeTokenSequence]
]

;;=============================================================================
;; DEPENDENCY LOADING
;;=============================================================================
;; Load core utilities module for token constants and validation functions
if not value? 'ANCHOR-START [
    do %block-regexp-core-utils.r3
]

;;=============================================================================
;; RULE GENERATION STATE MANAGEMENT
;;=============================================================================
ProcessorState: make object! [
    tokens: []          ;; Input token sequence
    rules: []           ;; Generated parse rules
    position: 1         ;; Current token position
    group-depth: 0      ;; Current group nesting depth
    alternation-stack: [] ;; Stack for handling alternation groups
]

ResetProcessorState: funct [
    "Reset processor state for new token sequence"
    state [object!] "Processor state object"
    token-sequence [block!] "New token sequence to process"
] [
    state/tokens: token-sequence
    state/rules: copy []
    state/position: 1
    state/group-depth: 0
    state/alternation-stack: copy []
]

;;=============================================================================
;; CORE TOKEN-TO-RULE CONVERSION FUNCTIONS
;;=============================================================================
ConvertTokenToRule: funct [
    "Convert a single semantic token to parse rule"
    token [word! block!] "Semantic token to convert"
    return: [any-type! none!] "Generated parse rule or none if invalid"
] [
    ;; Handle compound tokens (blocks)
    either block? token [
        if empty? token [
            return none
        ]
        
        token-type: token/1
        
        switch token-type [
            literal [
                ;; Literal character token
                if (length? token) >= 2 [
                    token/2
                ]
            ]
            escaped-char [
                ;; Escaped character token
                if (length? token) >= 2 [
                    token/2
                ]
            ]
            quantifier-exact [
                ;; Exact quantifier - return quantifier specification
                if (length? token) >= 2 [
                    reduce ['exact token/2]
                ]
            ]
            quantifier-range [
                ;; Range quantifier - return quantifier specification
                if (length? token) >= 3 [
                    reduce ['range token/2 token/3]
                ]
            ]
            custom-class [
                ;; Custom character class
                if (length? token) >= 3 [
                    class-type: token/2
                    class-spec: token/3
                    
                    ;; Create character set safely
                    charset-result: none
                    set/any 'charset-result try [
                        either class-type = 'negated [
                            complement CreateTokenizedCharSet class-spec
                        ] [
                            CreateTokenizedCharSet class-spec
                        ]
                    ]
                    
                    either error? charset-result [
                        none  ;; Invalid character class
                    ] [
                        charset-result
                    ]
                ]
            ]
            group [
                ;; Group handling - return group marker
                if (length? token) >= 2 [
                    reduce ['group token/2]
                ]
            ]
            default [
                none  ;; Unknown compound token type
            ]
        ]
    ] [
        ;; Handle simple tokens (words)
        switch token [
            anchor-start ['start]
            anchor-end ['end]
            digit-class [digit-charset]
            word-class [word-charset]
            space-class [space-charset]
            non-digit-class [non-digit-charset]
            non-word-class [non-word-charset]
            non-space-class [non-space-charset]
            wildcard [complement charset "^/"]  ;; Any character except newline
            quantifier-plus ['plus]
            quantifier-star ['star]
            quantifier-optional ['optional]
            alternation ['alternation]
            default [none]  ;; Unknown simple token type
        ]
    ]
]

ApplyQuantifierToRule: funct [
    "Apply quantifier specification to a base rule"
    base-rule [any-type!] "Base rule to quantify"
    quantifier-spec [word! block!] "Quantifier specification"
    return: [block! any-type!] "Quantified rule"
] [
    ;; Handle different quantifier types
    either block? quantifier-spec [
        ;; Compound quantifier specification
        switch quantifier-spec/1 [
            exact [
                if (length? quantifier-spec) >= 2 [
                    exact-count: quantifier-spec/2
                    compose [(exact-count) (base-rule)]
                ]
            ]
            range [
                if (length? quantifier-spec) >= 3 [
                    min-count: quantifier-spec/2
                    max-count: quantifier-spec/3
                    compose [(min-count) (max-count) (base-rule)]
                ]
            ]
            default [base-rule]  ;; Unknown quantifier, return base rule
        ]
    ] [
        ;; Simple quantifier specification
        switch quantifier-spec [
            plus [compose [some (base-rule)]]
            star [compose [any (base-rule)]]
            optional [compose [opt (base-rule)]]
            default [base-rule]  ;; Unknown quantifier, return base rule
        ]
    ]
]

;;=============================================================================
;; ADVANCED RULE GENERATION FUNCTIONS
;;=============================================================================
GenerateParseRules: funct [
    "Generate parse rules from semantic tokens"
    tokens [block!] "Token sequence"
    return: [block!] "Parse rule block"
] [
    ;; Handle empty token sequence
    if empty? tokens [
        return copy []
    ]
    
    ;; Validate token sequence first
    validation-result: ValidateTokenSequence tokens
    if string? validation-result [
        ;; Return error marker for invalid sequences
        return reduce ['error validation-result]
    ]
    
    rules: copy []
    token-index: 1
    
    ;; Process tokens sequentially
    while [token-index <= length? tokens] [
        current-token: pick tokens token-index
        next-token: either (token-index + 1) <= length? tokens [
            pick tokens (token-index + 1)
        ] [none]
        
        ;; Convert current token to rule
        base-rule: ConvertTokenToRule current-token
        
        either base-rule [
            ;; Check if next token is a quantifier
            quantifier-applied: false
            
            if next-token [
                quantifier-spec: ConvertTokenToRule next-token
                
                ;; Check if it's a quantifier specification
                if any [
                    quantifier-spec = 'plus
                    quantifier-spec = 'star
                    quantifier-spec = 'optional
                    all [block? quantifier-spec quantifier-spec/1 = 'exact]
                    all [block? quantifier-spec quantifier-spec/1 = 'range]
                ] [
                    ;; Apply quantifier to base rule
                    quantified-rule: ApplyQuantifierToRule base-rule quantifier-spec
                    append rules quantified-rule
                    token-index: token-index + 2  ;; Skip both tokens
                    quantifier-applied: true
                ]
            ]
            
            ;; If no quantifier was applied, just add the base rule
            if not quantifier-applied [
                ;; Handle special rule types
                either any [
                    base-rule = 'start
                    base-rule = 'end
                    base-rule = 'alternation
                    all [block? base-rule base-rule/1 = 'group]
                ] [
                    ;; Special rules - add directly
                    append rules base-rule
                ] [
                    ;; Regular rules - add as-is
                    append rules base-rule
                ]
                token-index: token-index + 1
            ]
        ] [
            ;; Skip invalid tokens
            token-index: token-index + 1
        ]
    ]
    
    rules
]

ProcessPatternBlock: funct [
    "Process semantic block tokens into parse rules"
    pattern-block [block!] "Semantic token block"
    return: [block!] "Generated parse rules"
] [
    ;; Handle empty pattern block
    if empty? pattern-block [
        return copy []
    ]
    
    ;; Check for error tokens in the pattern block
    foreach token pattern-block [
        if all [word? token token = 'error] [
            ;; Found error token - return it
            return pattern-block
        ]
        if all [block? token not empty? token word? token/1 token/1 = 'error] [
            ;; Found compound error token - return it
            return pattern-block
        ]
    ]
    
    ;; Generate basic parse rules
    basic-rules: GenerateParseRules pattern-block
    
    ;; Check if rule generation produced errors
    if all [
        not empty? basic-rules
        block? basic-rules
        basic-rules/1 = 'error
    ] [
        return basic-rules
    ]
    
    ;; Optimize the generated rules
    optimized-rules: OptimizeTokenSequence basic-rules
    
    ;; Validate the final rules
    validation-result: ValidateGeneratedRules optimized-rules
    either validation-result = true [
        optimized-rules
    ] [
        ;; Return error if validation failed
        reduce ['error validation-result]
    ]
]

;;=============================================================================
;; RULE OPTIMIZATION FUNCTIONS
;;=============================================================================

OptimizeTokenSequence: funct [
    "Optimize token sequence for performance improvements"
    rules [block!] "Parse rules to optimize"
    return: [block!] "Optimized parse rules"
] [
    ;; Handle empty rules
    if empty? rules [
        return copy []
    ]
    
    ;; Handle error rules
    if all [rules/1 = 'error] [
        return rules
    ]
    
    optimized: copy []
    rule-index: 1
    
    ;; Process rules for optimization opportunities
    while [rule-index <= length? rules] [
        current-rule: pick rules rule-index
        next-rule: either (rule-index + 1) <= length? rules [
            pick rules (rule-index + 1)
        ] [none]
        
        ;; Look for optimization patterns
        optimization-applied: false
        
        ;; Optimization 1: Merge consecutive identical character sets
        if all [
            bitset? current-rule
            bitset? next-rule
            current-rule = next-rule
        ] [
            ;; Merge identical consecutive character sets into one
            append optimized current-rule
            rule-index: rule-index + 2  ;; Skip the duplicate
            optimization-applied: true
        ]
        
        ;; Optimization 2: Combine consecutive 'some rules with same charset
        if all [
            not optimization-applied
            block? current-rule
            (length? current-rule) = 2
            current-rule/1 = 'some
            block? next-rule
            (length? next-rule) = 2
            next-rule/1 = 'some
            current-rule/2 = next-rule/2
        ] [
            ;; [some digit-charset] [some digit-charset] -> [some digit-charset]
            append optimized current-rule
            rule-index: rule-index + 2  ;; Skip the duplicate
            optimization-applied: true
        ]
        
        ;; Optimization 3: Simplify redundant quantifiers
        if all [
            not optimization-applied
            block? current-rule
            (length? current-rule) = 2
            current-rule/1 = 'any
            block? next-rule
            (length? next-rule) = 2
            next-rule/1 = 'some
            current-rule/2 = next-rule/2
        ] [
            ;; [any charset] [some charset] -> [some charset] (any + some = some)
            append optimized next-rule
            rule-index: rule-index + 2
            optimization-applied: true
        ]
        
        ;; No optimization applied, keep rule as-is
        if not optimization-applied [
            append optimized current-rule
            rule-index: rule-index + 1
        ]
    ]
    
    optimized
]

;;=============================================================================
;; RULE VALIDATION FUNCTIONS
;;=============================================================================

ValidateGeneratedRules: funct [
    "Validate generated parse rules for correctness"
    rules [block!] "Parse rules to validate"
    return: [logic! string!] "True if valid, or error message string"
] [
    ;; Handle empty rules
    if empty? rules [
        return true  ;; Empty rules are valid (match empty string)
    ]
    
    ;; Check for error markers
    if rules/1 = 'error [
        return "Error marker found in rules"
    ]
    
    ;; Check for basic structural issues
    foreach rule rules [
        ;; Check for invalid rule types
        if not any [
            word? rule
            char? rule
            bitset? rule
            integer? rule
            block? rule
        ] [
            return "Invalid rule type found in parse rules"
        ]
        
        ;; Check for malformed quantifier rules
        if block? rule [
            if all [
                (length? rule) >= 2
                word? rule/1
                any [rule/1 = 'some rule/1 = 'any rule/1 = 'opt]
                not any [bitset? rule/2 char? rule/2 block? rule/2]
            ] [
                return "Malformed quantifier rule found"
            ]
            
            ;; Check for malformed exact/range quantifiers
            if all [
                (length? rule) >= 2
                integer? rule/1
                rule/1 < 0
            ] [
                return "Negative quantifier count found"
            ]
            
            if all [
                (length? rule) >= 3
                integer? rule/1
                integer? rule/2
                rule/1 > rule/2
            ] [
                return "Invalid quantifier range (min > max)"
            ]
        ]
        
        ;; Check for invalid anchor placement
        if any [rule = 'start rule = 'end] [
            ;; Anchors should be at appropriate positions
            ;; This is a basic check - more sophisticated validation could be added
        ]
    ]
    
    ;; Check for unmatched groups (basic check)
    group-depth: 0
    foreach rule rules [
        if all [block? rule rule/1 = 'group] [
            either rule/2 = 'open [
                group-depth: group-depth + 1
            ] [
                if rule/2 = 'close [
                    group-depth: group-depth - 1
                    if group-depth < 0 [
                        return "Unmatched group close in rules"
                    ]
                ]
            ]
        ]
    ]
    
    if group-depth <> 0 [
        return "Unmatched group open in rules"
    ]
    
    ;; All validation checks passed
    true
]

;;=============================================================================
;; UTILITY FUNCTIONS FOR DEBUGGING AND TESTING
;;=============================================================================

RulesToString: funct [
    "Convert parse rules back to readable string representation"
    rules [block!] "Parse rules to convert"
    return: [string!] "String representation of rules"
] [
    if empty? rules [
        return "(empty rules)"
    ]
    
    result: make string! 200
    
    foreach rule rules [
        rule-str: either block? rule [
            ;; Compound rule
            switch rule/1 [
                some [rejoin ["some(" mold rule/2 ")"]]
                any [rejoin ["any(" mold rule/2 ")"]]
                opt [rejoin ["opt(" mold rule/2 ")"]]
                group [rejoin ["group-" rule/2]]
                error [rejoin ["ERROR: " rule/2]]
                default [
                    either all [integer? rule/1 (length? rule) >= 2] [
                        either (length? rule) = 2 [
                            rejoin [rule/1 "x(" mold rule/2 ")"]
                        ] [
                            rejoin [rule/1 "-" rule/2 "x(" mold rule/3 ")"]
                        ]
                    ] [
                        mold rule
                    ]
                ]
            ]
        ] [
            ;; Simple rule - handle different types
            either word? rule [
                ;; Handle word rules
                switch rule [
                    start ["^^"]
                    end ["$"]
                    alternation ["|"]
                    default [mold rule]
                ]
            ] [
                either bitset? rule [
                    ;; Handle bitset rules
                    either rule = digit-charset ["\d"] [
                        either rule = word-charset ["\w"] [
                            either rule = space-charset ["\s"] [
                                either rule = non-digit-charset ["\D"] [
                                    either rule = non-word-charset ["\W"] [
                                        either rule = non-space-charset ["\S"] [
                                            either rule = (complement charset "^/") ["."] [
                                                "[charset]"
                                            ]
                                        ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ] [
                    either char? rule [
                        to string! rule
                    ] [
                        mold rule
                    ]
                ]
            ]
        ]
        
        append result rule-str
        append result " "
    ]
    
    trim result
]

;;=============================================================================
;; MODULE EXPORTS
;;=============================================================================

;; Export main functions for use by other modules
;; ProcessPatternBlock - Main block processing function
;; GenerateParseRules - Rule generation from tokens
;; OptimizeTokenSequence - Performance optimization function
