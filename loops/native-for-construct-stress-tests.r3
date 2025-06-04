REBOL [
    Title: "REBOL 3 Oldes Native `for` Loop Construct - Comprehensive Test Suite and Analysis"
    Date: 03-Jun-2025
    File: %native-for-stress-tests.r3
    Oldes-Note: "REBOL 3 Oldes refers to a specific community-driven branch of REBOL 3, and REBOL/Bulk 3.19.0 is a particular build from this lineage, known for certain behaviors tested herein."
    Author: "Lutra AI and Claude 4 Sonnet AI"
    Version: "1.1.0"
    Status: "Reviewed and updated based on AI code review."
    Purpose: {
        Provides a comprehensive test suite and detailed analysis of REBOL 3 Oldes's
        native `for` loop construct. This script documents both successful and
        problematic behaviors to serve as a reference and guide for developers.
        It includes tests for:
        - Basic ascending and descending integer loops.
        - Various step values (positive, negative, larger steps).
        - Single and zero iteration boundary conditions.
        - Edge cases like zero start values and negative ranges.
        - Fractional number iteration, highlighting precision issues with small steps.
        - Scope safety, specifically investigating the loop variable's state after execution.
        - (Conceptually) Zero step protection, noting the critical failure (hang) of native `for`.
        The script uses a local test framework to run and report on each case.
        It concludes with an assessment summary and recommendations for using a
        safer wrapper (such as `safe-for`), in production code.
    }
    Notes: {
        This script is intended to be a definitive reference for the behavior of
        the native `for` loop in REBOL/Bulk 3.19.0.  It meticulously tests various
        scenarios and clearly identifies known issues, such as floating-point
        precision errors with small decimal steps and the critical flaw of
        variable scope leakage (loop variable not restored).
        The test for zero step is commented out due to its potential to hang the system.
        The script includes a detailed commentary on the practical implications of these
        behaviors and when a `safe-for` wrapper is essential, considering common
        programming patterns in scientific computing, financial systems, complex
        state management, and applications handling dynamic or external input.
    }
    Keywords: [
        rebol rebol3 native-for for-loop test-suite stress-test documentation
        analysis iteration boundary-conditions edge-cases scope-safety
        floating-point-precision zero-step infinite-loop variable-leakage
        oldes-branch REBOL/Bulk safe-for recommendation
    ]
    Security-Considerations: {
        1. Denial of Service (DoS): The native `for` loop's lack of zero-step protection (Test 14)
           is a critical flaw. If loop parameters (start, end, step) are derived from
           unvalidated external/untrusted input, an attacker can supply a step of zero,
           causing the script to hang indefinitely, leading to a Denial of Service.
           Always validate inputs when they control loop parameters. The provided
           `safe-for` stub includes a check for zero step.

        2. Variable Scope Leakage: The failure to restore the loop variable's original
           value (Test 13) can lead to unpredictable behavior and subtle bugs.
           In complex applications, if the leaked variable holds sensitive data or
           influences security-critical logic later in the program flow, this could
           indirectly contribute to information leakage or flawed access control.
           The `safe-for` stub demonstrates scope preservation.

        3. Floating-Point Precision: Inaccuracies with small fractional steps (Test 11)
           can lead to incorrect loop execution counts. If such loops are used in
           contexts involving financial calculations, resource allocation, or threshold-based
           security decisions, these inaccuracies could result in exploitable logic errors.
           Using a robust decimal arithmetic library or careful comparison (e.g., epsilon
           comparison as in `safe-for`) is advised for such cases.
    }
]


; test-state: Global object to track test execution progress and results.
; While global state is generally minimized, it's practical for this
; self-contained test script.
test-state: make object! [
    current-test-num: 1
    pass-count: 0
    fail-count: 0
    test-results: []
]

