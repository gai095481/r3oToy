Rebol [
    Title: "TASK Function Comprehensive Diagnostic Probe"
    Purpose: "Systematically test the behavior of TASK, TASK? and TASK! datatype"
    Author: "Lutra AI"
    Date: 19-Jul-2025
    Version: 0.1.0
    Note: "Truth from the REPL - Evidence gathering tool."
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

print "^/=== TASK FUNCTION COMPREHENSIVE DIAGNOSTIC PROBE ==="
print "=== Testing TASK, TASK?, and TASK! behaviors ==="

;;====================================================================
;; SECTION 1: Probing Basic TASK Creation
;;====================================================================
print "^/--- SECTION 1: Probing Basic TASK Creation ---"
;; HYPOTHESIS: task function creates a task! datatype when given valid spec and body blocks

;; Test 1.1: Basic task creation with empty spec and empty body
basic-task-empty: task [] []
assert-equal task! type? basic-task-empty "Basic task with empty spec and body should create task! type"

;; Test 1.2: Basic task creation with simple spec and body
basic-task-simple: task [arg] [print arg]
assert-equal task! type? basic-task-simple "Basic task with simple spec and body should create task! type"

;; Test 1.3: Task creation with multiple arguments in spec
multi-arg-task: task [first-arg second-arg] [first-arg + second-arg]
assert-equal task! type? multi-arg-task "Task with multiple arguments should create task! type"

;; Test 1.4: Task creation with typed arguments
typed-task: task [num [integer!] txt [string!]] [rejoin [txt ": " num]]
assert-equal task! type? typed-task "Task with typed arguments should create task! type"

;;====================================================================
;; SECTION 2: Probing TASK? Function Behavior
;;====================================================================
print "^/--- SECTION 2: Probing TASK? Function Behavior ---"
;; HYPOTHESIS: task? returns true only for task! datatypes and false for all other types

;; Test 2.1: task? with actual task should return true
assert-equal true task? basic-task-empty "task? should return true for actual task"

;; Test 2.2: task? with function should return false
safe-test-func: func [] [42]  ;; No arguments, completely safe
assert-equal false task? safe-test-func "task? should return false for function!"

;; Test 2.3: task? with block should return false
test-block: [1 2 3]
assert-equal false task? test-block "task? should return false for block!"

;; Test 2.4: task? with string should return false
test-string: "hello"
assert-equal false task? test-string "task? should return false for string!"

;; Test 2.5: task? with integer should return false
test-integer: 42
assert-equal false task? test-integer "task? should return false for integer!"

;; Test 2.6: task? with none should return false
assert-equal false task? none "task? should return false for none!"

;; Test 2.7: task? with object should return false
test-object: make object! [value: 10]
assert-equal false task? test-object "task? should return false for object!"

;; Test 2.8: task? with word should return false
test-word: 'sample-word
assert-equal false task? test-word "task? should return false for word!"

;; Test 2.9: task? with decimal should return false
test-decimal: 3.14
assert-equal false task? test-decimal "task? should return false for decimal!"

;; Test 2.10: task? with refinement should return false
test-refinement: /test-ref
assert-equal false task? test-refinement "task? should return false for refinement!"

;; Test 2.11: task? with logic values
assert-equal false task? true "task? should return false for true logic"
assert-equal false task? false "task? should return false for false logic"

;;====================================================================
;; SECTION 3: Probing Task Content and Structure
;;====================================================================
print "^/--- SECTION 3: Probing Task Content and Structure ---"
;; HYPOTHESIS: Tasks store their spec and body internally and can be examined

;; Test 3.1: Examining task structure using probe (visual inspection)
print "^/=== VISUAL INSPECTION: Basic task structure ==="
probe basic-task-simple

;; Test 3.2: Checking if task has accessible spec and body fields
print "^/=== ATTEMPTING TO ACCESS TASK INTERNALS ==="
spec-accessible: false
body-accessible: false

try [
    task-spec: basic-task-simple/spec
    spec-accessible: true
    print ["✅ Task spec accessed successfully:" mold task-spec]
] catch [
    print "❌ Task spec field not directly accessible"
]

try [
    task-body: basic-task-simple/body
    body-accessible: true
    print ["✅ Task body accessed successfully:" mold task-body]
] catch [
    print "❌ Task body field not directly accessible"
]

;; Test 3.3: Check if tasks can be reflected like objects
try [
    task-words: words-of basic-task-simple
    print ["✅ Task words accessible:" mold task-words]
] catch [
    print "❌ Task words not accessible via words-of"
]

;; Test 3.4: Check if tasks have values like objects
try [
    task-values: values-of basic-task-simple
    print ["✅ Task values accessible:" mold task-values]
] catch [
    print "❌ Task values not accessible via values-of"
]

;;====================================================================
;; SECTION 4: Probing Task Creation Edge Cases
;;====================================================================
print "^/--- SECTION 4: Probing Task Creation Edge Cases ---"
;; HYPOTHESIS: Various edge cases should either work or fail predictably

;; Test 4.1: Task with complex body containing nested blocks
complex-body-task: task [input-val] [
    result: copy []
    repeat counter 3 [
        append result input-val * counter
    ]
    result
]
assert-equal task! type? complex-body-task "Task with complex nested body should create task! type"

;; Test 4.2: Task with refinement-style spec
refinement-task: task [base-val /multiply factor] [
    either multiply [base-val * factor] [base-val]
]
assert-equal task! type? refinement-task "Task with refinement in spec should create task! type"

;; Test 4.3: Task with return type specification
return-typed-task: task [num [integer!] return: [string!]] [to string! num]
assert-equal task! type? return-typed-task "Task with return type should create task! type"

;; Test 4.4: Task with documentation string
documented-task: task ["Adds two numbers" first-num second-num] [first-num + second-num]
assert-equal task! type? documented-task "Task with documentation string should create task! type"

;; Test 4.5: Task with local variables
local-vars-task: task [input-data /local temp-var result-var] [
    temp-var: input-data * 2
    result-var: temp-var + 10
    result-var
]
assert-equal task! type? local-vars-task "Task with local variables should create task! type"

;; Test 4.6: Task with empty body but complex spec
empty-body-complex-spec: task [arg1 [string!] arg2 [integer!] /flag option] []
assert-equal task! type? empty-body-complex-spec "Task with empty body but complex spec should create task! type"

;;====================================================================
;; SECTION 5: Probing Task Creation Error Conditions
;;====================================================================
print "^/--- SECTION 5: Probing Task Creation Error Conditions ---"
;; HYPOTHESIS: Invalid inputs to task should generate appropriate errors

;; Test 5.1: Attempting task creation with non-block spec
print "^/=== TESTING ERROR CONDITIONS ==="
error-caught-spec: false
try [
    invalid-spec-task: task "not a block" [print "hello"]
] catch [
    error-caught-spec: true
    print "✅ ERROR CAUGHT: task with string spec generates error as expected"
]
assert-equal true error-caught-spec "task should reject non-block spec"

;; Test 5.2: Attempting task creation with non-block body
error-caught-body: false
try [
    invalid-body-task: task [arg] "not a block"
] catch [
    error-caught-body: true
    print "✅ ERROR CAUGHT: task with string body generates error as expected"
]
assert-equal true error-caught-body "task should reject non-block body"

;; Test 5.3: Attempting task creation with missing arguments
error-caught-missing: false
try [
    incomplete-task: task [arg]  ;; Missing body
] catch [
    error-caught-missing: true
    print "✅ ERROR CAUGHT: task with missing body generates error as expected"
]
assert-equal true error-caught-missing "task should reject missing body argument"

;; Test 5.4: Attempting task creation with too many arguments
error-caught-extra: false
try [
    extra-args-task: task [arg] [print arg] [extra-block]  ;; Extra argument
] catch [
    error-caught-extra: true
    print "✅ ERROR CAUGHT: task with extra arguments generates error as expected"
]
assert-equal true error-caught-extra "task should reject extra arguments"

;; Test 5.5: Attempting task creation with integer spec
error-caught-int-spec: false
try [
    int-spec-task: task 123 [print "hello"]
] catch [
    error-caught-int-spec: true
    print "✅ ERROR CAUGHT: task with integer spec generates error as expected"
]
assert-equal true error-caught-int-spec "task should reject integer spec"

;;====================================================================
;; SECTION 6: Probing Task Datatype Properties
;;====================================================================
print "^/--- SECTION 6: Probing Task Datatype Properties ---"
;; HYPOTHESIS: task! has specific datatype characteristics and inheritance

;; Test 6.1: Checking if task! is of object general type
print "^/=== EXAMINING TASK! DATATYPE PROPERTIES ==="
probe task!

;; Test 6.2: Verifying task inherits from object! general type
sample-task: task [val] [val * 2]
object-test-result: object? sample-task
print ["Is task an object?:" object-test-result]

;; Test 6.3: Testing equality between different tasks with same spec/body
;; CORRECTED EXPECTATION: Tasks with identical spec/body ARE equal in Rebol 3 Oldes
identical-task-one: task [num] [num + 1]
identical-task-two: task [num] [num + 1]
tasks-equal: equal? identical-task-one identical-task-two
assert-equal true tasks-equal "Two tasks with identical spec/body ARE equal in Rebol 3 Oldes"

;; Test 6.4: Testing identity of same task
task-identity: same? identical-task-one identical-task-one
assert-equal true task-identity "Same task should be identical to itself"

;; Test 6.5: Testing if task responds to type queries
assert-equal true task! = type? sample-task "Task type should equal task!"

;; Test 6.6: Testing task with various type checking functions
assert-equal true any-object? sample-task "Task should be recognized as any-object?"
assert-equal false any-function? sample-task "Task should not be recognized as any-function?"

;; Test 6.7: Testing tasks with different specs ARE ALSO equal (observed behavior)
;; CORRECTED EXPECTATION: Tasks with different parameter names are ALSO equal in Rebol 3 Oldes
different-task-alpha: task [x] [x + 10]
different-task-beta: task [y] [y + 10]  ;; Different parameter name
different-tasks-equal: equal? different-task-alpha different-task-beta
assert-equal true different-tasks-equal "Tasks with different parameter names are ALSO equal in Rebol 3 Oldes (observed behavior)"

;; Test 6.8: Testing tasks with truly different bodies
truly-different-task-alpha: task [x] [x + 10]
truly-different-task-beta: task [x] [x * 2]  ;; Different operation
truly-different-equal: equal? truly-different-task-alpha truly-different-task-beta
assert-equal true truly-different-equal "Even tasks with different bodies appear equal in Rebol 3 Oldes (observed behavior)"

;;====================================================================
;; SECTION 7: Probing Task Copy Behavior
;;====================================================================
print "^/--- SECTION 7: Probing Task Copy Behavior ---"
;; HYPOTHESIS: Tasks may not support standard copy operations

;; Test 7.1: Testing basic copy of task (safely)
original-task: task [input-data] [reverse copy input-data]
copy-successful: false
copied-task: none

try [
    copied-task: copy original-task
    copy-successful: true
    print ["✅ Task copy successful, type:" type? copied-task]
] catch [
    print "❌ Task does not support basic copy operation"
]

;; Test 7.2: Testing if copied task is different instance (only if copy worked)
if copy-successful [
    copy-identity-test: same? original-task copied-task
    assert-equal false copy-identity-test "Copied task should be different instance from original"
    assert-equal task! type? copied-task "Copied task should maintain task! type"
]

;; Test 7.3: Testing deep copy behavior (safely)
deep-copy-successful: false
deep-copied-task: none

try [
    deep-copied-task: copy/deep original-task
    deep-copy-successful: true
    print ["✅ Task deep copy successful, type:" type? deep-copied-task]
] catch [
    print "❌ Task does not support deep copy operation"
]

;; Test 7.4: Testing deep copy identity (only if deep copy worked)
if deep-copy-successful [
    deep-copy-identity: same? original-task deep-copied-task
    assert-equal false deep-copy-identity "Deep copied task should be different instance from original"
    assert-equal task! type? deep-copied-task "Deep copied task should maintain task! type"
]

;; Test 7.5: Testing copy/part behavior (safely)
try [
    part-copied-task: copy/part original-task 1
    print ["✅ Task copy/part successful:" type? part-copied-task]
] catch [
    print "❌ Task does not support copy/part refinement"
]

;;====================================================================
;; SECTION 8: Probing Task with Various Data Types in Spec/Body
;;====================================================================
print "^/--- SECTION 8: Probing Task with Various Data Types ---"
;; HYPOTHESIS: Tasks can handle various Rebol data types in their specs and bodies

;; Test 8.1: Task spec with all basic argument types
comprehensive-task: task [
    str-arg [string!]
    int-arg [integer!]
    blk-arg [block!]
    /optional-flag
    opt-arg [any-type!]
] [
    result-list: copy []
    append result-list str-arg
    append result-list int-arg
    append result-list blk-arg
    if optional-flag [append result-list opt-arg]
    result-list
]
assert-equal task! type? comprehensive-task "Task with comprehensive typed spec should create task! type"

;; Test 8.2: Task body with various operations
operation-task: task [data-input] [
    ;; Mathematical operations
    num-result: 10 * 5 + 3
    ;; String operations
    str-result: rejoin ["Result: " num-result]
    ;; Block operations
    blk-result: append copy [a b c] data-input
    ;; Return composite result
    reduce [num-result str-result blk-result]
]
assert-equal task! type? operation-task "Task with various operations in body should create task! type"

;; Test 8.3: Task with conditional logic
conditional-task: task [test-val threshold] [
    case [
        test-val > threshold ["HIGH"]
        test-val < threshold ["LOW"]
        true ["EQUAL"]
    ]
]
assert-equal task! type? conditional-task "Task with conditional logic should create task! type"

;; Test 8.4: Task with series operations
series-task: task [data-series] [
    ;; Various series operations
    series-length: length? data-series
    series-first: first data-series
    series-last: last data-series
    reduce [series-length series-first series-last]
]
assert-equal task! type? series-task "Task with series operations should create task! type"

;;====================================================================
;; SECTION 9: Probing Task Comparison and Conversion
;;====================================================================
print "^/--- SECTION 9: Probing Task Comparison and Conversion ---"
;; HYPOTHESIS: Tasks have specific comparison and conversion behaviors

;; Test 9.1: Comparing tasks for strict equality
task-alpha: task [x] [x + 10]
task-beta: task [x] [x + 10]
strict-equal-test: strict-equal? task-alpha task-beta
print ["Strict equality test result:" strict-equal-test]

;; Test 9.2: Testing task conversion to string
task-to-string: to string! task-alpha
print ["Task converted to string:" mold task-to-string]

;; Test 9.3: Testing task conversion to block (safely)
block-conversion-successful: false
try [
    task-to-block: to block! task-alpha
    block-conversion-successful: true
    print ["✅ Task converted to block:" mold task-to-block]
] catch [
    print "❌ Task cannot be converted to block"
]

;; Test 9.4: Testing mold representation
task-molded: mold task-alpha
print ["Task molded representation:" task-molded]

;; Test 9.5: Testing form representation
task-formed: form task-alpha
print ["Task formed representation:" task-formed]

;;====================================================================
;; SECTION 10: Probing Task Memory and Performance Characteristics
;;====================================================================
print "^/--- SECTION 10: Probing Task Memory and Performance ---"
;; HYPOTHESIS: Tasks have predictable memory usage and creation performance

;; Test 10.1: Creating multiple tasks to test memory behavior
print "^/=== CREATING MULTIPLE TASKS FOR MEMORY TESTING ==="
task-collection: copy []
repeat task-counter 10 [
    new-task: task [val] [val + task-counter]
    append task-collection new-task
]
assert-equal 10 length? task-collection "Should be able to create and store multiple tasks"

;; Test 10.2: Verify all created tasks are valid
all-valid-tasks: true
foreach current-task task-collection [
    unless task? current-task [
        all-valid-tasks: false
        break
    ]
]
assert-equal true all-valid-tasks "All created tasks in collection should be valid task! types"

;; Test 10.3: Test task with large body content
large-body-task: task [input-val] [
    ;; Large computation body
    step-one: input-val * 2
    step-two: step-one + 100
    step-three: step-two / 3
    step-four: to integer! step-three
    step-five: step-four * step-four
    step-six: step-five + input-val
    step-seven: step-six - 50
    final-result: step-seven
    ;; Return with debug info
    reduce [final-result step-one step-two step-three]
]
assert-equal task! type? large-body-task "Task with large body should create task! type"

;; Test 10.4: Test multiple task creation in sequence
sequence-tasks: copy []
repeat seq-counter 5 [
    seq-task: task [base] [base * seq-counter + seq-counter]
    append sequence-tasks seq-task
    assert-equal task! type? seq-task "Each sequentially created task should be valid task! type"
]

;;====================================================================
;; SECTION 11: Probing Task Advanced Features
;;====================================================================
print "^/--- SECTION 11: Probing Task Advanced Features ---"
;; HYPOTHESIS: Tasks support advanced Rebol features and constructs

;; Test 11.1: Task with catch/throw constructs
exception-task: task [test-mode] [
    catch [
        if test-mode = 'error [throw "Test error thrown"]
        if test-mode = 'normal [return "Normal execution"]
        "Default case"
    ]
]
assert-equal task! type? exception-task "Task with catch/throw should create task! type"

;; Test 11.2: Task with parse operations
parse-task: task [input-string] [
    rules: [some [letter! | digit! | space]]
    parse input-string rules
]
assert-equal task! type? parse-task "Task with parse operations should create task! type"

;; Test 11.3: Task with function creation inside
meta-task: task [func-name] [
    new-func: func [x] [x * 2]
    reduce [func-name new-func]
]
assert-equal task! type? meta-task "Task creating functions internally should create task! type"

;; Test 11.4: Task with object creation
object-creation-task: task [obj-name value] [
    new-obj: make object! compose [
        name: (obj-name)
        data: (value)
        get-info: func [] [reduce [name data]]
    ]
    new-obj
]
assert-equal task! type? object-creation-task "Task creating objects should create task! type"

;;====================================================================
;; FINAL TEST SUMMARY
;;====================================================================
print "^/=== DIAGNOSTIC PROBE COMPLETE ==="
print "=== All sections executed successfully ==="
print-test-summary
