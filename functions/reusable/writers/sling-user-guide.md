### sling User's Guide (v0.2.2)

This guide teaches you how to use `sling` to modify Rebol data structures safely and productively. It distills proven behavior from a full QA suite, including subtle nuances discovered during development.

Tested with: Rebol/Bulk 3.19.0 (Oldes Branch)

## Overview
`sling` is a super-setter that modifies data structures in place. It unifies common mutation patterns across `block!`, `map!`, and `object!` and adds:
- `/path` traversal for deeply nested modifications
- `/create` to create missing keys/containers along the way
- Safe, non-erroring behavior on invalid inputs
- `/report` to return whether a change actually occurred
- `/strict` for fail-fast error handling when no change occurs
- `/secure` for hardened path traversal with restricted evaluation

## API
```
USAGE:
  sling data key value
  sling/path data path-block value
  sling/path/create data path-block value
  sling/report data key value
  sling/strict data key value
  sling/secure data key value
  sling/path/create/report data path-block value
  sling/path/secure/strict data path-block value

PARAMETERS:
  data   [block! map! object! none!]  ; modified in place
  key    [any-word! integer! decimal! block!]
  value  [any-type!]

REFINEMENTS:
  /path     ; Treat key as a path (a block of steps)
  /create   ; Create missing keys/containers on the path
  /report   ; Return logic! changed? instead of data
  /strict   ; Fail-fast: raise an error if no change occurs (no-op)
  /secure   ; Harden path traversal (no evaluation; restrict steps to safe types)
```

- Without `/report`, returns the (possibly modified) `data` you passed in; modifies it in place.
- With `/report`, returns a `logic!` indicating whether the operation made a change (`true`) or was a no-op (`false`).
- With `/strict`, raises an error if the operation was a no-op instead of silently continuing.
- With `/secure`, restricts path traversal to safe operations without expression evaluation.
- Never raises errors in default mode; invalid operations become no-ops.

## Supported containers and keys
- `block!`
  - Integer index (1-based): `poke` at index; out-of-bounds is a no-op.
  - Word key (set-word layout): replaces the value for the corresponding `set-word!` if present; appends key/value if `/create` is used.
- `map!`
  - Word (or other) keys: `put` sets existing keys. With `/create`, missing keys are created.
- `object!`
  - Word field names: sets existing fields. Field creation is not automatic (no `/create` for objects).

Notes:
- Decimal indices/keys are not supported for blocks/paths; treated as no-ops.
- Negative or zero indexes are no-ops.
- Negative indices for `block!` are supported: -1 is last, -2 second-to-last, …, -len is first. Out-of-bounds negatives are no-ops. Negative indices do not trigger growth even with `/create`.

## Path traversal (/path)
A path is a `block!` of steps. Each step navigates one level deeper:
- Into `block!`:
  - Integer step: select positional element.
  - Word step: select the value following a matching `set-word!`.
- Into `map!`:
  - Step is used as a map key (commonly a `word!`).
- Into `object!`:
  - Step must be a `word!` naming an existing field.

With `/create`, missing map keys and missing block `set-word!` pairs are created; missing intermediate containers are created as empty maps when needed.

Important nuance (blocks with expressions):
- If a `set-word!` is followed by an expression (e.g., `database: make map! [host: "localhost"]`), `sling` evaluates that expression one time during traversal, replaces the expression span in-place with its evaluated result, then continues traversal using the live container. This ensures that subsequent steps modify the actual structure, not a literal expression.

Security note: Because `/path` may evaluate expressions found immediately after `set-word!`s in blocks, avoid traversing untrusted source blocks. Use `/secure` to disable expression evaluation for enhanced security.

## Secure Mode (/secure)
The `/secure` refinement hardens path traversal by:
- **Disabling expression evaluation**: Expressions after `set-word!`s in blocks are not evaluated
- **Restricting step types**: Only `word!` steps are allowed for maps and objects
- **Type safety**: Prevents potential code injection through path traversal

### Secure mode behavior:
- **Blocks**: Only allows word steps for key-based access; no expression evaluation
- **Maps**: Only allows word keys (converted via `to word!` if needed)
- **Objects**: Only allows word field names

### When to use `/secure`:
- Processing untrusted data structures
- Security-critical applications
- When expression evaluation poses risks
- Automated/batch processing of external data

### Secure mode examples:
```rebol
; Safe traversal of untrusted data
untrusted-data: [config: make map! [host: "localhost"]]
sling/path/secure untrusted-data ['config 'host] "safe.example.com"

; Secure mode rejects non-word steps
secure-map: make map! [config: make map! [port: 80]]
sling/path/secure/report secure-map ['config 1] 90        ; => false (rejected)
sling/path/secure/report secure-map ['config 'port] 81    ; => true (allowed)
```

## Strict Mode (/strict)
The `/strict` refinement changes `sling`'s error handling from silent no-ops to fail-fast errors:
- **Default behavior**: Invalid operations are silent no-ops
- **Strict behavior**: Invalid operations raise errors immediately

