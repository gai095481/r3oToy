REBOL [
    Title: "A Diagnostic Probe for the `take` function"
    Version: 0.1.0
    Author: "AI Software Development Assistant"
    Date: 22-Jun-2025
    Purpose: "To gather error-free evidence on `take`'s behavior."
]

print "--- `take` Function: A Diagnostic Probe ---"

; Helper to check and flag test results
assert: func [
    description [string!] "Description of the test"
    actual-val [any-type!] "The actual value obtained from the test"
    expected-val [any-type!] "The expected value"
] [
    condition: false
    ; Use 'equal? for robust comparison, especially for blocks and series.
    ; Use 'same? for none! checks if required, but '=' handles none correctly.
    if all [any-series? :actual-val any-series? :expected-val] [
        condition: all [equal? :actual-val :expected-val same-type? :actual-val :expected-val]
    ] else [
        condition: :actual-val = :expected-val
    ]

    either condition [
        print ["✅ PASSED:" description]
    ] [
        print ["❌ FAILED:" description]
        print ["  Expected:" mold :expected-val]
        print ["  Actual:  " mold :actual-val]
        if not same-type? :actual-val :expected-val [
            print ["  Type Mismatch: Expected" (form type? :expected-val) "Got" (form type? :actual-val)]
        ]
    ]
]

;-----------------------------------------------------------------------------
;;; 1. Probing Basic `take` on a BLOCK
;-----------------------------------------------------------------------------
print "^/--- 1. Probing Basic `take` on a BLOCK ---"
data: [a b c d e]
expected-result: 'a
expected-data-after: [b c d e]
actual-result: take data
assert "Basic take: Result" actual-result expected-result
assert "Basic take: Data after" data expected-data-after

;-----------------------------------------------------------------------------
;;; 2. Probing `take` on a Series Position
;-----------------------------------------------------------------------------
print "^/--- 2. Probing `take` on a Series Position ---"
data: [a b c d e]
expected-result: 'b
expected-data-after: [a c d e]
actual-result: take next data
assert "Take from series position: Result" actual-result expected-result
assert "Take from series position: Data after" data expected-data-after

;-----------------------------------------------------------------------------
;;; 3. Probing `/part` with a NUMBER
;-----------------------------------------------------------------------------
print "^/--- 3. Probing `/part` with a NUMBER ---"
data: [a b c d e]
expected-result1: [a b]
expected-data-after1: [c d e]
actual-result1: take/part data 2
assert "/part (standard): Result" actual-result1 expected-result1
assert "/part (standard): Data after" data expected-data-after1

data: [x y]
expected-result2: [x y]
expected-data-after2: [] ; empty block
actual-result2: take/part data 5 ; Take more than available
assert "/part (large count): Result" actual-result2 expected-result2
assert "/part (large count): Data after is empty" data expected-data-after2


;-----------------------------------------------------------------------------
;;; 4. Probing `/last`
;-----------------------------------------------------------------------------
print "^/--- 4. Probing `/last` ---"
data: [a b c d e]
expected-result: 'e
expected-data-after: [a b c d]
actual-result: take/last data
assert "/last: Result" actual-result expected-result
assert "/last: Data after" data expected-data-after


;-----------------------------------------------------------------------------
;;; 5. Probing `/last` with `/part`
;-----------------------------------------------------------------------------
print "^/--- 5. Probing `/last` with `/part` ---"
data: [a b c d e]
expected-result: [d e]
expected-data-after: [a b c]
actual-result: take/last/part data 2
assert "/last/part: Result" actual-result expected-result
assert "/last/part: Data after" data expected-data-after


;-----------------------------------------------------------------------------
;;; 6. Probing `/deep` on the RETURNED VALUE
;-----------------------------------------------------------------------------
print "^/--- 6. Probing `/deep` on the RETURNED VALUE ---"
print {The `/deep` refinement with `take` ensures that if the taken item is a series,
the *returned value* is a deep copy of that series. If `/deep` is not used,
the returned value (if a series) is the actual series node from the original structure.}

