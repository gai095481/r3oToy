Rebol [
    Title: "Robust Diagnostic Probe for `closure`, `closure? Functions"
    Purpose: "Systematically test `closure`, `closure?` functions and their refinements"
    Author: "MyNinja AI"
    Date: 11-Apr-2025
    Version: 0.1.0
    Target: "REBOL/Bulk 3.19.0 (Oldes Branch)"
]

;;-----------------------------
;; A Battle-Tested QA Harness
;;------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    either equal? expected actual [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {Output the final summary of the entire test run.}
    print "^/============================================"
    print "=== TEST SUMMARY ==="
    print "============================================"
    print rejoin ["Total Tests: " test-count]
    print rejoin ["Passed: " pass-count]
    print rejoin ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - FUNCTION IS STABLE"
    ][
        print "❌  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/============================================"
print "=== COMPREHENSIVE CLOSURE DIAGNOSTIC PROBE ==="
print "============================================^/"

;;-----------------------------
;; Probing CLOSURE? Type Checker
;;-----------------------------
print "^/--- Probing CLOSURE? Type Checker ---"
;; Hypothesis: closure? should return true only for closure! values and false for all other types

;; Test with various non-closure types
assert-equal false closure? 42 "closure? with integer should return false"
assert-equal false closure? "hello" "closure? with string should return false"
assert-equal false closure? [1 2 3] "closure? with block should return false"
assert-equal false closure? none "closure? with none should return false"
assert-equal false closure? true "closure? with logic should return false"

;; Test with function types
simple-func: func [x] [x + 1]
assert-equal false closure? :simple-func "closure? with function! should return false"

;; Test with actual closure
simple-closure: closure [x] [x + 1]
assert-equal true closure? :simple-closure "closure? with closure! should return true"

;;-----------------------------
;; Probing Basic CLOSURE Creation
;;-----------------------------
print "^/--- Probing Basic CLOSURE Creation ---"
;; Hypothesis: closure should create closure! values that behave like functions

;; Test basic closure creation
basic-closure: closure [] [print "Hello from closure"]
assert-equal closure! type? :basic-closure "Basic closure should be of type closure!"

;; Test closure with parameters
param-closure: closure [value] [value * 2]
assert-equal closure! type? :param-closure "Parameterized closure should be of type closure!"

;; Test closure execution
result-value: param-closure 5
assert-equal 10 result-value "Closure with parameter should execute correctly"

;;-----------------------------
;; Probing CLOSURE Basic Variable Behavior
;;-----------------------------
print "^/--- Probing CLOSURE Basic Variable Behavior ---"
;; Hypothesis: Basic closures without /with do NOT maintain persistent state automatically

;; Create a simple counter closure to test behavior
counter-closure: closure [] [
    set/any 'counter-result try [counter-var + 1]
    counter-var: either error? counter-result [1] [counter-result]
    counter-var
]

first-call: counter-closure
second-call: counter-closure
third-call: counter-closure

;; Based on test results, closures without /with don't maintain state
assert-equal 1 first-call "First counter call should return 1"
assert-equal 1 second-call "Second counter call should return 1 (no automatic persistence)"
assert-equal 1 third-call "Third counter call should return 1 (no automatic persistence)"

;;-----------------------------
;; Probing CLOSURE Set-Word Locals
;;-----------------------------
print "^/--- Probing CLOSURE Set-Word Locals ---"
;; Hypothesis: Set-words in closures are local but don't persist between calls without /with

;; Create closure with multiple set-words
setword-closure: closure [input-val] [
    local-var1: input-val * 2
    local-var2: local-var1 + 10
    local-var3: local-var2 / 2
    local-var3
]

;; Test that set-words don't leak to global scope
global-before: length? words-of system/contexts/user
result-setword: setword-closure 5
global-after: length? words-of system/contexts/user

;; Based on test results, the calculation is simpler than expected
assert-equal 10 result-setword "Set-word closure calculation: (5 * 2 + 10) / 2 = 10"
assert-equal global-before global-after "Set-words should not leak to global context"

;;-----------------------------
;; Probing CLOSURE /WITH Refinement for Persistence
;;-----------------------------
print "^/--- Probing CLOSURE /WITH Refinement for Persistence ---"
;; Hypothesis: /with refinement enables true persistent state in closures

;; Test /with using object spec block
with-spec-closure: closure/with [input-val] [
    set/any 'counter-result try [persistent-counter + 1]
    persistent-counter: either error? counter-result [1] [counter-result]
    set/any 'sum-result try [persistent-sum + input-val]
    persistent-sum: either error? sum-result [input-val] [sum-result]
    reduce [persistent-counter persistent-sum]
] [persistent-counter: 0 persistent-sum: 0]

first-with-call: with-spec-closure 10
second-with-call: with-spec-closure 20
third-with-call: with-spec-closure 30

assert-equal [1 10] first-with-call "First /with call should initialize correctly"
assert-equal [2 30] second-with-call "Second /with call should maintain state"
assert-equal [3 60] third-with-call "Third /with call should continue maintaining state"

;; Test /with using existing object
persistent-obj: make object! [shared-value: 100]
with-object-closure: closure/with [multiplier] [
    shared-value: shared-value * multiplier
    shared-value
] persistent-obj

obj-result1: with-object-closure 2
obj-result2: with-object-closure 3

assert-equal 200 obj-result1 "First /with object call should modify shared state"
assert-equal 600 obj-result2 "Second /with object call should continue from modified state"
assert-equal 600 persistent-obj/shared-value "Original object should be modified"

;;-----------------------------
;; Probing CLOSURE /EXTERN Refinement
;;-----------------------------
print "^/--- Probing CLOSURE /EXTERN Refinement ---"
;; Hypothesis: /extern refinement should prevent specified words from being local

;; Set up global variables for extern testing
global-extern-var: 1000
another-global-var: 2000

;; Create closure with /extern
extern-closure: closure/extern [modifier] [
    global-extern-var: global-extern-var + modifier
    local-calc: modifier * 2  ;; This should be local
    global-extern-var
] [global-extern-var]

extern-result1: extern-closure 50
extern-result2: extern-closure 100

assert-equal 1050 extern-result1 "First /extern call should modify global variable"
assert-equal 1150 extern-result2 "Second /extern call should continue modifying global"
assert-equal 1150 global-extern-var "Global variable should be modified by /extern closure"

;;-----------------------------
;; Probing CLOSURE Combined Refinements
;;-----------------------------
print "^/--- Probing CLOSURE Combined Refinements ---"
;; Hypothesis: /with and /extern can be used together

combined-global: 500
combined-closure: closure/with/extern [input-val] [
    set/any 'state-result try [persistent-state + 1]
    persistent-state: either error? state-result [1] [state-result]
    combined-global: combined-global + input-val
    calculation-temp: input-val * persistent-state  ;; Should be local
    reduce [persistent-state combined-global calculation-temp]
] [persistent-state: 0] [combined-global]

combined-result1: combined-closure 25
combined-result2: combined-closure 75

assert-equal [1 525 25] combined-result1 "First combined refinement call"
assert-equal [2 600 150] combined-result2 "Second combined refinement call"
assert-equal 600 combined-global "Combined global should be modified"

;;-----------------------------
;; Probing CLOSURE Spec Variations
;;-----------------------------
print "^/--- Probing CLOSURE Spec Variations ---"
;; Hypothesis: Closures should handle various spec formats like functions

;; Test with docstring
doc-closure: closure ["This closure has documentation" value] [value + 1]
assert-equal closure! type? :doc-closure "Closure with docstring should create successfully"

;; Test with typed parameters
typed-closure: closure [value [integer!] "An integer parameter"] [value * 3]
assert-equal closure! type? :typed-closure "Closure with typed parameters should create successfully"
assert-equal 15 typed-closure 5 "Typed closure should execute correctly"

;; Test with refinements in spec
refined-closure: closure [base-val /double "Double the result"] [
    result-val: base-val + 10
    either double [result-val * 2] [result-val]
]
assert-equal closure! type? :refined-closure "Closure with refinements should create successfully"
assert-equal 15 refined-closure 5 "Closure refinement without flag"
assert-equal 30 refined-closure/double 5 "Closure refinement with flag"

;;-----------------------------
;; Probing CLOSURE Error Cases
;;-----------------------------
print "^/--- Probing CLOSURE Error Cases ---"
;; Hypothesis: Invalid arguments should produce appropriate errors

;; Test invalid spec types - these should cause errors, so we'll test they fail
error-caught1: false
set/any 'error-result1 try [
    invalid-spec-closure: closure "not a block" [print "test"]
    error-caught1: true
]
assert-equal false error-caught1 "Invalid spec should cause error"

