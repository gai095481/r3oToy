REBOL [
    Title: "REBOL 3 Block-Based Regular Expressions Engine - Core Utilities Module"
    Date: 20-Jul-2025
    File: %block-regexp-core-utils.r3
    Author: "Enhanced by Kiro AI Assistant"
    Version: "1.0.0"
    Purpose: "Core utilities, constants, and validation functions for block-based RegExp engine"
    Note: "Enhanced from modular regexp-core-utils.r3 for block-based semantic token processing"
]

;;=============================================================================
;; SEMANTIC TOKEN TYPE CONSTANTS FOR BLOCK-BASED PROCESSING
;;=============================================================================

;; Basic Token Types
ANCHOR-START: 'anchor-start
ANCHOR-END: 'anchor-end
LITERAL: 'literal
WILDCARD: 'wildcard

;; Character Class Token Types
DIGIT-CLASS: 'digit-class
WORD-CLASS: 'word-class
SPACE-CLASS: 'space-class
NON-DIGIT-CLASS: 'non-digit-class
NON-WORD-CLASS: 'non-word-class
NON-SPACE-CLASS: 'non-space-class
CUSTOM-CLASS: 'custom-class

;; Quantifier Token Types
QUANTIFIER-PLUS: 'quantifier-plus
QUANTIFIER-STAR: 'quantifier-star
QUANTIFIER-OPTIONAL: 'quantifier-optional
QUANTIFIER-EXACT: 'quantifier-exact
QUANTIFIER-RANGE: 'quantifier-range

;; Complex Token Types
GROUP: 'group
ALTERNATION: 'alternation
ESCAPED-CHAR: 'escaped-char

;;=============================================================================
;; LEGACY CONSTANTS (for backward compatibility)
;;=============================================================================

TypChrCaret: #"^(5E)"

;; Character set specifications (constants for better maintainability)
DIGITS: "0-9"
WORD_CHARS: "0-9A-Za-z_"
WHITESPACE: " ^-^/"

;;=============================================================================
;; CHARACTER SET CREATION UTILITIES (Enhanced for Block Processing)
;;=============================================================================

