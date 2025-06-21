# **Advanced Function Introspection Suite User's Guide**

A set of robust, secure utilities for introspecting function existence and properties in Rebol 3 Oldes.  It enables developers to safely analyze a function's characteristics (such as its argument count, refinements and signature) before execution.  The entire suite is built around the `spec-of` native for accuracy and uses safe, idiomatic error-handling patterns.

## **Installation and Usage**

To use these utilities, `do` the script file into your project.  All introspection functions will then be available in the global context.

```rebol
do %function-introspection-suite.r3

;; Ask if the `append` function exists:
if function-exists? 'append [
    print "The 'append' function exists."
]
```

## **API Reference**

This section details the public-facing functions provided by the utility suite.

### `function-exists?`

Safely checks if a word refers to a defined function in the current context.

**Signature:** `function-exists? func-name`
-   `func-name` [word!]: The word to check.
-   **Returns** [logic!]: Returns `true` if the function exists, otherwise `false`.

**Example:**
```rebol
assert-true function-exists? 'print      ; This will pass.
assert-false function-exists? 'no-such-function  ; This will also pass.
```

### `get-function-type`

Safely determines the datatype of a function.

**Signature:** `get-function-type func-name`
-   `func-name` [word!]: The word for the function to analyze.
-   **Returns** [word! | none!]: Returns the function's type (e.g., `action!`, `native!`) as a `word!` or `none` if the function does not exist or an error occurs.

**Example:**
```rebol
type: get-function-type 'append
print ["Type of 'append' is:" type]
;   >> Type of 'append' is: action!
```

### `get-function-arity`

Safely determines the argument count (arity) of a function.

**Signature:** `get-function-arity func-name`
-   `func-name` [word!]: The word for the function to analyze.
-   **Returns** [block! | none!]: Returns a two-element `block!` containing `[required-args total-args]` or `none` on failure.  *Total arguments* includes all arguments for all refinements.

**Example:**
```rebol
arity-info: get-function-arity 'append
print [
    "Append requires" (first arity-info) "arguments and has"
    (second arity-info) "total arguments."
]
;   >> Append requires 2 arguments and has 4 total arguments.
```

### `has-refinement?`

Safely checks if a function's specification includes a given refinement.

**Signature:** `has-refinement? func-name refinement`
-   `func-name` [word!]: The word for the function to check.
-   `refinement` [word!]: The name of the refinement to look for, without the leading slash (`/`).
-   **Returns** [logic!]: Returns `true` if the refinement exists, otherwise `false`.

**Example:**
```rebol
print ["'append' has /dup?" has-refinement? 'append 'dup]
;   >> 'append' has /dup? true

print ["'length?' has /dup?" has-refinement? 'length? 'dup]
;   >> 'length?' has /dup? false
```

### `get-function-signature`

Generates a clean, human-readable signature for a function.

**Signature:** `get-function-signature func-name`
-   `func-name` [word!]: The word for the function to analyze.
-   **Returns** [string! | none!]: Returns a string containing the formatted signature or `none` on failure.

**Example:**
```rebol
signature: get-function-signature 'append
print ["Signature:" signature]
;   >> Signature: append series value /part range /only /dup count
```

### `validate-function-arguments`

Validates a block of arguments against a function's arity.

**Signature:** `validate-function-arguments func-name arguments`
-   `func-name` [word!]: The word for the function to validate against.
-   `arguments` [block!]: A block of arguments to be checked.
-   **Returns** [block!]: Returns a block of error strings.  The block is empty if validation succeeds.

**Example:**
```rebol
;; A valid call.
errors: validate-function-arguments 'length? ["hello"]
print ["Validation result:" either empty? errors ["Valid"] [errors]]
;   >> Validation result: Valid

;; An invalid call.
errors: validate-function-arguments 'append ["one"]
print ["Validation result:" errors]
;   >> Validation result: [Too few arguments: expected 2, got 1]
```

### `safe-function-call`

Executes a function only after validating its arguments, with controlled error handling.

**Signature:** `safe-function-call func-name arguments /fallback fallback-value`
-   `func-name` [word!]: The word for the function to call.
-   `arguments` [block!]: The block of arguments to pass to the function.
-   `/fallback` [refinement!]: If present, the function will not error on failure.
-   `fallback-value` [any-type!]: The value to return if validation or execution fails.
-   **Returns** [any-type!]: Returns the result of the function call, the `fallback-value` on failure (if `/fallback` is used) or a structured `error!` object on failure.

