Drawing from the insights gained through our iterative development and debugging process,
here is the comprehensive user documentation for the `find` function, written in GitHub Flavored Markdown for a professional technical audience.

This documentation goes beyond the basic `help` output to include the critical "sharp edges" and idiomatic usage patterns we discovered.

---

# `find`

The `find` function is one of the most fundamental and versatile tools in Rebol for searching within series data. It returns the *position* where a value is found, allowing for powerful chaining and series manipulation.

## Signature

```rebol
find: make action! [[
    {Searches for a value; for series returns where found, else none.}
    series [series! gob! port! bitset! typeset! object! map! none!]
    value [any-type!]
    /part "Limits the search to a given length or position"
        range [number! series! pair!]
    /only "Treats a series value as only a single value"
    /case "Characters are case-sensitive"
    /same {Use "same?" as comparator}
    /any "Enables the * and ? wildcards"
    /with "Allows custom wildcards"
        wild [string!] "Specifies alternates for * and ?"
    /skip "Treat the series as records of fixed size"
        size [integer!]
    /last "Backwards from end of series"
    /reverse "Backwards from the current position"
    /tail "Returns the end of the series"
    /match {Performs comparison and returns the head of the match (not imply /tail)}
]]
```

## Core Concepts

The key to understanding `find` is that it **does not return the value itself**. Instead, it returns a `series!` representing the position (the sub-series) starting from the found element. If no match is found, it returns `none`.

This positional return value is powerful because it can be used directly in other functions (`copy`, `insert`, `remove`, etc.) without needing to calculate an index.

```rebol
data: [a b c d e]

; Find the position of 'c'
position: find data 'c
; position is now [c d e]

; You can now operate on this position
insert position 'X
; data is now [a b X c d e]
```

---

## Refinements

The true power of `find` is unlocked through its refinements.

| Refinement | Description | Example | Results |
| :--- | :--- | :--- | :--- |
| **(default)** | Finds the first occurrence of a value. | `find [a b c a b c] 'b` | **→** `[b c a b c]` |
| `/tail` | Returns the position **after** the found value. | `find/tail [a b c] 'b` | **→** `[c]` |
| `/last` | Searches backwards from the end of the series. | `find/last [a b c a b c] 'b` | **→** `[b c]` |
| `/reverse` | Searches backwards from the **current position**. | `p: at [a b c d] 3` | `find/reverse p 'a'`  **→** `[a b c d]` |
| `/skip` | Treats the series as records of a fixed size, matching only on the first item of each record. | `find/skip [a 1 b 2] 'b 2` | **→** `[b 2]` |
| `/case` | Makes string searches case-sensitive. | `find/case "aBc" "b"` | **→** `none` |
| `/same` | Uses `same?` for comparison instead of `equal?`. | `s: "s"` | `find/same reduce [s] "s"` **→** `none` |
| `/only` | Finds a series as a single value, instead of matching its contents. | `find/only [a [b c] d] [b c]` | **→** `[[b c] d]` |
| `/any` | Enables wildcards (`*` for many, `?` for one) in string searches. | `find/any "abcdef" "a*d?f"` | **→** `"abcdef"` |
| `/part` | Limits the search to a specified length or boundary. | `find/part [a b c d] 'd 3` | **→** `none` |
| `/match`| **Anchored search**; only checks if the series *starts with* the value. | `find/match [a b c] 'a'` | **→** `[a b c]` |

---

## Sharp Edges & Nuances

The behavior of `find` can be non-obvious, especially with certain datatypes and refinements. Understanding these nuances is key to using it effectively.

### 1. `/match` is an Anchored Predicate, Not a Search

This is the most critical nuance. `/match` **does not search** the series. It only checks if the **head** of the series matches the provided value.

* **If it matches:** It returns the **entire original series**, acting like a predicate.
* **If it doesn't match:** It returns `none`.

```rebol
>> find/match [a b c] 'a
== [a b c]  ; Success, returns the whole series

>> find/match [a b c] 'b
== none      ; Failure, because the series does not start with 'b'
```

### 2. Behavior Varies by Datatype

`find` does not treat all series types the same way.

* **`map!`:** Returns the `set-word!` of the key if found, not a position.
    
    ```rebol
    >> data-map: make map! [a 1 b 2]
    >> find data-map 'b
    == b:
    ```
* **`typeset!`:** Returns a `logic!` value (`true` or `false`), not a position.
    
    ```rebol
    >> numeric-types: make typeset! [integer! decimal!]
    >> find numeric-types type? 100
    == true
    ```
* **`path!`:** `find` does not reliably search for string components within a `path!`. The idiomatic way to search a path is to convert it to a `block!` of `word!`s first, or a `string!` to be split.
    
    **The Robust Pattern:**
    
    ```rebol
    path-contains-dir?: function [
        file-path [path!] "The path to inspect."
        dir-name [string!] "The directory name to find."
    ][
        path-parts: to-block file-path
        dir-as-word: to-word dir-name
        not none? find path-parts dir-as-word
    ]
    
    >> path-contains-dir? %/users/rebol/scripts/ 'rebol
    == true
    ```

### 3. `/reverse` is Not `/last`

* `/last` always starts its search from the tail of the series and works backward.
* `/reverse` starts its search from the *current series position* and works backward.

They are only equivalent if the search starts from the tail of the series. Searching backward from the head will always fail.

```rebol
>> series: [a b c]

>> find/last series 'a
== [a b c]

>> find/reverse series 'a
== none  ; Fails because we are at the head, with nothing before it.
```

---

## Practical Usage Patterns

`find` is a building block for many common operations.

* **Parsing Key-Value Data:** Use `find/tail` to locate a delimiter and return the value that follows.
    
    ```rebol
    data: "Host: rebol.com"
    host: find/tail data "Host: "  ; host is now "rebol.com"
    ```
* **Configuration & Metadata:** Use `find` on a block of `word!`s to check for the presence of a configuration flag.
    
    ```rebol
    config: [secure logging verbose]
    if find config 'verbose [print "Verbose mode on"]
    ```
* **Command-Line Argument Parsing:** Use `find/tail` to get the value associated with an option.
    
    ```rebol
    args: ["--input" %data.txt "--mode" "fast"]
    file-to-load: select (find/tail args "--input") 1
    ```
* **Navigating Structured Records:** Use `find/skip` to treat a flat block as a series of fixed-size records and find a record by its first element (e.g., an ID).
    
    ```rebol
    user-db: [101 "Alice" 102 "Bob"]
    user-record: find/skip user-db 102 2  ; user-record is [102 "Bob"]
    ```
* **Input Validation:** Use `find/case` or `find/same` for precise, case-sensitive validation against a whitelist of commands or values.
    
    ```rebol
    valid-cmds: ["COMMIT" "PUSH" "PULL"]
    if find/case valid-cmds user-input [...]
    ```
