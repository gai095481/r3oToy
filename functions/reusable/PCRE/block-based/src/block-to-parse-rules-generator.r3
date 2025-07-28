REBOL [
    Title: "Block-to-Parse-Rules Generator for RegExp Engine"
    Date: 27-Jul-2025
    Author: "AI Assistant"
    Version: "1.0.0"
    Purpose: "Convert semantic block tokens to REBOL parse rules for block-based RegExp processing"
    Note: "Implements rule generation from tokens with quantifier handling and optimization"
]

;;=============================================================================
;; DEPENDENCIES AND IMPORTS
;;=============================================================================

;; Import tokenizer constants and functions
do %string-to-block-tokenizer.r3

;;=============================================================================
;; CHARACTER SET DEFINITIONS
;;=============================================================================

;; Character set specifications (constants for better maintainability)
DIGITS: "0-9"
WORD_CHARS: "0-9A-Za-z_"
WHITESPACE: " ^-^/"

MakeCharSet: funct [
    "Create a character set from a string specification."
    specStr [string!]
    return: [bitset!]
] [
    strChars: make string! 256
    parse specStr [
        some [
            ;; Handle character ranges like "a-z" or "0-9"
            startChar: skip "-" endChar: skip (
                ;; Add all characters in the range from startChar to endChar
                startCode: to integer! startChar/1
                endCode: to integer! endChar/1
                repeat charCode (endCode - startCode + 1) [
                    append strChars to char! (startCode + charCode - 1)
                ]
            ) |
            ;; Handle individual characters
            charCurrent: skip (append strChars charCurrent/1)
        ]
    ]
    make bitset! strChars
]

;; Pre-built character sets (created once, reused many times)
digit-charset: MakeCharSet DIGITS
word-charset: MakeCharSet WORD_CHARS
space-charset: MakeCharSet WHITESPACE
non-digit-charset: complement digit-charset
non-word-charset: complement word-charset
non-space-charset: complement space-charset

;;=============================================================================
;; CORE BLOCK-TO-PARSE-RULES GENERATOR
;;=============================================================================

