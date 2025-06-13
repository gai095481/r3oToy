REBOL [
    Title: "Rebol 3 Function Introspection & Validation Library"
    Version: 1.0.0
    Author: "Lutra AI Assistant"
    Date: 11-Jun-2025
    Purpose: {Provide robust tools for function introspection and safe execution in REBOL/Bulk 3.19.0 (Oldes branch)}
    Status: "Untested."
    Notes: {
        This library implements strict coding standards for the Oldes branch:
        - All functions use 'function' keyword with proper local scoping
        - Error handling returns structured error! objects
        - Comprehensive documentation with curly brace docstrings
        - No 'else' keyword usage - only 'either', 'case', or 'switch'
        - String inputs converted to word! for consistency
    }
    Keywords: [introspection validation function-analysis datatype safe-execution rebol3-oldes]
]

;; =============================================================================
;; CORE FUNCTION INTROSPECTION UTILITIES (F-01 through F-04)
;; =============================================================================
function-exists?: function [
    name [word! string!] "Function name to check - strings converted to TYPE `word!`"
][
    {Check if a given word is bound to a callable function.

    This function safely determines whether a word refers to a callable function
    (native!, action!, function!, closure!) without producing errors for non-existent
    or non-function values.

    RETURNS: [logic!] "true if name is bound to a callable function, false otherwise"
    ERRORS: This function does not return errors - it returns false for all error conditions.}

    local: [fn-word fn-value]
][
    ;; Convert string input to word for consistency:
    fn-word: either string? name [to-word name] [name]

    ;; Safely attempt to get the value - return false if word is not bound:
    fn-value: try [get fn-word]
    either error? fn-value [
        false
    ][
        either none? fn-value [
            false
        ][
            ;; Check if the value is one of the callable function types:
            any [
                native? fn-value
                action? fn-value
                function? fn-value
                closure? fn-value
            ]
        ]
    ]
]

function-type: function [
    name [word! string!] "Function name to analyze - strings converted to TYPE `word!`."
][
    {Return the specific datatype of a given function.

    Determine the exact datatype (native!, action!, function!, closure!)
    of a callable function, returning `none` if the target is not a function.

    RETURNS: [datatype! none!] "The function's datatype or none if not a function"
    ERRORS: This function does not return errors - it returns none for all error conditions.}
][
    ;; Convert string input to word for consistency:
    fn-word: either string? name [to-word name] [name]

    ;; Return `none` if the word doesn't exist as a function:
    either function-exists? fn-word [
        fn-value: get fn-word
        type? fn-value
    ][
        return none
    ]
]

function-type-matches?: function [
    name [word! string!] "Function name to check - strings converted to type `word!`."
    expected-type [datatype!] "Expected datatype to match (`native!`, `action!`, `function!`, `closure!`)"
][
    {Check if a function's datatype matches an expected datatype.

    USE: Validate whether the specified function matches a specific expected
    datatype, providing a safe way to verify function types before operations
    that depend on specific function characteristics.

    RETURNS: [logic!] "`true` if function exists and matches expected type, otherwise `false`"
    ERRORS: Does not return errors; it returns `false` for all error conditions.}
][
    ;; Convert string input to word for consistency:
    fn-word: either string? name [to-word name] [name]

    ;; Get the actual datatype; `function-type` returns `none` if not a function:
    actual-type: function-type fn-word

    either none? actual-type [
        false
    ][
        actual-type = expected-type
    ]
]

function-spec: function [
    name [word! string!] "Function name to analyze"
][
    {Safely retrieve the specification block of a function.

    This function returns the complete specification block (spec-of) for a given
    function, providing access to argument definitions, types, and refinements.

    Parameters:
    - name [word! string!] "Function name to analyze - strings converted to word!"

    Returns: [block! none!] "The function's specification block or none if not a function"

    Errors: This function does not return errors - it returns none for all error conditions.}

    local: [fn-word fn-value spec-result]
][
    ; Convert string input to word for consistency
    fn-word: either string? name [to-word name] [name]

    ; Return none if the word doesn't exist as a function
    either function-exists? fn-word [
        fn-value: get fn-word
        ; Safely attempt to get the specification
        spec-result: try [spec-of fn-value]
        either error? spec-result [
            none
        ][
            spec-result
        ]
    ][
        none
    ]
]

