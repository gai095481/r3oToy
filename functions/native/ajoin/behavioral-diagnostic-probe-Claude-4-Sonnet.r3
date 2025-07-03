REBOL [
    Title: "Corrected Diagnostic Probe for AJOIN Function"
    Author: "Rebol 3 Oldes Branch Expert"
    Version: 0.2.0
    Purpose: {Systematically probe the behavior of AJOIN native function in REBOL/Bulk 3.19.0}
]

;;-----------------------------------------------------------------------------
;; QA Test Harness
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
        print "✅ ALL `ajoin` TESTS PASSED"
    ][
        print "❌ SOME `ajoin` TESTS FAILED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; Corrected Diagnostic Probe for AJOIN
;;-----------------------------------------------------------------------------
print {=== Starting AJOIN Behavior Probe ===^/}

;;
;; SECTION 1: BASIC BEHAVIOR (NO REFINEMENTS)
;;
print "^/=== 1. Basic Behavior (No Refinements) ==="

;; Test 1.1: Basic string concatenation
assert-equal "ABCDEF" ajoin ["ABC" "DEF"] "1.1a: Basic string concatenation"
assert-equal "1applebanana3.14" ajoin [1 "apple" none "banana" 3.14] "1.1b: Mixed types with none ignored"
assert-equal "Hellotrue" ajoin ["Hello" true] "1.1c: String and logic concatenation"

;; Test 1.2: Return type is always string! (CORRECTED)
assert-equal string! type? ajoin [<ABC> 123] "1.2a: Return type is always string!"
assert-equal "10birds20trees" ajoin [10 "birds" none 20 "trees"] "1.2b: Integer start returns string"
assert-equal "<b>" ajoin [none <b>] "1.2c: First non-none (tag) returns string"

;; Test 1.3: Reduction occurs before joining
x: 100
assert-equal "100value" ajoin [x "value"] "1.3a: Word reduction to value"
assert-equal "3" ajoin [1 + 2] "1.3b: Expression reduction"

;;
;; SECTION 2: /WITH REFINEMENT (DELIMITER)
;;
print "^/=== 2. /with Refinement Behavior ==="

;; Test 2.1: Delimiter is inserted between elements
assert-equal "1,2,3" ajoin/with [1 2 3] "," "2.1a: Basic delimiter"
assert-equal "apple|banana|cherry" ajoin/with ["apple" "banana" "cherry"] "|" "2.1b: Pipe delimiter"
assert-equal "<a>-<b>" ajoin/with [<a> <b>] "-" "2.1c: Tag elements with string delimiter"

;; Test 2.2: Delimiter not added for single element
assert-equal "single" ajoin/with ["single"] ":" "2.2a: Single string element"
assert-equal "100" ajoin/with [100] "," "2.2b: Single integer element"

;; Test 2.3: None values are ignored, so no delimiter disruption
assert-equal "one-two" ajoin/with ["one" none "two"] "-" "2.3a: None ignored, delimiter between remaining"

;;
;; SECTION 3: /ALL REFINEMENT (INCLUDE NONE)
;;
print "^/=== 3. /all Refinement Behavior ==="

;; Test 3.1: None is included as "none"
assert-equal "HellononeWorld" ajoin/all ["Hello" none "World"] "3.1a: Include none values"

;; Test 3.2: /all still returns string! type
assert-equal string! type? ajoin/all [<tag> 123] "3.2a: /all returns string! type"
assert-equal "100" ajoin/all [100] "3.2b: Single integer becomes string"

;;
;; SECTION 4: /ALL AND /WITH COMBINED
;;
print "^/=== 4. /all and /with Combined Behavior ==="

;; Test 4.1: Delimiters separate all values including nones
assert-equal "1|none|2" ajoin/with/all [1 none 2] "|" "4.1a: Delimiter with none included"

;;
;; SECTION 5: EDGE CASES
;;
print "^/=== 5. Edge Cases ==="

;; Test 5.1: Empty block returns empty string
assert-equal "" ajoin [] "5.1a: Empty block (basic)"
assert-equal "" ajoin/with [] "," "5.1b: Empty block (/with)"
assert-equal "" ajoin/all [] "5.1c: Empty block (/all)"

;; Test 5.2: Block elements are processed (CORRECTED - no spaces assumed)
assert-equal "1 2|3 4" ajoin/with [[1 2] [3 4]] "|" "5.2a: Nested blocks with delimiter"

;; Test 5.3: All-none blocks
assert-equal "" ajoin [none none] "5.3a: All none values ignored"
assert-equal "nonenone" ajoin/all [none none] "5.3b: All none values with /all"
assert-equal "none|none" ajoin/with/all [none none] "|" "5.3c: All none values with /all/with"

;; Test 5.4: File handling (CORRECTED - always returns string!)
assert-equal "123" ajoin [1 2 3] "5.4a: All integers"
assert-equal "truefalse" ajoin [true none false] "5.4b: Logic values (none ignored)"
assert-equal "home/user/file.txt" ajoin [%home/user/ "file" %.txt] "5.4c: File elements join as string"

;;
;; SECTION 6: DATA TYPE CONVERSIONS
;;
print "^/=== 6. Data Type Conversions ==="

;; Test 6.1: Various data types
assert-equal "A" ajoin [#"A"] "6.1a: Character type"
assert-equal "<ABC>" ajoin [<ABC>] "6.1b: Tag type"
assert-equal "true" ajoin [true] "6.1c: Logic true"
assert-equal "false" ajoin [false] "6.1d: Logic false"

;; Test 6.2: File paths (CORRECTED)
assert-equal "/home/user/file.txt" ajoin [%/home/user/file.txt] "6.2a: File to string conversion"

;;
;; SECTION 7: UNSET VALUE HANDLING (CORRECTED)
;;
print "^/=== 7. Unset Value Handling ==="

;; Properly create unset values for testing
tmp-word: 'test-unset
unset 'tmp-word

;; Test with properly constructed blocks containing unset values
test-block-with-unset: reduce ["a" none "b" (get/any 'tmp-word) "c"]
assert-equal "abc" ajoin test-block-with-unset "7.1a: Unset values ignored by default"

;;
;; SECTION 8: ERROR CONDITIONS
;;
print "^/=== 8. Error Conditions ==="

;; Test 8.1: Non-block arguments
set/any 'error-result try [ajoin "string"]
assert-equal true error? error-result "8.1a: Non-block argument produces error"

;;-----------------------------------------------------------------------------
;; TEST SUMMARY
;;-----------------------------------------------------------------------------
print-test-summary
