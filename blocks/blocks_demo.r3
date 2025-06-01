REBOL[]

blkFoo: copy []
append blkFoo "cat"
append blkFoo "cow"
append blkFoo "dog"
append blkFoo "pig"
;; "print" only takes 1 argument and returns "none".
print blkFoo

;; appending more than 1 character to an item is illegal:
append (first blkFoo) #"s"
append (second blkFoo) #"s"
append (third blkFoo) #"s"
append (last blkFoo) #"s"
print blkFoo

print pick blkFoo 2
print pick blkFoo 3
;; The search pattern must exactly match an entire item in the list:
replace/case blkFoo "dogs" "zebras"
print blkFoo


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This example demonstrates the creation of literal blocks in Rebol 3.
;; A block is a fundamental data type in Rebol.  It acts as a container,
;; capable of holding a series of any other Rebol values, including other blocks.
;; Literal blocks are defined by enclosing values within square brackets `[ ]`.

print "--- Demonstrating Literal Block Creation ---"
print ["--- Example 1: An Empty Block ---" newline]

;; You can create an empty block like this.
empty-block: []

;; Let's print the block.
;; To see its string representation (how you would type it in code), use `mold`.
;; `mold` is safer for printing blocks that might contain unbound words,
;; as `print` on a block might try to evaluate words.
print "The empty-block (molded):"
print mold empty-block

;; We can check its type.
print ["Type of empty-block:  " type? empty-block] ;; Should be `block!`.

;; And its length (number of elements).
print ["Length of empty-block:" length? empty-block] ;; Should be 0.
print newline

;; --- Example 2: A Block with Various Literal Values ---
print "--- Example 2: A Block with Various Literal Values ---"

mixed-block: [
    100             ;; This is an integer!
    "hello Rebol"   ;; This is a string!
    #"R"            ;; This is a char! (a single character)
    apple           ;; This is a word! (here, it's a literal symbol, not a variable's value)
    true            ;; This is a logic! value (for true/false)
    none            ;; This represents 'no value' or 'nothing'
    [nested data]   ;; This is another block inside the main block
]

;; Using `mold` to print the block ensures we see its structure without evaluation.
print "The mixed-block (molded):"
print mold mixed-block

print ["Type of mixed-block:  " type? mixed-block]   ;; Should be `block!`.
print ["Length of mixed-block:" length? mixed-block] ;; Counts top-level elements.
print newline

;; --- A Note on `word!` types in Literal Blocks ---
print "--- A Note on `word!` types in Literal Blocks ---"
;; In the `mixed-block` above, `apple` is a `word!`.  When a `word!` appears
;; inside a literal block like this (that is, data you type directly into your script),
;; it is generally treated as a symbolic literal.  It represents the word "apple" itself,
;; not the value of a variable named `apple` (unless the block is later *evaluated*
;; by functions like `do` or `reduce`).

;; For example, if we try to get the type of the fourth element:
word-element: pick mixed-block 4 ;; `pick` gets an element by its 1-based index.

;; When printing the word itself, it's fine.
print ["The fourth element is (the word itself):" word-element]
;; To show it as it would be typed in code, or safely within other structures, mold it.
print ["The fourth element (molded):" mold word-element]

print ["The type of the fourth element is:" type? word-element] ;; This will be `word!`.

;; If `apple` was a variable, like `apple: "Fuji"`, the `word!` `apple` inside
;; `mixed-block` still just means the symbol 'apple'. To get the *value* of such
;; a word if it's a variable, you would typically need to evaluate it,
;; often using `get` or by reducing/doing the block.  This script focuses on
;; literal block construction, not evaluation.
print newline

print "--- End of Literal Block Creation Examples ---"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This script demonstrates creating blocks using the `make` constructor in Rebol 3.
;; While literal blocks `[]` are common, `make` provides more control,
;; especially for pre-allocating memory or constructing blocks from other types.

print "--- Demonstrating Block Creation with `make` ---"

;; --- Example 1: Pre-allocating a Block with `make block! <size>` ---
print ["--- Example 1: Pre-allocating a Block with `make block! <size>` ---" newline]

;; `make block! <integer-size>` creates an empty block but hints to Rebol
;; to reserve space for a certain number of elements.
;; For demonstration, we use a small size. In real-world applications,
;; if you anticipate holding many elements (e.g., lines from a large file,
;; or many data records), this size might be much larger, like `make block! 10000`
;; or `make block! (size-of-file / average-line-length-estimate)`.
pre-allocated-block: make block! 10 ;; Hint to reserve space for 10 elements for this demo.

print "The pre-allocated-block (molded):"
print mold pre-allocated-block ;; It's initially empty.

print ["Type of pre-allocated-block:  " type? pre-allocated-block] ;; Still `block!`.
print ["Length of pre-allocated-block:" length? pre-allocated-block] ;; Initially 0.
print newline

print ["--- Why Pre-allocate? ---" newline]
;; When you repeatedly `append` items to a block that wasn't pre-allocated (or
;; has reached its current capacity), Rebol might need to:
;; 1. Find a new, larger piece of memory.
;; 2. Copy all existing elements from the old memory location to the new one.
;; 3. Add the new element.
;; This process of resizing and copying can take time, especially for large blocks
;; or if done very frequently in a loop (e.g., reading a large file line by line
;; and appending each line to a block).

;; By using `make block! <size>`, you tell Rebol: "I expect to put roughly
;; this many items in here." Rebol can then reserve a suitable amount of memory
;; upfront. This can significantly reduce the number of times Rebol needs to resize
;; the block internally as you add elements, potentially making your code run faster.

;; Note: The `size` in `make block! <size>` is a *capacity hint*. The block
;; still starts empty (length 0). You can append more than the initial hint,
;; and Rebol will resize if needed, but the initial hint helps optimize.
;; This pre-allocation is not directly visible via a `capacity?` function
;; in Rebol 3; it's an internal optimization.

;; Let's add some items to see it grow.
append pre-allocated-block "first item"
append pre-allocated-block "second item"
print "After appending two items (molded):"
print mold pre-allocated-block
print ["New length:" length? pre-allocated-block] ;; Now 2.
print newline

;; --- Example 2: Creating a Block from a String with `make block! <string>` ---
print ["--- Example 2: Creating a Block from a String with `make block! <string>` ---" newline]

;; `make block! "..."` can parse a string and create a block from it.
string-sourced-block: make block! "[one 2 three]" ;; Note: string contains valid block syntax.

print "The string-sourced-block (molded):"
print mold string-sourced-block ;; Output: [[one 2 three]]

;; Note the result: [[one 2 three]]. When the input string to `make block!`
;; is a fully formed block representation (like "[one 2 three]"), `make` (acting
;; similarly to `load` here) creates a new block where the *first element*
;; is the block parsed from the string.
;; This differs from `to-block "[one 2 three]"` which would result in `[one 2 three]`.
;; `make block! <string>` is akin to `reduce [load <string>]` if the load results in a single value.
;; If `load <string>` produces multiple values (e.g. `load "a b"`), `make block! <string>` still produces a block of those multiple values.

print ["Type of string-sourced-block:  " type? string-sourced-block] ;; block!
print ["Length of string-sourced-block:" length? string-sourced-block] ;; 1 (because the outer block contains one element: the inner [one 2 three] block)
print newline

string-sourced-block-no-brackets: make block! "alpha beta gamma"
;; If the string doesn't have outer brackets, `make block!`
;; will often treat space-separated items as elements of the new block,
;; similar to `load "alpha beta gamma"`.
print "Block from string without outer brackets (molded):"
print mold string-sourced-block-no-brackets ;; Output: [alpha beta gamma]
print ["Length:" length? string-sourced-block-no-brackets] ;; Output: 3
print newline

;; --- Example 3: `make block! <existing-block>` and Shallow vs. Deep Copy ---
print ["--- Example 3: `make block! <existing-block>` and Shallow vs. Deep Copy ---" newline]

original-block: [10 [200 300] 30] ;; A block with a nested block.
print ["Original block before copy:" mold original-block]

;; Using `make block! <existing-block>` creates a *new, shallow copy*.
shallow-copied-block: make block! original-block

;; What is a "Shallow Copy"?
;; A shallow copy creates a new block, and it copies the elements from the
;; original block into this new block.
;; - If an element is a simple value (like an integer, char, logic), the value itself is copied.
;; - If an element is *another series* (like a nested block or a string), the *reference*
;;   (or pointer) to that series is copied, NOT the series' content itself.
;; This means both the original block and the shallow copy will point to the
;; *exact same* nested block or string in memory if those elements were series.

;; Let's modify the original block's top level.
append original-block 40
print ["Original block after top-level append:" mold original-block]
print ["Shallow copy after original's top-level append:" mold shallow-copied-block]
;; The shallow copy is unaffected by adding a new element to the original's top level,
;; because `shallow-copied-block` is a distinct top-level block.

;; Now, let's modify the *nested block* VIA the shallow copy.
inner-block-from-shallow-copy: pick shallow-copied-block 2 ;; Get the nested block [200 300]
append inner-block-from-shallow-copy 301 ;; Modify this nested block.

