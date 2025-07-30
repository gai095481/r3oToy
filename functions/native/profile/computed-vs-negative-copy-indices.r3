REBOL [
    Title: "Profiling Negative vs Computed Positive Indexing"
    Date: 2025-07-30
    File: %profile-performance.r3
    Purpose: {Profile the performance difference between:
              1. Using negative indexes with COPY/PART.
              2. Using computed positive indexes (via INDEX?) with COPY/PART.
              While negative indexes are common, computing them explicitly can improve clarity and reduce off-by-one errors.
              This file demonstrates how to use the PROFILE refinement to benchmark these two methods.}
]

testString: "Programming in Rebol, a demonstration string for performance testing."

;--------------------------------------------------------------------------
; Method 1: Negative Index Approach
; Using negative length directly.
negMethod: function [str] [
    ; In this example, we extract 6 characters immediately preceding the found "Rebol"
    ; Note: Negative lengths may return unexpected results if not carefully computed.
    copy/part (find str "Rebol") -6
]

;--------------------------------------------------------------------------
; Method 2: Computed Positive Index Approach
; Compute the proper starting index via INDEX? and use a positive length.
posMethod: function [str] [
    ; Calculate the starting position 6 characters before the found position.
    startIndex: (index? find str "Rebol") - 6
    copy/part (at str startIndex) 6
]

; Print example results:
print {Result using negative method:} negMethod testString
print {Result using computed positive method:} posMethod testString

;--------------------------------------------------------------------------
; Profile the two methods:

print "Profiling negative method (using negative length)..."
profile [
    repeat 100000 [
        negMethod testString
    ]
]

print "Profiling computed positive method (using computed positive index)..."
profile [
    repeat 100000 [
        posMethod testString
    ]
]

print "Profiling complete."
