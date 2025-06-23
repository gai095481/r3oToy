REBOL [
    Title: "2. `take` - Highly Useful and Practical Examples"
    Date: 22-Jun-2025
    Purpose: "To showcase practical examples of `take` using the standard QA framework."
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
        print "✅ ALL `take` EXAMPLES PASSED"
    ][
        print "❌ SOME `take` EXAMPLES FAILED"
    ]
    print "============================================^/"
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
print ["^/Assertion:" either all assert ["✅ PASSED"]["❌FAILED"]]


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
print ["^/Assertion:" either all assert ["✅ PASSED"]["❌FAILED"]]


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
print ["^/Assertion:" either all assert ["✅ PASSED"]["❌FAILED"]]


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
print ["^/Assertion:" either all assert ["✅ PASSED"]["❌FAILED"]]


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
print ["^/Assertion:" either all assert ["✅ PASSED"]["❌FAILED"]]


print "=== `take` Function: Highly Useful and Practical Examples ==="

;-----------------------------------------------------------------------------
print "^/--- Example 1: Processing a Queue (First-In, First-Out) ---"
;-----------------------------------------------------------------------------
task-queue: [ "Print report" "Send email" "Backup database" ]
while [not empty? task-queue] [ take task-queue ]
assert-equal true empty? task-queue "Queue Processing: Queue should be empty after processing."


;-----------------------------------------------------------------------------
print "^/--- Example 2: Processing a Stack (Last-In, First-Out) ---"
;-----------------------------------------------------------------------------
history-stack: [ "page1.html" "page2.html" "page3.html" ]
last-page: take/last history-stack
assert-equal "page3.html" last-page "Stack Processing: Correct page is taken."
assert-equal ["page1.html" "page2.html"] history-stack "Stack Processing: Stack is modified correctly."


;-----------------------------------------------------------------------------
print "^/--- Example 3: Parsing Command-Line Arguments ---"
;-----------------------------------------------------------------------------
args: [ "--port" "8080" "--mode" "verbose" ]
port: none
mode: none
while [not empty? args] [
    switch take args [
        "--port" [ port: to-integer take args ]
        "--mode" [ mode: take args ]
    ]
]
assert-equal 8080 port "Argument Parsing: Port is set correctly."
assert-equal "verbose" mode "Argument Parsing: Mode is set correctly."


;-----------------------------------------------------------------------------
print "^/--- Example 4: Dealing a Hand of Cards ---"
;-----------------------------------------------------------------------------
deck: [ "A" "K" "Q" "J" "10" "9" "8" "7" ]
hand: take/part deck 5
assert-equal ["A" "K" "Q" "J" "10"] hand "Card Dealing: Hand is correct."
assert-equal ["9" "8" "7"] deck "Card Dealing: Deck is correct."


;-----------------------------------------------------------------------------
print "^/--- Example 5: Splitting a String at a Delimiter ---"
;-----------------------------------------------------------------------------
log-entry: "INFO: User 'admin' logged in."
delimiter-pos: find log-entry ":"
prefix: take/part log-entry delimiter-pos
take log-entry ; Consume the colon
message: trim/head log-entry
assert-equal "INFO" prefix "String Splitting: Prefix is correct."
assert-equal "User 'admin' logged in." message "String Splitting: Message is correct."


;-----------------------------------------------------------------------------
print "^/--- Example 6: Reading a File in Chunks ---"
;-----------------------------------------------------------------------------
file-content: "Line 1^/Line 2^/"
chunk1: take/part file-content 7
chunk2: take/part file-content 7
assert-equal "Line 1^/" chunk1 "Chunking: First chunk is correct."
assert-equal true empty? file-content "Chunking: Original content is empty after processing."


;-----------------------------------------------------------------------------
print "^/--- Example 7: Moving an Item from One List to Another ---"
;-----------------------------------------------------------------------------
todo: [ "Task A" "Task B" "Task C" ]
done: []
append done take todo
assert-equal ["Task A"] done "Item Moving: `done` list is correct."
assert-equal ["Task B" "Task C"] todo "Item Moving: `todo` list is correct."


;-----------------------------------------------------------------------------
print "^/--- Example 8: Extracting a Header from a Data Block ---"
;-----------------------------------------------------------------------------
packet: [ version: 1 protocol: 'tcp "Some data..." ]

; FIX: A key-value pair consists of 2 elements. To take 2 pairs, we need to take 4 elements.
header: take/part packet 4
payload: packet
assert-equal [version: 1 protocol: 'tcp] header "Header Extraction: Header is correct."
assert-equal ["Some data..."] payload "Header Extraction: Payload is correct."


;-----------------------------------------------------------------------------
print "^/--- Example 9: Creating a Temporary, Destructive Copy ---"
;-----------------------------------------------------------------------------
original-data: ["a" "b" "c"]
temp-copy: take/all original-data
assert-equal ["a" "b" "c"] temp-copy "Destructive Copy: The copy contains all original elements."
assert-equal true empty? original-data "Destructive Copy: The original is empty."


;-----------------------------------------------------------------------------
print "^/--- Example 10: Removing and Returning the Rest of a Series ---"
;-----------------------------------------------------------------------------
data: [ a b c d e f ]
position: find data 'd
rest-of-series: take/all position
assert-equal [d e f] rest-of-series "Take Rest: The correct rest-of-series is returned."
assert-equal [a b c] data "Take Rest: The original data is correctly modified."


print-test-summary
