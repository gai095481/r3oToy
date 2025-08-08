## Looping and Block Helpers

### `sfor` (safe-for loop)
- File: `loops/sfor-safe-for-contruct.-and-test-harness.r3`
- Load:
  ```rebol
  do %loops/sfor-safe-for-contruct.-and-test-harness.r3
  ```
- Signature:
  ```rebol
  sfor 'loopIndex [lit-word!] startValue [number!] endValue [number!]
       stepValue [number!] bodyBlock [block!]
       /tolerance epsilonValue [decimal!]
  ```
- Description: Robust replacement for `for` handling scope, zero-step protection, and floating-point precision. Restores the caller's `loopIndex` after completion. Returns `unset!` or an `error!` on invalid step.
- Examples:
  ```rebol
  sfor 'i 1 5 1 [print i]             ;; 1..5
  sfor 'i 5 1 -1 [print i]            ;; 5..1
  sfor 'x 0.5 2.5 0.5 [print x]
  sfor/tolerance 'x 1.0 1.3 0.1 0.01 [print round/to x 0.01]

  ; Scope safety
  i: 100
  sfor 'i 1 3 1 [print i]
  print i                              ;; 100 (restored)

  ; Zero-step error
  err: sfor 'i 5 5 0 []                ;; make error! [type: 'User id: 'message ...]
  ```

### `retrieve-block-item-via-index`
- File: `loops/blocks/retrieve-block-item-via-index.r3`
- Load:
  ```rebol
  do %loops/blocks/retrieve-block-item-via-index.r3
  ```
- Signature:
  ```rebol
  retrieve-block-item-via-index block-data [block! none!] index [integer!]
      /default default-value [any-type!]
  ```
- Description: Safely fetch the element at a 1-based `index` from a `block!`. Returns `none` or `default-value` for invalid/missing cases.
- Example:
  ```rebol
  row: ["name" "desc" 123]
  retrieve-block-item-via-index row 3        ;; 123
  retrieve-block-item-via-index/default none 2 "N/A"   ;; "N/A"
  ```

Notes:
- `retrieve-block-item-via-index` includes a demo procedure in the script which prints sample output. Treat it as an example.