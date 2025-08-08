## Output Utilities

### `eprt`
- File: `output/eprt-to-write-to-stderr.r3`
- Signature:
  ```rebol
  eprt the-value-to-write [any-type!] /no-nln
  ```
- Description: Write any value to stderr (`/dev/stderr`). Appends a newline by default; use `/no-nln` to suppress.
- Example:
  ```rebol
  do %output/eprt-to-write-to-stderr.r3
  eprt "Something went to stderr"
  eprt/no-nln "Prompt: "
  ```

### `bprt`
- File: `output/bprt-an-alias-to-output-blank-lines.r3`
- Signature:
  ```rebol
  bprt  ;; same as: does [prin lf]
  ```
- Description: Print a blank line to stdout.
- Example:
  ```rebol
  do %output/bprt-an-alias-to-output-blank-lines.r3
  print "Header"
  bprt
  print "Body after blank line"
  ```

### `stylize`
- File: `output/text-output-stylizer-via-ANSI-control-codes.r3`
- Signature:
  ```rebol
  stylize text-hue [word! none!] the-text-to-stylize [any-type!]
      /blink /bold /invert /struck /underlined
  ```
- Description: Wrap a value with ANSI codes using a named base color and optional style modifiers. Returns a styled string plus a final reset-to-plain code.
- Colors: keys from `gbl-map-text-opts` (e.g., `plain, alert, blue, cyan, green, red, sky, yellow, ...`).
- Example:
  ```rebol
  do %output/text-output-stylizer-via-ANSI-control-codes.r3
  print rejoin [stylize/bold 'green "OK" " - Operation succeeded"]
  print rejoin [stylize/invert 'warn "CAUTION"]
  print rejoin [stylize 'blue "Note"]
  ```

### `hue-datatype`
- File: `output/text-output-stylizer-via-ANSI-control-codes.r3`
- Signature:
  ```rebol
  hue-datatype the-datatype-to-colorize [any-type!]
  ```
- Description: Colorize a value based on its datatype. Uses `stylize` internally.
- Example:
  ```rebol
  do %output/text-output-stylizer-via-ANSI-control-codes.r3
  print hue-datatype 42
  print hue-datatype 3.14
  print hue-datatype [1 "a" 3]
  print hue-datatype error make error! [type: 'script id: 'no-value]
  ```

Notes:
- The stylizer script defines global maps/constants: `gbl-map-text-opts`, `as-plain`, etc. Load once per process.