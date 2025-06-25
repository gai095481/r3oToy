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
        print "✅ ALL `get` PRACTICAL EXAMPLES PASSED"
    ][
        print "❌ SOME `get` PRACTICAL EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; GET FUNCTION: FIVE PRACTICAL EXAMPLES
;;=============================================================================
;; Purpose: Showcase real-world applications of GET for everyday programming.
;; Evidence: Based on validated diagnostic probe showing GET's reliability.
;;=============================================================================
print "=== GET FUNCTION: FIVE PRACTICAL EXAMPLES ==="
print "=== Real-World Problem Solving Scenarios ==="

;;-----------------------------------------------------------------------------
;; PRACTICAL EXAMPLE 1: Configuration Management and Defaults
;;-----------------------------------------------------------------------------
print "^/--- PRACTICAL EXAMPLE 1: Configuration Management ---"
print "Problem: Load configuration with fallback to defaults"
print "Solution: Use GET/any to safely check if config values exist"

;; Simulate partial configuration (some values might be unset)
config-database-host: "localhost"
config-database-port: 5432
;; config-database-timeout intentionally not set (unset)

;; Configuration loader with defaults
get-config-value: function [
    config-key [word!] "Configuration key to retrieve"
    default-value [any-type!] "Default value if config not set"
][
    either unset? get/any config-key [default-value] [get config-key]
]

;; Test the configuration system
assert-equal "localhost" get-config-value 'config-database-host "production" "Config system retrieves set values"
assert-equal 5432 get-config-value 'config-database-port 3306 "Config system handles numeric values"
assert-equal 30 get-config-value 'config-database-timeout 30 "Config system provides defaults for unset values"

;;-----------------------------------------------------------------------------
;; PRACTICAL EXAMPLE 2: API Response Data Extraction
;;-----------------------------------------------------------------------------
print "^/--- PRACTICAL EXAMPLE 2: API Response Processing ---"
print "Problem: Extract specific fields from complex API response objects"
print "Solution: Use GET with paths to navigate nested API data safely"

;; Simulate API response structure
api-response: make object! [
    status: "success"
    data: make object! [
        user: make object! [
            id: 12345
            profile: make object! [
                name: "John Doe"
                email: "john@example.com"
                preferences: make object! [
                    theme: "dark"
                    notifications: #(true)
                ]
            ]
        ]
        metadata: make object! [
            timestamp: "2025-06-24T22:22:00Z"
            version: "v2.1"
        ]
    ]
]

;; Extract specific data points using GET
user-id: get 'api-response/data/user/id
user-email: get 'api-response/data/user/profile/email
user-theme: get 'api-response/data/user/profile/preferences/theme
api-version: get 'api-response/data/metadata/version

assert-equal 12345 user-id "GET extracts user ID from nested API response"
assert-equal "john@example.com" user-email "GET navigates deep API object paths"
assert-equal "dark" user-theme "GET accesses deeply nested preference data"
assert-equal "v2.1" api-version "GET retrieves metadata from API responses"

;;-----------------------------------------------------------------------------
;; PRACTICAL EXAMPLE 3: Dynamic Property Inspector
;;-----------------------------------------------------------------------------
print "^/--- PRACTICAL EXAMPLE 3: Object Property Inspector ---"
print "Problem: Build debugging tools that inspect object properties"
print "Solution: Use GET with objects to extract all values for analysis"

;; Sample object to inspect
user-account: make object! [
    username: "alice123"
    balance: 1500.75
    active: #(true)
    last-login: "2025-06-23"
]

;; Property inspector function
inspect-object: function [
    obj [object!] "Object to inspect"
    return: [block!] "Block containing property analysis"
][
    all-values: get obj
    analysis: make object! [
        value-count: length? all-values
        has-strings: #(false)
        has-numbers: #(false)
        has-logic: #(false)
        foreach value all-values [
            if string? value [has-strings: #(true)]
            if any [integer? value decimal? value] [has-numbers: #(true)]
            if logic? value [has-logic: #(true)]
        ]
    ]
    reduce [analysis all-values]
]

inspection-result: inspect-object user-account
analysis: first inspection-result
extracted-values: second inspection-result

assert-equal 4 analysis/value-count "Inspector counts object properties correctly"
assert-equal #(true) analysis/has-strings "Inspector detects string properties"
assert-equal #(true) analysis/has-numbers "Inspector detects numeric properties"
assert-equal #(true) analysis/has-logic "Inspector detects logic properties"

;;-----------------------------------------------------------------------------
;; PRACTICAL EXAMPLE 4: Error-Safe Data Pipeline
;;-----------------------------------------------------------------------------
print "^/--- PRACTICAL EXAMPLE 4: Safe Data Pipeline Processing ---"
print "Problem: Process data through pipeline with error handling"
print "Solution: Use GET/any to safely check intermediate results"

;; Pipeline data storage
pipeline-step-1: "raw-data-processed"
pipeline-step-2: "validation-complete"
;; pipeline-step-3 intentionally missing (error condition)

;; Safe pipeline processor
check-pipeline-step: function [
    step-num [integer!] "Pipeline step number to check"
    return: [logic!] "True if step completed successfully"
][
    ;; Use explicit checks instead of dynamic word construction
    switch step-num [
        1 [not unset? get/any 'pipeline-step-1]
        2 [not unset? get/any 'pipeline-step-2]
        3 [not unset? get/any 'pipeline-step-3]
        default [false]
    ]
]

;; Pipeline status checker
pipeline-status: function [
    max-steps [integer!] "Total number of pipeline steps"
    return: [block!] "Status report [completed-steps total-steps all-complete?]"
][
    completed-count: 0
    repeat i max-steps [
        if check-pipeline-step i [completed-count: completed-count + 1]
    ]
    reduce [completed-count max-steps completed-count = max-steps]
]

status: pipeline-status 3
assert-equal 2 first status "Pipeline correctly counts completed steps"
assert-equal 3 second status "Pipeline correctly reports total steps"
assert-equal #(false) third status "Pipeline correctly detects incomplete status"

;;-----------------------------------------------------------------------------
;; PRACTICAL EXAMPLE 5: Multi-Source Data Aggregator
;;-----------------------------------------------------------------------------
print "^/--- PRACTICAL EXAMPLE 5: Data Source Aggregation ---"
print "Problem: Aggregate data from multiple sources with different schemas"
print "Solution: Use GET with paths to normalize different data structures"

;; Different data source schemas
source-a: make object! [
    user-data: make object! [
        full-name: "Alice Johnson"
        contact-email: "alice@example.com"
    ]
]

source-b: make object! [
    profile: make object! [
        name: "Bob Smith"
        email: "bob@example.com"
    ]
]

;; Data aggregator that normalizes different schemas
extract-user-info: function [
    source [object!] "Data source object"
    name-path [path!] "Path to name field"
    email-path [path!] "Path to email field"
    return: [object!] "Normalized user info"
][
    make object! [
        name: get name-path
        email: get email-path
    ]
]

;; Extract normalized data from different sources
user-a: extract-user-info source-a 'source-a/user-data/full-name 'source-a/user-data/contact-email
user-b: extract-user-info source-b 'source-b/profile/name 'source-b/profile/email

assert-equal "Alice Johnson" user-a/name "Aggregator extracts name from source A schema"
assert-equal "alice@example.com" user-a/email "Aggregator extracts email from source A schema"
assert-equal "Bob Smith" user-b/name "Aggregator extracts name from source B schema"
assert-equal "bob@example.com" user-b/email "Aggregator extracts email from source B schema"

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
