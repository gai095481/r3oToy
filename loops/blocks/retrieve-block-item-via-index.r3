REBOL [
    Title: "Convenient Nested Block Element Retrieval Function"
    Version: 0.1.1
    Author: "Person and AI Coding Assistants"
    Date: 20-Jun-2025
    File: %retrieve-block-item-via-index.r3
    Status: "Release candidate"
    Purpose: {
        A convenient function for iterating and retrieving
        elements in nested block data structures.  Solve common iteration patterns
        and field access challenges in structured block data.

        Features:
        - Safe field retrieval with default values for missing fields.
    }
    Keywords: [nested blocks iterate loop field element access data-structure Rebol-3 Oldes]
]

;;==============================================================================
;; It takes a `block!`, an index (index) and an optional default value `default-value`.
;; First it checks if the provided block is `none` or not a valid block.
;; If the block is invalid:
;;  If the `/default` refinement is used, it returns the provided `default-value`.
;;  If the `/default` refinement is not used, it returns `none`.
;; If the block is valid, it checks if the index is out of bounds (less than 1 or greater than the block's length).
;;  If the index is out of bounds:
;;   If the `/default` refinement is used, it returns the provided `default-value`.
;;   If the `/default` refinement is not used, it returns `none`.
;;  If the block is valid and the index is within bounds, it returns the item at the specified index using `pick`.
;; A robust and well-documented function, ensuring safe access to block elements with proper error handling and optional default values.
;;==============================================================================
retrieve-block-item-via-index: function [
    block-data [block! none!] "Block with the element / field / item to retrieve."
    index [integer!] "one-based index of the field to retrieve."
    /default "Provide a default value if the field is missing."
    default-value [any-type!] "The default value if the field is missing."
    return: [any-type!] "The field value, default value or `none`"
][
    {USE: Safely get a field from a block with optional default value.
    Provide safe access to block elements with bounds checking
    and optional default values when the field doesn't exist.
    RETURNS:[any-type!] - Field value or default value or `none`.
    ERRORS: None - This function never throws errors, returns safe values.}

    either any [none? block-data not block? block-data][
        either default [:default-value][none]
    ][
        either any [index < 1 index > length? block-data][
            either default [:default-value][none]
        ][
            pick block-data index
        ]
    ]
]

;;==============================================================================
;; DEMONSTRATE NESTED BLOCK ITERATORS
;;==============================================================================
demo-retrieve-block-item-via-index-function: function [
    return: [none!] "No return value - prints demonstration results to console"
][
    {USE: Demonstrate EASY nested block functions.
    Demonstrate how to properly iterate through nested block data structures.}

    print "=== NESTED BLOCK ITERATORS DEMONSTRATION ==="

    ;; Sample of a nested block data structure:
    system-items: [
        ["system/version" "Interpreter version for compatibility confirmation" system/version]
        ["system/platform" "Operating system platform for OS-specific logic" system/platform]
        ["system/product" "Rebol product name identifying interpreter capabilities" system/product]
        ["system/build" "Detailed build information for diagnostics" system/build]
        ["system/options/path" "Current working directory for relative file access" system/options/path]
        ["system/options/home" "Home directory path for user-specific files" system/options/home]
        ["system/options/boot" "Full path to the running Rebol executable" system/options/boot]
        ["system/options/script" "Path to currently executing script" system/options/script]
        ["system/options/args" "Command-line arguments for script parameterization" system/options/args]
        ["system/options/result-types" " Typeset of recognized Rebol data types" system/options/result-types]
    ]

    print "^/=== SOLUTION 1: SIMPLE ITERATION ==="

    foreach item system-items [
        call-name: retrieve-block-item-via-index item 1
        description: retrieve-block-item-via-index item 2
        value-path: retrieve-block-item-via-index item 3

        print rejoin ["Call name:   " call-name]
        print rejoin ["Description: " description]
        print rejoin ["Value path:  " value-path]
        print newline
    ]

    print "^/=== NESTED BLOCK ITERATORS DEMONSTRATION COMPLETE ==="
    print "Key Benefits:"
    print "✅ Clean, readable code with clear field access."
    print "✅ Safe handling of missing or malformed data."
    print "✅ Reusable function for common block structure patterns."
    print "✅ Avoid confusing index errors or path access issues"
]

;; Run the demonstration:
demo-retrieve-block-item-via-index-function
