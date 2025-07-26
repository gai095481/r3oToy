REBOL [
    Title: "REBOL 3 Regular Expressions Engine - Matcher Module"
    Date: 20-Jul-2025
    File: %regexp-matcher.r3
    Author: "Enhanced by Kiro AI Assistant"
    Version: "2.0.0"
    Purpose: "Pattern matching execution logic for RegExp engine"
    Note: "Extracted from monolithic regexp-engine.r3 for better maintainability"
]

;;=============================================================================
;; LOAD DEPENDENCIES
;;=============================================================================

;; Load core utilities module
core-utils-result: none
set/any 'core-utils-result try [
    do %regexp-core-utils.r3
]
if error? core-utils-result [
    print "ERROR: Failed to load regexp-core-utils.r3 in matcher"
    halt
]

;;=============================================================================
;; QUANTIFIER MATCHING FUNCTIONS
;;=============================================================================

HandleQuantifierMatching: funct [
    "Handle exact and range quantifier matching with anchored parsing"
    strHaystack [string!] "String to match against"
    blkRules [block!] "Translated parse rules"
    return: [string! logic! none!] "Matched string, false if no match, none if error"
] [
    ;; EXACT QUANTIFIER FIX - Check if this is an exact quantifier pattern
    is-exact-quantifier: all [
        (length? blkRules) = 2
        integer? blkRules/1
        bitset? blkRules/2
    ]
    
    ;; RANGE QUANTIFIER FIX - Check if this is a range quantifier pattern  
    is-range-quantifier: all [
        (length? blkRules) = 3
        integer? blkRules/1
        integer? blkRules/2
        bitset? blkRules/3
    ]
    
    ;; Execute quantifier matching
    parse-result: none
    matched: none
    set/any 'parse-result try [
        either is-range-quantifier [
            ;; Range quantifier like \d{2,4} - use min/max syntax
            min-count: blkRules/1
            max-count: blkRules/2
            charset-rule: blkRules/3
            parse/case strHaystack compose [
                copy matched (min-count) (max-count) (charset-rule) end
            ]
        ] [
            ;; Exact quantifier like \d{3} - use original logic
            parse/case strHaystack compose [
                copy matched (blkRules) end
            ]
        ]
    ]
    
    either error? parse-result [
        none  ;; Parse execution failed
    ] [
        ;; For quantifiers, only return match if parse succeeded
        either parse-result [
            either matched [matched] [false]
        ] [
            false  ;; Parse failed, return false
        ]
    ]
]

;;=============================================================================
;; SIMPLE PATTERN MATCHING FUNCTIONS
;;=============================================================================

HandleSimplePatterns: funct [
    "Handle simple patterns with 1-2 rules including anchors"
    strHaystack [string!] "String to match against"
    blkRules [block!] "Translated parse rules"
    return: [string! logic! none!] "Matched string, false if no match, none if error"
] [
    parse-result: none
    matched: none
    
    set/any 'parse-result try [
        either (length? blkRules) = 1 [
            ;; Single rule - check for anchors
            single-rule: blkRules/1
            either single-rule = 'start [
                ;; Start anchor alone - matches beginning of string
                matched: ""
                parse/case strHaystack [start]
            ] [
                either single-rule = 'end [
                    ;; End anchor alone - matches end of string  
                    matched: ""
                    parse/case strHaystack [to end]
                ] [
                    ;; Regular single rule
                    parse/case strHaystack [
                        some [
                            copy matched single-rule (break) |
                            skip
                        ]
                    ]
                ]
            ]
        ] [
            ;; Two rules - check for anchors first
            either blkRules/1 = 'start [
                ;; Start anchor with pattern
                remaining-pattern: skip blkRules 1
                parse/case strHaystack compose [
                    start copy matched (remaining-pattern) to end
                ]
            ] [
                either blkRules/2 = 'end [
                    ;; Pattern with end anchor
                    pattern-part: copy/part blkRules 1
                    parse/case strHaystack compose [
                        copy matched (pattern-part) end
                    ]
                ] [
                    ;; Regular two-rule pattern
                    parse/case strHaystack [
                        some [
                            copy matched blkRules (break) |
                            skip
                        ]
                    ]
                ]
            ]
        ]
    ]
    
    either error? parse-result [
        none  ;; Parse execution failed
    ] [
        ;; Return match if found
        either matched [
            matched  ;; Match successful, return matched portion
        ] [
            false  ;; No match, return false
        ]
    ]
]

;;=============================================================================
;; COMPLEX PATTERN MATCHING WITH BACKTRACKING
;;=============================================================================

