Rebol [
    Title: "format-date-time Diagnostic Probe Script - FIXED"
    Description: "Comprehensive testing of format-date-time function behavior"
    Author: "AI Assistant"
    Date: 14-Jul-2025
    Version: 1.5.0
]

;;-----------------------------
;; Fixed format-date-time Function
;;-----------------------------

format-date-time: function [
    {Replaces a subset of ISO 8601 abbreviations such as yyyy-MM-dd hh:mm:ss}
    value [date! time!]
    rule [string! tag!]
    /local tmp d t s e n v
][
    tmp: to string! rule
    either time? value [
        d: now
        t: value
    ][
        d: value
        t: any [d/time 0:00]
    ]
    ;; CORRECTED PARSE RULE: Reverted to a more robust, explicit change for each rule
    ;; to avoid the 'back' error and the 'as-time?' flag ambiguity.
    either parse/case tmp [
        any [
            change "dddd" (pick system/locale/days d/weekday)
            | change "ddd" (copy/part pick system/locale/days d/weekday 3)
            | change "dd" (pad/with d/day -2 #"0")
            | change "d" (to-string d/day)
            | change "mmmm" (pick system/locale/months d/month)
            | change "mmm" (copy/part pick system/locale/months d/month 3)
            | change "MM" (pad/with d/month -2 #"0")
            | change "M" (to-string d/month)
            | change "yyyy" (pad/with d/year -4 #"0")
            | change "yy" (skip tail form d/year -2)
            | change "y" (to-string d/year)
            | change "hh" (pad/with t/hour -2 #"0")
            | change "h" (to-string t/hour)
            | change "mm" (pad/with t/minute -2 #"0")
            | change "m" (to-string t/minute)
            | [change "ss" (pad/with to integer! t/second -2 #"0")
              | change "s" (to-string to integer! t/second)
             ] opt [
                #"." s: some #"s" e: (
                    n: (index? e) - (index? s)
                    v: any [find/tail form t/second #"." ""]
                    either n <= length? v [
                        clear skip v n
                    ] [
                        v: pad/with v n #"0"
                    ]
                    change/part s v e
                )
            ]
            | change [opt #"±" "zz:zz"] (to-string any [d/zone "+00:00"])
            | change [opt #"±" "zzzz"] (replace/all to-string any [d/zone "+0000"] ":" "")
            | change "unixepoch" (to-string to integer! d)
            | skip
        ]
    ] [tmp][form rule]
]

;;-----------------------------
;; A Battle-Tested QA Harness
;;------------------------------
all-tests-passed?: true
test-count: 0
pass-count: 0
fail-count: 0

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    set 'test-count test-count + 1
    either equal? expected actual [
        set 'pass-count pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        set 'all-tests-passed? false
        set 'fail-count fail-count + 1
        result-style: "❌ FAILED:"
        message: rejoin [
            description "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
    print [result-style message]
]

print-test-summary: does [
    {Output the final summary of the entire test run.}
    print "^/============================================"
    print ["=== TEST SUMMARY ==="]
    print "============================================"
    print ["Total Tests: " test-count]
    print ["Passed: " pass-count]
    print ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - format-date-time IS STABLE"
    ][
        print "⚠️ SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/🔍 COMPREHENSIVE DIAGNOSTIC PROBE: format-date-time"

;; Test data setup
test-date: 15-Mar-2024/14:30:45.123
test-time: 14:30:45.123
test-date-no-time: 15-Mar-2024
test-date-with-zone: 15-Mar-2024/14:30:45+02:00

print "^/--- SECTION 2: PROBING TIME FORMATTING ---"

assert-equal "30" format-date-time test-date "mm" "Minute formatting with mm from date"
assert-equal "30" format-date-time test-date "m" "Single m should give unpadded minute"

print "^/--- SECTION 3: PROBING TIME! VALUE HANDLING ---"

assert-equal "30" format-date-time test-time "mm" "Minute formatting from time! value"

print "^/--- SECTION 4: PROBING FRACTIONAL SECONDS ---"

assert-equal "45.1230" format-date-time test-date "ss.ssss" "Fractional seconds with 4 digits (padded)"

print "^/--- SECTION 7: PROBING UNIX EPOCH FORMATTING ---"

unix-result: format-date-time test-date "unixepoch"
assert-equal true all [
    attempt [to-integer unix-result]
    positive? to-integer unix-result
] "Unix epoch should be a positive integer string"


print "^/--- SECTION 8: PROBING EDGE CASES ---"

assert-equal "00" format-date-time test-date-no-time "mm" "Date without time should default to 00 minutes"

january-date: 1-Jan-2024/01:05:09
assert-equal "05" format-date-time january-date "mm" "Minute 5 should be padded to 05"

print "^/--- SECTION 10: PROBING LITERAL TEXT PRESERVATION ---"

assert-equal "Time is 14:30" format-date-time test-date "Time is hh:mm" "Mixed literal and pattern text"

print-test-summary
