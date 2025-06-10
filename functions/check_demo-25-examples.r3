REBOL [
    Title: "`check` Function - A Comprehensive Guide with Examples"
    Author: "Expert Rebol 3 Programmer"
    Date: 09-Jun-2025
    Version: 1.1.1
    Purpose: "Complete guide to `check` function with 25 practical examples."
    Description: {
        The `check` function in Rebol 3 (Oldes branch) is a debugging utility
        that performs internal validation checks on series values. This script
        provides comprehensive examples and explanations for novice programmers.
    }
]
;;============================================================================
;; UNDERSTANDING THE `check` FUNCTION
;;============================================================================
print "^/=== REBOL 3 `check` FUNCTION - A COMPREHENSIVE GUIDE ===^/"
print {
WHAT IS THE `check` FUNCTION?
The `check` function is a native debugging utility in Rebol 3 that performs
internal consistency checks on series data structures. A "series" in Rebol
includes strings, blocks, binary data, and other sequential data types.
WHY USE `check`?
- Debugging: Helps identify corrupted or invalid series data using ow-level internal validation.
- Development: Ensures data integrity during program development
- Testing: Validates that series operations completed successfully
- Memory Safety: Detects potential memory-related issues.
SYNTAX: `check` series-value
RETURNS: The same series value if valid, or triggers an error if corrupted.
BEST PRACTICES FOR USING `check`:
- Use only during development and debugging phases.
- It should NOT be used in production code for regular validation (performance impact).
- Different from user-level validation functions.
- Apply before critical operations on untrusted data.
- Include in test suites for data integrity verification.
- Combine with error handling for robust applications.
- Remove from production code for performance optimization.
COMMON MISTAKES TO AVOID:
- Don't use `check` for user input validation (use other functions).
- Don't rely on `check` for business logic validation.
- Don't use in tight loops without performance considerations.
- Don't assume `check` catches all possible data issues.
The `check` function is a powerful debugging tool that helps ensure the
internal consistency of series data structures in Rebol 3 programs.
}

;;============================================================================
;; HELPER FUNCTION FOR SERIES VALIDATION
;;============================================================================
validate-series: function [
    "Performs validation on a series value with comprehensive error handling"
    series-value [series!] "The series value to validate"
    type-name [string!] "Name of the series type (for display purposes)"
    /with-formatting "Use custom formatting for display"
    formatter [any-function!] "Function to format the series for display"
    /with-extra "Perform extra operations on successful validation"
    extra-fn [any-function!] "Function to perform extra operations on successful validation"
][
    formatted-value: either with-formatting [
        do [formatter series-value]
    ][
        series-value
    ]

    print reform ["Original " type-name ":" formatted-value]

    checked-result: try [check series-value]

    either error? checked-result [
        print reform [type-name " series integrity `check` ❌ FAILED with error:" checked-result/id]
        return false
    ][
        formatted-result: either with-formatting [
            do [formatter checked-result]
        ][
            checked-result
        ]

        print reform ["Validated " type-name " data:" formatted-result]

        either equal? series-value checked-result [
            print reform [" " type-name " series integrity `check` ✅ PASSED."]
            if with-extra [do [extra-fn checked-result]]
            return true
        ][
            print reform [type-name " series integrity `check` ❌ FAILED / ❓ UNEXPECTED. The results differs from original " type-name "."]
            return false
        ]
    ]
]

