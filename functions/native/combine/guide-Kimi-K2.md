# Unofficial User's Guide for `combine`

*A test-driven, nuance-aware and novice-friendly guide.*

---

### Overview

The `combine` function walks through a block, turns every value into text (or keeps the original datatype if you use `/into`), and scrunches the pieces together.

```rebol
>> combine [1 "hello" 2.5]
== "1hello2.5"
```

---

### Quick-start Cheat Sheet

| What you want | Call | Result |
|---------------|------|--------|
| Plain concat. | `combine [1 2 3]` | `"123"` |
| Add a space   | `combine/with [1 2 3] " "` | `"1 2 3"` |
| Skip numbers  | `combine/ignore [1 "a" 2 "b"] make typeset! [integer!]` | `"ab"` |
| Keep sub-blocks intact | `combine/only [1 [2 3] 4]` | `"1[2 3]4"` |
| Output into a block | `combine/into [1 2 3] []` | `[1 2 3]` |

---

### Core Behavior (What the REPL Proved)

| Item | Evidence-Based Truth |
|------|----------------------|
| **Empty block** | Returns an empty string or empty target series. |
| **Single value** | Returns its string form; no delimiter added. |
| **Nested blocks** | **Flattened** by default (`[1 [2 3]] → "123"`). |
| **Paren `()`** | **Evaluated** before processing (`(3 + 1) → 4`). |
| **Get-word `:`** | **Evaluated** (`:my-var` → value of `my-var`). |
| **Ignored by default** | `unset!`, `error!`, any-function! (but **NOT `none!`**). |
| **Datatype quirks** | 
Binary `#{}` loses the `#{}` wrapper.
Issue `#abc` loses the `#`.
File `%f` loses `%`.
 |

---

### Refinements – The Complete Map

#### `/with delimiter`

Adds the delimiter **between** items only when more than one item survives filtering.

#### `/into series`

- Writes into any existing series (string, block, tag, …).
- Returns the **same series** for chaining.
- When the target is **any-string!**, values are converted to string; when it is **block!**, original datatypes are kept.
- Pre-existing content is **preserved**.

#### `/ignore typeset`

- Replaces the default ignore list.
- **You must supply a full typeset**: `make typeset! [integer! string!]`.
- `none!` **cannot** be ignored in practice—`combine` still prints `"none"` even if you add `none!` to the set.

**How to properly ignore `none` values**

* `none!` values → converted to string "none".

```rebol
combine/ignore reduce [1 none 2] make typeset! [none!]
;;== "12"

combine/ignore [1 #[none] 2] make typeset! [none!]
;;== "12"

;; This works because get-words are resolved by the `combine` function:
combine/ignore [1 :none 2] make typeset! [none!]
;;== "12"
```

#### `/only`

- Treats an entire sub-block as **one value** instead of flattening it.
- Works together with `/with` and `/into`.

---

### Novice Traps & How to Dodge Them

| Trap | Symptom | Fix |
|------|---------|-----|
| **Expecting `none!` to be skipped** | `"1none2"` appears. | Explicitly filter before calling `combine` or use `exclude` to pre-clean the block. |
| **Nested blocks explode unexpectedly** | `[[a b] [c d]] → "abcd"` | Use `/only` if you want `[[a b][c d]]`. |
| **Delimiter appears before first element** | It never does—`/with` only inserts **between** surviving items. |
| **Binary, issue, file lose sigils** | If you need the original literal form, `mold` the values yourself. |
| **`/ignore` seems to ignore you** | You forgot to build a full typeset: `make typeset! [integer!]`. |


### Idiomatic Patterns

```rebol
;; 1. Safe concat that skips NONE and errors
safe-combine: funct [blk][
    combine/ignore blk make typeset! [none! error! unset! any-function!]
]

;; 2. Build a CSV line
csv-line: funct [row][
    combine/with row ","
]

;; 3. Append into a reusable buffer
buffer: make string! 1000
loop 10 [
    combine/into/with ["chunk"] buffer "-"
]

;; 4. Keep nested structure for JSON-ish output
json-chunks: []
combine/only/into [["a" 1] ["b" 2]] json-chunks
```

### Summary Flowchart

```
Input block
    │
    ├─ Paren? → Evaluate
    ├─ Get-word? → Evaluate
    ├─ Block? → Flatten (unless /only)
    ├─ Ignored type? → Skip (unless overridden)
    │
Combine to string  ← default
    or
Combine/into series
    optionally
/with delimiter
```
