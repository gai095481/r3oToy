REBOL [
    Title: "Heavily Commented Diagnostic Probe Script for GET"
    Date: 20-Jul-2024
    Author: "Rebol Expert"
    Purpose: "A comprehensive and educational script to test and explain the GET native."
]

print "=== DIAGNOSTIC PROBE SCRIPT FOR 'GET' FUNCTION ==="
print "=== Using Battle-Tested QA Harness ==="
print newline

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;
;; This section contains helper functions that provide a consistent and
;; readable way to test our code's behavior. `assert-equal` checks if our
;; code produced the result we expected. `assert-error` checks if our code
;; correctly failed when we expected it to.
;;-----------------------------------------------------------------------------
all-tests-passed?: true
assert-equal: function [
    "Compare two values and output a formatted PASSED or FAILED message."
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

assert-error: function [
    "Confirm that a block of code correctly throws an error."
    code-to-run [block!] "The code block expected to error."
    description [string!] "A description of the specific QA test being run."
][
    result: try code-to-run
    either error? result [
        print ["✅ PASSED:" description]
    ][
        set 'all-tests-passed? false
        print ["❌ FAILED:" description "^/   >> Expected an error, but none occurred."]
    ]
]

print-test-summary: does [
    "Prints the final summary of the entire test run."
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL `get` EXAMPLES PASSED"
    ][
        print "❌ SOME `get` EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; SECTION 1: Setup Test Environment
;;
;; CONTEXT: Before we run tests, we need data to test with.
;; PURPOSE: This section creates a variety of variables (`test-integer`,
;; `test-string`, etc.) and a nested `object!` to ensure our `get` tests
;; cover a wide range of realistic Rebol data types and structures.
;;=============================================================================
print "=== SETTING UP TEST ENVIRONMENT ==="

;; Create comprehensive test data covering all major REBOL data types
test-integer: 42
test-string: "hello world"
test-block: [a b c]
test-none: none
test-true: true
test-false: false
test-decimal: 3.14159
test-empty-block: []
test-empty-string: ""
test-zero: 0
test-negative: -100
test-large-num: 999999999

;; Create test object with nested structure
test-obj: make object! [
    name: "test-object"
    value: 100
    nested: make object! [
        deep: "nested-value"
        deeper: make object! [
            deepest: "very-deep"
        ]
    ]
]

;; Create various word references to test indirect access
test-word-ref: 'test-integer
test-path-ref: 'test-obj/name
test-deep-path-ref: 'test-obj/nested/deep

print "Test environment initialized with comprehensive data types"
print newline

;;=============================================================================
;; SECTION 2: Probing Basic GET Behavior with Core Data Types
;;
;; CONTEXT: This is the most basic and common use of `get`.
;; PURPOSE: To verify that `get` can correctly retrieve the value associated
;; with a word, regardless of the datatype of that value (number, text, block, etc.).
;; This confirms the function's primary role.
;;=============================================================================
print "=== PROBING BASIC GET BEHAVIOR ==="

;; HYPOTHESIS: GET should retrieve values from words regardless of data type.
assert-equal 42 get 'test-integer "GET retrieves integer value from word"
assert-equal "hello world" get 'test-string "GET retrieves string value from word"
assert-equal [a b c] get 'test-block "GET retrieves block value from word"
assert-equal none get 'test-none "GET retrieves none value from word"
assert-equal true get 'test-true "GET retrieves true logic value from word"
assert-equal false get 'test-false "GET retrieves false logic value from word"
assert-equal 3.14159 get 'test-decimal "GET retrieves decimal value from word"

print newline

;;=============================================================================
;; SECTION 3: Probing GET with Empty and Edge Case Values
;;
;; CONTEXT: Robust code must handle "edge cases" like empty data or zero.
;; PURPOSE: This ensures `get` doesn't fail or behave unexpectedly when
;; retrieving values that might be considered "empty" or are boundary
;; conditions (like zero or negative numbers). This confirms `get` is reliable.
;;=============================================================================
print "=== PROBING GET WITH EMPTY AND EDGE CASE VALUES ==="

;; HYPOTHESIS: GET should handle empty collections and boundary values correctly.
assert-equal [] get 'test-empty-block "GET handles empty block"
assert-equal "" get 'test-empty-string "GET handles empty string"
assert-equal 0 get 'test-zero "GET handles zero value"
assert-equal -100 get 'test-negative "GET handles negative values"
assert-equal 999999999 get 'test-large-num "GET handles large numeric values"

print newline

;;=============================================================================
;; SECTION 4: Probing GET with Word References and Indirection
;;
;; CONTEXT: What if the name of the variable you want is stored in another variable?
;; PURPOSE: This demonstrates the power of "indirection". The `test-word-ref`
;; variable holds the word `'test-integer`. `get test-word-ref` first gets the
;; value of `test-word-ref` (which is `'test-integer`) and then gets the value
;; of *that* word. This is key for dynamic programming.
;;=============================================================================
print "=== PROBING GET WITH WORD REFERENCES ==="

;; HYPOTHESIS: GET should work with lit-word! values and indirect references.
assert-equal 42 get test-word-ref "GET works with lit-word reference"

;; Test dynamic word creation and retrieval
dynamic-word: 'test-string
assert-equal "hello world" get dynamic-word "GET works with dynamically referenced word"

print newline

;;=============================================================================
;; SECTION 5: Probing GET with Object Paths
;;
;; CONTEXT: Objects store data in named fields. A "path" is how we access them.
;; PURPOSE: To verify that `get` can navigate these paths (`object/field/sub-field`)
;; to retrieve deeply nested data. This is essential for working with any
;; structured data in Rebol.
;;=============================================================================
print "=== PROBING GET WITH OBJECT PATHS ==="

;; HYPOTHESIS: GET should resolve object paths to field values.
assert-equal "test-object" get 'test-obj/name "GET resolves simple object path"
assert-equal 100 get 'test-obj/value "GET resolves object path to numeric field"
assert-equal "nested-value" get 'test-obj/nested/deep "GET resolves nested object path"
assert-equal "very-deep" get 'test-obj/nested/deeper/deepest "GET resolves deeply nested path"

;; HYPOTHESIS: GET should also work with path values stored in variables.
assert-equal "test-object" get test-path-ref "GET works with stored path reference"
assert-equal "nested-value" get test-deep-path-ref "GET works with stored deep path reference"

print newline

;;=============================================================================
;; SECTION 6: Probing GET with Object Values (Special Behavior)
;;
;; CONTEXT: Sometimes you need all the values from an object, not just one.
;; PURPOSE: This tests a special feature of `get`. When applied directly to an
;; `object!` value, it doesn't return the object itself. Instead, it extracts
;; all the object's values into a new `block!`. This is a handy shortcut.
;;=============================================================================
print "=== PROBING GET WITH OBJECT VALUES ==="

;; HYPOTHESIS: GET applied to an object should return a block of the object's values.
obj-result: get test-obj
print ["GET object result type:" type? obj-result]
print ["GET object result content:" mold obj-result]

;; Verify the object-to-block conversion behavior
either block? obj-result [
    print "✅ PASSED: GET with object returns block type"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET with object should return block type"
]

print newline

;;=============================================================================
;; SECTION 7: Probing GET with Unset Values (Error Conditions)
;;
;; CONTEXT: A common programming error is trying to use a variable that
;; hasn't been given a value yet.
;; PURPOSE: This test confirms that standard `get` will correctly throw an
;; error if it's asked to retrieve a value from an "unset" word. This is
;; important, as it prevents scripts from continuing with missing data.
;;=============================================================================
print "=== PROBING GET WITH UNSET VALUES ==="

;; HYPOTHESIS: GET should error when accessing unset words without the /any refinement.
unset 'test-unset-word
assert-error [get 'test-unset-word] "GET errors on unset word without /any refinement"

print newline

;;=============================================================================
;; SECTION 8: Probing GET/any Refinement Behavior
;;
;; CONTEXT: We confirmed `get` errors on unset words. How do we safely check
;; if a word is unset without crashing the script?
;; PURPOSE: This section tests the `/any` refinement, which is `get`'s built-in
;; safety feature. `get/any` will *not* error on an unset word. Instead, it
;; returns a special `unset!` value, which we can test for using `unset?`.
;; This is the primary way to write safe, conditional code that depends on
;; whether a variable exists.
;;=============================================================================
print "=== PROBING GET/ANY REFINEMENT ==="

;; HYPOTHESIS: GET/any should handle unset words without errors and return an unset! value.

;; Test that GET/any doesn't throw errors with unset words
unset-access-succeeded?: false
try [
    get/any 'test-unset-word
    unset-access-succeeded?: true
]
either unset-access-succeeded? [
    print "✅ PASSED: GET/any does not error on unset word"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET/any should not error on unset word"
]

;; HYPOTHESIS: The value returned by GET/any on an unset word is of the unset! type.
either unset? get/any 'test-unset-word [
    print "✅ PASSED: GET/any returns unset! for unset words"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET/any should return unset! for unset words"
]

;; HYPOTHESIS: GET/any should work normally for words that are set.
assert-equal 42 get/any 'test-integer "GET/any works normally with set integer"
assert-equal "hello world" get/any 'test-string "GET/any works normally with set string"
assert-equal [a b c] get/any 'test-block "GET/any works normally with set block"

print newline

;;=============================================================================
;; SECTION 9: Probing GET Error Conditions and Invalid Inputs
;;
;; CONTEXT: Beyond unset words, what other invalid inputs cause `get` to error?
;; PURPOSE: To confirm that `get` fails safely and predictably when given a
;; word that has never existed, or a path that points to a non-existent field
;; in an object. This confirms the function is strict and reliable.
;;=============================================================================
print "=== PROBING GET ERROR CONDITIONS ==="

;; HYPOTHESIS: GET should error for non-existent words.
assert-error [get 'completely-non-existent-word-xyz123] "GET errors on non-existent word"

;; HYPOTHESIS: GET should error for invalid object paths.
assert-error [get 'test-obj/non-existent-field] "GET errors on non-existent object field"
assert-error [get 'test-obj/nested/non-existent-deep] "GET errors on invalid nested object path"

;; Test accessing invalid deeply nested paths
assert-error [get 'test-obj/nested/deeper/non-existent] "GET errors on invalid deep nested path"

print newline

;;=============================================================================
;; SECTION 10: Probing GET Type Preservation and Consistency
;;
;; CONTEXT: When you get a value, is it the exact same type as what you stored?
;; PURPOSE: This suite of tests confirms that `get` does not change the datatype
;; of the values it retrieves. An `integer!` stays an `integer!`, a `string!`
;; stays a `string!`, etc. This is crucial for writing predictable code.
;;=============================================================================
print "=== PROBING GET TYPE PRESERVATION ==="

;; HYPOTHESIS: GET should preserve the exact datatypes of retrieved values.
either integer? get 'test-integer [
    print "✅ PASSED: GET preserves integer! type"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET should preserve integer! type"
]

either string? get 'test-string [
    print "✅ PASSED: GET preserves string! type"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET should preserve string! type"
]

either block? get 'test-block [
    print "✅ PASSED: GET preserves block! type"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET should preserve block! type"
]

either decimal? get 'test-decimal [
    print "✅ PASSED: GET preserves decimal! type"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET should preserve decimal! type"
]

either logic? get 'test-true [
    print "✅ PASSED: GET preserves logic! type for true"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET should preserve logic! type for true"
]

either logic? get 'test-false [
    print "✅ PASSED: GET preserves logic! type for false"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET should preserve logic! type for false"
]