master-nested-block: ['inner 'original]
original-structure: reduce ['outer1 copy master-nested-block 'outer2]

; Test 1: take/deep
data-for-deep-take: copy/deep original-structure
print ["^/Initial data for /deep take:" mold data-for-deep-take]

taken-item-deep: take/deep at data-for-deep-take 2 ; Takes the nested block [inner original]
print ["Item taken with /deep:" mold taken-item-deep]
print ["Data after /deep take:" mold data-for-deep-take]

assert "Data structure after /deep take" data-for-deep-take ['outer1 'outer2]
assert "Content of deeply taken item" taken-item-deep ['inner 'original]

; Test 2: take (shallow)
data-for-shallow-take: copy/deep original-structure
print ["^/Initial data for shallow take:" mold data-for-shallow-take]

taken-item-shallow: take at data-for-shallow-take 2 ; Takes the nested block [inner original]
print ["Item taken with shallow take:" mold taken-item-shallow]
print ["Data after shallow take:" mold data-for-shallow-take]

assert "Data structure after shallow take" data-for-shallow-take ['outer1 'outer2]
assert "Content of shallowly taken item" taken-item-shallow ['inner 'original]

; Key assertions: equality and sameness
assert "Deep vs. Shallow: Initial content equality" taken-item-deep taken-item-shallow
assert "Deep vs. Shallow: Should be different series instances" (not same? head taken-item-deep head taken-item-shallow) true

print ["^/Modifying the shallowly taken item (original sub-series):" mold taken-item-shallow]
append taken-item-shallow 'MODIFIED_SHALLOW
print ["Modified shallowly taken item:" mold taken-item-shallow]