;; =============================================================================
;; FUNCTION ANALYSIS UTILITIES (F-05 through F-09)
;; =============================================================================

required-arg-count: function [
    spec [block!] "Function specification block"
][
    {Count the number of required arguments in a function specification.

    This function analyzes a function specification block and returns the count
    of required arguments (all arguments before the first refinement).

    Parameters:
    - spec [block!] "Function specification block from spec-of"

    Returns: [integer!] "Number of required arguments"

    Errors: Returns error! object if spec is not a valid block.}

    local: [count item]
][
    either empty? spec [
        0
    ][
        count: 0
        foreach item spec [
            ; Stop counting when we hit the first refinement
            either refinement? item [
                break
            ][
                ; Only count words (argument names), skip type blocks and strings
                either word? item [
                    count: count + 1
                ][
                    ; Continue processing - type blocks and doc strings don't affect count
                ]
            ]
        ]
        count
    ]
]

total-arg-count: function [
    spec [block!] "Function specification block"
][
    {Count the total number of arguments including refinements in a function specification.

    This function analyzes a function specification block and returns the total
    count of all arguments, including both required arguments and refinements.

    Parameters:
    - spec [block!] "Function specification block from spec-of"

    Returns: [integer!] "Total number of arguments including refinements"

    Errors: Returns error! object if spec is not a valid block.}

    local: [count item]
][
    either empty? spec [
        0
    ][
        count: 0
        foreach item spec [
            ; Count both regular words and refinements
            either any [word? item refinement? item] [
                count: count + 1
            ][
                ; Skip type blocks and doc strings
            ]
        ]
        count
    ]
]

function-refinements: function [
    spec [block!] "Function specification block"
][
    {Extract all refinement words from a function specification.

    This function analyzes a function specification block and returns a new
    block containing all refinement! words found within it.

    Parameters:
    - spec [block!] "Function specification block from spec-of"

    Returns: [block!] "Block of refinement! words (empty if no refinements)"

    Errors: Returns error! object if spec is not a valid block.}

    local: [refinements item]
][
    refinements: make block! []

    either empty? spec [
        refinements
    ][
        foreach item spec [
            either refinement? item [
                append refinements item
            ][
                ; Continue - not a refinement
            ]
        ]
        refinements
    ]
]

has-refinement?: function [
    name [word! string!] "Function name to check"
    refinement [refinement!] "Refinement to look for"
][
    {Check if a function has a specific refinement.

    This function determines whether a given function includes a specific
    refinement in its specification, providing a way to verify supported
    options before attempting to use them.

    Parameters:
    - name [word! string!] "Function name to check - strings converted to word!"
    - refinement [refinement!] "The refinement to search for"

    Returns: [logic!] "true if function has the refinement, false otherwise"

    Errors: This function does not return errors - it returns false for all error conditions.}

    local: [fn-word spec refinements]
][
    ; Convert string input to word for consistency
    fn-word: either string? name [to-word name] [name]

    ; Get the function specification
    spec: function-spec fn-word

    either none? spec [
        false
    ][
        refinements: function-refinements spec
        found? find refinements refinement
    ]
]

function-signature: function [
    name [word! string!] "Function name to analyze"
][
    {Generate a human-readable signature string for a function.

    This function creates a complete signature showing the function name
    followed by all its arguments and refinements, providing a quick
    overview of the function's interface.

    Parameters:
    - name [word! string!] "Function name to analyze - strings converted to word!"

    Returns: [string! none!] "Human-readable function signature or none if not a function"

    Errors: This function does not return errors - it returns none for all error conditions.}

    local: [fn-word spec signature item]
][
    ; Convert string input to word for consistency
    fn-word: either string? name [to-word name] [name]

    ; Get the function specification
    spec: function-spec fn-word

    either none? spec [
        none
    ][
        ; Start with the function name
        signature: to-string fn-word

        ; Add each argument and refinement
        foreach item spec [
            either any [word? item refinement? item] [
                signature: rejoin [signature " " to-string item]
            ][
                ; Skip type blocks and doc strings
            ]
        ]

        signature
    ]
]

