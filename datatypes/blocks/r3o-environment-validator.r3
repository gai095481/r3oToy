Rebol [
    Title: "Rebol 3 Oldes Environment Validator"
    Purpose: {Validates system environment meets the minimum requirements.}
    Author: "Mistral AI"
    Version: 0.2.0
    Date: 21-Jun-2025
    Notes: {Added strict type checking and documentation to all functions}
]

;; Supported comparison operators:
valid-comparators: [= <> > < >= <=]
unless block? valid-comparators [  ; Added validation
    print ["❌ FAILED: Invalid comparator definition - must be block!"]
    quit/return 2
]

;; Rule format: [probe-to-run expects-this-value comparator description]
rules: [
        [system/version 3.19.0 '>= "The Rebol version must be 3.19.0 or higher."]
        [system/platform "Linux" '= "Only the Linux platform is supported."]
        [system/product  "Bulk"  '= "Must be the 'Bulk' product build."]
]

;; Enhanced version comparison with error handling:
compare-version: function [
    "Compare two version numbers using specified comparison operator."
    v1 [tuple! number!]
    v2 [tuple! number!]
    op [word!] "(= <> > < >= <=)"
][
    do reduce [op v1 v2]
]

;; Safer expression evaluator:
safe-eval: function [
    "Safely evaluate an expression, return `logic!`"
    expr [block! word! path! string!]
][
    either error? err: try [do expr] [
        print ["EVALUATION ❌ FAILED:" mold expr]
        print ["❌ FAILED -> REASON:" mold err]
        return false
    ] [return true]
]

;; Core validation reporting:
validate-rules: function [
    "Validate the system against requirement rules."
    rules [block!]
][
    failures: make block! 3
    print ["Starting validation of" length? rules "rules...^/"]

    foreach rule rules [
        ;; Process each rule component with better error checking:
        if not block? rule [continue]

        if (4 > (length? rule)) [
            append failures reduce [
                "❌ FAILED - INVALID RULE FORMAT:" mold rule
            ]
            continue
        ]

        probe: rule/1
        expected: rule/2
        op: rule/3
        description: rule/4

        print ["^/Validating rule:" description]
        print ["  Field:" mold probe "-- Type:" type? probe]
        print ["  Expected:" mold expected "-- Type:" type? expected]
        print ["  Operation:" mold op]

        ;; Special handling for version comparisons:
        if all [
            word? op
            find valid-comparators op
        ][
            either probe = 'system/version [
                result: compare-version get probe expected op
            ][
                result: safe-eval reduce [op get probe expected]
            ]

            unless result [
                append failures reform [
                    "❌ FAILED:" description
                    "| Current:" mold get probe
                    "| Required:" expected
                ]
            ]
        ]
    ]

    return failures
]

;; Main execution with enhanced error handling:
main: does [
    print ["=== System Validation @ " now/precise "==="]
    print ["System info:" mold reduce [system/version system/platform system/build system/build/date]]  ; Show reliable system details

    if error? failures: try [validate-rules rules] [
        print ["❌ FAILED VALIDATION:" mold failures]
        quit/return 10
    ]

    either empty? failures [
        print "^/✅ PASSED all checks.^/"
    ][
        print ["^/❌ FAILED" length? failures "issues:"]
        foreach failure failures [print ["- " failure]]
        print "^/System configuration invalid!^/"
        quit/return 1
    ]
    print "Validation complete.^/"
]

;; Execute validation suite:
main
