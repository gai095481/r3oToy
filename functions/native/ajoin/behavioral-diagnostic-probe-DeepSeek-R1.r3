REBOL [
    Title: "Diagnostic Probe for AJOIN Function"
    Author: "Rebol 3 Oldes Branch Expert"
    Version: 0.1.5
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
;; Diagnostic Probe for AJOIN
;;-----------------------------------------------------------------------------
print {=== Starting AJOIN Behavior Probe ===^/}

;;
;; SECTION 1: BASIC BEHAVIOR (NO REFINEMENTS)
;;
print "^/=== 1. Basic Behavior (No Refinements) ==="

;; Hypothesis 1.1: Basic string concatenation ignores none and returns string
assert-equal "ABCDEF" ajoin ["ABC" "DEF"] "1.1a: Basic string concatenation"
assert-equal "1applebanana3.14" ajoin [1 "apple" none "banana" 3.14] "1.1b: Mixed types with none"
assert-equal "Hellotrue" ajoin ["Hello" true] "1.1c: String and logic concatenation"

;; Hypothesis 1.2: ajoin always returns string! regardless of input type
assert-equal "<ABC>123" ajoin [<ABC> 123] "1.2a: Tag input returns string"
assert-equal "10birds20trees" ajoin [10 "birds" none 20 "trees"] "1.2b: Integer start returns string"
assert-equal "<b>" ajoin [none <b>] "1.2c: First non-none (tag) returns string"

;; Hypothesis 1.3: Reduction occurs before joining
x: 100
assert-equal "100value" ajoin [x "value"] "1.3a: Word reduction to value"
assert-equal "3" ajoin [1 + 2] "1.3b: Expression reduction"

;;
;; SECTION 2: /WITH REFINEMENT (DELIMITER)
;;
print "^/=== 2. /with Refinement Behavior ==="

;; Hypothesis 2.1: Delimiter is inserted between elements
assert-equal "1,2,3" ajoin/with [1 2 3] "," "2.1a: Basic delimiter"
assert-equal "apple|banana|cherry" ajoin/with ["apple" "banana" "cherry"] "|" "2.1b: Pipe delimiter"
assert-equal "<a>-<b>" ajoin/with [<a> <b>] "-" "2.1c: Tag elements with string delimiter"

;; Hypothesis 2.2: Delimiter not added for single element
assert-equal "single" ajoin/with ["single"] ":" "2.2a: Single string element"
assert-equal "100" ajoin/with [100] "," "2.2b: Single integer element"

;; Hypothesis 2.3: None values break delimiter sequences
assert-equal "one-two" ajoin/with ["one" none "two"] "-" "2.3a: None breaks delimiter chain"

;;
;; SECTION 3: /all REFINEMENT (INCLUDE NONE)
;;
print "^/=== 3. /all Refinement Behavior ==="

;; Hypothesis 3.1: None is included as "none"
assert-equal "HellononeWorld" ajoin/all ["Hello" none "World"] "3.1a: Include none values"

;; Hypothesis 3.2: /all forces string output
assert-equal string! type? ajoin/all [<tag> 123] "3.2a: Tag input becomes string"
assert-equal "100" ajoin/all [100] "3.2b: Integer becomes string"

;;
;; SECTION 4: /all AND /with COMBINED
;;
print "^/=== 4. /all and /with Combined Behavior ==="

;; Hypothesis 4.1: Delimiters separate all values including nones
assert-equal "1|none|2" ajoin/with/all [1 none 2] "|" "4.1a: Delimiter with none"

;;
;; SECTION 5: EDGE CASES
;;
print "^/=== 5. Edge Cases ==="

;; Hypothesis 5.1: Empty block returns empty string
assert-equal "" ajoin [] "5.1a: Empty block (basic)"
assert-equal "" ajoin/with [] "," "5.1b: Empty block (/with)"
assert-equal "" ajoin/all [] "5.1c: Empty block (/all)"

;; Hypothesis 5.2: Block elements are recursively processed
assert-equal "ab cd" ajoin ["a" ["b" "c"] "d"] "5.2a: Nested block concatenation"
assert-equal "1 2|3 4" ajoin/with [[1 2] [3 4]] "|" "5.2b: Nested blocks with delimiter"

;; Hypothesis 5.3: All-none blocks
assert-equal "" ajoin [none none] "5.3a: All none values (basic)"
assert-equal "nonenone" ajoin/all [none none] "5.3b: All none values (/all)"
assert-equal "none|none" ajoin/with/all [none none] "|" "5.3c: All none values (/all/with)"

;; Hypothesis 5.4: Pathological inputs
assert-equal "123" ajoin [1 2 3] "5.4a: All integers"
assert-equal "truefalse" ajoin [true none false] "5.4b: Logic values (none ignored)"
assert-equal %home/user/file.txt ajoin [%home/user/ "file" %.txt] "5.4c: File handling returns file! type"

;; Hypothesis 5.5: File handling with non-file elements
assert-equal "home/user/file.txt123" ajoin [%home/user/ "file" %.txt 123] "5.5: Mixed file and integer returns string"

;;-----------------------------------------------------------------------------
;; TEST SUMMARY
;;-----------------------------------------------------------------------------
print-test-summary