; Test runner function with improved error handling:
run-test: function [
    test-name [string!]
    test-code [block!]
    expected-result [any-type!]
    /local result success error-msg
][
    ; Access state through context object
    print ["TEST" test-state/current-test-num ":" test-name]
    test-state/current-test-num: test-state/current-test-num + 1

    ; Execute the test code, capturing normal result or error object
    ; `try/with` is used for robust error trapping.
    set/any 'result try/with test-code func [error] [error]
    error-msg: none

    ; Case 1: Test code produced an error object.
    either error? :result [
        ; Case 1a: Error occurred, but no error was expected.
        either not error? expected-result [
            error-msg: reform ["Got error:" result/id "but expected:" mold expected-result]
            success: false
        ][
            ; Case 1b: Error occurred, and an error was expected.
            ; Compare the error IDs for equality.
            success: (result/id = expected-result/id)
            if not success [
                error-msg: reform ["Got error:" result/id "but expected error:" expected-result/id]
            ]
        ]
    ][
        ; Case 2: Test code did NOT produce an error object (got a normal result).
        either error? expected-result [
            ; Case 2a: No error occurred, but an error was expected.
            error-msg: reform ["Expected error:" expected-result/id "but got:" mold result]
            success: false
        ][
            ; Case 2b: No error occurred, and a normal result was expected.
            ; Standard equality check for non-error results.
            success: equal? :result expected-result
            if not success [
                error-msg: reform ["Expected:" mold expected-result "but got:" mold :result]
            ]
        ]
    ]

    ; Report test results
    either success [
        print "   PASS"
        test-state/pass-count: test-state/pass-count + 1
        append test-state/test-results reduce [test-name "PASS" none]
    ][
        print ["   FAIL -" error-msg]
        test-state/fail-count: test-state/fail-count + 1
        append test-state/test-results reduce [test-name "FAIL" error-msg]
    ]
    print ""
]

; --- Safe-For Wrapper (Conceptual Implementation) ---
; The following 'safe-for' is a conceptual stub. A robust implementation
; would be required for production use. It illustrates the key safety
; features discussed in this test suite's recommendations.

safe-for: func [
    "Safely iterates a variable from start to end by a step value."
    word [word!]            "Word to set (loop variable)"
    start [any-number!]     "Starting value"
    end [any-number!]       "Ending value"
    step [any-number!]      "Step value"
    body [block!]           "Block to evaluate for each step"
    /local original-value current-value effective-step
           loop-condition comparison-adjustment
] [
    if zero? step [
        cause-error 'script 'invalid-arg "safe-for: Step value cannot be zero."
    ]

    original-value: either bound? word [get word] [none]
    current-value: start
    effective-step: step

    ; Adjust comparison for floating point numbers to avoid precision pitfalls
    ; This is a simplified epsilon comparison; robust versions might be more complex.
    comparison-adjustment: either all [decimal? effective-step effective-step <> 0] [
        abs effective-step * 0.00000001 ; Small epsilon
    ] [0]

    loop-condition: either effective-step > 0 [
        [to-logic :current-value <= (:end + :comparison-adjustment)]
    ] [
        [to-logic :current-value >= (:end - :comparison-adjustment)]
    ]

    while loop-condition [
        set word current-value
        do body
        current-value: current-value + effective-step
    ]

    ; Restore original value or unbind if it was not bound before
    either original-value [
        set word original-value
    ] [
        if find words-of self word [unset word] ; Unset only if it became global
    ]
    unset 'current-value ; Clean up local
]

comment {
    Key features of a robust `safe-for`:
    1. Zero-Step Check: Explicitly disallows a step of 0 to prevent infinite loops.
    2. Scope Preservation: Stores the loop variable's original value (if any) and
       restores it after the loop, preventing leakage.
    3. Floating-Point Precision Handling: For decimal steps, incorporates an
       epsilon comparison or similar technique to mitigate precision errors near
       the loop boundary (the example above uses a simplified adjustment).
    4. Compatibility: Aims to be a mostly drop-in replacement for native `for`
       for common use cases, while adding safety.
}
; --- End of Safe-For Wrapper ---

print "=== REBOL 3 OLDES NATIVE FOR LOOP TEST SUITE ==="
print ["Started at:" now]
print ""
print "=== BASIC FUNCTIONALITY TESTS ==="
print ""

; Note on Test Structure:
; Each test's execution block is wrapped in `do function [] [...]`.
; This ensures that variables like `i` and `result` used within the
; test logic are local to that specific test, preventing unintended
; interactions or state leakage between tests. This is a standard
; practice for creating self-contained test units.

