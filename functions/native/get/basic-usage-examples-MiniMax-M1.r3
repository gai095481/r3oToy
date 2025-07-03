REBOL []
print "=== [GET]: BASIC / HAPPY PATH EXAMPLES ==="
print "=== Demonstrating common, simple and correct uses ===^/"

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
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
        print "✅ ALL `get` EXAMPLES PASSED"
    ][
        print "❌ SOME `get` EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;----------------------------------------------------------------------------
;; EXAMPLE 1: Basic variable access
;;----------------------------------------------------------------------------
print "--- EXAMPLE 1: Simple Variable Access ---"
user-name: "Alice"
assert-equal "Alice" get 'user-name "Basic variable access"
comment {
    GET retrieves the value of a word.
    The word 'user-name contains the string "Alice".
    This is the most fundamental use of GET.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 2: Object property access
;;----------------------------------------------------------------------------
print "--- EXAMPLE 2: Object Property Access ---"
config: make object! [timeout: 30]
assert-equal 30 get 'config/timeout "Object property access"
comment {
    GET can resolve paths to access object properties.
    The path 'config/timeout navigates to the timeout field in the config object.
    This is useful for accessing structured data.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 3: Safe undefined check
;;----------------------------------------------------------------------------
print "--- EXAMPLE 3: Safe Undefined Check ---"
assert-equal true unset? get/any 'optional-feature "Safe undefined check"
comment {
    The /any refinement allows GET to safely access potentially undefined words
    without throwing an error. This is useful for feature detection or
    optional settings where you want to check if a value exists.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 4: Accessing nested object values
;;----------------------------------------------------------------------------
print "--- EXAMPLE 4: Nested Object Access ---"
user: make object! [
    profile: make object! [
        preferences: make object! [
            theme: "dark"
        ]
    ]
]
assert-equal "dark" get 'user/profile/preferences/theme "Nested object access"
comment {
    GET can navigate through multiple levels of object nesting.
    This is essential for working with complex data structures.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 5: Getting function references
;;----------------------------------------------------------------------------
print "--- EXAMPLE 5: Get Function Reference ---"
action: func [] [print "executed"]
assert-equal :action get 'action "Function reference retrieval"
comment {
    GET can retrieve function references, which is useful for
    dynamic function invocation or creating function pointers.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 6: Getting values of different data types
;;----------------------------------------------------------------------------
print "--- EXAMPLE 6: Various Data Types ---"
test-integer: 42
test-string: "hello"
test-block: [1 2 3]
test-none: none

assert-equal 42 get 'test-integer "Integer value retrieval"
assert-equal "hello" get 'test-string "String value retrieval"
assert-equal [1 2 3] get 'test-block "Block value retrieval"
assert-equal none get 'test-none "None value retrieval"
comment {
    GET works with all basic data types in REBOL.
    The type of the retrieved value matches the type stored in the word.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 7: Getting values from words that contain words
;;----------------------------------------------------------------------------
print "--- EXAMPLE 7: Word That Contains Another Word ---"
target: 'test-integer
assert-equal 42 get target "Word containing another word"
comment {
    GET can take a word that itself contains another word as its argument.
    This allows for indirect referencing and dynamic value access.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 8: Getting values from words that contain paths
;;----------------------------------------------------------------------------
print "--- EXAMPLE 8: Word That Contains a Path ---"
target-path: 'config/timeout
assert-equal 30 get target-path "Word containing a path"
comment {
    Words can store path references, and GET can resolve these paths.
    This enables building dynamic paths for data access.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 9: Multiple calls return consistent results
;;----------------------------------------------------------------------------
print "--- EXAMPLE 9: Consistent Results ---"
first-get: get 'test-integer
second-get: get 'test-integer
assert-equal first-get second-get "Consistent results on repeated calls"
comment {
    GET is consistent and returns the same value on repeated calls
    as long as the source word hasn't changed.
}

;;----------------------------------------------------------------------------
;; EXAMPLE 10: Getting values from words with literal values
;;----------------------------------------------------------------------------
print "--- EXAMPLE 10: Word With Literal Value ---"
assert-equal 42 get 42 "Literal integer value"
assert-equal "text" get "text" "Literal string value"
comment {
    GET can take literal values directly as arguments.
    This demonstrates the flexibility of GET with different argument types.
}

print-test-summary
