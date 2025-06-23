REBOL [
    Title: "3. `take` - Unintuitive Function Behavior (Corrected)"
    Date: 22-Jun-2025
    Purpose: "To correctly document the unintuitive behavior of `take/deep`."
]

;-----------------------------------------------------------------------------
;;; Battle-Tested QA Harness
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
        print "✅ ALL `take` UNINTUITIVE TESTS PASSED"
    ][
        print "❌ SOME `take` UNINTUITIVE TESTS FAILED"
    ]
    print "============================================^/"
]

print "--- `take` Function: Unintuitive Behavior Examples ---"

;-----------------------------------------------------------------------------
print "^/--- Quirk 1: The Nuance of `/deep` ---"
;-----------------------------------------------------------------------------
print {
The most unintuitive part of `take` is the `/deep` refinement.
It only affects the VALUE that is RETURNED by `take`.

The Rule of `/deep`:
  - A normal `take` performs a SHALLOW copy. If you take a block that
    contains another series, the returned value remains linked to the
    original source of that series.
  - `take/deep` performs a DEEP copy. The returned value is a brand new,
    independent copy with no links to any other data.
}


; --- Demonstration of Shallow Take (Default) ---
print "^/-- 1. Shallow `take` (Default) --"
; We create a handle to the nested block BEFORE we take it.
original-data: [a [x y] b]
handle-to-nested-block: second original-data
print ["Original data:" mold original-data]
print ["Handle points to:" mold handle-to-nested-block]

; Now, we take the element. The `taken-shallow` variable now holds [x y].
taken-shallow: take next original-data
print ["Item taken:" mold taken-shallow]

print "Modifying the `taken-shallow` result..."
append taken-shallow 'Z

print ["Modified `taken-shallow`:" mold taken-shallow]
print ["Value of our original handle:" mold handle-to-nested-block]
assert-equal [x y Z] handle-to-nested-block "Shallow Take: Modifying the result also modified the original source."
print ""


; --- Demonstration of Deep Take (`/deep`) ---
print "-- 2. Deep `take/deep` --"
original-data: [a [x y] b]
handle-to-nested-block: second original-data
print ["Original data:" mold original-data]
print ["Handle points to:" mold handle-to-nested-block]

taken-deep: take/deep next original-data
print ["Item taken with /deep:" mold taken-deep]

print "Modifying the `taken-deep` result..."
append taken-deep 'Z

print ["Modified `taken-deep`:" mold taken-deep]
print ["Value of our original handle:" mold handle-to-nested-block]
assert-equal [x y] handle-to-nested-block "Deep Take: Modifying the result did NOT modify the original source."


print-test-summary
