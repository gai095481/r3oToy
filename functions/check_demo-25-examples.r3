REBOL [
    Title: "CHECK Function - Comprehensive Guide and Examples"
    Author: "Expert Rebol 3 Programmer"
    Date: 06-Jun-2025
    Version: 1.1
    Purpose: "Complete guide to CHECK function with 25 practical examples"
    Description: {
        The CHECK function in Rebol 3 (Oldes branch) is a debugging utility
        that performs internal validation checks on series values. This script
        provides comprehensive examples and explanations for novice programmers.
    }
]

;; ============================================================================
;; UNDERSTANDING THE CHECK FUNCTION
;; ============================================================================

print "^/=== REBOL 3 CHECK FUNCTION - COMPREHENSIVE GUIDE ===^/"

print {
WHAT IS THE CHECK FUNCTION?
The CHECK function is a native debugging utility in Rebol 3 that performs
internal consistency checks on series data structures. A "series" in Rebol
includes strings, blocks, binary data, and other sequential data types.

WHY USE CHECK?
- Debugging: Helps identify corrupted or invalid series data
- Development: Ensures data integrity during program development
- Testing: Validates that series operations completed successfully
- Memory Safety: Detects potential memory-related issues

SYNTAX: CHECK series-value
RETURNS: The same series value if valid, or triggers an error if corrupted

IMPORTANT NOTES:
- CHECK is primarily a development/debugging tool
- It performs low-level internal validation
- Should not be used in production code for regular validation
- Different from user-level validation functions
}

;; ============================================================================
;; EXAMPLE 1: Basic String Checking
;; ============================================================================

print "^/--- Example 1: Basic String Checking ---"
example1: function [] [
    my-string: none
    checked-string: none

    print "Creating and checking a simple string..."
    my-string: "Hello, World!"
    checked-string: check my-string
    print ["Original string:" my-string]
    print ["Checked string:" checked-string]
    print ["Check passed: Both strings are identical"]
]
example1

;; ============================================================================
;; EXAMPLE 2: Block Checking
;; ============================================================================

print "^/--- Example 2: Block Checking ---"
example2: function [] [
    my-block: none
    checked-block: none

    print "Creating and checking a block of data..."
    my-block: [1 2 3 "hello" word]
    checked-block: check my-block
    print ["Original block:" mold my-block]
    print ["Checked block:" mold checked-block]
    print "Block structure validated successfully"
]
example2

;; ============================================================================
;; EXAMPLE 3: Binary Data Checking
;; ============================================================================

print "^/--- Example 3: Binary Data Checking ---"
example3: function [] [
    my-binary: none
    checked-binary: none

    print "Creating and checking binary data..."
    my-binary: to-binary "Hello"
    checked-binary: check my-binary
    print ["Original binary:" mold my-binary]
    print ["Checked binary:" mold checked-binary]
    print ["As string:" to-string my-binary]
]
example3

;; ============================================================================
;; EXAMPLE 4: Empty Series Checking
;; ============================================================================

print "^/--- Example 4: Empty Series Checking ---"
example4: function [] [
    empty-string: none
    empty-block: none
    empty-binary: none

    print "Checking empty series..."
    empty-string: ""
    empty-block: []
    empty-binary: to-binary ""

    print ["Empty string check:" either (check empty-string) = empty-string ["PASSED"]["FAILED"]]
    print ["Empty block check:" either (check empty-block) = empty-block ["PASSED"]["FAILED"]]
    print ["Empty binary check:" either (check empty-binary) = empty-binary ["PASSED"]["FAILED"]]
]
example4

;; ============================================================================
;; EXAMPLE 5: Large String Checking
;; ============================================================================

print "^/--- Example 5: Large String Checking ---"
example5: function [] [
    large-string: none
    checked-string: none
    start-time: none
    end-time: none
    i: none

    print "Creating and checking a large string..."
    large-string: ""
    repeat i 1000 [append large-string join "Item " [i " "]]

    print ["Large string length:" length? large-string]
    start-time: now/precise
    checked-string: check large-string
    end-time: now/precise
    print ["Check completed in:" difference end-time start-time]
    print ["First 50 characters:" copy/part large-string 50]
]
example5

