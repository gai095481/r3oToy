REBOL [
    Title: "Robust Message Logging Utility"
    Version: 0.1.0
    Author: "AI Software Development Assistant"
    Date: 26-Jun-2025
    Status: 'alpha-release-candidate
    Purpose: {
        A standardized function for logging messages to a file.
        - Supports any Rebol datatype by molding it.
        - Includes timestamping for all entries.
        - Provides robust error handling for file I/O.
        - Allows specifying an alternative log file.
    }
    Keywords: [log logging file IO event message reusable]
]

;;-----------------------------------------------------------------------------
;; Configuration
;;-----------------------------------------------------------------------------
alt-msg-log-filename: %alt-messages.log
std-msg-log-filename: %std-messages.log

;;-----------------------------------------------------------------------------
;; Core Logging Function
;;-----------------------------------------------------------------------------
log-msg: function [
    message [any-type!] "The event message or data to log."
    /file alt-log-filename [file!] "Use an alternative log file."
][
    {USE: Log a message to a file with a timestamp.
    All messages are prefixed with a timestamp in the format "YYYY-MM-DD HH:MM:SS.mmm".
    Non-string/binary values are molded for logging.  The function attempts to
    create the log file if it doesn't exist or append to it if it's present.
    RETURNS: [logic!] Return `true` on successful write, `false` on any failure.

    ERRORS: Return `false` if file path is insecure or if file I/O operations
        (like write or write/append) fail due to permissions, disk space, etc.}

    ;; Determine which log file to use:
    log-file: either file [alt-log-filename] [std-msg-log-filename]

    ;; Validate log file path for basic security:
    if any [
        find to-string log-file ".."
        find to-string log-file "/"
        (first to-string log-file) = #"/"
    ][
        print rejoin ["❌ REJECT: Possibly unsafe wild log file path detected: " log-file]
        return false
    ]

    ;; Create the entry's timestamp:
    timestamp: rejoin [now/date " " now/time]

    ;; Format the message for logging:
    formatted-message: case [
        string? message  [message]
        binary? message  [to-string message]
        true             [mold message]
    ]

    ;; Construct the log entry:
    log-entry: rejoin [
        timestamp ": "
        formatted-message
        newline
    ]

    ;; Attempt to write to the log file with error handling:
    set/any 'write-result try [
        either exists? log-file [
            write/append log-file log-entry
        ][
            write log-file log-entry
        ]
        ;; The result of write/append or `write` is 'unset on success.
        ;; The 'try' block should ONLY contain the fallible operation.
    ]

    ;; Check the result and return the appropriate status:
    either error? write-result [
        print ["❌ FAILED: Cannot write the log file:" log-file "(" write-result/id ")"]
        return false  ;; Return a failure indicator.
    ][
        return true   ;; Return a success indicator.
    ]
]

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

assert-file-exists: function [
    {Check if a file exists and report test result.}
    filename [file!] "The file to check for existence."
    description [string!] "A description of the test."
][
    file-exists: exists? filename
    either file-exists [
        print ["✅ PASSED:" description]
    ][
        set 'all-tests-passed? false
        print ["❌ FAILED:" description "- File does not exist:" filename]
    ]
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ PASSED: ALL MESSAGE LOGGER OPERATIONS ARE SUCCESSFUL."
    ][
        print "❌ FAILED: SOME MESSAGE LOGGER OPERATIONS WERE UNSUCCESSFUL."
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Test Execution
;;-----------------------------------------------------------------------------
print "^/=== Testing Message Logger Function ===^/"

;; Clean up any existing test message logs:
if exists? alt-msg-log-filename [delete alt-msg-log-filename]
if exists? std-msg-log-filename [delete std-msg-log-filename]

;; Test 1: Basic string logging.
result-1: log-msg "This is a basic test message."
assert-equal true result-1 "Basic string message logging should succeed."
assert-file-exists std-msg-log-filename "Default log file should now be created."

;; Test 2: Block data logging.
result-2: log-msg [1 2 3 "test"]
assert-equal true result-2 "Block data logging should succeed."

;; Test 3: Object data logging.
test-object: make object! [name: "Error Object" code: 404 reason: 'denied]
result-3: log-msg test-object
assert-equal true result-3 "Object logging should succeed."

;; Test 4: Alternate file logging.
result-4: log-msg/file "Alternate file test message." alt-msg-log-filename
assert-equal true result-4 "Alternate file logging should succeed."
assert-file-exists alt-msg-log-filename "Alternate log file should be created."

;; Test 5: Security test - invalid path (should fail).
result-5: log-msg/file "Should fail" %../invalid-path.log
assert-equal false result-5 "Invalid path should be rejected for security reasons."

;; Test 6: Binary data logging
binary-data: #{48656C6C6F} ;; "Hello" in binary
result-6: log-msg binary-data
assert-equal true result-6 "Binary data logging should succeed."

print-test-summary
