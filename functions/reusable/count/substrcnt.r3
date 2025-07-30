REBOL []

;;=============================================================================
;; Purpose: Count the number of non-overlapping occurrences of a sub-string
;;          within a series using letter case-sensitivity.
;;
;; Arguments:
;;   - series [string!] "The string to search for the substring."
;;   - sub-string [string!] "The sub-string to count."
;;
;; Returns:[integer!] The number of times the sub-string occurs.
;;         0 if `sub-string` is empty to prevent infinite loops.
;; Notes:
;;   - The search is letter case-sensitive.
;;   - Optimized for performance by advancing the search position after each `find` call.
;;=============================================================================
substrcntcs: funct [
    series [string!]
    sub-string [string!]
] [
    ;;; Prevent infinite loop with an empty sub-string:
    if empty? sub-string [return 0]

    count: 0

    while [series: find/case series sub-string] [
        count: count + 1
        series: find/case series sub-string

        if not series [break]

        series: skip series length? sub-string
    ]

    return count
]

;;=============================================================================
;; Purpose: letter case-insensitive version of `substrcntcs`.
;;=============================================================================
substrcntci: funct [
    series [string!]
    sub-string [string!]
] [
    ;;; Prevent infinite loop with an empty sub-string:
    if empty? sub-string [return 0]

    count: 0

    while [series: find series sub-string] [
        count: count + 1
        series: find series sub-string

        if not series [break]

        series: skip series length? sub-string
    ]

    return count
]

;;=============================================================================
;; QA Test Harness
;;=============================================================================
assert-equal: funct [
    expected
    actual
    description
] [
    either expected = actual [
        print ["✅ PASS:" description]
    ] [
        print ["❌ FAIL:" description]
        print ["    Expected:" mold expected]
        print ["    Actual:  " mold actual]
    ]
]

print "^/--- Testing substrcntcs ---"

;;--- Test Cases ---
assert-equal 3 substrcntcs "ababab" "ab" "Simple case"
assert-equal 2 substrcntcs "aaaaa" "aa" "Overlapping case"
assert-equal 0 substrcntcs "hello" "z" "No occurrence"
assert-equal 1 substrcntcs "Hello" "H" "Case-sensitive match"
assert-equal 0 substrcntcs "Hello" "h" "Case-sensitive non-match"
assert-equal 0 substrcntcs "" "a" "Empty series"
assert-equal 0 substrcntcs "abc" "" "Empty sub-string"
assert-equal 1 substrcntcs "one two three" "two" "Substring in the middle"
assert-equal 4 substrcntcs "!!!!" "!" "Repetitive characters"
assert-equal 2 substrcntcs "abababab" "abab" "Non-overlapping overlapping pattern"