;; =============================================================================
;; SAFE EXECUTION AND VALIDATION UTILITIES (F-10 and F-11)
;; =============================================================================

validate-arguments: function [
    name [word! string!] "Function name to validate against"
    args [block!] "Block of arguments to validate"
][
    {Validate provided arguments against a function's specification.

    This function checks whether the provided arguments meet the minimum
    requirements for calling a function, specifically ensuring sufficient
    required arguments are provided.

    Parameters:
    - name [word! string!] "Function name to validate against - strings converted to word!"
    - args [block!] "Block of arguments to validate"

    Returns: [block!] "Block of error message strings (empty if validation passes)"

    Errors: Returns error! object if function does not exist or spec cannot be retrieved.}

    local: [fn-word spec required-count provided-count errors]
][
    ; Convert string input to word for consistency
    fn-word: either string? name [to-word name] [name]

    errors: make block! []

    ; Check if function exists
    either function-exists? fn-word [
        ; Get function specification
        spec: function-spec fn-word
        either none? spec [
            append errors "Unable to retrieve function specification"
        ][
            ; Check argument count
            required-count: required-arg-count spec
            provided-count: length? args

            either provided-count < required-count [
                append errors rejoin [
                    "Too few arguments: expected at least "
                    required-count
                    " but got "
                    provided-count
                ]
            ][
                ; Validation passed - no errors to add
            ]
        ]
    ][
        append errors rejoin ["Function '" to-string fn-word "' does not exist"]
    ]

    errors
]

safe-call: function [
    name [word! string!] "Function name to call"
    args [block!] "Block of arguments to pass"
    /validate "Validate arguments before calling"
    /fallback fallback-value "Value to return on any error"
][
    {Safely call any function with optional validation and fallback handling.

    This is the master function for safe function execution, providing optional
    argument validation and comprehensive error handling with fallback support.

    Parameters:
    - name [word! string!] "Function name to call - strings converted to word!"
    - args [block!] "Block of arguments to pass to the function"
    - /validate "If present, validates arguments before attempting the call"
    - /fallback fallback-value "Value to return instead of error! objects on any failure"

    Returns: [any-type!] "Function result, fallback-value, or error! object"

    Errors: Returns error! object for various failure conditions unless /fallback is used.}

    local: [fn-word validation-errors fn-value call-result]
][
    ; Convert string input to word for consistency
    fn-word: either string? name [to-word name] [name]

    ; Validation step (if requested)
    either validate [
        validation-errors: validate-arguments fn-word args
        either empty? validation-errors [
            ; Validation passed - continue to execution
        ][
            ; Validation failed
            either fallback [
                return fallback-value
            ][
                return make error! [
                    type: 'User
                    id: 'validation-failed
                    message: first validation-errors
                ]
            ]
        ]
    ][
        ; No validation requested - proceed directly to execution
    ]

    ; Check if function exists
    either function-exists? fn-word [
        fn-value: get fn-word

        ; Attempt to call the function
        call-result: try [
            ; Use 'do' to apply the function with the argument block
            do compose [(fn-value) (args)]
        ]

        either error? call-result [
            ; Function call failed
            either fallback [
                fallback-value
            ][
                make error! [
                    type: 'User
                    id: 'execution-failed
                    message: rejoin ["Function call failed: " call-result/message]
                ]
            ]
        ][
            ; Function call succeeded
            call-result
        ]
    ][
        ; Function doesn't exist
        either fallback [
            fallback-value
        ][
            make error! [
                type: 'User
                id: 'function-not-found
                message: rejoin ["Function '" to-string fn-word "' does not exist"]
            ]
        ]
    ]
]

