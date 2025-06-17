REBOL [
    Title: "Advanced Function Introspection Suite for Rebol 3 Oldes"
    Date: 16-Jun-2025
    File: %function-introspection-suite.r3
    Author: "Gemini Pro Preview v2025-06-05, Claude 4 Sonnet & Human Collaborator"
    Version: 0.1.0
    Status: "All test cases passed + Claude optimizations"
	Purpose: {
		Provide a comprehensive, secure and fully tested set of utilities for
		validating function existence and properties in Rebol 3 Oldes scripts.
		Correctly parses function specifications using `spec-of`,
		provide accurate arity, refinement and signature information.
		Adhere to all specified error-handling, coding and performance standards.
	}
	Security: {
		Implement defense-in-depth security practices:
		- Datatype checking before operations.
		- Correctly uses `spec-of` for reflection without code execution.
		- Safe, structured error handling without information leakage.
	}
	Usage: {
		Primary functions:
		- function-exists? : Safely validate if a function exists.
		- get-function-type : Get function type with validation.
		- get-function-arity : Safely get argument count.
		- has-refinement? : Validate if a function has a specific refinement.
		- get-function-signature : Get a human-readable function signature.
		- validate-function-arguments : Validate arguments before calling.
		- safe-function-call : Execute functions with error handling.
	}
	Keywords: [
		rebol rebol3 function introspection reflection spec-of
		arity refinement signature validation error-handling
		safe-call security qa testing utilities vibe-coding
	]
]

;;============================================================================
;; QA TEST HARNESS
;;============================================================================
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

assert-true: function [
    {Assert that a condition is `true` and outputs a PASSED or FAILED message.}
    condition [any-type!] "The condition to test.  Expect `true`."
    description [string!] "A description of the specific QA test being run."
][
    assert-equal true to-logic :condition description
]

assert-false: function [
    {Assert that a condition is `false` and outputs a PASSED or FAILED message.}
    condition [any-type!] "The condition to validate.  Expect `false`."
    description [string!] "A description of the specific QA test being run."
][
    assert-equal false to-logic :condition description
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"

    either all-tests-passed? [
        print "✅ ALL TESTS PASSED"
    ][
        print "❌ SOME TESTS FAILED"
    ]
    print "============================================^/"
]

;;============================================================================
;; CORE VALIDATION UTILITIES
;;============================================================================
function-exists?: function [
    {Safely validate if a function exists in the current context.}
    func-name [word!] "Name of the function to validate."
    return: [logic!] "`true` if function exists, otherwise `false`"
][
    unless word? func-name [
        return false
    ]

    set/any 'value try [get/any func-name]

    if error? :value [return false]

    return not unset? :value
]

get-function-type: function [
    {Safely determine the type of a function.}
    func-name [word!] "Name of the function to analyze."
    return: [word! | none!] "Function type or `none` if invalid."
][
    unless function-exists? func-name [
        return none
    ]

    set/any 'func-value try [get func-name]

    if any [error? :func-value none? :func-value] [
        return none
    ]

    return to-word type? :func-value
]

get-function-arity: function [
    {Safely determine the arity (argument count), of a function using `spec-of`.}
    func-name [word!] "Name of the function to analyze."
    return: [block! | none!] "A block of two integers `[required total]` or `none` on failure."
][
    if not function-exists? func-name [return none]

    set/any 'result try [
        func-value: get func-name
        spec: spec-of :func-value
        required-count: 0
        total-count: 0
        in-refinement?: false

        foreach item spec [
            either any [refinement? :item lit-word? :item] [
                in-refinement?: true
            ][
                if word? :item [
                    total-count: total-count + 1
                    if not in-refinement? [
                        required-count: required-count + 1
                    ]
                ]
            ]
        ]
        reduce [required-count total-count]
    ]

    if error? result [return none]

    return :result
]

has-refinement?: function [
    {Safely check if a function has a specific refinement using `spec-of`.}
    func-name [word!] "Name of the function to validate."
    return: [logic!] "`true` if the refinement exists, otherwise `false`."
    refinement [word!] "Refinement to expect (without the '/' character)."
][
    if not function-exists? func-name [return false]

    set/any 'result try [
        func-value: get func-name
        spec: spec-of :func-value
        refinement-string: to-string refinement

        foreach item spec [
            if any [refinement? :item lit-word? :item] [
                if refinement-string = to-string item [
                    return true
                ]
            ]
        ]

        return false
    ]

    if error? result [return false]
    return :result
]

get-function-signature: function [
    {Get a human-readable signature for a function using `spec-of`.}
    func-name [word!] "Name of the function to analyze."
    return: [string! | none!] "The signature as a string or `none` on failure."
][
    if not function-exists? func-name [return none]

    set/any 'result try [
        func-value: get func-name
        spec: spec-of :func-value
        signature: copy to-string func-name

        foreach item spec [
            if any [word? :item refinement? :item lit-word? :item] [
                append signature " "
                append signature either any [refinement? :item lit-word? :item] [
                    rejoin ["/" to-string item]
                ][
                    to-string item
                ]
            ]
        ]

        return signature
    ]

    if error? result [return none]
    return :result
]

