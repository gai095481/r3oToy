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
        print "✅ ALL TEMPLATE RESOLVER EXAMPLES PASSED"
    ][
        print "❌ SOME TEMPLATE RESOLVER EXAMPLES FAILED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; GET FUNCTION: PRACTICAL EXAMPLE
;;=============================================================================
;; Purpose: Demonstrate dynamic variable resolution using GET with proper binding
;; Key Learning: How to handle binding failures for non-existent variables
;;=============================================================================
print "=== GET FUNCTION: PRACTICAL EXAMPLE 4 (CORRECTED VERSION) ==="
print "=== Template Variable Resolution with Robust Error Handling ==="

;;-----------------------------------------------------------------------------
;; PRACTICAL EXAMPLE: Graceful Template Variable Resolver
;;-----------------------------------------------------------------------------
print "^/--- PRACTICAL EXAMPLE: Graceful Template Variable Resolution ---"
print "Problem: Gracefully resolve template variables dynamically with robust error handling."
print "Solution: Protect both binding and GET operations from syntax error failures."

;; Template context variables existing in the global context:
template-title: "REBOL Programming Guide"
template-author: "Expert Developer"
template-version: "2.1"
template-date: "2025-06-24"

;; Template resolver function with corrected error handling:
resolve-template-var: function [
    {USE: Resolve template variables dynamically using GET with protected binding.

    Demonstrate how to safely resolve variable names constructed at runtime.
    The key insight is that both word binding and GET
    operations can fail, so both need protection in Rebol 3 Oldes.

    RETURNS: String value of resolved variable or error message for undefined variables.
    ERRORS: None - all errors are caught and converted to descriptive messages.}
    var-name [string!] "Variable name to resolve (without 'template-' prefix)."
    return: [string!] "Resolved value or error message."
][
    ;; Step 1: Construct the full variable name:
    full-var-name: rejoin ["template-" var-name]

    ;; Step 2: Create a word from the string:
    template-word: to-word full-var-name

    ;; Step 3: Attempt binding with error protection:
    ;; In Rebol 3 Oldes, BIND itself can fail for non-existent variables.
    set/any 'bind-result try [bind template-word system/contexts/user]

    either error? bind-result [
        ;; Binding failed - the variable definitely doesn't exist.
        rejoin ["{{" var-name " - UNDEFINED}}"]
    ][
        ;; Binding succeeded - now try to get the value:
        set/any 'resolved-value try [get bind-result]

        either error? resolved-value [
            ;; GET failed - variable exists in context but has no value:
            rejoin ["{{" var-name " - UNDEFINED}}"]
        ][
            ;; GET succeeded - handle the value appropriately:
            either none? resolved-value [
                rejoin ["{{" var-name " - NONE}}"]
            ][
                ;; Convert whatever we got to a string for template use:
                to-string resolved-value
            ]
        ]
    ]
]

;;-----------------------------------------------------------------------------
;; Testing the Corrected Template Resolution System
;;-----------------------------------------------------------------------------
print "^/Testing graceful template variable resolution..."

;; Test Case 1: Existing string variable.
assert-equal "REBOL Programming Guide" resolve-template-var "title" "Resolve existing string template variables correctly"

;; Test Case 2: Another existing string variable
assert-equal "Expert Developer" resolve-template-var "author" "Handle different string template variables"

;; Test Case 3: Non-string variable (number as string)
assert-equal "2.1" resolve-template-var "version" "Convert non-string values to strings properly"

;; Test Case 4: Date string variable
assert-equal "2025-06-24" resolve-template-var "date" "Process date string template variables"

;; Test Case 5: Undefined variable (this should now work!)
assert-equal "{{unknown - UNDEFINED}}" resolve-template-var "unknown" "Handles missing variables with appropriate error message"

;; Test Case 6: None value handling
template-empty: none
assert-equal "{{empty - NONE}}" resolve-template-var "empty" "Distinguish between undefined variables and none values"

print "^/--- Key Insight: Binding Can Fail in Rebol 3 Oldes ---"
print "This graceful version demonstrates:"
print "1. The 'bind' function itself can fail for non-existent variables."
print "2. We must protect BOTH binding and GET operations."
print "3. Proper error handling requires nested try blocks."
print "4. Different error types need different handling strategies."

;;-----------------------------------------------------------------------------
;; Advanced Example: Complete Template Processing
;;-----------------------------------------------------------------------------
print "^/--- Advanced Example: Complete Template Processing ---"
;; A simple template string with multiple variables:
sample-template: {Document Title: {{title}}
Written by: {{author}}
Version: {{version}}
Date: {{date}}
Status: {{status}}}

print ["Original template:^/" sample-template]

;; Simple template processor using the corrected resolver:
process-template: function [
    {USE: Process a template string by resolving all {{variable}} patterns.

    Use the `resolve-template-var` function to properly handle
    binding failures in Rebol 3 Oldes to ensure robust template processing
    even with undefined variables.

    RETURNS: Processed template string with variables gracefully resolved.
    ERRORS: None - undefined variables are replaced with error messages.}
    template [string!] "Template string with {{variable}} placeholders."
    return: [string!] "Processed template with resolved variables."
][
    ;; Make a copy to avoid modifying the original:
    result: copy template

    ;; Replace each template variable using the corrected resolver:
    replace/all result "{{title}}" resolve-template-var "title"
    replace/all result "{{author}}" resolve-template-var "author"
    replace/all result "{{version}}" resolve-template-var "version"
    replace/all result "{{date}}" resolve-template-var "date"
    replace/all result "{{status}}" resolve-template-var "status"

    return result
]

;; Process the template and output the result:
processed-result: process-template sample-template
print ["^/Processed template:^/" processed-result]

;;=============================================================================
;; FINAL TEST SUMMARY
;;=============================================================================
print-test-summary
