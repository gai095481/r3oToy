REBOL [
    Title: "TAKE Function - Highly Useful and Practical Examples"
    Date: now/date
    Author: "Jules (AI Agent)"
    Purpose: {
        Showcases practical, real-world examples of how the TAKE function
        can be used to solve common programming problems in Rebol.
        These examples aim to demonstrate TAKE's versatility.
        Each example is verified using the assert-equal test harness.
    }
    File: %take_highly_useful_examples.r
    Version: 1.0.0
    License: Public Domain
]

;-----------------------------------------------------------------------------
; A Battle-Tested QA Harness (Provided by User)
;-----------------------------------------------------------------------------
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
        print "✅ ALL `take` HIGHLY USEFUL EXAMPLES PASSED"
    ][
        print "❌ SOME `take` HIGHLY USEFUL EXAMPLES FAILED"
    ]
    print "============================================^/"
]

; Initial placeholder print
print "Starting Highly Useful and Practical Examples for TAKE function..."
print newline

; --- Example 1: Processing a FIFO Queue ---
print "--- Example 1: Processing a FIFO Queue (First-In, First-Out) ---"
; `take` is ideal for processing items from a list one by one from the beginning.
; This effectively treats the block as a queue.
task-queue: copy ["Task A" "Task B" "Task C"]
processed-tasks: copy []
original-queue-mold: mold task-queue

while [not empty? task-queue] [
    current-task: take task-queue
    append processed-tasks join "Processed: " current-task
    ; In a real scenario, you'd perform an action with current-task
]

expected-processed-tasks: ["Processed: Task A" "Processed: Task B" "Processed: Task C"]
assert-equal expected-processed-tasks processed-tasks "Processing a FIFO queue - accumulated results"
assert-equal [] task-queue "Processing a FIFO queue - queue should be empty"
print ["Original queue: " original-queue-mold " -> Processed: " mold processed-tasks "^/"]

; --- Example 2: Parsing Command Line Arguments (Simple) ---
print "--- Example 2: Parsing Command Line Arguments (Simple) ---"
; `take` can be used to iteratively consume arguments from a list,
; such as a simplified version of command-line arguments.
; Note: Real command-line parsing might involve `parse` for more complex scenarios.
args-list: copy ["--input" "file.txt" "--verbose" "--output" "out.log"]
original-args-mold: mold args-list

input-file: none
verbose-mode: false
output-file: none

while [not empty? args-list] [
    arg: take args-list
    case [
        arg = "--input" [
            input-file: take args-list ; Take the next item as the filename
        ]
        arg = "--verbose" [
            verbose-mode: true
        ]
        arg = "--output" [
            output-file: take args-list ; Take the next item as the filename
        ]
        ; default (value is ignored if not a recognized switch)
    ]
]

assert-equal "file.txt" input-file "Parsing CLI args - input file"
assert-equal true verbose-mode "Parsing CLI args - verbose mode"
assert-equal "out.log" output-file "Parsing CLI args - output file"
assert-equal [] args-list "Parsing CLI args - args list should be empty"
print ["Original args: " original-args-mold
       " -> Parsed: input=" input-file ", verbose=" verbose-mode ", output=" output-file "^/"]

; --- Example 3: Extracting a Prefix from a String using a Delimiter ---
print "--- Example 3: Extracting a Prefix from a String using a Delimiter ---"
; `take/part` can be combined with `find` to extract a portion of a string
; up to a specific delimiter. The delimiter itself is not part of the taken string.
path-string: copy "/usr/local/bin/script.r"
original-path-mold: mold path-string
prefix: none
filename-part: copy path-string ; if no delimiter, filename is whole string

delimiter-pos: find/last path-string #"/" ; find last /
if delimiter-pos [
    ; We need to take up to the character *after* the delimiter to get the path
    ; but for the prefix, we take up to the delimiter itself.
    ; For `take/part`, if `delimiter-pos` is `at path-string 1` (delimiter is first char),
    ; taking up to `delimiter-pos` results in an empty string.
    ; If we want the path (prefix), we take up to the delimiter.
    ; The `take` operation modifies `path-string` to be the part *after* the taken prefix.

    temp-path-string: copy path-string
    prefix-end: find/last temp-path-string #"/"

    prefix: take/part temp-path-string prefix-end ; Takes up to (but not including) the delimiter position

    ; After taking the prefix, what remains in temp-path-string is the delimiter + filename.
    ; We need to take the delimiter itself to isolate the filename.
    if (first temp-path-string) = #"/" [
        take temp-path-string ; remove the leading slash if present
    ]
    filename-part: temp-path-string
]

