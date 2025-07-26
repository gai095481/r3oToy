REBOL [
    Title: "REBOL 3 Regular Expressions Engine - Core Utilities Module"
    Date: 20-Jul-2025
    File: %regexp-core-utils.r3
    Author: "Enhanced by Kiro AI Assistant"
    Version: "2.0.0"
    Type: 'module
    Purpose: "Core utilities, constants, and validation functions for RegExp engine"
    Note: "Extracted from monolithic regexp-engine.r3 for better maintainability"
    Exports: [
        ;; Constants
        TypChrCaret DIGITS WORD_CHARS WHITESPACE
        ;; Character sets
        digit-charset word-charset space-charset 
        non-digit-charset non-word-charset non-space-charset
        ;; Functions
        MakeCharSet ValidateQuantifierRange ValidateCharacterClass ProcessQuantifierSafely
    ]
]

;;=============================================================================
;; CORE CONSTANTS
;;=============================================================================

TypChrCaret: #"^(5E)"

;; Character set specifications (constants for better maintainability)
DIGITS: "0-9"
WORD_CHARS: "0-9A-Za-z_"
WHITESPACE: " ^-^/"

;;=============================================================================
;; CHARACTER SET CREATION UTILITIES
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

;;=============================================================================
;; PRE-BUILT CHARACTER SETS
;;=============================================================================

;; Pre-built character sets (created once, reused many times)
digit-charset: MakeCharSet DIGITS
word-charset: MakeCharSet WORD_CHARS
space-charset: MakeCharSet WHITESPACE
non-digit-charset: complement digit-charset
non-word-charset: complement word-charset
non-space-charset: complement space-charset

;;=============================================================================
;; VALIDATION FUNCTIONS
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
