REBOL FUNCTION PROBE DIAGNOSTIC AND DOCUMENTATION PLAYBOOK
Evidence-Based Methodology for Creating High-Quality Function Documentation

PREREQUISITES
Access to REBOL/Bulk 3.19.0 (Oldes Branch).

Output from help [function-name] command.

Commitment to strict two-step validation process.

CORE PRINCIPLES
"Truth from the REPL" - No assumptions, only validated behavior.

Evidence-Based Documentation - Every claim backed by working code.

Systematic Testing - Cover all arguments, refinements and edge cases.

Error-Free Scripts - All deliverables must run without errors.

STEP 1: THE DIAGNOSTIC PROBE SCRIPT
Objective: Prove understanding through systematic testing.

1.1 Script Structure Template
```
REBOL []
print "=== DIAGNOSTIC PROBE SCRIPT FOR '[FUNCTION-NAME]' FUNCTION ==="
print "=== Using Battle-Tested QA Harness ==="
print NEWLINE

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

assert-error: function [
    {Confirm that a block of code correctly throws an error.}
    code-to-run [block!] "The code block expected to error."
    description [string!] "A description of the specific QA test being run."
][
    result: try code-to-run
    either error? result [
        print ["✅ PASSED:" description]
    ][
        set 'all-tests-passed? false
        print ["❌ FAILED:" description "^/   >> Expected an error, but none occurred."]
    ]
]

print-test-summary: does [
    {Prints the final summary of the entire test run.}
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL `take` EDGE CASE TESTS PASSED"
    ][
        print "❌ SOME `take` EDGE CASE TESTS FAILED"
    ]
    print "============================================^/"
]

;;=============================================================================
;; SECTION 1: Probing basic [FUNCTION-NAME] behavior
;;=============================================================================
[Systematic tests with assert-equal statements]
```

1.2 Testing Categories to Include
Basic behavior with different data types (block!, string!, binary!, etc.)

All refinements individually tested.

Refinement combinations where applicable.

Edge cases (empty series, single elements, boundary values).

Error conditions (invalid inputs, type mismatches).

Return value types verification.

Series positioning behavior if applicable.

1.3 Hypothesis-Driven Testing
State clear hypothesis before each test section.

Use `assert-equal` expected actual description format.

Group related tests logically.

Include `print-test-summary` at the end of each script.

1.4 Validation Requirement
Script must run 100% error-free.

All tests must pass (✅ ALL [function-name] EXAMPLES PASSED).

STOP HERE until validation complete.

STEP 2: THE FOUR DOCUMENTATION SCRIPTS
Objective: Create comprehensive tutorials based on validated evidence.

2.1 Happy Path Examples Script
Purpose: Most common, simple, and correct uses.

Content Requirements:

Minimum of six fundamental / "happy path" usage patterns.

Clean, idiomatic Rebol 3 Oldes code.

Detailed comments explaining basic usage patterns.

Examples that "just work" for newcomers.

Template Structure:

;;=============================================================================
;; [FUNCTION-NAME]: BASIC / HAPPY PATH EXAMPLES
;;=============================================================================
;; Purpose: Demonstrate the most common, simple and correct uses.
;; Evidence: Based on validated diagnostic probe results.
;;=============================================================================

;;-----------------------------------------------------------------------------
;; EXAMPLE 1: [Fundamental usage description]
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 1: [Clear descriptive title] ---"
print "[Purpose and context explanation]"
[Working code example with clear comments]

2.2 Practical Examples Script
Purpose: Real-world problem solving scenarios.

Content Requirements:

Minimum of ten practical, highly-useful, real-world examples.

Self-contained problem/solution pairs.

Context explaining why the function is the right choice.

Examples of chaining with other functions.

2.3 Unintuitive Behavior Script
Purpose: Document sharp edges and quirks.

Content Requirements:

All unexpected behaviors discovered during probe phase.

Clear demonstrations of non-obvious behavior.

Explanations of WHY the behavior occurs.

Practical implications for developers.

2.4 Edge Case Examples Script
Purpose: Boundary conditions and unusual inputs.

Content Requirements:

Empty series handling.

Single element scenarios.

Boundary value testing.

Mixed data type handling.

Complex nested structures.

EXECUTION CHECKLIST
Phase 1: Preparation

[ ] Obtain help [function-name] output.

[ ] Review function signature and refinements.

[ ] Identify all datatypes the function accepts.

Phase 2: Diagnostic Development

[ ] Create diagnostic probe script with QA harness.

[ ] Include systematic tests for all behaviors.

[ ] Add clear hypotheses for each test section.

[ ] Ensure script is 100% error-free.

Phase 3: Validation Gate

[ ] Run diagnostic script in Rebol environment.

[ ] Verify all test cases pass.

[ ] Analyze any unexpected behaviors.

[ ] DO NOT PROCEED until validation complete.

Phase 4: Documentation Creation
[ ] Create Happy Path Examples script.

[ ] Create Practical Examples script.

[ ] Create Unintuitive Behavior script.

[ ] Create Edge Case Examples script.

[ ] Ensure all scripts are heavily commented.

Phase 5: Quality Assurance

[ ] Test all five scripts run error-free.

[ ] Verify documentation accuracy against probe results.

[ ] Ensure examples are practical and educational.

SUCCESS CRITERIA
Five error-free scripts that run from top to bottom.

All behaviors documented are backed by validated evidence.

No assumptions made - everything proven through testing.

Comprehensive coverage of function capabilities and limitations.

Developer-friendly documentation suitable for other Rebol programmers.

COMMON PITFALLS TO AVOID
Skipping validation - Never proceed to Step 2 without validated probe results.

Making assumptions - Test everything, assume nothing.

Incomplete testing - Cover all refinements and edge cases.

Poor commenting - Explain both WHAT and WHY.

Declaring victory prematurely - Ensure all scripts actually work.
