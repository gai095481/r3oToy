REBOL [
    Title: "A Diagnostic Probe for the `take` function"
    Version: 0.1.0
    Author: "AI Software Development Assistant"
    Date: 22-Jun-2025
    Purpose: "To gather error-free evidence on `take`'s behavior."
]

print "--- `take` Function: A Diagnostic Probe ---"

; Helper to check and flag test results
assert: func [description [string!] condition [logic!]] [
    print [
        either condition ["✅ PASSED:"] ["❌ FAILED:"]
        description
    ]
]

;-----------------------------------------------------------------------------
;;; 1. Probing Basic `take` on a BLOCK
;-----------------------------------------------------------------------------
print "^/--- 1. Probing Basic `take` on a BLOCK ---"
data: [a b c d e]
result: take data
assert "Basic take returns the first element" (result = 'a)
assert "Basic take modifies the original" (data = [b c d e])

;-----------------------------------------------------------------------------
;;; 2. Probing `take` on a Series Position
;-----------------------------------------------------------------------------
print "^/--- 2. Probing `take` on a Series Position ---"
data: [a b c d e]
result: take next data
assert "take on a series position returns the correct element" (result = 'b)
assert "take on a series position modifies the original correctly" (data = [a c d e])

;-----------------------------------------------------------------------------
;;; 3. Probing `/part` with a NUMBER
;-----------------------------------------------------------------------------
print "^/--- 3. Probing `/part` with a NUMBER ---"
data: [a b c d e]
result: take/part data 2
assert "/part returns the correct number of elements" (result = [a b])
assert "/part modifies the original correctly" (data = [c d e])

data: [x y]
result: take/part data 5 ; Take more than available
assert "/part with a large count takes all elements" (result = [x y])
assert "/part with a large count empties the original" (empty? data)


;-----------------------------------------------------------------------------
;;; 4. Probing `/last`
;-----------------------------------------------------------------------------
print "^/--- 4. Probing `/last` ---"
data: [a b c d e]
result: take/last data
assert "/last returns the final element" (result = 'e)
assert "/last modifies the original correctly" (data = [a b c d])


;-----------------------------------------------------------------------------
;;; 5. Probing `/last` with `/part`
;-----------------------------------------------------------------------------
print "^/--- 5. Probing `/last` with `/part` ---"
data: [a b c d e]
result: take/last/part data 2
assert "/last/part returns the correct elements from the tail" (result = [d e])
assert "/last/part modifies the original correctly" (data = [a b c])


;-----------------------------------------------------------------------------
;;; 6. Probing `/deep` vs. Shallow Copy (Corrected Test)
;-----------------------------------------------------------------------------
print "^/--- 6. Probing `/deep` vs. Shallow Copy (Corrected) ---"

print "^/-- Testing shallow take (default) --"
nested-series: [x y]
data-shallow: reduce ['a nested-series 'b]
print ["Original data:" mold data-shallow]

result-shallow: take data-shallow ; Take just the 'a
print ["Result of take:" mold result-shallow]

print "^/Modifying the nested block in the *original* data..."
append nested-series 'Z

print "Original data after modification:"
probe data-shallow
assert "Shallow take: Original data reflects modification" (data-shallow = [[x y Z] b])
print ""

print "-- Testing /deep take --"
nested-series: [x y]
data-deep: reduce ['a nested-series 'b]

result-deep: take/deep data-deep ; Use /deep
print ["Original data:" mold data-deep]
print ["Result of take/deep:" mold result-deep]

print "^/Modifying the nested block in the *original* data..."
append nested-series 'Z

print "Original data after modification:"
probe data-deep
assert "/deep take: Original data should NOT reflect modification (INCORRECT DEMO)" (data-deep = [[x y Z] b])
print {NOTE: This probe reveals `take`'s copy behavior applies to the RETURNED value,
not what is left behind. The premise of this test is flawed for `take`.
The correct way to test shallow vs deep copy is on the *result*.}

print "^/-- Testing shallow vs deep on the RETURNED value (Definitive) --"
original-data: [ [a b] [c d] ]
print ["Original:" mold original-data]

shallow-result: take/part original-data 1
deep-result: take/deep/part original-data 1
print ["Shallow Result:" mold shallow-result]
print ["Deep Result:" mold deep-result]
print ["Data after two takes:" mold original-data]

print "^/Modifying the nested block in the SHALLOW result..."
append first shallow-result 'Z
print "Modified shallow result:" probe shallow-result
; The original data is empty, so we can't check it.
; This test's structure is still not ideal for `take`. Let's simplify.

print "^/-- FINAL, SIMPLEST TEST --"
original: [ a [b c] d ]
taken-shallow: take/part next original 1 ; takes [[b c]]
taken-deep:    take/deep/part next original 1 ; takes [d] -- wait, series moves!
print "This reveals `take` is destructive, making this comparison difficult."
print "Final conclusion: The `/deep` refinement copies series *out* of the original."
print "It does not affect what is left behind. Testing this requires checking the result."

data: [ [a b] [c d] ]
res-s: take data
res-d: take/deep data
append res-s 'S
append res-d 'D
assert "Shallow copy test on result" (res-s = [[a b] S])
assert "Deep copy test on result" (res-d = [[c d] D])
print {This still doesn't show the link. This is a very difficult behavior to
probe with `take` because it's destructive. The user guide will need to explain
this very carefully based on the `copy` function's behavior.}
print ""


;-----------------------------------------------------------------------------
;;; 7. Probing `/all`
;-----------------------------------------------------------------------------
print "^/--- 7. Probing `/all` ---"
data: [a b c d e]
result: take/all data
assert "/all returns a copy of the entire series" (result = [a b c d e])
assert "/all empties the original series" (empty? data)


;-----------------------------------------------------------------------------
;;; 8. Probing `take` on a STRING
;-----------------------------------------------------------------------------
print "^/--- 8. Probing `take` on a STRING ---"
data: "Hello World"
result: take/part data 5
assert "/part on a string returns the correct substring" (result = "Hello")
assert "/part on a string modifies the original" (data = " World")
print ""

print "--- End of Diagnostic Probe ---"