assert-equal "/usr/local/bin" prefix "Extracting prefix - path part"
assert-equal "script.r" filename-part "Extracting prefix - filename part"
assert-equal "/usr/local/bin/script.r" path-string "Extracting prefix - original string unchanged for this logic"
; Note: the original path-string was not used with 'take' in this example's logic for prefix/filename extraction,
; rather, a copy (temp-path-string) was used. This is a common pattern to preserve the original if needed.
; If we had used 'take' on path-string directly, it would be modified.
print ["Original path: " original-path-mold " -> Prefix: " mold prefix ", Filename: " mold filename-part "^/"]

; --- Example 4: Getting the Last Item from a Log (LIFO Stack) ---
print "--- Example 4: Getting the Last Item from a Log (LIFO Stack) ---"
; `take/last` is perfect for LIFO (Last-In, First-Out) stack behavior,
; like retrieving the most recent entry from a log.
event-log: copy ["Event Alpha" "Event Beta" "Event Gamma"]
original-log-mold: mold event-log

most-recent-event: take/last event-log

assert-equal "Event Gamma" most-recent-event "LIFO log - most recent event"
assert-equal ["Event Alpha" "Event Beta"] event-log "LIFO log - log after taking last"
print ["Original log: " original-log-mold " -> Last event: " mold most-recent-event ", Remaining log: " mold event-log "^/"]

; --- Example 5: Splitting a String by the First Delimiter ---
print "--- Example 5: Splitting a String by the First Delimiter ---"
; Use `find` to locate the first occurrence of a delimiter, then `take/part`
; to extract the segment before it. The original string is modified to hold the remainder.
key-value-str: copy "user_id=12345"
original-kv-mold: mold key-value-str
key-part: ""
value-part: ""

delimiter-char: #"="
delimiter-pos: find key-value-str delimiter-char

either delimiter-pos [
    key-part: take/part key-value-str delimiter-pos ; Takes up to the delimiter
    take key-value-str ; Removes the delimiter itself from the modified string
    value-part: copy key-value-str ; What remains is the value (copy it for assertion)
    clear key-value-str ; ensure original is empty after value is "moved"
][
    key-part: take/all key-value-str ; No delimiter, so the whole string is the key, consume it
    value-part: "" ; No value part
]

assert-equal "user_id" key-part "Splitting string - key part"
assert-equal "12345" value-part "Splitting string - value part"
assert-equal "" key-value-str "Splitting string - original str should be empty"
print ["Original key-value: " original-kv-mold " -> Key: " mold key-part ", Value: " mold value-part "^/"]


; Example with no delimiter found
no-delimiter-str: copy "justkey"
original-nd-mold: mold no-delimiter-str
key-only: ""
value-only: ""
delimiter_pos_nd: find no-delimiter-str delimiter-char

either delimiter_pos_nd [
    key-only: take/part no-delimiter-str delimiter_pos_nd
    take no-delimiter-str ; remove delimiter
    value-only: copy no-delimiter-str
    clear no-delimiter-str
][
    key-only: take/all no-delimiter-str ; take the whole string as key
    value-only: "" ; Value part is empty, original string is now empty via take/all
]
assert-equal "justkey" key-only "Splitting string (no delimiter) - key part"
assert-equal "" value-only "Splitting string (no delimiter) - value part (empty)"
assert-equal "" no-delimiter-str "Splitting string (no delimiter) - original str should be empty"
print ["Original no-delimiter: " original-nd-mold " -> Key: " mold key-only ", Value: " mold value-only "^/"]

; --- Example 6: Taking a Fixed-Size Chunk from a Binary Series ---
print "--- Example 6: Taking a Fixed-Size Chunk from a Binary Series ---"
; `take/part` is useful for reading fixed-size chunks from binary data,
; like a packet header or a record.
binary-data: copy #{0102030405060708} ; 8 bytes of data
original-binary-mold: mold binary-data
chunk-size: 4 ; e.g., a 4-byte header

header-chunk: take/part binary-data chunk-size
remaining-data: copy binary-data

expected-header: #{01020304}
expected-remaining: #{05060708}

assert-equal expected-header header-chunk "Binary chunk - taken header"
assert-equal expected-remaining remaining-data "Binary chunk - remaining data"
print ["Original binary: " original-binary-mold
       " -> Header: " mold header-chunk ", Remaining: " mold remaining-data "^/"]

