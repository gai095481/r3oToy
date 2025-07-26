REBOL [
    Title: "REBOL 3 Regular Expressions Engine - Pattern Processor Module"
    Date: 20-Jul-2025
    File: %regexp-pattern-processor.r3
    Author: "Enhanced by Kiro AI Assistant"
    Version: "2.0.0"
    Purpose: "Pattern translation and preprocessing for RegExp engine"
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
    print "ERROR: Failed to load regexp-core-utils.r3 in pattern processor"
    print ["Error details:" core-utils-result]
    halt
]

;;=============================================================================
;; GROUPED QUANTIFIER PREPROCESSING
;;=============================================================================

PreprocessGroupedQuantifiers: funct [
    "Preprocess grouped quantifiers like (pattern){n} by expanding them"
    pattern [string!] "Regular expression pattern to preprocess"
    return: [string!] "Preprocessed pattern with expanded groups"
] [
    ;; GROUPED QUANTIFIER PREPROCESSING FIX
    ;; Handle patterns like (\w\d\s){3} - expand to \w\d\s\w\d\s\w\d\s
    preprocessed-pattern: copy pattern
    
    if find preprocessed-pattern "(" [
        ;; Look for patterns like (pattern){n}
        group-content: none
        count-str: none
        parse preprocessed-pattern [
            some [
                "(" copy group-content to ")" skip "{" copy count-str to "}" skip (
                    ;; Try to convert count to integer
                    count-result: none
                    set/any 'count-result try [to integer! count-str]
                    if all [not error? count-result count-result > 0 count-result < 10] [
                        ;; Expand the group
                        expanded: copy ""
                        repeat i count-result [
                            append expanded group-content
                        ]
                        ;; Replace the grouped quantifier with the expanded version
                        group-pattern: rejoin ["(" group-content "){" count-str "}"]
                        preprocessed-pattern: replace preprocessed-pattern group-pattern expanded
                    ]
                ) |
                skip
            ]
        ]
    ]
    
    preprocessed-pattern
]

;;=============================================================================
;; MAIN PATTERN TRANSLATION ENGINE
;;=============================================================================

