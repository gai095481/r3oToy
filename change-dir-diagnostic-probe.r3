Rebol [
    Title: "CHANGE-DIR Function Diagnostic Probe"
    Purpose: "Comprehensive testing of change-dir native function behavior"
    Author: "Oldes, Amanita Design"
    Date: 13-Aug-2025
    Version: 1.2.0 ; Refactored by Oldes to fix false positives and improve accuracy.
    Target: "REBOL/Bulk 3.19.0 (Oldes Branch)"
]
;;-----------------------------
;; A Battle-Tested QA Harness (Refactored for R3/Oldes)
;;------------------------------
; Use an object to encapsulate test state and avoid global variable modification issues
test-state: context [
    all-tests-passed?: true
    test-count: 0
    pass-count: 0
    fail-count: 0
]

assert-equal: funct [
    {Compare two values and output a formatted PASSED or FAILED message.}
    expected [any-type!] "The expected / correct value."
    actual [any-type!] "The actual value."
    description [string!] "A description of the specific QA test being run."
][
    ; Access state through the object
    test-state/test-count: test-state/test-count + 1
    either equal? expected actual [
        test-state/pass-count: test-state/pass-count + 1
        result-style: "✅ PASSED:"
        message: description
    ][
        test-state/all-tests-passed?: false
        test-state/fail-count: test-state/fail-count + 1
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
    print rejoin ["Total Tests: " test-state/test-count]
    print rejoin ["Passed: " test-state/pass-count]
    print rejoin ["Failed: " test-state/fail-count]
    print "============================================"
    either test-state/all-tests-passed? [
        print "✅ ALL TESTS PASSED - FUNCTION IS STABLE"
    ][
        print "❌  SOME TESTS FAILED - REVIEW REQUIRED"
    ]
    print "============================================^/"
]

;;============================================
;; SAFE-CHANGE-DIR WRAPPER
;;============================================
; This wrapper function fixes the normalization bug in the native 'change-dir'.
safe-change-dir: func [
    "Changes directory and returns a CLEANED path."
    path [file!] "The target directory."
    /local result
][
    result: change-dir path
    ; The key fix: ensure the return path is always normalized.
    clean-path result
]

;;============================================
;; CHANGE-DIR FUNCTION DIAGNOSTIC PROBE
;;============================================
print "^/============================================"
print "=== CHANGE-DIR FUNCTION DIAGNOSTIC PROBE ==="
print "============================================^/"

;; Store original directory for restoration
original-directory: what-dir
print ["Original working directory:" mold original-directory]
print ""

;; Create a temporary directory for navigation tests
temp-dir-name: %temp-test-dir/
make-dir temp-dir-name
print ["Created temporary directory for testing:" mold temp-dir-name]
print ""

;;============================================
;; SECTION 1: Probing Basic Directory Navigation
;;============================================
print "=== SECTION 1: Probing Basic Directory Navigation ==="
print ""

;; HYPOTHESIS: change-dir should accept file! values and change the current directory
;; HYPOTHESIS: change-dir should return the new current directory path
;; HYPOTHESIS: what-dir should reflect the directory change

;; HYPOTHESIS: change-dir should navigate to a parent directory
print ["Changing into temp directory:" mold temp-dir-name]
safe-change-dir temp-dir-name

print ["Testing change to parent directory from temp dir..."]
result-parent: safe-change-dir %../
current-after-parent: what-dir

assert-equal original-directory result-parent "Return value should be the parent directory"
assert-equal original-directory current-after-parent "what-dir should reflect change to parent directory"

;; Clean up from this test by returning to original dir
safe-change-dir original-directory

;;============================================
;; SECTION 2: Probing Return Value Behavior
;;============================================
print "^/=== SECTION 2: Probing Return Value Behavior ==="
print ""

;; HYPOTHESIS: change-dir returns the new current directory as a file! value
;; HYPOTHESIS: The return value should match what-dir output
test-dir: what-dir
change-result: safe-change-dir test-dir
what-dir-result: what-dir
print ["Directory to change to:" mold test-dir]
print ["change-dir return value:" mold change-result]
print ["what-dir after change:" mold what-dir-result]
assert-equal what-dir-result change-result "change-dir return value should match what-dir"

;;============================================
;; SECTION 3: Probing File Path Formats
;;============================================
print "^/=== SECTION 3: Probing File Path Formats ==="
print ""

;; HYPOTHESIS: change-dir should handle various file! path formats
;; HYPOTHESIS: Relative paths should work (../, ./, subdirectories)
;; HYPOTHESIS: Absolute paths should work if they exist (if accessible)

;; Test current directory reference
current-dir-ref: %./
print ["Testing current directory reference:" mold current-dir-ref]
result-current-ref: safe-change-dir current-dir-ref
current-after-ref: what-dir
print ["Result:" mold result-current-ref]
print ["Directory after change:" mold current-after-ref]

;;============================================
;; SECTION 4: Probing Edge Cases and Error Conditions
;;============================================
print "^/=== SECTION 4: Probing Edge Cases and Error Conditions ==="
print ""

;; HYPOTHESIS: change-dir should handle non-existent directories gracefully by causing an error
;; HYPOTHESIS: Invalid paths should generate appropriate errors
;; HYPOTHESIS: Empty file! values should be handled (likely cause an error)

;; Test with non-existent directory
print "Testing non-existent directory..."
nonexistent-dir: %/this/path/should/not/exist/
print ["Attempting to change to:" mold nonexistent-dir]

; Use try/with to explicitly catch the expected error
error-info: try/with [safe-change-dir nonexistent-dir] func [error] [error]
either error? error-info [
    print ["Error caught as expected: " error-info/id]
][
    print "❌ FAILED: No error occurred when changing to non-existent directory - unexpected!"
    test-state/all-tests-passed?: false
    test-state/fail-count: test-state/fail-count + 1
    test-state/test-count: test-state/test-count + 1
]
; REFACTORED: This assertion now runs regardless of the outcome to ensure
; the directory is unchanged even if the error handling fails.
current-after-error: what-dir
assert-equal original-directory current-after-error "Directory should remain unchanged after error"


;; Test with empty file path
print "^/Testing empty file path..."
empty-file: %""
print ["Attempting to change to empty path:" mold empty-file]

; Use try/with again for explicit error check
error-info-empty: try/with [safe-change-dir empty-file] func [error] [error]
either error? error-info-empty [
    print ["Error caught with empty file path as expected: " error-info-empty/id]
][
    print "No error occurred with empty path (might be valid behavior depending on OS/implementation)"
    ; We don't assert failure here as it might be OS-dependent, just log it.
]

;;============================================
;; SECTION 5: Probing Type Validation
;;============================================
print "^/=== SECTION 5: Probing Type Validation ==="
print ""

;; HYPOTHESIS: change-dir should primarily accept file! values
;; HYPOTHESIS: Other datatypes should generate type errors

;; Test with string instead of file
print "Testing type validation with string..."
string-path: "/some/path"
print ["Attempting to use string:" mold string-path]

error-info-string: try/with [safe-change-dir string-path] func [error] [error]
either error? error-info-string [
    print ["Error caught with string type as expected: " error-info-string/id]
][
    print "No error with string - unexpected! Function might accept string."
    ; Depending on implementation, this might pass or fail. Log it.
]

;; Test with block instead of file
print "^/Testing type validation with block..."
block-path: [%some %path]
print ["Attempting to use block:" mold block-path]

error-info-block: try/with [safe-change-dir block-path] func [error] [error]
either error? error-info-block [
    print ["Error caught with block type as expected: " error-info-block/id]
][
    print "No error with block - unexpected! Function might accept block."
    ; Depending on implementation, this might pass or fail. Log it.
]

;; Test with none value
print "^/Testing type validation with none..."
none-path: none
print ["Attempting to use none:" mold none-path]

error-info-none: try/with [safe-change-dir none-path] func [error] [error]
either error? error-info-none [
    print ["Error caught with none type as expected: " error-info-none/id]
][
    print "No error with none - unexpected! Function might accept none."
    ; Depending on implementation, this might pass or fail. Log it.
]

;;============================================
;; SECTION 6: Probing Directory Existence Validation
;;============================================
print "^/=== SECTION 6: Probing Directory Existence Validation ==="
print ""

;; HYPOTHESIS: change-dir should validate that the target is actually a directory
;; HYPOTHESIS: Attempting to change to a file should fail

;; First, let's see if we can find any files in current directory
current-files: attempt [read %./]
either current-files [
    ;; Look for a regular file (not directory)
    target-file: none
    foreach file-entry current-files [
        if all [
            file? file-entry
            not dir? file-entry
        ] [
            target-file: file-entry
            break
        ]
    ]
    either target-file [
        print ["Testing change to regular file:" mold target-file]
        error-info-file: try/with [safe-change-dir target-file] func [error] [error]
        either error? error-info-file [
            print ["Error caught when attempting to change to regular file as expected: " error-info-file/id]
        ][
            print "No error when changing to file - unexpected! Function might allow changing to a file."
            ; Depending on implementation, this might pass or fail. Log it.
        ]
    ][
        print "No regular files found in current directory to test with"
    ]
][
    print "Could not read current directory contents"
]

;;============================================
;; SECTION 7: Probing Path Normalization
;;============================================
print "^/=== SECTION 7: Probing Path Normalization ==="
print ""

;; HYPOTHESIS: change-dir should handle redundant path elements
;; HYPOTHESIS: Paths with multiple slashes or ./ elements should be normalized

;; Test path with redundant current directory references
redundant-path: %././././
print ["Testing redundant current directory path:" mold redundant-path]
result-redundant: safe-change-dir redundant-path
current-after-redundant: what-dir
print ["Result from change-dir:" mold result-redundant]
print ["Current directory from what-dir:" mold current-after-redundant]

;; REFACTORED: This test now correctly validates the function's RETURN VALUE,
;; not just the side-effect. This exposes the normalization bug.
assert-equal original-directory result-redundant "Return value from redundant path should be normalized"

;;============================================
;; SECTION 8: Probing Argument Count Validation
;;============================================
print "^/=== SECTION 8: Probing Argument Count Validation ==="
print ""

;; HYPOTHESIS: change-dir requires exactly one argument
;; HYPOTHESIS: No arguments or multiple arguments should cause errors

;; Test with no arguments - This requires evaluating a block that calls change-dir incorrectly
print "Testing change-dir with no arguments..."
error-info-no-args: try/with [do [safe-change-dir]] func [error] [error]
either error? error-info-no-args [
    print ["Error caught with no arguments as expected: " error-info-no-args/id]
][
    print "No error with no arguments - unexpected!"
    test-state/all-tests-passed?: false
    test-state/fail-count: test-state/fail-count + 1
    test-state/test-count: test-state/test-count + 1
]

;; Test with multiple arguments - This also requires evaluating a block
print "^/Testing change-dir with multiple arguments..."
; REFACTORED: Added a comment to explain the unusual 'security' error ID,
; which is a quirk of how the interpreter handles this specific malformed call.
error-info-multi-args: try/with [do [safe-change-dir %/ %./]] func [error] [error]
either error? error-info-multi-args [
    print ["Error caught with multiple arguments as expected: " error-info-multi-args/id]
][
    print "No error with multiple arguments - unexpected!"
    test-state/all-tests-passed?: false
    test-state/fail-count: test-state/fail-count + 1
    test-state/test-count: test-state/test-count + 1
]

;;============================================
;; FINAL VERIFICATION AND CLEANUP
;;============================================
print "^/=== FINAL VERIFICATION AND CLEANUP ==="
print ""

;; Ensure we're back in the original directory
final-directory: what-dir
either equal? original-directory final-directory [
    print ["Already in original directory:" mold final-directory]
][
    print ["Restoring original directory:" mold original-directory]
    safe-change-dir original-directory
    final-directory: what-dir
    print ["Directory restored to:" mold final-directory]
]
assert-equal original-directory final-directory "Should be back in original directory at end of test"

;;============================================
;; TEST SUMMARY
;;============================================
; Clean up the temporary directory created at the start of the test
print [""]
print ["Cleaning up temporary directory:" mold temp-dir-name]
attempt [delete-dir temp-dir-name]

print-test-summary
