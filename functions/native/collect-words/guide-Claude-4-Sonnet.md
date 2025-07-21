# COLLECT-WORDS Function User's Guide

## Rebol 3 (Oldes Branch) - Unofficial Reference

### Overview

The `collect-words` function is a powerful native function that extracts unique words from blocks and other data structures. It returns a block containing word! values in their order of first appearance, making it invaluable for analysis, filtering, and data processing tasks.

## Basic Syntax

```rebol
;; Basic usage
result: collect-words input-block

;; With refinements
result: collect-words/deep input-block          ;; Deep traversal
result: collect-words/set input-block           ;; Only set-words
result: collect-words/ignore input-block [words-to-skip]
result: collect-words/as input-block word-type  ;; Convert result type
```

## Core Behavior & Key Principles

### 1. **Uniqueness Guarantee**

`collect-words` automatically eliminates duplicates and preserves order of first occurrence:

```rebol
;; Input with duplicates
words: [hello world hello test world]
result: collect-words words
;; Result: [hello world test] - duplicates removed, order preserved
```

### 2. **Word Type Normalization**

All word variants (get-words `:word`, set-words `word:`, lit-words `'word`) are normalized to regular `word!` type in the result:

```rebol
mixed-words: [normal :get-word set-word: 'lit-word]
result: collect-words mixed-words
;; Result: [normal get-word set-word lit-word] - all are `word!` datatype.
```

### 3. **Data Type Filtering**

Only word-like elements are extracted; other data types are ignored:

```rebol
mixed-block: [hello 42 "string" world [nested] test]
result: collect-words mixed-block
;; Result: [hello world test] - only words extracted.
```

### 4. **Issue Literal Handling** ⚠️

Issue literals (`#word`) contribute their word component to the collection:

```rebol
with-issues: [#red #green normal-word #blue]
result: collect-words with-issues
;; Result: [red green normal-word blue] - # symbols stripped.
```

## Refinements Reference

### `/deep` - Nested Block Traversal

**Default behavior** (shallow): Only processes the top level of the input block.

```rebol
nested: [outer [inner deep-word] surface]
shallow: collect-words nested
;; Result: [outer surface] - nested blocks ignored.
```

​**With `/deep`**​: Recursively processes all nested blocks.

```rebol
deep: collect-words/deep nested
;; Result: [outer inner deep-word surface] - all levels processed.
```

### `/set` - Set-Word Only Collection

Collects only set-words (`word:`), ignoring all other word types:

```rebol
mixed: [normal-word set-word: another: regular :get-word]
sets-only: collect-words/set mixed
;; Result: [set-word another] - only set-words collected.
```

### `/ignore` - Selective Exclusion

Excludes specified words from the result:

```rebol
words: [hello world test ignore-me hello]
filtered: collect-words/ignore words [hello ignore-me]
;; Result: [world test] - specified words excluded.
```

**Special cases:**

* `collect-words/ignore block none` behaves like regular `collect-words`
* `collect-words/ignore block []` behaves like regular `collect-words`

### `/as` - Result Type Conversion

Converts collected words to a different word type:

```rebol
words: [hello world test]

;; Convert to lit-words
lits: collect-words/as words lit-word!
;; Result: ['hello 'world 'test]

;; Convert to set-words  
sets: collect-words/as words set-word!
;; Result: [hello: world: test:]

;; Convert to get-words
gets: collect-words/as words get-word!
;; Result: [:hello :world :test]
```

## Combining Refinements

Multiple refinements can be combined for sophisticated filtering:

### `/deep` + `/set`

Collect set-words from nested structures:

```rebol
nested-sets: [outer-set: [inner-set: word] another:]
result: collect-words/deep/set nested-sets
;; Result: [outer-set inner-set another]
```

### `/deep` + `/ignore`

Deep traversal while excluding specific words:

```rebol
data: [keep [skip nested] keep-too]
result: collect-words/deep/ignore data [skip]
;; Result: [keep nested keep-too]
```

### `/set` + `/as`

Collect set-words and convert their type:

```rebol
sets: [first: second: normal-word]
result: collect-words/set/as sets lit-word!
;; Result: ['first 'second] - only set-words collected and converted
```

---

## Common Patterns & Best Practices

### 1. **Variable Analysis**

```rebol
;; Extract all variables referenced in a code block
code: [if x > y [print z]]
variables: collect-words/deep code
;; Use for dependency analysis, variable tracking
```

### 2. **Configuration Key Extraction**

```rebol
;; Extract configuration keys from nested settings
config: [database [host: "localhost" port: 3306] cache [enabled: true]]
keys: collect-words/deep/set config
;; Result: [host port enabled] - all configuration keys
```

### 3. **Template Variable Discovery**

```rebol
;; Find template variables in content
template: [Hello :name, welcome to :site on :date]
vars: collect-words template
;; Filter out non-template words manually if needed
```

### 4. **Data Structure Cleanup**

```rebol
;; Remove unwanted words from analysis
raw-data: [data noise process cleanup data]
clean: collect-words/ignore raw-data [noise cleanup]
;; Result: [data process] - clean word list
```

---

## Edge Cases & Gotchas

### 1. **Empty Results**

```rebol
;; These all return empty blocks []
collect-words []                    ; Empty input
collect-words [42 "string" 3.14]   ; No words present
collect-words/set [normal :get]     ; No set-words present
```

### 2. **Single Character Words**

```rebol
;; Single characters are valid words
chars: [a b c x y z]
result: collect-words chars
;; Result: [a b c x y z] - all collected normally
```

### 3. **Special Characters in Words**

```rebol
;; Valid word characters are preserved
special: [word-dash word_under word?question]
result: collect-words special
;; Result: [word-dash word_under word?question] - all valid
```

### 4. **Performance with Large Data**

```rebol
;; Function efficiently handles large blocks with many duplicates
;; No special considerations needed for typical use cases
```

---

## Error Prevention

### 1. **Input Validation**

```rebol
safe-collect: function [input][
    {Safely collect words with input validation}
    if not block? input [
        return []
    ]
    collect-words input
]
```

### 2. **Refinement Safety**

```rebol
;; Safe ignore pattern
ignore-list: either block? ignore-words [ignore-words] [[]]
result: collect-words/ignore data ignore-list
```

---

## Quick Reference Summary

| Usage                                   | Purpose                | Result                   |
| ----------------------------------------- | ------------------------ | -------------------------- |
| `collect-words block`               | Basic word extraction  | `[unique words]`     |
| `collect-words/deep block`          | Include nested blocks  | `[all nested words]` |
| `collect-words/set block`           | Only set-words         | `[set-words only]`   |
| `collect-words/ignore block [skip]` | Exclude specific words | `[filtered words]`   |
| `collect-words/as block lit-word!`  | Convert result type    | `['lit 'words]`      |

**Remember:**

* Results are always unique (no duplicates)
* Order of first appearance is preserved
* All word types normalize to `word!` unless using `/as`
* Issue literals (`#word`) contribute their word part
* Empty inputs return empty blocks `[]`
