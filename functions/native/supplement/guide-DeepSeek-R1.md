## Unofficial `supplement` Function Guide


### Overview

`supplement` conditionally appends values to a block if they're not found. It always returns the original head position of the block.

Key characteristics:

- **Modifies input blocks** directly
- **Returns original head** regardless of changes
- **Block arguments** are treated as subsequence patterns
- **Case-sensitivity** available via `/case` refinement
- **Special values** (`true`, `none`) are stored as `#(true)`, `#(none)`
  
 ### Core Behavior


1. **Value Handling**
   Appends any datatype if not present:
   
   ```rebol
   b: [a b] 
   supplement b 'c  ;; => [a b c]
   supplement b 'b  ;; => [a b] (no change)
   ```
2. **Pattern Matching**
   Blocks are treated as subsequence patterns, not single elements:
   
   ```rebol
   b: [1 2 3]
   supplement b [2 3]  ;; No append (subsequence exists)
   supplement b [4 5]  ;; Appends elements: [1 2 3 4 5]
   ```
3. **Return Value**
   Always returns original head position:
   
   ```rebol
   b: [x y]
   head? supplement b 'z  ;; => true (even after append)
   ```

### Refinements

`/case` - Enables case-sensitive comparison for strings:

```rebol
b: ["Apple"]
supplement b "apple"     ;; Appends (case-insensitive)
supplement/case b "apple" ;; Appends
supplement/case b "Apple" ;; No append
```

### Special Values

Handle logic/none values carefully:

```rebol
b: [#(true)]
supplement b true   ;; No append (matches #(true))
supplement b false  ;; Appends #(false)

b: []
supplement b none   ;; Appends #(none)
```

### Common Pitfalls & Solutions

1. **Unexpected Block Expansion**
   *Problem:* Blocks append as individual elements
   *Solution:* Wrap in additional block for single element:
   
   ```rebol
   ;; To append nested block:
   b: []
   supplement b reduce [ [1 2] ]  ;; => [[1 2]]
   ```
2. **Case-Sensitivity Confusion**
   *Problem:* String matching ignores case by default
   *Solution:* Use `/case` when needed:
   
   ```rebol
   supplement/case ["A"] "a"  ;; Appends
   ```
3. **Special Value Representation**
   *Problem:* `true` becomes `#(true)` in blocks
   *Solution:* Use consistent comparison:
   
   ```rebol
   find block #(true)  ;; Correct way to locate
   ```
4. **Position Tracking**
   *Problem:* Return value doesn't reflect new elements
   *Solution:* Capture tail separately:
   
   ```rebol
   b: [1 2]
   tail-pos: tail b
   supplement b 3
   tail-pos  ;; => [3] (position after append)
   ```

### Edge Case Handling

| Case | Behavior | Example |
|------|----------|---------|
| **Empty block** | Accepts first value | `supplement [] 'a → [a]` |
| **Duplicate values** | First occurrence prevents append | `supplement [a a] 'a → no change` |
| **Mixed datatypes** | Never match equivalent values | `supplement [1] "1" → appends` |
| **Zero-length patterns** | Always "found" (no append) | `supplement [x] [] → no change` |

### Best Practices

1. **Clone blocks** before supplementing if original must be preserved:
   
   ```rebol
   safe-supplement: func [b val] [
       supplement copy b val
   ]
   ```
2. **Use explicit types** for clarity:
   
   ```rebol
   supplement [1] to-integer "2"  ;; Better than supplement [1] "2"
   ```
3. **Combine with `find`** for position checks:
   
   ```rebol
   unless find block value [append block value]
   ;; Equivalent to supplement but returns insertion point
   ```

### Real-World Examples

**Case-insensitive string collection:**

```rebol
unique-words: []
foreach word ["Apple" "apple" "BANANA"] [
    supplement unique-words word
]
;; => ["Apple" "BANANA"] (only one "apple" variant)
```

**Pattern-based security rules:**

```rebol
forbidden-patterns: [
    [delete "system" *]
    [format "rm" -rf]
]

rule-check: funct [cmd [block!]][
    foreach pattern forbidden-patterns [
        if find cmd pattern [return "Blocked!"]
    ]
    supplement allowed-commands cmd
    "OK"
]
```

**Safe value initialization:**

```rebol
defaults: [
    timeout: 30
    retries: 3
]

apply-settings: func [config [block!]][
    foreach [k v] defaults [
        supplement config reduce [k v]
    ]
]
```

### Conclusion

`supplement` provides efficient "append-if-missing" functionality with these key nuances:

- Use `/case` for case-sensitive string operations
- Blocks are **always** treated as subsequence patterns
- Special values require `#( )` syntax for matching
- Return value maintains original head position

When in doubt, remember:

> "Patterns expand, cases matter and heads never move."