assert "Modified shallow item reflects change" taken-item-shallow ['inner 'original 'MODIFIED_SHALLOW]
assert "Deeply taken item should NOT reflect change to shallow item" taken-item-deep ['inner 'original]

print ["^/Modifying the deeply taken item:" mold taken-item-deep]
append taken-item-deep 'MODIFIED_DEEP
print ["Modified deeply taken item:" mold taken-item-deep]

assert "Modified deep item reflects its own change" taken-item-deep ['inner 'original 'MODIFIED_DEEP]
assert "Shallow item should NOT reflect change to deep item (already confirmed, but good check)" taken-item-shallow ['inner 'original 'MODIFIED_SHALLOW]

print {^/Conclusion: `take/deep` results in a distinct, deep copy of the taken series.
Modifications to this copy do not affect the original series (which was taken shallowly in the other test).
Modifications to a shallowly taken series also do not affect the deeply taken one because they are different instances.}
print ""


;-----------------------------------------------------------------------------
;;; 7. Probing `/all`
;-----------------------------------------------------------------------------
print "^/--- 7. Probing `/all` ---"
data: [a b c d e]
original-copy: copy data ; For expected result
expected-data-after: []
actual-result: take/all data
assert "/all: Result" actual-result original-copy
assert "/all: Data after is empty" data expected-data-after


;-----------------------------------------------------------------------------
;;; 8. Probing `take` on a STRING
;-----------------------------------------------------------------------------
print "^/--- 8. Probing `take` on a STRING ---"
; Test /part on string
data-str1: "Hello World"
expected-result-str1: "Hello"
expected-data-after-str1: " World"
actual-result-str1: take/part data-str1 5
assert "/part on string: Result" actual-result-str1 expected-result-str1
assert "/part on string: Data after" data-str1 expected-data-after-str1

; Test basic take on string (char! result)
print "^/-- Basic take on string (char! result) --"
data-str2: "abc"
expected-char: #"a"
expected-data-after-str2: "bc"
actual-char: take data-str2
assert "Basic take on string: Result value" actual-char expected-char
assert "Basic take on string: Result type is char!" (char? actual-char) true
assert "Basic take on string: Data after" data-str2 expected-data-after-str2
print ""

;-----------------------------------------------------------------------------
;;; 9. Probing `take/part` with COUNT = 0
;-----------------------------------------------------------------------------
print "^/--- 9. Probing `take/part` with COUNT = 0 ---"
print "Expected: returns empty series of same type, original unchanged."

; Test with BLOCK
print "^/-- Block --"
data-b0: [a b c]
original-b0: copy data-b0
expected-res-b0: []
actual-res-b0: take/part data-b0 0
assert "take/part block 0: Result is empty block" actual-res-b0 expected-res-b0
assert "take/part block 0: Original block unchanged" data-b0 original-b0

; Test with STRING
print "^/-- String --"
data-s0: "xyz"
original-s0: copy data-s0
expected-res-s0: ""
actual-res-s0: take/part data-s0 0
assert "take/part string 0: Result is empty string" actual-res-s0 expected-res-s0
assert "take/part string 0: Original string unchanged" data-s0 original-s0

; Test with BINARY
print "^/-- Binary --"
data-bin0: #{010203}
original-bin0: copy data-bin0
expected-res-bin0: #{}
actual-res-bin0: take/part data-bin0 0
assert "take/part binary 0: Result is empty binary" actual-res-bin0 expected-res-bin0
assert "take/part binary 0: Original binary unchanged" data-bin0 original-bin0
print ""

;-----------------------------------------------------------------------------
;;; 10. Probing `take/part` with COUNT = 1
;-----------------------------------------------------------------------------
print "^/--- 10. Probing `take/part` with COUNT = 1 ---"
print "Expected: returns series of same type with one element, original modified."

; Test with BLOCK
print "^/-- Block --"
data-b1: [a b c]
expected-res-b1: [a]
expected-data-b1: [b c]
actual-res-b1: take/part data-b1 1
assert "take/part block 1: Result is block with first element" actual-res-b1 expected-res-b1
assert "take/part block 1: Original block modified" data-b1 expected-data-b1

; Test with STRING
print "^/-- String --"
data-s1: "xyz"
expected-res-s1: "x"
expected-data-s1: "yz"
actual-res-s1: take/part data-s1 1
assert "take/part string 1: Result is string with first char" actual-res-s1 expected-res-s1
assert "take/part string 1: Original string modified" data-s1 expected-data-s1

; Test with BINARY
print "^/-- Binary --"
data-bin1: #{010203}
expected-res-bin1: #{01}
expected-data-bin1: #{0203}
actual-res-bin1: take/part data-bin1 1
assert "take/part binary 1: Result is binary with first byte" actual-res-bin1 expected-res-bin1
assert "take/part binary 1: Original binary modified" data-bin1 expected-data-bin1
print ""

;-----------------------------------------------------------------------------
;;; 11. Probing `take/all` on EMPTY Series
;-----------------------------------------------------------------------------
print "^/--- 11. Probing `take/all` on EMPTY Series ---"
print "Expected: returns empty series of same type, original remains empty."

; Test with BLOCK
print "^/-- Empty Block --"
data-be: []
original-be: copy data-be
expected-res-be: []
actual-res-be: take/all data-be
assert "take/all empty block: Result is empty block" actual-res-be expected-res-be
assert "take/all empty block: Original block still empty" data-be original-be

; Test with STRING
print "^/-- Empty String --"
data-se: ""
original-se: copy data-se
expected-res-se: ""
actual-res-se: take/all data-se
assert "take/all empty string: Result is empty string" actual-res-se expected-res-se
assert "take/all empty string: Original string still empty" data-se original-se

; Test with BINARY
print "^/-- Empty Binary --"
data-bine: #{}
original-bine: copy data-bine
expected-res-bine: #{}
actual-res-bine: take/all data-bine
assert "take/all empty binary: Result is empty binary" actual-res-bine expected-res-bine
assert "take/all empty binary: Original binary still empty" data-bine original-bine
print ""

;-----------------------------------------------------------------------------
;;; 12. Probing Basic `take` on EMPTY Series
;-----------------------------------------------------------------------------
print "^/--- 12. Probing Basic `take` on EMPTY Series ---"
print "Expected: returns none, original remains empty."

; Test with BLOCK
print "^/-- Empty Block --"
data-be2: []
original-be2: copy data-be2
expected-res-be2: none
actual-res-be2: take data-be2
assert "Basic take empty block: Result is none" actual-res-be2 expected-res-be2
assert "Basic take empty block: Original block still empty" data-be2 original-be2

; Test with STRING
print "^/-- Empty String --"
data-se2: ""
original-se2: copy data-se2
expected-res-se2: none
actual-res-se2: take data-se2
assert "Basic take empty string: Result is none" actual-res-se2 expected-res-se2
assert "Basic take empty string: Original string still empty" data-se2 original-se2

; Test with BINARY
print "^/-- Empty Binary --"
data-bine2: #{}
original-bine2: copy data-bine2
expected-res-bine2: none
actual-res-bine2: take data-bine2
assert "Basic take empty binary: Result is none" actual-res-bine2 expected-res-bine2
assert "Basic take empty binary: Original binary still empty" data-bine2 original-bine2
print ""

;-----------------------------------------------------------------------------
;;; 13. Probing `take/last` on EMPTY Series
;-----------------------------------------------------------------------------
print "^/--- 13. Probing `take/last` on EMPTY Series ---"
print "Expected: returns none, original remains empty."

; Test with BLOCK
print "^/-- Empty Block --"
data-be3: []
original-be3: copy data-be3
expected-res-be3: none
actual-res-be3: take/last data-be3
assert "take/last empty block: Result is none" actual-res-be3 expected-res-be3
assert "take/last empty block: Original block still empty" data-be3 original-be3

; Test with STRING
print "^/-- Empty String --"
data-se3: ""
original-se3: copy data-se3
expected-res-se3: none
actual-res-se3: take/last data-se3
assert "take/last empty string: Result is none" actual-res-se3 expected-res-se3
assert "take/last empty string: Original string still empty" data-se3 original-se3

; Test with BINARY
print "^/-- Empty Binary --"
data-bine3: #{}
original-bine3: copy data-bine3
expected-res-bine3: none
actual-res-bine3: take/last data-bine3
assert "take/last empty binary: Result is none" actual-res-bine3 expected-res-bine3
assert "take/last empty binary: Original binary still empty" data-bine3 original-bine3
print ""

;-----------------------------------------------------------------------------
;;; 14. Probing `take` on BINARY (including type checks)
;-----------------------------------------------------------------------------
print "^/--- 14. Probing `take` on BINARY (including type checks) ---"

; Test basic take on binary (integer! result)
print "^/-- Basic take on binary (integer! result) --"
data-bin-type1: #{010203}
expected-int-res: 1 ; First byte as integer
expected-bin-after1: #{0203}
actual-int-res: take data-bin-type1
assert "Basic take on binary: Result value" actual-int-res expected-int-res
assert "Basic take on binary: Result type is integer!" (integer? actual-int-res) true
assert "Basic take on binary: Data after" data-bin-type1 expected-bin-after1

; Test take/part on binary (binary! result) - already covered by section 10, but good to have here too for consolidation
print "^/-- take/part binary 1 (binary! result) --"
data-bin-type2: #{0A0B0C}
expected-bin-part-res: #{0A}
expected-bin-after2: #{0B0C}
actual-bin-part-res: take/part data-bin-type2 1
assert "take/part binary 1: Result value" actual-bin-part-res expected-bin-part-res
assert "take/part binary 1: Result type is binary!" (binary? actual-bin-part-res) true
assert "take/part binary 1: Data after" data-bin-type2 expected-bin-after2

; Test take/last on binary (integer! result)
print "^/-- take/last on binary (integer! result) --"
data-bin-type3: #{F1F2F3}
expected-int-last-res: 243 ; Last byte F3 as integer (15*16 + 3)
expected-bin-after3: #{F1F2}
actual-int-last-res: take/last data-bin-type3
assert "take/last on binary: Result value" actual-int-last-res expected-int-last-res
assert "take/last on binary: Result type is integer!" (integer? actual-int-last-res) true
assert "take/last on binary: Data after" data-bin-type3 expected-bin-after3
print ""

print "--- End of Diagnostic Probe ---"