;;============================================================================
;; EXAMPLE FUNCTIONS USING THE HELPER
;;============================================================================
example-01: function [
    "Demonstrates proper string validation using the `check` function with error handling."
][
    {Validates string data integrity by processing a test string through the `check` function
    and properly handling potential validation errors. Demonstrates the correct pattern for
    using `check` with comprehensive error handling and result verification.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 1: Basic String Checking ---"
    print "Creating and validating a test string..."

    my-string: "Hello, World!"
    validate-series my-string "string"
]

example-02: function [
    "Demonstrates proper block validation using the `check` function with error handling."
][
    {Validates block data integrity by processing a test block through the `check` function
    and properly handling potential validation errors. Demonstrates the correct pattern for
    using `check` with comprehensive error handling and result verification.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 2: Block Checking ---"
    print "Creating and validating a test block..."

    my-block: [1 2 3 "hello" word]
    validate-series/with-formatting my-block "block" :mold
]

example-03: function [
    "Demonstrates proper binary data validation using the `check` function with error handling."
][
    {Validates binary data integrity by processing test binary data through the `check` function
    and properly handling potential validation errors. Demonstrates the correct pattern for
    using `check` with comprehensive error handling and result verification.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 3: Binary Data Checking ---"
    print "Creating and validating binary data..."

    my-binary: to-binary "Hello"
    validate-series/with-formatting/with-extra
        my-binary
        "binary"
        :mold
        func [val][print reform ["As string:" to-string val]]
]


example-04: function [
    "Demonstrates validation of empty series using the `check` function."
][
    {Validates empty series integrity by processing empty strings, blocks, and binary data
    through the `check` function. Demonstrates that `check` properly handles empty series.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 4: Empty Series Checking ---"
    print "Checking empty series..."

    empty-string: ""
    empty-block: []
    empty-binary: to-binary ""

    print "Empty string check:"
    validate-series empty-string "empty string"

    print "Empty block check:"
    validate-series/with-formatting empty-block "empty block" :mold

    print "Empty binary check:"
    validate-series/with-formatting empty-binary "empty binary" :mold
]

example-05: function [
    "Demonstrates performance characteristics of `check` on large strings."
][
    {Creates a large string and measures the time required to perform the `check` operation.
    Demonstrates the performance impact of the `check` function on larger data sets.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 5: Large String Checking ---"
    print "Creating and checking a large string..."

    large-string: ""
    repeat i 1000 [append large-string join "Item " [i " "]]
    print ["Large string length:" length? large-string]

    ;; Timing the check operation
    start-time: now/precise
    result: validate-series/with-extra
        large-string
        "large string"
        func [val][
            print ["First 50 characters:" copy/part val 50]
            end-time: now/precise
            print ["Check completed in:" difference end-time start-time]
        ]
]


example-06: function [
    "Demonstrates validation of nested block structures using the `check` function."
][
    {Validates nested block structures by processing a complex nested block through the `check` function.
    Demonstrates that `check` properly handles deep nesting of block series.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 6: Nested Block Checking ---"
    print "Creating and checking nested blocks..."

    nested-block: [
        level1 [
            level2 [
                level3 ["deep" "data" 123]
            ]
        ]
        "top-level"
    ]

    result: validate-series/with-formatting/with-extra
        nested-block
        "nested block"
        :mold
        func [val][
            print "Nested block structure validated"
            print "Block depth verified through `check`"
        ]
]

example-07: function [
    "Demonstrates validation of strings after modifications using the `check` function."
][
    {Validates string integrity after various modifications by processing a string through
    the `check` function after each modification. Demonstrates that `check` properly verifies
    the series after common operations like append and uppercase.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 7: String After Modification ---"
    print "Checking string after modifications..."

    base-string: "Original Text"
    print ["Before modification:" base-string]

    ;; First check the original string
    validate-series base-string "original string"

    ;; Modify with append and check again
    append base-string " - Modified"
    print ["After append modification:" base-string]
    validate-series base-string "appended string"

    ;; Modify with uppercase and check again
    uppercase base-string
    print ["After uppercase modification:" base-string]
    validate-series base-string "uppercase string"
]


example-08: function [
    "Demonstrates validation of blocks after various insertion operations."
][
    {Validates block integrity after multiple modification operations by processing
    the block through the `check` function after each operation. Demonstrates that
    `check` properly verifies the series after common operations like insert and append.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 8: Block After Insertions ---"
    print "Checking block after various insertions..."

    work-block: [a b c]
    print ["Initial block:" mold work-block]

    ;; Insert at head and validate
    insert work-block 'start
    print ["After insert at head:" mold work-block]
    validate-series/with-formatting work-block "modified block (head insert)" :mold

    ;; Append and validate
    append work-block 'end
    print ["After append:" mold work-block]
    validate-series/with-formatting work-block "modified block (append)" :mold

    ;; Insert in middle and validate
    insert at work-block 3 'middle
    print ["After middle insert:" mold work-block]
    validate-series/with-formatting work-block "modified block (middle insert)" :mold
]

example-09: function [
    "Demonstrates validation of binary data after various manipulation operations."
][
    {Validates binary data integrity after multiple modification operations by processing
    the data through the `check` function after each operation. Demonstrates that
    `check` properly verifies binary series after common operations.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 9: Binary Data Manipulation ---"
    print "Checking binary data after manipulation..."

    binary-data: to-binary "ABC"
    print ["Initial binary:" mold binary-data]

    ;; Append to copy and validate
    binary-copy: copy binary-data
    append binary-copy to-binary "DEF"
    print ["After append:" mold binary-copy]
    validate-series/with-formatting binary-copy "modified binary (append)" :mold

    ;; Insert to another copy and validate
    binary-data2: copy binary-data
    insert binary-data2 to-binary "Z"
    print ["After insert:" mold binary-data2]
    validate-series/with-formatting binary-data2 "modified binary (insert)" :mold
]

example-10: function [
    "Demonstrates validation of file path strings using the `check` function."
][
    {Validates file path string integrity by converting a file path to a string
    and processing it through the `check` function. Demonstrates that `check`
    properly handles strings representing file paths.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 10: Path Series Checking ---"
    print "Checking path series..."

    file-path: %/home/user/documents/file.txt
    string-path: to-string file-path

    validate-series/with-extra
        string-path
        "file path string"
        func [val][
            print ["File path as string:" val]
            print "Path validation completed"
        ]
]

example-11: function [
    "Demonstrates validation of URL strings using the `check` function."
][
    {Validates URL string integrity by converting a URL to a string
    and processing it through the `check` function. Demonstrates that `check`
    properly handles strings representing URLs.
    Parameters: None
    Returns: [unset!] "No return value - function performs demonstration output"
    Errors: None - function captures and handles all errors from check function internally.}

    print "--- Example 11: URL String Checking ---"
    print "Checking URL converted to string..."

    url-value: http://www.example.com/path
    url-string: to-string url-value

    validate-series/with-extra
        url-string
        "URL string"
        func [val][
            print ["URL as string:" val]
            print "URL string structure validated"
        ]
]

example-12: function [] [
	email-value: none
	email-string: none
	checked-email: none
	print "^/--- Example 12: Email String Checking ---"
	print "Checking email converted to string..."
	email-value: user@example.com
	email-string: to-string email-value

	checked-email: check email-string
	print ["Email as string:" checked-email]
	print ["Email string structure validated"]
]

example-13: function [] [
	multi-line: none
	checked-multi: none
	print "^/--- Example 13: Multi-line String Checking ---"
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

example-14: function [] [
	mixed-block: none
	checked-mixed: none
	print "^/--- Example 14: Block with Mixed Data Types ---"
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

example-15: function [] [
	work-block: none
	print "^/--- Example 15: Checking After Block Removal Operations ---"
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


example-16: function [] [
	source-string: none
	parts: none
	part: none
	checked-part: none
	print "^/--- Example 16: String Parsing Results Checking ---"
	print "Checking strings after parsing operations..."
	source-string: "word1,word2,word3,word4"
	parts: split source-string ","

	foreach part parts [
		checked-part: check part
		print ["Parsed part validated:" checked-part]
	]
]


example-17: function [] [
	original-block: none
	copied-block: none
	print "^/--- Example 17: Checking Copied Series ---"
	print "Checking copied series..."
	original-block: [1 2 3 4 5]
	copied-block: copy original-block

	print ["Original block valid:" either check original-block ["YES"]["NO"]]
	print ["Copied block valid:" either check copied-block ["YES"]["NO"]]

	append copied-block 6
	print ["Original after copy modified:" either check original-block ["YES"]["NO"]]
	print ["Modified copy valid:" either check copied-block ["YES"]["NO"]]
]


example-18: function [] [
	data-block: none
	at-head: none
	at-middle: none
	at-tail: none
	print "^/--- Example 18: Checking Series at Different Positions ---"
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

example-19: function [] [
	data-string: none
	skipped-2: none
	skipped-back: none
	print "^/--- Example 19: Checking Skip Results ---"
	print "Checking series after skip operations..."
	data-string: "abcdefghijk"

	skipped-2: skip data-string 2
	check skipped-2
	print ["Skipped 2 chars:" copy skipped-2]

	skipped-back: skip skipped-2 -1
	check skipped-back
	print ["Skipped back 1:" copy skipped-back]
]


example-20: function [] [
	original-block: none
	checked-reversed: none
	checked-restored: none
	print "^/--- Example 20: Checking Reversed Series ---"
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

example-21: function [] [
	unsorted-block: none
	checked-sorted: none
	print "^/--- Example 21: Checking Sorted Series ---"
	print "Checking sorted series..."
	unsorted-block: [5 2 8 1 9 3]
	print ["Unsorted:" mold unsorted-block]

	sort unsorted-block
	checked-sorted: check unsorted-block
	print ["Sorted and validated:" mold checked-sorted]
]

example-22: function [] [
	unicode-string: none
	checked-unicode: none
	simple-unicode: none
	print "^/--- Example 22: Checking Series with Unicode Content ---"
	print "Checking series with Unicode characters..."

	;; `try` with simpler Unicode content first:
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

example-23: function [] [
	test-data: none
	validated-data: none
	print "^/--- Example 23: Checking Series in Error Handling ---"
	print "Using `check` in error handling context..."

	try/with [
		test-data: "Valid data string"
		validated-data: check test-data
		print ["Data validation successful:" validated-data]
	] function [error] [
		print ["Error during validation:" error/id]
	]
]

example-24: function [] [
	critical-data: none
	item: none
	print "^/--- Example 24: Checking Before Critical Operations ---"
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

example-25: function [] [
	sizes: none
	size: none
	test-block: none
	i: none
	start-time: none
	end-time: none
	time-diff: none
	print "^/--- Example 25: Performance Testing with `check` ---"
	print "Performance testing `check` function..."

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

;; Run all examples
print "^/Running all examples:^/"
example-01
example-02
example-03
example-04
example-05
example-06
example-07
example-08
example-09
example-10
example-11
example-12
example-13
example-14
example-15
example-16
example-17
example-18
example-19
example-20
example-21
example-22
example-23
example-24
example-25
print "^/All examples completed.^/"
