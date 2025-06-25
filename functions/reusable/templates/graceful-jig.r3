REBOL []

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
        print "✅ ALL TEMPLATE RESOLVER TESTS PASSED"
    ][
        print "❌ SOME TEMPLATE RESOLVER TESTS FAILED"
    ]
    print "============================================^/"
]

print "=== Robust Template Resolution with Popular Datatype Support ==="
print "Problem: Handle all Rebol datatypes in template fields with proper formatting."
print "Solution: Enhanced formatter with specialized handling for each datatype."

;; Template context fields with the supported datatypes:
template-title: "REBOL Programming Guide"          ;; String
template-author: "Expert Developer"                ;; String
template-version: 0.2.1                            ;; Tuple
template-date: 24-Jun-2025                         ;; Date
template-status: true                              ;; Logic
template-tags: ["template" "system" "demo"]        ;; Block
template-revision: 42                              ;; Integer
template-percent: 75%                              ;; Percent
template-price: $19.99                             ;; Money
template-size: 1024x768                            ;; Pair
template-duration: 1:23:45.67                      ;; Time
template-file: %settings.cfg                       ;; File
template-contact: user@example.com                 ;; Email
template-website: http://example.com               ;; URL
template-empty: none                               ;; None

;;-----------------------------------------------------------------------------
;; Enhanced Template Resolution System
;;-----------------------------------------------------------------------------

;; Global formatter function with comprehensive type handling
template-formatter: function [
    "Format values for template output with specialized handling per datatype."
    value [any-type!]
    return: [string!]
][
    case [
        ;;; Existing datatype handling:
        tuple? value [mold value] ;; Use `mold` for tuples.

        date? value [mold value]  ;; Use `mold` for dates.

        block? value [mold value]

        percent? value [form round/to value 0.01]

        money? value [rejoin ["$" form round/to value 0.01]]

        pair? value [
            rejoin [
                either value/x = to integer! value/x [
                    form to integer! value/x
                ][
                    form value/x
                ]
                "x"
                either value/y = to integer! value/y [
                    form to integer! value/y
                ][
                    form value/y
                ]
            ]
        ]

        time? value [
            rejoin [
                next form 100 + value/hour ":"
                next form 100 + value/minute ":"
                next form 100 + to-integer value/second
                either value/second > to-integer value/second [
                    rejoin ["." next form 1000 + to-integer (value/second - to-integer value/second) * 1000]
                ][
                    ""
                ]
            ]
        ]

        file? value [mold value]

        email? value [form value]  ;; Use form for email.

        url? value [mold value]

        ;;; Default handling:
        true [form value]
    ]
]

;;------------------------------------------------------
resolve-template-var: function [
    {USE: Graceful template resolver for popular Rebol datatypes with robust error handling.}
    fld-name [string!] "The field / variable name to resolve (without the 'template-' prefix.)"
    return: [string!] "The resolved value or error message."
][
    full-fld-name: rejoin ["template-" fld-name]
    template-word: to-word full-fld-name

    set/any 'bind-result try [bind template-word system/contexts/user]

    either error? bind-result [
        rejoin ["{{" fld-name " - ~UNDEFINED~}}"]
    ][
        set/any 'resolved-value try [get bind-result]

        either error? resolved-value [
            rejoin ["{{" fld-name " - ~UNDEFINED~}}"]
        ][
            either none? resolved-value [
                rejoin ["{{" fld-name " - ~NONE~}}"]
            ][
                template-formatter resolved-value
            ]
        ]
    ]
]

;;-----------------------------------------------------------------------------
;; Testing Comprehensive Template Resolution
;;-----------------------------------------------------------------------------
print "^/Testing Robust Template Resolution datatype support..."

;; Test Case 1: String handling.
assert-equal "REBOL Programming Guide" resolve-template-var "title" "Resolve string variables"

;; Test Case 2: Tuple formatting.
assert-equal "0.2.1" resolve-template-var "version" "Format tuple values"

;; Test Case 3: Date formatting.
assert-equal "24-Jun-2025" resolve-template-var "date" "Format date values"

;; Test Case 4: Logic handling.
assert-equal "true" resolve-template-var "status" "Convert logic values"

;; Test Case 5: Block serialization.
assert-equal {["template" "system" "demo"]} resolve-template-var "tags" "Serialize block values"

;; Test Case 6: Integer conversion.
assert-equal "42" resolve-template-var "revision" "Convert integer values"

;; Test Case 7: Percent formatting.
assert-equal "75%" resolve-template-var "percent" "Format percent values"

;; Test Case 8: Money formatting.
assert-equal "$19.99" resolve-template-var "price" "Format money values"

;; Test Case 9: Pair formatting.
assert-equal "1024x768" resolve-template-var "size" "Format pair values as integers"

;; Test Case 10: Time formatting.
assert-equal "01:23:45.670" resolve-template-var "duration" "Format time values"

;; Test Case 11: File handling.
assert-equal "%settings.cfg" resolve-template-var "file" "Format file values"

;; Test Case 12: Email handling.
assert-equal "user@example.com" resolve-template-var "contact" "Format email values"

;; Test Case 14: URL handling.
assert-equal "http://example.com" resolve-template-var "website" "Format URL values"

;; Test Case 15: Undefined variable.
assert-equal "{{unknown - ~UNDEFINED~}}" resolve-template-var "unknown" "Handle missing variables"

;; Test Case 16: None value
assert-equal "{{empty - ~NONE~}}" resolve-template-var "empty" "Distinguish undefined vs none values"

;;-----------------------------------------------------------------------------
;; Advanced Example: Complete Template Processing
;;-----------------------------------------------------------------------------
print "^/--- Advanced Example: Complete Template Processing ---"

;; Comprehensive template with all datatypes
comprehensive-template: {Document Metadata:
Title:      {{title}}
Author:     {{author}}
Version:    {{version}} (revision: {{revision}})
Released:   {{date}}
Status:     {{status}} ({{percent}} complete)
Price:      {{price}}
Resolution: {{size}}
Duration:   {{duration}}
File:       {{file}}
Contact:    {{contact}}
Location:   {{location}}
Website:    {{website}}
Tags:       {{tags}}
Empty:      {{empty}}
Missing:    {{unknown}}}

print ["Original template:^/" comprehensive-template]

;; Generic template processor:
process-template: function [
    {Process template with comprehensive datatype support.}
    template [string!] "Template with {{variable}} placeholders."
    return: [string!] "Processed template with resolved fields / variables."
][
    result: copy template
    tags: copy []

    ; Find all template variables
    parse template [
        any [
            to "{{"
            "{{" copy tag to "}}" "}}"
            (append tags tag)
            to "{{" | end
        ]
    ]
    tags: unique tags

    ; Resolve and replace each variable:
    foreach tag tags [
        replace/all result rejoin ["{{" tag "}}"] resolve-template-var tag
    ]

    return result
]

;; Process and output the results:
processed-result: process-template comprehensive-template
print ["^/Processed template:^/" processed-result]

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
