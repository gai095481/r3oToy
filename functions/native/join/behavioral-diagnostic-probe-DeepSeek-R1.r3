Rebol []

;;-----------------------------------------------------------------------------
;; Diagnostic Probe Script for `join` Function
;; Verified against REBOL/Bulk 3.19.0 target
;;-----------------------------------------------------------------------------

;;-- Test Harness
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
    {Output the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL TEST CASE EXAMPLES  PASSED."
    ][
        print "❌ SOME TEST CASE EXAMPLES FAILED."
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Probing Core Behavior
;;-----------------------------------------------------------------------------
assert-equal "510" (join 5 10) "Integer join becomes string concatenation"
assert-equal "2.03.5" (join 2.0 3.5) "Decimal join becomes string concatenation"
assert-equal "5true" (join 5 true) "Integer + logic becomes string"

original-block: [initial content]
joined-result: join original-block ["appended content"]
append original-block 'modified
assert-equal [initial content "appended content"] joined-result "First argument block is copied"

test-value: 42
assert-equal "Answer:42" (join "Answer:" test-value) "REST argument reduction (word->value)"
assert-equal "Result:30" (join "Result:" [10 + 20]) "REST argument reduction (expression)"

;;-----------------------------------------------------------------------------
;; Probing Block Behavior
;;-----------------------------------------------------------------------------
assert-equal [1 2 3 4] (join [1 2] [3 4]) "Block-to-block join"
assert-equal [a b c] (join [a b] 'c) "Block + word appends value"

word-val: 100
assert-equal [test 100] (join [test] [word-val]) "Block + evaluated word"
assert-equal [preserve symbol] (join [preserve] ['symbol]) "Block + lit-word"
assert-equal [outer [inner]] (join [outer] [[inner]]) "Nested block preservation"

;;-----------------------------------------------------------------------------
;; Probing String Behavior
;;-----------------------------------------------------------------------------
assert-equal "HelloWorld" (join "Hello" "World") "String + string"
assert-equal "Rebol 3" (join "Rebol" [" " 3]) "String + block of string and integer"
assert-equal "ID:0A1" (join "ID:" [00 #"A" 1]) "String + mixed block (00 becomes 0)"
assert-equal "Character:A" (join "Character:" #"A") "String + character"

;;-----------------------------------------------------------------------------
;; Probing Edge Cases
;;-----------------------------------------------------------------------------
assert-equal "nonenone" (join none none) "NONE arguments become 'none' strings"
assert-equal "Testnone" (join "Test" none) "String + NONE"
assert-equal "Hello" (join "Hello" "") "String + empty string"
assert-equal [1 2] (join [1 2] []) "Block + empty block"
assert-equal "" (join "" "") "Two empty strings"
assert-equal [] (join [] []) "Two empty blocks"
assert-equal %/path/to/file (join %/path/to/ %file) "File path join"

date-test-expected: rejoin ["Today: " form 2025-07-06]
date-test-actual: join "Today: " 2025-07-06
assert-equal date-test-expected date-test-actual "Date joining uses FORM"

;;-----------------------------------------------------------------------------
;; Probing Type Mixing Behavior
;;-----------------------------------------------------------------------------
assert-equal "Number:42" (join "Number:" 42) "String + integer"
assert-equal "true12" (join true [1 2]) "Logic + block becomes 'true' + block elements"
assert-equal rejoin [form 2025-07-06 "value"] (join 2025-07-06 "value") "Date + string"
assert-equal [item 1 2 3] (join [item] [1 2 3]) "Block + value block"
assert-equal "Result:30" (join "Result:" [10 + 20]) "String + expression block"

;;-----------------------------------------------------------------------------
;; Final Test Summary
;;-----------------------------------------------------------------------------
print-test-summary
