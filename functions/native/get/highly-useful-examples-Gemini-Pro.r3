REBOL [
    Title: "GET Function - Ten Highly Useful and Commented Examples"
    Version: 1.2.0
    Author: "Rebol 3 Oldes Branch Expert"
    Date: 26-Jun-2025
    Purpose: {
        A fully corrected script demonstrating practical applications of GET,
        using the correct, idiomatic tools like SELECT for safe key lookups.
    }
]

;;-----------------------------------------------------------------------------
;; Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    "Compares an expected value to what our code actually produces."
    expected [any-type!] "The expected value"
    actual [any-type!] "The actual value"
    description [string!] "Test description"
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
    "Prints a final summary of our test run."
    print newline
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL USEFUL EXAMPLES PASSED"
    ][
        print "❌ SOME USEFUL EXAMPLES FAILED"
    ]
    print "============================================"
]

;;-----------------------------------------------------------------------------
;; Ten Highly Useful Examples
;;-----------------------------------------------------------------------------
print newline
print "=== TEN PRACTICAL, REAL-WORLD EXAMPLES OF GET ==="
print "---"

;; Example 1: Dynamic Configuration Access (Refactored)
;
; CONTEXT: Loading a setting where the setting's name is stored in a variable.
; WHY IT'S USEFUL: `select` is the ideal tool for this. `select config setting`
; safely looks for the key held in `setting` inside the `config` object.
; It's more direct and idiomatic than building a path for simple key lookups.
;
config: make object! [timeout: 30 theme: "dark"]
setting: 'timeout
retrieved-value: select config setting
assert-equal 30 retrieved-value "Example 1: Dynamic configuration access"

;; Example 2: Safe Unset Variable Checking
;
; CONTEXT: Safely handling a variable that may not exist.
; WHY `GET` IS USEFUL: Here, `get` is the right tool because we are checking a
; top-level word, not a key in a map. `get/any` safely returns `unset!`,
; which `any` then replaces with our `none` fallback.
;
unset 'user-preference
preference: any [get/any 'user-preference none]
assert-equal none preference "Example 2: Safely checking an unset variable and assigning none"

;; Example 3: Value Lookup in a Data Block
;
; CONTEXT: Finding a value that follows a key in a simple block.
; WHY IT'S USEFUL: This shows chaining series functions. `find` locates the key,
; `next` advances the position, and `pick` extracts the single value at that
; new position. `get` is not used here as `pick` is the correct tool.
;
error-codes: [404 "Not Found" 500 "Internal Server Error"]
code-to-find: 404
position: find error-codes code-to-find
error-message: pick (next position) 1
assert-equal "Not Found" error-message "Example 3: Look up value in a key-value block"

;; Example 4: System Information
;
; CONTEXT: Getting data from the built-in system object.
; WHY `GET` IS USEFUL: `get` with a hard-coded path is the most direct way to
; access deeply nested, known data.
;
os-name: get 'system/build/os
assert-equal 'ubuntu os-name "Example 4: Retrieving OS from system object"

;; Example 5: Dynamic Object Field Access.
;
; CONTEXT: Getting data from an object using a variable that holds the field name.
; WHY IT'S USEFUL: `select` is again the perfect tool. `select person 'name` is
; a safe and direct way to look up the field.
;
person: make object! [name: "Alice" age: 30]
retrieved-name: select person 'name
retrieved-age: select person 'age
assert-equal "Alice" retrieved-name "Example 5a: Dynamic access to 'name' field"
assert-equal 30 retrieved-age "Example 5b: Dynamic access to 'age' field"

;; Example 6: Context-based Value Retrieval (Namespace)
;
; CONTEXT: Keeping variables with the same name in different contexts separate.
; WHY `GET` IS USEFUL: `get` is essential here because it respects a word's
; "binding". After we `bind` the word to a context, `get` knows to look
; only inside that context for the value.
;
ctx: make object! [api-key: "123-ABC"]
bound-word: bind 'api-key ctx
secret-key: get bound-word
assert-equal "123-ABC" secret-key "Example 6: Retrieving a value from a specific context"

;; Example 7: Default Value Pattern
;
; CONTEXT: Providing a fallback value if a variable is not set.
; WHY `GET` IS USEFUL: This classic pattern relies on `get/any` safely returning
; `unset!`, which the `any` function then replaces with the default value.
;
unset 'missing-var
value: any [get/any 'missing-var "default"]
assert-equal "default" value "Example 7: Providing a default for a missing variable"

;; Example 8: Mathematical Constant Usage
;
; CONTEXT: Using precise constants in calculations.
; WHY `GET` IS USEFUL: `get 'pi` is the standard way to retrieve Rebol's
; built-in high-precision value for Pi.
;
radius: 5
pi-value: get 'pi
area: pi-value * radius * radius
assert-equal 78.53981633974483 area "Example 8: Using PI for area calculation"

;; Example 9: Dynamic Template Rendering (Refactored)
;
; CONTEXT: Filling a text template with data from an object.
; WHY IT'S USEFUL: `select` provides a safe and clean way to fetch the replacement
; values from the `data` object before passing them to `replace/all`.
;
template: "Dear {{name}}, Your balance is: {{balance}}."
data: make object! [name: "John" balance: "$100"]
rendered: copy template
replace/all rendered "{{name}}" (select data 'name)
replace/all rendered "{{balance}}" (select data 'balance)
expected-render: "Dear John, Your balance is: $100."
assert-equal expected-render rendered "Example 9: Rendering a simple template"

;; Example 10: Configuration Validation (CORRECTED)
;
; CONTEXT: Verifying that all required settings exist in a config object.
; WHY IT'S USEFUL: This makes application startup robust.
; THE FIX: `select` is the correct tool. It safely looks for each required key.
; If the key is not found, `select` returns `none`, which we can easily detect.
; This avoids the path traversal errors that `get/any` was causing.
;
required: [timeout theme non-existent-setting]
config: make object! [timeout: 30 theme: "dark"]
missing-settings: copy []
foreach setting required [
    value: select config setting
    if none? value [
        append missing-settings setting
    ]
]
assert-equal [non-existent-setting] missing-settings "Example 10: Validating configuration finds missing setting"

;; Final Summary
print-test-summary