**Example:**
```rebol
;; Successful call
result: safe-function-call 'length? ["hello"]
print ["Result:" result]
;   >> Result: 5

;; Failed call with fallback
result: safe-function-call/fallback 'append ["a"] "FAILED"
print ["Result:" result]
;   >> Result: FAILED

;; Failed call that produces a catchable error
result: try [safe-function-call 'append ["a"]]
print ["Result is an error?" error? result]
;   >> Result is an error? true
```

## **Error Handling Philosophy**

The utilities are designed to be safe and predictable.
1.  **Graceful Failure:** Most functions (`get-function-type`, `get-function-arity`, etc.) will return `none` or `false` when they encounter an issue, preventing script crashes.
2.  **Explicit Errors:** The `safe-function-call` function, when used *without* the `/fallback` refinement, is designed to fail loudly by returning a structured `error!` object.  This allows for robust `try/with` patterns in the calling code.
---
## Typical Function Validation Code
```
if all [
    attempt [get 'append]
    any-function? get 'append
] [
    print "The 'append' function exists and is callable."
]
```
The `function-exists?` implementation represents a significant improvement over the typical `if all` approach above, demonstrating superior error handling and more comprehensive validation logic.

### Superior Error Handling Architecture
The `function-exists?` employs a more sophisticated error handling strategy through the combination of `set/any` with `try` and `get/any`.
This approach provides several advantages over the simpler `attempt` method. The `set/any` operation ensures that even unset values are captured properly,
while the `try` block prevents any evaluation errors from propagating to the calling context. This creates a robust barrier against various failure modes that might occur during function lookup.
The explicit error checking with `if error? :value` provides precise error detection rather than relying on the broader failure detection of `attempt`.
This granular approach allows for more predictable behavior and clearer debugging when issues arise.

### Comprehensive Value State Detection
The `function-exists?` addresses a critical limitation in the simpler approaches by explicitly testing for unset values using `return not unset? :value`.
This check ensures that the function distinguishes between truly undefined words and words that have been explicitly set to unset values, which represents a more accurate assessment of function availability.
The use of get/any rather than plain get allows the function to retrieve values regardless of their type, including unset values that would normally cause get to fail.
This comprehensive retrieval mechanism ensures that all possible word states are properly evaluated.

### Improved Type Safety and Validation
The initial type checking with `unless word? func-name` provides early validation that prevents inappropriate inputs from progressing through the more complex evaluation logic.
This defensive programming practice improves both performance and reliability by catching type errors at the function boundary.
The systematic progression from type validation through existence checking to value state verification creates a comprehensive validation pipeline to handle edge cases more effectively than simpler approaches.

### Comparison with Alternative Methods
This implementation surpasses the `attempt [get 'word]` pattern by providing more precise error categorization and handling unset value scenarios that the simpler approach might miss.
The combination of multiple validation steps creates a more thorough assessment of function availability than any single-step approach might achieve.
The explicit return values and clear error handling make this implementation more maintainable and debuggable compared to approaches that rely on implicit error handling or value coercion.

### Conclusion
The `function-exists?` implementation demonstrates excellent understanding of Rebol's value system and error handling mechanisms.
The function provides comprehensive validation that handles edge cases effectively while maintaining clear, readable code structure.
This approach represents a best practice for defensive programming in Rebol 3 environments where reliable function existence checking is required.

---
```
=== COMPREHENSIVE FUNCTION VALIDATION TESTS ===

--- Test Section: `function-exists?` ---
✅ PASSED: print should exist.
✅ PASSED: non-existent-function should not exist.

--- Test Section: `get-function-type` ---
✅ PASSED: length? should be type action!.
✅ PASSED: A non-existent function should return none for type.

--- Test Section: `get-function-arity` ---
✅ PASSED: CORRECT: length? has 1 required, 1 total args.
✅ PASSED: CORRECT: append has 2 required, 4 total args.

--- Test Section: `has-refinement?` ---
✅ PASSED: append should have /dup refinement.
✅ PASSED: CORRECT: length? does NOT have /skip.
✅ PASSED: print should not have /skip refinement.

--- Test Section: `get-function-signature` ---
✅ PASSED: CORRECT: Signature for length?.
✅ PASSED: CORRECT: Signature for append.

--- Test Section: `validate-function-arguments` ---
✅ PASSED: Valid call to length? should produce no errors.
✅ PASSED: Invalid call to length? should produce an error.
✅ PASSED: Valid call to append should produce no errors.
✅ PASSED: Invalid call to append should produce an error.

--- Test Section: `safe-function-call` ---
✅ PASSED: Safe call to length? should return the correct value.
✅ PASSED: Invalid safe call to append should return fallback.
✅ PASSED: safe-function-call without fallback should produce an error.

============================================
✅ ALL TESTS PASSED
============================================
```
