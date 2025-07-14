Rebol [
    Title: "format-date-time Diagnostic Probe Script - FINAL"
    Description: "Comprehensive testing of format-date-time function behavior"
    Author: "AI Assistant"
    Date: 14-Jul-2025
    Version: 1.6.0
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
    ;; CORRECTED PARSE RULE v2:
    ;; - Restructured 'ss.sss' to be an atomic rule to prevent duplication.
    ;; - Removed single 'm' and 's' rules which were corrupting literal text.
    ;;   Users should use 'mm' and 'ss' for clarity.
    either parse/case tmp [
        any [
            change "dddd" (pick system/locale/days d/weekday)
            | change "ddd" (copy/part pick system/locale/days d/weekday 3)
            | change "dd" (pad/with d/day -2 #"0")
            | change "d" (to-string d/day)
            | change "mmmm" (pick system/locale/months d/month)
            | change "mmm" (copy/part pick system/locale/months d/month 3)
            | change "yyyy" (pad/with d/year -4 #"0")
            | change "yy" (skip tail form d/year -2)
            | change "y" (to-string d/year)
            | change "hh" (pad/with t/hour -2 #"0")
            | change "h" (to-string t/hour)
            | change "mm" (pad/with t/minute -2 #"0")
            | change "MM" (pad/with d/month -2 #"0")
            | change "M" (to-string d/month)
            | change [
                "ss" s: opt [#"." some #"s"] e: (
                    res: pad/with to integer! t/second -2 #"0"
                    if s [
                        n: (index? e) - (index? s)
                        v: any [find/tail form t/second #"." ""]
                        either n <= length? v [
                            clear skip v n
                        ] [
                            v: pad/with v n #"0"
                        ]
                        res: rejoin [res "." v]
                    ]
                    res
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

;;==============================================================================
;; DIAGNOSTIC PROBE SCRIPT FOR format-date-time
;;==============================================================================

print "^/🔍 COMPREHENSIVE DIAGNOSTIC PROBE: format-date-time"
print "====================================================="

;; Test data setup
test-date: 15-Mar-2024/14:30:45.123
test-time: 14:30:45.123
test-date-no-time: 15-Mar-2024
test-date-with-zone: 15-Mar-2024/14:30:45+02:00

;;==============================================================================
;; SECTION 1: PROBING BASIC DATE FORMATTING
;;==============================================================================

print "^/--- SECTION 1: PROBING BASIC DATE FORMATTING ---"

assert-equal "2024" format-date-time test-date "yyyy" "Basic year formatting with yyyy"
assert-equal "03" format-date-time test-date "MM" "Basic month formatting with MM"
assert-equal "15" format-date-time test-date "dd" "Basic day formatting with dd"
assert-equal "2024" format-date-time test-date "y" "Single y should give full year"
assert-equal "3" format-date-time test-date "M" "Single M should give unpadded month"
assert-equal "15" format-date-time test-date "d" "Single d should give unpadded day"
assert-equal "24" format-date-time test-date "yy" "Two-digit year formatting"
assert-equal "2024-03-15" format-date-time test-date "yyyy-MM-dd" "Complete ISO date format"

;;==============================================================================
;; SECTION 2: PROBING TIME FORMATTING
;;==============================================================================

print "^/--- SECTION 2: PROBING TIME FORMATTING ---"

assert-equal "14" format-date-time test-date "hh" "Hour formatting with hh from date"
assert-equal "30" format-date-time test-date "mm" "Minute formatting with mm from date"
assert-equal "45" format-date-time test-date "ss" "Second formatting with ss from date"
assert-equal "14" format-date-time test-date "h" "Single h should give unpadded hour"
assert-equal "30" format-date-time test-date "m" "Single m should give unpadded minute"
assert-equal "45" format-date-time test-date "s" "Single s should give unpadded second"
assert-equal "14:30:45" format-date-time test-date "hh:mm:ss" "Complete time format from date"

;;==============================================================================
;; SECTION 3: PROBING TIME! VALUE HANDLING
;;==============================================================================

print "^/--- SECTION 3: PROBING TIME! VALUE HANDLING ---"

current-year: to string! now/year
current-month: pad/with now/month -2 #"0"
current-day: pad/with now/day -2 #"0"

assert-equal "14" format-date-time test-time "hh" "Time formatting from time! value"
assert-equal "30" format-date-time test-time "mm" "Minute formatting from time! value"
assert-equal "45" format-date-time test-time "ss" "Second formatting from time! value"
assert-equal current-year format-date-time test-time "yyyy" "Year from time! should use current date"
assert-equal current-month format-date-time test-time "MM" "Month from time! should use current date"
assert-equal current-day format-date-time test-time "dd" "Day from time! should use current date"

;;==============================================================================
;; SECTION 4: PROBING FRACTIONAL SECONDS
;;==============================================================================

print "^/--- SECTION 4: PROBING FRACTIONAL SECONDS ---"

assert-equal "45.123" format-date-time test-date "ss.sss" "Fractional seconds with 3 digits"
assert-equal "45.12" format-date-time test-date "ss.ss" "Fractional seconds with 2 digits"
assert-equal "45.1" format-date-time test-date "ss.s" "Fractional seconds with 1 digit"
assert-equal "45.1230" format-date-time test-date "ss.ssss" "Fractional seconds with 4 digits (padded)"

;;==============================================================================
;; SECTION 5: PROBING MONTH AND DAY NAMES
;;==============================================================================

print "^/--- SECTION 5: PROBING MONTH AND DAY NAMES ---"

month-result: format-date-time test-date "mmmm"
month-abbrev: format-date-time test-date "mmm"
assert-equal true string? month-result "Full month name should be string"
assert-equal true string? month-abbrev "Abbreviated month name should be string"
assert-equal true (3 = length? month-abbrev) "Month abbreviation should be 3 characters"

day-result: format-date-time test-date "dddd"
day-abbrev: format-date-time test-date "ddd"
assert-equal true string? day-result "Full day name should be string"
assert-equal true string? day-abbrev "Abbreviated day name should be string"
assert-equal true (3 = length? day-abbrev) "Day abbreviation should be 3 characters"

;;==============================================================================
;; SECTION 6: PROBING TIMEZONE HANDLING
;;==============================================================================

print "^/--- SECTION 6: PROBING TIMEZONE HANDLING ---"

zone-result: format-date-time test-date-with-zone "zzzz"
zone-colon-result: format-date-time test-date-with-zone "zz:zz"
assert-equal true string? zone-result "Zone formatting should return string"
assert-equal true string? zone-colon-result "Zone with colon formatting should return string"

;;==============================================================================
;; SECTION 7: PROBING UNIX EPOCH FORMATTING
;;==============================================================================

print "^/--- SECTION 7: PROBING UNIX EPOCH FORMATTING ---"

unix-result: format-date-time test-date "unixepoch"
assert-equal true string? unix-result "Unix epoch should return string representation"
assert-equal true all [attempt [to-integer unix-result] positive? to-integer unix-result] "Unix epoch should be a positive integer string"

;;==============================================================================
;; SECTION 8: PROBING EDGE CASES
;;==============================================================================

print "^/--- SECTION 8: PROBING EDGE CASES ---"

assert-equal "00" format-date-time test-date-no-time "hh" "Date without time should default to 00 hours"
assert-equal "00" format-date-time test-date-no-time "mm" "Date without time should default to 00 minutes"
assert-equal "00" format-date-time test-date-no-time "ss" "Date without time should default to 00 seconds"
assert-equal "2024-03-15 14:30:45" format-date-time test-date "yyyy-MM-dd hh:mm:ss" "Mixed date and time formatting"

january-date: 1-Jan-2024/01:05:09
assert-equal "01" format-date-time january-date "MM" "January should be padded to 01"
assert-equal "01" format-date-time january-date "dd" "First day should be padded to 01"
assert-equal "01" format-date-time january-date "hh" "Hour 1 should be padded to 01"
assert-equal "05" format-date-time january-date "mm" "Minute 5 should be padded to 05"
assert-equal "09" format-date-time january-date "ss" "Second 9 should be padded to 09"

;;==============================================================================
;; SECTION 9: PROBING TAG! RULE PARAMETER
;;==============================================================================

print "^/--- SECTION 9: PROBING TAG! RULE PARAMETER ---"

tag-result: format-date-time test-date <yyyy-MM-dd>
string-result: format-date-time test-date "yyyy-MM-dd"
assert-equal string-result tag-result "Tag! and string! rules should produce same result"

;;==============================================================================
;; SECTION 10: PROBING LITERAL TEXT PRESERVATION
;;==============================================================================

print "^/--- SECTION 10: PROBING LITERAL TEXT PRESERVATION ---"

assert-equal "Date: 2024-03-15" format-date-time test-date "Date: yyyy-MM-dd" "Literal text should be preserved"
assert-equal "15/03/2024" format-date-time test-date "dd/MM/yyyy" "Custom separators should be preserved"
assert-equal "Time is 14:30" format-date-time test-date "Time is hh:mm" "Mixed literal and pattern text"

;;==============================================================================
;; SECTION 11: PROBING CASE SENSITIVITY
;;==============================================================================

print "^/--- SECTION 11: PROBING CASE SENSITIVITY ---"

uppercase-result: format-date-time test-date "YYYY-MM-DD"
lowercase-result: format-date-time test-date "yyyy-MM-dd"
assert-equal false equal? uppercase-result lowercase-result "Case should matter in patterns"

;;==============================================================================
;; FINAL TEST SUMMARY
;;==============================================================================

print-test-summary
