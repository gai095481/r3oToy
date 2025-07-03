REBOL [
    Title: "Final Evidence-Based and Commented Probe for GET"
    Date: 20-Jul-2024
    Author: "Rebol Expert"
    Purpose: "The definitive, error-free, and heavily commented script to test and explain all aspects of the GET native."
]

;;-----------------------------------------------------------------------------
;; A Battle-Tested QA Harness
;;
;; This section contains helper functions for our tests. It provides a
;; consistent way to check our assumptions against what Rebol actually does.
;;-----------------------------------------------------------------------------
all-tests-passed?: true
target-func-name: 'get

assert-equal: function [
    "Compares an expected value to an actual value and prints a clear message."
    expected [any-type!] "The value we expect the code to produce."
    actual [any-type!] "The value the code actually produced."
    description [string!] "A human-readable description of what we are testing."
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
    "Confirms that a piece of code correctly produces an error, as expected."
    code-to-run [block!] "The code we expect to fail."
    description [string!] "A description of the test."
][
    result: try code-to-run
    either error? result [
        print ["✅ PASSED:" description]
    ][
        set 'all-tests-passed? false
        print ["❌ FAILED:" description "^/   >> Expected an error, but code ran without error."]
    ]
]

print-test-summary: does [
    "Prints a final summary of the entire test run."
    print "^/============================================"
    either all-tests-passed? [
        print [rejoin ["✅ ALL `" mold target-func-name "` EXAMPLES PASSED"]]
    ][
        print [rejoin ["❌ SOME `" mold target-func-name "` EXAMPLES FAILED"]]
    ]
    print "============================================^/"
]
;;-----------------------------------------------------------------------------

print "--- SECTION 1: Basic Word and Path Retrieval ---"
;
; CONTEXT: The most fundamental job of `get` is to retrieve a value that is
; stored in a variable (a "word"). It also works with "paths" to access
; data inside objects.
; WHY IT'S A GOOD CHOICE: `get` allows you to access data *indirectly*.
; Instead of writing `test-integer`, you can write `get 'test-integer`.
; This is powerful when the name of the variable you want to access is
; itself stored in another variable.
;
test-integer: 42
test-string: "hello world"
test-obj: make object! [name: "test-object" value: 100]

assert-equal 42 (get 'test-integer) "GET retrieves an integer value from a word."
assert-equal "hello world" (get 'test-string) "GET retrieves a string value from a word."
assert-equal "test-object" (get 'test-obj/name) "GET retrieves a value from a path."


print "--- SECTION 2: The 'Identity Function' Behavior ---"
;
; CONTEXT: What happens if you give `get` something that isn't a variable
; name (a word!) or a path?
; WHY IT'S IMPORTANT: Rebol's `get` has a special behavior: it simply returns
; the value you gave it. `get 123` returns `123`. This makes `get` predictable.
; It only "looks up" data for words and paths; for everything else, it does nothing.
; This prevents unexpected behavior.
;
assert-equal 123 (get 123) "GET on a literal integer! returns itself."
assert-equal "foo" (get "foo") "GET on a literal string! returns itself."
assert-equal [a b] (get [a b]) "GET on a literal block! returns itself."
assert-equal none (get none) "GET on a literal none! returns itself."


print "--- SECTION 3: The Path! vs. Block! Distinction ---"
;
; CONTEXT: In Rebol, `'obj/name` (a path!) and `[obj name]` (a block!) can
; look similar, but they are very different to `get`.
; WHY IT'S A GOOD CHOICE: This demonstrates `get`'s strict rules. It will only
; "follow the path" if you give it a real `path!` value. If you give it a
; `block!`, it will follow the "Identity Function" rule from Section 2 and
; just return the block itself. This prevents blocks of data from being
; accidentally executed as paths.
;
assert-equal "test-object" (get 'test-obj/name) "GET on a PATH! evaluates the path."
assert-equal ['test-obj/name] (get ['test-obj/name]) "GET on a BLOCK! that looks like a path returns the block itself."


print "--- SECTION 4: Unset Words and the /ANY Refinement ---"
;
; CONTEXT: Trying to access a variable that doesn't exist (is "unset")
; normally crashes a Rebol script. This is a common source of bugs.
; WHY IT'S A GOOD CHOICE: `get` provides the `/any` refinement as a safety
; mechanism. `get/any 'unknown-word` will not crash. Instead, it returns a
; special `unset!` value. This lets you safely check if a variable exists
; without wrapping your code in complex `try` blocks.
;
if value? 'unset-word [unset 'unset-word]
assert-error [get 'unset-word] "GET on an unset word produces an error."

either unset? get/any 'unset-word [
    print "✅ PASSED: GET/ANY on an unset word returns an unset! value."
][
    set 'all-tests-passed? false
    print "❌ FAILED: GET/ANY should have returned an unset! value."
]


print "--- SECTION 5: Special Behavior with OBJECT! ---"
;
; CONTEXT: Sometimes you don't care about the names of the fields in an
; object, you just want all the data it contains.
; WHY IT'S A GOOD CHOICE: `get` has a special mode for objects. If you `get` an
; object directly, it returns a `block!` containing all of the object's
; values in the order they were defined. This is a fantastic shortcut for
; iterating over an object's data without needing to know its internal structure.
;
person: make object! [name: "Bob" age: 25]
assert-equal ["Bob" 25] (get person) "GET on an object! extracts its values into a block."


print "--- SECTION 6: Correct Dynamic Field Access ---"
;
; CONTEXT: Imagine you have a list of field names and you want to get the
; value for each of those fields from an object.
; WHY IT'S A GOOD CHOICE: This shows how `get` (or in this case, the related
; `/:` accessor, which is syntactic sugar for this kind of `get`) can be
; used in a loop. We `collect` the results of accessing each `field` from
; the `person` object, demonstrating a powerful data extraction pattern.
;
fields: [name age]
results: collect [foreach field fields [keep person/:field]]
assert-equal ["Bob" 25] results "Dynamic field access using /: accessor is correct."


print "--- SECTION 7: Safe Default Value Pattern ---"
;
; CONTEXT: A very common task is to get a configuration value, but if it
; doesn't exist, use a safe default value instead of crashing.
; WHY IT'S A GOOD CHOICE: This pattern combines `either`, `error?`, and `try` with
; `get` to create a robust, industrial-strength "safe get". If `get 'defined-var`
; fails, `try` catches the error, `error?` detects it, and `either` provides
; the default value. If it succeeds, `either` provides the retrieved value.
;
if value? 'defined-var [unset 'defined-var]
defaulted-value: either error? result: try [get 'defined-var] [
    "default-value"
][
    result
]
assert-equal "default-value" defaulted-value "Safe default value pattern works for unset variables."


