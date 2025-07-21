# Unofficial `collect-words` Function User's Guide

`collect-words` is a powerful function designed to extract unique words from blocks of code or data, returning them as a block of `word!` datatype values. It preserves the order of first appearance and supports multiple refinements to customize its behavior.

## Function Signature

> collect-words block [ /deep /set /ignore block /as datatype! ]

- **block** — The block from which to extract words.
- `/deep` — Recursively processes nested blocks, maintaining uniqueness across all levels.
- `/set`— Filters to only`set-word!`types, converting them to`word!` in results.
- `/ignore` block — Excludes specified words, objects, or none from the results.
- `/as` datatype! — Converts the results to the specified word datatype (`set-word!`, `get-word!`, `lit-word!`, `refinement!`, `issue!`).
- Multiple refinements can be combined logically.

## Description

- Extracts unique words from the specifed block.
- Returns a block of `word!` values.
- Maintains the order of first appearance.
- Converts all word types (`set-word!`, `get-word!`, `lit-word!`, `refinement!`, `issue!`) to regular `word!` by default.
- Handles Unicode, special characters and case sensitivity by preserving the first occurrence's case.
- Supports circular references safely.
- Designed for efficient context construction with `make object!`.
- Very fast even with large datasets and deep nesting.

## Refinements and Examples

### `/deep`

Recursively processes nested blocks, ensuring uniqueness across all nested levels.

```rebol
block: [foo bar [baz foo] qux]
collect-words block
; ;=> [foo bar qux]

collect-words/deep block
;; => [foo bar baz qux]
```

### `/set`

Filters to only `set-word!` types (words with `:`), converting them to `word!`.

```rebol
block: [a: b c: d]
collect-words block
;; => [a b c d]

collect-words/set block
;; => [a c]
```

### `/ignore` `block!`

Excludes specified words or objects from the results.

```rebol
block: [foo bar baz qux]
collect-words/ignore [bar qux] block
;; => [foo baz]
```

Supports ignoring words, objects, or none.

### `/as` `datatype!`

Converts the results to the specified word datatype.

```rebol
block: [foo bar baz]
collect-words/as 'set-word! block
;; => [foo: bar: baz:]
```

Supported datatypes: `set-word!`, `get-word!`, `lit-word!`, `refinement!`, `issue!`.

### Combining Refinements

Refinements can be combined logically.

```rebol
block: [a: b c: [d e: f]]
collect-words/deep/set/ignore [b] block
;; => [a c e]
```

## Common Pitfalls

- **Case Sensitivity:** The function preserves the letter case of the first occurrence of a word. Subsequent occurrences with different cases are ignored.
  
  ```rebol
  block: [Foo foo FOO]
  collect-words block
  ;; => [Foo]
  ```
- **Word Type Conversion:** All word types are converted to `word!` by default, which may affect code expecting original word types.
- **Nesting Behavior Without `/deep`:** Without `/deep`, nested blocks are not processed, potentially missing words.
- **Ignoring Words:** Ensure the `/ignore` block contains the exact words or objects to exclude; mismatches will not exclude intended items.

## Best Practices

- Use `/deep` when working with nested blocks to ensure comprehensive extraction.
- Use `/set` to focus on variable assignments or definitions.
- Use `/ignore` to exclude common or irrelevant words to reduce noise.
- Use `/as` to convert results to the desired word type for further processing.
- Combine refinements thoughtfully to tailor results to your needs.
- Test with your specific data to understand letter case sensitivity and word type conversions.

## Performance Considerations

- `collect-words` is optimized for speed, handling large datasets and deep nesting efficiently.
- Circular references in blocks are safely handled without infinite loops.
- Avoid unnecessary deep recursion if only top-level words are needed to save processing time.

## Practical Use Cases

- **Context Construction:** Quickly gather all unique words from code blocks to build objects or contexts with `make object!`.
  
  ```rebol
  context-words: collect-words/deep/set some-code-block
  context: make object! context-words
  ```
- **Code Analysis:** Extract identifiers for static analysis, refactoring, or documentation generation.
- **Filtering and Validation:** Identify and exclude certain words or types from blocks before processing.
- **Data Cleaning:** Normalize word lists by extracting unique words and converting them to a consistent datatype.

This guide covers the essentials of `collect-words` in Rebol/Bulk 3.19.0 (Oldes Branch),
enabling novice programmers to effectively extract and manipulate words from blocks with confidence.
