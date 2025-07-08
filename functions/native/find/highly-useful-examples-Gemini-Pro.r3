Rebol []

;;=============================================================================
;; Ten Practical Examples for FIND
;;=============================================================================
;; This script demonstrates real-world usage patterns for the find
;; function through ten practical examples suitable for daily programming tasks.
;;=============================================================================

;;-----------------------------------------------------------------------------
;; QA Test Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    either equal? expected actual [
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL PRACTICAL EXAMPLES PASSED"
    ][
        print "❌ SOME PRACTICAL EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Example 1: Extracting a Value from a Key-Value String
;;-----------------------------------------------------------------------------
extract-value-after-delimiter: function [
    {
        Finds a delimiter in a string and returns the trimmed value that follows.
        This is useful for parsing simple configuration lines or headers.
    }
    source-string [string!] "The string to parse (e.g., ""Key: Value"")."
    delimiter [char! string!] "The character or string that separates key and value."
][
    value: none
    if position: find/tail source-string delimiter [
        value: trim position
    ]
    value
]

test-value-extraction: does [
    print "  Testing Example 1: Extracting a Value from a Key-Value String"
    assert-equal "Value" extract-value-after-delimiter "Key: Value" ":" "Extracts simple value"
    assert-equal "rebol.org" extract-value-after-delimiter "Host=> rebol.org" "=>" "Extracts value with string delimiter"
    assert-equal "item" extract-value-after-delimiter " setting:item " ":" "Handles surrounding whitespace"
    assert-equal "" extract-value-after-delimiter "NoValue:" ":" "Handles empty value"
    assert-equal none extract-value-after-delimiter "No Delimiter" ":" "Returns none if delimiter not found"
]

;;-----------------------------------------------------------------------------
;; Example 2: Checking for a Configuration Flag
;;-----------------------------------------------------------------------------
has-flag?: function [
    {
        Checks for the presence of a specific flag (a word!) in a block.
        This is a common pattern for checking metadata or configuration blocks.
        RETURNS:
            A logic! value: true if the flag is found, false otherwise.
    }
    config-block [block!] "The block of configuration data to search."
    flag-word [word!] "The flag to search for."
][
    not none? find config-block flag-word
]

test-flag-checking: does [
    print "  Testing Example 2: Checking for a Configuration Flag"
    metadata: [author "Carl" version 1.2 secure log-output]
    assert-equal true has-flag? metadata 'secure "Returns true when flag is present"
    assert-equal true has-flag? metadata 'log-output "Returns true for the last flag"
    assert-equal false has-flag? metadata 'debug "Returns false when flag is not present"
    assert-equal false has-flag? [] 'any "Returns false for an empty block"
]

;;-----------------------------------------------------------------------------
;; Example 3: Finding the Last Matching Log Entry
;;-----------------------------------------------------------------------------
get-last-log-by-type: function [
    {
        Finds the last log entry of a specific type from a log block.
        Assumes log entries are blocks of a fixed size (2 in this case).
        RETURNS:
            The last matching log entry [block!] or [none!].
    }
    log-data [block!] "A block of log entries."
    log-type [word!] "The type of log entry to find (e.g., 'ERROR)."
    record-size [integer!] "The number of items per log entry."
][
    record-start: find/last/skip log-data log-type record-size
    either record-start [
        copy/part record-start record-size
    ][
        none
    ]
]

test-last-log-retrieval: does [
    print "  Testing Example 3: Finding the Last Matching Log Entry"
    log-block: [
        INFO "System start"
        DEBUG "Connecting to DB"
        INFO "Processing user 1"
        ERROR "Connection failed"
        INFO "Retrying..."
        ERROR "Permanent failure"
    ]
    assert-equal [ERROR "Permanent failure"] get-last-log-by-type log-block 'ERROR 2 "Finds the very last ERROR entry"
    assert-equal [INFO "Retrying..."] get-last-log-by-type log-block 'INFO 2 "Finds the last INFO entry"
    assert-equal none get-last-log-by-type log-block 'WARN 2 "Returns none for a type that doesn't exist"
]

;;-----------------------------------------------------------------------------
;; Example 4: Retrieving a Command-Line Argument's Value
;;-----------------------------------------------------------------------------
get-cli-option-value: function [
    {
        Finds an option (e.g., "--output") in a block of command-line args
        and returns its value (the following item).
        RETURNS:
            The value [any-type!] associated with the option, or [none!].
    }
    arg-block [block!] "The block of command-line arguments."
    option-name [string!] "The option to find (e.g., ""--file"")."
][
    value: none
    if position: find/tail arg-block option-name [
        if not tail? position [
            value: first position
        ]
    ]
    value
]

test-cli-option-parsing: does [
    print "  Testing Example 4: Retrieving a Command-Line Argument's Value"
    cli-args: ["--input" %data.txt "--mode" "fast" "--verbose"]
    assert-equal %data.txt get-cli-option-value cli-args "--input" "Finds a file path argument"
    assert-equal "fast" get-cli-option-value cli-args "--mode" "Finds a string argument"
    assert-equal none get-cli-option-value cli-args "--verbose" "Returns none for an option without a value"
    assert-equal none get-cli-option-value cli-args "--output" "Returns none for a non-existent option"
]

;;-----------------------------------------------------------------------------
;; Example 5: Filtering Log Messages with Wildcards
;;-----------------------------------------------------------------------------
filter-log-messages: function [
    {
        Searches a block of log strings and returns a new block containing only
        the strings that match the given wildcard pattern.
        RETURNS:
            A [block!] of matching strings.
    }
    log-list [block!] "A block of log strings to filter."
    pattern [string!] "The wildcard pattern to match (uses `*` and `?`)."
][
    results: copy []
    foreach message log-list [
        if find/any message pattern [
            append results message
        ]
    ]
    results
]

test-wildcard-log-filtering: does [
    print "  Testing Example 5: Filtering Log Messages with Wildcards"
    log-messages: [
        "INFO: [MOD_NET] Connection established"
        "WARN: [MOD_NET] Connection timeout"
        "INFO: [MOD_UI] Button clicked"
        "ERROR: [MOD_NET] Socket closed"
    ]
    assert-equal [
        "INFO: [MOD_NET] Connection established"
        "WARN: [MOD_NET] Connection timeout"
        "ERROR: [MOD_NET] Socket closed"
    ] filter-log-messages log-messages "*[MOD_NET]*" "Filters for all MOD_NET messages"

    assert-equal [
        "WARN: [MOD_NET] Connection timeout"
    ] filter-log-messages log-messages "WARN:*" "Filters for messages starting with WARN:"

    assert-equal [] filter-log-messages log-messages "*MOD_DB*" "Returns empty block for no matches"
]

;;-----------------------------------------------------------------------------
;; Example 6: Finding a Record by ID in a Fixed-Size Record List
;;-----------------------------------------------------------------------------
get-record-by-id: function [
    {
        Finds a record in a flat block where records have a fixed size.
        Assumes the ID is the first element of each record.
        RETURNS:
            A [block!] containing the record, or [none!].
    }
    database-block [block!] "A flat block of data."
    record-id [any-type!] "The ID to search for."
    record-size [integer!] "The number of elements in each record."
][
    record-start: find/skip database-block record-id record-size
    either record-start [
        copy/part record-start record-size
    ][
        none
    ]
]

test-record-finding: does [
    print "  Testing Example 6: Finding a Record by ID in a Fixed-Size Record List"
    user-db: [
        101 "Alice" "Admin"
        102 "Bob"   "User"
        103 "Charlie" "User"
    ]
    assert-equal [102 "Bob" "User"] get-record-by-id user-db 102 3 "Finds record by integer ID"
    assert-equal [101 "Alice" "Admin"] get-record-by-id user-db 101 3 "Finds the first record"
    assert-equal none get-record-by-id user-db 999 3 "Returns none for non-existent ID"
    assert-equal none get-record-by-id user-db "Alice" 3 "Does not find value if not at start of a record"
]

;;-----------------------------------------------------------------------------
;; Example 7: Validating Input with a Case-Sensitive Whitelist
;;-----------------------------------------------------------------------------
is-valid-command?: function [
    {
        Checks if a command string exists in a case-sensitive list of commands.
        This is useful for dispatchers or command interpreters where case matters.
        RETURNS:
            A logic! value: true if the command is valid, false otherwise.
    }
    command-list [block!] "A block of valid command strings."
    command-to-check [string!] "The command string to validate."
][
    not none? find/case command-list command-to-check
]

test-case-sensitive-validation: does [
    print "  Testing Example 7: Validating Input with a Case-Sensitive Whitelist"
    valid-cmds: ["COMMIT" "PUSH" "PULL" "add" "status"]
    assert-equal true is-valid-command? valid-cmds "PUSH" "Finds valid uppercase command"
    assert-equal true is-valid-command? valid-cmds "add" "Finds valid lowercase command"
    assert-equal false is-valid-command? valid-cmds "push" "Rejects incorrect case"
    assert-equal false is-valid-command? valid-cmds "MERGE" "Rejects command not in list"
]

;;-----------------------------------------------------------------------------
;; Example 8: Extracting a Section Between Two Markers
;;-----------------------------------------------------------------------------
get-section-between: function [
    {
        Finds and returns the block of data between a start and end marker.
        The search is confined to the range between the markers.
        RETURNS:
            A [block!] containing the section, or [none!] if not found.
    }
    source-block [block!] "The block to search within."
    start-marker [any-type!] "The value indicating the start of the section."
    end-marker [any-type!] "The value indicating the end of the section."
][
    section: none
    if start-pos: find/tail source-block start-marker [
        if end-pos: find/part start-pos end-marker (length? start-pos) [
            section: copy/part start-pos (index? end-pos) - (index? start-pos)
        ]
    ]
    section
]

test-section-extraction: does [
    print "  Testing Example 8: Extracting a Section Between Two Markers"
    data-block: [--header-- title "My Doc" version 1 --body-- p "Hello" img %a.png --end--]
    assert-equal [p "Hello" img %a.png] get-section-between data-block '--body-- '--end-- "Extracts section between two markers"
    assert-equal [title "My Doc" version 1] get-section-between data-block '--header-- '--body-- "Extracts a different section"
    assert-equal none get-section-between data-block '--body-- '--footer-- "Returns none if end-marker is missing"
    assert-equal none get-section-between data-block '--config-- '--end-- "Returns none if start-marker is missing"
]

;;-----------------------------------------------------------------------------
;; Example 9: Confirming a Datatype is Supported
;;-----------------------------------------------------------------------------
is-supported-type?: function [
    {
        Checks if a given value's datatype is present in a typeset of supported types.
        RETURNS:
            A logic! value: true if the type is supported, false otherwise.
    }
    supported-types [typeset!] "A typeset of allowed datatypes."
    value-to-check [any-type!] "The value whose type will be checked."
][
    find supported-types type? value-to-check
]

test-type-support: does [
    print "  Testing Example 9: Confirming a Datatype is Supported"
    numeric-types: make typeset! [integer! decimal! percent!]
    a-char: #"Z"
    assert-equal true is-supported-type? numeric-types 100 "Validates an integer"
    assert-equal true is-supported-type? numeric-types 99.9 "Validates a decimal"
    assert-equal false is-supported-type? numeric-types "100" "Rejects a string"
    assert-equal false is-supported-type? numeric-types a-char "Rejects a char"
]

;;-----------------------------------------------------------------------------
;; Example 10: Checking for a Directory in a File Path (FIXED)
;;-----------------------------------------------------------------------------
path-contains-dir?: function [
    {
        Checks if a file path contains a specific directory component.
        RETURNS:
            A logic! value: true if the directory is found, false otherwise.
    }
    file-path [path!] "The path to inspect."
    dir-name [string!] "The directory name to find."
][
    ; Convert path to string, then split by directory separator
    path-string: to-string file-path
    ; Split the path by both forward and back slashes to handle cross-platform paths
    path-parts: split path-string "/"
    ; Remove empty parts that might result from leading/trailing slashes
    path-parts: remove-each part path-parts [empty? part]
    ; Use case-sensitive find to match the directory name exactly
    not none? find/case path-parts dir-name
]

test-path-component-check: does [
    print "  Testing Example 10: Checking for a Directory in a File Path"
    my-path: to-path %/c/users/rebol/scripts/test.r
    assert-equal true path-contains-dir? my-path "rebol" "Finds a directory in the middle"
    assert-equal true path-contains-dir? my-path "scripts" "Finds the parent directory"
    assert-equal false path-contains-dir? my-path "Rebol" "Confirms path find is case-sensitive"
    assert-equal false path-contains-dir? my-path "apps" "Returns false for non-existent directory"
]

;;-----------------------------------------------------------------------------
;; Run All Tests
;;-----------------------------------------------------------------------------
print "Running all practical examples tests...^/"
test-value-extraction
test-flag-checking
test-last-log-retrieval
test-cli-option-parsing
test-wildcard-log-filtering
test-record-finding
test-case-sensitive-validation
test-section-extraction
test-type-support
test-path-component-check

print-test-summary
