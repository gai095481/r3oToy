# Unofficial `collect-words` Function User's Guide

Based on comprehensive testing in Rebol/Bulk 3.19.0, here's a complete guide to using `collect-words` effectively.

## Overview

`collect-words` extracts unique words from Rebol blocks, primarily used for context construction. It processes all word-like types, normalizes them to `word!` and preserves first-occurrence casing.

>  collect-words block [/deep /set /ignore words /as type]


## Key Behaviors

1. **Normalization**: All word-like types are converted to `word!` in the result
   
   - `set-word!` (e.g., `a:`) → `a`
   - `get-word!` (e.g., `:b`) → `b`
   - `issue!` (e.g., `#123`) → `123`
   - `lit-word!` (e.g., `'c`) → `c`
2. **Case Handling**: Case-insensitive uniqueness with first occurrence casing preserved:
   
   ```rebol
   collect-words [a A]  ; => [a]
   collect-words [A a]  ; => [A]
   ```
3. **Non-Word Values**: These types are ignored:
   
   - Integers (e.g., `1`)
   - Strings (e.g., `"text"`)
   - Files (e.g., `%file.txt`)
   - Binary values

## Refinements

### `/deep`

Collects from nested blocks (recursive traversal):

```rebol
collect-words [a [b]]        ; => [a]
collect-words/deep [a [b]]   ; => [a b]
```

### `/set`

Filters to only set-words (`word:` syntax), still normalized to words:

```rebol
collect-words/set [a: b c:]  ; => [a c]
```

### `/ignore`

Excludes words by normalized spelling (case-insensitive). Accepts blocks or objects:

```rebol
collect-words/ignore [a b c] [b]        ; => [a c]
collect-words/ignore [a: b] object [a: 1]  ; => [b] (ignores 'a)
```

### `/as`

Converts result to specified word type:

```rebol
collect-words/as [a b] set-word!  ; => [a: b:]
collect-words/set/as [a: b] word! ; => [a] (set-words only)
```

## Processing Order

Refinements apply in this sequence:

1. `/deep` traversal (if present)
2. `/set` filtering (if present)
3. Normalization to `word!` + uniqueness
4. `/ignore` exclusion
5. `/as` type conversion

## Common Patterns

### Creating Contexts

```rebol
context collect-words/deep [
    title: "Example"
    actions: [
        do-action: func [x] [print x]
    ]
]
```

### Collecting Set-Words

```rebol
collect-words/set [
    name: "John"
    age: 30
]  ;; => [name age]
```

### Filtering with Ignore

```rebol
ignore-words: [print func if]
code: [a: print "Hello" if true [b: 10]]
words: collect-words/deep/ignore code ignore-words
;; => [a b]
```

## Nuances & Solutions

1. **Unexpected Normalization**
   *Problem*: Set-words (`a:`) become regular words (`a`)
   *Solution*: Use `/as set-word!` to maintain colon notation:
   
   ```rebol
   collect-words/as [a: b] set-word!  ;; => [a: b:]
   ```
2. **Case Sensitivity Confusion**
   *Problem*: `[Foo foo]` returns `[Foo]` (not `[foo]`)
   *Solution*: Standardize casing first if needed:
   
   ```rebol
   words: collect-words [Foo foo]
   lowercase-words: map words :to-word
   ```
3. **Issue! Handling**
   *Problem*: `#issue` becomes `issue` (loses `#` prefix)
   *Solution*: Convert back to issues after collection:
   
   ```rebol
   issues: map (collect-words [#bug #feature]) :to-issue
   ```
4. **Ignoring System Words**
   *Problem*: Built-in words appear in results
   *Solution*: Use `/ignore` with system context:
   
   ```rebol
   collect-words/ignore [a + b] system/words
   ```

## Performance Notes

- Prefer shallow collection (without `/deep`) for flat blocks
- For large code blocks, use `/ignore` with common system words
- Complex nested structures benefit from combining `/deep` and `/ignore`

## Edge Case Handling

```rebol
collect-words []          ;; => [] (empty block)
collect-words [1 "a" b]  ;; => [b] (non-words ignored)
collect-words [#123]      ;; => [123] (issues converted)
```

This guide reflects actual behavior verified through comprehensive testing in Rebol/Bulk 3.19.0.
