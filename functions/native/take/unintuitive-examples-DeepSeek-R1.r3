REBOL [
    Title: "TAKE - Unintuitive Behavior Examples (Corrected)"
    Purpose: {Documents surprising edge cases and quirks of TAKE function}
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
        print "✅ ALL UNINTUITIVE BEHAVIORS DOCUMENTED"
    ][
        print "❌ SOME DOCUMENTATION TESTS FAILED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Corrected Unintuitive Behavior Examples
;;-----------------------------------------------------------------------------
print "===== STARTING UNINTUITIVE BEHAVIOR DOCUMENTATION ====="

; Quirk 1: String returns CHAR! not STRING!
print "^/=== Quirk 1: String Handling ==="
str: "Hello"
taken: take str
print ["Taken value type:" type? taken]
print ["Value:" mold taken]
; Fixed: Compare the word representation of the type
assert-equal 'char! to word! type? taken "Should return char! for string take"
assert-equal #"H" taken "First character should be #H"

; Quirk 2: /part with series position takes to BEFORE marker
print "^/=== Quirk 2: /PART Marker Position ==="
text: "documentation"
mark: find text "c"  ; Position at "cumentation"
result: take/part text mark
print ["Result:" mold result]
print ["Remaining:" mold text]
assert-equal "do" result "Should take to BEFORE marker (not including 'c')"
assert-equal "cumentation" text "Should leave from marker position"

; Quirk 3: Path access breaks after nested removal
print "^/=== Quirk 3: Nested Block Path Instability ==="
blk: [1 [2 3] 4]
take blk        ; remove 1
take blk        ; remove [2 3]
print ["Block now:" mold blk]  ; [4]
print "Attempting blk/1/1 would now fail - structure changed"
assert-equal [4] blk "Nested block removal changes structure"
assert-equal 4 blk/1 "First element is now 4"

; Quirk 4: /deep creates independent copies
print "^/=== Quirk 4: /DEEP Copy Semantics ==="
original: [1 [2 3]]
nested-ref: original/2
taken: take/deep next original  ; Take nested block
taken/1: "modified"
print ["Original nested:" mold nested-ref]
print ["Taken copy:" mold taken]
assert-equal [2 3] nested-ref "Original nested block unchanged"
assert-equal ["modified" 3] taken "Modification only affects copy"

; Quirk 5: View positions update original
print "^/=== Quirk 5: Series View Awareness ==="
data: [1 2 3 4]
view: next data  ; [2 3 4]
take view        ; removes 2
print ["Original after view take:" mold data]
assert-equal [1 3 4] data "Original modified through view"

; Quirk 6: /all on empty string
print "^/=== Quirk 6: /ALL with Empty Series ==="
empty-str: ""
result: take/all empty-str
print ["Result:" mold result]
print ["Type:" type? result]
assert-equal "" result "Should return empty string, not none"
; Fixed: Compare the word representation of the type
assert-equal 'string! to word! type? result "Should maintain string type"

; Quirk 7: Taking none returns none
print "^/=== Quirk 7: Taking None ==="
result: take none
print ["Result:" mold result]
assert-equal none result "Take none returns none (no error)"

; Quirk 8: Over-length take returns available elements
print "^/=== Quirk 8: Over-length Take ==="
blk: [single]
result: take/part blk 3
print ["Result:" mold result]
assert-equal [single] result "Should return available elements"

;;-----------------------------------------------------------------------------
;; Test Summary
;;-----------------------------------------------------------------------------
print-test-summary
