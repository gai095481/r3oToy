REBOL [
    Title: "REBOL 3 Block-Based Regular Expressions Engine - String-to-Block Tokenizer Module"
    Date: 30-Jul-2025
    File: %string-to-block-tokenizer.r3
    Author: "AI Assistant"
    Version: "1.0.1"
    Purpose: "Convert string patterns to semantic block tokens, eliminating meta-character conflicts"
    Note: "Handles anchors, character classes, quantifiers, and complex patterns with block tokenization"
    Exports: [StringToPatternBlock TokenizePattern PreprocessMetaCharacters]
]

;;=============================================================================
;; DEPENDENCY LOADING
;;=============================================================================
;; Load core utilities module for token constants and validation functions
if not value? 'ANCHOR-START [
    do %block-regexp-core-utils.r3
]

;;=============================================================================
;; TOKENIZATION STATE MANAGEMENT
;;=============================================================================
TokenizerState: make object! [
    input: ""           ;; Original input string
    position: 1         ;; Current parsing position
    tokens: []          ;; Accumulated tokens
    group-depth: 0      ;; Current group nesting depth
    in-character-class: false  ;; Whether we're inside [...]
    escape-next: false  ;; Whether next character should be escaped
]

ResetTokenizerState: funct [
    "Reset tokenizer state for new pattern"
    state [object!] "Tokenizer state object"
    pattern [string!] "New pattern to tokenize"
] [
    state/input: pattern
    state/position: 1
    state/tokens: copy []
    state/group-depth: 0
    state/in-character-class: false
    state/escape-next: false
]

;;=============================================================================
;; CHARACTER CLASSIFICATION UTILITIES
;;=============================================================================

IsQuantifierChar: funct [
    "Check if character is a quantifier symbol"
    char [char!] "Character to check"
    return: [logic!] "True if quantifier character"
] [
    find "+*?" char
]

IsAnchorChar: funct [
    "Check if character is an anchor symbol"
    char [char!] "Character to check"
    return: [logic!] "True if anchor character"
] [
    any [char = #"^(5E)" char = #"$"]
]

IsMetaChar: funct [
    "Check if character is a meta-character that needs special handling"
    char [char!] "Character to check"
    return: [logic!] "True if meta-character"
] [
    any [
        char = #"^(5E)"
        find "$+*?[]{}()|\." char
    ]
]

;;=============================================================================
;; ESCAPE SEQUENCE PROCESSING
;;=============================================================================

ProcessEscapeSequence: funct [
    "Process escape sequence and return appropriate token"
    state [object!] "Tokenizer state"
    return: [block! none!] "Token block or none if invalid"
] [
    ;; Check if we have enough characters for escape sequence
    if state/position >= length? state/input [
        ;; Trailing backslash - treat as literal backslash
        state/position: state/position + 1
        return reduce [ESCAPED-CHAR #"\"]
    ]
    
    ;; Get the escaped character
    escape-char: pick state/input (state/position + 1)
    
    ;; Process escape sequences (case-sensitive)
    token: switch/case escape-char [
        ;; Character class escape sequences
        #"d" [reduce [DIGIT-CLASS]]
        #"D" [reduce [NON-DIGIT-CLASS]]
        #"w" [reduce [WORD-CLASS]]
        #"W" [reduce [NON-WORD-CLASS]]
        #"s" [reduce [SPACE-CLASS]]
        #"S" [reduce [NON-SPACE-CLASS]]
        
        ;; Whitespace escape sequences
        #"n" [reduce [ESCAPED-CHAR #"^/"]]      ;; Newline
        #"t" [reduce [ESCAPED-CHAR #"^-"]]      ;; Tab
        #"r" [reduce [ESCAPED-CHAR #"^M"]]      ;; Carriage return
        
        ;; Meta-character escape sequences (literal versions)
        #"\" [reduce [ESCAPED-CHAR #"\"]]       ;; Literal backslash
        #"." [reduce [ESCAPED-CHAR #"."]]       ;; Literal dot
        #"+" [reduce [ESCAPED-CHAR #"+"]]       ;; Literal plus
        #"*" [reduce [ESCAPED-CHAR #"*"]]       ;; Literal star
        #"?" [reduce [ESCAPED-CHAR #"?"]]       ;; Literal question
        ;; Note: Caret character escaping removed due to REBOL syntax limitations
        #"$" [reduce [ESCAPED-CHAR #"$"]]       ;; Literal dollar
        #"(" [reduce [ESCAPED-CHAR #"("]]       ;; Literal left paren
        #")" [reduce [ESCAPED-CHAR #")"]]       ;; Literal right paren
        #"[" [reduce [ESCAPED-CHAR #"["]]       ;; Literal left bracket
        #"]" [reduce [ESCAPED-CHAR #"]"]]       ;; Literal right bracket
        #"{" [reduce [ESCAPED-CHAR #"{"]]       ;; Literal left brace
        #"}" [reduce [ESCAPED-CHAR #"}"]]       ;; Literal right brace
        #"|" [reduce [ESCAPED-CHAR #"|"]]       ;; Literal pipe
    ]
    
    ;; Check if escape sequence was valid
    if none? token [
        ;; Invalid escape sequence - return error
        return reduce ['error rejoin ["Invalid escape sequence: \" escape-char]]
    ]
    
    ;; Advance position past escape sequence
    state/position: state/position + 2
    
    token
]

;;=============================================================================
;; QUANTIFIER PROCESSING
;;=============================================================================

ProcessQuantifier: funct [
    "Process quantifier characters and ranges"
    state [object!] "Tokenizer state"
    quantifier-char [char!] "Quantifier character (+, *, ?, {)"
    return: [block! none!] "Quantifier token or none if invalid"
] [
    token: none
    
    switch quantifier-char [
        #"+" [
            token: reduce [QUANTIFIER-PLUS]
            state/position: state/position + 1
        ]
        #"*" [
            token: reduce [QUANTIFIER-STAR]
            state/position: state/position + 1
        ]
        #"?" [
            token: reduce [QUANTIFIER-OPTIONAL]
            state/position: state/position + 1
        ]
        #"{" [
            ;; Process quantifier range {n} or {n,m}
            token: ProcessQuantifierRange state
        ]
    ]
    
    token
]

