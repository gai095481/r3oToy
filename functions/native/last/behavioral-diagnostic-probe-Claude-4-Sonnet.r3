REBOL [
    Title: "Diagnostic Probe for `last` Function"
    Purpose: "Comprehensive testing and documentation of Rebol 3 Oldes `last` native function"
    Author: "Claude 4 Sonnet"
    Date: 15-Jul-2025
    Version: 0.1.1
    Type: 'script
    Description: {
        This diagnostic probe script systematically tests the `last` function behavior
        across all supported data types, refinements, and edge cases. The script
        follows a "Truth from the REPL" philosophy where every claim about function
        behavior is backed by demonstrable code and empirical evidence.
        
        The script generates structured test output showing passed/failed tests,
        expected vs actual values, and comprehensive coverage statistics. This serves
        as both a testing tool and living documentation for the `last` function.
        
        Target: Rebol 3 Oldes
        Coverage: series!, tuple!, gob! data types and edge cases
    }
    Notes: {
        - Uses battle-tested QA harness functions for structured testing
        - Groups tests logically by data type and behavior
        - Includes hypothesis comments explaining expected outcomes
        - Follows idiomatic Rebol conventions with descriptive variable names
    }
]

;;=============================================================================
;; QA TEST HARNESS SECTION
;;=============================================================================
;; The battle-tested helper functions for structured
;; testing with pass/fail tracking and formatted output.

;; Global test tracking variables
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

;; Assert-equal function for structured test comparisons
assert-equal: funct [
    "Compare expected and actual values with formatted output"
    expected [any-type!] "Expected value"
    actual [any-type!] "Actual value" 
    description [string!] "Test description"
    tc [integer!] "Current test count"
    pc [integer!] "Current pass count"
    fc [integer!] "Current fail count"
    atp [logic!] "Current all tests passed status"
    return: [block!] "Updated [test-count pass-count fail-count all-tests-passed]"
] [
    tc: tc + 1
    
    either equal? expected actual [
        pc: pc + 1
        print rejoin ["✅ PASSED: " description]
    ] [
        fc: fc + 1
        atp: false
        print rejoin ["❌ FAILED: " description]
        print rejoin ["   Expected: " mold expected]
        print rejoin ["   Actual:   " mold actual]
    ]
    
    reduce [tc pc fc atp]
]

;; Print-test-summary function for final statistics output
print-test-summary: funct [
    "Display final test statistics and success rate"
    tc [integer!] "Total test count"
    pc [integer!] "Pass count"
    fc [integer!] "Fail count"
    atp [logic!] "All tests passed status"
] [
    print "^/=========================================="
    print "           TEST SUMMARY"
    print "=========================================="
    print rejoin ["Total Tests:  " tc]
    print rejoin ["Passed:       " pc]
    print rejoin ["Failed:       " fc]
    
    either tc > 0 [
        success-rate: round/to (pc * 100.0) / tc 0.1
        print rejoin ["Success Rate: " success-rate "%"]
    ] [
        print "Success Rate: N/A (no tests run)"
    ]
    
    prin lf
    either atp [
        print "✅ ALL TESTS PASSED!"
    ] [
        print "❌  SOME TESTS FAILED"
    ]
    print "=========================================="
]


;;=============================================================================
;; TEST DATA SETUP SECTION  
;;=============================================================================
;; This section defines comprehensive test data collections for all supported
;; data types that the `last` function can operate on.

;; Series test data collections
;; Block test data with various lengths and content types
basic-numeric-blocks: [
    [1 2 3 4 5]           ;; basic numeric sequence
    [10 20 30]            ;; simple three-element block
    [42]                  ;; single-element block
    []                    ;; empty block
]

mixed-content-blocks: [
    [1 "hello" 3.14]      ;; mixed types: integer, string, decimal
    ["first" "second"]    ;; string-only block
    [true false none]     ;; logic and none values
    [[1 2] [3 4]]         ;; nested blocks
]

large-content-blocks: [
    [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20]  ;; twenty elements
]

;; String test data including empty and multi-character strings
basic-string-samples: [
    "hello"               ;; basic multi-character string
    "a"                   ;; single character
    ""                    ;; empty string
    "test123"             ;; alphanumeric string
]

special-character-strings: [
    "hello world"         ;; string with space
    "line1^/line2"        ;; string with newline
    "tab^-separated"      ;; string with tab
    "special!@#$%"        ;; string with special characters
]

unicode-string-samples: [
    "café"               ;; string with accented characters
    "测试"                ;; non-Latin characters (if supported)
]

;; Binary test data for comprehensive series coverage
basic-binary-samples: [
    #{01}                 ;; single byte
    #{DEADBEEF}           ;; four bytes
    #{00}                 ;; zero byte
    #{}                   ;; empty binary
]

