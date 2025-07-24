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

---
Based on the diagnostic probe script and its findings for Rebol/Bulk 3.19.0, here are some common pitfalls when using the `compose` function and how to avoid them:

1. **Misunderstanding Block Splicing (Default Behavior):**
    
    * **Pitfall:** Expecting a block returned by a parenthesized expression to be inserted as a single nested block.
    * **Example:**
        ```rebol
        items: [A B]
        result: compose [Start (items) End]
        print result ; Incorrectly expected: [Start [A B] End]
                     ; Actual output:     [Start A B End]
        ```
    * **Avoidance:** Use the `/only` refinement when you want the block result inserted as a single element.
        ```rebol
        items: [A B]
        result: compose/only [Start (items) End]
        print result ; Correct output: [Start [A B] End]
        ```
2. **Incorrect Assumptions about `/into` Behavior:**
    
    * **Pitfall 1: Assuming `/into` appends.** The `/into` refinement **prepends** the composed result to the beginning of the target series.
        * **Example:**
            ```rebol
            target: [existing]
            compose/into [new] target
            print target ; Incorrectly expected: [existing new]
                         ; Actual output:     [new existing]
            ```
        * **Avoidance:** Remember that `compose/into` prepends. Plan your target block's initial content accordingly, or adjust your logic to account for the prepended result.
    * **Pitfall 2: Using invalid target types.** Attempting to use `()` (a `paren!` *value*) as the target for `/into` is invalid because it's not a modifiable series context in the way a variable holding a `block!` or `paren!` series is.
        * **Example (Error):**
            ```rebol
            paren-target: () ; This is just the value ()
            compose/into [item] paren-target ; Error: paren-target needs a value / Invalid target
            ```
        * **Avoidance:** Use a variable that holds a modifiable `block!` or `paren!` series as the target.
            ```rebol
            target-series: [] ; An empty block series
            compose/into [item] target-series ; Correct
            print target-series ; Output: [item]
            ```
3. **Confusing Return Value of `/into`:**
    
    * **Pitfall:** Expecting `compose/into` to return the modified target *series content* or a *copy*. It returns a *reference* to the (head of the) *same series object* that was passed as the target.
    * **Avoidance:** Understand that `compose/into source target` modifies `target` itself and returns a reference to `target` (specifically, its head after modification). Use the target variable directly if needed, or be aware that modifying the returned reference modifies the original target.
4. **Misinterpreting Handling of `none` and `unset`:**
    
    * **Pitfall 1: Expecting `none` values to be omitted.** If a parenthesized expression evaluates to the `none!` value (`#(none)`), this value is **included** in the resulting block.
        * **Example:**
            ```rebol
            result: compose [Value (none)]
            print result ; Incorrectly expected: [Value] or [Value none as word]
                         ; Actual output:     [Value #(none)]
            ```
        * **Avoidance:** Be aware that `none` is a value and gets included. If omission is desired, ensure the expression evaluates to `unset!` (e.g., using `()`, `print`, or `do []`).
    * **Pitfall 2: Not understanding `unset` omission.** Values of type `unset!` (distinct from `none!`) are correctly omitted from the composed result.
        * **Avoidance:** This behavior is generally as expected, but it's good to know *why* empty parens `()` disappear – they evaluate to `unset!`.
5. **Incorrect Expectations for Non-Block Inputs:**
    
    * **Pitfall:** Expecting `compose` to process or evaluate non-`series!` inputs like strings or numbers in a special way.
    * **Example:**
        ```rebol
        str: "hello"
        result: compose str
        print result ; Output is just "hello", unchanged
        ```
    * **Avoidance:** Remember that `compose` primarily operates on `series!` types (like `block!`, `paren!`). If the input isn't a series, it's returned as-is without any paren evaluation attempted.

By being mindful of these points – especially the default splicing behavior, the prepending nature of `/into`, and the distinction between `none!` and `unset!` handling – you can use `compose` effectively and avoid common mistakes.

---
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
