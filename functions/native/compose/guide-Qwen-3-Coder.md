# Unofficial `compose` Function User Guide

This guide explains the `compose` function based on empirical testing and source code analysis for Rebol/Bulk 3.19.0.
The `compose` function is used to create new blocks (or other series) by evaluating expressions within parentheses `()` found in a template block.

## Core Concept

`compose block`

It takes one main argument:

- `block`: A block (or other series), containing literal values and parenthesized expressions.

The function returns a new series of the same type as the input, where:

- Literal values (strings, numbers, words, sub-blocks, etc.) are copied as-is.
- Expressions inside `()` are **evaluated**, and their results replace the parentheses in the output.

## Basic Behavior

```rebol
template: [a (1 + 2) b ("hello" "world") c]
result: compose template
print result ;; Output: [a 3 b ["hello" "world"] c]
```

## Handling of Expression Results

The way `compose` inserts the result of evaluating a parenthesized expression depends on the result's type:

- **Non-Block Values**: The value is inserted directly.
  ```rebol
  compose [Value: (10 * 5)] ;; Output: [Value: 50]
  ```
- **Block Values (`block!`)**: By **default**, the contents of the block are **spliced** (inserted individually) into the result.
  ```rebol
  compose [Start (['A 'B]) End] ;; Output: [Start A B End] (Note: A and B are spliced)
  ```

## Refinements

### `/only`

`compose/only block`

- **Purpose**: Prevent the splicing of block results.
- **Effect**: If a parenthesized expression evaluates to a `block!`, that entire block is inserted as a single element, not spliced.

**Example:**

```rebol
template: [Start (['A 'B]) End]
result-default: compose template
print result-default ;; Output: [Start A B End] (Spliced)

result-only: compose/only template
print result-only ;; Output: [Start [A B] End] (Block inserted as one element)
```

### `/deep`

`compose/deep block`

- **Purpose**: Perform composition recursively, evaluating parentheses not just in the top-level block, but also within any nested sub-blocks.
- **Effect**: Parentheses at any depth within the structure are evaluated.

**Example:**

```rebol
template: [Outer [Inner (1 + 1)] (2 + 2)]
result-shallow: compose template
print result-shallow ;; Output: [Outer [Inner (1 + 1)] 4] (Inner paren untouched)

result-deep: compose/deep template
print result-deep ;; Output: [Outer [Inner 2] 4] (Inner paren evaluated)
```

### `/into`

`compose/into block target-series`

- **Purpose**: Instead of creating a new series, inserts the composed result **at the beginning** of an existing `target-series`.
- `target-series`: Must be a mutable `series!` type (like `block!` or `paren!`). **It cannot be `()`**.
- **Return Value**: Returns a reference to the **head** of the modified `target-series`.
- **Effect**: The `target-series` is modified in place by **prepending** the composed result. The original content of the `target-series` remains after the prepended content.

**Example:**

```rebol
target: [existing items]
source: [New (1 + 2) Item]
result-ref: compose/into source target
print target       ; Output: [New 3 Item existing items] (Modified target)
print result-ref   ; Output: [New 3 Item existing items] (Reference to modified target's head)
```

## Important Nuances & Gotchas

1. **Splicing vs. Insertion**: The default behavior of splicing block results is a common source of confusion. Use `/only` if you intend to insert a block as a single nested block.
2. **Evaluation Context**: Expressions inside `()` are evaluated in the current context. Variables and functions available where `compose` is called can be used inside the parentheses.
3. **Handling of `none` and `unset`**:
    * If a parenthesized expression evaluates to the `none!` value (`#(none)`), that `none` value is included in the resulting block.
    * If a parenthesized expression evaluates to the `unset!` value (e.g., the result of `()` or `print`), that value is **omitted** entirely from the result.
4. **Non-Block Input**: If the input to `compose` is not a `block!` (or `paren!`, etc.), it is returned unchanged.
    ```rebol
    compose "string" ; Output: "string"
    compose 42       ; Output: 42
    ```
5. **`/into` Prepends**: Contrary to potential assumptions, `compose/into` **prepends** the result to the `target-series`, it does not append. The original content of the target follows the newly composed content.
6. **`/into` Target Type**: The `target-series` for `/into` must be a proper, modifiable series. Using `()` as the target will cause an error.
7. **Return Value of `/into`**: It returns a reference to the head of the (now modified) `target-series`. If the target was not at its head position before the call, the returned reference might point to a different part of the series than expected, although it's still the same series context.

## Examples for Novices

```rebol
;; --- Basic Usage ---
template: [Name: (user-name) Score: (calculate-score)]
user-name: "Alice"
calculate-score: does [100]
result: compose template
print result ;; Output: [Name: "Alice" Score: 100]

;; --- Splicing vs /only ---
items: [X Y]
print compose [Start (items) End]    ;; Output: [Start X Y End]
print compose/only [Start (items) End] ;; Output: [Start [X Y] End]

;; --- /deep for Nested Structures ---
config-template: [Settings [Debug: (debug-flag)] Version: (version-info)]
debug-flag: true
version-info: [Major 1 Minor 0]
config-shallow: compose config-template
print config-shallow ; Output: [Settings [Debug: (debug-flag)] Version: [Major 1 Minor 0]]
config-deep: compose/deep config-template
print config-deep    ; ;Output: [Settings [Debug: true] Version: [Major 1 Minor 0]]

;; --- /into to Modify Existing Block ---
output-buffer: [Header]
data: [Item (item-id) Value (item-value)]
item-id: 123
item-value: 45.67
compose/into data output-buffer
print output-buffer ;; Output: [Item 123 Value 45.67 Header]

;; --- Handling none and unset ---
test-block: [
    Value (10)
    NoneVal (none)        ;; none! value included
    UnsetVal ()           ;; unset! value omitted
    AlsoUnset (print "")  ;; Result of print is unset, omitted
]
result: compose test-block
print result ;; Output: [Value 10 NoneVal #(none)] (Note: #(none) is the none! value)
```

Understanding these rules and nuances allows for effective use of `compose` to dynamically build complex data structures and code blocks.
