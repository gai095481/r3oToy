REBOL [
    Title: "Test Harness for array-utils"
    Date: now/date
    Purpose: "To test the functions in arrays/arrays-TraeAI.r3"
]

do %../arrays/arrays-TraeAI.r3
print "Loaded arrays/arrays-TraeAI.r3 for testing."

total-tests: 0
passed-tests: 0
failed-tests: 0

print-test-title: function [title [string!]] [
    print ["^/^-- Test:" title "--"]
]

assert-equal: function [
    title [string!]
    actual [any-type!]
    expected [any-type!]
    /message msg [string!]
] [
    total-tests: total-tests + 1
    either all [
        (type? :actual) = (type? :expected) ; Basic type check first
        equal? :actual :expected
    ][
        passed-tests: passed-tests + 1
        print ["PASS:" title]
    ][
        failed-tests: failed-tests + 1
        print ["FAIL:" title]
        print ["  Expected:" mold :expected]
        print ["  Actual:  " mold :actual]
        if message [print ["  Message: " msg]]
    ]
]

assert-error: function [
    title [string!]
    code-block [block!]
] [
    total-tests: total-tests + 1
    error: attempt [do code-block]
    either all [
        error? error
        error/id <> 'no-error ; Ensure it's a real error, not just 'none' from attempt
    ][
        passed-tests: passed-tests + 1
        print ["PASS (Error Expected):" title]
        print ["  Error:" mold disarm error] ; disarm to print error object nicely
    ][
        failed-tests: failed-tests + 1
        print ["FAIL (Error Expected, but none or wrong type occurred):" title]
        print ["  Code block:" mold code-block]
        print ["  Result:" mold :error]
    ]
]

print-summary: function [] [
    print [
        "^/^/--- Test Summary ---"
        newline "Total Tests:" total-tests
        newline "Passed:     " passed-tests
        newline "Failed:     " failed-tests
        newline "--------------------^/"
    ]
]

; --- Test Cases for make-array ---
print-test-title "MA1: Create 1D array [3]"
result-ma1: make-array [3]
assert-equal "MA1 result" result-ma1 [none none none]

print-test-title "MA2: Create 2D array [2 2]"
result-ma2: make-array [2 2]
assert-equal "MA2 result" result-ma2 [[none none] [none none]]

print-test-title "MA3: Create 3D array [1 2 1]"
result-ma3: make-array [1 2 1]
assert-equal "MA3 result" result-ma3 [[[none] [none]]]

print-test-title "MA4: Create 1D array [2] with value 0"
result-ma4: make-array/with [2] 0
assert-equal "MA4 result" result-ma4 [0 0]

print-test-title "MA5: Create 2D array [2 1] with value 'a'"
result-ma5: make-array/with [2 1] "a"
assert-equal "MA5 result" result-ma5 [["a"] ["a"]]

print-test-title "MA6: Error - Empty dimensions"
assert-error "MA6 execution" [make-array []]

print-test-title "MA7: Error - Zero dimension [3 0 2]"
assert-error "MA7 execution" [make-array [3 0 2]]

print-test-title "MA8: Error - Negative dimension [3 -1 2]"
assert-error "MA8 execution" [make-array [3 -1 2]]

print-test-title "MA9: Error - Non-integer dimension [3 2.5]"
assert-error "MA9 execution" [make-array [3 2.5]]

print-test-title "MA10: Error - Mixed good/bad dimensions [3 'a']"
assert-error "MA10 execution" [make-array [3 "a"]]


; --- Setup for get-element and set-element tests ---
arr1D: [10 20 30]
arr2D: [[1 2] [3 4]]
arr3D: [[[5 6] [7 8]] [[9 10] [11 12]]]

; --- Test Cases for get-element ---
print-test-title "GE1: arr1D, [2]"
result-ge1: get-element arr1D [2]
assert-equal "GE1 result" result-ge1 20

print-test-title "GE2: arr2D, [1 2]"
result-ge2: get-element arr2D [1 2]
assert-equal "GE2 result" result-ge2 2

print-test-title "GE3: arr2D, [2 1]"
result-ge3: get-element arr2D [2 1]
assert-equal "GE3 result" result-ge3 3

print-test-title "GE4: arr3D, [1 1 2]"
result-ge4: get-element arr3D [1 1 2]
assert-equal "GE4 result" result-ge4 6

print-test-title "GE5: arr3D, [2 2 1]"
result-ge5: get-element arr3D [2 2 1]
assert-equal "GE5 result" result-ge5 11

print-test-title "GE6: Error - arr1D, [4] (out of bounds)"
assert-error "GE6 execution" [get-element arr1D [4]]

print-test-title "GE7: Error - arr2D, [1 3] (out of bounds)"
assert-error "GE7 execution" [get-element arr2D [1 3]]

print-test-title "GE8: Error - arr1D, [0] (out of bounds - 1-based)"
assert-error "GE8 execution" [get-element arr1D [0]]

print-test-title "GE9: Error - arr1D, [1 1] (too many indices)"
assert-error "GE9 execution" [get-element arr1D [1 1]]

print-test-title "GE10: Error - arr2D, [1] (too few indices)"
assert-error "GE10 execution" [get-element arr2D [1]]

print-test-title "GE11: Error - arr1D, ['a'] (non-integer index)"
assert-error "GE11 execution" [get-element arr1D ["a"]]


