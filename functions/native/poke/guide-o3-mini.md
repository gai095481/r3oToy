# Unofficial User's Guide - `poke` Function

A robust overview of the `poke` function based on extensive diagnostic evidence. Whether you are a novice programmer or seeking to understand the nuances of series manipulation in Rebol 3 Oldes, this guide lays out clear explanations, common pitfalls and practical examples.

## Overview

The `poke` function is an action that replaces an element in a series (or similar types), at a specified index. The change is _in-place_, meaning the original series is mutated. Additionally, `poke` returns the new value that was assigned, providing confirmation of the operation.

**Usage Syntax:**

> poke series index value

- **series**: The target series to modify. Supported types include `block!`, `string!`, `binary!`, `map!`, and `bitset!`. Other types such as `port!` and `gob!` are generally unsupported.
- **index**: A position indicator. For series types like `block!`, `string!`, and `binary!`, indices are **1-based**. For `map!`, the index is typically a `symbol!` representing the key.
- **value**: The new value to set. The expected type of the new value is dependent on the type of series being modified.

## Supported Types and Nuances

### 1. `block!`

- **Behavior**: Replaces an element at a given 1-based index.
- **Return**: The new value that was set.
- **Example**:
  
  ```rebol
  my-block: [10 20 30]
  poke my-block 2 99  ;; Replaces element at position 2
  ;; After this, my-block equals: [10 99 30]
  ```
- **Error Handling**: Using an out-of-bound index (e.g., greater than the series length, or index ≤ 0), will cause an error without mutating the series.

### 2. `string!`

- **Behavior**: When used with a `string!`, `poke` does **not** accept a literal string as the replacement. Instead, it requires an **integer codepoint** corresponding to the character.
- **Return**: The integer codepoint that was set.
- **Example**:
  ```rebol
  my-string: "abc"
  poke my-string 2 90  ;; 90 is the codepoint for 'Z'
  ;; After this, my-string equals: "aZc"
  ```
- **Common Pitfall**: Novices might try using `"Z"` directly. Always convert your character to its integer codepoint (e.g., 90 for 'Z', 81 for 'Q').

### 3. `binary!`

- **Behavior**: Alters a byte in a binary series.
- **Return**: The new integer value that was set.
- **Example**:
  ```rebol
  my-binary: #{010203}
  poke my-binary 2 255  ; Replaces the second byte with 255 (0xFF)
  ;; After this, my-binary equals: #{01FF03}
  ```
- **Error Handling**: Out-of-range index operations will error and leave the binary unchanged.

### 4. `map!`

- **Behavior**: For maps, `poke` allows you to set a value for a key. If the key exists, its value is replaced; if the key is new, it is added.
- **Return**: The new value that was set.
- **Example**:
  ```rebol
  my-map: make map! [a 1 b 2]
  poke my-map 'a 99   ;; Replaces the value for key 'a
  poke my-map 'c 77   ;; Adds a new key 'c with value 77
  ```

### 5. `bitset!` (charset)

- **Behavior**: Modifies a specified bit (1-based index). Setting a bit to `true` marks it as 1; `false` marks it as 0.
- **Return**: The modified bitset is actually returned.
- **Example**:
  ```rebol
  my-bitset: make bitset! 8
  poke my-bitset 2 true   ;; Sets the 2nd bit to true
  ;; Later, setting it to false:
  poke my-bitset 2 false  ;; The bitset reflects the modification
  ```
- **Nuance**: Unlike other types, `poke` on a `bitset!` appears to return the whole modified bitset rather than just the value provided.

## Best Practices and Recommendations

1. **Understand the Data Type**: Always check which series type you are working with. The behavior of `poke` varies, and using the correct type is key to avoiding errors.
2. **Indexing is 1-Based**: Remember that Rebol’s indexing starts at 1. Providing an index of 0 or a negative number leads to errors.
3. **Type Matching for the Value**:
   
   - For strings, convert characters to their corresponding integer codepoints before using them with `poke`.
   - For maps, use a `symbol!` for the key.
   - For binary and bitset, ensure the value is within acceptable limits (e.g., for binary, a byte value between 0 and 255).
4. **Error Handling**:
   
   - Operations on out-of-bound indices or invalid index types will result in errors and leave the series unmodified.
   - For unsupported types (`port!`, `gob!`), expect the operation to fail. Always handle errors gracefully in your code.
5. **Testing Your Code**: Use diagnostic probe scripts to experiment and learn how `poke` behaves with different data types. This kind of evidence-based testing is invaluable in understanding nuances and avoiding potential pitfalls.
6. **Reading the Return Value**: Keep in mind that while most series will return the new value directly (e.g., an integer or a modified series), bitset! returns the modified bitset itself. Tailor your checks accordingly.

## Summary

The `poke` function in Rebol 3 Oldes is a powerful tool to mutate series data.
Its behavior is consistent within each supported type, but the nuances—like the requirement to use integer codepoints for strings and
the unique return value for bitset!—are essential for proper use. By carefully following this guide and testing your code,
you'll be well-equipped to overcome common challenges and use `poke` effectively in your Rebol programming endeavors.
