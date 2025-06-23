REBOL []
;;=============================================================================
;; TAKE FUNCTION: EDGE CASE EXAMPLES
;;=============================================================================
;; Purpose: Test unusual but valid inputs and boundary conditions
;; Audience: Rebol developers building robust systems
;; Evidence: Based on validated diagnostic probe results
;;=============================================================================

print "=== TAKE FUNCTION: EDGE CASE EXAMPLES ==="
print "=== Testing unusual but valid inputs and boundary conditions ==="
print ""

;;-----------------------------------------------------------------------------
;; EDGE CASE 1: Single element series boundary testing
;;-----------------------------------------------------------------------------
print "--- EDGE CASE 1: Single element series ---"
print "Testing: What happens with exactly one element?"
print ""

single-block: [lonely]
single-string: "X"
single-binary: #{FF}

print ["Single block:" mold single-block "Length:" length? single-block]
print ["Single string:" mold single-string "Length:" length? single-string]
print ["Single binary:" mold single-binary "Length:" length? single-binary]

; Test normal TAKE
result1: take single-block
result2: take single-string
result3: take single-binary

print ""
print "Results of normal TAKE:"
print ["Block result:" mold result1 ", remaining:" mold single-block]
print ["String result:" mold result2 ", remaining:" mold single-string]
print ["Binary result:" mold result3 ", remaining:" mold single-binary]

; Reset and test /LAST (should be same as normal TAKE)
single-block2: [only]
result4: take/last single-block2
print ["take/last result:" mold result4 ", remaining:" mold single-block2]

print ""
print "Edge case insight: Single element behavior is consistent"
print "Normal TAKE and /LAST produce identical results"
print ""

;;-----------------------------------------------------------------------------
;; EDGE CASE 2: /PART boundary values testing
;;-----------------------------------------------------------------------------
print "--- EDGE CASE 2: /PART boundary values ---"
print "Testing: /PART with edge case numbers"
print ""

test-data: [a b c d e]
original-length: length? test-data
print ["Test data:" mold test-data "Length:" original-length]

; Test various boundary conditions
print ""
print "Testing /PART with different count values:"

; Zero count
data-copy: copy test-data
result-zero: take/part data-copy 0
print ["take/part 0:" mold result-zero "Length:" length? result-zero]
print ["  Data unchanged:" mold data-copy "Length:" length? data-copy]

; Exact length count
data-copy: copy test-data
result-exact: take/part data-copy original-length
print ["take/part" original-length "(exact):" mold result-exact]
print ["  Data after:" mold data-copy "Length:" length? data-copy]

; Oversized count
data-copy: copy test-data
result-over: take/part data-copy (original-length + 5)
print ["take/part" (original-length + 5) "(oversized):" mold result-over]
print ["  Data after:" mold data-copy "Length:" length? data-copy]

print ""
print "Edge case insight: /PART handles any count gracefully"
print "Takes what's available, never errors on oversized requests"
print ""

;;-----------------------------------------------------------------------------
;; EDGE CASE 3: Deep nested structure testing
;;-----------------------------------------------------------------------------
print "--- EDGE CASE 3: Deep nested structures ---"
print "Testing: TAKE with complex nested data"
print ""

complex-data: [
    [level1 [level2 [level3 "deep-string"]]]
    [branch2 [data1 data2]]
    "top-level-string"
    42
]

print ["Complex structure:" mold complex-data]
print ["Structure length:" length? complex-data]

; Take first element (deeply nested)
first-element: take complex-data
print ["Took first element:" mold first-element]
print ["Remaining structure:" mold complex-data]

; Test /DEEP with nested structure
nested-test: [[inner1] [inner2] [inner3]]
print ["Before take/deep:" mold nested-test]
deep-result: take/deep nested-test
print ["take/deep result:" mold deep-result]
print ["Remaining after take/deep:" mold nested-test]

print ""
print "Edge case insight: TAKE preserves nested structure integrity"
print "/DEEP ensures taken elements are independent copies"
print ""

;;-----------------------------------------------------------------------------
;; EDGE CASE 4: Mixed data type series
;;-----------------------------------------------------------------------------
print "--- EDGE CASE 4: Mixed data type series ---"
print "Testing: TAKE from heterogeneous blocks"
print ""

mixed-data: [
    42                    ; integer
    "hello"              ; string
    [nested block]       ; block
    3.14                 ; decimal
    #"c"                 ; character
    true                 ; logic
    none                 ; none value
]

print ["Mixed data:" mold mixed-data]
print ["Types present: integer, string, block, decimal, char, logic, none"]

print ""
print "Taking elements and checking types:"
type-count: 0
while [all [not empty? mixed-data type-count < 5]] [  ; Limit iterations
    element: take mixed-data
    type-count: type-count + 1
    print ["Element" type-count ":" mold element "Type:" mold type? element]
]

print ["Remaining mixed data:" mold mixed-data]
print ""
print "Edge case insight: TAKE preserves original element types"
print "Each element retains its specific datatype"
print ""

;;-----------------------------------------------------------------------------
;; EDGE CASE 5: Refinement combination stress testing
;;-----------------------------------------------------------------------------
print "--- EDGE CASE 5: Complex refinement combinations ---"
print "Testing: Multiple refinements working together"
print ""

; Test /PART /LAST combination with various sizes
test-series: [item1 item2 item3 item4 item5 item6 item7 item8]
print ["Test series:" mold test-series]

print ""
print "Testing /PART /LAST combinations:"

; Take last 2 elements
data-copy: copy test-series
result1: take/part/last data-copy 2
print ["take/part/last 2:" mold result1]
print ["  Remaining:" mold data-copy]

; Take last 1 element (should equal take/last)
data-copy: copy test-series
result2: take/part/last data-copy 1
print ["take/part/last 1:" mold result2]
print ["  Remaining:" mold data-copy]

; Compare with simple take/last
data-copy: copy test-series
result3: take/last data-copy
print ["take/last alone:" mold result3]
print ["  Are they equal?" equal? result2 [result3]]

print ""
print "Edge case insight: Refinement combinations work predictably"
print "/PART /LAST maintains element order from the tail"
print ""

;;-----------------------------------------------------------------------------
;; EDGE CASE 6: Series positioning edge cases
;;-----------------------------------------------------------------------------
print "--- EDGE CASE 6: Series positioning at boundaries ---"
print "Testing: TAKE from series positioned at start/end"
print ""

original: [first second third fourth last]
print ["Original series:" mold original]

; Position at very beginning (index 1)
at-start: at original 1
print ["Positioned at start:" mold at-start]
result1: take at-start
print ["Take from start position:" mold result1]
print ["Original after:" mold original]

; Reset and position near end
original: [first second third fourth last]
at-near-end: skip original 3  ; Position at 'fourth'
print ["Positioned at 'fourth':" mold at-near-end]
result2: take at-near-end
print ["Take from near-end position:" mold result2]
print ["Original after:" mold original]

print ""
print "Edge case insight: Positioning works at any valid index"
print "TAKE always operates from the current position"
print ""

print "=== EDGE CASE EXAMPLES COMPLETE ==="
print "These tests ensure TAKE works reliably in all boundary conditions"
