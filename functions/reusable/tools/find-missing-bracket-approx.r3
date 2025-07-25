REBOL [
    Title: "Rebol 3 Missing Square Bracket Finder (Report Opening Bracket)"
    Author: "Qwen 3 Coder"
    File: %find-missing-brackets.r3
    Date:   25-Jul-2025
    Purpose: {
        Analyzes a Rebol 3 (.r3) script file to find syntax errors caused by
        unmatched square brackets '[' and ']'. Reports the approximate location of unexpected
        closing brackets or indicates the number and locations of missing closing brackets.
        Ignores brackets within strings ("...", {...}) and comments (;...).
        Supports UTF-8 and common Unicode text files.
        Reports the location of the opening bracket(s) that are missing their closing match.
        Complies with r3oToy Rebol style guide.
    }
    Usage: { r3 find-missing-brackets.r3 <script-file.r3> }
]

; --- PROVIDED STDERR OUTPUT FUNCTION ---
eprt: function [
    {Output / write any datatype to stderr.}
   the-value-to-write [any-type!]
   /no-nln "Suppress newline output."
][
    secure [file allow]
    stderr: open %/dev/stderr
    write stderr the-value-to-write

    if not no-nln [write stderr newline]
    close stderr
]

; --- Helper Functions ---

; Prints an error message to stderr using the provided eprt function
print-error: func [
    msg [block!] "Message block to form and print"
] [
    eprt/no-nln rejoin msg
    eprt ""
]

; Prints usage information to stderr
print-usage: does [
    print-error ["Usage: " system/script/header/File " <script-file.r3>"]
]

; Checks if a character is considered whitespace
is-whitespace-char: func [ch [char!]] [
    find "^(0009) ^(0020) ^(000A) ^(000D)" ch ; Tab, Space, Newline, Carriage Return
]

; Gets a snippet of text around a specific line from the content string
get-line-snippet: func [
    content-str [string!] "The full file content"
    target-line [integer!] "The 1-based line number"
    /local lines snippet start-line end-line i
][
    lines: split content-str "^/"
    either any [target-line < 1 target-line > length? lines] [
        return "..."
    ] [
        start-line: max 1 (target-line - 1)
        end-line: min (length? lines) (target-line + 1)
        snippet: copy ""
        for i start-line end-line 1 [
            append snippet rejoin [i ": "]
            append snippet pick lines i
            if i < end-line [append snippet "^/"]
        ]
        return snippet
    ]
]


; --- 1. Argument Validation (FR-2) ---
script-file-arg: system/script/args
either any [script-file-arg = none script-file-arg = ""] [
    print-error ["Error: No script file provided."]
    print-usage
    quit/return 1
] [
    script-file: to-file script-file-arg
]

; --- 2. Input Handling & File Access (FR-1) ---
either exists? script-file [
    ; File exists, proceed
] [
    print-error ["Error: File '" script-file "' does not exist."]
    quit/return 1
]

; --- Robust File Reading (Handles Binary/UTF-8) ---
content: ""
read-error: none
read-error: attempt [binary-content: read/binary script-file none]
either error? read-error [
     print-error ["Error reading file '" script-file "' (binary read failed):"]
     print-error ["  Type: " type? read-error]
     print-error ["  Message: " get in read-error 'message]
     quit/return 1
] [
    ; Read succeeded, check type
]

either binary? binary-content [
    conversion-error: attempt [content: to-string binary-content none]
    either error? conversion-error [
         print-error ["Error converting binary content of '" script-file "' to string:"]
         print-error ["  Type: " type? conversion-error]
         print-error ["  Message: " get in conversion-error 'message]
         quit/return 1
    ] [
        ; Conversion succeeded, check final type
    ]
    either string? content [
        ; Final content is string, proceed
    ] [
         print-error [
             "Error: Failed to obtain valid text content from file '" script-file "'."
             " Conversion resulted in type: " type? content
         ]
         quit/return 1
    ]
] [
     print-error ["Error: 'read/binary' did not return binary data for '" script-file "'."]
     print-error ["  Returned type: " type? binary-content]
     quit/return 1
]

; --- 3. State Tracking Variables ---
bracket-stack: make block! 100 ; Stores [start-line start-col]
current-line: 1
current-col: 1
pos: 1
len: length? content

in-double-quote-string: false
in-brace-string: false
brace-string-level: 0
in-comment: false
error-found: false

; --- 4. Main Parsing Loop (FR-3) ---
while [pos <= len] [
    char: pick content pos

    case [
        char = #"^/" [
            current-line: current-line + 1
            current-col: 1
            in-comment: false
        ]
        true [
            current-col: current-col + 1
        ]
    ]

    either in-comment [
        pos: pos + 1
        continue
    ] [
        ; Not in comment
    ]

    either in-double-quote-string [
        either all [
            char = #"^""
            (pos + 1) <= len
            (pick content pos + 1) = #"^""
        ] [
            pos: pos + 2
            current-col: current-col + 2
            continue
        ] [
            either char = #"^"" [
                in-double-quote-string: false
            ] [
                ; Other chars in string
            ]
        ]
        pos: pos + 1
        continue
    ] [
        ; Not in double quote string
    ]

    either in-brace-string [
        either char = #"{" [
            brace-string-level: brace-string-level + 1
        ] [
            either char = #"}" [
                brace-string-level: brace-string-level - 1
                either brace-string-level = 0 [
                    in-brace-string: false
                ] [
                    ; Nested
                ]
            ] [
                ; Other chars in brace string
            ]
        ]
        pos: pos + 1
        continue
    ] [
        ; Not in brace string
    ]

    either char = #"^"" [
        in-double-quote-string: true
        pos: pos + 1
        continue
    ] [
        either char = #"{" [
            in-brace-string: true
            brace-string-level: 1
            pos: pos + 1
            continue
        ] [
            either char = #";" [
                in-comment: true
                pos: pos + 1
                continue
            ] [
                case [
                    char = #"[" [
                        append/only bracket-stack reduce [current-line current-col]
                    ]
                    char = #"]" [
                        either empty? bracket-stack [
                            print-error [
                                "Unexpected closing bracket ']' found at Line " current-line
                                " Column " current-col "."
                            ]
                            error-found: true
                            break
                        ] [
                            take/last bracket-stack
                        ]
                    ]
                ]
                pos: pos + 1
            ]
        ]
    ]
]

; --- 5. Final Check after Parsing (FR-4) - REPORT OPENING BRACKET LOCATIONS ---
either error-found [
    ; Error already reported
] [
    either empty? bracket-stack [
        print "No unmatched square brackets found." ; Standard output (FR-5.4)
    ] [
        num-missing: length? bracket-stack
        print-error [
            "Error: Missing " num-missing " closing bracket(s) ']'."
        ]

        ; --- REPORT THE LOCATIONS OF THE UNMATCHED OPENING BRACKETS ---
        print-error ["Unclosed bracket(s) start at:"]
        foreach bracket-pos bracket-stack [
            br-line: first bracket-pos
            br-col: second bracket-pos
            print-error [
                "  * Line " br-line " Column " br-col
            ]
            ; --- Provide context snippet ---
            snippet: get-line-snippet content br-line
            either string? snippet [
                ; Indent the snippet for readability
                print-error [ "    " replace/all copy snippet "^/" rejoin ["^/    "]]
            ] [
                ; Ignore snippet error
            ]
        ]
        error-found: true
    ]
]

; --- 6. Exit Status (FR-6) ---
either error-found [quit/return 1] [quit/return 0]
