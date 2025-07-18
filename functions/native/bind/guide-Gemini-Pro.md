# Unofficial `bind` User's Guide

## 1. Overview: The Purpose of Binding

In Rebol, a word is more than just a name; it's a reference to a value within a specific **context** (an object). When you write `x: 10`, you create a word `'x` that is "bound" to the global user context.

However, when you create a word dynamically, for example from a string, it starts its life **unbound**. It's just a symbol with no connection to any context.

```rebol
unbound-word: to-word "print"
; ==> 'print

; This will FAIL, because `unbound-word` is just a symbol.
; It doesn't know about the `print` function in the system context.
>> get unbound-word
** Script error: print has no value
```

The `bind` function is the tool that solves this problem. Its core purpose is to take one or more unbound words and give them a home, linking them to a specific context so they can be evaluated.

## 2. Syntax

```rebol
bind word-or-block context
```

- **`word-or-block`**: The `any-word!` or `block!` containing words to be bound. **Crucially, this argument is modified in-place.**
- **`context`**: The `object!`, `module!`, or `port!` to bind the words to. A common choice is `system/contexts/user` for the global context.

---

## 3. Core Use Cases

### A. Binding a Single, Dynamic Word

This is the solution to the problem in the diagnostic script. We have a word's name as a string, and we want to get the value of the variable it names.

```rebol
; The name of the variable we want to access
word-name: "system"
unbound-word: to-word word-name

; Bind the unbound word to the global context where 'system' lives
bound-word: bind unbound-word system/contexts/user

; Now that it's bound, we can get its value
system-object: get bound-word

print type? system-object
; ==> object!
```

**Key Insight:** `bind` returns the word it was given, but now that word is modified to be linked to the context.

### B. Binding a Block of Code (The Most Powerful Use Case)

This is where `bind` truly shines. You can take an entire block of code, perhaps loaded from a file or a string, and make it executable within a specific context.

```rebol
; 1. A context with our functions and data
math-lib: context [
    pi: 3.14
    double: func [x] [x * 2]
]

; 2. A block of code with unbound words
code-to-run: [
    print ["Pi doubled is:" double pi]
]

; 3. This will FAIL because 'double' and 'pi' are unbound in this block
; >> do code-to-run

; 4. Bind the entire block to our library's context
bind code-to-run math-lib

; 5. Now it works! The words are linked.
do code-to-run
; ==> Pi doubled is: 6.28
```

---

## 4. The Refinements: Fine-Tuning the Behavior

### `/copy` - The "Safe" Mode

By default, `bind` modifies your original block. If you want to keep the original block unbound, use `/copy` to bind the words in a new copy of the block.

```rebol
unbound-code: [print "hello"]
bound-copy: bind/copy unbound-code system/contexts/user

; `unbound-code` is unchanged, `bound-copy` is ready to run
```

### `/new` and `/set` - Extending Contexts

These are advanced but powerful. They are used when your code contains words that **do not yet exist** in the target context.

- **/new**: If `bind` finds a word in your block that isn't in the context, it **adds** that word to the context (with a value of `none`).
- **/set**: Does the same as `/new`, but only for `set-word!` types (e.g., `word:`).

This is extremely useful for creating objects from templates.

```rebol
template-block: [
    name: "Default"
    value: none
]

my-object: make object! []

; Bind the block, adding the new words 'name' and 'value' to the object
bind/set template-block my-object

print my-object/name
; ==> "Default"
```

### `/only` - The "Shallow" Bind

By default, `bind` will recursively go into nested blocks to bind all words. `/only` tells it to only bind the words in the top-level block.

---

## 5. `bind` vs. `in`: A Critical Distinction

The diagnostic script correctly explores `in` as an alternative. They solve similar problems but are fundamentally different:

- **`bind word context`**: **Modifies `word`** to be bound to `context`. It changes its argument.
- **`in context 'word`**: **Looks up `'word`** inside `context` and returns a **new, already-bound word**. It does not change the original word.

**When to Use Which?**

- Use **`in`** for a simple, one-off dynamic lookup. It is often cleaner and safer as it has no side effects.
  
  ```rebol
  word-name: "system"
  system-object: get in system/contexts/user to-word word-name
  ```
- Use **`bind`** when you need to prepare an entire block of code for later execution, or when you need to modify a word or block in-place.

## 6. Practical Patterns

### Dynamic Function Calls

```rebol
func-name: "random"
number-to-pick: 10

; Create the word, bind it, then call it
bound-func: bind (to-word func-name) system/contexts/user
result: do reduce [bound-func number-to-pick]

print result ; ==> (a random integer)
```

### Building a Simple Plugin System

```rebol
plugin-host: context [
    data: "some data"
    register: func [name code] [bind code self]
]

plugin-code: [
    print ["Plugin sees data:" data]
]

plugin-host/register "my-plugin" plugin-code
do plugin-code
; ==> Plugin sees data: some data
```
