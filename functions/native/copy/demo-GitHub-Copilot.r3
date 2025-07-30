REBOL [
    Title: "Rebol 3 Substring Copy Operations with QA Harness (Fixed Failing Tests)"
    Date: 10-Jul-2024
    Version: 0.1.0
    File: %demo-GitHub-Copilot.r3
    Purpose: {Demonstrate raw usage of the `copy` function with negative indices.
             Demo various substring extraction techniques using the raw behaviors of `copy`,
             including negative `/part` arguments and use of `at`, `skip`, `tail` to adjust location.}
]

;; ================================
;; QA Testing Harness
;; ================================
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

;; Debug print function:
dprint: function [
   "Debug print function that can be easily disabled."
   value [any-type!]
][
   if debugMode [print value]
]

;; Set this to true to enable debug printing:
debugMode: true

;; Test cases block:
;; Each test case is a block: [test-string test-type test-code expected-result description]
testCases: [
    ;; Standard test cases demonstrating basic substring extraction:
    ["Hello, World!" "standard" [copy/part testString 5] "Hello" "Copy first 5 characters"]
    ["Rebol is awesome!" "standard" [copy at tail testString -5] "some!" "Copy last 5 characters"]
    ["abcdefghijklmnopqrstuvwxyz" "standard" [copy/part (at testString 8) 7] "hijklmn" "Copy 7 characters starting from 8th position"]
    ["The quick brown fox jumps over the lazy dog" "standard" [copy/part (skip (find testString "quick") 6) 7] "brown f" "Copy 7 characters starting 6 after 'quick'"]
    ["abcdefghijklmnop" "standard" [copy/part (find testString "j") -5] "efghi" "Copy 5 characters before 'j' (raw negative index)"]
    ["12345" "standard" [copy/part (find testString "5") -3] "234" "Copy 3 characters before '5' (raw negative index)"]
    ["wxyz" "standard" [copy/part (find testString "z") -3] "wxy" "Copy 3 characters before 'z' (raw negative index)"]
    ["áéíóúAB" "standard" [copy/part (find testString "A") -5] "áéíóú" "Copy 5 characters before 'A' with Unicode"]

    ;; New standard test cases using raw negative indices:
    ["abcdefghij" "standard" [copy/part testString 10] "abcdefghij" "Copy all characters"]
    ["Rebol programming" "standard" [copy/part (find testString "p") 11] "programming" "Copy 11 characters starting from 'p'"]
    ["1234567890" "standard" [copy/part (find testString "4") 3] "456" "Copy 3 characters starting from '4'"]
    ["A quick brown fox" "standard" [copy/part (skip (find testString "brown") -2) 5] "k bro" "Copy 5 characters starting 2 before 'brown'"]
    ["Rebol script example" "standard" [copy/part (at testString 7) 6] "script" "Copy 6 characters starting from 7th position"]
    ["Data processing in Rebol" "standard" [copy/part (find testString "processing") 10] "processing" "Copy 10 characters starting from 'processing'"]
    ["Functional programming" "standard" [copy/part (find testString "Func") 4] "Func" "Copy 4 characters starting from 'Func'"]

    ;; Revised test cases for previously failing tests using raw negative indices:

    ;; Use "Rebol" (rather than "R") so that FIND returns the pointer in the second word.
    ["Programming in Rebol" "standard" [copy/part (at testString ((index? (find testString "Rebol")) - 6)) 6] "ng in " "Copy 6 characters immediately preceding 'Rebol' using AT"]
    ["Programming in Rebol" "standard" [copy/part (skip (find testString "Rebol") -6) 6] "ng in " "Copy 6 characters immediately preceding 'Rebol' using SKIP"]

    ;; Test case for complete string copy.
    ["Complete string" "standard" [copy testString] "Complete string" "Copy complete string using COPY without /part"]
]

;; The original script's failedTestCases block is now integrated into testCases.
failedTestCases: []

;; Test execution function:
runTest: function [
    "Run a single test case."
    testNumber [integer!]
    testString [string!]
    testType [string!]
    testCode [block!]
    expectedResult [any-type!]
    description [string!]
][
    dprint rejoin ["Running Test case " testNumber " (" testType "): '" testString "' - " description]
    dprint rejoin ["  Test code: " mold testCode]
    actualResult: do bind/copy testCode 'testString
    dprint rejoin ["  Result: '" actualResult "'"]
    ;; Use the QA test harness to compare expected and actual values:
    assert-equal expectedResult actualResult rejoin ["Test case " testNumber " (" testType "): " description]
]

;; Run all tests
index: 1
forall testCases [
    testCase: first testCases
    runTest index testCase/1 testCase/2 testCase/3 testCase/4 testCase/5
    index: index + 1
]

print "All tests completed."
print-test-summary