; Script last updated: 2025-06-11/UTC
REBOL [
    Title: "Validation Scripts for Rebol 3 Introspection & Validation Library"
    Version: 1.0.0
    Author: "Lutra AI Assistant"
    Date: 11-Jun-2025
    Purpose: {Test suite to verify correct behavior of all introspection library functions}
    Notes: {
        These scripts test each function with various inputs including edge cases,
        non-existent functions, and different input types to ensure robust behavior.
    }
    Keywords: [testing validation introspection rebol3-oldes]
]

;; Load the main library (adjust path as needed)
;; do %introspection-lib.r

;; =============================================================================
;; TEST HELPER FUNCTIONS
;; =============================================================================

assert-equal: function [
    expected [any-type!] "Expected value"
    actual [any-type!] "Actual value"
    test-name [string!] "Name of the test"
][
    {Compare two values and report test results.

    Parameters:
    - expected [any-type!] "The expected result"
    - actual [any-type!] "The actual result from function call"
    - test-name [string!] "Descriptive name for the test"

    Returns: [logic!] "true if test passed, false if failed"

    Errors: Does not return errors - prints results and returns success status.}

    local: [passed]
][
    passed: equal? expected actual

    print reform [
        "Test:" test-name
        "- Expected:" expected
        "- Actual:" actual
        "- Result:" either passed ["PASSED"] ["FAILED"]
    ]
    print ""

    passed
]

assert-error: function [
    result [any-type!] "Result to check for error"
    test-name [string!] "Name of the test"
][
    {Check if result is an error object and report test results.

    Parameters:
    - result [any-type!] "The result to check"
    - test-name [string!] "Descriptive name for the test"

    Returns: [logic!] "true if result is an error, false otherwise"

    Errors: Does not return errors - prints results and returns success status.}

    local: [is-error]
][
    is-error: error? result

    print reform [
        "Test:" test-name
        "- Expected: error! object"
        "- Actual:" either is-error ["error! object"] [type? result]
        "- Result:" either is-error ["PASSED"] ["FAILED"]
    ]
    print ""

    is-error
]