HandleComplexPatterns: funct [
    "Handle complex patterns with backtracking for overlapping quantifiers"
    strHaystack [string!] "String to match against"
    blkRules [block!] "Translated parse rules"
    return: [string! logic! none!] "Matched string, false if no match, none if error"
] [
    parse-result: none
    matched: none
    
    set/any 'parse-result try [
        ;; Complex multi-element patterns - like [some bitset some bitset]
        ;; MIXED PATTERN BACKTRACKING FIX - Handle greedy matching issues
        either (length? blkRules) = 4 [
            ;; MIXED PATTERN FIX - Two quantified patterns need backtracking
            found-match: none
            string-pos: strHaystack
            while [all [not empty? string-pos not found-match]] [
                ;; Try matching from this position
                test-match: none
                direct-rule: reduce ['copy 'test-match blkRules]
                test-result: parse/case string-pos direct-rule
                either test-match [
                    found-match: test-match
                    matched: found-match  ;; Set matched for return
                ] [
                    ;; If direct match failed, try with backtracking simulation
                    ;; For patterns like \w+\d+, try different split points
                    if all [
                        word? blkRules/1
                        bitset? blkRules/2
                        word? blkRules/3
                        bitset? blkRules/4
                        blkRules/1 = 'some
                        blkRules/3 = 'some
                    ] [
                        ;; Try different split points for greedy patterns
                        string-len: length? string-pos
                        repeat split-point (string-len - 1) [
                            first-part: copy/part string-pos split-point
                            second-part: skip string-pos split-point
                            
                            ;; Test if first part matches first pattern and second part matches second pattern
                            first-match: none
                            second-match: none
                            
                            first-result: parse/case first-part [
                                copy first-match [some blkRules/2]
                            ]
                            second-result: parse/case second-part [
                                copy second-match [some blkRules/4]
                            ]
                            
                            if all [first-result second-result first-match second-match] [
                                found-match: rejoin [first-match second-match]
                                matched: found-match  ;; Set the matched variable for return
                                break
                            ]
                        ]
                    ]
                    string-pos: next string-pos
                ]
            ]
            either found-match [true] [false]
        ] [
            ;; COMPLEX PATTERN FIX - Other complex patterns with extended backtracking
            has-overlapping-quantifiers: false
            
            ;; Look for patterns with multiple 'some' quantifiers that might overlap
            some-count: 0
            repeat i length? blkRules [
                if blkRules/:i = 'some [
                    some-count: some-count + 1
                ]
            ]
            
            either some-count >= 2 [
                ;; Try backtracking approach for patterns with multiple quantifiers
                found-match: none
                string-pos: strHaystack
                while [all [not empty? string-pos not found-match]] [
                    ;; Try direct match first
                    test-match: none
                    direct-rule: reduce ['copy 'test-match blkRules]
                    test-result: parse string-pos direct-rule
                    either test-match [
                        found-match: test-match
                        matched: found-match
                    ] [
                        ;; If direct match failed, try splitting at different points
                        string-len: length? string-pos
                        repeat split-point (string-len - 1) [
                            ;; Try splitting the pattern - this is a simplified approach
                            ;; For \w+\d+\s\w+, try \w+ vs \d+\s\w+
                            if some-count >= 2 [
                                first-part: copy/part string-pos split-point
                                second-part: skip string-pos split-point
                                
                                ;; Test if we can match first part with first quantifier
                                ;; and second part with remaining pattern
                                first-match: none
                                first-result: parse first-part [
                                    copy first-match [some blkRules/2]  ;; First quantified pattern
                                ]
                                
                                if first-result [
                                    ;; Build remaining pattern (everything after first quantifier)
                                    remaining-rules: copy skip blkRules 2
                                    second-match: none
                                    remaining-rule: reduce ['copy 'second-match remaining-rules]
                                    second-result: parse second-part remaining-rule
                                    
                                    if all [second-result first-match second-match] [
                                        found-match: rejoin [first-match second-match]
                                        matched: found-match
                                        break
                                    ]
                                ]
                            ]
                        ]
                        string-pos: next string-pos
                    ]
                ]
                either found-match [true] [false]
            ] [
                ;; No overlapping quantifiers - use manual rule approach
                manual-rule: reduce ['copy 'matched blkRules]
                parse strHaystack manual-rule
            ]
        ]
    ]
    
    either error? parse-result [
        none  ;; Parse execution failed
    ] [
        ;; Return match if found
        either matched [
            matched  ;; Match successful, return matched portion
        ] [
            false  ;; No match, return false
        ]
    ]
]

;;=============================================================================
;; MAIN EXECUTION FUNCTION
;;=============================================================================

ExecuteMatch: funct [
    "Execute pattern matching using translated parse rules"
    strHaystack [string!] "String to match against"
    blkRules [block!] "Translated parse rules from pattern processor"
    return: [string! logic! none!] "Matched string, false if no match, none if error"
] [
    ;; Check for quantifier patterns first
    is-exact-quantifier: all [
        (length? blkRules) = 2
        integer? blkRules/1
        bitset? blkRules/2
    ]
    
    is-range-quantifier: all [
        (length? blkRules) = 3
        integer? blkRules/1
        integer? blkRules/2
        bitset? blkRules/3
    ]
    
    ;; Route to appropriate matching function
    either any [is-exact-quantifier is-range-quantifier] [
        ;; Handle quantifier patterns
        HandleQuantifierMatching strHaystack blkRules
    ] [
        either (length? blkRules) <= 2 [
            ;; Handle simple patterns (1-2 rules)
            HandleSimplePatterns strHaystack blkRules
        ] [
            ;; Handle complex patterns with backtracking
            HandleComplexPatterns strHaystack blkRules
        ]
    ]
]
