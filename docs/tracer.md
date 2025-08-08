## Tracer and Error Utilities

- File: `functions/tracer/bomb-burst-unwind-and-dprt.r3`
- Load:
  ```rebol
  do %functions/tracer/bomb-burst-unwind-and-dprt.r3
  ```

### Debug verbosity toggles
- Global config object: `gblBlkTypCfgDbgPrt` with field `dvue` (0,1,2)
- Predicates: `dvue0?`, `dvue1?`, `dvue2?`
- Setters: `mkdvue0`, `mkdvue1`, `mkdvue2`

Example:
```rebol
mkdvue2  ;; full debug output
if dvue2? [print "Verbose debug logging enabled"]
```

### `dprt`
- Signature:
  ```rebol
  dprt any-dtype [any-type!] /nln /quoted
  ```
- Description: Conditional debug print with "DEBUG: " prefix when verbosity is level 2. Handles empty values and special-cases `lf`.
- Examples:
  ```rebol
  mkdvue2
  dprt "Hello"
  dprt/quoted "  padded  "
  dprt/nln "line without trailing newline"
  dprt lf  ;; prints a blank line without the DEBUG label
  ```

### Message helpers
- `ErrMsg any-dtype [any-type!] /nln /blank /fatal /plain /thrown`
  - Red background by default. `/blank` prints spacing only. `/fatal` or `/thrown` adjust label.
- `SuccessMsg any-dtype [any-type!] /nln /blank /dvue /plain`
  - Green background. `/dvue` respects verbosity.
- `WarnMsg any-dtype [any-type!] /blank /plain /nln`
  - Yellow foreground.

Examples:
```rebol
ErrMsg "Error happened"
SuccessMsg "Done"
WarnMsg/plain "Heads up"
```

### Function/spec introspection helpers
- `AllFncRft_Blk ptrFncThs [function!]` → block of declared refinements; sets first docstring in `gblObjWarnCfg/desc`.
- `FabPerFncGob_Str strTypNmeFnc [string!] ptrFncThs [function!]` → join function name + refinements (e.g., "sfor/local").

### Warning formatters
- `WarnForTypFncRng strTypNmeFnc [string!] ptrFncThs [function!] aryFoo [series! none!] strTheArgNme [string!] intTypAmtRng [integer!] strThsRblScrFleNme [file! string!]`
- `WarnForDryOreNulFncArgStr strTypNmeFnc [string!] ptrFncThs [function!] anyChkThsArg [bitset! series! none!] strTheArgNme [string!] strThsRblScrFleNme [file! string!]`

Usage sketch:
```rebol
WarnForDryOreNulFncArgStr "MyFunc" :my-func [] "data" %my-script.r3
```

### Error object fabricators and printers
- `ArgBomb wrdTypIduErr [word!] strTypNmeFnc [block! string!] strTypNmeArgForFnc [string!] strArgVal [string!] strTypCueArg [string!]` → `error!`
- `ArgBurst errObject [error!]` → formatted dump via `ErrMsg`
- `CmdBomb wrdTypIduErr [word!] strTypNmeCmd [block! string!] strTypNmeArgForCmd [string!] strArgVal [string!] strTypCueArg [string!]` → `error!`
- `CmdBurst errObject [error!]` → formatted dump via `ErrMsg`

Example:
```rebol
err: ArgBomb 'no-value ["Fn" "arg"] "Missing" {""} "1st"
ArgBurst err
```

Notes:
- The script also includes demo functions `FncSimCall_1`, `FncSimCall_2` and `BombBurst_RunQac_*` for QA; treat them as examples rather than API.