generate-parse-rules: funct [
    "Generate parse rules from semantic tokens"
    tokens [block!] "Semantic token block"
    return: [block!] "Generated parse rules"
] [
    ;; Handle empty token sequence
    if empty? tokens [
        return copy []
    ]
    
    rules: copy []
    token-index: 1
    
    ;; Process each token in sequence
    while [token-index <= length? tokens] [
        current-token: pick tokens token-index
        next-token: either (token-index + 1) <= length? tokens [
            pick tokens (token-index + 1)
        ] [none]
        
        ;; Process current token based on type
        either block? current-token [
            ;; Handle compound tokens
            switch current-token/1 [
                literal [
                    ;; Literal character token
                    char-value: current-token/2
                    append rules char-value
                    token-index: token-index + 1
                ]
                escaped-char [
                    ;; Escaped character token
                    char-value: current-token/2
                    append rules char-value
                    token-index: token-index + 1
                ]
                quantifier-exact [
                    ;; Exact quantifier - apply to previous rule
                    if not empty? rules [
                        exact-count: current-token/2
                        previous-rule: take/last rules
                        append rules compose [(exact-count) (previous-rule)]
                    ]
                    token-index: token-index + 1
                ]
                quantifier-range [
                    ;; Range quantifier - apply to previous rule
                    if not empty? rules [
                        min-count: current-token/2
                        max-count: current-token/3
                        previous-rule: take/last rules
                        append rules compose [(min-count) (max-count) (previous-rule)]
                    ]
                    token-index: token-index + 1
                ]
                custom-class [
                    ;; Custom character class
                    class-type: current-token/2
                    class-spec: current-token/3
                    
                    ;; Create character set
                    charset-result: none
                    set/any 'charset-result try [
                        either class-type = 'negated [
                            complement MakeCharSet class-spec
                        ] [
                            MakeCharSet class-spec
                        ]
                    ]
                    
                    either error? charset-result [
                        ;; Skip invalid character class
                        token-index: token-index + 1
                    ] [
                        append rules charset-result
                        token-index: token-index + 1
                    ]
                ]
                group [
                    ;; Group handling - for now, just skip group markers
                    token-index: token-index + 1
                ]
            ]
        ] [
            ;; Handle simple tokens
            switch current-token [
                anchor-start [
                    append rules 'start
                    token-index: token-index + 1
                ]
                anchor-end [
                    append rules 'end
                    token-index: token-index + 1
                ]
                digit-class [
                    ;; Check if next token is a quantifier
                    quantifier-applied: apply-quantifier-if-present rules digit-charset tokens token-index
                    token-index: quantifier-applied/1
                ]
                word-class [
                    quantifier-applied: apply-quantifier-if-present rules word-charset tokens token-index
                    token-index: quantifier-applied/1
                ]
                space-class [
                    quantifier-applied: apply-quantifier-if-present rules space-charset tokens token-index
                    token-index: quantifier-applied/1
                ]
                non-digit-class [
                    quantifier-applied: apply-quantifier-if-present rules non-digit-charset tokens token-index
                    token-index: quantifier-applied/1
                ]
                non-word-class [
                    quantifier-applied: apply-quantifier-if-present rules non-word-charset tokens token-index
                    token-index: quantifier-applied/1
                ]
                non-space-class [
                    quantifier-applied: apply-quantifier-if-present rules non-space-charset tokens token-index
                    token-index: quantifier-applied/1
                ]
                quantifier-plus [
                    ;; Apply to previous rule
                    if not empty? rules [
                        previous-rule: take/last rules
                        append rules compose [some (previous-rule)]
                    ]
                    token-index: token-index + 1
                ]
                quantifier-star [
                    ;; Apply to previous rule
                    if not empty? rules [
                        previous-rule: take/last rules
                        append rules compose [any (previous-rule)]
                    ]
                    token-index: token-index + 1
                ]
                quantifier-optional [
                    ;; Apply to previous rule
                    if not empty? rules [
                        previous-rule: take/last rules
                        append rules compose [opt (previous-rule)]
                    ]
                    token-index: token-index + 1
                ]
                wildcard [
                    ;; Wildcard matches any character except newline
                    quantifier-applied: apply-quantifier-if-present rules (complement charset "^/") tokens token-index
                    token-index: quantifier-applied/1
                ]
                alternation [
                    ;; Alternation handling - for now, just add marker
                    append rules '|
                    token-index: token-index + 1
                ]
            ]
        ]
    ]
    
    rules
]

;;=============================================================================
;; QUANTIFIER APPLICATION HELPER
;;=============================================================================

apply-quantifier-if-present: funct [
    "Apply quantifier to base rule if next token is a quantifier"
    rules [block!] "Current rules block to append to"
    base-rule [any-type!] "Base rule to potentially quantify"
    tokens [block!] "Token sequence"
    current-index [integer!] "Current token index"
    return: [block!] "Updated index and whether quantifier was applied"
] [
    next-index: current-index + 1
    
    ;; Check if there's a next token and if it's a quantifier
    if next-index <= length? tokens [
        next-token: pick tokens next-index
        
        ;; Handle different quantifier types
        either block? next-token [
            ;; Check for compound quantifier tokens
            switch next-token/1 [
                quantifier-exact [
                    exact-count: next-token/2
                    append rules compose [(exact-count) (base-rule)]
                    return reduce [next-index + 1]  ;; Skip both current and quantifier token
                ]
                quantifier-range [
                    min-count: next-token/2
                    max-count: next-token/3
                    append rules compose [(min-count) (max-count) (base-rule)]
                    return reduce [next-index + 1]  ;; Skip both current and quantifier token
                ]
            ]
        ] [
            ;; Check for simple quantifier tokens
            switch next-token [
                quantifier-plus [
                    append rules compose [some (base-rule)]
                    return reduce [next-index + 1]  ;; Skip both current and quantifier token
                ]
                quantifier-star [
                    append rules compose [any (base-rule)]
                    return reduce [next-index + 1]  ;; Skip both current and quantifier token
                ]
                quantifier-optional [
                    append rules compose [opt (base-rule)]
                    return reduce [next-index + 1]  ;; Skip both current and quantifier token
                ]
            ]
        ]
    ]
    
    ;; No quantifier found, just add base rule
    append rules base-rule
    reduce [next-index]  ;; Move to next token
]

;;=============================================================================
;; RULE OPTIMIZATION FUNCTIONS
;;=============================================================================