;-------------------------------------------------------------------
; Test 1: Basic ascending loop 1-5.
; Purpose: Verify the FOR loop correctly iterates from 1 to 5 with a step of 1
; Expected behavior: Successfully iterates through all values 1,2,3,4,5
; Result with native FOR: PASS
; Notes: Basic integer counting works correctly with native FOR.
;-------------------------------------------------------------------
run-test "Basic ascending loop 1-5" [
    do function [] [
        i: 0
        result: []
        for i 1 5 1 [append result i]
        result
    ]
] [1 2 3 4 5]

;-------------------------------------------------------------------
; Test 2: Basic descending loop 5-1.
; Purpose: Verify the FOR loop correctly iterates from 5 to 1 with a step of -1
; Expected behavior: Successfully iterates through all values 5,4,3,2,1
; Result with native FOR: PASS
; Notes: Basic integer countdown works correctly with native FOR.
;-------------------------------------------------------------------
run-test "Basic descending loop 5-1" [
    do function [] [
        i: 0
        result: []
        for i 5 1 -1 [append result i]
        result
    ]
] [5 4 3 2 1]

;-------------------------------------------------------------------
; Test 3: Step by 2 (1-10).
; Purpose: Verify the FOR loop correctly handles non-1 step values.
; Expected behavior: Iterates through odd values from 1 to 9.
; Result with native FOR: PASS
; Notes: Integer step values other than 1 work correctly.
;-------------------------------------------------------------------
run-test "Step by 2 (1-10)" [
    do function [] [
        i: 0
        result: []
        for i 1 10 2 [append result i]
        result
    ]
] [1 3 5 7 9]

;-------------------------------------------------------------------
; Test 4: Step by -2 (10-1).
; Purpose: Verify the FOR loop correctly handles negative non-1 step values.
; Expected behavior: Iterates through even values from 10 to 2
; Result with native FOR: PASS
; Notes: Negative integer step values other than -1 work correctly.
;-------------------------------------------------------------------
run-test "Step by -2 (10-1)" [
    do function [] [
        i: 0
        result: []
        for i 10 1 -2 [append result i]
        result
    ]
] [10 8 6 4 2]

;-------------------------------------------------------------------
; Test 5: Single iteration (5-5)
; Purpose: Verify the FOR loop correctly handles start=end case
; Expected behavior: Performs exactly one iteration when start equals end
; Result with native FOR: PASS
; Notes: Boundary condition where start equals end works correctly
;-------------------------------------------------------------------
run-test "Single iteration (5-5)" [
    do function [] [
        i: 0
        result: []
        for i 5 5 1 [append result i]
        result
    ]
] [5]

;-------------------------------------------------------------------
; Test 6: Zero iterations (5-1 with +1)
; Purpose: Verify the FOR loop correctly handles cases where no iterations should occur
; Expected behavior: Performs zero iterations when loop conditions prevent entry
; Result with native FOR: PASS
; Notes: Early termination condition works correctly (ascending loop with end < start)
;-------------------------------------------------------------------
run-test "Zero iterations (5-1 with +1)" [
    do function [] [
        i: 0
        result: []
        for i 5 1 1 [append result i]
        result
    ]
] []

print "=== EDGE CASE TESTS ==="
print ""

;-------------------------------------------------------------------
; Test 7: Zero as start (0-3)
; Purpose: Verify the FOR loop correctly handles zero as a start value
; Expected behavior: Iterates from 0 to 3 correctly
; Result with native FOR: PASS
; Notes: Zero as a boundary value works correctly
;-------------------------------------------------------------------
run-test "Zero as start (0-3)" [
    do function [] [
        i: 100
        result: []
        for i 0 3 1 [append result i]
        result
    ]
] [0 1 2 3]

;-------------------------------------------------------------------
; Test 8: Negative range (-3 to -1)
; Purpose: Verify the FOR loop correctly handles negative number ranges
; Expected behavior: Iterates through negative values from -3 to -1
; Result with native FOR: PASS
; Notes: Negative number ranges work correctly
;-------------------------------------------------------------------
run-test "Negative range (-3 to -1)" [
    do function [] [
        i: 0
        result: []
        for i -3 -1 1 [append result i]
        result
    ]
] [-3 -2 -1]

;-------------------------------------------------------------------
; Test 9: Large step (1-100 by 25)
; Purpose: Verify the FOR loop correctly handles large step values
; Expected behavior: Iterates with large steps of 25 units
; Result with native FOR: PASS
; Notes: Large integer step values work correctly
;-------------------------------------------------------------------
run-test "Large step (1-100 by 25)" [
    do function [] [
        i: 0
        result: []
        for i 1 100 25 [append result i]
        result
    ]
] [1 26 51 76]

