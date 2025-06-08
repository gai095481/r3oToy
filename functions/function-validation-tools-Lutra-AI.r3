REBOL [
    Title: "Advanced Function Validation Utilities for Rebol 3 Oldes"
    Date: 07-Jun-2025
    File: %function-validation-tools.r3
    Author: "Lutra AI Assistant guided by a person"
    Version: "1.0.0"
    Status: "Minor improvements needed."
    Purpose: {
        Provides a comprehensive set of utilities for validating function existence
        and properties in Rebol 3 Oldes scripts.  These utilities enable robust function
        checking, argument validation and safe function calling with a fallback
        mechanisms.

        The utilities include:
        - Function existence checking (any type of callable function).
        - Specific function type detection (native, action, etc.).
        - Function introspection (arity, refinements, signature).
        - Argument validation against function specifications.
        - Safe function calling with error handling and fallbacks.

        Together, these tools provide a foundation for creating more robust,
        adaptive and self-documenting Rebol code.
    }
    Notes: {
        This script addresses common challenges in Rebol programming related to
        function availability and type validation.  It provides a systematic approach
        to handling optional dependencies, version differences between Rebol
        implementations and runtime function validation.

        The utilities are designed to be lightweight, non-intrusive and compatible
        with different Rebol 3 implementations. They follow Rebol's philosophy of
        clarity and simplicity while adding an additional layer of safety.

        All functions are thoroughly documented and include practical examples
        to demonstrate their usage in real-world scenarios.
    }
    Keywords: [
        rebol rebol3 function-validation type-checking introspection
        safe-function-call error-handling fallback-mechanism
        function-discovery function-existence function-arity
        argument-validation refinement-detection function-signature
        robust-code self-documenting-code adaptive-programming
    ]
    Security-Considerations: {
        1. Defensive Programming: These utilities enable defensive programming
           practices by validating function existence and argument types before
           execution, reducing the risk of runtime errors in production environments.

        2. Safe Integration: When integrating with external libraries or code from
           different sources, these utilities provide a safety layer that prevents
           errors due to missing or incompatible functions.

        3. Input Validation: The argument validation capabilities help prevent
           type-related security issues by ensuring that functions receive the
           expected data types, reducing the risk of injection attacks or unexpected
           behavior due to malformed inputs.

        4. Graceful Degradation: The fallback mechanisms allow scripts to gracefully
           handle missing functionality, enabling more robust behavior in restricted
           or varying runtime environments.
    }
]

;;------------------------------------------------------------------------------
;; FUNCTION-EXISTS? - Check if a word represents any callable function.
;;------------------------------------------------------------------------------
function-exists?: function [
    {Check if a word exists and contains a callable function.}
    word-name [word!] "Word to check for function existence"
] [
    ;; Safe check: first verify the word has a value, then check if it's any function type
    all [
        value? word-name
        any-function? get/any word-name
    ]
]

;;------------------------------------------------------------------------------
;; NATIVE-FUNCTION? - Check if a word represents specifically a native function.
;;------------------------------------------------------------------------------
native-function?: function [
    {Check if a word exists and contains specifically a native function.}
    word-name [word!] "Word to check for native function"
] [
    ;; Safe check: first verify the word has a value, then check if it's a native function
    all [
        value? word-name
        native! = type? get/any word-name
    ]
]

;;------------------------------------------------------------------------------
;; ANY-FUNCTION? - Polyfill for systems without `any-function?`
;;------------------------------------------------------------------------------
if not value? 'any-function? [
    any-function?: function [
        {Return TRUE if value is any type of function.}
        value [any-type!]
    ] [
        ;; Check all possible function types in Rebol:
        found: false
        foreach type [native! action! function! op! routine! closure!] [
            if type = type? :value [found: true break]
        ]
        found
    ]
]

;;------------------------------------------------------------------------------
;; FUNCTION-TYPE - Get the specific type of a function.
;;------------------------------------------------------------------------------
function-type: function [
    {Return the specific type of a function.}
    func-word [word!] "Function to analyze"
] [
    ;; Check if function exists
    if not function-exists? func-word [
        return make error! rejoin ["Function " func-word " not available"]
    ]

    ;; Return the type:
    type? get func-word
]