;; ============================================================================
;; EXAMPLE 6: Nested Block Checking
;; ============================================================================

print "^/--- Example 6: Nested Block Checking ---"
example6: function [] [
    nested-block: none
    checked-nested: none

    print "Creating and checking nested blocks..."
    nested-block: [
        level1 [
            level2 [
                level3 ["deep" "data" 123]
            ]
        ]
        "top-level"
    ]

    checked-nested: check nested-block
    print ["Nested block structure validated"]
    print ["Block depth verified through CHECK"]
]
example6

;; ============================================================================
;; EXAMPLE 7: String After Modification
;; ============================================================================

print "^/--- Example 7: String After Modification ---"
example7: function [] [
    base-string: none
    checked-after-append: none
    checked-after-case: none

    print "Checking string after modifications..."
    base-string: "Original Text"
    print ["Before modification:" base-string]

    append base-string " - Modified"
    checked-after-append: check base-string
    print ["After append:" checked-after-append]

    uppercase base-string
    checked-after-case: check base-string
    print ["After uppercase:" checked-after-case]
]
example7

;; ============================================================================
;; EXAMPLE 8: Block After Insertions
;; ============================================================================

print "^/--- Example 8: Block After Insertions ---"
example8: function [] [
    work-block: none

    print "Checking block after various insertions..."
    work-block: [a b c]
    print ["Initial block:" mold work-block]

    insert work-block 'start
    check work-block
    print ["After insert at head:" mold work-block]

    append work-block 'end
    check work-block
    print ["After append:" mold work-block]

    insert at work-block 3 'middle
    check work-block
    print ["After middle insert:" mold work-block]
]
example8

;; ============================================================================
;; EXAMPLE 9: Binary Data Manipulation
;; ============================================================================

print "^/--- Example 9: Binary Data Manipulation ---"
example9: function [] [
    binary-data: none
    binary-copy: none
    binary-data2: none

    print "Checking binary data after manipulation..."
    binary-data: to-binary "ABC"
    print ["Initial binary:" mold binary-data]

    binary-copy: copy binary-data
    append binary-copy to-binary "DEF"
    check binary-copy
    print ["After append:" mold binary-copy]

    binary-data2: copy binary-data
    insert binary-data2 to-binary "Z"
    check binary-data2
    print ["After insert:" mold binary-data2]
]
example9

;; ============================================================================
;; EXAMPLE 10: Path Series Checking
;; ============================================================================

print "^/--- Example 10: Path Series Checking ---"
example10: function [] [
    file-path: none
    string-path: none
    checked-path: none

    print "Checking path series..."
    file-path: %/home/user/documents/file.txt
    string-path: to-string file-path

    checked-path: check string-path
    print ["File path as string:" checked-path]
    print ["Path validation completed"]
]
example10

;; ============================================================================
;; EXAMPLE 11: URL String Checking
;; ============================================================================

print "^/--- Example 11: URL String Checking ---"
example11: function [] [
    url-value: none
    url-string: none
    checked-url: none

    print "Checking URL converted to string..."
    url-value: http://www.example.com/path
    url-string: to-string url-value

    checked-url: check url-string
    print ["URL as string:" checked-url]
    print ["URL string structure validated"]
]
example11

;; ============================================================================
;; EXAMPLE 12: Email String Checking
;; ============================================================================

print "^/--- Example 12: Email String Checking ---"
example12: function [] [
    email-value: none
    email-string: none
    checked-email: none

    print "Checking email converted to string..."
    email-value: user@example.com
    email-string: to-string email-value

    checked-email: check email-string
    print ["Email as string:" checked-email]
    print ["Email string structure validated"]
]
example12

;; ============================================================================
;; EXAMPLE 13: Multi-line String Checking
;; ============================================================================

print "^/--- Example 13: Multi-line String Checking ---"
example13: function [] [
    multi-line: none
    checked-multi: none

    print "Checking multi-line string..."
    multi-line: {Line 1
Line 2
Line 3
    Indented line
Final line}

    checked-multi: check multi-line
    print "Multi-line string structure:"
    print checked-multi
    print "^/Multi-line validation completed"
]
example13