print ["Shallow copy after modifying its nested block:" mold shallow-copied-block]
print ["Original block AFTER nested block modified via shallow copy:" mold original-block]
;; Crucially, the `original-block` ALSO shows this change (301 is added).
;; This is because both `original-block/2` and `shallow-copied-block/2`
;; were pointing to the *same* underlying `[200 300]` block in memory.

;; What is a "Deep Copy"?
;; A deep copy (e.g., using `copy/deep original-block`) creates a new block AND
;; recursively creates new copies of any nested series (blocks, strings, etc.) it contains.
;; This ensures that the new copy is completely independent of the original,
;; even regarding its nested structures.

deep-copied-block: copy/deep original-block ;; original-block is now [10 [200 300 301] 30 40]

;; Let's modify the nested block in the deep copy.
inner-block-from-deep-copy: pick deep-copied-block 2
append inner-block-from-deep-copy 302

print ["Deep copy after modifying its (deeply copied) nested block:" mold deep-copied-block]
print ["Original block AFTER nested block modified via deep copy:" mold original-block]
;; The `original-block` does NOT show the change (302). It's still [10 [200 300 301] 30 40].
;; This is because `deep-copied-block/2` is a completely separate block from `original-block/2`.

;; When to use Shallow Copy (like `make block! existing-block` or `copy existing-block`):
;; - When you want a new block but don't mind (or explicitly want) it to share
;;   any mutable sub-series (like nested blocks or strings) with the original.
;; - If the block only contains immutable values (integers, chars etc.), or if you
;;   won't be modifying any nested series.
;; - It's generally faster and uses less memory than a deep copy.

;; When to use Deep Copy (like `copy/deep existing-block`):
;; - When you need a completely independent duplicate of a block, including all its
;;   nested structures, so that modifications to one do not affect the other.
;; - This is crucial if you're passing a block to a function that might modify it
;;   (or its sub-series) and you want to preserve the original.
;; - Essential when dealing with complex data structures that will be independently manipulated.
print newline

print "--- End of Block Creation with `make` Examples ---"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This script demonstrates creating blocks from strings using `to-block` and `load`.
;; These functions are essential for converting textual representations of blocks
;; (e.g., read from a file, received over a network, or constructed as a string)
;; into actual Rebol `block!` data types.

print "--- Demonstrating Block Creation with `to-block` and `load` ---"

;; --- Example 1: Using `to-block` ---
print newline ;; Add separation before this example section.
print "--- Example 1: Using `to-block` ---"

;; `to-block` is a versatile function used to convert various data types to a `block!`.
;; IMPORTANT: When `to-block` is given a single STRING, it typically creates a new block
;; containing that ONE string as its single element. It does NOT parse the string's content
;; in the same way `load` does.

print "-- `to-block` with a simple content string --"
simple-string-content: "one 2 three"
block-from-simple-string: to-block simple-string-content

print ["Original string:" mold simple-string-content]
print ["Resulting block (molded):" mold block-from-simple-string]
print ["Type:" type? block-from-simple-string]
print ["Length:" length? block-from-simple-string] ;; Will be 1.

print "-- `to-block` with a string containing block syntax --"
string-with-block-syntax: "[alpha [beta gamma] delta]"
block-from-syntax-string: to-block string-with-block-syntax

print ["Original string:" mold string-with-block-syntax]
print ["Resulting block (molded):" mold block-from-syntax-string]
print ["Type:" type? block-from-syntax-string]
print ["Length:" length? block-from-syntax-string] ;; Will be 1.

;; `to-block` is more commonly used to convert other *series types* (like a vector or a hash)
;; or single values into a block containing those items/item.
;; For example: `to-block 123` results in `[123]`.
;; If you have multiple values you want in a block, you often construct the block directly
;; or `reduce` a block of expressions.
;; To parse a string into a block of multiple values, `load` is the primary tool.

;; --- Example 2: Using `load` ---
print newline ;; Add separation before this example section.
print "--- Example 2: Using `load` ---"

;; `load` is a powerful function that parses a string (or a binary series) as Rebol source code
;; and returns the value(s) resulting from that parse. If the string represents
;; a block, `load` will return that block.

print "-- `load` with a string representing a simple block --"
string-data-for-load: "[item1 item2 item3]"
loaded-block-data: load string-data-for-load

print ["Original string:" mold string-data-for-load]
print ["Resulting block (molded):" mold loaded-block-data]
print ["Type:" type? loaded-block-data]
print ["Length:" length? loaded-block-data]

print "-- `load` with a string representing a nested block structure --"
string-nested-data-for-load: { [10 ["inner text" 20] 30] }
loaded-nested-block: load string-nested-data-for-load

print ["Original string:" mold string-nested-data-for-load]
print ["Resulting block (molded):" mold loaded-nested-block]
print ["Type:" type? loaded-nested-block]
print ["Length:" length? loaded-nested-block]

print "-- `load` with invalid block syntax string --"
invalid-string-for-load: "[a b c" ;; Missing closing bracket
error-loaded-block: try [load invalid-string-for-load]

print ["Original invalid string:" mold invalid-string-for-load]
either error? error-loaded-block [
    print "`load` resulted in an error, as expected:"
    print mold error-loaded-block
] [
    print ["`load` unexpectedly succeeded (molded):" mold error-loaded-block]
]

print ["-- CAUTION with `load`: Potential for Code Execution --"]
;; `load` parses Rebol source. If a string contains executable code, `load` itself doesn't
;; execute it directly, but it creates the structure that `do` would execute.
;; When `load`ing data, ensure the source string is known to be safe data literals.
;; (The script focuses on `load` for simple data block construction.)


;; --- Example 3: `load` (and `to-block`) create NEW data structures ---
;; --- Revisiting Shallow vs. Deep Copy in this context ---
print newline ;; Add separation before this example section.
print "--- Example 3: `load`, `to-block`, and Fresh Data Structures ---"

;; When `load` creates a block from a string (e.g., `"[aa [bb cc] dd]"`),
;; the resulting main block and all its nested blocks are *newly created in memory*.
;; `to-block <string>` also creates a new block (typically `[<string>]`).

loaded-structure-string: "[aa [bb cc] dd]"
my-loaded-block: load loaded-structure-string

print ["String used for loading:" mold loaded-structure-string]
print ["`my-loaded-block` (molded):" mold my-loaded-block]

print "-- Making a SHALLOW copy of the loaded block --"
shallow-copy-of-loaded: copy my-loaded-block
inner-from-shallow: pick shallow-copy-of-loaded 2
append inner-from-shallow 'ee

print ["`my-loaded-block` after its shared inner block was modified via shallow copy:" mold my-loaded-block]
print ["`shallow-copy-of-loaded` after modifying its inner block:" mold shallow-copy-of-loaded]

print "-- Making a DEEP copy of the loaded block --"
my-loaded-block: load loaded-structure-string ;; Reset
deep-copy-of-loaded: copy/deep my-loaded-block
inner-from-deep: pick deep-copy-of-loaded 2
append inner-from-deep 'ff

print ["`my-loaded-block` after its inner block was NOT affected by deep copy modification:" mold my-loaded-block]
print ["`deep-copy-of-loaded` after modifying its (independent) inner block:" mold deep-copy-of-loaded]

;; Summary for `load` and copies:
;; 1. `load` creates entirely new data structures from valid string input.
;; 2. If these structures contain nested series, those are also newly created by `load`.
;; 3. `copy` (shallow) of a `load`ed block shares references to these `load`ed nested series.
;; 4. `copy/deep` of a `load`ed block creates independent copies of all nested series.

print newline ;; Add separation before the final closing line.
print "--- End of `to-block` and `load` Examples ---"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This example demonstrates the `append` action in Rebol 3, specifically how it's
;; used to add elements to the end of a `block!`.  We will explore appending
;; single values, other blocks (with and without the `/only` refinement) and
;; understand `append`'s return value.
comment {
Key aspects covered in this script:
Appending Single Values: Demonstrates appending different data types (integer!, string!, word!, none!) to a block and how the block grows.
Appending Blocks (Default): Clearly shows that by default, the elements of the appended block are merged into the target block.
Appending Blocks with /only: Explains and demonstrates how /only causes the appended block to be added as a single, nested element.
Appending to Empty Blocks: Shows that append works as expected on initially empty blocks.
Return Value of append:
Explains that append modifies the series in place.
Shows that append returns the head of the modified series.
Demonstrates that this return value is not a new copy but refers to the same modified series using same?.
Clarity for Novices: Comments explain the "why" and "how" for each step, especially for concepts like /only and the return value.
Validation Checks (Implicit): The print mold ... and print ["Length:" length? ...] statements serve as
implicit validation checks that the user can observe. The type check on the /only appended block also serves this purpose.
}

print "--- Demonstrating `append` with Blocks ---"

;; --- Example 1: Basic `append` with Single Values ---
print newline
print "--- Example 1: Basic `append` with Single Values ---"

