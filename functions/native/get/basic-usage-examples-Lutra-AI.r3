REBOL []
print "=== GET FUNCTION: TEN BASIC EXAMPLES (HAPPY PATH) ==="
print "=== Using Battle-Tested QA Harness ==="
print NEWLINE

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

;;=============================================================================
;; GET FUNCTION: TEN BASIC EXAMPLES (HAPPY PATH)
;;=============================================================================
;; Purpose: Demonstrate the most common, simple and correct uses of GET.
;; Evidence: Based on validated diagnostic probe results.
;;=============================================================================

;;-----------------------------------------------------------------------------
;; EXAMPLE 1: Basic Value Retrieval from Words
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 1: Basic Value Retrieval ---"
print "Purpose: GET retrieves the value stored in any word"
print "Why: This is the fundamental operation - accessing stored data"

my-number: 42
my-text: "Hello REBOL"
my-data: [a b c]

assert-equal 42 get 'my-number "GET retrieves integer value from word"
assert-equal "Hello REBOL" get 'my-text "GET retrieves string value from word"
assert-equal [a b c] get 'my-data "GET retrieves block value from word"
print NEWLINE

;;-----------------------------------------------------------------------------
;; EXAMPLE 2: Indirect Access Using Word References
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 2: Indirect Access via Word References ---"
print "Purpose: GET works with word! values (quoted words) for indirection"
print "Why: Enables dynamic variable access and meta-programming"

target-word: 'my-number  ;; Store a reference to another word
assert-equal 42 get target-word "GET works with word! reference for indirection"
assert-equal my-number get target-word "Indirect access equals direct access"
print NEWLINE

;;-----------------------------------------------------------------------------
;; EXAMPLE 3: Object Field Access with Paths
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 3: Object Field Access ---"
print "Purpose: GET resolves object paths to access specific fields"
print "Why: Essential for working with structured data and objects"

person: make object! [
    name: "Alice"
    age: 30
    city: "New York"
]

assert-equal "Alice" get 'person/name "GET resolves object path to name field"
assert-equal 30 get 'person/age "GET resolves object path to age field"
assert-equal "New York" get 'person/city "GET resolves object path to city field"
print NEWLINE

;;-----------------------------------------------------------------------------
;; EXAMPLE 4: Nested Object Access
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 4: Nested Object Navigation ---"
print "Purpose: GET handles deeply nested object structures"
print "Why: Real applications often have complex nested data"

company: make object! [
    name: "TechCorp"
    location: make object! [
        address: make object! [
            street: "123 Main St"
            city: "Boston"
            zip: "02101"
        ]
    ]
]

assert-equal "123 Main St" get 'company/location/address/street "GET handles deep nested object paths"
assert-equal "Boston" get 'company/location/address/city "GET navigates complex nested structures"
assert-equal "02101" get 'company/location/address/zip "GET resolves deeply nested field access"
print NEWLINE

;;-----------------------------------------------------------------------------
;; EXAMPLE 5: Working with Different Data Types
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 5: Multi-Type Data Retrieval ---"
print "Purpose: GET preserves exact data types of all REBOL values"
print "Why: Type safety and predictable behavior across all data"

integer-val: 100
decimal-val: 3.14159
string-val: "REBOL rocks!"
block-val: [red green blue]
logic-true: true
logic-false: false
none-val: none

assert-equal 100 get 'integer-val "GET preserves integer values"
assert-equal 3.14159 get 'decimal-val "GET preserves decimal values"
assert-equal "REBOL rocks!" get 'string-val "GET preserves string values"
assert-equal [red green blue] get 'block-val "GET preserves block values"
assert-equal true get 'logic-true "GET preserves true logic values"
assert-equal false get 'logic-false "GET preserves false logic values"
assert-equal none get 'none-val "GET preserves none values"
print NEWLINE

;;-----------------------------------------------------------------------------
;; EXAMPLE 6: GET Applied to Objects (Special Behavior)
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 6: GET with Objects Returns Value Collections ---"
print "Purpose: GET applied to an object returns a block of all object values"
print "Why: Useful for extracting all data from an object at once"

config: make object! [
    debug: true
    port: 8080
    host: "localhost"
]

config-values: get config
expected-values: [#(true) 8080 "localhost"]
assert-equal expected-values config-values "GET with object returns block of all values"

;; Verify it's a block type
either block? config-values [
    print "✅ PASSED: GET with object returns block! type"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET with object should return block! type"
]
print NEWLINE

;;-----------------------------------------------------------------------------
;; EXAMPLE 7: Safe Access with GET/any for Unset Variables
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 7: Safe Variable Access with GET/any ---"
print "Purpose: GET/any allows checking unset variables without errors"
print "Why: Essential for conditional logic and variable validation"

;; Create an unset variable for demonstration
unset 'maybe-unset-var

;; Test that GET/any doesn't error with unset variables
unset-access-worked?: false
try [
    get/any 'maybe-unset-var
    unset-access-worked?: true
]
either unset-access-worked? [
    print "✅ PASSED: GET/any does not error on unset variables"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET/any should not error on unset variables"
]

;; Test that the result is actually unset
either unset? get/any 'maybe-unset-var [
    print "✅ PASSED: GET/any returns unset! for unset variables"
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET/any should return unset! for unset variables"
]

;; Show it works normally with set variables
normal-var: "I exist!"
assert-equal "I exist!" get/any 'normal-var "GET/any works normally with set variables"
print NEWLINE

;;-----------------------------------------------------------------------------
;; EXAMPLE 8: Path References for Flexible Access
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 8: Stored Path References ---"
print "Purpose: GET works with path! values stored in variables"
print "Why: Enables flexible, configurable data access patterns"

database: make object! [
    users: make object! [
        admin: make object! [
            name: "Administrator"
            level: 5
        ]
        guest: make object! [
            name: "Guest User"
            level: 1
        ]
    ]
]

;; Store path references for flexible access
admin-name-path: 'database/users/admin/name
admin-level-path: 'database/users/admin/level
guest-name-path: 'database/users/guest/name

assert-equal "Administrator" get admin-name-path "GET works with stored path references"
assert-equal 5 get admin-level-path "GET enables configurable data access via stored paths"
assert-equal "Guest User" get guest-name-path "GET supports flexible path-based data retrieval"
print NEWLINE

;;-----------------------------------------------------------------------------
;; EXAMPLE 9: Handling Edge Cases and Empty Values
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 19: Edge Cases and Empty Values ---"
print "Purpose: GET reliably handles edge cases and boundary values"
print "Why: Robust code must handle empty data and edge conditions"

;; Edge case values
zero-value: 0
negative-value: -42
empty-string: ""
empty-block: []
large-number: 999999999

assert-equal 0 get 'zero-value "GET handles zero values correctly"
assert-equal -42 get 'negative-value "GET handles negative values correctly"
assert-equal "" get 'empty-string "GET handles empty strings correctly"
assert-equal [] get 'empty-block "GET handles empty blocks correctly"
assert-equal 999999999 get 'large-number "GET handles large numeric values correctly"
print NEWLINE

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
