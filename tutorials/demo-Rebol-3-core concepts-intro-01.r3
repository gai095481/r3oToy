REBOL [
    Title: "Demo of Rebol 3 Oldes Core Concepts Intro Part 1"
    Date: 15-Jun-2025
    File: %demo-Rebol-3-core concepts-intro-01.r3
    Author: "Gemini Pro Preview 2025-06, Claude 4 Sonnet AI Assistants"
    Version: 0.1.0
    Purpose: {
        A collection of runnable examples demonstrating fundamental concepts of
        the Rebol 3 Oldes programming language for novices. This script serves as an educational
        resource, illustrating:

        - Variable Assignment: The `set-word!` datatype (`word:`), case-insensitivity,
          and the mandatory space after the colon.
        - Core Datatypes: The use of `type?` to inspect common types like `integer!`,
          `string!`, `decimal!`, `tuple!`, `url!` and `block!`.
        - Special Word Notations: The behavioral differences between a plain `word`,
          `:word` (get-word), `'word` (lit-word) and `/word` (refinement).
        - Malleability: How core functions can be redefined and the "code is data"
          principle using `block!` and `do`.
        - Path Syntax: Accessing nested elements in blocks and the distinction
          between path access (`/`) and mathematical division.
    }
    Note: {
        This script is organized into modular functions for clarity.  It's
        designed to be run using the Rebol 3 Oldes branch and it prints
        descriptive output for each demonstrated concept.  All variables are
        managed in the main script body to ensure correct scoping for the
        demonstration functions.
    }
    Keywords: [
        rebol rebol3 tutorial demonstration example novice concept word-notation
        assignment variable datatype plain-word set-word get-word lit-word path
        malleability block do case-insensitivity path-access
    ]
]

;;===================================================================
demonstrate-assignment-and-types: function [
][
    {Demonstrate variable assignment, core datatypes, and type inspection.}
    print "--- Section I & II: Variable Assignment and Datatypes ---"

    print "^/-- 1.1. Core Syntax --"
    print ["Value of 'num':" num]
    print ["Value of 'site':" site]

    print "^/-- 1.2. The `set-word!` Datatype --"
    print ["The type of the `set-word!` `num:` is:" type? to-set-word 'num]

    print "^/-- 1.3. Evaluation and Case-Insensitivity --"
    print ["Value of 'Pi' (note the case):" Pi]

    print "^/-- 2.1 & 2.2. The `type?` Function and Datatype Examples --"
    str: "hello"
    color: 255.0.0
    my-block: [a b c]
    my-path: system/options/home
    print ["type? num:" type? num]
    print ["type? pi:" type? pi]
    print ["type? str:" type? str]
    print ["type? color:" type? color]
    print ["type? site:" type? site]
    print ["type? my-block:" type? my-block]
    print ["type? my-path:" type? my-path]
]

;;===================================================================
;; REBOL "word"" Notation Terminology
;; The accurate terminology is:
;;
;; 'word = lit-word (literal word).
;; word = plain word (evaluates to bound value).
;; :word = get-word (gets value without evaluation).
;; /word = refinement (function option).
;;===================================================================
demonstrate-word-notations: function [
][
    {Demonstrate special word notations and their behavior:
    RETURNS: [none!] "No return value, outputs demonstration to console"
    ERRORS: None - function contains no error conditions}

    print "^/--- Section III: Special Rebol Word Notations ---"
    print "^/-- `'word` (lit-word) - Get the word as a literal symbol --"
    print ["The datatype of `'apple` is:" type? 'apple]
    print ["The value of `'apple` is:" mold 'apple]

    print "^/-- `word` (plain word) - Evaluates to its bound value --"
    print ["The type of `append` (when accessed as function) is:" type? :append]
    print ["Calling `append [a] 'b'` results in:" mold append copy [a] 'b]
    print ["Note: Plain word `append` evaluates to execute the function"]

    print "^/-- `:word` (get-word) - Get the value without evaluating it --"
    print ["The value of `:append` is the function itself, which is type:" type? :append]
    print ["The value of `:append` (molded) is:" mold :append]

    print "^/-- `/word` (refinement) - Use as an option for a function --"
    print ["Copying 5 chars from ""Hello World"" with `/part`:" mold copy/part "Hello World" 5]
]

;;===================================================================
demonstrate-malleability: function [
][
    {Demonstrate REBOL's malleable nature by redefining core functions and treating code as data.}
    print newline
    print "--- Section IV: The Malleable Nature of Rebol ---"

    ;; 4.1 Redefining a Core Function
    print "^/-- 4.1. Redefining a Core Function --"
    print "Original `print` function is about to be redefined."

    set 'print "I am not a function anymore!"
    probe "Value of the word 'print' is now:"
    probe get 'print
    set 'print get 'print-original

    print "Restored `print`. The new value of 'print' is:"
    probe :print

    ;; 4.2 Code is Data: The `block!`
    print "^/-- 4.2. Code is Data: The `block!` --"
    ;; Note: The initial value of pi is printed in the previous section.
    ;; This section focuses on demonstrating the change.

    code-block: [
        print "This code inside the block is now being executed..."
        pi: 3.14159
    ]
    print ["The 'code-block' is just data:" mold code-block]

    do code-block
    print ["After `do code-block`, the value of 'pi' is now:" pi]
]

;;===================================================================
demonstrate-paths: function [
][
    {Demonstrate accessing nested data with path notation and spacing rules.}
    print newline
    print "--- Section V: Accessing Nested Data with Paths ---"

    data-block: [10 "hello" [a b]]
    print ["The data-block is:" mold data-block]
    print ["Accessing the 2nd element with `data-block/2`:" data-block/2]
    print ["Accessing the 1st element of the nested block with `data-block/3/1`:" data-block/3/1]

    numFoo: 10
    print "^/-- Spacing Example --"
    print ["`numFoo / 2` (division) evaluates to:" numFoo / 2]

    numFoo-path-block: [aa bb cc]
    print ["A block named `numFoo-path-block` contains:" mold numFoo-path-block]
    print ["`numFoo-path-block/2` (path access) evaluates to:" numFoo-path-block/2]
]

;; ===================================================================
;; --- Main Execution Block ---
;; ===================================================================
num: 5
site: http://www.rebol.com
pi: 3.14

print "====== Running Code Examples for Rebol Concepts Intro 01 ======^/"
print-original: :print
demonstrate-assignment-and-types
demonstrate-word-notations
demonstrate-malleability
demonstrate-paths

print "^/====== End of Rebol Concepts Intro 01 Examples ======"