ProcessQuantifierRange: funct [
    "Process quantifier range like {3} or {2,5}"
    state [object!] "Tokenizer state"
    return: [block! none!] "Quantifier range token or none if invalid"
] [
    ;; Find the closing brace
    start-pos: to integer! (state/position + 1)  ;; Skip opening brace, ensure integer
    end-pos: none
    input-length: to integer! length? state/input
    
    ;; Search for closing brace
    if start-pos <= input-length [
        search-length: input-length - start-pos + 1
        repeat i search-length [
            check-pos: start-pos + i - 1
            if check-pos <= input-length [
                if (pick state/input check-pos) = #"}" [
                    end-pos: check-pos
                    break
                ]
            ]
        ]
    ]
    
    if none? end-pos [
        return none  ;; No closing brace found
    ]
    
    ;; Extract quantifier specification using string positions
    quantifier-spec: copy/part (at state/input start-pos) (end-pos - start-pos)
    
    ;; Validate the quantifier specification
    if not ValidateQuantifierRange quantifier-spec [
        return none
    ]
    
    ;; Parse the specification
    token: either find quantifier-spec "," [
        ;; Range quantifier {n,m}
        range-parts: split quantifier-spec ","
        min-count: to integer! trim range-parts/1
        max-count: to integer! trim range-parts/2
        reduce [QUANTIFIER-RANGE min-count max-count]
    ] [
        ;; Exact quantifier {n}
        exact-count: to integer! trim quantifier-spec
        reduce [QUANTIFIER-EXACT exact-count]
    ]
    
    ;; Advance position past the quantifier range
    state/position: end-pos + 1
    
    token
]

;;=============================================================================
;; CHARACTER CLASS PROCESSING
;;=============================================================================

ProcessCharacterClass: funct [
    "Process character class like [a-z] or [^0-9]"
    state [object!] "Tokenizer state"
    return: [block! none!] "Character class token or none if invalid"
] [
    ;; Find the closing bracket
    start-pos: state/position + 1  ;; Skip opening bracket
    end-pos: none
    
    ;; Search for closing bracket (handle escaped brackets)
    pos: start-pos
    while [pos <= length? state/input] [
        current-char: pick state/input pos
        if current-char = #"]" [
            ;; Check if this bracket is escaped
            either pos > 1 [
                prev-char: pick state/input (pos - 1)
                if prev-char <> #"\" [
                    end-pos: pos
                    break
                ]
            ] [
                end-pos: pos
                break
            ]
        ]
        pos: pos + 1
    ]
    
    if none? end-pos [
        return none  ;; No closing bracket found
    ]
    
    ;; Extract character class specification
    length-to-copy: end-pos - start-pos
    class-spec: copy/part (at state/input start-pos) length-to-copy
    
    ;; Check for negated character class using [!...] or [^...] syntax
    negated: false
    if not empty? class-spec [
        if any [class-spec/1 = #"!" class-spec/1 = TypChrCaret] [
            negated: true
            class-spec: next class-spec
        ]
    ]
    
    ;; Validate the character class specification
    if not ValidateCharacterClass class-spec [
        return none
    ]
    
    ;; Create the token using correct structure
    token: either negated [
        reduce [NEGATED-CLASS class-spec]
    ] [
        reduce [CUSTOM-CLASS 'normal class-spec]
    ]
    
    ;; Advance position past the character class
    state/position: end-pos + 1
    
    token
]