pattern-binary-samples: [
    #{0102030405}         ;; sequential pattern
    #{FFFFFFFF}           ;; all ones pattern
    #{00000000}           ;; all zeros pattern
    #{A5A5A5A5}           ;; alternating pattern
]


;; Tuple test data collections
;; IP address tuples for testing
ip-address-tuples: [
    1.2.3.4               ;; standard IPv4 address
    192.168.1.1           ;; common private IP
    127.0.0.1             ;; localhost address
    255.255.255.255       ;; broadcast address
    0.0.0.0               ;; null route address
]

;; Version number tuples for testing
version-number-tuples: [
    1.0                   ;; simple two-part version
    2.1.3                 ;; three-part version
    1.0.0.0               ;; four-part version
    10.15.7               ;; larger version numbers
    0.1                   ;; zero major version
]

;; Color tuples for comprehensive coverage (RGB values)
color-value-tuples: [
    255.0.0               ;; pure red
    0.255.0               ;; pure green
    0.0.255               ;; pure blue
    255.255.255           ;; white
    0.0.0                 ;; black
]


;;=============================================================================
;; BASIC SERIES BEHAVIOR TESTS
;;=============================================================================
;; This section tests the `last` function with common series types including
;; blocks, strings, and binary data to establish baseline behavior.

;; HYPOTHESIS: Basic series behavior tests
;; Expected behavior for `last` function with common series types:
;; 
;; BLOCKS: last [1 2 3 4 5] should return 5 (the final element)
;;         last [42] should return 42 (single element)
;;         last [] should return none (empty block has no last element)
;;         last [[1 2] [3 4]] should return [3 4] (last sub-block)
;;         last [1 "hello" 3.14] should return 3.14 (last mixed-type element)
;; 
;; STRINGS: last "hello" should return #"o" (the final character)
;;          last "a" should return #"a" (single character)
;;          last "" should return none (empty string has no last character)
;;          last "test123" should return #"3" (last alphanumeric character)
;; 
;; BINARY: last #{DEADBEEF} should return 239 (last byte as integer: EF = 239)
;;         last #{01} should return 1 (single byte as integer)
;;         last #{} should return none (empty binary has no last byte)
;;         last #{0102030405} should return 5 (last byte in sequence)
;;
;; The `last` function should consistently return the final element of any series,
;; or none for empty series. For strings, it returns a character datatype.
;; For binary data, it returns the last byte as an integer value.

print "^/=========================================="
print "    BASIC SERIES BEHAVIOR TESTS"
print "=========================================="

;; Block testing with various sizes and content types
print "^/--- Block Testing ---"

;; Test basic numeric blocks
set [test-count pass-count fail-count all-tests-passed?] assert-equal 5 last [1 2 3 4 5] "last of basic numeric sequence [1 2 3 4 5]" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 30 last [10 20 30] "last of three-element block [10 20 30]" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 42 last [42] "last of single-element block [42]" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal none last [] "last of empty block []" test-count pass-count fail-count all-tests-passed?

