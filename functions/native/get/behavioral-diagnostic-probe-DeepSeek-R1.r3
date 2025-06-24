REBOL [
    Title: "An Educational Guide to the GET Function"
    Version: 0.2.0
    Author: "DeepSeek R1 AI as creator and Gemini Pro as documenter"
    Date: 26-Jun-2025
    Status: "Documentation"
    Purpose: {
        A heavily commented script designed to teach novice Rebol programmers
        the behavior and practical uses of the GET function, using the best
        commenting style and proven, working code.
    }
    Keywords: ["get" "tutorial" "documentation" "Rebol-3" "Oldes"]
]

;;-----------------------------------------------------------------------------
;; Robust QA Harness
;;
;; This section provides helper functions that let us test our code.
;; `assert-equal` checks if a piece of code produces the result we expect.
;; This helps us prove that our understanding of Rebol is correct.
;;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
    "Compares an expected value to what our code actually produces."
    expected [any-type!] "The value we expect to get."
    actual [any-type!] "The value the code returned."
    description [string!] "A simple explanation of the test."
][
    either equal? expected actual [
        print rejoin ["✅ PASSED: " description]
    ][
        set 'all-tests-passed? false
        print rejoin [
            "❌ FAILED: " description
            "^/   >> Expected: " mold expected
            "^/   >> Actual:   " mold actual
        ]
    ]
]

print-test-summary: does [
    "Prints a final summary of our test run."
    print "^/============================================"
    either all-tests-passed? [
        print "✅ ALL GET TESTS PASSED"
    ][
        print "❌ SOME GET TESTS FAILED"
    ]
    print "============================================"
]

;;-----------------------------------------------------------------------------
;; Learning About the GET Function
;;-----------------------------------------------------------------------------
print "^/--- TESTING BASIC WORD RETRIEVAL ---"
x: 10
assert-equal 10 get 'x "Basic word retrieval"

; PURPOSE: This test checks if `get 'x` is the same as `:x`.
; WHY IT'S A GOOD CHOICE: It demonstrates that `get 'word` is the functional
; equivalent of the colon-prefix (`:word`) syntax, which also gets the value
; of a word. This is a core concept for understanding Rebol's evaluation rules.
assert-equal :x get 'x "Colon prefix equivalence"

print "^/--- TESTING UNSET WORDS & /ANY REFINEMENT ---"
unset 'y
; PURPOSE: To confirm that trying to `get` a word that has no value will
; correctly and safely produce an error. This is important, as it prevents
; scripts from continuing with missing data.
assert-equal true error? try [get 'y] "Unset word without /any causes error"

; PURPOSE: To confirm that using the `/any` refinement on `get` for an unset
; word does *not* error, and instead returns a special `unset!` value. This is
; the primary way to write safe, conditional code that depends on whether
; a variable exists.
assert-equal true unset? get/any 'y "/any returns UNSET! for unset words"

; CONTEXT: What happens if a path is invalid? Does `/any` still suppress the error?
; PURPOSE: This test proves a critical limitation: the `/any` safety net does NOT
; suppress errors that happen during path navigation. It only works for simple,
; top-level words. This is a "sharp edge" developers must be aware of.
obj: make object! [a: 1]
assert-equal true error? try [get/any 'obj/b] "/any doesn't suppress path errors"

print "^/--- TESTING OBJECT RETRIEVAL ---"
obj: make object! [a: 1 b: 2]
obj-copy: get 'obj
; CONTEXT: How does `get` handle a WORD that holds a user-created object?
; PURPOSE: This test proves that `get` returns a direct "handle" to the original
; object. It does NOT make a copy. `same?` confirms that `obj-copy` and `obj`
; point to the exact same object in memory.
assert-equal true same? obj obj-copy "Object retrieval returns same object"

; WHY IT'S USEFUL: Because `obj-copy` is a handle to the original object, we can use
; it to access the object's fields just like the original variable name.
assert-equal 1 get 'obj-copy/a "Field access after object retrieval"

print "^/--- TESTING PATH RESOLUTION ---"
obj: make object! [nested: make object! [value: 42]]
; PURPOSE: To show that `get` can navigate multi-level paths to find nested data.
assert-equal 42 get 'obj/nested/value "Nested path resolution"
; PURPOSE: To confirm `get` errors if any part of a path is invalid.
assert-equal true error? try [get 'obj/invalid-path] "Invalid path causes error"

block-path: [obj nested value]
; PURPOSE: To demonstrate the crucial difference between a `path!` and a `block!`.
; WHY IT'S A GOOD CHOICE: This proves that `get` does not treat a block as a path.
; It follows the "identity" rule and simply returns the block itself, unevaluated.
; This is a vital concept to prevent accidental code execution.
assert-equal block-path get block-path "Block argument returns itself"

print "^/--- TESTING NON-WORD ARGUMENTS ---"
; PURPOSE: To explicitly test the "identity function" behavior of `get`. When
; the argument is not a `word!` or `path!`, `get` does nothing and returns the
; argument as-is. This confirms its behavior is predictable.
assert-equal 123 get 123 "Integer argument returns itself"
assert-equal "test" get "test" "String argument returns itself"
assert-equal [1 2 3] get [1 2 3] "Block argument returns itself"
assert-equal none get none "None argument returns none"

print "^/--- TESTING SPECIAL VALUES (PERFECTED) ---"
; CONTEXT: How does `get` handle built-in objects like `system`?
; PURPOSE: This test reveals a critical special case. When you `get` a direct
; object VALUE (like `system`), it EXTRACTS all the object's values into a new
; BLOCK. This is different from `get 'word-holding-object`, which returns a handle.
sys-val: get system
assert-equal block! type? sys-val "System context is block"