my-block: [10 "apple"]
print ["Initial 'my-block':" mold my-block]

print "-- Appending an integer --"
append my-block 20
print ["After appending 20:" mold my-block]
print ["Length:" length? my-block]

print "-- Appending a string --"
append my-block "banana"
print ["After appending 'banana':" mold my-block]
print ["Length:" length? my-block]

print "-- Appending a `word!` --"
append my-block 'orange ;; 'orange is a word!
print ["After appending 'orange:" mold my-block]
print ["Length:" length? my-block]

print "-- Appending `none` --"
append my-block none
print ["After appending `none`:" mold my-block]
print ["Length:" length? my-block] ;; `none` is a distinct value and adds to length.

;; --- Example 2: Appending a Block (Default Behavior) ---
print newline
print "--- Example 2: Appending a Block (Default Behavior) ---"

block-a: ["cat" "dog"]
block-to-append: ["fish" "bird"]
print ["Initial 'block-a':" mold block-a]
print ["Block to append:" mold block-to-append]

;; By default, when you append a block to another block, the *elements*
;; of the second block are added individually to the first block.
;; The second block is effectively 'merged' into the first.
append block-a block-to-append
print ["'block-a' after appending 'block-to-append':" mold block-a]
print ["Length of 'block-a':" length? block-a] ;; Should be 4 (cat, dog, fish, bird)

;; --- Example 3: Appending a Block with `/only` Refinement ---
print newline
print "--- Example 3: Appending a Block with `/only` Refinement ---"

block-b: [100 200]
block-for-only-append: [300 400]
print ["Initial 'block-b':" mold block-b]
print ["Block for /only append:" mold block-for-only-append]

;; The `/only` refinement changes `append`'s behavior when appending a series (like a block).
;; With `/only`, the block being appended is added as a *single element*
;; to the target block, rather than its contents being merged.
append/only block-b block-for-only-append
print ["'block-b' after `append/only` 'block-for-only-append':" mold block-b]
print ["Length of 'block-b':" length? block-b] ;; Should be 3 (100, 200, [300 400])
;; The third element is now the block `[300 400]` itself.

;; Let's check the type of the last element.
print ["Type of last element in 'block-b':" type? last block-b] ;; Should be `block!`.

;; --- Example 4: Appending to an Empty Block ---
print newline
print "--- Example 4: Appending to an Empty Block ---"

empty-one: []
print ["Initial 'empty-one':" mold empty-one]

print "-- Appending a single value to empty block --"
append empty-one "hello"
print ["After appending 'hello':" mold empty-one]
print ["Length:" length? empty-one]

print "-- Appending a block (default) to a block that now has one item --"
append empty-one ["world" "!"]
print ["After appending ['world' '!'] (default):" mold empty-one]
print ["Length:" length? empty-one]

print "-- Appending a block with /only to it --"
append/only empty-one ["nested" "example"]
print ["After `append/only` ['nested' 'example']:" mold empty-one]
print ["Length:" length? empty-one]

;; --- Example 5: Understanding the Return Value of `append` ---
print newline
print "--- Example 5: Understanding the Return Value of `append` ---"

;; The `append` action (like many series modification actions in Rebol)
;; modifies the target series *in place*.
;; It also returns a value: the *head* (beginning) of the modified series.

data-block: [1 2]
print ["'data-block' before append:" mold data-block]

return-value: append data-block 3
print ["'data-block' after append:" mold data-block] ;; Shows [1 2 3]
print ["Return value of `append data-block 3` (molded):" mold return-value] ;; Shows [1 2 3]

;; This is useful because it allows chaining or immediate use of the modified series' head.
;; For example, you could print the result directly:
print ["Result of printing the return of an append:" mold (append data-block 4)] ;; data-block is now [1 2 3 4]
print ["'data-block' current state:" mold data-block]

;; It's important to note that the return value is not a *new copy* of the block,
;; but rather a reference to the original (now modified) block, positioned at its head.
print ["Are 'data-block' and 'return-value' the same series?" same? data-block return-value] ;; Will be true.
;; (`return-value` still holds the reference to `data-block` from the first append in this example).

print newline
print "--- End of `append` with Blocks Examples ---"


;; This example demonstrates the `insert` action in Rebol 3, focusing on its use
;; with `block!` data types. `insert` allows you to add elements at specific
;; positions within a block, not just at the end like `append`. We'll explore
;; inserting single values, blocks (with and without `/only`), behavior with
;; different positions (head, middle, tail) and `insert`'s return value.

comment {
Key Aspects Covered & Lessons from example-block-insert.r3:
Core insert Functionality:
Demonstrated inserting single values and blocks at various positions: head, middle and tail of a target block.
Illustrated the default behavior of insert where elements of an inserted block are merged.
/only Refinement with insert:
Clearly showed how insert/only causes an entire block to be inserted as a single, nested element.
Positional Arguments for insert:
Used find to get a series position for middle insertions.
Correctly used the tail action (e.g., tail my-block) to obtain the tail position for insertions at the end, distinguishing it from the tail? predicate.
Return Value of insert:
Explained and demonstrated that insert returns the position in the modified series just past the inserted material.
Showed how to use this returned position (e.g., with pick).
Illustrated the specific return value when inserting at the tail (an empty series at the very end).
Robust Conditional Logic:
Correctly used either condition [true-branch] [false-branch] for if-else constructs, avoiding the non-existent else keyword.
Employed if not none? position [...] to safely guard insert calls that depend on a position found by find.
Handling none Positions:
Demonstrated that insert will error if its first argument (the series/position) is none.
Showed the correct practice of checking for none before attempting insert if the position's existence is uncertain.
Multiple Logical Conditions:
Successfully used the all [...] block to evaluate multiple and-ed logical conditions robustly and clearly, particularly for validating the return position of insert at tail.
Clarity for Novices:
Maintained detailed comments explaining Rebol concepts, the purpose of different code sections and the behavior of insert and its refinements.
Implicit validation was present through print mold ... and print ["Length:"...] statements, allowing observation of outcomes.
Iterative Debugging Insights:
The process highlighted common Rebol pitfalls: tail vs. tail?, if vs. either, handling of none and the evaluation of compound logical expressions
These are valuable learning points embedded in the final correct script.
}

print "--- Demonstrating `insert` with Blocks ---"

;; --- Example 1: Basic `insert` with Single Values ---
print newline
print "--- Example 1: Basic `insert` with Single Values ---"

my-block: ["banana" "cherry"]
print ["Initial 'my-block':" mold my-block]

print "-- Inserting at the head (beginning) --"
insert my-block "apple"
print ["After inserting 'apple' at head:" mold my-block]
print ["Length:" length? my-block]

print "-- Inserting in the middle --"
position-to-insert-before: find my-block "cherry"
either not none? position-to-insert-before [ ;; Check if 'cherry' was found
    insert position-to-insert-before "blueberry"
    print ["After inserting 'blueberry' before 'cherry':" mold my-block]
] [
    print "'cherry' not found in block, 'blueberry' not inserted."
]
print ["Length:" length? my-block]

print "-- Inserting at the tail (end) --"
;; To get the TAIL POSITION of a series, use the `tail` action.
;; `tail?` is a predicate that tests if a position IS the tail.
either block? my-block [ ;; Ensure my-block is still a block
    actual-tail-position: tail my-block ;; Use `tail` action here
    insert actual-tail-position "date"
    print ["After inserting 'date' at tail:" mold my-block]
    print ["Length:" length? my-block]
] [
    ;; This case should ideally not be reached if my-block remains a block.
    print ["'my-block' is not a block, cannot insert at tail. Current value:" mold my-block]
]


;; --- Example 2: Inserting a Block (Default Behavior) ---
print newline
print "--- Example 2: Inserting a Block (Default Behavior) ---"
block-a: ["red" "green" "blue"]
block-to-insert: ["yellow" "orange"]
print ["Initial 'block-a':" mold block-a]
print ["Block to insert:" mold block-to-insert]
position-in-a: find block-a "green"
either not none? position-in-a [
    insert position-in-a block-to-insert
    print ["'block-a' after inserting 'block-to-insert' before 'green':" mold block-a]
    print ["Length of 'block-a':" length? block-a]
] [
    print "Could not find 'green' in 'block-a'."
]

;; --- Example 3: Inserting a Block with `/only` Refinement ---
print newline
print "--- Example 3: Inserting a Block with `/only` Refinement ---"
block-b: [100 400 500]
block-for-only-insert: [200 300]
print ["Initial 'block-b':" mold block-b]
print ["Block for /only insert:" mold block-for-only-insert]
position-in-b: find block-b 400
either not none? position-in-b [
    insert/only position-in-b block-for-only-insert
    print ["'block-b' after `insert/only` before 400:" mold block-b]
    print ["Length of 'block-b':" length? block-b]
    print ["Type of second element:" type? pick block-b 2]
] [
    print "Could not find 400 in 'block-b'."
]

