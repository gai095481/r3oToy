REBOL [
    Title: "Multi-Purpose Caching Template Resolver (Corrected Money Formatting)"
    Date: 26-Jun-2025
    Author: "Gemini Pro AI"
    Purpose: {
        A corrected, robust template system that explicitly uses a data
        context object and provides proper two-decimal-place money formatting.
    }
]

;;-----------------------------------------------------------------------------
;; 1. A Battle-Tested QA Harness
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    "Compares an expected value to what our code actually produces."
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
    "Prints a final summary of the entire test run."
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL TEMPLATE RESOLVER TESTS PASSED"
    ][
        print "❌ SOME TEMPLATE RESOLVER TESTS FAILED"
    ]
    print "============================================^/"
]

;;-----------------------------------------------------------------------------
;; 2. The Data Context
;;-----------------------------------------------------------------------------
print "--- Setting up Data Context for Template ---"
data-context: make object! [
    project-name: "Project Phoenix"
    version: 1.5.0
    launched: 15-Mar-2025
    is-active: true
    contributors: ["Alice" "Bob" "Charlie"]
    id: 101
    progress: 80%
    budget: $250000.00
    logo-size: 128x128
    avg-response: 0:00:00.550
    config-file: %phoenix.cfg
    lead-dev: dev@phoenix.team
    repo-url: http://dev.phoenix.team/
    notes: none
]

;;-----------------------------------------------------------------------------
;; 3. The Template Resolution System (CORRECTED FORMATTER)
;;-----------------------------------------------------------------------------

template-formatter: function [
    "Formats a Rebol value into a human-readable string for template output."
    value [any-type!] "The value to be formatted."
    return: [string!]
][
    case [
        tuple? value   [mold value]
        date? value    [mold value]
        block? value   [mold value]
        file? value    [mold value]
        url? value     [mold value]

        money? value [
            ;; This logic correctly formats money to two decimal places.
            ;; It separates the whole number from the cents, formats the cents
            ;; with a leading zero if needed, and joins them back together.
            value: round/to value 0.01
            integer-part: to-integer value
            cents-part: to-integer (100 * (value - integer-part)) + 100
            rejoin ["$" form integer-part "." next form cents-part]
        ]
        percent? value [form value]

        true           [form value]
    ]
]

resolve-template-var: function [
    "Safely retrieve and format a single variable from a data context."
    field-name [string!] "The name of the placeholder (e.g., 'version')."
    context [object!] "The object containing the data."
    return: [string!] "The formatted value or a graceful placeholder."
][
    value: select context to-word field-name

    case [
        not find context to-word field-name [
            rejoin ["{{ " field-name " - UNDEFINED }}" ]
        ]
        none? value [
            rejoin ["{{ " field-name " - NONE }}" ]
        ]
        true [
            template-formatter value
        ]
    ]
]

process-template: function [
    "Process a template string against a data context, using a cache for performance."
    template [string!] "The template string with {{placeholder}} tags."
    context [object!] "The object containing the data."
][
    result: copy template
    all-tags: copy []

    parse template [any [to "{{" "{{" copy tag to "}}" "}}" (append all-tags tag) to "{{" | end]]
    if empty? all-tags [return result]

    unique-tags: unique copy all-tags
    cache: make map! length? unique-tags

    foreach tag unique-tags [
        cache/:tag: resolve-template-var tag context
    ]

    foreach tag unique-tags [
        placeholder: rejoin ["{{" tag "}}"]
        replace/all result placeholder cache/:tag
    ]

    return result
]

;;-----------------------------------------------------------------------------
;; 4. QA Tests
;;-----------------------------------------------------------------------------
print "^/=== Testing Individual Data Type Resolution ==="
assert-equal "Project Phoenix" (resolve-template-var "project-name" data-context) "String resolution"
assert-equal "1.5.0" (resolve-template-var "version" data-context) "Tuple formatting"
assert-equal "15-Mar-2025" (resolve-template-var "launched" data-context) "Date formatting"
assert-equal "true" (resolve-template-var "is-active" data-context) "Logic formatting"
assert-equal {["Alice" "Bob" "Charlie"]} (resolve-template-var "contributors" data-context) "Block formatting"
assert-equal "$250000.00" (resolve-template-var "budget" data-context) "Money formatting"
assert-equal "80%" (resolve-template-var "progress" data-context) "Percent formatting"
assert-equal "dev@phoenix.team" (resolve-template-var "lead-dev" data-context) "Email formatting"
assert-equal "{{ notes - NONE }}" (resolve-template-var "notes" data-context) "Graceful `none` handling"
assert-equal "{{ manager - UNDEFINED }}" (resolve-template-var "manager" data-context) "Graceful `unset` handling"


print "^/--- Testing Full Template Processing with Caching ---"
report-template: {
Project Report: {{project-name}}
Version: {{version}}
Manager: {{manager}}
Notes: {{notes}}
Project again for cache test: {{project-name}}
}

expected-output: {
Project Report: Project Phoenix
Version: 1.5.0
Manager: {{ manager - UNDEFINED }}
Notes: {{ notes - NONE }}
Project again for cache test: Project Phoenix
}

processed-report: process-template report-template data-context

assert-equal expected-output processed-report "Full template processing with caching works correctly"

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
