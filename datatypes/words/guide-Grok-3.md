# Updated Document for Rebol 3 Oldes: Expressions and Words

This document provides an updated guide for Rebol 3 Oldes, focusing on expressions and words. It corrects inaccuracies from the original Rebol 2 help document and incorporates Rebol 3-specific features while maintaining consistency with the Oldes branch's goals of usability and minimal changes.

---

## Table of Contents
1. [Introduction](#introduction)
2. [Word Naming Rules](#word-naming-rules)
3. [Setting Words](#setting-words)
4. [Getting Word Values](#getting-word-values)
5. [Literal Words](#literal-words)
6. [Unset Words](#unset-words)
7. [Protecting Words](#protecting-words)
8. [Additional Rebol 3 Features](#additional-rebol-3-features)
9. [Using the Help System](#using-the-help-system)

---

## Introduction
In Rebol 3 Oldes, expressions are built from values and words. Words serve as symbols or variables and are evaluated differently from direct values. This document clarifies word usage, including setting, getting, and protection mechanisms, while highlighting Rebol 3-specific enhancements tailored for the Oldes branch. For more details, visit the [Oldes/Rebol3 GitHub repository](https://github.com/Oldes/Rebol3).

---

## Word Naming Rules
Word naming in Rebol 3 Oldes follows these rules, consistent with Rebol 2:
- Composed of alphabetic characters, digits, and special characters: `? ! . ' + - * & | = _ ~`.
- Cannot start with a number (e.g., `1st` is invalid).
- Terminated by space, newline, or delimiters: `[ ] ( ) { } " : ; /`.
- Illegal characters include: `@ # $ % ^ ,`.
- Case-insensitive (e.g., `blue`, `Blue`, `BLUE` are identical), though case is preserved in output.
- No reserved keywords; words can be reused across contexts.

**Example:**
```rebol
copy print test
number?  time?  date!
image-files  l'image
++ -- == +-
```

---

## Setting Words
Words are assigned values using a colon (`:`) or the `SET` function. Rebol 3 Oldes enhances `SET` with refinements for flexibility:

- **Basic Setting:**
  ```rebol
  age: 42
  set 'time 10:30
  set [number num ten] 10
  ```
- **Refinements:**
  - `/any`: Allows any value, including `unset!`.
    ```rebol
    set/any 'var none  ; Sets var to none
    ```
  - `/only`: Treats a block or object as a single value.
    ```rebol
    set/only 'var [1 2 3]  ; Sets var to [1 2 3]
    ```
  - `/some`: Skips `none!` values in blocks.
    ```rebol
    set/some [a b c] [1 none 3]  ; Sets a: 1, c: 3, b unchanged
    ```

**Why Use Colon?**  
The colon ensures atomic setting, useful in reflective programming:
```rebol
print length? [age: 42]  ; Returns 2
print length? [age = 42]  ; Returns 3
```

---

## Getting Word Values
Use `:` or `GET` to retrieve word values without evaluating them if they are functions:

- **Basic Getting:**
  ```rebol
  drucken: :print  ; Aliases the print function
  get 'print       ; Retrieves the print function
  ```
- **Refinement:**
  - `/any`: Safely retrieves unset words without errors.
    ```rebol
    get/any 'outlook  ; Returns unset! if outlook is unset
    ```

**Note:** The `/any` refinement in Rebol 3 Oldes prevents errors with unset words, an improvement over Rebol 2.

---

## Literal Words
Literal words are symbolic and unevaluated, marked with a tick (`'`) or extracted from blocks:

- **Using Tick:**
  ```rebol
  test-word: 'this  ; Sets test-word to the word 'this'
  ```
- **Using Blocks:**
  ```rebol
  test-word: first [this and that]  ; Sets test-word to 'this'
  ```

Literal words are critical for functions like `set`, `get`, and `value?`.

---

## Unset Words
Unset words have no value and are of type `unset!`. Evaluating them triggers an error:
```rebol
outlook  ; ** Script Error: outlook has no value.
```
- **Checking if Set:**
  ```rebol
  if not value? 'word [print "word is not set"]
  ```
- **Unsetting:**
  ```rebol
  unset 'word
  ```

**Tip:** Use `GET /any` to safely handle unset words.

---

## Protecting Words
Use `protect` to prevent modification and `unprotect` to reverse it:

- **Basic Protection:**
  ```rebol
  protect 'word
  word: "here"  ; ** Script Error: Word word is protected.
  unprotect 'word
  ```
- **Protecting Blocks:**
  ```rebol
  protect [this that other]
  ```
- **System Protection:**
  ```rebol
  protect-system-object  ; Protects the system object and sub-objects
  ```

**Refinements for `protect`:**
- `/deep`: Protects sub-series or objects.
- `/words`: Treats a block as a list of words.
- `/values`: Processes a list of values (implied `GET`).
- `/hide`: Hides variables from binding and lookup.
- `/lock`: Permanently protects (cannot be unprotected).

**Refinements for `unprotect`:**
- `/deep`: Unprotects sub-series.
- `/words`: Treats a block as words.
- `/values`: Processes a list of values.

---

## Additional Rebol 3 Features
Rebol 3 Oldes introduces new datatypes and improved context handling:

- **New Datatypes:**
  - `refinement!`: Represents variations in meaning or location (e.g., `/local`).
    ```
    REFINEMENT! is a datatype.
    It is defined as a variation of meaning or location.
    It is of the general type word.
    ```
  - `issue!`: Identifying marker word (e.g., `#123`).
    ```
    ISSUE! is a datatype.
    It is defined as an identifying marker word.
    It is of the general type word.
    ```
  - `lit-word!`: Literal word value.
    ```
    LIT-WORD! is a datatype.
    It is defined as a literal word value.
    It is of the general type word.
    ```
- **Context Handling:** Enhanced in functions and objects for better scoping.

These features support advanced scripting while preserving simplicity.

---

## Using the Help System
The Rebol 3 Oldes help system provides detailed insights into datatypes and functions:

- **Examples:**
  ```rebol
  >> help refinement!
  REFINEMENT! is a datatype.
  It is defined as a variation of meaning or location.
  It is of the general type word.

  >> help protect
  USAGE:
      PROTECT value
  DESCRIPTION:
      Protect a series or a variable from being modified.
      PROTECT is a native! value.
  ARGUMENTS:
      value         [word! series! bitset! map! object! module!]
  REFINEMENTS:
      /deep         Protect all sub-series/objects as well
      /words        Process list as words (and path words)
      /values       Process list of values (implied GET)
      /hide         Hide variables (avoid binding and lookup)
      /lock         Protect permanently (unprotect will fail)

  >> help protect-system-object
  USAGE:
      PROTECT-SYSTEM-OBJECT
  DESCRIPTION:
      Protect the system object and selected sub-objects.
      PROTECT-SYSTEM-OBJECT is a function! value.
  ```

Use the help system to explore features and ensure accurate usage.

---

This document offers a comprehensive guide to expressions and words in Rebol 3 Oldes, integrating REPL help data and aligning with the Oldes branch's enhancements. For further details, consult the [Rebol 3 documentation](http://www.rebol.com/r3/docs/) and the [Oldes/Rebol3 GitHub repository](https://github.com/Oldes/Rebol3).