TranslateRegExp: funct [
    "Translate regular expression to parse rules"
    strRegExp [string!] "Regular expression pattern to translate"
    return: [block! none!] "Parse rules block or none if translation fails"
] [
    ;; Handle empty pattern
    if empty? strRegExp [
        return none  ;; Empty pattern should fail
    ]
    
    ;; Preprocess grouped quantifiers
    preprocessed-pattern: PreprocessGroupedQuantifiers strRegExp
    
    ;; Initialize result block and parse variables
    blkRules: copy []
    translation-result: none
    strCount: none
    strSetSpec: none
    charEscape: none
    charCurrent: none
    blkAlternate: none
    quantifier-rule: none
    charset-result: none
    
    ;; Wrap the entire translation process in error handling
    set/any 'translation-result try [
        parse-success: parse/case preprocessed-pattern [
            some [
                ;; Handle escape sequences first (before general escaping)
                "\" [
                    "d" [
                        "+" (
                            append blkRules reduce ['some digit-charset]
                        ) |
                        "*" (
                            append blkRules reduce ['any digit-charset]
                        ) |
                        "?" (
                            append blkRules reduce ['opt digit-charset]
                        ) |
                        "{" copy strCount to "}" skip (
                            quantifier-rule: ProcessQuantifierSafely strCount digit-charset
                            either quantifier-rule [
                                append blkRules quantifier-rule
                            ] [
                                ;; Invalid quantifier - fail translation
                                fail
                            ]
                        ) |
                        (
                            append blkRules digit-charset
                        )
                    ] |
                    "w" [
                        "+" (append blkRules reduce ['some word-charset]) |
                        "*" (append blkRules reduce ['any word-charset]) |
                        "?" (append blkRules reduce ['opt word-charset]) |
                        "{" copy strCount to "}" skip (
                            quantifier-rule: ProcessQuantifierSafely strCount word-charset
                            either quantifier-rule [
                                append blkRules quantifier-rule
                            ] [
                                ;; Invalid quantifier - fail translation
                                fail
                            ]
                        ) |
                        (append blkRules word-charset)
                    ] |
                    "s" [
                        "+" (append blkRules compose [some space-charset]) |
                        "*" (append blkRules compose [any space-charset]) |
                        "?" (append blkRules compose [opt space-charset]) |
                        "{" copy strCount to "}" skip (
                            quantifier-rule: ProcessQuantifierSafely strCount space-charset
                            either quantifier-rule [
                                append blkRules quantifier-rule
                            ] [
                                ;; Invalid quantifier - fail translation
                                fail
                            ]
                        ) |
                        (append blkRules space-charset)
                    ] |
                    "D" [
                        "+" (append blkRules compose [some (complement MakeCharSet "0-9")]) |
                        "*" (append blkRules compose [any (complement MakeCharSet "0-9")]) |
                        "?" (append blkRules compose [opt (complement MakeCharSet "0-9")]) |
                        "{" copy strCount to "}" skip (
                            quantifier-rule: ProcessQuantifierSafely strCount (complement MakeCharSet "0-9")
                            either quantifier-rule [
                                append blkRules quantifier-rule
                            ] [
                                ;; Invalid quantifier - fail translation
                                fail
                            ]
                        ) |
                        (append blkRules complement MakeCharSet "0-9")
                    ] |
                    "S" [
                        "+" (append blkRules compose [some (complement MakeCharSet " ^-^/")]) |
                        "*" (append blkRules compose [any (complement MakeCharSet " ^-^/")]) |
                        "?" (append blkRules compose [opt (complement MakeCharSet " ^-^/")]) |
                        "{" copy strCount to "}" skip (
                            quantifier-rule: ProcessQuantifierSafely strCount (complement MakeCharSet " ^-^/")
                            either quantifier-rule [
                                append blkRules quantifier-rule
                            ] [
                                ;; Invalid quantifier - fail translation
                                fail
                            ]
                        ) |
                        (append blkRules complement MakeCharSet " ^-^/")
                    ] |
                    "W" [
                        "+" (append blkRules compose [some (complement MakeCharSet "0-9A-Za-z_")]) |
                        "*" (append blkRules compose [any (complement MakeCharSet "0-9A-Za-z_")]) |
                        "?" (append blkRules compose [opt (complement MakeCharSet "0-9A-Za-z_")]) |
                        "{" copy strCount to "}" skip (
                            quantifier-rule: ProcessQuantifierSafely strCount (complement MakeCharSet "0-9A-Za-z_")
                            either quantifier-rule [
                                append blkRules quantifier-rule
                            ] [
                                ;; Invalid quantifier - fail translation
                                fail
                            ]
                        ) |
                        (append blkRules complement MakeCharSet "0-9A-Za-z_")
                    ] |
                    "(" (append blkRules [collect [keep (copy [])]]) |
                    ")" (append blkRules []) |
                    "." (append blkRules 'skip) |
                    "\" (append blkRules #"\") |  ;; Escaped backslash
                    ;; Handle invalid escape sequences as literals (just the character, not backslash+char)
                    charEscape: skip (
                        ;; Invalid escape sequence - treat as literal character without backslash
                        append blkRules charEscape/1
                    )
                ] |
                "." [
                    "+" (append blkRules compose [some (complement charset "^/")]) |
                    "*" (append blkRules compose [any (complement charset "^/")]) |
                    "?" (append blkRules compose [opt (complement charset "^/")]) |
                    "{" copy strCount to "}" skip (
                        quantifier-rule: ProcessQuantifierSafely strCount (complement charset "^/")
                        either quantifier-rule [
                            append blkRules quantifier-rule
                        ] [
                            ;; Invalid quantifier - fail translation
                            fail
                        ]
                    ) |
                    (append blkRules complement charset "^/")
                ] |
                ;; Handle character classes [...]
                "[" [
                    copy strSetSpec to "]" skip [
                        ;; Validate character class first
                        (
                            if not ValidateCharacterClass strSetSpec [
                                fail  ;; Invalid character class
                            ]
                        )
                        "+" (
                            charset-result: none
                            set/any 'charset-result try [
                                either strSetSpec/1 = TypChrCaret [
                                    complement MakeCharSet next strSetSpec
                                ] [
                                    MakeCharSet strSetSpec
                                ]
                            ]
                            either error? charset-result [
                                fail  ;; Character set creation failed
                            ] [
                                append blkRules compose [some (charset-result)]
                            ]
                        ) |
                        "*" (
                            charset-result: none
                            set/any 'charset-result try [
                                either strSetSpec/1 = TypChrCaret [
                                    complement MakeCharSet next strSetSpec
                                ] [
                                    MakeCharSet strSetSpec
                                ]
                            ]
                            either error? charset-result [
                                fail  ;; Character set creation failed
                            ] [
                                append blkRules compose [any (charset-result)]
                            ]
                        ) |
                        "?" (
                            charset-result: none
                            set/any 'charset-result try [
                                either strSetSpec/1 = TypChrCaret [
                                    complement MakeCharSet next strSetSpec
                                ] [
                                    MakeCharSet strSetSpec
                                ]
                            ]
                            either error? charset-result [
                                fail  ;; Character set creation failed
                            ] [
                                append blkRules compose [opt (charset-result)]
                            ]
                        ) |
                        "{" copy strCount to "}" skip (
                            charset-result: none
                            set/any 'charset-result try [
                                either strSetSpec/1 = TypChrCaret [
                                    complement MakeCharSet next strSetSpec
                                ] [
                                    MakeCharSet strSetSpec
                                ]
                            ]
                            either error? charset-result [
                                fail  ;; Character set creation failed
                            ] [
                                quantifier-rule: ProcessQuantifierSafely strCount charset-result
                                either quantifier-rule [
                                    append blkRules quantifier-rule
                                ] [
                                    fail  ;; Invalid quantifier
                                ]
                            ]
                        ) |
                        (
                            charset-result: none
                            set/any 'charset-result try [
                                either strSetSpec/1 = TypChrCaret [
                                    complement MakeCharSet next strSetSpec
                                ] [
                                    MakeCharSet strSetSpec
                                ]
                            ]
                            either error? charset-result [
                                fail  ;; Character set creation failed
                            ] [
                                append blkRules charset-result
                            ]
                        )
                    ] |
                    ;; Handle unclosed character class - fail immediately
                    (fail)
                ] |
                ;; Handle anchors
                TypChrCaret (append blkRules 'start) |
                "$" (append blkRules 'end) |
                ;; Handle alternation
                "|" (
                    blkAlternate: copy blkRules
                    clear blkRules
                    ;; Note: alternation will be completed when the pattern ends
                    ;; For now, just store the left side
                    append blkRules reduce ['alternation-left blkAlternate]
                ) |
                ;; Handle regular characters with quantifiers
                charCurrent: skip [
                    "+" (append blkRules compose [some (charCurrent/1)]) |
                    "*" (append blkRules compose [any (charCurrent/1)]) |
                    "?" (append blkRules compose [opt (charCurrent/1)]) |
                    "{" copy strCount to "}" skip (
                        quantifier-rule: ProcessQuantifierSafely strCount charCurrent/1
                        either quantifier-rule [
                            append blkRules quantifier-rule
                        ] [
                            ;; Invalid quantifier - fail translation
                            fail
                        ]
                    ) |
                    "{" (
                        ;; Unclosed quantifier brace - fail translation
                        fail
                    ) |
                    (append blkRules charCurrent/1)
                ]
            ]
        ]
        
        ;; Return the rules if parsing succeeded
        either parse-success [
            blkRules
        ] [
            none  ;; Parse failed
        ]
    ]
    
    ;; Handle any errors that occurred during translation
    either error? translation-result [
        none  ;; Return none for any translation error
    ] [
        translation-result  ;; Return successful translation result
    ]
]
