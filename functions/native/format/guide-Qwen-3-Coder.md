# Unofficial `format` Function User Guide

Based on empirical testing and source code analysis for Rebol/Bulk 3.19.0. The `format` function generates formatted strings based on a dialect of rules applied to a series of values.

## Core Concept

> format *rules values*

It takes two main arguments:

- `rules`: A block (or single value, which is wrapped), defining the output structure.
- `values`: A block (or single value, which is wrapped), of data to be formatted according to the `rules`.

The function returns a single formatted `string!`.

## Rules Dialect

The `rules` block is a sequence of rule items.  Each item determines how the output string is built.

### Integer Rules (`integer!`)

- **Purpose**: Specify a field width for formatting the *next* value from the `values` block.
- **Positive Integer (`N`)**:
  - Takes the next value, converts it to a string using `form`.
  - If the string is longer than `N` characters, it's **truncated** to `N` characters.
  - If the string is shorter than `N` characters, it's **left-aligned** and **padded with spaces** (or the `/pad` character) on the right to make it `N` characters wide.
- **Negative Integer (`-N`)**:
  - Takes the next value, converts it to a string using `form`.
  - If the string is longer than `N` characters, it's **truncated** to `N` characters.
  - If the string is shorter than `N` characters, it's **right-aligned** and **padded with spaces** (or the `/pad` character) on the left to make it `N` characters wide.
- **Buffer Size**: Contributes `abs(N)` characters to the initial buffer size calculation.

**Example:**

```rebol
print format [5] ["Hi"]        ;; Output: "Hi   "
print format [-5] ["Hi"]       ;; Output: "   Hi"
print format [3] ["Longer"]    ;; Output: "Lon"
```

### String Rules (`string!`)

- **Purpose**: Insert the string literal directly into the output.
- **Buffer Size**: Contributes the `length?` of the string to the initial buffer size calculation.

**Example:**

```rebol
print format ["Prefix: " 10] ["Data"] ;; Output: "Prefix: Data      "
```

### Character Rules (`char!`)

- **Purpose**: Insert the character literal directly into the output.
- **Buffer Size**: Contributes `1` to the initial buffer size calculation.

**Example:**

```rebol
print format [#"|"] []         ;; Output: "|"
print format [3 #"."] ["X"]    ;; Output: "X  ." (Value 'X' padded to 3, then '.' inserted)
```

### TagRules (`tag!`)

- **Purpose**: Handle date/time formatting or provide a fallback.
- **Mechanism**:
  - Takes the *next* value from `values`.
  - Checks if the value is of type `date!` or `time!`.
    - **If Yes**: Attempts to call an internal function `format-date-time value rule`.
      - Based on testing, this function's behavior in this environment seems limited or non-standard. It may substitute parts of the tag itself rather than interpreting it as a standard date/time format string.
      - Example outputs observed: `format [<%Y-%m-%d>] 1-Jan-2023` -> `"%Y-%1-%1"`.
    - **If No (or `format-date-time` fails/not as expected)**: Appends `form rule` followed by `form value`.
- **Buffer Size**: Contributes `length? rule` to the initial buffer size calculation.

**Example:**

```rebol
print format [<tag>] ["Value"] ; Output: "<tag>Value"
; Date/Time formatting via tags may not work as standard strftime formats in this build.
```

### Word Rules (`word!`)

- **Purpose**: Resolve the word to its value before processing the rule.
- **Mechanism**: If a `word!` is encountered in the `rules` block, `get` is used to retrieve its value, and *that value* is treated as the rule.

**Example:**

```rebol
rule-def: 10
print format [rule-def] ["Hi"] ; Output: "Hi        " (Same as format [10] ["Hi"])
```

### Other Rule Types (`none!`, `decimal!`, etc.)

- **Purpose**: Generally ignored in the buffer size calculation.
- **Buffer Size**: Contributes `0` to the initial buffer size.
- **Output Loop**: Depending on the specific type, they might be ignored or cause the next value to be appended directly.

**Example:**

```rebol
print format [none 5] ["IgnoredRule" "Value"] ;; Output: "IgnoredRuleValue  "
print format [1.5] ["Value"] ;; Output: "Value" (1.5 contributes 0 to buffer)
```

## Refinements

### `/pad`

`format/pad rules values pad-pattern`

- **Purpose**: Change the default padding character from a space (`#" "`) to a custom pattern.
- `pad-pattern`: Can be any value. It is converted to a string using `form` and used to fill the initial buffer.
- This affects padding for `integer!` rules (both positive and negative alignment) and also pads the buffer if there are insufficient values for the rules.

**Example:**

```rebol
print format/pad [10] ["Hi"] #"*" ;; Output: "Hi********"
print format/pad [10] ["Hi"] "." ;; Output: "Hi........"
print format/pad [-5] ["Hi"] #"0" ;; Output: "000Hi"
```

## Important Nuances & Gotchas

1. **Non-Block Arguments**: If `rules` or `values` is not a `block!`, it is automatically wrapped in a block using `reduce`. `format 10 "A"` is equivalent to `format [10] ["A"]`.
2. **Value Consumption**: Rules like `integer!`, `money!` and `tag!` consume one value from the `values` block. `string!` and `char!` rules do not consume values.
3. **Excess Values**: If there are more values in the `values` block than rules consume, the remaining values are converted to strings using `form` and **appended** to the end of the formatted string.
4. **Insufficient Values**: If a rule needs a value but the `values` block is exhausted, `form none` (which produces the string `"none"`), is used instead. This `"none"` string is then subject to formatting rules (like truncation/padding for `integer!` rules).
5. **Date/Time Formatting Limitation**: The standard `strftime`-like formatting expected from `tag!` rules (e.g., `<dd-mm-yy>`), does not appear to be fully implemented or functional in the tested Rebol/Bulk 3.19.0 environment. The `format-date-time` helper function's behavior is non-standard based on probe results.
6. **Buffer Initialization**: The function first calculates an approximate total length for the output string and creates a string buffer padded with the `/pad` pattern (or spaces). This buffer is then modified in-place by the rules.
7. **Truncation vs. Padding**: `integer!` rules enforce a strict field width via truncation (if too long) or padding (if too short). This is different from *only* padding.

## Examples for Novices

```rebol
;; Basic padding:
print format [10] ["Hello"] ; Left-aligned in 10 chars
print format [-10] ["Hello"] ; Right-aligned in 10 chars

;; Combining rules:
print format [5 "-" 5] ["A" "B"] ; "A    -B    "

;; Using `/pad`:
print format/pad [8] ["Rebol"] #"-" ; "Rebol---"

;; Literal strings/chars:
print format ["Result: " 5 #"="] ["OK"] ; "Result: OK   ="

;; Handling extra values:
print format [3] ["A" "B" "C"] ; "A  BC" ('A' formatted, 'B' and 'C' appended)

;; Handling missing values:
print format [5 5] ["X"] ; "X    none " (First rule uses 'X', second uses 'form none')
```