either none? get 'test-none [
    print "✅ PASSED: GET preserves none! type"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET should preserve none! type"
]

print newline

;;=============================================================================
;; SECTION 11: Probing GET with Complex Nested Structures
;;
;; CONTEXT: This section was part of our debugging journey. It originally
;; contained a complex test that failed due to a misunderstanding of how
;; Rebol builds data structures (`reduce` vs `compose`).
;; PURPOSE: It is left here, commented out, as a historical record of the
;; debugging process. The final, correct version of this test can be found
;; in the other heavily commented script.
;;=============================================================================
comment {
print "=== PROBING GET WITH COMPLEX STRUCTURES ==="

;; Create complex nested structure for advanced testing
complex-structure: make object! [
    level1: [
        "string-in-block"
        make object! [inner: "object-in-block"]
        42
    ]
    level2: make object! [
        data: [1 2 3]
        ref: 'test-integer
    ]
]

;; HYPOTHESIS: GET should handle complex nested object-block combinations
assert-equal "object-in-block" get 'complex-structure/level1/2/inner "GET handles object-in-block path"
assert-equal [1 2 3] get 'complex-structure/level2/data "GET handles block-in-object path"

print newline
}
;;=============================================================================
;; SECTION 12: Probing GET Performance with Identical Operations
;;
;; CONTEXT: If you `get` the same value twice, do you get the same result?
;; PURPOSE: This is a sanity check to ensure the `get` function is "stable"
;; and "deterministic". It confirms that, for the same input, `get` will
;; always produce the same output, which is a cornerstone of reliable functions.
;;=============================================================================
print "=== PROBING GET CONSISTENCY ==="

;; HYPOTHESIS: GET should return identical results for repeated operations.
first-get: get 'test-integer
second-get: get 'test-integer
assert-equal first-get second-get "GET returns consistent results for repeated calls"

;; Test consistency with complex paths
first-path-get: get 'test-obj/nested/deep
second-path-get: get 'test-obj/nested/deep
assert-equal first-path-get second-path-get "GET returns consistent results for path operations"

print newline

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
