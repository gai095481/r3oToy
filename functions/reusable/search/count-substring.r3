REBOL []

;; Last-Updated: 2025-07-30 09:05:02

;;=============================================================================
;; Function: count-substring
;;=============================================================================
;;
;; **Purpose:**
;;     Counts the number of non-overlapping occurrences of a sub-string within
;;     a series, with case-sensitivity.
;;
;; **Arguments:**
;;     - series [string!] "The string to search within."
;;     - sub-string [string!] "The sub-string to count."
;;
;; **Returns:**
;;     - [integer!] The number of times the sub-string is found.
;;
;; **Notes:**
;;     - The search is case-sensitive.
;;     - The function is optimized for performance by advancing the search
;;       position after each find.
;;     - If `sub-string` is empty, the function returns 0 to prevent infinite loops.
;;
count-substring: funct [
    series [string!]
    sub-string [string!]
] [
    ;;; Prevent infinite loop with an empty sub-string
    if empty? sub-string [return 0]

    count: 0
    while [series: find/case series sub-string] [
        count: count + 1
        series: find/case series sub-string
        if not series [break]
        series: skip series length? sub-string
    ]
    count
]

;;=============================================================================
;; Test Harness
;;=============================================================================

;;--- Test Helper ---
assert-equal: funct [
    expected
    actual
    description
] [
    either expected = actual [
        print ["  PASS:" description]
    ] [
        print ["  FAIL:" description]
        print ["    Expected:" mold expected]
        print ["    Actual:  " mold actual]
    ]
]

print "^/--- Testing count-substring ---"

;;--- Test Cases ---
assert-equal 3 count-substring "ababab" "ab" "Simple case"
assert-equal 2 count-substring "aaaaa" "aa" "Overlapping case"
assert-equal 0 count-substring "hello" "z" "No occurrence"
assert-equal 1 count-substring "Hello" "H" "Case-sensitive match"
assert-equal 0 count-substring "Hello" "h" "Case-sensitive non-match"
assert-equal 0 count-substring "" "a" "Empty series"
assert-equal 0 count-substring "abc" "" "Empty sub-string"
assert-equal 1 count-substring "one two three" "two" "Substring in the middle"
assert-equal 4 count-substring "!!!!" "!" "Repetitive characters"
