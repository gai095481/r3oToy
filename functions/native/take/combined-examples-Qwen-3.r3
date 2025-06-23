REBOL []

; Diagnostic Probe Script for 'take' function
; Target: REBOL/Bulk 3.19.0 (Oldes Branch)
; This script validates actual behavior including unique Oldes branch deviations

check-result: func [actual expected msg] [
    either equal? actual expected [
        print ["✅ PASSED:" msg]
    ] [
        print ["❌ FAILED:" msg]
        print ["  Expected:" mold expected]
        print ["  Actual:" mold actual]
    ]
]

print "=== 1. Basic TAKE Behavior ==="

; Test 1.1: Block series
blk: [a b c]
result: take blk
check-result result 'a "Basic TAKE - Block: removed element"
check-result blk [b c] "Basic TAKE - Block: remaining elements"

; Test 1.2: String series
str: "hello"
result: take str
check-result result #"h" "Basic TAKE - String: removed element"
check-result str "ello" "Basic TAKE - String: remaining elements"

; Test 1.3: Binary series
bin: #{010203}
result: take bin
check-result result 1 "Basic TAKE - Binary: removed element (integer byte)"
check-result bin #{0203} "Basic TAKE - Binary: remaining elements"

print "^=== 2. Refinement Testing ==="

; Test 2.1: /last refinement
blk2: [a b c]
result: take/last blk2
check-result result 'c "/last refinement: removed element"
check-result blk2 [a b] "/last refinement: remaining elements"

; Test 2.2: /all refinement
blk3: [x y z]
result: take/all blk3
check-result result [x y z] "/all refinement: removed elements"
check-result blk3 [] "/all refinement: remaining elements"

print "^=== 3. Specialized Behavior Testing ==="

; Test 3.1: /deep refinement (corrected for Oldes behavior)
nested: [[a [b c]] [d [e f]]]
taken: take/deep nested
check-result taken [a [b c]] "/deep refinement: returned block instead of word"
check-result type? taken #(block!) "/deep refinement: datatype verification"
check-result nested [[d [e f]]] "/deep refinement: original preserved"
print "Note: /deep in Oldes branch returns first block element rather than flattening"

print "^=== 4. Edge Case Testing ==="

; Test 4.1: Empty block
empty-blk: []
result: error? try [take empty-blk]
check-result result false "Empty block handling"
print "Note: TAKE on empty block does not throw error in Oldes branch"

; Test 4.2: NONE input
result: error? try [take none]
check-result result false "NONE input handling"
print "Note: TAKE on NONE does not throw error in Oldes branch"

; Test 4.3: Taking beyond length
blk6: [a b]
result: take/part blk6 5
check-result result [a b] "Taking beyond length"
check-result blk6 [] "Taking beyond length: emptied"

print "^=== 5. Series Position Effects ==="

; Test 5.1: Mid-position block
blk7: [first second third]
blk7: next blk7 ; Position at 2nd element
result: take blk7
check-result result 'second "Mid-position take"
check-result blk7 [third] "Mid-position remaining"

; Test 5.2: Tail position
blk8: [x y z]
blk8: tail blk8
result: error? try [take blk8]
check-result result false "Tail position handling"
print "Note: TAKE from tail position does not throw error in Oldes branch"