;; --- Example 4: Inserting into an Empty Block ---
print newline
print "--- Example 4: Inserting into an Empty Block ---"
empty-one: []
print ["Initial 'empty-one':" mold empty-one]
print "-- Inserting a single value into an empty block --"
insert empty-one "first"
print ["After inserting 'first':" mold empty-one]
print ["Length:" length? empty-one]
print "-- Inserting a block (default) into the block --"
;; When series (first arg) is empty, insert effectively prepends.
insert empty-one ["second" "third"]
print ["After inserting ['second' 'third'] at head:" mold empty-one]
print ["Length:" length? empty-one]

;; --- Example 5: Understanding the Return Value of `insert` ---
print newline
print "--- Example 5: Understanding the Return Value of `insert` ---"
data-block: [10 20 50 60]
print ["'data-block' before insert:" mold data-block]
position-of-50: find data-block 50
either not none? position-of-50 [
    return-value: insert position-of-50 [30 40]
    print ["'data-block' after insert:" mold data-block]
    print ["Return value of `insert` (molded):" mold return-value]
    print ["Value at the returned position:" pick return-value 1]
] [
    print "Could not find 50 in 'data-block' for insert."
]

data-block-tail-insert: [1 2]
print ["'data-block-tail-insert' before insert at tail:" mold data-block-tail-insert]
either block? data-block-tail-insert [ ;; Ensure it's a block
    return-at-tail: insert (tail data-block-tail-insert) 3 ;; Use `tail` action
    print ["'data-block-tail-insert' after insert at tail:" mold data-block-tail-insert]
    print ["Return value of `insert` at tail (molded):" mold return-at-tail]
    actual-tail-of-original: tail data-block-tail-insert
    all-conditions-true: all [ ;; Use `all` for multiple logical conditions
        series? return-at-tail
        empty? return-at-tail
        actual-tail-of-original == return-at-tail
    ]
    print ["Is return value the tail of the original block? " all-conditions-true]
] [
    ;; This case should ideally not be reached if data-block-tail-insert remains a block.
    print ["'data-block-tail-insert' is not a block." mold data-block-tail-insert]
]

;; --- Example 6: `insert` with Non-Existent Positions (Illustrative) ---
print newline
print "--- Example 6: `insert` with Non-Existent Positions ---"
safe-block: [1 2 3]
print ["'safe-block' before attempt:" mold safe-block]
position-not-found: find safe-block 99 ;; This will be `none`.

print ["Position from `find safe-block 99` (is `none`?):" none? position-not-found]

;; You MUST check if the position is valid (not `none`) before using `insert`.
;; If `position-not-found` is `none`, `insert` will error if called with it as the series.
either not none? position-not-found [
    ;; This branch will not be taken in this specific example.
    insert position-not-found 100
    print ["'safe-block' after successful insert (should not happen here):" mold safe-block]
] [
    print "Cannot insert: Position to insert at was not found (it is `none`). Block remains unchanged."
]
print ["'safe-block' after attempt to insert at `none` position:" mold safe-block] ;; Should be unchanged.


print newline
print "--- End of `insert` with Blocks Examples ---"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This example demonstrates the `copy` action in Rebol 3, specifically for blocks.
;; We will focus on:
;; 1. Shallow copies: Understanding what they are and how modifications to
;;    nested series within a shallow copy can affect the original.
;; 2. The `/part` refinement: For copying a specific portion of a block.
;; The concept of `copy/deep` will be covered in a later, separate example.
comment {
Key aspects demonstrated:
Shallow copy with Simple Values: Shows that a new top-level block is created and modifications to it don't affect the original if elements are simple immutable types.
Shallow copy with Nested Blocks:
Crucially demonstrates that while the top-level block is a new copy, any nested series (like a sub-block) is shared by reference.
Modifying this shared nested block through the copy affects the original, and vice-versa.
Uses same? to confirm that the nested blocks in the original and the copy are indeed the same series object in memory.
Foreshadowing copy/deep: Comments explicitly state that copy/deep is needed for fully independent copies.
copy/part with Length: Shows copying a specified number of elements from the head or a given position.
copy/part with End Position: Demonstrates copying from a start position up to (but not including) a specified end position.
copy/part Robustness: Shows behavior when the specified length exceeds available elements (it copies what it can).
Shallow Nature of copy/part Results: Confirms that elements copied by copy/part are also shallow copies; if a copied element is a series, it's shared by reference.
Conditional Logic: Uses if not none? ... and if all [...] for safe conditional execution, strictly avoiding else with if.
Comments: Detailed explanations for novice users about shallow copies and the behavior of /part.
}

print "--- Demonstrating `copy` (Shallow) and `copy/part` with Blocks ---"

;; --- Example 1: Shallow `copy` of a Block with Simple Values ---
print newline
print "--- Example 1: Shallow `copy` of a Block with Simple Values ---"

original-simple-block: [10 "apple" true]
print ["Original simple block:" mold original-simple-block]

copied-simple-block: copy original-simple-block
print ["Copied simple block:" mold copied-simple-block]

;; Modify the copied block (top-level elements)
change copied-simple-block "banana" ;; Change "apple" to "banana"
append copied-simple-block 20

print ["Modified copied simple block:" mold copied-simple-block]
print ["Original simple block (should be unchanged):" mold original-simple-block]
;; For blocks with only simple, immutable values at the top level,
;; modifying the copy does not affect the original's top-level structure.

print ["Are original and copied simple blocks the same series?" same? original-simple-block copied-simple-block]
;; `false`, because `copy` creates a new top-level block series.

;; --- Example 2: Shallow `copy` with a Nested Block ---
print newline
print "--- Example 2: Shallow `copy` with a Nested Block ---"

original-nested-block: ["header" [1 2 3] "footer"]
print ["Original nested block:" mold original-nested-block]

copied-nested-block: copy original-nested-block
print ["Copied nested block (initially same content):" mold copied-nested-block]

print ["-- Modifying a top-level simple element in the copy --"]
change copied-nested-block "new-header" ;; Change "header"
print ["Copied nested block after top-level change:" mold copied-nested-block]
print ["Original nested block (top-level should be unchanged):" mold original-nested-block]
;; The original's "header" is not affected.

print ["-- Modifying the NESTED block VIA the copy --"]
;; Get the nested block from the *copied* version.
;; Because it's a shallow copy, this `inner-block-from-copy` is the SAME series
;; as the one inside `original-nested-block`.
inner-block-from-copy: pick copied-nested-block 2 ;; This is [1 2 3]
append inner-block-from-copy 4 ;; Modify the shared nested block

print ["Copied nested block after modifying its inner block:" mold copied-nested-block]
print ["Original nested block (INNER block IS affected!):" mold original-nested-block]
;; The original block now shows `["header" [1 2 3 4] "footer"]` because the nested
;; block `[1 2 3]` was shared between the original and the shallow copy.

print ["Are the nested blocks the same series?"]
original-inner: pick original-nested-block 2
copied-inner: pick copied-nested-block 2 ;; This will be the same series as original-inner now
print ["(pick original-nested-block 2) vs (pick copied-nested-block 2):" same? original-inner copied-inner]
;; `true`, confirming they point to the exact same nested block in memory.

;; This demonstrates the core characteristic of a shallow copy:
;; The top-level container is new, but any series elements within it are shared
;; by reference with the original. Modifying such shared series elements (like the
;; inner block [1 2 3]) will be visible through both the original and the copy.
;; To get a completely independent copy, `copy/deep` is needed.

;; --- Example 3: `copy/part` - Copying a Portion of a Block ---
print newline
print "--- Example 3: `copy/part` - Copying a Portion of a Block ---"

source-block: [a b c d e f g]
print ["Source block:" mold source-block]

print ["-- `copy/part` with a length (integer) --"]
;; `copy/part <series> <length>` copies <length> elements from the current position.
;; If series is at its head, it copies the first <length> elements.
partial-copy-length: copy/part source-block 3 ;; Copies "a", "b", "c"
print ["Copied 3 elements from head:" mold partial-copy-length]

print ["-- `copy/part` up to a specific position (series) --"]
;; `copy/part <series> <end-position>` copies from current position up to (but not including) <end-position>.
position-d: find source-block 'd
if not none? position-d [
    partial-copy-to-pos: copy/part source-block position-d ;; Copies "a", "b", "c"
    print ["Copied from head up to position of 'd':" mold partial-copy-to-pos]
]

print ["-- `copy/part` from a mid-point with a length --"]
start-at-c: find source-block 'c
if not none? start-at-c [
    partial-copy-mid-len: copy/part start-at-c 3 ;; Copies "c", "d", "e"
    print ["Copied 3 elements starting from 'c':" mold partial-copy-mid-len]
]

print ["-- `copy/part` from a mid-point to another mid-point --"]
start-at-b: find source-block 'b
end-at-f: find source-block 'f
if all [not none? start-at-b  not none? end-at-f] [
    partial-copy-mid-mid: copy/part start-at-b end-at-f ;; Copies "b", "c", "d", "e"
    print ["Copied from 'b' up to 'f':" mold partial-copy-mid-mid]
]