validate-function-arguments: function [
    {Validate arguments against a function's specification.}
    func-name [word!] "Name of the function to validate against."
    return: [block!] "A block of error messages; the block is empty if validation passes."
    arguments [block!] "Arguments to validate."
][
    errors: copy []

    if not word? func-name [
        append errors "Invalid function name: must be word!"
        return errors
    ]

    if not block? arguments [
        append errors "Invalid arguments: must be block!"
        return errors
    ]

    unless function-exists? func-name [
        append errors rejoin ["Function does not exist: " func-name]
        return errors
    ]

    arity-info: get-function-arity func-name

    unless arity-info [
        append errors rejoin ["Cannot determine arity for function: " func-name]
        return errors
    ]

    required-args: first arity-info
    total-args: second arity-info
    provided-args: length? arguments

    if provided-args < required-args [
        append errors rejoin ["Too few arguments: expected " required-args ", got " provided-args]
    ]

    if provided-args > total-args [
        append errors rejoin ["Too many arguments: expected " total-args ", got " provided-args]
    ]

    return errors
]

safe-function-call: function [
    {Safely call a function with comprehensive error handling.}
    func-name [word!] "Name of the function to call."
    return: [any-type!] "The result of the function call, a fallback value or an error object."
    arguments [block!] "Arguments to pass to the function."
    /fallback "Use fallback value on error."
    fallback-value [any-type!] "Value to return on error."
][
    result: none
    validation-errors: validate-function-arguments func-name arguments

    if not empty? validation-errors [
        result: either fallback [
            :fallback-value
        ][
            error-msg: rejoin ["Function call validation failed: " first validation-errors]
            make error! [type: 'User id: 'message message: error-msg]
        ]
    ]

    if none? result [
        set/any 'result try [
            func-value: get func-name
            apply :func-value arguments
        ]

        if error? :result [
            result: either fallback [
                :fallback-value
            ][
                make error! [type: 'User id: 'message message: rejoin ["Function execution failed: " func-name]]
            ]
        ]
    ]

    return :result
]

;;============================================================================
;; COMPREHENSIVE QA TEST SUITE
;;============================================================================
run-comprehensive-tests: does [
    {Run comprehensive validation tests with clear, accurate reporting.}

    print "=== COMPREHENSIVE FUNCTION VALIDATION TESTS ==="

    print "^/--- Test Section: `function-exists?` ---"
    assert-true function-exists? 'print "print should exist."
    assert-false function-exists? 'non-existent-function "non-existent-function should not exist."

    print "^/--- Test Section: `get-function-type` ---"
    assert-equal 'action! get-function-type 'length? "length? should be type action!."
    assert-equal none get-function-type 'non-existent-function "A non-existent function should return none for type."

    print "^/--- Test Section: `get-function-arity` ---"
    assert-equal [1 1] get-function-arity 'length? "CORRECT: length? has 1 required, 1 total args."
    assert-equal [2 4] get-function-arity 'append "CORRECT: append has 2 required, 4 total args."
    print newline

    print "^/--- Test Section: `has-refinement?` ---"
    assert-true has-refinement? 'append 'dup "append should have /dup refinement."
    assert-false has-refinement? 'length? 'skip "CORRECT: length? does NOT have /skip."
    assert-false has-refinement? 'print 'skip "print should not have /skip refinement."

    print "^/--- Test Section: `get-function-signature` ---"
    assert-equal "length? series" get-function-signature 'length? "CORRECT: Signature for length?."
    assert-equal "append series value /part range /only /dup count" get-function-signature 'append "CORRECT: Signature for append."

    print "^/--- Test Section: `validate-function-arguments` ---"
    assert-true empty? validate-function-arguments 'length? ["hello"] "Valid call to length? should produce no errors."
    assert-equal ["Too many arguments: expected 1, got 2"] validate-function-arguments 'length? ["a" "b"] "Invalid call to length? should produce an error."
    assert-true empty? validate-function-arguments 'append ["a" "b"] "Valid call to append should produce no errors."
    assert-equal ["Too few arguments: expected 2, got 1"] validate-function-arguments 'append ["a"] "Invalid call to append should produce an error."

    print "^/--- Test Section: `safe-function-call` ---"
    assert-equal 5 safe-function-call 'length? ["hello"] "Safe call to length? should return the correct value."
    assert-equal "fallback" (safe-function-call/fallback 'append ["a"] "fallback") "Invalid safe call to append should return fallback."
    set/any 'error-result try [safe-function-call 'append ["a"]]
    assert-true error? :error-result "safe-function-call without fallback should produce an error."
    print newline

    print-test-summary
]

;;============================================================================
;; DEMONSTRATION EXECUTION
;;============================================================================
run-comprehensive-tests