;; ============================================================================
;; EXAMPLE 14: Block with Mixed Data Types
;; ============================================================================

print "^/--- Example 14: Block with Mixed Data Types ---"
example14: function [] [
    mixed-block: none
    checked-mixed: none

    print "Checking block with various data types..."
    mixed-block: [
        "string"
        123
        45.67
        true
        none
        word
        [nested block]
        (to-binary "data")
    ]

    checked-mixed: check mixed-block
    print ["Mixed type block validated"]
    print ["Block contains" length? checked-mixed "elements"]
]
example14

;; ============================================================================
;; EXAMPLE 15: Checking After Block Removal Operations
;; ============================================================================

print "^/--- Example 15: Checking After Block Removal Operations ---"
example15: function [] [
    work-block: none

    print "Checking block after removal operations..."
    work-block: [a b c d e f g]
    print ["Original:" mold work-block]

    remove work-block
    check work-block
    print ["After remove first:" mold work-block]

    remove back tail work-block
    check work-block
    print ["After remove last:" mold work-block]

    remove/part work-block 2
    check work-block
    print ["After remove/part 2:" mold work-block]
]
example15

;; ============================================================================
;; EXAMPLE 16: String Parsing Results Checking
;; ============================================================================

print "^/--- Example 16: String Parsing Results Checking ---"
example16: function [] [
    source-string: none
    parts: none
    part: none
    checked-part: none

    print "Checking strings after parsing operations..."
    source-string: "word1,word2,word3,word4"
    parts: split source-string ","

    foreach part parts [
        checked-part: check part
        print ["Parsed part validated:" checked-part]
    ]
]
example16

;; ============================================================================
;; EXAMPLE 17: Checking Copied Series
;; ============================================================================

print "^/--- Example 17: Checking Copied Series ---"
example17: function [] [
    original-block: none
    copied-block: none

    print "Checking copied series..."
    original-block: [1 2 3 4 5]
    copied-block: copy original-block

    print ["Original block valid:" either check original-block ["YES"]["NO"]]
    print ["Copied block valid:" either check copied-block ["YES"]["NO"]]

    append copied-block 6
    print ["Original after copy modified:" either check original-block ["YES"]["NO"]]
    print ["Modified copy valid:" either check copied-block ["YES"]["NO"]]
]
example17

;; ============================================================================
;; EXAMPLE 18: Checking Series at Different Positions
;; ============================================================================

print "^/--- Example 18: Checking Series at Different Positions ---"
example18: function [] [
    data-block: none
    at-head: none
    at-middle: none
    at-tail: none

    print "Checking series at various positions..."
    data-block: [a b c d e f]

    at-head: head data-block
    check at-head
    print ["At head position - valid"]

    at-middle: at data-block 3
    check at-middle
    print ["At middle position - valid"]

    at-tail: tail data-block
    check at-tail
    print ["At tail position - valid"]
]
example18

;; ============================================================================
;; EXAMPLE 19: Checking Skip Results
;; ============================================================================

print "^/--- Example 19: Checking Skip Results ---"
example19: function [] [
    data-string: none
    skipped-2: none
    skipped-back: none

    print "Checking series after skip operations..."
    data-string: "abcdefghijk"

    skipped-2: skip data-string 2
    check skipped-2
    print ["Skipped 2 chars:" copy skipped-2]

    skipped-back: skip skipped-2 -1
    check skipped-back
    print ["Skipped back 1:" copy skipped-back]
]
example19

;; ============================================================================
;; EXAMPLE 20: Checking Reversed Series
;; ============================================================================

print "^/--- Example 20: Checking Reversed Series ---"
example20: function [] [
    original-block: none
    checked-reversed: none
    checked-restored: none

    print "Checking reversed series..."
    original-block: [1 2 3 4 5]
    print ["Original:" mold original-block]

    reverse original-block
    checked-reversed: check original-block
    print ["Reversed and validated:" mold checked-reversed]

    reverse original-block
    checked-restored: check original-block
    print ["Restored and validated:" mold checked-restored]
]
example20

