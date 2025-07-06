Rebol [
    Title: "JOIN Function Diagnostic Probe Script (Final)"
    Purpose: "Systematically test the behavior of the JOIN function"
    Author: "Diagnostic Probe Generator"
    Date: 6-Jul-2025
]

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
            description
            "^/ >> Expected: " mold expected
            "^/ >> Actual: " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL TEST CASE EXAMPLES PASSED."
    ][
        print "❌ SOME TEST CASE EXAMPLES FAILED."
    ]
    print "============================================^/"
]

print "^/=== JOIN Function Diagnostic Probe Script ==="
print "Testing JOIN function behavior systematically..."
print "^/Source: join: make function! [[value rest][append either series? :value [copy value] [form :value] reduce :rest]]"

;;-----------------------------------------------------------------------------
;; Probing Basic String Concatenation
;;-----------------------------------------------------------------------------
print "^/--- Probing Basic String Concatenation ---"
;; Hypothesis: JOIN with string value and string rest should concatenate them
assert-equal "hello world" join "hello " "world" "String + String concatenation"
assert-equal "abc123" join "abc" "123" "String + Number string concatenation"

;;-----------------------------------------------------------------------------
;; Probing Non-Series Value Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing Non-Series Value Behavior ---"
;; Hypothesis: JOIN with non-series value should convert value to string via form, then append rest
assert-equal "42test" join 42 "test" "Integer + String should form integer first"
assert-equal "truefalse" join true false "Logic + Logic should form both values"
assert-equal "3.14159" join 3.14 "159" "Decimal + String should form decimal first"

;;-----------------------------------------------------------------------------
;; Probing Series Value Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing Series Value Behavior ---"
;; Hypothesis: JOIN with series value should copy the series, then append reduced rest
test-block: [1 2 3]
result-block: join test-block [4 5]
assert-equal [1 2 3 4 5] result-block "Block + Block should copy first block and append second"

;; Hypothesis: Original series should not be modified (copy behavior)
assert-equal [1 2 3] test-block "Original block should remain unchanged after join"

;;-----------------------------------------------------------------------------
;; Probing Block Rest Reduction
;;-----------------------------------------------------------------------------
print "^/--- Probing Block Rest Reduction ---"
;; Hypothesis: Block rest should be reduced before appending
test-var: 100
assert-equal "start100end" join "start" [test-var "end"] "Block rest should be reduced before joining"

;; Hypothesis: Empty block rest should result in no addition
assert-equal "test" join "test" [] "Empty block rest should add nothing"

;;-----------------------------------------------------------------------------
;; Probing Mixed Type Combinations
;;-----------------------------------------------------------------------------
print "^/--- Probing Mixed Type Combinations ---"
;; Hypothesis: Various type combinations should work via form conversion
assert-equal "123abc" join 123 "abc" "Number + String"
assert-equal "test456" join "test" 456 "String + Number"
assert-equal ['alpha 'beta 'gamma 'delta] join ['alpha 'beta] ['gamma 'delta] "Block + Block with quoted words"

;;-----------------------------------------------------------------------------
;; Probing Edge Cases
;;-----------------------------------------------------------------------------
print "^/--- Probing Edge Cases ---"
;; Hypothesis: Empty string value should work
assert-equal "hello" join "" "hello" "Empty string + String"

;; Hypothesis: Empty string rest should work
assert-equal "hello" join "hello" "" "String + Empty string"

;; Hypothesis: None values should be handled
assert-equal "none" join none "" "None value should be formed"
assert-equal "testnone" join "test" none "String + None rest"

;;-----------------------------------------------------------------------------
;; Probing Complex Block Scenarios
;;-----------------------------------------------------------------------------
print "^/--- Probing Complex Block Scenarios ---"
;; Hypothesis: Nested blocks in rest should be reduced properly
assert-equal "start123end" join "start" [1 2 3 "end"] "Block with mixed types should be reduced"

;; Hypothesis: Block with variables should evaluate them
test-num: 42
test-str: "hello"
assert-equal "prefix42hello" join "prefix" [test-num test-str] "Block with variables should evaluate"

;;-----------------------------------------------------------------------------
;; Probing Different Series Types
;;-----------------------------------------------------------------------------
print "^/--- Probing Different Series Types ---"
;; Hypothesis: Different series types should behave consistently
test-string: "abc"
result-string: join test-string "def"
assert-equal "abcdef" result-string "String series should copy and append"
assert-equal "abc" test-string "Original string should remain unchanged"

;;-----------------------------------------------------------------------------
;; Probing Quoted Word Behavior
;;-----------------------------------------------------------------------------
print "^/--- Probing Quoted Word Behavior ---"
;; Hypothesis: Quoted words should be preserved as symbols
assert-equal ['start 'middle 'end] join ['start] ['middle 'end] "Quoted words should be preserved"

;; Hypothesis: Mix of quoted and unquoted should work when unquoted have values
word-val: 'dynamic
assert-equal ['start 'dynamic 'end] join ['start] [word-val 'end] "Mix of quoted words and variables"

;;-----------------------------------------------------------------------------
;; Probing Type Preservation
;;-----------------------------------------------------------------------------
print "^/--- Probing Type Preservation ---"
;; Hypothesis: Result type should match the base value type (after form if needed)
string-result: join "test" [1 2 3]
assert-equal string! type? string-result "String base should produce string result"

block-result: join ['elem1 'elem2] ['elem3 'elem4]
assert-equal block! type? block-result "Block base should produce block result"

;;-----------------------------------------------------------------------------
;; Probing Large Data Handling
;;-----------------------------------------------------------------------------
print "^/--- Probing Large Data Handling ---"
;; Hypothesis: JOIN should handle larger datasets efficiently
;; Using strings instead of symbols to avoid variable evaluation issues
large-block: []
loop 100 [append large-block "item"]
result-large: join ["start"] large-block
assert-equal 101 length? result-large "Large block append should work correctly"
assert-equal "start" first result-large "First element should be preserved"

;; Alternative large data test with numbers
large-number-block: []
loop 50 [append large-number-block length? large-number-block]
result-numbers: join [0] large-number-block
assert-equal 51 length? result-numbers "Large number block should work"
assert-equal 0 first result-numbers "First number should be preserved"

print "^/=== End of JOIN Function Diagnostic Probe ==="
print-test-summary
