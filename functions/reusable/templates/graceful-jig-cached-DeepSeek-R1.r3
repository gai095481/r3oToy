REBOL [
    Title: "Multi-Purpose Caching Template Field Resolver"
    Date: 26-Jun-2025
    Author: "DeepSeek R1 and human orchestrator"
    Purpose: {
        A robust cached template (macro), field resolver system
        supporting most popualar Rebol 3 Oldes datatypes.
    }
]

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "The QA test type description."
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
    {Print the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL TEMPLATE RESOLVER TESTS PASSED"
    ][
        print "❌ SOME TEMPLATE RESOLVER TESTS FAILED"
    ]
    print "============================================^/"
]

print "=== Graceful Template Field Resolver with Popular Datatype Support ==="
print "Problem: Handle most Rebol datatypes in template fields with proper formatting."
print "Solution: Enhanced formatter with specialized handling and intelligent caching."

;; Template context fields with most supported datatypes:
template-title: "REBOL Programming Guide"          ;; string
template-author: "Expert Developer"                ;; string
template-version: 0.2.1                            ;; tuple
template-date: 24-Jun-2025                         ;; date
template-status: true                              ;; logic / bool
template-tags: ["template" "system" "demo"]        ;; block
template-revision: 42                              ;; integer
template-percent: 75%                              ;; percent
template-price: $19.99                             ;; money
template-size: 1024x768                            ;; pair
template-duration: 1:23:45.67                      ;; time
template-file: %settings.cfg                       ;; file
template-contact: user@example.com                 ;; email
template-website: http://example.com               ;; URL
template-empty: none                               ;; none

;;-----------------------------------------------------------------------------
;; Graceful cache-based Template Field Resolution System
;;-----------------------------------------------------------------------------
;; Global formatter function with comprehensive datatype handling:
template-formatter: function [
    "Format field values for template output with specialized handling per datatype."
    value [any-type!]
    return: [string!]
][
    case [
        ;;; Specialized datatype handling:
        tuple? value [mold value]

        date? value [mold value]

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

        email? value [form value]

        url? value [mold value]

        ;;; Default datatype handling:
        true [form value]
    ]
]

;; Enhanced template resolver with datatype support
resolve-template-var: function [
    {Comprehensive resolver for popular Rebol datatypes with robust error handling.}
    fld-name [string!] "Variable / field name to resolve (without the 'template-' prefix.)"
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
;; Optimized Template Processor with Intelligent Caching
;;-----------------------------------------------------------------------------
process-template: function [
    {Process template with popular datatype support and resolution caching.}
    template [string!] "Template with macro {{variable}} placeholders."
][
    ;; Create a working copy of the template:
    result: copy template

    ;; Phase 1: Collect all tags from template:
    tags: make block! 20  ; Pre-size for efficiency
    parse template [
        any [
            to "{{"
            "{{" copy tag to "}}" "}}"
            (append tags tag)
            to "{{" | end
        ]
    ]

    ;; Get the unique tags to minimize resolutions:
    unique-tags: unique tags

    ;; Phase 2: Build resolution cache:
    cache: make map! []
    foreach tag unique-tags [
        ;; Cache stores resolved string values:
        cache/:tag: resolve-template-var tag
    ]

    ;; Phase 3: Efficient replacement using cache:
    foreach tag tags [
        replace/all result rejoin ["{{" tag "}}"] cache/:tag
    ]

    return result
]

;;-----------------------------------------------------------------------------
;; Testing Comprehensive Template Resolution
;;-----------------------------------------------------------------------------
print "^/=== Testing popular datatype support ==="

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

;; Test Case 6: Integer conversion
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

;; Test Case 13: URL handling.
assert-equal "http://example.com" resolve-template-var "website" "Format URL values"

;; Test Case 14: Undefined variable.
assert-equal "{{unknown - ~UNDEFINED~}}" resolve-template-var "unknown" "Handle missing variables"

;; Test Case 15: `none` value.
assert-equal "{{empty - ~NONE~}}" resolve-template-var "empty" "Distinguish undefined vs none values"

;; Test Case 16: Verify cache respects value modifications.
template-version: 0.2.1
result1: process-template "Version: {{version}}"
template-version: 1.0.0
result2: process-template "Version: {{version}}"
assert-equal "Version: 0.2.1" result1 "Cache isolation in first run"
assert-equal "Version: 1.0.0" result2 "Cache updates in second run"

;;-----------------------------------------------------------------------------
;; Advanced Example: Complete Template Processing
;;-----------------------------------------------------------------------------
print "^/=== Advanced Example: Complete Template Processing ==="

;; Comprehensive template with most datatypes:
comprehensive-template: {Document Metadata:
Title:      {{title}}
Author:     {{author}}
Version:    {{version}} (revision: {{revision}})
Released:   {{date}}
Status:     {{status}} ({{percent}} complete)
Price:      {{price}}
Resolution: {{size}}
Duration:   {{duration}}
Config:     {{file}}
Contact:    {{contact}}
Website:    {{website}}
Tags:       {{tags}}
Empty:      {{empty}}
Missing:    {{unknown}}}

print ["Original template:^/" comprehensive-template]

;; Process and output the results
processed-result: process-template comprehensive-template
print ["^/Processed template:^/" processed-result]

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