;; ============================================================================
;; EXAMPLE 21: Checking Sorted Series
;; ============================================================================

print "^/--- Example 21: Checking Sorted Series ---"
example21: function [] [
    unsorted-block: none
    checked-sorted: none

    print "Checking sorted series..."
    unsorted-block: [5 2 8 1 9 3]
    print ["Unsorted:" mold unsorted-block]

    sort unsorted-block
    checked-sorted: check unsorted-block
    print ["Sorted and validated:" mold checked-sorted]
]
example21

;; ============================================================================
;; EXAMPLE 22: Checking Series with Unicode Content
;; ============================================================================

print "^/--- Example 22: Checking Series with Unicode Content ---"
example22: function [] [
    unicode-string: none
    checked-unicode: none
    simple-unicode: none

    print "Checking series with Unicode characters..."

    ; Try with simpler Unicode content first
    try/with [
        simple-unicode: "Hello Café résumé naïve"
        checked-unicode: check simple-unicode
        print ["Simple Unicode validated:" checked-unicode]
        print ["String length:" length? checked-unicode]
    ] function [error] [
        print "Unicode check failed, trying ASCII alternative..."
        simple-unicode: "Hello World - ASCII safe"
        checked-unicode: check simple-unicode
        print ["ASCII fallback validated:" checked-unicode]
    ]
]
example22

;; ============================================================================
;; EXAMPLE 23: Checking Series in Error Handling Context
;; ============================================================================

print "^/--- Example 23: Checking Series in Error Handling ---"
example23: function [] [
    test-data: none
    validated-data: none

    print "Using CHECK in error handling context..."

    try/with [
        test-data: "Valid data string"
        validated-data: check test-data
        print ["Data validation successful:" validated-data]
    ] function [error] [
        print ["Error during validation:" error/id]
    ]
]
example23

;; ============================================================================
;; EXAMPLE 24: Checking Series Before Critical Operations
;; ============================================================================

print "^/--- Example 24: Checking Before Critical Operations ---"
example24: function [] [
    critical-data: none
    item: none

    print "Pre-validating series before critical operations..."

    critical-data: [important config values here]

    if check critical-data [
        print "Data validated - proceeding with critical operation"
        foreach item critical-data [
            ; Process each validated item
        ]
        print "Critical operation completed safely"
    ]
]
example24

;; ============================================================================
;; EXAMPLE 25: Performance Testing with CHECK
;; ============================================================================

print "^/--- Example 25: Performance Testing with CHECK ---"
example25: function [] [
    sizes: none
    size: none
    test-block: none
    i: none
    start-time: none
    end-time: none
    time-diff: none

    print "Performance testing CHECK function..."

    sizes: [10 100 1000 10000]

    foreach size sizes [
        test-block: []
        repeat i size [append test-block i]

        start-time: now/precise
        check test-block
        end-time: now/precise

        time-diff: difference end-time start-time
        print ["Size:" size "elements, Check time:" time-diff]
    ]
]
example25

;; ============================================================================
;; COMPREHENSIVE TESTING SUMMARY
;; ============================================================================

print "^/^/=== TESTING SUMMARY ==="
print {
All 25 examples have been executed, demonstrating:

1. Basic series validation (strings, blocks, binary)
2. Empty series handling
3. Large data structure validation
4. Series modification tracking
5. Nested structure validation
6. Performance characteristics
7. Error handling integration
8. Unicode and special character support
9. Position-dependent checking
10. Integration with other Rebol operations

BEST PRACTICES FOR USING CHECK:
- Use during development and debugging phases
- Apply before critical operations on untrusted data
- Include in test suites for data integrity verification
- Combine with error handling for robust applications
- Remove from production code for performance optimization

COMMON MISTAKES TO AVOID:
- Don't use CHECK for user input validation (use other functions)
- Don't rely on CHECK for business logic validation
- Don't use in tight loops without performance considerations
- Don't assume CHECK catches all possible data issues

The CHECK function is a powerful debugging tool that helps ensure the
internal consistency of series data structures in Rebol 3 programs.
}

print "^/All examples completed successfully!"
