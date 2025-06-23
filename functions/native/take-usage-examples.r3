REBOL [
    Title: "1. `take` - Happy Path Examples"
    Date: 22-Jun-2025
    Purpose: "To demonstrate the most common, simple, and correct uses of the `take` function."
]

print "--- `take` Function: Happy Path Examples ---"
print {
The `take` function is a destructive action that removes one or more
elements from a series and returns the element(s) it removed.
The original series is always modified in place.
}

;-----------------------------------------------------------------------------
print "^/--- Example 1: Taking a Single Element from the Front ---"
;-----------------------------------------------------------------------------
; This is the simplest use case. `take` on its own removes and returns
; the very first element of the series.

data: [a b c d e]
print ["Original series:" mold data]

first-item: take data
print ["Item taken:" mold first-item]
print ["Series after `take`:" mold data]

; FIX: Removed comma from assertion block
assert: [first-item = 'a data = [b c d e]]
print ["^/Assertion:" either all assert ["PASSED"]["FAILED"]]


;-----------------------------------------------------------------------------
print "^/--- Example 2: Taking a Single Element from the End (`/last`) ---"
;-----------------------------------------------------------------------------
; The `/last` refinement changes the direction. It takes the very last
; element from the series instead of the first.

data: [a b c d e]
print ["^/Original series:" mold data]

last-item: take/last data
print ["Item taken with /last:" mold last-item]
print ["Series after `take/last`:" mold data]

assert: [last-item = 'e data = [a b c d]]
print ["^/Assertion:" either all assert ["PASSED"]["FAILED"]]


;-----------------------------------------------------------------------------
print "^/--- Example 3: Taking Multiple Elements from the Front (`/part`) ---"
;-----------------------------------------------------------------------------
; The `/part` refinement is used with a number to specify how many
; elements to take.

data: [a b c d e]
print ["^/Original series:" mold data]

first-two-items: take/part data 2
print ["Items taken with /part 2:" mold first-two-items]
print ["Series after `take/part`:" mold data]

assert: [first-two-items = [a b] data = [c d e]]
print ["^/Assertion:" either all assert ["PASSED"]["FAILED"]]


;-----------------------------------------------------------------------------
print "^/--- Example 4: Taking from a Specific Position ---"
;-----------------------------------------------------------------------------
; `take` operates on the "current position" of a series. We can use
; functions like `find` or `next` to get a handle to a different position
; and take from there.

data: [a b c d e]
print ["^/Original series:" mold data]

; `next data` gives us a handle to the series starting at 'b
item-from-middle: take (next data)
print ["Item taken from the middle:" mold item-from-middle]
print ["Series after taking from the middle:" mold data]

assert: [item-from-middle = 'b data = [a c d e]]
print ["^/Assertion:" either all assert ["PASSED"]["FAILED"]]


;-----------------------------------------------------------------------------
print "^/--- Example 5: Taking All Elements (`/all`) ---"
;-----------------------------------------------------------------------------
; The `/all` refinement is a convenient way to get a copy of the
; entire series while simultaneously clearing the original.

data: [a b c d e]
print ["^/Original series:" mold data]

all-items: take/all data
print ["Items taken with /all:" mold all-items]
print ["Series after `take/all`:" mold data]

assert: [all-items = [a b c d e] empty? data]
print ["^/Assertion:" either all assert ["PASSED"]["FAILED"]]