print ["-- `copy/part` with length exceeding available elements --"]
;; If length exceeds available elements, it copies only what's available.
copy-too-long: copy/part source-block 100
print ["`copy/part source-block 100` (source has 7 elements):" mold copy-too-long]
print ["Length of copy-too-long:" length? copy-too-long] ;; Will be 7

;; The result of `copy/part` is also a shallow copy of the elements it includes.
;; If any of those elements were series themselves, they would be shared by reference.
source-with-nested: [x y [10 20] z]
print ["Source with nested:" mold source-with-nested]
partial-nested-copy: copy/part source-with-nested 3 ;; Copies x, y, [10 20]
print ["Partial copy with nested:" mold partial-nested-copy]

;; Modify nested block in the partial copy
inner-in-partial: pick partial-nested-copy 3
if block? inner-in-partial [
    append inner-in-partial 30
]
print ["Partial copy after modifying its inner block:" mold partial-nested-copy]
print ["Original source-with-nested (INNER block IS affected!):" mold source-with-nested]
;; This confirms `copy/part` also performs shallow copies of contained series.

print newline
print "--- End of `copy` (Shallow) and `copy/part` Examples ---"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This script demonstrates advanced refinements for `append` and `insert` actions
;; when used with `block!` data types in Rebol 3. Specifically, we will explore:
;; 1. The `/part` refinement: For appending or inserting only a portion of another series.
;; 2. The `/dup` refinement: For duplicating the appended or inserted value multiple times.
comment {
Key aspects demonstrated in this script:

append/part:
Using an integer limit to specify the number of elements to append from the source.
Using a series position (from `find` in the source) as the limit.
Behavior when the limit exceeds the source's available length (appends all available).
Appending a part from a specific starting position within the source series.

append/dup:
Duplicating a simple value multiple times.
Duplicating a block with default merge behavior (elements are merged, then the merge is duplicated).
This needs careful observation as the "value" for `/dup` is what `/append` (or `/append/only`) would normally process once.
Correctly using append/only/dup to duplicate a block as a single unit
(Order of refinements can matter: `/only` affects what is considered the "value" that `/dup` then duplicates).
Behavior with a count of 0 (appends nothing).

insert/part:
Similar to `append/part` but inserts at a specified position within the target.
Demonstrates integer and series position limits.

insert/dup:
Similar to `append/dup` but inserts at a specified position.
Shows duplicating simple values and blocks (with default merge and `insert/only/dup`).
Behavior with a count of 0.
Use of `find` for Positions: Continues to use `find` to get dynamic positions for `insert` and for specifying limits or start points in `/part` operations.
}

print "--- Demonstrating `append` & `insert` Refinements: /part and /dup ---"

;; --- Section 1: `append` Refinements ---

