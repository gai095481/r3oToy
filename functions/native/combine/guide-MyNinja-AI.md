# `combine` Function Unofficial User's Guide

*Based on the robust testing of REBOL/Bulk 3.19.0 (Oldes Branch)*

## Overview

The `combine` function concatenates values from a block into a series (typically a string), with support for evaluation, type filtering and various output formats.

**Basic Syntax:**

```rebol
combine data
combine/with data delimiter
combine/into data target-series
combine/ignore data ignored-typeset
combine/only data
```

## Core Behavior

### Basic Combination

```rebol
combine [1 2 3]                    ;; => "123"
combine ["hello" "world"]          ;; => "helloworld"
combine [1 "hello" 2.5]           ;; => "1hello2.5"
```

### Evaluation Features

* **Parentheses are evaluated:**
  ```rebol
  combine [1 (2 + 3) 4]            ;; => "154"
  combine ["hello" (uppercase "world")] ;; => "helloWORLD"
  ```
* **Get-words are resolved:**
  ```rebol
  name: "John"
  combine ["Hello " :name]         ;; => "Hello John"
  ```

### Nested Block Processing

By default, nested blocks are processed recursively:

```rebol
combine [1 [2 3] 4]               ;; => "1234"
combine [1 [2 [3 4] 5] 6]        ;; => "123456"
```

## Default Ignored Types

**IMPORTANT:** The documentation is incorrect about default ignored types.

**Actually Ignored by Default:**

* `unset!` values
* `error!` values
* `any-function!` values (functions, natives, etc.)

**NOT Ignored by Default (contrary to documentation):**

* `none!` values → converted to string "none"

```rebol
combine [1 none 2]               ;; => "1none2" (NOT "12")
combine [1 :print 2]             ;; => "12" (function ignored)
```

## Type Formatting Behavior

When converting to strings, type formatting markers are stripped:

```rebol
combine [#{DEADBEEF}]            ;; => "DEADBEEF" (not "#{DEADBEEF}")
combine [#issue]                 ;; => "issue" (not "#issue")  
combine [%file.txt]              ;; => "file.txt" (not "%file.txt")
combine [<tag>]                  ;; => "<tag>" (preserves angle brackets)
combine [http://site.com]        ;; => "http://site.com" (URLs preserved)
combine [#"A" #"B"]              ;; => "AB" (characters work correctly)
```

## Refinements

### /with - Add Delimiters

Inserts a delimiter between values:

```rebol
combine/with [1 2 3] " "         ;; => "1 2 3"
combine/with ["a" "b" "c"] ", "  ;; => "a, b, c"
```

**Edge cases:**

* Single values: no delimiter added
* Empty blocks: returns empty string
* Delimiter is inserted as-is (not type-converted)

### /into - Specify Output Series

Outputs results into a specified series:

```rebol
result: []
combine/into [1 2 3] result      ;; result becomes [1 2 3]

result: ""  
combine/into [1 2 3] result      ;; result becomes "123"
```

**Key behavior:** When outputting to blocks, original data types are preserved:

```rebol
result: []
combine/with/into [1 2 3] " " result  ;; => [1 " " 2 " " 3] (mixed types)
```

### /ignore - Custom Type Filtering

Specify which types to ignore:

```rebol
combine/ignore [1 "skip" 2] make typeset! [string!]  ;; => "12"
combine/ignore ["keep" 1 "keep"] make typeset! [integer!]  ;; => "keepkeep"
```

**Important limitation:** The `/ignore` refinement appears to have issues with `none!` values:

```rebol
;; This doesn't work as expected:
combine/ignore [1 none 2] make typeset! [none!]  ;; => "1none2" (should be "12")
```

### `/only` - Preserve Block Structure

Prevents recursive processing of nested blocks:

```rebol
combine [1 [2 3] 4]              ; ;=> "1234" (recursive).
combine/only [1 [2 3] 4]         ;; => "1[2 3]4" (blocks as single values).
```

## Common Patterns & Solutions

### Handling None Values

Since `none` values aren't ignored by default:

```rebol
;; Problem:
combine [1 none 2]               ;; => "1none2"

;; Solution 1: Filter out nones beforehand
clean-data: remove-each item copy [1 none 2] [item = none]
combine clean-data               ;; => "12"

;; Solution 2: Use conditional evaluation
combine [1 (if condition ["value"]) 2]  ;; none from if is ignored
```

### Preserving Type Formatting

To keep type formatting markers:

```rebol
;; Problem:
combine [#{BEEF}]                ;; => "BEEF"

;; Solution: Use mold explicitly
combine [(mold #{BEEF})]         ;; => "#{BEEF}"
```

### Working with Mixed Output Types

```rebol
;; For string output (default):
combine/with [1 2 3] " "         ;; => "1 2 3"

;; For block output with preserved types:
result: []
combine/with/into [1 2 3] " " result  ;; => [1 " " 2 " " 3]

;; For block output with string conversion:
result: []
combine/into [(mold 1) (mold 2) (mold 3)] result  ;; => ["1" "2" "3"]
```

### Complex Data Processing

```rebol
;; Process nested structures with evaluation:
data: [
    "Name: " (user/name)
    " Age: " (user/age)  
    " Items: " [
        (user/item1) ", " (user/item2)
    ]
]
combine data  ;; Evaluates parens and flattens blocks
```

## Best Practices

1. **Test your assumptions** - Has subtle behaviors that differ from the documentation.
2. **Handle none values explicitly** if you need them ignored.
3. **Use /only when you want to preserve block structure**
4. **Remember type formatting is stripped** in string output.
5. **Use /into with blocks** when you need to preserve original datatypes.
6. **Pre-filter data** rather than relying on /ignore for complex filtering needs.

## Performance Notes

* `combine` uses `parse` internally, making it efficient for large datasets.
* Evaluation of parentheses and get-words adds overhead.
* Consider pre-processing data if you have many conditional elements.

## Troubleshooting

**"Why are my `none` values showing up?"**

* `none` values are NOT ignored by default (documentation error).
* Filter them out beforehand or use conditional evaluation.

**"Why did my binary/file/issue formatting disappear?"**

* Type formatting markers are stripped during string conversion.
* Use `mold` explicitly if you need to preserve formatting.

**"Why doesn't `/ignore` work with `none` values?"**

* There appears to be a bug or limitation with `/ignore` and `none` values.
* Use alternative filtering approaches.

**"Why are my delimiters the wrong type in block output?"**

* `/into` with blocks preserves original types, including delimiter type.
* This is intended behavior, not a bug.
