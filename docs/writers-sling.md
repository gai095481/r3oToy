## Data Writers and Accessors (`sling` suite)

- File: `functions/reusable/writers/sling.r3`
- Load:
  ```rebol
  do %functions/reusable/writers/sling.r3
  ```

### `grab`
- Signature:
  ```rebol
  grab data [any-type!] key [any-word! string! integer! decimal! block!]
       /path /default default-value [any-type!]
  ```
- Description: Safe retrieval from `block!` or `map!`, with optional path traversal and defaulting. Never throws; returns `none` or default on failure.
- Notes:
  - For `block!` with integer index: normalizes `none true false` words to actual values.
  - `decimal!` keys and `block!` keys (non-path mode) return `none`/default.
  - Path mode expects a block of steps, each a key or index.
- Examples:
  ```rebol
  data: [name: "Alice" age: 25]
  grab data 'age                ;; 25
  grab data 100                 ;; none
  grab/default data 100 "NA"    ;; "NA"

  nest: [cfg: [port: 8080]]
  grab/path nest ['cfg 'port]   ;; 8080
  ```

### `grab-item`
- Signature:
  ```rebol
  grab-item key-string [string!] index [integer!]
  ```
- Description: Find a record in `system-items` whose first element equals `key-string` and return the `index`th element via `grab`.
- Example:
  ```rebol
  system-items: [["system/version" "desc" system/version]]
  grab-item "system/version" 3  ;; system/version
  ```

### `sling`
- Signature:
  ```rebol
  sling data [block! map! object! none!] key [any-word! integer! decimal! block!] value [any-type!]
        /path /create
  ```
- Description: Safe, robust setter for `block!`, `map!`, or `object!`. Can traverse paths (`/path`) and create missing keys (`/create`). Returns the original `data` (modified in place when applicable).
- Behavior highlights:
  - Non-path mode:
    - Block + integer index within bounds → `poke`.
    - Block + word key → set if exists; with `/create`, append new `set-word` and value.
    - Map → `put` if key exists; with `/create`, add the key.
  - Path mode:
    - Walk intermediate containers (blocks or maps). With `/create`, missing steps are created as empty `map!` or appended block pairs.
- Examples:
  ```rebol
  blk: [name: "Alice" age: 25]
  sling blk 'age 30                ;; [name: "Alice" age: 30]
  sling/create blk 'city "Boston"  ;; [name: "Alice" age: 30 city: "Boston"]

  cfg: [config: [port: 8080 database: make map! [host: "localhost"]]]
  sling/path cfg ['config 'port] 9090
  grab/path cfg ['config 'port]   ;; 9090
  sling/path/create cfg ['config 'database 'host] "db.example.com"

  mp: make map! [a: 1]
  sling mp 'a 2
  sling/create mp 'b 3
  ```

Notes:
- The script includes QA tests (`assert-equal`, `print-test-summary`) which are helpers, not part of the public API.