;;------------------------------------------------------------------------------
;; FUNCTION-SPEC - Get a function's specification block.
;;------------------------------------------------------------------------------
function-spec: function [
    {Return a function's specification block, accounting for different function types.}
    func-word [word!] "Function to analyze"
] [
    ;; Check if function exists
    if not function-exists? func-word [
        return make error! rejoin ["Function " func-word " not available"]
    ]

    func-value: get func-word
    func-type: type? func-value

    ;; Extract spec based on function type
    case [
        ;; Most function types store spec in 3rd position:
        any [
            func-type = function!
            func-type = native!
            func-type = action!
        ] [
            first skip func-value 2
        ]

        ;; Handle special cases for other function types:
        ;; This may need to be adjusted for specific Rebol implementations.
        true [
            ;; Try to use spec-of if available (Rebol 3)
            if function-exists? 'spec-of [
                return spec-of :func-value
            ]

            ;; Fallback - may not work for all function types
            first skip func-value 2
        ]
    ]
]

;;------------------------------------------------------------------------------
;; FUNCTION-ARITY - Get the number of arguments a function accepts.
;;------------------------------------------------------------------------------
function-arity: function [
    {Return the number of non-refinement arguments a function accepts.}
    func-word [word!] "Function to analyze"
    /with-refinements "Include refinement arguments in the count"
] [
    ;; Check if function exists:
    if not function-exists? func-word [
        return make error! rejoin ["Function " func-word " not available."]
    ]

    ;; Get function spec and count arguments:
    spec: function-spec func-word
    arg-count: 0

    ;; Process each item in the spec block:
    refinement-mode: false

    foreach item spec [
        ;; Skip datatype specs and string descriptions:
        if any [string? item block? item] [continue]

        ;; Check for refinements:
        case [
            refinement? item [
                refinement-mode: true
                continue
            ]

            ;; Count arguments:
            word? item [
                either all [refinement-mode not with-refinements] [
                    ;; Skip refinement arguments unless requested
                    continue
                ] [
                    ;; Count this argument:
                    arg-count: arg-count + 1
                ]
            ]
        ]
    ]

    return arg-count
]

;;------------------------------------------------------------------------------
;; FUNCTION-HAS-REFINEMENT? - Check if a function has a specific refinement.
;;------------------------------------------------------------------------------
function-has-refinement?: function [
    {Check if a function has a specific refinement.}
    func-word [word!] "Function to check"
    refinement-name [word!] "Refinement to look for (without the /)"
] [
    ;; Check if function exists:
    if not function-exists? func-word [
        return make error! rejoin ["Function " func-word " not available"]
    ]

    ;; Get function spec and look for the refinement:
    spec: function-spec func-word

    ;; Create the refinement word (with /):
    ref-word: to refinement! refinement-name

    ;; Look for the refinement in the spec - using direct check instead of `found?`:
    not none? find spec ref-word
]

