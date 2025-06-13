# User Manual: Rebol 3 Oldes Block Manipulation Guide

This document is the user manual for the `untitled-script.r3` demonstration script. The script is an educational resource showcasing a wide array of functions and techniques for creating manipulating and copying `block!` data types in the Rebol 3 Oldes branch. It is designed to be run directly with all output printed to the console for learning purposes.

## 1. Introduction to Rebol Blocks

In Rebol a **`block!`** is a fundamental data structure. It acts as a versatile container a list that can hold a series of any other Rebol values including numbers strings words and even other blocks. This ability to nest blocks within each other is key to building complex data structures.

This guide covers the entire lifecycle of a block:
- **Creation:** How to make new blocks.
- **Modification:** How to add, remove and change a block's contents.
- **Copying:** How to duplicate blocks and the critical differences between copy types.

## 2. Block Creation

The script demonstrates four primary ways to create a block.

### 2.1. Literal Creation: `[...]`
The most common way to create a block is by enclosing values in square brackets.
```rebol
my-block: [10 "apple" [a b]]
```

### 2.2. Using `make`
The `make` constructor offers more control.
- **`make block! <size>`**: Creates an empty block but pre-allocates memory for `<size>` elements. This is a performance optimization for large blocks that will be built up in a loop as it reduces the need for the interpreter to resize the block repeatedly.
    ```rebol
    >> big-block: make block! 1000  ; Ready to hold 1000 items efficiently
    ```
- **`make block! <string>`**: Parses a string to create a block.
    ```rebol
    >> make block! "one two"
    == [one two]
    ```

### 2.3. Using `load`
The `load` function parses a string as Rebol source code. If the string contains valid block syntax it will produce a `block!`. This is the most powerful method for creating blocks from text data (e.g. from a file).
```rebol
>> load "[config [debug on]]"
== [config [debug on]]
```
> **Security Note:** `load` is powerful and will parse any valid Rebol code. Only use `load` on trusted data sources to avoid potential code injection.

### 2.4. Using `to-block`
The `to-block` function converts another datatype into a block. When used with a string it typically creates a block containing that single string as its only element.
```rebol
>> to-block "one two"
== ["one two"]
```

## 3. Block Modification

Once a block is created its contents can be modified in-place using a variety of powerful functions.

### `append`
Adds one or more items to the **end** of a block.
```rebol
>> my-block: [a b]
>> append my-block "c"
== [a b "c"]
```
- **`append/only`**: Appends a block as a single nested item rather than merging its contents.
    ```rebol
    >> my-block: [a b]
    >> append/only my-block [c d]
    == [a b [c d]]
    ```
- **`append/part <limit>`**: Appends a specific number of items from another block.
- **`append/dup <count>`**: Appends a value a specified number of times.

### `insert`
Adds one or more items at a **specific position** in a block. The position can be the head the tail or a location found using `find`.
```rebol
>> my-block: [a c]
>> insert at my-block 2 "b"  ; `at` gets the position
== [a "b" c]
```
- **`insert/only`**: Inserts a block as a single nested item.
- **`insert/part <limit>`**: Inserts a portion of another block.
- **`insert/dup <count>`**: Inserts a value multiple times.

### `change`
Replaces one or more elements in a block.
```rebol
>> my-block: [a x c]
>> change at my-block 2 "b"
== [a "b" c]
```
- **`change/part <limit>`**: Replaces `<limit>` number of elements with the new value(s).
- **`change/only`**: Replaces one element with a block as a single nested item.
- **`change/dup <count>`**: Replaces `<count>` elements with `<count>` copies of the new value.

### `remove` and `clear`
- **`remove`**: Removes one element from a specific position.
    ```rebol
    >> my-block: [a b c]
    >> remove at my-block 2
    == [a c]
    ```
- **`remove/part <limit>`**: Removes `<limit>` number of elements.
- **`clear`**: Removes all elements from a block making it empty.

### Return Values
All modification functions (`append` `insert` `change` `remove`) modify the block in-place and return the position in the series **after** the modification. This is useful for chaining operations or for immediately working with the remainder of the block.

## 4. Block Copying

Understanding how blocks are copied is critical for avoiding bugs.

### 4.1. Shallow Copy (the default)
A shallow copy creates a new top-level block but **shares** any nested blocks or strings with the original. Modifying a shared nested block in the copy **will also modify the original**.

**Created with:** `copy my-block` or `make block! my-block`
```rebol
>> original: ["config" [1 2]]
>> shallow-copy: copy original
>> append pick shallow-copy 2 3   ; Modify nested block in the copy
>> original
== ["config" [1 2 3]]  ; The original is also changed!
```

### 4.2. Deep Copy
A deep copy creates a completely new and independent block including new copies of all nested blocks and strings. Modifications to the deep copy **will not** affect the original.

**Created with:** `copy/deep my-block`
```rebol
>> original: ["config" [1 2]]
>> deep-copy: copy/deep original
>> append pick deep-copy 2 3      ; Modify nested block in the copy
>> original
== ["config" [1 2]]  ; The original is unchanged.
```

### 4.3. Partial Copy: `copy/part`
Creates a new shallow copy containing only a specified portion of the original block.

### 4.4. `copy/types` (and `filter-by-types` workaround)
The script observes that in REBOL/Bulk 3.19.0 `copy/types` does not filter elements by type as might be expected. As a solution the script provides a helper function `filter-by-types` which correctly performs this action.

```rebol
filter-by-types: function [
    series-to-filter [series!]
    allowed-types    [typeset!]
] [...]
```

**Usage:**
```rebol
>> mixed-block: ["text" 100 [a] 'word]
>> filter-by-types mixed-block make typeset! [string! integer!]
== ["text" 100]
```

## 5. Running the Demonstration Script
It will print the "before" and "after" state for dozens of examples each demonstrating a specific function or concept discussed in this manual. The verbose output is designed to make the behavior of each operation clear.
