Rebol []

; --- Renamed function for clarity ---
word-is-native?: funct [
    {Determine if a given word refers to a built-in native function.

    RETURNS: true if the word is bound to a native function, false otherwise
    ERRORS: none - function handles all edge cases gracefully}

    a_word [any-type!] "The word to check for native function binding"
] [
    ; --- Input Validation ---
    if unset? :a_word [return false]
    if not word? :a_word [return false]

    ; --- Core Logic using 'try/with ---
    try/with [
        native? get/any :a_word
    ] function [error-object] [
        ; Handle any error (e.g., word is unset) by returning false
        false
    ]
]

;; QA Test Harness (Your original harness)
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: funct [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
    /local result-style message
] [
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
        print "✅ ALL word-is-native? TESTS PASSED"
    ][
        print "❌ SOME word-is-native? TESTS FAILED"
    ]
    print "============================================^/"
]

;; Test Cases (Updated function name)
;;-----------------------------------------------------------------------------
print "^/Testing word-is-native? function:^/"

;; Test 1: Known native function using word syntax
assert-equal true (word-is-native? 'print) "Native function 'print' should return true"

;; Test 2: Known native function (switch)
assert-equal true (word-is-native? 'switch) "Native function 'switch' should return true"

;; Test 3: Another native function (assuming 'if' is native)
assert-equal true (word-is-native? 'if) "Native function 'if' should return true"

;; Test 4: Another native function (assuming 'get' is native)
assert-equal true (word-is-native? 'get) "Native function 'get' should return true"

;; Test 5: User-defined function (this test function itself)
assert-equal false (word-is-native? 'word-is-native?) "User function 'word-is-native?' should return false"

;; Test 6: Action function (make is likely an action in Bulk)
assert-equal false (word-is-native? 'make) "Action function 'make' should return false (not native)"

;; Test 7: Action function (add is likely an action in Bulk)
assert-equal false (word-is-native? 'add) "Action function 'add' should return false (not native)"

;; Test 8: Unset word - test with actual unset word
assert-equal false (word-is-native? 'else) "Unset word 'else' should return false"

;; Test 9: Variable containing a value (not a function)
test-var: "hello"
assert-equal false (word-is-native? 'test-var) "Variable with string value should return false"

;; Test 10: Test error handling for non-word input
assert-equal false (word-is-native? 123) "Non-word input should return false"

;; Test 11: Test error handling for string input
assert-equal false (word-is-native? "print") "String input should return false"

;; Test 12: Test with none value
test-none: none
assert-equal false (word-is-native? 'test-none) "Word bound to none should return false"

print-test-summary