print "--- SECTION 8: Dynamic Map! Key Retrieval ---"
;
; CONTEXT: A `map!` is a key-value data store. We often need to get a value
; from a map, but the key we're looking for might be stored in a variable.
; WHY IT'S A GOOD CHOICE: This demonstrates how to build a `path!` at runtime.
; We `reduce` a block containing the map's name and the variable holding our
; key. `to-path` turns this block into a true path (`config-map/port`).
; `get` can then evaluate this dynamically created path to fetch the correct value.
;
config-map: make map! [host: "localhost" port: 8080]
setting-to-get: 'port
dynamic-path: to-path reduce ['config-map setting-to-get]
assert-equal 8080 (get dynamic-path) "GET can retrieve from a map using a dynamically constructed path."


print "--- SECTION 9: Configuration Validation ---"
;
; CONTEXT: Before running an application, you might need to check if all
; required configuration variables have been set.
; WHY IT'S A GOOD CHOICE: This shows the correct, safe way to loop through
; a list of required variable names and check if they exist. The key is using
; `value? setting`. If the word stored in `setting` (e.g., `'config-timeout`)
; has a value in the current context, `value?` returns `true`. This avoids
; the errors that would happen if we tried to `get` an unset variable directly.
;
if value? 'config-timeout [unset 'config-timeout]
required-settings: [config-timeout]
valid: true
foreach setting required-settings [
    unless value? setting [valid: false]
]
assert-equal false valid "Safely validating a missing configuration setting works."

config-timeout: 30
valid: true
foreach setting required-settings [
    unless value? setting [valid: false]
]
assert-equal true valid "Safely validating a present configuration setting works."


print "--- SECTION 10: Context-Specific Retrieval with BIND ---"
;
; CONTEXT: What happens if you have two variables with the same name, one
; "global" and one inside an object? How do you tell `get` which one to use?
; WHY IT'S A GOOD CHOICE: This demonstrates Rebol's powerful "context" system.
; The `bind` function creates a new word that is explicitly linked to a
; specific context (in this case, our `local-context` object). When we use
; `get` on this specially bound word, it knows to look *inside* the object
; for the value, ignoring the global variable of the same name. This is
; essential for creating modules and avoiding naming conflicts.
;
my-var: "I am global"

local-context: make object! [
    my-var: "I am local to the object"
]
assert-equal "I am global" (get 'my-var) "GET finds the global variable by default."

word-bound-to-context: bind 'my-var local-context
assert-equal "I am local to the object" (get word-bound-to-context) "GET respects binding and retrieves value from the specified context."

print-test-summary