; --- Test Cases for set-element ---
print-test-title "SE1: copy arr1D, [2], 99"
se_arr1: copy arr1D
result-se1: set-element se_arr1 [2] 99
assert-equal "SE1 result array" result-se1 [10 99 30]
assert-equal "SE1 original arr1D unchanged" arr1D [10 20 30]

print-test-title "SE2: copy arr2D, [1 2], 99"
se_arr2: copy/deep arr2D ; Use deep copy for multi-dimensional
result-se2: set-element se_arr2 [1 2] 99
assert-equal "SE2 result array" result-se2 [[1 99] [3 4]]
assert-equal "SE2 original arr2D unchanged" arr2D [[1 2] [3 4]]

print-test-title "SE3: copy arr2D, [2 1], 99"
se_arr3: copy/deep arr2D
result-se3: set-element se_arr3 [2 1] 99
assert-equal "SE3 result array" result-se3 [[1 2] [99 4]]

print-test-title "SE4: copy arr3D, [1 1 2], 99"
se_arr4: copy/deep arr3D
result-se4: set-element se_arr4 [1 1 2] 99
assert-equal "SE4 result array" result-se4 [[[5 99] [7 8]] [[9 10] [11 12]]]

print-test-title "SE5: copy arr3D, [2 2 1], 99"
se_arr5: copy/deep arr3D
result-se5: set-element se_arr5 [2 2 1] 99
assert-equal "SE5 result array" result-se5 [[[5 6] [7 8]] [[9 10] [99 12]]]

print-test-title "SE6: Error - copy arr1D, [4], 99 (out of bounds)"
se_arr6: copy arr1D
assert-error "SE6 execution" [set-element se_arr6 [4] 99]

print-test-title "SE7: Error - copy arr2D, [1 3], 99 (out of bounds)"
se_arr7: copy/deep arr2D
assert-error "SE7 execution" [set-element se_arr7 [1 3] 99]

print-test-title "SE8: Error - copy arr1D, [1 1], 99 (too many indices)"
se_arr8: copy arr1D
assert-error "SE8 execution" [set-element se_arr8 [1 1] 99]

print-test-title "SE9: Error - copy arr2D, [1], 99 (too few indices)"
se_arr9: copy/deep arr2D
assert-error "SE9 execution" [set-element se_arr9 [1] 99]

print-test-title "SE10: Error - copy arr1D, ['a'], 99 (non-integer index)"
se_arr10: copy arr1D
assert-error "SE10 execution" [set-element se_arr10 ["a"] 99]


; --- Test Cases for get-dimensions ---
print-test-title "GD1: [none none none]"
result-gd1: get-dimensions [none none none]
assert-equal "GD1 result" result-gd1 [3]

print-test-title "GD2: [[1 2] [3 4]]"
result-gd2: get-dimensions [[1 2] [3 4]]
assert-equal "GD2 result" result-gd2 [2 2]

print-test-title "GD3: [[[5 6] [7 8]] [[9 10] [11 12]]]"
result-gd3: get-dimensions arr3D ; using predefined arr3D
assert-equal "GD3 result" result-gd3 [2 2 2]

print-test-title "GD4: [[1 2 3] [4 5]] (irregular)"
result-gd4: get-dimensions [[1 2 3] [4 5]]
assert-equal "GD4 result" result-gd4 [2 3]

print-test-title "GD5: [] (empty array)"
result-gd5: get-dimensions []
assert-equal "GD5 result" result-gd5 []

print-test-title "GD6: [10] (scalar in list)"
result-gd6: get-dimensions [10]
assert-equal "GD6 result" result-gd6 [1]

print-test-title "GD7: [[[1]]]]"
result-gd7: get-dimensions [[[1]]]
assert-equal "GD7 result" result-gd7 [1 1 1]

print-test-title "GD8: Error - Scalar 5 (due to type hint)"
assert-error "GD8 execution" [get-dimensions 5]


; --- Test Cases for valid-array? ---
print-test-title "VA1: [none none none]"
result-va1: valid-array? [none none none]
assert-equal "VA1 result" result-va1 true

print-test-title "VA2: [[1 2] [3 4]]"
result-va2: valid-array? [[1 2] [3 4]]
assert-equal "VA2 result" result-va2 true

print-test-title "VA3: arr3D"
result-va3: valid-array? arr3D
assert-equal "VA3 result" result-va3 true

print-test-title "VA4: [[1 2] [3]] (irregular)"
result-va4: valid-array? [[1 2] [3]]
assert-equal "VA4 result" result-va4 false

print-test-title "VA5: [[1 2] [3 [4]]] (irregular depth)"
result-va5: valid-array? [[1 2] [3 [4]]]
assert-equal "VA5 result" result-va5 false

print-test-title "VA6: [] (empty array)"
result-va6: valid-array? []
assert-equal "VA6 result" result-va6 true

print-test-title "VA7: [10] (scalar in list)"
result-va7: valid-array? [10]
assert-equal "VA7 result" result-va7 true

print-test-title "VA8: [[1] [2] [3]]"
result-va8: valid-array? [[1] [2] [3]]
assert-equal "VA8 result" result-va8 true

print-test-title "VA9: [[1 2] [none none]] (mixed types, regular)"
result-va9: valid-array? [[1 2] [none none]]
assert-equal "VA9 result" result-va9 true

print-test-title "VA10: Error - Scalar 5 (due to type hint)"
assert-error "VA10 execution" [valid-array? 5]

print-test-title "VA11: [[1] [2 3]] (irregular)"
result-va11: valid-array? [[1] [2 3]]
assert-equal "VA11 result" result-va11 false

; --- Final Summary ---
print-summary