optimize-parse-rules: funct [
    "Optimize generated parse rules for better performance"
    rules [block!] "Parse rules to optimize"
    return: [block!] "Optimized parse rules"
] [
    ;; Handle empty rules
    if empty? rules [
        return copy []
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
        either all [
            block? current-rule
            (length? current-rule) = 2
            current-rule/1 = 'some
            block? next-rule
            (length? next-rule) = 2
            next-rule/1 = 'some
            current-rule/2 = next-rule/2
        ] [
            ;; Merge consecutive 'some rules with same charset
            ;; [some digit-charset] [some digit-charset] -> [some digit-charset]
            append optimized current-rule
            rule-index: rule-index + 2  ;; Skip the duplicate
        ] [
            ;; No optimization, keep rule as-is
            append optimized current-rule
            rule-index: rule-index + 1
        ]
    ]
    
    optimized
]

;;=============================================================================
;; RULE VALIDATION FUNCTIONS
;;=============================================================================

validate-parse-rules: funct [
    "Validate generated parse rules for correctness"
    rules [block!] "Parse rules to validate"
    return: [logic! string!] "True if valid, or error message string"
] [
    ;; Handle empty rules
    if empty? rules [
        return true  ;; Empty rules are valid
    ]
    
    ;; Check for basic structural issues
    foreach rule rules [
        ;; Check for invalid rule types
        if all [
            not word? rule
            not char? rule
            not bitset? rule
            not integer? rule
            not block? rule
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
        ]
    ]
    
    ;; Additional validation could be added here
    true
]

;;=============================================================================
;; TESTING AND VALIDATION FUNCTIONS
;;=============================================================================