### When strict mode raises errors:
- Out-of-bounds indices
- Missing keys without `/create`
- Invalid container types
- Type mismatches in secure mode

### Strict mode examples:
```rebol
; Default: silent no-op
blk: [a b c]
sling blk 5 "X"                    ; => [a b c] (no change, no error)

; Strict: raises error
sling/strict blk 5 "X"             ; => Error: "sling: no change"

; Useful for validation
try [
    sling/strict data key value
    print "Success: value was set"
] [
    print "Failed: operation was invalid"
]
```

### Error handling patterns with strict mode:
```rebol
; Guard pattern
if all [block? data integer? idx idx >= 1 idx <= length? data] [
    sling/strict data idx value
]

; Try/catch pattern  
result: try [sling/path/strict/report data path value]
either error? result [
    print "Operation failed"
] [
    if result [print "Change successful"]
]
```

## Quick start examples

### Single-level updates
```rebol
; Block by index
blk: [a b c]
sling blk 2 "X"             ; => blk is [a "X" c]
; Negative indexing
sling blk -1 "Z"             ; => blk is [a "X" "Z"] (last)
sling blk -2 "Y"             ; => blk is [a "Y" "Z"] (second-to-last)
sling blk -5 "X"             ; => no-op (out-of-bounds)

; Block by key
blk: [name: "Alice" age: 25]
sling blk 'age 30            ; => [name: "Alice" age: 30]
sling/create blk 'city "LA"   ; => [name: "Alice" age: 30 city: "LA"]

; Map
mp: make map! [name: "Alice" age: 25]
sling mp 'age 31             ; => select mp 'age is 31
sling mp 'city "Paris"        ; no-op (no /create)
sling/create mp 'city "Paris" ; creates key 'city

; Object (existing fields only)
obj: make object! [name: "Alice" age: 25]
sling obj 'age 32            ; => obj/age is 32
sling obj 'city "LA"          ; no-op (field does not exist)
```

### Nested updates with /path
```rebol
; Nested block + map
data: [
  config: [
    port: 8080
    database: make map! [host: "localhost"]
  ]
  rows: [1 2 3 4]
]

; Set nested port
sling/path data ['config 'port] 9090
; => grab/path data ['config 'port] is 9090

; Set nested map key
sling/path data ['config 'database 'host] "db.example.com"
; => grab/path data ['config 'database 'host] is "db.example.com"

; Create a missing key under a nested block
sling/path/create data ['config 'debug] true
; => grab/path data ['config 'debug] is true

; Negative indexing inside a path
sling/path data ['rows -1] 99
; => grab/path data ['rows 4] is 99

; Secure traversal (no expression evaluation)
sling/path/secure data ['config 'database 'host] "secure.example.com"

; Strict mode with error on failure
assert sling/path/strict/report data ['config 'port] 8081
```

### Creating missing intermediate containers
```rebol
; When a step under a map is missing or not a container,
; /create will allocate an empty map at that step.
mp: make map! [config: make map! [a: 1]]
sling/path/create mp ['config 'b] 2
; => grab/path mp ['config 'b] is 2
```

### Mixed container paths
```rebol
sys: [
  users: [
    first: make map! [name: "Ann" meta: make map! []]
  ]
]

sling/path sys ['users 'first 'meta 'active] true  ; no-op (no /create)
sling/path/create sys ['users 'first 'meta 'active] true
; => grab/path sys ['users 'first 'meta 'active] is true
```

## Detecting no-ops and confirming success (no copying required)
Because `sling` is non-erroring by design, use one of the following methods to know if a call had any effect:

- Use `/report` (simplest)
  - Returns `true` if a change occurred, `false` if it was a no-op.
  ```rebol
changed?: sling/report blk 'age 30
changed?: sling/path/report data ['config 'port] 9090
changed?: sling/path/create/report mp ['config 'b] 2
changed?: sling/path/secure/report data ['config 'host] "safe.com"
  ```

- Use `/strict` for fail-fast behavior
  - Raises an error if no change occurs instead of returning false
  ```rebol
; Will error if idx is out of bounds
sling/strict blk idx value

; Combine with /report for both error handling and change detection
try [
    changed?: sling/path/strict/report data path value
    if changed? [print "Successfully updated"]
]
  ```

## Behavior reference and nuances
- **In-place modification**: All mutations occur on the original container; without `/report`, the return value is the same reference you passed. With `/report`, a `logic!` is returned.
- **Safe failure**: Invalid container types, unsupported key types, or missing keys without `/create` result in no-ops rather than errors (unless `/strict` is used).
- **Strict mode**: With `/strict`, operations that would normally be no-ops raise errors instead.
- **Secure mode**: With `/secure`, path traversal is hardened against expression evaluation and type-based attacks.
- **Blocks with set-words**: If a `set-word!` is present, `sling` will either descend into the literal block that follows, or evaluate the value expression and replace it in place (unless `/secure` is used). Best practice: keep these expressions side-effect free.
- **Map traversal**: Creation must happen at the parent. `sling` maintains a parent reference and inserts a new `map!` into the parent when `/create` is used and an intermediate step is missing or not a container.
- **Object traversal**: Only traverses existing fields via `in`/`get`. It does not add fields. To add new fields, construct a new `object!` or extend your type ahead of time.
- **Indices**: Block indices are 1-based for positive integers. Negative indices are supported for reverse indexing (-1 last, -2 second-to-last, …). Out-of-bounds negatives and zero are no-ops. Negative indices never trigger growth; use positive indices with `/create` to extend.
- **Decimals**: Decimal keys/indices are ignored (no-ops) for blocks/paths.