;-------------------------------------------------------------------
; Test 10: Fractional numbers (0.5-2.5 by 0.5)
; Purpose: Verify the FOR loop correctly handles decimal values
; Expected behavior: Iterates through 0.5, 1.0, 1.5, 2.0, 2.5
; Result with native FOR: PASS
; Notes: Basic decimal values work, but can be unreliable with small step values
;        due to floating-point precision issues
;-------------------------------------------------------------------
run-test "Fractional numbers (0.5-2.5 by 0.5)" [
    do function [] [
        i: 0
        result: []
        for i 0.5 2.5 0.5 [append result i]
        result
    ]
] [0.5 1.0 1.5 2.0 2.5]

;-------------------------------------------------------------------
; Test 11: Small fractional step (1-1.3 by 0.1)
; Purpose: Verify the FOR loop correctly handles small decimal step values
; Expected behavior: Should iterate through 1.0, 1.1, 1.2, 1.3
; Result with native FOR: FAIL
; Known Issue: Due to floating-point precision issues, the native FOR
;              terminates prematurely, producing [1.0 1.1 1.2] and missing 1.3
; Recommendation: Use safe-for with epsilon-based comparison for this case
;-------------------------------------------------------------------
run-test "Small fractional step (1-1.3 by 0.1)" [
    do function [] [
        i: 0
        result: []
        for i 1 1.3 0.1 [append result round/to i 0.01]
        result
    ]
] [1.0 1.1 1.2 1.3]

print "=== SCOPE SAFETY TESTS ==="
print ""

;-------------------------------------------------------------------
; Test 12: Variable accessible in body
; Purpose: Verify the loop variable is accessible within the loop body
; Expected behavior: Loop variable is accessible and stores correct values
; Result with native FOR: PASS
; Notes: Basic variable access within loop body works correctly
;-------------------------------------------------------------------
run-test "Variable accessible in body" [
    do function [] [
        i: 0
        result: none
        for i 1 3 1 [result: i]
        result
    ]
] 3

;-------------------------------------------------------------------
; Test 13: Variable value after loop
; Purpose: Verify the loop variable retains its original value after loop execution
; Expected behavior: Loop variable should revert to its pre-loop value (100)
; Result with native FOR: FAIL
; Known Issue: The native FOR construct modifies the loop variable and does not
;              restore its original value, potentially contaminating surrounding code
; Recommendation: Use safe-for to preserve variable scope integrity
;-------------------------------------------------------------------
run-test "Variable value after loop" [
    do function [] [
        i-before: 100
        i: i-before
        result: none
        for i 1 3 1 [result: i]
        reduce [result i]  ; Return both values to verify scope
    ]
] [3 100]  ; We expect the loop to restore the original value, but native FOR doesn't

;-------------------------------------------------------------------
; Test 14: Zero step protection
; Purpose: Verify the FOR loop handles zero step values safely
; Expected behavior: Should raise an error rather than entering infinite loop
; Result with native FOR: CRITICAL FAIL - Causes infinite loop
; Known Issue: The native FOR has no protection against zero step values,
;              resulting in system hangs and resource exhaustion
; Recommendation: NEVER use native FOR with zero step - use safe-for which
;                 includes validation to prevent this hazard
; NOTE: This test is commented out to prevent system hangs
;-------------------------------------------------------------------
; DANGER - DO NOT UNCOMMENT - SYSTEM HANG RISK
; run-test "Zero step should error" [
;     error? try [for i 5 5 0 []]
; ] true

print "=== TEST SUMMARY ==="
print ["Total tests:" test-state/current-test-num - 1]
print ["Passed:" test-state/pass-count]
print ["Failed:" test-state/fail-count]
print ""
either test-state/fail-count = 0 [
    print "All tests passed successfully!"
][
    print "The following tests failed:"
    foreach [name status msg] test-state/test-results [
        if status = "FAIL" [print ["  -" name "==>" msg]]
    ]
]

