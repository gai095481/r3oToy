## CLI Tools

### Square Bracket Analyzer: `find-missing-bracket-approx.r3`
- File: `functions/reusable/tools/find-missing-bracket-approx.r3`
- Purpose: Analyze a `.r3` script and report unmatched `[` or `]`, ignoring brackets in strings and comments. Reports opening bracket locations for missing closers.

#### Usage
```shell
r3 functions/reusable/tools/find-missing-bracket-approx.r3 path/to/script.r3
```
- Exit status: `0` if no unmatched brackets, `1` if errors were reported (unexpected `]` or missing `]`).
- Output:
  - Standard output: success message when no issues.
  - Standard error: detailed error messages and line-context snippets when issues are found.

#### Behavior
- Robust file reading (`read/binary` → `to-string`) with error reporting.
- Tracks line/column; handles `"..."` with escaped quotes, `{...}` with nesting, and `;` comments.
- Stops on first unexpected `]`. At end, reports any remaining unmatched `[` positions.

#### Helper functions (can be reused)
- `eprt the-value-to-write [any-type!] /no-nln` — write to stderr
- `print-error msg [block!]` — formatted stderr print
- `print-usage` — prints usage to stderr
- `is-whitespace-char ch [char!]` — detect whitespace
- `get-line-snippet content-str [string!] target-line [integer!] /context-lines num-context [integer!]` — extract numbered snippet
- `read-text-file file [file!]` — robust text read (string or error!)

Notes:
- The script calls `quit/return` with appropriate exit codes; when embedding as a library, refactor the bottom-level driver to return a value instead.