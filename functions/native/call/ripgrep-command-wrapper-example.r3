REBOL []

;; =============================================================================
;; RIPGREP COMMAND WRAPPER - Claude 4 Sonnet
;; =============================================================================
;; This script executes a ripgrep command to search for patterns in a text file
;; and processes the output into a usable block format.
;;
;; RIPGREP OPTIONS REFERENCE:
;; /shell: Force command to be run from a shell
;; /wait: Wait for command to finish before returning from call
;; --case-sensitive: Default mode (vs --ignore-case)
;; --pcre2: Use PCRE2 compatible regular expressions
;; --fixed-strings: Treat search patterns as literals, not regex
;; --invert-match: Output non-matching lines
;; --line-regexp: Only match entire lines
;; --max-count=NUM: Limit output to first NUM matches
;; --multiline: Apply pattern across multiple lines
;; --no-unicode: Disable Unicode support
;; --ignore-file=PATH: Specify ignore file
;; --color=never: Disable colored output
;; --no-heading: Suppress file headings
;; --no-line-number: Suppress line numbers
;; --quiet: No output except exit code
;; --sort=SORTBY: Sort results (path, modified)
;; --trim: Remove leading ASCII whitespace
;; --no-filename: Suppress filename in output
;; --count: Show only count of matches
;; --count-matches: Count individual matches
;; --files-with-matches: Show only filenames with matches
;; =============================================================================

;; Initialize variables with proper Rebol naming conventions
target-file: "acronyms.txt"
cmd-output-str: ""
exit-code: 0

;; Build the ripgrep command
;; Pattern: Lines starting with 'Z' followed by optional content
;; Using ^ for line start anchor (escaped as ^^ in Rebol strings)
rg-command: {rg --color=never --no-heading --no-line-number "^^Z.*" acronyms.txt}

;; Execute the command and capture output
print ["Executing command:" rg-command]
exit-code: call/wait/shell/output rg-command cmd-output-str

;; Process results based on exit code
either 0 = exit-code [
    ;; Command succeeded - process the output
    either empty? cmd-output-str [
        print "Command succeeded but returned no output."
    ][
        ;; Split output into lines and clean up
        output-lines: split cmd-output-str newline
        
        ;; Remove empty lines (including the typical trailing newline)
        output-lines: remove-each line output-lines [empty? line]
        
        ;; Display results if any lines remain
        either empty? output-lines [
            print "No matching lines found after filtering."
        ][
            print ["Found" length? output-lines "matching lines:"]
            print "--- RAW OUTPUT BLOCK ---"
            probe output-lines
            print "--- FIRST LINE ---"
            print output-lines/1
            print "--- LAST LINE ---"
            print last output-lines
        ]
    ]
][
    ;; Command failed or found no matches
    case [
        1 = exit-code [print "No matches found for the specified pattern."]
        2 = exit-code [print "Error: Invalid command line arguments or file not found."]
        true [print ["Command failed with exit code:" exit-code]]
    ]
]

print "Script execution completed."
