REBOL [
    Title: "GET Function - Ten Highly Useful Examples"
    Version: 1.0.5
    Author: "Rebol 3 Oldes Branch Expert"
    Date: 26-Jun-2025
    Purpose: {Ten practical real-world applications of the GET function}
]

;;-----------------------------------------------------------------------------
;; Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
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
    print newline
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TAKE TESTS PASSED"
    ][
        print "❌ SOME TAKE TESTS FAILED"
    ]
    print "============================================"
]

;; Example 1: Dynamic configuration access
; Why useful: Load settings based on runtime variables
config: make object! [timeout: 30 theme: "dark"]
setting: 'timeout
print ["Config value:" get in config setting]  ; Returns 30

;; Example 2: Safe unset checking
; Why useful: Prevent errors with optional values
unset 'user-preference
if unset? get/any 'user-preference [
    print "Using default preference"
]

;; Example 3: Function metadata inspection
; Why useful: Build help systems or debug tools
print ["Append description:" get 'append/description]

;; Example 4: System information
; Why useful: Create platform-aware applications
print ["OS:" system/build/os]  ; Direct access

;; Example 5: Safe object field access
; Why useful: Process objects without knowing their structure
person: make object! [name: "Alice" age: 30]
print ["Name:" get in person 'name]
print ["Age:" get in person 'age]

;; Example 6: Context-based value retrieval
; Why useful: Implement namespacing in complex systems
ctx: make object! [api-key: "123-ABC"]
bound-word: bind 'api-key ctx
print ["Secret:" get bound-word]

;; Example 7: Default value pattern
; Why useful: Graceful fallback for missing values
value: any [get/any 'missing-var "default"]
print ["Value:" value]

;; Example 8: Mathematical constant (CORRECTED)
; Why useful: Precision calculations in scientific apps
radius: 5
pi-value: get 'pi  ; Get value first
print ["Circle area:" pi-value * radius * radius]

;; Example 9: Dynamic template rendering
; Why useful: Generate documents from templates
template: {
    Dear {{name}},
    Your balance is: {{balance}}.
}
data: make object! [name: "John" balance: "$100"]
rendered: copy template
replace/all rendered "{{name}}" get in data 'name
replace/all rendered "{{balance}}" get in data 'balance
print rendered

;; Example 10: Configuration validation
; Why useful: Ensure required settings exist
required: [timeout theme]
foreach setting required [
    value: get/any in config setting
    if unset? value [
        print ["Missing:" setting]
    ]
]
