REBOL [
    Title: "TAKE - Practical Usage Examples (Fully Corrected)"
    Purpose: {Real-world applications of TAKE function with verified behavior}
]

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    either equal? expected actual [
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL PRACTICAL EXAMPLES PASSED"
    ][
        print "❌ SOME PRACTICAL EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Corrected Practical Examples
;;-----------------------------------------------------------------------------
print "===== STARTING CORRECTED PRACTICAL EXAMPLES ====="

; Example 1: Message Queue Processing
print "^/=== Example 1: Message Queue Processing ==="
queue: ["msg1" "msg2" "msg3"]
processed: copy []
while [not empty? queue][
    msg: take queue
    append processed msg
    print ["Processing:" msg]
]
assert-equal ["msg1" "msg2" "msg3"] processed "Should process all messages"
assert-equal [] queue "Queue should be empty after processing"

; Example 2: Stack implementation (LIFO)
print "^/=== Example 2: Stack Implementation (Corrected) ==="
stack: []
push: func [item][insert/only tail stack item]
pop: func [][take/last stack]

push "data1"
push "data2"
popped: pop
print ["Popped:" popped]
assert-equal "data2" popped "Should pop last item first (LIFO)"
assert-equal ["data1"] stack "Stack should have first item remaining"

; Example 3: Safe take with default
print "^/=== Example 3: Safe Take with Default ==="
safe-take: func [series][
    either empty? series [none][take series]
]
result1: safe-take [only-item]
result2: safe-take []
print ["Safe take from populated:" result1]
print ["Safe take from empty:" result2]
assert-equal 'only-item result1 "Should take item from populated series"
assert-equal none result2 "Should return none for empty series"

; Example 4: Data Header Extraction
print "^/=== Example 4: Data Header Extraction (Corrected) ==="
data: copy "Header: metadata^/Body: content"
header-end: find data newline
header: take/part data header-end
take data  ; Remove the newline character
print ["Header:" mold header]
print ["Body:" mold data]
assert-equal "Header: metadata" header "Should extract header"
assert-equal "Body: content" data "Should leave clean body content"

; Example 5: Password masking
print "^/=== Example 5: Password Masking ==="
password: "secret"
masked: copy ""
loop length? password [append masked "*" take password]
print ["Masked password:" masked]
assert-equal "******" masked "Should create masked string"
assert-equal "" password "Password should be cleared"

; Example 6: Process data in chunks
print "^/=== Example 6: Chunk Processing ==="
data-block: array/initial 15 [random 100]
chunk-size: 5
processed-chunks: 0
while [not empty? data-block][
    chunk: take/part data-block chunk-size
    processed-chunks: processed-chunks + 1
    print ["Processing chunk:" processed-chunks "Size:" length? chunk]
]
assert-equal 3 processed-chunks "Should process 3 chunks (5+5+5)"
assert-equal [] data-block "Data block should be empty"

; Example 7: Rotate list items
print "^/=== Example 7: List Rotation ==="
list: [A B C D]
rotate: func [series][append series take series]
print ["Original:" mold list]
rotate list
print ["After rotation:" mold list]
assert-equal [B C D A] list "Should rotate first item to end"

; Example 8: Extract nested configuration - Fixed test expectation
print "^/=== Example 8: Nested Config Extraction (Corrected) ==="
config: [prefs [colors [red green] size 10]]
; Find the 'colors position in the nested block
colors-pos: find config/2 'colors
; Take the 'colors word itself
take colors-pos
; Now take the color block that follows
colors: take/deep colors-pos
print ["Color preferences:" mold colors]
print ["Config now:" mold config]
assert-equal [red green] colors "Should extract nested color preferences"
; CORRECTED EXPECTATION: The nested block remains but without colors
assert-equal [prefs [size 10]] config "Config should have colors removed"

; Example 9: Paired data processing
print "^/=== Example 9: Paired Data Processing ==="
pairs: [name "John" age 30 city "Boston"]
extract-pairs: func [blk][
    result: copy []
    while [not empty? blk][
        append result reduce [take blk take blk]
    ]
    result
]
result: extract-pairs pairs
print ["Extracted pairs:" mold result]
assert-equal [name "John" age 30 city "Boston"] result "Should extract all pairs"
assert-equal [] pairs "Original series should be empty"

; Example 10: Efficient buffer processing
print "^/=== Example 10: Buffer Processing ==="
buffer: make string! 1000
append buffer "Header: data payload"
colon-pos: find buffer ":"
header: take/part buffer colon-pos
take buffer  ; Remove the colon
print ["Header:" header]
print ["Remaining:" buffer]
assert-equal "Header" header "Should extract header"
assert-equal " data payload" buffer "Should leave payload"

;;-----------------------------------------------------------------------------
;; Test Summary
;;-----------------------------------------------------------------------------
print-test-summary
