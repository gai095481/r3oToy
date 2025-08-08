## Search Utilities

### `sfind` — Safe Find Wrapper
- File: `functions/reusable/search/sfind.r3`
- Load:
  ```rebol
  do %functions/reusable/search/sfind.r3
  ```
- Signature:
  ```rebol
  sfind data [block! map!] target /key /value
  ```
- Description: Type-agnostic key/value search that returns consistent results for both `block!` and `map!` containers.

#### Return conventions
- `/key` mode:
  - For `block!` of pairs `[k1 v1 k2 v2 ...]` returns `[key: value]` (2-element copy)
  - For `map!` returns `[key value]`
  - Returns `none` when not found
- `/value` mode:
  - For `block!` and `map!`, returns the matched value itself (not the pair)
  - Uses strict type and value equality; logic values are matched by type
  - Returns `none` when not found
- Errors:
  - Raises error if called without `/key` or `/value`
  - Raises error for odd-length blocks in key/value pair mode

#### Examples
```rebol
blk: [name "Alice" active true level 10 config none]
mp: make map! [name: "Alice" active: true level: 10 config: none]

sfind/key blk 'level          ;; => [level: 10]
sfind/key mp 'level           ;; => [level 10]

sfind/value blk true          ;; => true
sfind/value mp none           ;; => none

; Not found
sfind/key blk 'missing        ;; => none
sfind/value mp "Bob"          ;; => none
```

Notes:
- The file includes a test runner; use as reference. For embedding, keep only the `sfind` definition.