print ""
print "=== NATIVE `for` ASSESSMENT SUMMARY ==="
print ""
print "RELIABLE FOR NATIVE USE CASES:"
print "- Basic integer loops (ascending, descending)"
print "- Simple step values (including negative steps)"
print "- Zero-iteration boundary cases"
print "- Basic integer edge cases (negative numbers, zero boundaries)"
print ""
print "REQUIRES `safe-for` / `sfor` wrapper:"
print "- Small fractional step values (floating-point precision issues)"
print "- Variable scoping requirements (preserving original values)"
print "- Zero step protection (preventing infinite loops)"
print "- Production code where reliability is essential"
print ""
print "RECOMMENDATION: Use `safe-for` consistently in production code for all `for` loops"
print "(A conceptual `safe-for` stub illustrating these principles is included above.)"

comment {
Question: Do programmers typically use these type of for loops or are these extreme use cases?
USE the `safe-for` / `sfor` wrapper for:
- Small fractional step values (floating-point precision issues)
- Variable scoping requirements (preserving original values)
- Zero step protection (preventing infinite loops)

The scenarios requiring the `safe-for` wrapper represent a mixture of common programming patterns and edge cases,
with their frequency varying significantly across different application domains and development contexts.

- Floating-Point Operations in Production Systems:
Small fractional step values appear regularly in scientific computing, financial calculations and data visualization applications.
Mathematical modeling software frequently employs decimal increments for parameter sweeps,
while financial systems commonly iterate through percentage ranges or currency calculations using fractional steps.
Graphics and animation libraries routinely use small decimal increments for smooth transitions and interpolation effects.
These applications represent substantial segments of professional software development where floating-point precision directly impacts system reliability and accuracy.
The prevalence of these use cases makes the floating-point boundary errors in REBOL's native implementation a significant concern for production environments.
While basic integer loops dominate simple applications and educational examples,
professional software development frequently encounters scenarios where decimal precision becomes critical to system functionality.

- Variable Scoping Considerations:
Variable scoping requirements present more nuanced deployment patterns.
Traditional procedural programming often accepts loop variable modification as expected behavior,
particularly in languages where loop counters remain accessible after completion.
However, modern development practices increasingly emphasize functional programming principles and
immutable state management, making variable preservation more relevant to contemporary software architecture.
Enterprise applications with complex state management requirements benefit substantially from predictable variable scoping behavior.
Multi-threaded systems, event-driven architectures, and component-based frameworks often require strict isolation between control structures and surrounding code contexts. The variable restoration capabilities of safe-for align with these architectural requirements while
eliminating potential contamination vectors that could introduce subtle bugs in complex systems.

- Zero Step Protection Analysis:
Zero step scenarios typically arise from dynamic parameter calculation rather than explicit programming choices.
Applications that compute step values from user input, configuration files or mathematical formulas might
inadvertently generate zero step conditions through edge cases in their calculation logic.
Web applications processing form input, data analysis tools handling empty datasets and
algorithmic trading systems responding to market conditions represent common sources of dynamic step generation.
While experienced programmers rarely write explicit zero step loops, the protection becomes valuable in robust error handling strategies.
Production systems that process external data or respond to user input benefit from comprehensive validation logic that
    prevents system hangs (and potential Denial of Service) regardless of input quality or calculation accuracy.

- Industry Application Patterns:
Enterprise software development increasingly emphasizes defensive programming practices and comprehensive error handling.
The reliability requirements of production systems often justify protective measures that might seem excessive for simple applications or educational examples.
Modern development frameworks commonly implement similar protective patterns for database connections, network operations, and resource management.
The trend toward microservices architecture and distributed systems amplifies the importance of predictable component behavior.
Individual service failures can cascade through entire system architectures, making local reliability improvements valuable investments in overall system stability.
The minimal performance overhead of protective wrappers becomes negligible compared to the potential cost of system-wide failures or data corruption incidents.

- Recommendation for Professional Development:
The adoption of safe-for as a standard practice reflects sound engineering judgment rather than excessive caution.
Professional software development benefits from consistent patterns that eliminate categories of potential defects while maintaining code readability and maintainability. The wrapper approach provides insurance against edge cases while establishing reliable foundations for future development initiatives.
The investment in comprehensive loop safety represents practical risk management for production environments where
system reliability directly impacts business operations and user experience.
The documented defects in REBOL's native implementation create unnecessary technical debt that defensive programming practices can effectively eliminate.
}