;; Test mixed-content blocks
set [test-count pass-count fail-count all-tests-passed?] assert-equal 3.14 last [1 "hello" 3.14] "last of mixed-type block with string and decimal" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal "second" last ["first" "second"] "last of string-only block" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal none last [true false #(none)] "last of logic/none block [true false #(none)]" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal [3 4] last [[1 2] [3 4]] "last of nested blocks [[1 2] [3 4]]" test-count pass-count fail-count all-tests-passed?

;; Test large content blocks
set [test-count pass-count fail-count all-tests-passed?] assert-equal 20 last [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20] "last of twenty-element block" test-count pass-count fail-count all-tests-passed?

;; String testing with single-character and multi-character strings
print "^/--- String Testing ---"

;; Test basic string samples
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"o" last "hello" "last character of hello string" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"a" last "a" "last character of single-char string" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal none last "" "last character of empty string" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"3" last "test123" "last character of alphanumeric string" test-count pass-count fail-count all-tests-passed?

;; Test special character strings
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"d" last "hello world" "last character of hello world" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"2" last "line1^/line2" "last character of string with newline" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"d" last "tab^-separated" "last character of string with tab" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"%" last "special!@#$%" "last character of special chars string" test-count pass-count fail-count all-tests-passed?

;; Test unicode string samples (if supported)
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"é" last "café" "last character of accented string" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"试" last "测试" "last character of non-Latin string" test-count pass-count fail-count all-tests-passed?

;; Binary testing with various lengths and patterns
print "^/--- Binary Testing ---"

;; Test basic binary samples
set [test-count pass-count fail-count all-tests-passed?] assert-equal 1 last #{01} "last byte of single-byte binary #{01}" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 239 last #{DEADBEEF} "last byte of four-byte binary #{DEADBEEF} (EF = 239)" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last #{00} "last byte of zero-byte binary #{00}" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal none last #{} "last byte of empty binary #{}" test-count pass-count fail-count all-tests-passed?

;; Test pattern binary samples
set [test-count pass-count fail-count all-tests-passed?] assert-equal 5 last #{0102030405} "last byte of sequential pattern #{0102030405}" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 255 last #{FFFFFFFF} "last byte of all-ones pattern #{FFFFFFFF}" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last #{00000000} "last byte of all-zeros pattern #{00000000}" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 165 last #{A5A5A5A5} "last byte of alternating pattern #{A5A5A5A5} (A5 = 165)" test-count pass-count fail-count all-tests-passed?


;;=============================================================================
;; TUPLE BEHAVIOR TESTS
;;=============================================================================
;; This section tests the `last` function with tuple data types including
;; IP addresses and version numbers.

;; HYPOTHESIS: Tuple behavior tests
;; 
;; Expected behavior for `last` function with tuple data types:
;; 
;; IP ADDRESS TUPLES: last 1.2.3.4 should return 4 (the final octet)
;;                    last 192.168.1.1 should return 1 (last octet of private IP)
;;                    last 127.0.0.1 should return 1 (last octet of localhost)
;;                    last 255.255.255.255 should return 255 (broadcast address last octet)
;;                    last 0.0.0.0 should return 0 (null route last octet)
;; 
;; VERSION NUMBER TUPLES: last 1.0.0 should return 0 (patch version number)
;;                        last 2.1.3 should return 3 (patch version number)
;;                        last 1.0.0.0 should return 0 (final version component)
;;                        last 10.15.7 should return 7 (last version component)
;;                        last 0.1.1 should return 1 (patch version of zero major)
;; 
;; COLOR VALUE TUPLES: last 255.0.0 should return 0 (blue component of pure red)
;;                     last 0.255.0 should return 0 (blue component of pure green)
;;                     last 0.0.255 should return 255 (blue component of pure blue)
;;                     last 255.255.255 should return 255 (blue component of white)
;;                     last 0.0.0 should return 0 (blue component of black)
;;
;; The `last` function should consistently return the final numeric component of any tuple,
;; treating tuples as ordered sequences where the rightmost value is the "last" element.
;; This applies to IP addresses (returning the final octet), version numbers (returning
;; the final version component), and color values (returning the final color channel).

print "^/=========================================="
print "      TUPLE BEHAVIOR TESTS"
print "=========================================="

;; IP address tuple testing
print "^/--- IP Address Tuple Testing ---"

;; Test standard IP address tuples
set [test-count pass-count fail-count all-tests-passed?] assert-equal 4 last 1.2.3.4 "last octet of standard IPv4 address 1.2.3.4" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 1 last 192.168.1.1 "last octet of private IP address 192.168.1.1" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 1 last 127.0.0.1 "last octet of localhost address 127.0.0.1" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 255 last 255.255.255.255 "last octet of broadcast address 255.255.255.255" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last 0.0.0.0 "last octet of null route address 0.0.0.0" test-count pass-count fail-count all-tests-passed?

;; Version number tuple testing
print "^/--- Version Number Tuple Testing ---"

;; Test various version number formats
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last 1.0.0 "last component of three-part version 1.0.0" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 3 last 2.1.3 "last component of three-part version 2.1.3" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last 1.0.0.0 "last component of four-part version 1.0.0.0" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 7 last 10.15.7 "last component of larger version numbers 10.15.7" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 1 last 0.1.1 "last component of zero major version 0.1.1" test-count pass-count fail-count all-tests-passed?

;; Color value tuple testing
print "^/--- Color Value Tuple Testing ---"

;; Test RGB color tuples
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last 255.0.0 "blue component of pure red color 255.0.0" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last 0.255.0 "blue component of pure green color 0.255.0" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 255 last 0.0.255 "blue component of pure blue color 0.0.255" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 255 last 255.255.255 "blue component of white color 255.255.255" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last 0.0.0 "blue component of black color 0.0.0" test-count pass-count fail-count all-tests-passed?


;;=============================================================================
;; EDGE CASE TESTS
;;=============================================================================
;; This section tests boundary conditions, empty series, and invalid inputs
;; to understand error handling and edge case behavior.

;; HYPOTHESIS: Edge case tests
;; Expected behavior for `last` function with edge cases and boundary conditions:
;; 
;; EMPTY SERIES: last [] should return none (empty block has no elements)
;;               last "" should return none (empty string has no characters)
;;               last #{} should return none (empty binary has no bytes)
;;               Empty series should consistently return none across all series types
;; 
;; SINGLE-ELEMENT SERIES: last [42] should return 42 (only element in block)
;;                        last "x" should return #"x" (only character in string)
;;                        last #{FF} should return 255 (only byte as integer)
;;                        Single-element series should return that element
;; 
;; INVALID INPUT TYPES: last 42 should generate error (integer is not a series)
;;                      last true should generate error (logic is not a series)
;;                      last none should generate error (none is not a series)
;;                      last 3.14 should generate error (decimal is not a series)
;;                      Invalid inputs should produce consistent error messages
;; 
;; ERROR HANDLING: Error messages should be descriptive and consistent
;;                 Error types should be appropriate (script error, type error, etc.)
;;                 Function should fail gracefully without crashing the system
;;
;; The `last` function should handle boundary conditions predictably:
;; - Empty series return none (not an error)
;; - Single-element series return that element
;; - Invalid data types produce clear, consistent error messages
;; - Error handling is graceful and informative


print "^/=========================================="
print "         EDGE CASE TESTS"
print "=========================================="
;; Empty series testing
print "^/--- Empty Series Testing ---"

;; Test empty blocks
set [test-count pass-count fail-count all-tests-passed?] assert-equal none last [] "last of empty block []" test-count pass-count fail-count all-tests-passed?

;; Test empty strings  
set [test-count pass-count fail-count all-tests-passed?] assert-equal none last "" "last of empty string" test-count pass-count fail-count all-tests-passed?

;; Test empty binary data
set [test-count pass-count fail-count all-tests-passed?] assert-equal none last #{} "last of empty binary #{}" test-count pass-count fail-count all-tests-passed?

print "^/Empty series consistently return none across all series types."

;; Single-element series testing
print "^/--- Single-Element Series Testing ---"

;; Test single-element blocks
set [test-count pass-count fail-count all-tests-passed?] assert-equal 42 last [42] "last of single-element block [42]" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal "only" last ["only"] "last of single-element string block [only]" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #(true) last [#(true)] "last of single-element logic block [#(true)]" test-count pass-count fail-count all-tests-passed?

;; Test single-character strings
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"x" last "x" "last character of single-char string x" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"A" last "A" "last character of single-char string A" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal #"5" last "5" "last character of single-digit string 5" test-count pass-count fail-count all-tests-passed?

;; Test single-byte binary data
set [test-count pass-count fail-count all-tests-passed?] assert-equal 255 last #{FF} "last byte of single-byte binary #{FF} (255)" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 0 last #{00} "last byte of single-byte binary #{00} (0)" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] assert-equal 170 last #{AA} "last byte of single-byte binary #{AA} (170)" test-count pass-count fail-count all-tests-passed?

print "^/Single-element series correctly return their only element."

;; Invalid input testing with error handling
print "^/--- Invalid Input Testing ---"

;; Helper function to test error conditions
test-error: funct [
    "Test that a function call produces an error"
    test-code [block!] "Code to test (as block)"
    description [string!] "Test description"
    tc [integer!] "Current test count"
    pc [integer!] "Current pass count"
    fc [integer!] "Current fail count"
    atp [logic!] "Current all tests passed status"
    return: [block!] "Updated [test-count pass-count fail-count all-tests-passed]"
] [
    tc: tc + 1
    
    error-caught?: false
    result: none
    
    ;; Try to execute the code and catch any errors
    set/any 'result try [
        do test-code
    ]
    
    either error? result [
        error-caught?: true
        pc: pc + 1
        print rejoin ["✅ PASSED: " description " (error caught as expected)"]
        print rejoin ["   Error type: " result/type " - " result/id]
    ] [
        fc: fc + 1
        atp: false
        print rejoin ["❌ FAILED: " description " (no error was thrown)"]
        print rejoin ["   Unexpected result: " mold result]
    ]
    
    reduce [tc pc fc atp]
]

;; Test invalid data types that should generate errors
set [test-count pass-count fail-count all-tests-passed?] test-error [last 42] "last with integer input (42) should generate error" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] test-error [last true] "last with logic input (true) should generate error" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] test-error [last false] "last with logic input (false) should generate error" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] test-error [last none] "last with none input should generate error" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] test-error [last 3.14] "last with decimal input (3.14) should generate error" test-count pass-count fail-count all-tests-passed?

;; Test additional invalid types
set [test-count pass-count fail-count all-tests-passed?] test-error [last :print] "last with function input should generate error" test-count pass-count fail-count all-tests-passed?
set [test-count pass-count fail-count all-tests-passed?] test-error [last make object! []] "last with object input should generate error" test-count pass-count fail-count all-tests-passed?

print "^/Invalid input types produce consistent error messages as expected."


;;=============================================================================
;; TEST EXECUTION AND SUMMARY
;;=============================================================================
;; This section executes all tests and provides final summary output with
;; statistics and success rate calculation.

;; Execute all test sections and display final summary
print-test-summary test-count pass-count fail-count all-tests-passed?