error-caught2: false
set/any 'error-result2 try [
    invalid-body-closure: closure [] "not a block"
    error-caught2: true
]
assert-equal false error-caught2 "Invalid body should cause error"

;;-----------------------------
;; Probing CLOSURE Deep Copy Behavior
;;-----------------------------
print "^/--- Probing CLOSURE Deep Copy Behavior ---"
;; Hypothesis: Closures reset their internal state on each call without /with

nested-closure: closure [modify-flag] [
    test-block: [outer [middle [inner-val: 42]]]
    either modify-flag [
        test-block/2/2/2: 84
        test-block/2/2/2
    ] [
        test-block/2/2/2
    ]
]

original-nested: nested-closure false
modified-nested: nested-closure true
check-original: nested-closure false

assert-equal 42 original-nested "Original nested access should work"
assert-equal 84 modified-nested "Modified nested access should work"
;; Without /with, the block resets each call
assert-equal 42 check-original "Nested modification should NOT persist without /with"

;;-----------------------------
;; Probing CLOSURE vs FUNCTION Differences
;;-----------------------------
print "^/--- Probing CLOSURE vs FUNCTION Differences ---"
;; Hypothesis: Functions also maintain some persistence in Rebol 3 Oldes

;; Function version
func-counter: func [] [
    set/any 'func-result try [func-var + 1]
    func-var: either error? func-result [1] [func-result]
    func-var
]