;; --- Example 1.1: `append/part` ---
print newline
print "--- Example 1.1: `append/part` ---"
;; `append/part <target-series> <source-value> <limit>`
;; Appends elements from the `<source-value>` (if it's a series) up to a `<limit>`.
;; The `<limit>` can be an integer (number of elements) or a series position.

source-items: ["alpha" "beta" "gamma" "delta" "epsilon"]
print ["Source items for /part:" mold source-items]

print ["-- `append/part` with an integer limit (length) --"]
target1: [1 2]
append/part target1 source-items 3 ;; Append first 3 items from source-items
print ["Target1 after `append/part source-items 3`:" mold target1]
;; Expected: [1 2 "alpha" "beta" "gamma"]

print ["-- `append/part` with a series position limit --"]
target2: ["A" "B"]
limit-pos: find source-items "delta" ;; Position of "delta" in source-items
if not none? limit-pos [
    append/part target2 source-items limit-pos ;; Append from source-items up to (not including) "delta"
    print ["Target2 after `append/part source-items (find source-items {delta})`:" mold target2]
    ;; Expected: ["A" "B" "alpha" "beta" "gamma"]
]

print ["-- `append/part` when limit exceeds source length --"]
target3: [x y]
append/part target3 source-items 10 ;; Limit (10) is > length of source-items (5)
print ["Target3 after `append/part source-items 10`:" mold target3]
;; Expected: [x y "alpha" "beta" "gamma" "delta" "epsilon"] (appends all available)

print ["-- `append/part` from a specific position in source --"]
target4: ["start"]
start-pos-in-source: find source-items "gamma"
if not none? start-pos-in-source [
    append/part target4 start-pos-in-source 2 ;; Append 2 items starting from "gamma"
    print ["Target4 after `append/part (find source-items {gamma}) 2`:" mold target4]
    ;; Expected: ["start" "gamma" "delta"]
]

;; --- Example 1.2: `append/dup` ---
print newline
print "--- Example 1.2: `append/dup` ---"
;; `append/dup <target-series> <value-to-duplicate> <count>`
;; Appends the `<value-to-duplicate>` to `<target-series>` a total of `<count>` times.

target5: ["item"]
print ["Initial Target5:" mold target5]

print ["-- `append/dup` a simple value --"]
append/dup target5 "new" 3 ;; Append "new" 3 times
print ["Target5 after `append/dup {new} 3`:" mold target5]
;; Expected: ["item" "new" "new" "new"]

print ["-- `append/dup` a block (default merge behavior, duplicated) --"]
target6: ["data"]
block-to-dup-merge: [a b]
append/dup target6 block-to-dup-merge 2
print ["Target6 after `append/dup [a b] 2` (default merge):" mold target6]
;; Expected: ["data" a b a b]

print ["-- `append/only/dup` a block (appended as single item, duplicated) --"]
target7: ["info"]
block-to-dup-only: [x y]
append/only/dup target7 block-to-dup-only 2 ;; Note: /only comes before /dup
print ["Target7 after `append/only/dup [x y] 2`:" mold target7]
;; Expected: ["info" [x y] [x y]]

print ["-- `append/dup` with count 0 --"]
target8: ["original"]
append/dup target8 "zero" 0
print ["Target8 after `append/dup {zero} 0`:" mold target8]
;; Expected: ["original"] (appends nothing)


;; --- Section 2: `insert` Refinements ---

;; --- Example 2.1: `insert/part` ---
print newline
print "--- Example 2.1: `insert/part` ---"
;; `insert/part <target-pos> <source-value> <limit>`
;; Inserts elements from `<source-value>` (if series) up to `<limit>` at `<target-pos>`.

print ["-- `insert/part` with an integer limit --"]
target10: [10 50 60]
source-for-insert: [20 30 40 "extra"]
print ["Initial Target10:" mold target10]
insert-pos10: find target10 50
if not none? insert-pos10 [
    insert/part insert-pos10 source-for-insert 3 ;; Insert first 3 items from source
    print ["Target10 after `insert/part ... 3` before 50:" mold target10]
    ;; Expected: [10 20 30 40 50 60]
]

print ["-- `insert/part` with a series position limit --"]
target11: ["A" "D" "E"]
source-for-insert2: ["B" "C" "ignore"]
print ["Initial Target11:" mold target11]
insert-pos11: find target11 "D"
limit-pos-insert: find source-for-insert2 "ignore"
if all [not none? insert-pos11 not none? limit-pos-insert] [
    insert/part insert-pos11 source-for-insert2 limit-pos-insert
    print ["Target11 after `insert/part ... (find ... {ignore})` before 'D':" mold target11]
    ;; Expected: ["A" "B" "C" "D" "E"]
]

;; --- Example 2.2: `insert/dup` ---
print newline
print "--- Example 2.2: `insert/dup` ---"
;; `insert/dup <target-pos> <value-to-duplicate> <count>`
;; Inserts `<value-to-duplicate>` at `<target-pos>` a total of `<count>` times.

target12: [100 400]
print ["Initial Target12:" mold target12]

print ["-- `insert/dup` a simple value --"]
insert-pos12: find target12 400
if not none? insert-pos12 [
    insert/dup insert-pos12 200 2 ;; Insert 200 two times before 400
    print ["Target12 after `insert/dup 200 2` before 400:" mold target12]
    ;; Expected: [100 200 200 400]
]

print ["-- `insert/dup` a block (default merge behavior, duplicated) --"]
target13: ["alpha" "omega"]
block-to-insert-dup: [beta gamma]
print ["Initial Target13:" mold target13]
insert-pos13: find target13 "omega"
if not none? insert-pos13 [
    insert/dup insert-pos13 block-to-insert-dup 2
    print ["Target13 after `insert/dup [beta gamma] 2` before 'omega':" mold target13]
    ;; Expected: ["alpha" beta gamma beta gamma "omega"]
]

print ["-- `insert/only/dup` a block (inserted as single item, duplicated) --"]
target14: ["first" "last"]
block-to-insert-only-dup: [mid1 mid2]
print ["Initial Target14:" mold target14]
insert-pos14: find target14 "last"
if not none? insert-pos14 [
    insert/only/dup insert-pos14 block-to-insert-only-dup 2
    print ["Target14 after `insert/only/dup [mid1 mid2] 2` before 'last':" mold target14]
    ;; Expected: ["first" [mid1 mid2] [mid1 mid2] "last"]
]

print ["-- `insert/dup` with count 0 --"]
target15: ["keep-me"]
print ["Initial Target15:" mold target15]
insert/dup target15 "gone" 0 ;; Inserts at head if target15 is the position
print ["Target15 after `insert/dup {gone} 0` at head:" mold target15]
;; Expected: ["keep-me"] (inserts nothing)

print newline
print "--- End of `append` & `insert` Refinements Examples ---"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This script provides a comprehensive demonstration of the `change` action in Rebol 3,
;; used to replace elements within a `block!`. We will explore:
;; 1. Basic `change` of single elements.
;; 2. Changing with a block (default merge behavior).
;; 3. The `/part` refinement: To control how much of the target or source is affected.
;; 4. The `/only` refinement: To change with a block as a single new element.
;; 5. The `/dup` refinement: To duplicate the replacement value.
;; 6. Combinations of these refinements (e.g., /part/only, /only/dup, /part/dup, /part/only/dup).
;; 7. The return value of `change`.

print "--- Demonstrating `change` and its Refinements with Blocks ---"

;; --- Section 1: Basic `change` (No Refinements or only /only) ---
print newline
print "--- Section 1: Basic `change` (No Refinements or only /only) ---"

print "-- Changing a single element with another single element --"
my-block1: ["apple" "banana" "cherry"]
print ["Initial my-block1:" mold my-block1]
change my-block1 "apricot" ;; Changes "apple" (at head) to "apricot"
print ["After `change my-block1 {apricot}`:" mold my-block1]

position-banana: find my-block1 "banana"
if not none? position-banana [
    change position-banana "boysenberry"
    print ["After changing 'banana' to 'boysenberry':" mold my-block1]
]

print ["-- Changing elements with a block (default behavior) --"]
;; OBSERVED BEHAVIOR for `change <pos> <block-val>`:
;; Replaces elements in the target series starting at <pos> for a length
;; equal to `length? <block-val>`. The elements of <block-val> are inserted.
;; Overall length of target block is unchanged if enough elements were present to replace.
my-block2: [10 20 30 40 50]
print ["Initial my-block2:" mold my-block2]
position-20: find my-block2 20
if not none? position-20 [
    change position-20 [21 22] ;; Replacement [21 22] (len 2). Replaces 20, 30.
    print ["After changing at pos 20 with [21 22]:" mold my-block2] ;; [10 21 22 40 50]
    print ["Length of my-block2:" length? my-block2] ;; 5
]

my-block2b: [10 20 30 40 50]
print ["Initial my-block2b:" mold my-block2b]
position-20b: find my-block2b 20
if not none? position-20b [
    change position-20b ["X"] ;; Replacement ["X"] (len 1). Replaces only 20.
    print ["After changing at pos 20 with [{X}]:" mold my-block2b] ;; [10 "X" 30 40 50]
    print ["Length of my-block2b:" length? my-block2b]
]

print ["-- `change/only <pos> <block-value>` --"]
;; Replaces the single element at <pos> with <block-value> as a single new element.
my-block6: ["one" "two" "three"]
print ["Initial my-block6:" mold my-block6]
position-two6: find my-block6 "two"
if not none? position-two6 [
    change/only position-two6 ["is" "now" "nested"]
    print ["After `change/only (pos {two}) [{is} {now} {nested}]`:" mold my-block6] ;; ["one" ["is" "now" "nested"] "three"]
    print ["Length of my-block6:" length? my-block6] ;; 3
    print ["Type of second element:" type? pick my-block6 2] ;; block!
]

;; --- Section 2: `change` with `/part` Refinement (and `/part/only`) ---
print newline
print "--- Section 2: `change` with `/part` Refinement (and `/part/only`) ---"
;; `/part <limit>` explicitly controls how many elements in the target are removed.
;; The replacement value (or its elements if series and no /only) is then inserted.

print "-- `change/part` replacing multiple target elements with fewer source elements --"
my-block3: [a b c d e f]
print ["Initial my-block3:" mold my-block3]
position-b3: find my-block3 'b
if not none? position-b3 [
    change/part position-b3 ["X" "Y"] 3 ;; Part limit 3: remove 'b, 'c, 'd'. Insert "X", "Y".
    print ["After `change/part (pos 'b') [{X} {Y}] 3`:" mold my-block3] ;; [a "X" "Y" e f]
    print ["Length of my-block3:" length? my-block3] ;; 5
]

print "-- `change/part` replacing fewer target elements with more source elements --"
my-block4: [1 2 3 4 5]
print ["Initial my-block4:" mold my-block4]
position-2_4: find my-block4 2
if not none? position-2_4 [
    change/part position-2_4 [10 20 30] 2 ;; Part limit 2: remove 2, 3. Insert 10, 20, 30.
    print ["After `change/part (pos 2) [10 20 30] 2`:" mold my-block4] ;; [1 10 20 30 4 5]
    print ["Length of my-block4:" length? my-block4] ;; 6
]

print "-- `change/part` replacing with a non-series value and a limit --"
my-block5: [q w e r t y]
print ["Initial my-block5:" mold my-block5]
position-w5: find my-block5 'w
if not none? position-w5 [
    change/part position-w5 "Z" 3 ;; Part limit 3: remove 'w, 'e, 'r'. Insert "Z".
    print ["After `change/part (pos 'w') {Z} 3`:" mold my-block5] ;; [q "Z" t y]
    print ["Length of my-block5:" length? my-block5] ;; 4
]

print ["-- `change/part/only` --"]
my-block7: [alpha beta gamma delta]
print ["Initial my-block7:" mold my-block7]
pos-beta7: find my-block7 'beta
if not none? pos-beta7 [
    change/part/only pos-beta7 ["X" "Y" "Z"] 2 ;; Part limit 2: remove 'beta', 'gamma'. Insert block ["X" "Y" "Z"].
    print ["After `change/part/only (pos 'beta') [{X Y Z}] 2`:" mold my-block7] ;; [alpha ["X" "Y" "Z"] delta]
    print ["Length of my-block7:" length? my-block7] ;; 3
]

;; --- Section 3: `change` with `/dup` Refinement (and combinations) ---
print newline
print "--- Section 3: `change` with `/dup` Refinement (and combinations) ---"

print ["-- `change/dup` (No /part) with a scalar value --"]
;; BEHAVIOR: `change/dup <pos> <scalar-val> <count>`
;; Removes <count> elements from target (or until tail), inserts <count> copies of <scalar-val>.
dup-block1: [a b c d e]
print ["Initial dup-block1:" mold dup-block1]
pos-b_dup1: find dup-block1 'b
if not none? pos-b_dup1 [
    change/dup pos-b_dup1 'X 3 ;; Affects 3 target items (b,c,d), replaces with X,X,X. 'e' remains.
    print ["After `change/dup (pos 'b') 'X 3`:" mold dup-block1] ;; [a X X X e]
    print ["Length:" length? dup-block1] ;; 5
]

print ["-- `change/dup` (No /part) where replacement value is a block (default merge) --"]
;; BEHAVIOR: `change/dup <pos> <block-val> <count>`
;; N_insert = <count> * length? <block-val>. Removes N_insert elements from target (or until tail).
;; Inserts <count> duplicated merged block contents (total N_insert items).
dup-block2: [10 20 30 40 50]
print ["Initial dup-block2:" mold dup-block2]
pos-20_dup2: find dup-block2 20
if not none? pos-20_dup2 [
    change/dup pos-20_dup2 [Y Z] 2 ;; Value [Y Z] (len 2). Dup count 2. N_insert=4. Removes (20,30,40,50). Inserts Y,Z,Y,Z.
    print ["After `change/dup (pos 20) [Y Z] 2`:" mold dup-block2] ;; [10 Y Z Y Z]
    print ["Length:" length? dup-block2] ;; 5
]

print ["-- `change/only/dup` (No /part) --"]
;; BEHAVIOR: `change/only/dup <pos> <block-val> <count>`
;; N_insert = <count> (due to /only). Removes <count> elements from target (or until tail).
;; Inserts <count> copies of <block-val> (as single blocks).
dup-block3: [one two three four five]
print ["Initial dup-block3:" mold dup-block3]
pos-two_dup3: find dup-block3 'two
if not none? pos-two_dup3 [
    change/only/dup pos-two_dup3 [AA BB] 2 ;; Value [AA BB] (block). Dup count 2. N_insert=2. Removes (two,three). Inserts [[AA BB]], [[AA BB]].
    print ["After `change/only/dup (pos 'two') [[AA BB]] 2`:" mold dup-block3] ;; [one [AA BB] [AA BB] four five]
    print ["Length:" length? dup-block3] ;; 5
]

print ["-- `change/part/dup` with scalar value --"]
;; BEHAVIOR: `change/part/dup <pos> <val> <part-arg> <dup-arg>` (part-arg is limit, dup-arg is count)
;; Removes <part-arg> elements from target. Inserts <dup-arg> copies of <val>.
dup-block4: [1 2 3 4 5 6 7]
print ["Initial dup-block4:" mold dup-block4]
pos-2_dup4: find dup-block4 2
if not none? pos-2_dup4 [
    change/part/dup pos-2_dup4 "R" 3 2 ;; part-limit=3 (removes 2,3,4). dup-count=2. value "R". Inserts "R","R".
    print ["After `change/part/dup (pos 2) {R} 3 2`:" mold dup-block4] ;; [1 "R" "R" 5 6 7]
    print ["Length:" length? dup-block4] ;; 6
]

print ["-- `change/part/dup` where value is a block (default merge) --"]
dup-block5: [a b c d e f g]
print ["Initial dup-block5:" mold dup-block5]
pos-b_dup5: find dup-block5 'b
if not none? pos-b_dup5 [
    change/part/dup pos-b_dup5 [X Y] 3 2 ;; part-limit=3 (removes b,c,d). dup-count=2. value [X Y]. Inserts X,Y,X,Y.
    print ["After `change/part/dup (pos 'b') [X Y] 3 2`:" mold dup-block5] ;; [a X Y X Y e f g]
    print ["Length:" length? dup-block5] ;; 8
]

print ["-- `change/part/only/dup` (all refinements) --"]
dup-block6: [m n o p q r s]
print ["Initial dup-block6:" mold dup-block6]
pos-n_dup6: find dup-block6 'n
if not none? pos-n_dup6 [
    change/part/only/dup pos-n_dup6 [S T] 3 2 ;; part-limit=3 (removes n,o,p). dup-count=2. value [S T] (block). Inserts [[S T]],[[S T]].
    print ["After `change/part/only/dup (pos 'n') [[S T]] 3 2`:" mold dup-block6] ;; [m [S T] [S T] q r s]
    print ["Length:" length? dup-block6] ;; 6
]


;; --- Section 4: Return Value of `change` ---
print newline
print "--- Section 4: Return Value of `change` ---"
;; `change` (and its refinements) modifies the series in place and returns
;; the position in the series *just past* the changed section.

my-block-ret: [aa bb cc dd ee]
print ["Initial my-block-ret:" mold my-block-ret]
pos-bb-ret: find my-block-ret 'bb
if not none? pos-bb-ret [
    return-val: change pos-bb-ret "XX" ;; `change` one item with one item
    print ["my-block-ret after `change (pos 'bb') {XX}`:" mold my-block-ret] ;; [aa "XX" cc dd ee]
    print ["Return value (molded):" mold return-val] ;; Should be series at 'cc'
    if all [series? return-val not empty? return-val] [print ["Value at returned position:" pick return-val 1]]
]

my-block-ret2: [one two three four five]
print ["Initial my-block-ret2:" mold my-block-ret2]
pos-two-ret2: find my-block-ret2 'two
if not none? pos-two-ret2 [
    ;; Change at 'two' with ["2A" "2B"] (length 2). Implicitly targets 'two', 'three'.
    return-val2: change pos-two-ret2 ["2A" "2B"]
    print ["my-block-ret2 after `change ...`:" mold my-block-ret2] ;; [one "2A" "2B" four five]
    print ["Return value2 (molded):" mold return-val2] ;; Should be series at 'four'
    if all [series? return-val2 not empty? return-val2] [print ["Value at returned position2:" pick return-val2 1]]
]

print newline
print "--- End of `change` and its Refinements Examples ---"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This example demonstrates the `remove` and `clear` actions in Rebol 3,
;; used for deleting elements from a `block!`. We will explore:
;; 1. `remove`: Default behavior (removes one element).
;; 2. `remove/part`: Removing multiple elements using a count or an end position.
;; 3. Return value of `remove`.
;; 4. `clear`: Removing all elements from a block.
;; 5. Behavior with empty blocks and edge cases.
comment {
Key aspects demonstrated:
remove (default):
Removes a single element from the head or a specified position.
Its return value (the position of the element that followed the removed one).
Behavior on an empty block (no error, no change).
remove/part:
Using an integer <limit> to remove a specific number of elements.
Using a series position <limit> to remove elements up to that position.
Behavior when the count/limit exceeds available elements (removes what it can).
Its return value.
clear:
Clearing an entire block (by providing the head).
Clearing a block from a specific position to the end.
Behavior on an empty block.
Its return value (the position provided, which becomes the new tail).
Positional Logic: Use of find, at, and tail? where appropriate for defining positions or checking states.
Conditional Guarding: Using if not none? ... and if all [...] to ensure operations are safe.

`remove` (default), removes one element and returns the position of the next.
`remove/part` correctly removes elements based on a count or up to an end position.
`remove` and `remove/part` handle empty blocks or overreaching limits gracefully (by doing nothing or removing what's available).
`clear` empties a block from the head or a specified position to the end.
`clear` on an empty block does nothing.
}

print "--- Demonstrating `remove` and `clear` with Blocks ---"

;; --- Section 1: `remove` Action ---
print newline
print "--- Section 1: `remove` Action ---"

print "-- `remove` default behavior (removes one element) --"
my-block1: ["apple" "banana" "cherry" "date"]
print ["Initial my-block1:" mold my-block1]

remove my-block1
print ["After `remove my-block1` (removes 'apple'):" mold my-block1]
print ["Length:" length? my-block1]

position-cherry: find my-block1 "cherry"
if not none? position-cherry [
    remove position-cherry
    print ["After removing 'cherry':" mold my-block1]
    print ["Length:" length? my-block1]
]

print "-- Return value of `remove` --"
my-block2: [10 20 30 40]
print ["Initial my-block2:" mold my-block2]
position-20: find my-block2 20
if not none? position-20 [
    return-val: remove position-20
    print ["my-block2 after removing 20:" mold my-block2]
    print ["Return value (molded):" mold return-val]
    if all [series? return-val not empty? return-val] [
        print ["Value at returned position:" pick return-val 1]
    ]
]

print "-- `remove` from an empty block --"
empty-block1: []
print ["Initial empty-block1:" mold empty-block1]
remove empty-block1
print ["empty-block1 after `remove`:" mold empty-block1]
print ["Length:" length? empty-block1]

;; --- Section 2: `remove/part` Refinement ---
print newline
print "--- Section 2: `remove/part` Refinement ---"

print "-- `remove/part` with an integer limit (count) --"
my-block3: [a b c d e f g]
print ["Initial my-block3:" mold my-block3]
remove/part my-block3 3
print ["After `remove/part my-block3 3`:" mold my-block3]
print ["Length:" length? my-block3]

my-block4: [1 2 3 4 5 6]
print ["Initial my-block4:" mold my-block4]
position-3: find my-block4 3
if not none? position-3 [
    remove/part position-3 2
    print ["After `remove/part (pos 3) 2`:" mold my-block4]
    print ["Length:" length? my-block4]
]

print "-- `remove/part` with a series position as limit --"
my-block5: [q w e r t y u]
print ["Initial my-block5:" mold my-block5]
position-w: find my-block5 'w
limit-position-t: find my-block5 't
if all [not none? position-w not none? limit-position-t] [
    remove/part position-w limit-position-t
    print ["After `remove/part (pos 'w') (pos 't')`:" mold my-block5]
    print ["Length:" length? my-block5]
]

print "-- `remove/part` when count/limit exceeds available elements --"
my-block6: [x y z]
print ["Initial my-block6:" mold my-block6]
remove/part my-block6 5 ;; Tries to remove 5, only 3 available. Removes all.
print ["After `remove/part my-block6 5`:" mold my-block6] ;; []
print ["Length:" length? my-block6]

;; At this point, my-block6 is empty.
if empty? my-block6 [
    print "my-block6 is now empty, as expected after over-reaching remove/part."
]

my-block6b: [1 2]
print ["Initial my-block6b:" mold my-block6b]
pos1_6b: find my-block6b 1
limit_beyond_6b: at my-block6b 10 ;; Position beyond the end (valid way to get effective tail for range)
if not none? pos1_6b [ ;; Ensure pos1_6b is valid before using it
    remove/part pos1_6b limit_beyond_6b ;; Should remove all from pos1_6b to end
    print ["After `remove/part (pos 1) (at block 10)`:" mold my-block6b] ;; []
    print ["Length:" length? my-block6b]
]


print "-- Return value of `remove/part` --"
my-block7: [aa bb cc dd ee ff]
print ["Initial my-block7:" mold my-block7]
position-bb: find my-block7 'bb
if not none? position-bb [
    return-val-part: remove/part position-bb 2
    print ["my-block7 after `remove/part (pos 'bb') 2`:" mold my-block7]
    print ["Return value of `remove/part` (molded):" mold return-val-part]
    if all [series? return-val-part not empty? return-val-part] [
        print ["Value at returned position:" pick return-val-part 1]
    ]
]

;; --- Section 3: `clear` Action ---
print newline
print "--- Section 3: `clear` Action ---"

my-block8: [one two three four five]
print ["Initial my-block8:" mold my-block8]
clear my-block8
print ["After `clear my-block8`:" mold my-block8]
print ["Length:" length? my-block8]

my-block9: [a b c d e]
print ["Initial my-block9:" mold my-block9]
position-c: find my-block9 'c
if not none? position-c [
    clear position-c
    print ["After `clear (pos 'c')`:" mold my-block9]
    print ["Length:" length? my-block9]
]

print "-- `clear` an empty block --"
empty-block2: []
print ["Initial empty-block2:" mold empty-block2]
clear empty-block2
print ["empty-block2 after `clear`:" mold empty-block2]
print ["Length:" length? empty-block2]

print "-- Return value of `clear` --"
my-block10: [x y z]
print ["Initial my-block10:" mold my-block10]
return-val-clear: clear my-block10
print ["my-block10 after `clear`:" mold my-block10]
print ["Return value of `clear` (molded):" mold return-val-clear]
print ["Is the returned position the tail?" tail? return-val-clear]

print newline
print "--- End of `remove` and `clear` Examples ---"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; This script demonstrates advanced `copy` refinements in Rebol 3 and a workaround.
;; 1. `copy/deep`: For creating completely independent copies of blocks. (Works as expected)
;; 2. `copy/types`: Intended for copying only elements of specified datatypes.
;;    NOTE: Based on testing with REBOL/Bulk 3.19.0 (Oldes branch, 11-Apr-2025),
;;    the /types refinement for `copy` does NOT filter the results as documented.
;;    It behaves like a plain `copy` or `copy/part` if /part is also used.
;;    Status in other Rebol 3 builds/versions may vary.
;; 3. A helper function `filter-by-types` is provided as a workaround for `/types` behavior.

print "--- Demonstrating `copy/deep`, `copy/types` (and workaround) with Blocks ---"

;; --- Helper Function: Workaround for `copy/types` ---
filter-by-types: function [
    {Filters a series, returning a new block with only elements of specified datatypes.
    This is a workaround for the observed behavior of `copy/types`.}
    series-to-filter [series!] "Source series to filter."
    allowed-types    [typeset!] "Typeset of datatypes to keep."
] [
    result-block: copy []

    foreach item series-to-filter [
        if find allowed-types type? :item [
            either series? :item [
                append result-block copy :item ;; Shallow copy for series elements
            ][
                append result-block :item ;; Append the value itself
            ]
        ]
    ]

    result-block
]

;; --- Section 1: Revisiting Shallow `copy` (for context) ---
print newline
print "--- Section 1: Revisiting Shallow `copy` (for context) ---"

original-shallow: ["header" [10 20] "footer"]
copied-shallow: copy original-shallow

print ["Original for shallow test:" mold original-shallow]
print ["Shallow copy:" mold copied-shallow]

inner-block-shallow: pick copied-shallow 2
append inner-block-shallow 30

print ["Shallow copy after modifying its inner block:" mold copied-shallow]
print ["Original (IS AFFECTED by shallow copy's inner mod):" mold original-shallow]
print ["Are the inner blocks the same series?" same? (pick original-shallow 2) (pick copied-shallow 2)]
print "(This confirms shallow copy shares nested series.)"

;; --- Section 2: `copy/deep` ---
print newline
print "--- Section 2: `copy/deep` ---"

original-deep: ["config" ["setting-A" "value1"] ["setting-B" "value2"] "checksum"]
print ["Original for deep test:" mold original-deep]

copied-deep: copy/deep original-deep
print ["Deep copy (initially same content):" mold copied-deep]
print ["Are original and deep copy the same top-level series?" same? original-deep copied-deep]

print ["-- Modifying a top-level simple element in the deep copy --"]
change copied-deep "new-config"
print ["Deep copy after top-level change:" mold copied-deep]
print ["Original (top-level should be unchanged):" mold original-deep]

print ["-- Modifying a NESTED block VIA the deep copy --"]
inner-block1-deep: pick copied-deep 2
append inner-block1-deep "modified"
print ["Deep copy after modifying its 1st inner block:" mold copied-deep]
print ["Original (INNER block IS NOT AFFECTED!):" mold original-deep]

print ["-- Modifying another NESTED string element within a nested block VIA the deep copy --"]
inner-block2-deep: pick copied-deep 3
inner-string-deep: pick inner-block2-deep 2
append inner-string-deep "-changed"
print ["Deep copy after modifying string in 2nd inner block:" mold copied-deep]
print ["Original (string in 2nd inner block IS NOT AFFECTED!):" mold original-deep]

print ["Are the first nested blocks the same series?"]
original-inner1: pick original-deep 2
copied-inner1: pick copied-deep 2
print ["(pick original-deep 2) vs (pick copied-deep 2):" same? original-inner1 copied-inner1]

print ["Are the second nested blocks the same series?"]
original-inner2: pick original-deep 3
copied-inner2: pick copied-deep 3
print ["(pick original-deep 3) vs (pick copied-deep 3):" same? original-inner2 copied-inner2]

print ["-- `copy/deep` with an empty source block --"]
empty-source: []
copied-empty-deep: copy/deep empty-source
print ["Original empty source:" mold empty-source]
print ["`copy/deep` of empty source:" mold copied-empty-deep]
print ["Length of copied empty (deep):" length? copied-empty-deep]
append copied-empty-deep "new item"
print ["Modified deep copy of empty:" mold copied-empty-deep]
print ["Original empty source (should remain unchanged):" mold empty-source]

;; --- Section 3: `copy/types` (Observing Behavior and Using Workaround) ---
print newline
print "--- Section 3: `copy/types` (Observing Behavior and Using Workaround) ---"

;; NOTE: `copy/types` observations below are for REBOL/Bulk 3.19.0 (Oldes branch).
source-mixed-types: ["text1" 100 #"A" [a b] "text2" 200 'wordval]
source-mixed-types-original-copy: copy/deep source-mixed-types ;; For reset

print ["Source for /types test:" mold source-mixed-types]

print ["-- Verifying typeset creation --"]
string-only-typeset: make typeset! [string!]
print reform ["string-only-typeset is a typeset?:" typeset? string-only-typeset ", contains string!?" not none? find string-only-typeset string!]

string-int-typeset: make typeset! [string! integer!]
print reform ["string-int-typeset is a typeset?:" typeset? string-int-typeset ", contains integer!?" not none? find string-int-typeset integer!]

print ["-- Attempting `copy/types` (Observed: No filtering) --"]
strings-only-attempt: copy/types source-mixed-types string-only-typeset
print reform ["`copy/types ... string!` result:" mold strings-only-attempt]
print reform ["Expected (if filtering worked):" mold ["text1" "text2"]]

print ["-- Using `filter-by-types` (Workaround) --"]
filtered-strings: filter-by-types source-mixed-types string-only-typeset
print reform ["`filter-by-types ... string!` result:" mold filtered-strings]

filtered-strings-ints: filter-by-types source-mixed-types string-int-typeset
print reform ["`filter-by-types ... string! integer!` result:" mold filtered-strings-ints]

block-only-typeset: make typeset! [block!]
filtered-blocks: filter-by-types source-mixed-types block-only-typeset
print reform ["`filter-by-types ... block!` result:" mold filtered-blocks]

source-mixed-types: copy/deep source-mixed-types-original-copy ;; Reset source.
print ["Source before inner block modification test:" mold source-mixed-types]

filtered-blocks-for-mod-test: filter-by-types source-mixed-types block-only-typeset
if all [not empty? filtered-blocks-for-mod-test block? first filtered-blocks-for-mod-test] [
    inner-filtered-block: first filtered-blocks-for-mod-test
    append inner-filtered-block 'c
    print reform ["Modified inner block from filter-by-types result:" mold inner-filtered-block]
    print reform ["Original source `source-mixed-types` (inner block [a b] IS affected):" mold source-mixed-types]
]

print ["-- Attempting `copy/part/types` (Observed: /types ignored) --"]
source-mixed-types: copy/deep source-mixed-types-original-copy ;; Reset source.
int-char-typeset: make typeset! [integer! char!]
partial-range: 3
print ["Source for /part/types:" mold source-mixed-types]
print reform ["Part range:" partial-range ", Typeset for filtering:" mold int-char-typeset]

partial-typed-copy-attempt: copy/part/types source-mixed-types partial-range int-char-typeset
print reform ["`copy/part/types ...` result:" mold partial-typed-copy-attempt]
print reform ["Expected (if /part worked, /types ignored): [" {text1} " 100 " {#"A"} "]"]
print reform ["Expected (if /part and /types worked): [100 " {#"A"} "]"]

print ["-- Using `filter-by-types` on a `copy/part` result (Workaround for /part/types) --"]
temp-partial-copy: copy/part source-mixed-types partial-range
filtered-partial: filter-by-types temp-partial-copy int-char-typeset
print reform ["Workaround for `/part/types` result:" mold filtered-partial]

print newline
print "--- End of `copy/deep` and `copy/types` Examples ---"

;; Conclusion for /types: The `copy/types` refinement does not appear to function
;; as a type filter in REBOL/Bulk 3.19.0 (Oldes branch), based on these tests.
;; The `filter-by-types` helper function provides a working alternative.
;; `copy/deep` works correctly and is vital for independent copies of nested structures.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