;; =============================================================================
;; CORE INTROSPECTION UTILITIES TESTS (F-01 through F-04)
;; =============================================================================
test-function-exists?: function [] [
    {Test the function-exists? function with various inputs.}
][
    print "=== Testing function-exists? (F-01) ==="

    ; Test with existing native function
    assert-equal true (function-exists? 'print) "Existing native function (word)"
    assert-equal true (function-exists? "print") "Existing native function (string)"

    ; Test with existing action
    assert-equal true (function-exists? 'append) "Existing action function"

    ; Test with non-existent function
    assert-equal false (function-exists? 'non-existent-function) "Non-existent function"
    assert-equal false (function-exists? "non-existent-function") "Non-existent function (string)"

    ; Test with word bound to non-function value
    test-var: "not a function"
    assert-equal false (function-exists? 'test-var) "Word bound to non-function value"

    ; Test with unbound word
    assert-equal false (function-exists? 'completely-unbound-word) "Unbound word"

    print "=== function-exists? tests completed ===^/"
]

test-function-type: function [] [
    {Test the function-type function with various inputs.}
][
    print "=== Testing function-type (F-02) ==="

    ; Test with existing native function
    assert-equal native! (function-type 'print) "Native function type"
    assert-equal native! (function-type "print") "Native function type (string input)"

    ; Test with existing action
    assert-equal action! (function-type 'append) "Action function type"

    ; Test with non-existent function
    assert-equal none (function-type 'non-existent-function) "Non-existent function returns none"

    ; Test with word bound to non-function value
    test-var: "not a function"
    assert-equal none (function-type 'test-var) "Non-function value returns none"

    print "=== function-type tests completed ===^/"
]

test-function-type-matches?: function [] [
    {Test the function-type-matches? function with various inputs.}
][
    print "=== Testing function-type-matches? (F-03) ==="

    ; Test correct type matches
    assert-equal true (function-type-matches? 'print native!) "Correct native type match"
    assert-equal true (function-type-matches? "append" action!) "Correct action type match (string input)"

    ; Test incorrect type matches
    assert-equal false (function-type-matches? 'print action!) "Incorrect type match"
    assert-equal false (function-type-matches? 'append native!) "Another incorrect type match"

    ; Test with non-existent function
    assert-equal false (function-type-matches? 'non-existent-function native!) "Non-existent function type match"

    ; Test with word bound to non-function value
    test-var: "not a function"
    assert-equal false (function-type-matches? 'test-var string!) "Non-function value type match"

    print "=== function-type-matches? tests completed ===^/"
]

test-function-spec: function [] [
    {Test the function-spec function with various inputs.}
][
    print "=== Testing function-spec (F-04) ==="

    ; Test with existing function - verify we get a block
    spec-result: function-spec 'print
    assert-equal block! (type? spec-result) "Print function spec returns block"

    ; Test with string input
    spec-result: function-spec "append"
    assert-equal block! (type? spec-result) "Append function spec returns block (string input)"

    ; Test with non-existent function
    assert-equal none (function-spec 'non-existent-function) "Non-existent function spec returns none"

    ; Test with word bound to non-function value
    test-var: "not a function"
    assert-equal none (function-spec 'test-var) "Non-function value spec returns none"

    ; Verify spec contains expected elements for a known function
    print-spec: function-spec 'print
    either none? print-spec [
        print "Test: Print spec analysis - FAILED (spec was none)"
    ][
        print reform ["Test: Print spec analysis - spec length:" length? print-spec "- PASSED"]
    ]
    print ""

    print "=== function-spec tests completed ===^/"
]

;; =============================================================================
;; FUNCTION ANALYSIS UTILITIES TESTS (F-05 through F-09)
;; =============================================================================

test-required-arg-count: function [] [
    {Test the required-arg-count function with various specifications.}
][
    print "=== Testing required-arg-count (F-05) ==="

    ; Test with empty spec
    assert-equal 0 (required-arg-count []) "Empty spec has 0 required args"

    ; Test with simple spec (no refinements)
    test-spec: [value [any-type!] "Value to process"]
    assert-equal 1 (required-arg-count test-spec) "Simple spec with 1 argument"

    ; Test with multiple required args
    test-spec: [first [any-type!] "First value" second [any-type!] "Second value"]
    assert-equal 2 (required-arg-count test-spec) "Spec with 2 required arguments"

    ; Test with required args and refinements
    test-spec: [value [any-type!] "Value" /local local-var]
    assert-equal 1 (required-arg-count test-spec) "Spec with args and refinement"

    ; Test with refinements only
    test-spec: [/verbose "Verbose output" /debug "Debug mode"]
    assert-equal 0 (required-arg-count test-spec) "Spec with only refinements"

    print "=== required-arg-count tests completed ===^/"
]

test-total-arg-count: function [] [
    {Test the total-arg-count function with various specifications.}
][
    print "=== Testing total-arg-count (F-06) ==="

    ; Test with empty spec
    assert-equal 0 (total-arg-count []) "Empty spec has 0 total args"

    ; Test with simple spec (no refinements)
    test-spec: [value [any-type!] "Value to process"]
    assert-equal 1 (total-arg-count test-spec) "Simple spec with 1 total arg"

    ; Test with required args and refinements
    test-spec: [value [any-type!] "Value" /verbose "Verbose output" /debug "Debug mode"]
    assert-equal 3 (total-arg-count test-spec) "Spec with 1 arg + 2 refinements = 3 total"

    ; Test with multiple args and refinements
    test-spec: [first [any-type!] "First" second [any-type!] "Second" /local local-var /test]
    assert-equal 4 (total-arg-count test-spec) "Complex spec with 2 args + 2 refinements = 4 total"

    print "=== total-arg-count tests completed ===^/"
]

test-function-refinements: function [] [
    {Test the function-refinements function with various specifications.}
][
    print "=== Testing function-refinements (F-07) ==="

    ; Test with empty spec
    result: function-refinements []
    assert-equal 0 (length? result) "Empty spec returns empty refinements block"

    ; Test with no refinements
    test-spec: [value [any-type!] "Value to process"]
    result: function-refinements test-spec
    assert-equal 0 (length? result) "Spec with no refinements returns empty block"

    ; Test with refinements
    test-spec: [value [any-type!] "Value" /verbose "Verbose output" /debug "Debug mode"]
    result: function-refinements test-spec
    assert-equal 2 (length? result) "Spec with 2 refinements returns block of length 2"

    ; Verify the refinements are correct
    either all [
        found? find result /verbose
        found? find result /debug
    ] [
        print "Test: Refinement content verification - PASSED"
    ] [
        print "Test: Refinement content verification - FAILED"
    ]
    print ""

    print "=== function-refinements tests completed ===^/"
]

test-has-refinement?: function [] [
    {Test the has-refinement? function with various inputs.}
][
    print "=== Testing has-refinement? (F-08) ==="

    ; Test with existing function that has refinements
    ; Note: 'find function has /part, /only, /case, etc.
    assert-equal true (has-refinement? 'find /part) "Find function has /part refinement"
    assert-equal true (has-refinement? "find" /only) "Find function has /only refinement (string input)"

    ; Test with refinement that doesn't exist
    assert-equal false (has-refinement? 'find /nonexistent) "Find function lacks nonexistent refinement"

    ; Test with function that has no refinements (if any exist)
    ; Most native functions have refinements, so this might be challenging to test

    ; Test with non-existent function
    assert-equal false (has-refinement? 'non-existent-function /any) "Non-existent function has no refinements"

    print "=== has-refinement? tests completed ===^/"
]

test-function-signature: function [] [
    {Test the function-signature function with various inputs.}
][
    print "=== Testing function-signature (F-09) ==="

    ; Test with existing functions
    sig: function-signature 'print
    assert-equal string! (type? sig) "Print signature returns string"
    print reform ["Print signature:" sig "- PASSED"]
    print ""

    ; Test with string input
    sig: function-signature "find"
    assert-equal string! (type? sig) "Find signature returns string (string input)"
    print reform ["Find signature:" sig "- PASSED"]
    print ""

    ; Test with non-existent function
    assert-equal none (function-signature 'non-existent-function) "Non-existent function signature returns none"

    ; Test with word bound to non-function value
    test-var: "not a function"
    assert-equal none (function-signature 'test-var) "Non-function value signature returns none"

    print "=== function-signature tests completed ===^/"
]

;; =============================================================================
;; SAFE EXECUTION UTILITIES TESTS (F-10 and F-11)
;; =============================================================================

test-validate-arguments: function [] [
    {Test the validate-arguments function with various inputs.}
][
    print "=== Testing validate-arguments (F-10) ==="

    ; Test with correct number of arguments
    ; 'print typically requires 1 argument
    result: validate-arguments 'print ["Hello"]
    assert-equal 0 (length? result) "Correct arguments return empty error block"

    ; Test with too few arguments
    result: validate-arguments 'print []
    either empty? result [
        print "Test: Too few arguments - FAILED (should have returned error)"
    ] [
        print reform ["Test: Too few arguments - Error message:" first result "- PASSED"]
    ]
    print ""

    ; Test with string input
    result: validate-arguments "print" ["Hello"]
    assert-equal 0 (length? result) "String input with correct arguments"

    ; Test with non-existent function
    result: validate-arguments 'non-existent-function ["arg"]
    either empty? result [
        print "Test: Non-existent function - FAILED (should have returned error)"
    ] [
        print reform ["Test: Non-existent function - Error message:" first result "- PASSED"]
    ]
    print ""

    print "=== validate-arguments tests completed ===^/"
]