;; Closure version without /with
closure-counter: closure [] [
    set/any 'closure-result try [closure-var + 1]
    closure-var: either error? closure-result [1] [closure-result]
    closure-var
]

;; Test function behavior
func-call1: func-counter
func-call2: func-counter

;; Test closure behavior
closure-call1: closure-counter
closure-call2: closure-counter
closure-call3: closure-counter

;; Based on test results, functions also maintain some persistence
assert-equal 1 func-call1 "Function first call should return 1"
assert-equal 2 func-call2 "Function second call should return 2 (functions also persist in R3 Oldes)"

assert-equal 1 closure-call1 "Closure first call should return 1"
assert-equal 1 closure-call2 "Closure second call should return 1 (no /with persistence)"
assert-equal 1 closure-call3 "Closure third call should return 1 (no /with persistence)"

;;-----------------------------
;; Probing CLOSURE Memory and Identity
;;-----------------------------
print "^/--- Probing CLOSURE Memory and Identity ---"
;; Hypothesis: Each closure instance should be unique but without /with, no state persistence

;; Create two identical closures
counter-closure-a: closure [] [
    set/any 'counter-a-result try [counter-a + 1]
    counter-a: either error? counter-a-result [1] [counter-a-result]
    counter-a
]

counter-closure-b: closure [] [
    set/any 'counter-b-result try [counter-b + 1]
    counter-b: either error? counter-b-result [1] [counter-b-result]
    counter-b
]

;; Test they maintain separate contexts but no persistence
result-a1: counter-closure-a
result-b1: counter-closure-b
result-a2: counter-closure-a
result-b2: counter-closure-b

assert-equal 1 result-a1 "Closure A first call"
assert-equal 1 result-b1 "Closure B first call"
assert-equal 1 result-a2 "Closure A second call (no persistence without /with)"
assert-equal 1 result-b2 "Closure B second call (no persistence without /with)"

;; Test closure identity
assert-equal false same? :counter-closure-a :counter-closure-b "Different closures should not be same?"
assert-equal false equal? :counter-closure-a :counter-closure-b "Different closures should not be equal?"

;;-----------------------------
;; Probing CLOSURE Variable Scoping Edge Cases
;;-----------------------------
print "^/--- Probing CLOSURE Variable Scoping Edge Cases ---"
;; Hypothesis: Closures isolate variables but don't persist without /with

;; Test variable isolation between closures
isolation-test-a: closure [input-val] [
    set/any 'shared-result-a try [shared-name + input-val]
    shared-name: either error? shared-result-a [input-val] [shared-result-a]
    shared-name
]

isolation-test-b: closure [input-val] [
    set/any 'shared-result-b try [shared-name * input-val]
    shared-name: either error? shared-result-b [input-val] [shared-result-b]
    shared-name
]

iso-a1: isolation-test-a 10
iso-b1: isolation-test-b 5
iso-a2: isolation-test-a 20
iso-b2: isolation-test-b 3

assert-equal 10 iso-a1 "Isolation A first call"
assert-equal 5 iso-b1 "Isolation B first call"
assert-equal 20 iso-a2 "Isolation A second call (20, no persistence)"
assert-equal 3 iso-b2 "Isolation B second call (3, no persistence)"

;;-----------------------------
;; Probing CLOSURE Return Value Handling
;;-----------------------------
print "^/--- Probing CLOSURE Return Value Handling ---"
;; Hypothesis: Closures should handle various return value types correctly

;; Test closure returning different types - using /with for counter persistence
multi-return-closure: closure/with [return-type] [
    counter-val: either unset? get/any 'counter-val [1] [counter-val + 1]
    case [
        return-type = 'integer [counter-val]
        return-type = 'string [to string! counter-val]
        return-type = 'block [reduce [counter-val]]
        return-type = 'none [none]
        true [counter-val]
    ]
] [counter-val: 0]

int-result: multi-return-closure 'integer
str-result: multi-return-closure 'string
block-result: multi-return-closure 'block
none-result: multi-return-closure 'none

assert-equal 1 int-result "Closure should return integer correctly"
assert-equal "2" str-result "Closure should return string correctly"
assert-equal [3] block-result "Closure should return block correctly"
assert-equal none none-result "Closure should return none correctly"

;;-----------------------------
;; Probing CLOSURE True Persistence with /WITH
;;-----------------------------
print "^/--- Probing CLOSURE True Persistence with /WITH ---"
;; Hypothesis: Only /with provides true persistent state in closures

;; Create persistent counter with /with
persistent-counter: closure/with [] [
    counter-val: counter-val + 1
    counter-val
] [counter-val: 0]

persist-call1: persistent-counter
persist-call2: persistent-counter
persist-call3: persistent-counter

assert-equal 1 persist-call1 "Persistent counter first call"
assert-equal 2 persist-call2 "Persistent counter second call"
assert-equal 3 persist-call3 "Persistent counter third call"

print-test-summary