MakeCharSet: funct [
    "Create a character set from a string specification."
    specStr [string!]
    return: [bitset!] "Character set bitset"
][
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

CreateTokenizedCharSet: funct [
    "Create character set optimized for block token processing"
    token-spec [string! block!] "Character specification or token block"
    return: [bitset!] "Optimized character set bitset"
] [
    either string? token-spec [
        ;; String specification - use standard MakeCharSet
        MakeCharSet token-spec
    ] [
        ;; Block specification - handle semantic tokens
        ;; This allows for future optimization of token-based character sets
        if (length? token-spec) >= 1 [
            token-type: token-spec/1
            
            switch token-type [
                custom-class [
                    ;; Custom class needs additional parameters
                    if (length? token-spec) >= 3 [
                        MakeCharSet token-spec/3
                    ]
                ]
                digit-class [digit-charset]
                word-class [word-charset]
                space-class [space-charset]
                non-digit-class [non-digit-charset]
                non-word-class [non-word-charset]
                non-space-class [non-space-charset]
            ]
        ]
    ]
]

;;=============================================================================
;; PRE-BUILT CHARACTER SETS (Enhanced for Block Processing)
;;=============================================================================

;; Pre-built character sets (created once, reused many times)
digit-charset: MakeCharSet DIGITS
word-charset: MakeCharSet WORD_CHARS
space-charset: MakeCharSet WHITESPACE
non-digit-charset: complement digit-charset
non-word-charset: complement word-charset
non-space-charset: complement space-charset

;;=============================================================================
;; BLOCK TOKEN VALIDATION FUNCTIONS
;;=============================================================================

ValidateTokenType: funct [
    "Validate that a token type is recognized"
    token-type [word!] "Token type to validate"
    return: [logic!] "True if valid token type, false otherwise"
] [
    ;; Check if token type is in our recognized set
    not none? find [
        anchor-start anchor-end literal wildcard
        digit-class word-class space-class 
        non-digit-class non-word-class non-space-class
        custom-class quantifier-plus quantifier-star quantifier-optional
        quantifier-exact quantifier-range group alternation escaped-char
        error
    ] token-type
]

ValidateTokenSequence: funct [
    "Validate semantic token sequence for correctness"
    tokens [block!] "Block of semantic tokens to validate"
    return: [logic! string!] "True if valid, error message string if invalid"
] [
    if empty? tokens [
        return true  ;; Empty token sequence is valid (matches empty string)
    ]
    
    ;; Track validation state
    previous-token: none
    quantifier-expected: false
    group-depth: 0
    
    foreach token tokens [
        ;; Handle compound tokens (blocks within the token sequence)
        either block? token [
            if empty? token [
                return "Empty compound token found"
            ]
            
            token-type: token/1
            
            ;; Validate compound token structure
            switch token-type [
                quantifier-exact [
                    if (length? token) <> 2 [
                        return "Invalid quantifier-exact token structure"
                    ]
                    if not integer? token/2 [
                        return "Quantifier-exact requires integer parameter"
                    ]
                    if token/2 < 0 [
                        return "Quantifier-exact cannot be negative"
                    ]
                ]
                quantifier-range [
                    if (length? token) <> 3 [
                        return "Invalid quantifier-range token structure"
                    ]
                    if not all [integer? token/2 integer? token/3] [
                        return "Quantifier-range requires integer parameters"
                    ]
                    if any [token/2 < 0 token/3 < 0] [
                        return "Quantifier-range cannot have negative values"
                    ]
                    if token/2 > token/3 [
                        return "Quantifier-range minimum cannot exceed maximum"
                    ]
                ]
                custom-class [
                    if (length? token) < 3 [
                        return "Invalid custom-class token structure"
                    ]
                    if not find [normal negated] token/2 [
                        return "Custom-class requires 'normal or 'negated modifier"
                    ]
                    if not string? token/3 [
                        return "Custom-class requires string specification"
                    ]
                ]
                group [
                    if (length? token) < 2 [
                        return "Invalid group token structure"
                    ]
                    if not find [open close] token/2 [
                        return "Group token requires 'open or 'close modifier"
                    ]
                    ;; Track group nesting
                    either token/2 = 'open [
                        group-depth: group-depth + 1
                    ] [
                        group-depth: group-depth - 1
                        if group-depth < 0 [
                            return "Unmatched group close token"
                        ]
                    ]
                ]
                escaped-char [
                    if (length? token) <> 2 [
                        return "Invalid escaped-char token structure"
                    ]
                    if not char? token/2 [
                        return "Escaped-char requires character parameter"
                    ]
                ]
            ]
            
            ;; Validate token type
            if not ValidateTokenType token-type [
                return rejoin ["Unknown compound token type: " token-type]
            ]
        ] [
            ;; Simple token (word)
            if not word? token [
                return "Invalid token type - must be word or block"
            ]
            
            ;; Validate simple token type
            if not ValidateTokenType token [
                return rejoin ["Unknown simple token type: " token]
            ]
        ]
        
        ;; Check for invalid quantifier sequences (quantifier after quantifier)
        current-token: either block? token [token/1] [token]
        if any [
            all [previous-token = quantifier-plus current-token = quantifier-star]
            all [previous-token = quantifier-star current-token = quantifier-plus]
            all [previous-token = quantifier-optional current-token = quantifier-plus]
            all [previous-token = quantifier-plus current-token = quantifier-plus]
            all [previous-token = quantifier-star current-token = quantifier-star]
            all [previous-token = quantifier-optional current-token = quantifier-optional]
        ] [
            return "Invalid consecutive quantifier sequence"
        ]
        
        previous-token: either block? token [token/1] [token]
    ]
    
    ;; Check for unmatched groups
    if group-depth <> 0 [
        return "Unmatched group tokens - missing close"
    ]
    
    ;; Validation passed
    true
]

;;=============================================================================
;; LEGACY VALIDATION FUNCTIONS (Enhanced for Block Processing)
;;=============================================================================