;;=============================================================================
;; GROUP PROCESSING
;;=============================================================================

ProcessGroup: funct [
    "Process group markers ( and )"
    state [object!] "Tokenizer state"
    group-char [char!] "Group character ( or )"
    return: [block!] "Group token"
] [
    token: switch group-char [
        #"(" [
            state/group-depth: state/group-depth + 1
            reduce [GROUP 'open]
        ]
        #")" [
            state/group-depth: state/group-depth - 1
            reduce [GROUP 'close]
        ]
    ]
    
    state/position: state/position + 1
    token
]

;;=============================================================================
;; MAIN TOKENIZATION FUNCTIONS
;;=============================================================================

TokenizePattern: funct [
    "Advanced pattern tokenization with meta-character handling"
    pattern [string!] "String pattern to tokenize"
    return: [block!] "Processed token block"
] [
    ;; Initialize tokenizer state
    state: make TokenizerState []
    ResetTokenizerState state pattern
    
    ;; Main tokenization loop with safety counter
    loop-counter: 0
    max-loops: 10000
    
    while [all [state/position <= length? state/input loop-counter < max-loops]] [
        loop-counter: loop-counter + 1
        current-char: pick state/input state/position
        
        ;; Create token based on character type
        token: none
        
        ;; Handle specific characters first
        switch current-char [
            #"\" [
                ;; Check if this is a consecutive backslash (\\)
                either all [
                    (state/position + 1) <= length? state/input
                    (pick state/input (state/position + 1)) = #"\"
                ] [
                    ;; This is \\, treat as literal backslash and let next iteration handle the second one
                    token: reduce [reduce [LITERAL #"\"]]
                    state/position: state/position + 1
                ] [
                    ;; Regular escape sequence - wrap result in compound block if needed
                    raw-token: ProcessEscapeSequence state
                    either raw-token [
                        ;; Check if it's already a compound token or needs wrapping
                        either all [block? raw-token (length? raw-token) = 2 word? raw-token/1] [
                            ;; Simple token like [ESCAPED-CHAR #"."] - wrap it
                            token: reduce [raw-token]
                        ] [
                            ;; Already a simple word token like [DIGIT-CLASS] - use as is
                            token: raw-token
                        ]
                    ] [
                        ;; ProcessEscapeSequence returned none - this is an error
                        token: reduce ['error "Incomplete or invalid escape sequence"]
                    ]
                ]
            ]
            #"+" [
                token: reduce [QUANTIFIER-PLUS]
                state/position: state/position + 1
            ]
            #"*" [
                token: reduce [QUANTIFIER-STAR]
                state/position: state/position + 1
            ]
            #"?" [
                token: reduce [QUANTIFIER-OPTIONAL]
                state/position: state/position + 1
            ]
            #"." [
                token: reduce [WILDCARD]
                state/position: state/position + 1
            ]
            #"|" [
                token: reduce [ALTERNATION]
                state/position: state/position + 1
            ]
            #"{" [
                ;; Quantifier range - wrap result in compound block or return error
                raw-token: ProcessQuantifier state current-char
                either raw-token [
                    token: reduce [raw-token]
                ] [
                    ;; ProcessQuantifier failed - malformed quantifier
                    token: reduce ['error "Malformed quantifier range"]
                    state/position: state/position + 1  ;; Advance past the {
                ]
            ]
            #"[" [
                ;; Character class - wrap result in compound block or return error
                raw-token: ProcessCharacterClass state
                either raw-token [
                    token: reduce [raw-token]
                ] [
                    ;; ProcessCharacterClass failed - unclosed character class
                    token: reduce ['error "Unclosed character class"]
                    state/position: state/position + 1  ;; Advance past the [
                ]
            ]
            #"(" [
                ;; Group open - wrap result in compound block
                raw-token: ProcessGroup state current-char
                if raw-token [
                    token: reduce [raw-token]
                ]
            ]
            #")" [
                ;; Group close - wrap result in compound block
                raw-token: ProcessGroup state current-char
                if raw-token [
                    token: reduce [raw-token]
                ]
            ]
        ]
        
        ;; Handle default case outside switch to avoid variable evaluation issues
        if none? token [
            either current-char = #"^(5E)" [
                either state/position = 1 [
                    token: reduce [ANCHOR-START]
                ] [
                    token: reduce [reduce [LITERAL current-char]]
                ]
            ] [
                either current-char = #"$" [
                    either state/position = length? state/input [
                        token: reduce [ANCHOR-END]
                    ] [
                        token: reduce [reduce [LITERAL current-char]]
                    ]
                ] [
                    token: reduce [reduce [LITERAL current-char]]
                ]
            ]
            state/position: state/position + 1
        ]
        
        ;; Add token to result
        if token [
            append state/tokens token
        ]
    ]
    
    state/tokens
]