; --- Example 7: Using `take` in a Conditional `while` Loop ---
print "--- Example 7: Using `take` in a Conditional `while` Loop ---"
; `take` can be the core of a loop that processes a series until it's empty.
; `while [not empty? series]` or `while [value: take series]` are common.
; Here, we sum numbers from a block.
numbers-to-sum: copy [10 20 30 5 5]
original-numbers-mold: mold numbers-to-sum
total-sum: 0
value: none ; to ensure it's new in loop if that matters

; Loop while there are items to take. `take` returns `none` if series is empty,
; which evaluates as false in `while`'s condition block.
while [value: take numbers-to-sum] [
    total-sum: total-sum + value
]

assert-equal 70 total-sum "Conditional while loop - sum of numbers"
assert-equal [] numbers-to-sum "Conditional while loop - numbers block should be empty"
print ["Original numbers: " original-numbers-mold " -> Sum: " total-sum ", Remaining block: " mold numbers-to-sum "^/"]

; --- Example 8: Taking Elements to Form Pairs ---
print "--- Example 8: Taking Elements to Form Pairs ---"
; `take` can be used multiple times in a loop to extract structured data, like key-value pairs.
flat-data: copy ['name "Alice" 'age 30 'city "Wonderland"]
original-flat-data-mold: mold flat-data
paired-data: copy []

while [(length? flat-data) >= 2] [ ; Ensure there are at least two items to take
    key: take flat-data
    value: take flat-data
    append paired-data reduce [key value]
    ; or `append/only paired-data reduce [key value]` if you want a block of blocks
    ; or directly construct a map: `paired-data/(key): value` if key is word/string
]

expected-pairs: ['name "Alice" 'age 30 'city "Wonderland"]
; In this case, `append reduce` flattens it back. If we wanted blocks of pairs:
; expected-pairs-block-of-blocks: [['name "Alice"] ['age 30] ['city "Wonderland"]]
; For map: expected-map: make map! ['name "Alice" 'age 30 'city "Wonderland"]

assert-equal expected-pairs paired-data "Forming pairs - collected pairs"
assert-equal [] flat-data "Forming pairs - flat data block should be empty"
print ["Original flat data: " original-flat-data-mold " -> Paired data: " mold paired-data "^/"]

; --- Example 9: `take/part` with `length?` for Full Copy and Clear ---
print "--- Example 9: `take/part` with `length?` for Full Copy and Clear ---"
; You can use `take/part series (length? series)` to get a copy of the entire series,
; which also has the side effect of emptying the original series.
; This is an alternative to `take/all` or `new-series: copy old-series clear old-series`.
source-block: copy [x y z 1 2 3]
original-source-mold: mold source-block

full-copy: take/part source-block (length? source-block)

assert-equal [x y z 1 2 3] full-copy "take/part with length? - full copy"
assert-equal [] source-block "take/part with length? - original block emptied"
print ["Original block: " original-source-mold
       " -> Full copy taken: " mold full-copy
       ", Original now: " mold source-block "^/"]

; --- Example 10: Chaining `take` with other functions ---
print "--- Example 10: Chaining `take` with other functions ---"
; `take` returns a value, which can be immediately used by another function.
; This makes it useful in expressions.
words-list: copy ["rebol" "script" "language"]
original-words-mold: mold words-list

; Take the first word and uppercase it immediately
first-word-upped: uppercase take words-list

assert-equal "REBOL" first-word-upped "Chaining take - uppercased first word"
assert-equal ["script" "language"] words-list "Chaining take - modified words list"
print ["Original words: " original-words-mold
       " -> Uppercased taken word: " first-word-upped
       ", Remaining: " mold words-list "^/"]

; Another example: take a number and perform arithmetic
num-list: copy [100 25 5]
original-nums-mold: mold num-list
; To achieve 100 - (25 / 5), we need to manage Rebol's left-to-right evaluation
; by ensuring the division happens before the subtraction in the expression.
; val1: take num-list ; 100
; val2: take num-list ; 25
; val3: take num-list ; 5
; result-val: val1 - (val2 / val3)
; Or directly in the expression with parentheses:
result-val: (take num-list) - ((take num-list) / (take num-list))

assert-equal 95 result-val "Chaining take - arithmetic operations"
assert-equal [] num-list "Chaining take - num-list should be empty"
print ["Original nums: " original-nums-mold
       " -> Arithmetic result: " result-val
       ", Remaining: " mold num-list "^/"]

; --- Final Summary ---
print-test-summary