ValidateQuantifierRange: funct [
    "Validate quantifier range syntax and values"
    quantifier-string [string!] "Quantifier specification like '3' or '2,5'"
    return: [logic!] "True if valid, false if invalid"
] [
    ;; Handle empty quantifier
    if empty? trim quantifier-string [
        return false
    ]
    
    ;; Check for comma (range quantifier)
    either find quantifier-string "," [
        ;; Range quantifier {n,m}
        range-parts: split quantifier-string ","
        if (length? range-parts) <> 2 [
            return false  ;; Invalid format
        ]
        
        ;; Validate both parts are integers
        min-part: trim range-parts/1
        max-part: trim range-parts/2
        
        ;; Check if parts are valid integers using digit charset
        min-valid: all [
            not empty? min-part
            parse min-part [some digit-charset]
        ]
        max-valid: all [
            not empty? max-part
            parse max-part [some digit-charset]
        ]
        
        if not all [min-valid max-valid] [
            return false
        ]
        
        ;; Convert to integers and validate range
        conversion-result: none
        set/any 'conversion-result try [
            min-count: to integer! min-part
            max-count: to integer! max-part
            
            ;; Validate reasonable limits and proper range
            all [
                min-count >= 0
                max-count >= min-count
                max-count < 10000  ;; Reasonable upper limit (exclusive)
            ]
        ]
        
        either error? conversion-result [
            false  ;; Conversion failed
        ] [
            either conversion-result [true] [false]  ;; Ensure boolean return
        ]
    ] [
        ;; Exact quantifier {n}
        trimmed-count: trim quantifier-string
        
        ;; Check if it's a valid integer using digit charset
        count-valid: all [
            not empty? trimmed-count
            parse trimmed-count [some digit-charset]
        ]
        
        if not count-valid [
            return false
        ]
        
        ;; Validate reasonable limits
        exact-count: to integer! trimmed-count
        all [
            exact-count >= 0
            exact-count < 10000  ;; Reasonable upper limit (exclusive)
        ]
    ]
]

ValidateCharacterClass: funct [
    "Validate character class specification"
    char-spec [string!] "Character class specification"
    return: [logic!] "True if valid, false if invalid"
] [
    ;; Handle empty character class
    if empty? char-spec [
        return false
    ]
    
    ;; Handle negated character class
    spec-to-check: either char-spec/1 = TypChrCaret [
        next char-spec
    ] [
        char-spec
    ]
    
    ;; Basic validation - check for unclosed ranges
    ;; Look for patterns like "a-" at the end or "-z" at the start
    if any [
        all [(length? spec-to-check) > 1 (last spec-to-check) = #"-"]
        all [(length? spec-to-check) > 1 (first spec-to-check) = #"-"]
    ] [
        return false
    ]
    
    ;; Check for reverse ranges like "z-a" where start > end
    if find spec-to-check "-" [
        ;; Parse the character class to find ranges
        parse-result: parse spec-to-check [
            some [
                start-char: skip "-" end-char: skip (
                    ;; Check if this is a reverse range
                    if (to integer! start-char/1) > (to integer! end-char/1) [
                        return false  ;; Reverse range detected
                    ]
                ) |
                skip  ;; Skip non-range characters
            ]
        ]
    ]
    
    ;; Additional validation could be added here for more complex cases
    true
]

ProcessQuantifierSafely: funct [
    "Safely process quantifier with error handling"
    quantifier-string [string!] "Quantifier specification"
    base-rule [any-type!] "Base rule to apply quantifier to"
    return: [block! none!] "Generated rule block or none if error"
] [
    ;; Validate quantifier first
    if not ValidateQuantifierRange quantifier-string [
        return none
    ]
    
    ;; Process the quantifier
    quantifier-result: none
    set/any 'quantifier-result try [
        either find quantifier-string "," [
            ;; Range quantifier {n,m}
            range-parts: split quantifier-string ","
            min-count: to integer! trim range-parts/1
            max-count: to integer! trim range-parts/2
            compose [(min-count) (max-count) (base-rule)]
        ] [
            ;; Exact quantifier {n}
            exact-count: to integer! trim quantifier-string
            compose [(exact-count) (base-rule)]
        ]
    ]
    
    either error? quantifier-result [
        none
    ] [
        quantifier-result
    ]
]
