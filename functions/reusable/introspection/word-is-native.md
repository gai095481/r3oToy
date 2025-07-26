# Reusable Function `word-is-native?` User's Guide

## Purpose

The `word-is-native?` function determines whether a given **word** is currently **bound to** a value of the `native!` datatype. It provides a safe and straightforward way to check this specific condition.

## Usage

> result: word-is-native? 'a_word ;; <- Use the quote ' syntax

* **`'a_word`**: The **literal word** you want to check.
* **`result`**: Returns `true` if the word is a `word!` datatype and is bound to a `native!` function. Returns `false` otherwise.

## Why Use `word-is-native?` Over `native?` or `type?`?

While you can use the built-in functions `native?` and `type?` to achieve similar results, doing so **correctly and safely** requires a more verbose and error-prone approach. `word-is-native?` simplifies this.

**Manual Approach using `native?` and `get/any`:**

To safely check if `'my-word` refers to a native function, you must handle several cases:

```rebol
;; --- Potentially unsafe direct use ---
native? :my-word ;; Error if `my-word` is unset or `:my-word` isn't a function.

;; --- Safer, but verbose and complex ---
result: try/with [
    word-value: get/any 'my-word
    either any [unset? :word-value none? :word-value] [
        false
    ] [
        native? :word-value ;; Assumes `:word-value` is a function type.
    ]
] function [err] [
    ;; Handle unexpected errors:
    return false
]
print result
```

This manual code block must:

1. Use `get/any` to fetch the value.
2. Check if the fetched value is `#[unset!]` or `none`.
3. Use `try/with` (or `attempt`) to catch potential errors from `native?`.
4. Finally, apply `native?`.

**Using `word-is-native?`:**

```rebol
result: word-is-native? 'my-word
print result
```

`word-is-native?` **encapsulates all the safety checks and logic** (`get/any`, `unset?`, `none?`, `try/with`, `native?`) into a single, guaranteed-safe function call.

**Benefits:**

* **Simplicity:** One clear function call versus a multi-line block of code.
* **Built-in Safety:** It inherently handles unset words, `none` values, non-word inputs and internal errors gracefully, returning `false` for any non-`native!` binding.
* **Readability:** The intent is immediately clear.
* **Reduced Error Risk:** Eliminates the chance of forgetting a safety check in the manual approach.

## Examples

```rebol
;; --- Validate known native words ---
print word-is-native? 'print  ;; == true
print word-is-native? 'if     ;; == true
print word-is-native? 'get    ;; == true

;; --- Validate non-native built-ins ---
print word-is-native? 'add    ;; == false (action!)
print word-is-native? 'make   ;; == false (action!)

;; --- Validate user-defined functions ---
my-func: does [print "Hello"]
print word-is-native? 'my-func ;; == false

;; --- Validate unset words ---
print word-is-native? 'else   ;; == false (handled safely)

;; --- Validate words bound to other values ---
my-var: "a string"
print word-is-native? 'my-var ;; == false
my-none: none
print word-is-native? 'my-none ;; == false

;; --- Validate non-word inputs ---
print word-is-native? "print" ;; == false (string input)
print word-is-native? 123     ;; == false (integer input)

;; --- Validate the function itself ---
print word-is-native? 'word-is-native? ;; == false (user function)
```

## Key Reminder

Use the single quote `'` to pass the word itself: `word-is-native? 'word`.

## Summary

The `word-is-native?` helper function is a convenience function that wraps the correct, safe, but verbose idiom for checking a word's binding into a simple, reliable tool.  It's the "pit of success" approach: making the easy way also the correct and safe way.