; CONTEXT: How to get a value from within the `system` object.
; PURPOSE: This shows a working method. `in system` returns the system object, and
; `get` finds the word `'version` within its contents. A clearer way is often
; `get 'system/version`, but this pattern is also valid.
version: get in system 'version
assert-equal tuple! type? version "System version is tuple"

; PURPOSE: To show `get` works on built-in constants.
assert-equal 3.141592653589793 get 'pi "Special word 'pi'"

print "^/--- TESTING BINDING BEHAVIOR (CORRECTED) ---"
; CONTEXT: Rebol allows multiple variables with the same name to exist in
; different "contexts" (like objects). How does `get` know which one to pick?
; PURPOSE: This demonstrates that `get` respects a word's binding. The `bind`
; function creates a new word that is "hard-coded" to look inside a specific
; context. `get` honors this link, retrieving the value from the correct context.
; This is essential for writing modular, conflict-free code.
ctx1: make object! [bound-val: 10]
ctx2: make object! [bound-val: 20]

word1: bind 'bound-val ctx1
word2: bind 'bound-val ctx2

assert-equal 10 get word1 "Bound word in context 1"
assert-equal 20 get word2 "Bound word in context 2"

print "^/--- TESTING EDGE CASES ---"
empty-obj: make object! []
; WHY IT'S USEFUL: This confirms the "get 'word-form" rule holds true even for
; empty objects. It still returns a handle to the original empty object.
assert-equal true object? get 'empty-obj "Empty object retrieval"
unset 'ghost
assert-equal true unset? get/any 'ghost "Unset word with /any"

; CONTEXT: A "circular reference" is when an object contains a reference back to itself.
; PURPOSE: This test shows `get` handles this gracefully. The path `'a/b` resolves
; to the object `a`. Then, `get` returns a handle to that same object `a`, as proven
; by `same?`, preventing an infinite loop.
a: make object! [b: none]
a/b: a
assert-equal true same? a get 'a/b "Circular reference handling"

; Final test summary
print-test-summary