test-rule-generation: does [
    "Test rule generation functionality with various token combinations"
    
    print "^/=== RULE GENERATION TESTS ==="
    
    test-cases: [
        ;; [tokens expected-description]
        [anchor-start [literal #"h"] [literal #"e"] [literal #"l"] [literal #"l"] [literal #"o"]] "anchor + literals"
        [digit-class quantifier-plus] "digit class with plus quantifier"
        [word-class quantifier-star] "word class with star quantifier"
        [space-class quantifier-optional] "space class with optional quantifier"
        [[quantifier-exact 3] digit-class] "exact quantifier with digit class"
        [[quantifier-range 2 5] word-class] "range quantifier with word class"
        [[custom-class normal "a-z"]] "custom character class"
        [[custom-class negated "0-9"]] "negated character class"
        [anchor-start digit-class quantifier-plus anchor-end] "anchored digit pattern"
        [word-class quantifier-plus space-class digit-class quantifier-plus] "mixed pattern"
    ]
    
    test-count: 0
    pass-count: 0
    
    foreach [tokens description] test-cases [
        test-count: test-count + 1
        print ["^/Test" test-count ":" description]
        print ["  Tokens: " format-tokens-readable tokens]
        
        ;; Generate rules
        rules: generate-parse-rules tokens
        print ["  Rules:  " mold rules]
        
        ;; Validate rules
        validation: validate-parse-rules rules
        either validation = true [
            print "  Status: PASS - Valid parse rules generated"
            pass-count: pass-count + 1
        ] [
            print ["  Status: FAIL - " validation]
        ]
    ]
    
    print ["^/=== RULE GENERATION TEST SUMMARY ==="]
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " (test-count - pass-count)]
    if test-count > 0 [
        success-rate: to integer! (pass-count * 100) / test-count
        print ["Success Rate: " success-rate "%"]
    ]
    
    ;; Return test results
    reduce [test-count pass-count (test-count - pass-count)]
]

test-rule-matching-behavior: does [
    "Test that generated rules produce correct matching behavior"
    
    print "^/=== RULE MATCHING BEHAVIOR TESTS ==="
    
    test-cases: [
        ;; [pattern test-string expected-match description]
        "\d+" "abc123def" "123" "digit plus pattern"
        "\w*" "test_123 " "test_123" "word star pattern"
        "\d{3}" "12345" "123" "exact quantifier pattern"
        "\w{2,4}" "testing" "test" "range quantifier pattern"
        "[a-z]+" "Hello123" "ello" "custom class pattern"
        "[^(5E)0-9]+" "123abc456" "abc" "negated class pattern"
        "." "test" "t" "wildcard pattern"
        "\D+" "123abc456" "abc" "non-digit class pattern"
        "\W+" "test_123 space" " " "non-word class pattern"
        "\S+" "  test  " "test" "non-space class pattern"
    ]
    
    test-count: 0
    pass-count: 0
    
    foreach [pattern test-string expected description] test-cases [
        test-count: test-count + 1
        print ["^/Test" test-count ":" description]
        print ["  Pattern: " pattern]
        print ["  String:  " test-string]
        print ["  Expected:" expected]
        
        ;; Convert pattern to tokens
        tokens: string-to-pattern-block pattern
        
        ;; Generate rules
        rules: generate-parse-rules tokens
        
        ;; Test matching behavior
        matched: none
        match-result: none
        set/any 'match-result try [
            ;; Handle different rule patterns
            either all [
                not empty? rules
                block? rules
                rules/1 = 'start
            ] [
                ;; Handle start anchor patterns
                remaining-rules: skip rules 1
                parse/case test-string compose [
                    start copy matched (remaining-rules) to end
                ]
            ] [
                either all [
                    not empty? rules
                    block? rules
                    (length? rules) > 0
                    (last rules) = 'end
                ] [
                    ;; Handle end anchor patterns
                    pattern-rules: copy/part rules ((length? rules) - 1)
                    parse/case test-string compose [
                        copy matched (pattern-rules) end
                    ]
                ] [
                    ;; Handle regular patterns
                    parse/case test-string [
                        some [
                            copy matched rules (break) |
                            skip
                        ]
                    ]
                ]
            ]
        ]
        
        either error? match-result [
            print ["  Actual:  ERROR - " match-result]
            print "  Status:  FAIL - Parse error"
        ] [
            print ["  Actual:  " either matched [matched] ["(no match)"]]
            either matched = expected [
                print "  Status:  PASS - Correct match"
                pass-count: pass-count + 1
            ] [
                print "  Status:  FAIL - Incorrect match"
            ]
        ]
    ]
    
    print ["^/=== MATCHING BEHAVIOR TEST SUMMARY ==="]
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " (test-count - pass-count)]
    if test-count > 0 [
        success-rate: to integer! (pass-count * 100) / test-count
        print ["Success Rate: " success-rate "%"]
    ]
    
    ;; Return test results
    reduce [test-count pass-count (test-count - pass-count)]
]

;;=============================================================================
;; COMPREHENSIVE TEST SUITE
;;=============================================================================

run-comprehensive-rule-generator-tests: does [
    "Run comprehensive test suite for rule generation"
    
    print "^/=========================================="
    print "BLOCK-TO-PARSE-RULES GENERATOR - COMPREHENSIVE TESTS"
    print "=========================================="
    
    ;; Run individual test suites
    print "^/Running rule generation tests..."
    set [gen-total gen-pass gen-fail] test-rule-generation
    
    print "^/Running rule matching behavior tests..."
    set [match-total match-pass match-fail] test-rule-matching-behavior
    
    ;; Calculate overall statistics
    total-tests: gen-total + match-total
    total-passed: gen-pass + match-pass
    total-failed: gen-fail + match-fail
    
    print "^/=========================================="
    print "COMPREHENSIVE TEST SUMMARY"
    print "=========================================="
    print ["Total Tests Executed: " total-tests]
    print ["Tests Passed: " total-passed]
    print ["Tests Failed: " total-failed]
    
    if total-tests > 0 [
        success-rate: to integer! (total-passed * 100) / total-tests
        print ["Overall Success Rate: " success-rate "%"]
        
        reliability-score: either success-rate >= 95 ["EXCELLENT"] [
            either success-rate >= 90 ["VERY GOOD"] [
                either success-rate >= 80 ["GOOD"] ["NEEDS IMPROVEMENT"]
            ]
        ]
        print ["Test Reliability: " reliability-score]
    ]
    
    print "^/--- COMPONENT BREAKDOWN ---"
    print ["Rule Generation Tests: " gen-pass "/" gen-total " passed"]
    print ["Matching Behavior Tests: " match-pass "/" match-total " passed"]
    
    ;; Return overall results
    reduce [total-tests total-passed total-failed]
]
