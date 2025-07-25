REBOL [
    Title: "Rebol 3 Missing Square Bracket Finder (Report Opening Bracket) - Fixed Helpers"
    Author: "Qwen 3 Coder"
    File: %find-missing-bracket-approx.r3
    Date:   25-Jul-2025
    Purpose: {
        Analyzes a Rebol 3 (.r3) script file to find syntax errors caused by
        unmatched square brackets '[' and ']'. Reports the approximate location of unexpected
        closing brackets or indicates the number and locations of missing closing brackets.
        Ignores brackets within strings ("...", {...}) and comments (;...).
        Supports UTF-8 and common Unicode text files.
        Reports the location of the opening bracket(s) that are missing their closing match.
        Complies with r3oToy Rebol style guide.
        Uses fixed and enhanced helper functions.
    }
    Usage: { r3 find-missing-brackets.r3 <script-file.r3> }
]

; --- FIXED & ENHANCED Helper Functions ---

eprt: function [
    {Write any Rebol value to the standard error stream (stderr).
    Writes any Rebol value to stderr with optional newline suppression.
    RETURNS: None (unset)
    ERRORS: May throw file system errors if stderr cannot be accessed.}
    the-value-to-write [any-type!] "The value to output."
    /no-nln "If set, suppresses the trailing newline character."
] [
    secure [file allow]
    stderr: open %/dev/stderr
    write stderr the-value-to-write
    if not no-nln [write stderr newline]
    close stderr
]

print-error: function [
    {Formats a message block and prints it to stderr using eprt.
    Formats and prints error messages to stderr.
    RETURNS: None (unset)
    ERRORS: Propagates any errors from eprt function.}
    msg [block!] "Block of values to form and print as an error."
] [
    eprt/no-nln rejoin msg
    eprt "" ; Print a newline
]

print-usage: function [
    {Prints usage information to stderr.
    Prints the standard usage message for this script.
    RETURNS: None (unset)
    ERRORS: Propagates errors from print-error.}
] [
    print-error ["Usage: " system/script/header/File " <script-file.r3>"]
]

is-whitespace-char: function [
    {Checks if a character is a common whitespace character (Tab, Space, NL, CR).
    Tests if a character is whitespace (space, tab, newline, or carriage return).
    RETURNS: Logic value (true if whitespace, false otherwise)
    ERRORS: None}
    ch [char!] "The character to test."
] [
    ; FIXED: Ensure logic return value.
    not none? find "^(0009)^(0020)^(000A)^(000D)" ch ; Tab, Space, Newline, Carriage Return
]

get-line-snippet: function [
    {Extracts a text snippet around a specific line number.
    Extracts lines around a target line (default: target +/- 1 line).
    RETURNS: String containing the snippet with line numbers, or "..." for invalid lines
    ERRORS: None (returns "..." for invalid input)}
    content-str [string!] "The source string containing multiple lines."
    target-line [integer!] "The 1-based line number for the center of the snippet."
    /context-lines "Specify the number of lines of context (default is 1 line before/after)."
    num-context [integer!] "Number of lines before and after."
] [
    ; FIXED: Use `newline`, `function`, removed `/local`.
    ; ENHANCEMENT: Added /context-lines refinement.
    either context-lines [
        if num-context < 0 [num-context: 0]
    ] [
        ; Default behavior: 1 line before and after (original script's intent).
        num-context: 1
    ]

    lines: split content-str newline
    num-lines: length? lines

    if any [target-line < 1 target-line > num-lines] [
        return "..."
    ]

    start-line: max 1 (target-line - num-context)
    end-line: min num-lines (target-line + num-context)

    snippet: copy ""
    for i start-line end-line 1 [
        append snippet rejoin [i ": "]
        append snippet pick lines i
        if i < end-line [append snippet newline]
    ]
    return snippet
]

read-text-file: function [
    {Robustly reads a text file, attempting to handle binary/UTF-8 content.
    Robustly reads a text file with proper error handling and UTF-8 support.
    RETURNS: String content of the file, or error! if reading fails
    ERRORS: Returns error! for file system errors or conversion failures}
    file [file!] "The path to the file to read."
] [
    ; ENHANCEMENT: Added robust file reading helper.
    set/any 'read-result try [read/binary file]
    if error? read-result [return read-result]

    either binary? read-result [
        binary-content: read-result
    ] [
        return make error! rejoin ["'read/binary' did not return binary data for '" file "'."]
    ]

    set/any 'conversion-result try [to-string binary-content]
    if error? conversion-result [return conversion-result]

    either string? conversion-result [
        return conversion-result
    ] [
        return make error! rejoin [
            "Failed to obtain valid text content from file '" file "'. Conversion resulted in type: " type? conversion-result
        ]
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

; --- Robust File Reading (Handles Binary/UTF-8) - FIXED/ENHANCED ---
; Replaced original inline logic with call to new helper function.
content: read-text-file script-file
if error? content [
     print-error ["Error reading/converting file '" script-file "':"]
     print-error ["  Type: " type? content]
     print-error ["  Message: " get in content 'message]
     quit/return 1
]
; If no error, 'content' is now the string content of the file.
; --- State Tracking Variables ---
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
            snippet: get-line-snippet content br-line ; Uses default context (line +/- 1)
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