## Troubleshooting
- **Nothing changed**: Use `/report` to detect a no-op, or verify with a targeted read via `grab`/`grab/path`. Ensure you used `/create` when adding keys/containers.
- **Need fail-fast behavior**: Use `/strict` to convert silent no-ops into errors.
- **Security concerns with expressions**: Use `/secure` to disable expression evaluation during path traversal.
- **Unexpected results with expressions**: If a `set-word!` is followed by an expression (e.g., `make map! [...]`), it will be evaluated once and replaced (unless `/secure` is used). Ensure expressions are idempotent and safe to evaluate.
- **Object fields not created**: This is by design. Create or extend the object's fields before using `sling`.

## Best practices
- **Prefer words as map keys** for consistency in examples and readability.
- **Be explicit with `/create`** when you expect to add keys or intermediate containers.
- **Use `/report`** if you need to branch logic based on success/failure.
- **Use `/strict`** when you need fail-fast behavior instead of silent no-ops.
- **Use `/secure`** when processing untrusted data or when security is a concern.
- **Keep traversal expressions simple** behind `set-word!`s to avoid side effects during evaluation.
- **Combine refinements appropriately**: `/path/create/report` for comprehensive nested operations, `/path/secure/strict` for security-critical fail-fast operations.
- **Use `grab` to verify results** after a `sling` operation:
```rebol
grab/path data ['config 'database 'host]
```

## Security considerations
- **Expression evaluation risk**: By default, `sling` may evaluate expressions found after `set-word!`s during path traversal
- **Untrusted data**: Never use default path traversal on untrusted data structures without `/secure`
- **Safe patterns**:
  - Use `/secure` for all external/untrusted data processing
  - Validate data structures before traversal when possible
  - Prefer literal values over expressions in set-word pairs
  - Use `/strict` to catch unexpected failures early

## Testing and quality assurance
- **Comprehensive test suite**: The `sling` implementation includes a 200+ line QA test harness with 5 distinct test phases
- **Test coverage**: All refinement combinations, edge cases, and error conditions are validated
- **Regression testing**: The test suite validates subtle behaviors like negative indexing, expression evaluation, and type normalization
- **Interpreter compatibility**: Tested with Rebol/Bulk 3.19.0 (Oldes Branch)

## Compatibility and versioning
- Version: `sling` v0.2.2
- Interpreter: Rebol/Bulk 3.19.0
- The QA suite validates the behaviors described above, including nested map creation, block expression handling, secure mode restrictions, and strict mode error handling.

## Ergonomic wrapper for boolean-first style
Add a small alias that defaults to reporting success:
```rebol
; sling? behaves like sling but returns logic! changed? by default
sling?: func [
  data [block! map! object! none!]
  key  [any-word! integer! decimal! block!]
  value [any-type!]
  /path /create /strict /secure
][
  sling/:path/:create/:strict/:secure/report data key value
]
```
Usage examples:
```rebol
assert sling?/path/create data ['config 'db 'host] "db.example.com"
if sling?/secure data 'flag true [render data]
try [sling?/strict data key value]
```

## Safer chaining patterns
Chaining can hide no-ops unless you check for success. Use one of these patterns when a change is required:
- **Gate downstream work with `/report`**
  ```rebol
if sling/path/create/report data ['config 'port] 9090 [
  render data
]
  ```
- **Use `/strict` for fail-fast behavior**
  ```rebol
try [
  sling/path/strict data ['config 'port] 9090
  render data
] [
  print "Failed to set configuration"
]
  ```
- **Combine `/secure` and `/strict` for security-critical operations**
  ```rebol
try [
  sling/path/secure/strict data path value
  print "Secure update successful"
] [
  print "Secure update failed - invalid operation"
]
  ```
- **Preflight guards (fast checks before calling)**
  ```rebol
all [block? blk integer? i i >= 1 i <= length? blk]              ; block index
any [find blk to-set-word 'k create]                             ; block key
any [find mp 'k create]                                          ; map key
in obj 'field                                                    ; object field
  ```
- **Post-condition asserts (critical writes)**
  ```rebol
assert equal? grab/path data ['config 'database 'host] "db.example.com"
  ```
- **Optional strict wrapper (fail-fast)**
  ```rebol
sling-strict: func [data key value /path /create /secure][
  if not sling/:path/:create/:secure/report data key value [
    cause-error 'user 'message "sling: no change"
  ]
  data
]
  ```