PreprocessMetaCharacters: funct [
    "Preprocess string to handle REBOL meta-character conflicts"
    pattern [string!] "Original pattern string"
    return: [string!] "Preprocessed pattern string"
] [
    ;; For now, return the pattern as-is since we handle meta-characters
    ;; during tokenization. This function is available for future enhancements.
    pattern
]

StringToPatternBlock: funct [
    "Convert string pattern to semantic block tokens"
    pattern [string!] "User-provided string pattern"
    return: [block!] "Semantic token block"
] [
    ;; Preprocess the pattern if needed
    preprocessed-pattern: PreprocessMetaCharacters pattern
    
    ;; Tokenize the pattern
    tokens: TokenizePattern preprocessed-pattern
    
    ;; Check if any tokens are error tokens
    foreach token tokens [
        if all [word? token token = 'error] [
            ;; Found an error token - return it immediately
            return tokens
        ]
        if all [block? token not empty? token word? token/1 token/1 = 'error] [
            ;; Found a compound error token - return it immediately
            return tokens
        ]
    ]
    
    ;; Validate the token sequence
    validation-result: ValidateTokenSequence tokens
    
    ;; Handle validation errors
    if string? validation-result [
        ;; Return error token for invalid sequences
        return reduce ['error validation-result]
    ]
    
    ;; Return the validated tokens
    tokens
]

;;=============================================================================
;; UTILITY FUNCTIONS FOR DEBUGGING AND TESTING
;;=============================================================================

TokensToString: funct [
    "Convert token block back to readable string representation"
    tokens [block!] "Token block to convert"
    return: [string!] "String representation of tokens"
] [
    result: make string! 200
    
    foreach token tokens [
        token-str: either block? token [
            ;; Compound token
            token-type: token/1
            switch token-type [
                anchor-start [to string! TypChrCaret]
                anchor-end ["$"]
                digit-class ["\d"]
                non-digit-class ["\D"]
                word-class ["\w"]
                non-word-class ["\W"]
                space-class ["\s"]
                non-space-class ["\S"]
                wildcard ["."]
                quantifier-plus ["+"]
                quantifier-star ["*"]
                quantifier-optional ["?"]
                quantifier-exact [rejoin ["{" token/2 "}"]]
                quantifier-range [rejoin ["{" token/2 "," token/3 "}"]]
                custom-class [
                    rejoin ["[" token/2 "]"]
                ]
                negated-class [
                    rejoin ["[!" token/2 "]"]
                ]
                group [either token/2 = 'open ["("] [")"]]
                alternation ["|"]
                escaped-char [rejoin ["\" token/2]]
                literal [to string! token/2]
                default [rejoin ["<" token-type ">"]]
            ]
        ] [
            ;; Simple token
            switch token [
                anchor-start [to string! TypChrCaret]
                anchor-end ["$"]
                digit-class ["\d"]
                non-digit-class ["\D"]
                word-class ["\w"]
                non-word-class ["\W"]
                space-class ["\s"]
                non-space-class ["\S"]
                wildcard ["."]
                quantifier-plus ["+"]
                quantifier-star ["*"]
                quantifier-optional ["?"]
                alternation ["|"]
                default [rejoin ["<" token ">"]]
            ]
        ]
        
        append result token-str
    ]
    
    result
]

;;=============================================================================
;; MODULE EXPORTS
;;=============================================================================

;; Export main functions for use by other modules
;; StringToPatternBlock - Main conversion function
;; TokenizePattern - Advanced tokenization function  
;; PreprocessMetaCharacters - Meta-character preprocessing