;;------------------------------------------------------------------------------
;; FUNCTION-SIGNATURE - Get a function's signature as a string.
;;------------------------------------------------------------------------------
function-signature: function [
    {Return a string representation of a function's signature.}
    func-word [word!] "Function to analyze"
] [
    ;; Check if function exists:
    if not function-exists? func-word [
        return make error! rejoin ["Function " func-word " not available"]
    ]

    ;; Get function spec:
    spec: function-spec func-word

    ;; Build signature string - initialize as a `string!`:
    result: copy ""
    append result form func-word  ;; Start with the function name
    current-section: 'args

    foreach item spec [
        case [
            ;; Skip string descriptions
            string? item [continue]

            ;; Skip type specs
            block? item [continue]

            ;; Handle refinements:
            refinement? item [
                current-section: 'refinement
                append result rejoin [" " form item]
            ]

            ;; Handle arguments:
            word? item [
                append result rejoin [" " form item]
            ]
        ]
    ]

    return result
]

;;------------------------------------------------------------------------------
;; VALIDATE-ARGS - Validate arguments against expected types.
;;------------------------------------------------------------------------------
validate-args: function [
    {Validate arguments against expected types.}
    func-word [word!] "Function to validate against"
    args [block!] "Arguments to validate"
] [
    ;; Check if function exists:
    if not function-exists? func-word [
        return make error! rejoin ["Function " func-word " not available"]
    ]

    ;; Get function spec:
    spec: function-spec func-word

    ;; Prepare for validation:
    arg-pos: 1
    validation-errors: copy []
    current-ref: none
    current-ref-name: none

    ;; Process each item in the spec:
    foreach [item next-item] append copy spec none [
        ;; Skip string descriptions
        if string? item [continue]

        ;; Handle refinements:
        if refinement? item [
            current-ref: item
            current-ref-name: to word! form item
            continue
        ]

        ;; Handle arguments:
        if all [word? item block? next-item] [
            ;; Skip refinement arguments unless the refinement is used
            if all [
                current-ref
                not find args current-ref-name
            ] [
                continue
            ]

            ;; Validate this argument if we have enough args:
            if arg-pos <= length? args [
                arg-value: pick args arg-pos

                ;; Check type against spec:
                type-valid?: false
                foreach type next-item [
                    if type? :arg-value = type [
                        type-valid?: true
                        break
                    ]
                ]

                ;; Record error if type doesn't match:
                if not type-valid? [
                    append validation-errors rejoin [
                        "Argument " arg-pos " (" item "): Expected "
                        next-item " but got " type? :arg-value
                    ]
                ]

                arg-pos: arg-pos + 1
            ]
        ]
    ]

    ;; Check if we have extra arguments:
    if arg-pos <= length? args [
        append validation-errors rejoin [
            "Too many arguments: expected "
            arg-pos - 1 " but got " length? args
        ]
    ]

    ;; Return results:
    either empty? validation-errors [
        true
    ][
        validation-errors
    ]
]

;;------------------------------------------------------------------------------
;; SAFE-FUNCTION-CALL - Safely call a function with error handling.
;;------------------------------------------------------------------------------
safe-function-call: function [
    {Safely call a function with comprehensive error handling.}
    func-word [word!] "Function to call"
    args [block!] "Arguments to pass"
    /with-fallback "Provide fallback behavior"
    fallback [block!] "Fallback code to execute"
    /validate "Validate arguments before calling"
] [
    ;; First check if function exists:
    either function-exists? func-word [
        ;; Optional argument validation
        if validate [
            validation-result: validate-args func-word args

            if not equal? validation-result true [
                ;; Validation failed
                if with-fallback [return do fallback]
                return make error! rejoin [
                    "Argument validation failed for " func-word ": "
                    mold validation-result
                ]
            ]
        ]

        ;; Use apply to correctly pass arguments to the function:
        result: try/with [
            apply get func-word args
        ] func [err] [
            if with-fallback [do fallback]
            err ;; Return the error
        ]

        return result
    ][
        ;; Function doesn't exist:
        if with-fallback [return do fallback]
        return make error! rejoin ["Function " func-word " not available"]
    ]
]

;;------------------------------------------------------------------------------
;; TEST CASES
;;------------------------------------------------------------------------------
print "=== Function Checker Tests ==="

;; Test known functions - note the use of length? instead of length
foreach test-word [print length? check first] [
    either function-exists? test-word [
        print ["+" test-word "exists as" type? get test-word]
    ][
        print ["-" test-word "not available"]
    ]
]

;; Test specifically for native functions
foreach test-word [print length? check add] [
    either native-function? test-word [
        print ["+" test-word "is a native function"]
    ][
        either function-exists? test-word [
            print ["o" test-word "exists but is not native"]
        ][
            print ["-" test-word "not available"]
        ]
    ]
]

;; Test safe function calling
print "^/=== Safe Function Call Example ==="
result: safe-function-call 'length? [
    "Test string"
]
print ["Result:" result]

;; Test with fallback
print "^/=== Fallback Example ==="
result: safe-function-call/with-fallback 'nonexistent [
    "Test"
] [
    print "Fallback executed"
    10 ;; Return value from fallback
]
print ["Result:" either error? result ["Error handled"] [result]]

;; Test advanced function analysis
print "^/=== Advanced Function Analysis ==="

;; Test function type
print "^/Function Type Tests:"
print ["length? is of type:" function-type 'length?]
print ["append is of type:" function-type 'append]

;; Test function arity
print "^/Function Arity Tests:"
print ["length? has" function-arity 'length? "required argument(s)"]
print ["append has" function-arity 'append "required argument(s)"]
print ["append has" function-arity/with-refinements 'append "total argument(s) including refinements"]

;; Test refinement checking
print "^/Refinement Tests:"
print ["Does append have /dup refinement?" function-has-refinement? 'append 'dup]
print ["Does length? have /skip refinement?" function-has-refinement? 'length? 'skip]

;; Test function signature
print "^/Function Signature Tests:"
print ["length? signature:" function-signature 'length?]
print ["append signature:" function-signature 'append]

;; Test argument validation
print "^/Argument Validation Tests:"

;; Valid arguments
print "Valid arguments validation:"
validation-result: validate-args 'length? ["test"]
print ["length? with string argument:" mold validation-result]

;; Invalid arguments
print "Invalid arguments validation:"
validation-result: validate-args 'length? [123]
print ["length? with integer argument:" mold validation-result]

;; Test safe function call with validation
print "^/Safe Function Call with Validation:"
result: safe-function-call/validate 'length? ["Valid string"]
print ["Valid call result:" result]

result: try [safe-function-call/validate 'length? [123]]
print ["Invalid call result:" either error? result ["Error caught correctly"] [result]]

print "^/=== END OF TEST CASES ==="
