Rebol [
    Title: "Comprehensive Diagnostic Probe for `task` Function"
    Purpose: "Systematically test the behavior of `task`, `task?` and `task!` datatype."
    Author: "Claude 4 Sonnet"
    Date: 19-Jul-2025
    Version: 0.1.0
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
    print "=== TEST SUMMARY ==="
    print "============================================"
    print rejoin ["Total Tests: " test-count]
    print rejoin ["Passed: " pass-count]
    print rejoin ["Failed: " fail-count]
    print "============================================"
    either all-tests-passed? [
        print "✅ ALL TESTS PASSED - FUNCTION IS STABLE"
    ][
        print "❌  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

print "^/============================================"
print "=== COMPREHENSIVE TASK FUNCTION DIAGNOSTIC ==="
print "============================================^/"

;;-----------------------------------------------------------------------------
;; SECTION 1: Probing Basic TASK Creation Behavior
;;-----------------------------------------------------------------------------
print "^/=== SECTION 1: Probing Basic TASK Creation Behavior ==="
print "HYPOTHESIS: task function should create task! datatypes from spec and body blocks"

;; Test 1.1: Simple task creation with empty spec and body
print "^/--- Test 1.1: Creating task with empty blocks ---"
simple-task: task [] []
assert-equal task! type? simple-task "Empty spec/body should create task! datatype"
assert-equal true task? simple-task "task? should return true for created task"

;; Test 1.2: Task creation with basic spec
print "^/--- Test 1.2: Creating task with simple spec ---"
spec-task: task [name] [print name]
assert-equal task! type? spec-task "Task with spec should create task! datatype"
assert-equal true task? spec-task "task? should return true for spec task"

;; Test 1.3: Task creation with complex spec
print "^/--- Test 1.3: Creating task with complex spec ---"
complex-spec: [
    name [string!] "A name parameter"
    value [integer!] "An integer value"
    /local temp
]
complex-body: [
    temp: name
    print [temp "=" value]
]
complex-task: task complex-spec complex-body
assert-equal task! type? complex-task "Task with complex spec should create task! datatype"
assert-equal true task? complex-task "task? should return true for complex task"

;;-----------------------------------------------------------------------------
;; SECTION 2: Probing TASK? Type Checking Function
;;-----------------------------------------------------------------------------
print "^/=== SECTION 2: Probing TASK? Type Checking Function ==="
print "HYPOTHESIS: task? should return true only for task! datatypes, false for all others"

;; Test 2.1: task? with task! values
print "^/--- Test 2.1: task? with actual task! values ---"
test-task: task [x] [print x]
assert-equal true task? test-task "task? should return true for task! datatype"

;; Test 2.2: task? with non-task values
print "^/--- Test 2.2: task? with various non-task datatypes ---"
assert-equal false task? "string" "task? should return false for string!"
assert-equal false task? 42 "task? should return false for integer!"
assert-equal false task? [1 2 3] "task? should return false for block!"
assert-equal false task? none "task? should return false for none!"
assert-equal false task? true "task? should return false for logic!"
assert-equal false task? does [print "test"] "task? should return false for function!"

;; Test 2.3: task? with object! (since task! is described as general type object)
print "^/--- Test 2.3: task? with object! values ---"
test-object: make object! [name: "test"]
assert-equal false task? test-object "task? should return false for regular object!"

;;-----------------------------------------------------------------------------
;; SECTION 3: Probing Task Internal Structure and Data Access
;;-----------------------------------------------------------------------------
print "^/=== SECTION 3: Probing Task Internal Structure and Data Access ==="
print "HYPOTHESIS: Tasks should contain the spec and body as internal data, possibly accessible"

;; Test 3.1: Basic internal structure exploration
print "^/--- Test 3.1: Exploring task internal structure ---"
structure-task: task [param1 param2] [print [param1 param2]]
print ["Task mold representation:" mold structure-task]
print ["Task probe representation:"]
probe structure-task

;; Test 3.2: Testing if tasks behave like objects
print "^/--- Test 3.2: Testing object-like behavior ---"
;; Since task! is described as "general type object", test object access patterns
set/any 'obj-test-result try [first structure-task]
print ["Attempting 'first' on task:" either error? obj-test-result ["ERROR"] [mold obj-test-result]]

set/any 'length-test-result try [length? structure-task]
print ["Attempting 'length?' on task:" either error? length-test-result ["ERROR"] [mold length-test-result]]

;;-----------------------------------------------------------------------------
;; SECTION 4: Probing Task Argument Validation and Edge Cases
;;-----------------------------------------------------------------------------
print "^/=== SECTION 4: Probing Task Argument Validation and Edge Cases ==="
print "HYPOTHESIS: task function should validate that both arguments are blocks, error on invalid types"

;; Test 4.1: Invalid spec argument types
print "^/--- Test 4.1: Testing invalid spec argument types ---"
set/any 'error-result try [task "invalid-spec" []]
assert-equal true error? error-result "task should error when spec is not a block!"

set/any 'error-result try [task 42 []]
assert-equal true error? error-result "task should error when spec is integer!"

set/any 'error-result try [task none []]
assert-equal true error? error-result "task should error when spec is none!"

;; Test 4.2: Invalid body argument types
print "^/--- Test 4.2: Testing invalid body argument types ---"
set/any 'error-result try [task [] "invalid-body"]
assert-equal true error? error-result "task should error when body is not a block!"

set/any 'error-result try [task [] 42]
assert-equal true error? error-result "task should error when body is integer!"

set/any 'error-result try [task [] none]
assert-equal true error? error-result "task should error when body is none!"

;; Test 4.3: Both arguments invalid
print "^/--- Test 4.3: Testing both arguments invalid ---"
set/any 'error-result try [task "bad-spec" "bad-body"]
assert-equal true error? error-result "task should error when both arguments are invalid!"

;;-----------------------------------------------------------------------------
;; SECTION 5: Probing Task Deep Copy Behavior
;;-----------------------------------------------------------------------------
print "^/=== SECTION 5: Probing Task Deep Copy Behavior ==="
print "HYPOTHESIS: task uses copy/deep internally, so modifying original blocks won't affect task"

;; Test 5.1: Modifying original spec after task creation
print "^/--- Test 5.1: Testing spec independence after creation ---"
original-spec: [param1 param2 /local temp]
original-body: [temp: param1 + param2 print temp]
isolation-task: task original-spec original-body

;; Modify the original blocks
append original-spec 'param3
append original-body [print "modified"]

;; The task should be unaffected due to copy/deep
print ["Original spec after modification:" mold original-spec]
print ["Original body after modification:" mold original-body]
print ["Task after original modification:" mold isolation-task]

;; Test 5.2: Creating multiple tasks from same blocks
print "^/--- Test 5.2: Testing multiple tasks from same source blocks ---"
shared-spec: [value]
shared-body: [print value]

first-task: task shared-spec shared-body
second-task: task shared-spec shared-body

;; Tasks should be independent objects
different-tasks?: not same? first-task second-task
assert-equal true different-tasks? "Tasks created from same blocks should be different objects"

;;-----------------------------------------------------------------------------
;; SECTION 6: Probing Task with Complex Block Structures
;;-----------------------------------------------------------------------------
print "^/=== SECTION 6: Probing Task with Complex Block Structures ==="
print "HYPOTHESIS: task should handle nested blocks, complex data structures in spec/body"

;; Test 6.1: Nested blocks in spec
print "^/--- Test 6.1: Testing nested blocks in spec ---"
nested-spec: [
    config [block!] "Configuration block"
    data [[string! integer!]] "Structured data"
]
nested-body: [
    print ["Config:" mold config]
    print ["Data:" mold data]
]
nested-task: task nested-spec nested-body
assert-equal task! type? nested-task "Task with nested spec blocks should succeed"

;; Test 6.2: Complex body with nested structures
print "^/--- Test 6.2: Testing complex nested body structures ---"
complex-body-content: [
    if not empty? config [
        foreach item data [
            case [
                string? item [print ["String:" item]]
                integer? item [print ["Number:" item]]
                true [print ["Other:" mold item]]
            ]
        ]
    ]
]
complex-nested-task: task [config data] complex-body-content
assert-equal task! type? complex-nested-task "Task with complex nested body should succeed"

;;-----------------------------------------------------------------------------
;; SECTION 7: Probing Task Equality and Comparison
;;-----------------------------------------------------------------------------
print "^/=== SECTION 7: Probing Task Equality and Comparison ==="
print "HYPOTHESIS: All tasks appear to be equal regardless of spec/body due to identical internal structure"

;; Test 7.1: Tasks with identical content
print "^/--- Test 7.1: Testing equality of identical tasks ---"
task-a: task [x] [print x]
task-b: task [x] [print x]
identical-tasks?: equal? task-a task-b
assert-equal true identical-tasks? "Tasks with identical spec and body should be equal"

;; Test 7.2: Tasks with different specs
print "^/--- Test 7.2: Testing equality of different spec tasks ---"
task-diff-spec-a: task [x] [print x]
task-diff-spec-b: task [y] [print y]
different-spec-tasks?: equal? task-diff-spec-a task-diff-spec-b
assert-equal true different-spec-tasks? "Tasks with different specs should still be equal (internal structure identical)"

;; Test 7.3: Tasks with different bodies
print "^/--- Test 7.3: Testing equality of different body tasks ---"
task-diff-body-a: task [x] [print x]
task-diff-body-b: task [x] [probe x]
different-body-tasks?: equal? task-diff-body-a task-diff-body-b
assert-equal true different-body-tasks? "Tasks with different bodies should still be equal (internal structure identical)"

;;-----------------------------------------------------------------------------
;; SECTION 8: Probing Task Memory and Reference Behavior
;;-----------------------------------------------------------------------------
print "^/=== SECTION 8: Probing Task Memory and Reference Behavior ==="
print "HYPOTHESIS: Each task should be a unique object reference, even with same content"

;; Test 8.1: Testing same? vs equal? behavior
print "^/--- Test 8.1: Testing reference vs content equality ---"
ref-task-a: task [value] [return value]
ref-task-b: task [value] [return value]
ref-task-c: ref-task-a

same-reference?: same? ref-task-a ref-task-c
different-reference?: not same? ref-task-a ref-task-b
content-equal?: equal? ref-task-a ref-task-b

assert-equal true same-reference? "Task assigned to another variable should have same reference"
assert-equal true different-reference? "Separately created identical tasks should have different references"
assert-equal true content-equal? "Separately created identical tasks should have equal content"

;;-----------------------------------------------------------------------------
;; SECTION 9: Final Validation and Summary
;;-----------------------------------------------------------------------------
print "^/=== SECTION 9: Final Validation - Edge Case Completeness ==="
print "HYPOTHESIS: All edge cases should be covered without system crashes"

;; Test 9.1: Very large spec and body blocks
print "^/--- Test 9.1: Testing with large blocks ---"
large-spec: []
large-body: []
repeat counter 100 [
    append large-spec to-word rejoin ["param" counter]
    append large-body reduce ['print to-word rejoin ["param" counter]]
]
set/any 'large-result try [task large-spec large-body]
large-task-success?: not error? large-result
assert-equal true large-task-success? "Task should handle large spec and body blocks"

;; Test 9.2: Empty vs populated comparison
print "^/--- Test 9.2: Testing empty vs populated task comparison ---"
empty-task: task [] []
populated-task: task [x] [print x]
empty-vs-populated?: equal? empty-task populated-task
assert-equal true empty-vs-populated? "Empty and populated tasks should be equal (same internal structure)"

print "^/=== DIAGNOSTIC PROBE COMPLETE ==="
print-test-summary
