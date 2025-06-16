REBOL [
    Title: "Bitset to Charset Converter"
    Version: 0.1.0
    Author: "DeepSeek R1 0528"
    Date: 16-Jun-2025
    File: %bitset-to-charset.r3
    Status: "All QA tests pass."
    Purpose: "Convert bitset! values to charset expression strings"
    Notes: {
        Provides a function to convert `bitset!` values into
        their equivalent charset expression string representation.
        Handles single characters and character ranges appropriately.
    }
    Keywords: [bitset charset conversion string range]
]

bitset-to-charset: function [
    bset-input [bitset!] "Input: bitset to convert to charset expression."
][
    result: copy []
    start: none

    ;; Iterate through all possible 8-bit character codes:
    for idx 0 255 1 [
        current-char: to char! idx

        ;; Use case-sensitive find to check the bitset:
        either find/case bset-input current-char [
            ;; Character is in the bitset
            either none? start [
                start: idx  ; Start new range
            ][
                ;; Continue extending range.
            ]
        ][
            ;; Character not in bitset, close any active range:
            if not none? start [
                end: idx - 1
                either start = end [
                    append result to char! start
                ][
                    append result reduce [to char! start '- to char! end]
                ]
                start: none
            ]
        ]
    ]

    ;; Handle the final range if loop ended with an active range:
    if not none? start [
        end: 255
        either start = end [
            append result to char! start
        ][
            append result reduce [to char! start '- to char! end]
        ]
    ]

    return mold result
]

;; QA Test function demonstrating usage:
test-bitset-to-charset: function [
][
    {Test the bitset-to-charset function with various inputs.
    Demonstrate the function's behavior with different bitset configurations
    and validate the output format.
    RETURNS: [logic!] "True if all tests pass, otherwise false"}

    test-passed: true
    print "=== QA Testing the `bitset-to-charset` Function ===^/"

    print "^/--- QA Test 1: Digit charset ---"
    digit-set: charset [#"0" - #"9"]
    result1: bitset-to-charset digit-set
    expected1: {[#"0" - #"9"]}
    print reform ["Input bitset:" mold digit-set]
    print reform ["Output:" result1]
    print reform ["Expected:" expected1]
    print reform ["Result:" either result1 = expected1 ["✅ PASSED"] ["❌ FAILED"]]
    if result1 <> expected1 [test-passed: false]

    print "^/--- QA Test 2: Letter charset (a-z) ---"
    letter-set: charset [#"a" - #"z"]
    result2: bitset-to-charset letter-set
    expected2: {[#"a" - #"z"]}
    print reform ["Input bitset:" mold letter-set]
    print reform ["Output:" result2]
    print reform ["Expected:" expected2]
    print reform ["Result:" either result2 = expected2 ["✅ PASSED"] ["❌ FAILED"]]
    if result2 <> expected2 [test-passed: false]

    print "^/--- QA Test 3: Mixed single characters ---"
    mixed-set: charset [#"a" #"c" #"x"]
    result3: bitset-to-charset mixed-set
    expected3: {[#"a" #"c" #"x"]}
    print reform ["Input bitset:" mold mixed-set]
    print reform ["Output:" result3]
    print reform ["Expected:" expected3]
    print reform ["Result:" either result3 = expected3 ["✅ PASSED"] ["❌ FAILED"]]
    if result3 <> expected3 [test-passed: false]

    print "^/--- QA Test 4: Combined ranges and single characters ---"
    combined-set: charset [#"0" - #"9" #"A" - #"Z" #"_"]
    result4: bitset-to-charset combined-set
    expected4: {[#"0" - #"9" #"A" - #"Z" #"_"]}  ; Add this line
    print reform ["Input bitset:" mold combined-set]
    print reform ["Output:" result4]
    print reform ["Expected:" expected4]  ; Add this
    print reform ["Result:" either result4 = expected4 ["✅ PASSED"] ["❌ FAILED"]]
    if result4 <> expected4 [test-passed: false]

    print "^/--- QA Test 5: Type error handling (will cause error if uncommented) ---"
    print "Attempting to call with string input would halt execution:"
    print {bitset-to-charset "not-a-bitset"}
    print "This demonstrates Rebol's automatic type validation"

    print reform ["^/=== Overall Test Result:" either test-passed ["✅ ALL TESTS PASSED"] ["❌ SOME TESTS FAILED"] "==="]
    return test-passed
]

;; Run the QA test suite:
test-result: test-bitset-to-charset

prin "^/Usage Example: "
;; Define your bitset:
digit-set: charset [#"0" - #"9"]

;; Output as a charset expression:
print rejoin ["charset " bitset-to-charset digit-set]
