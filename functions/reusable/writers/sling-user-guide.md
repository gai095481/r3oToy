### sling User’s Guide (v0.2.1)

This guide teaches you how to use `sling` to modify Rebol data structures safely and productively. It distills proven behavior from a full QA suite, including subtle nuances discovered during development.

Tested with: Rebol/Bulk 3.19.0 (Oldes Branch)

## Overview
`sling` is a super-setter that modifies data structures in place. It unifies common mutation patterns across `block!`, `map!`, and `object!` and adds:
- `/path` traversal for deeply nested modifications
- `/create` to create missing keys/containers along the way
- Safe, non-erroring behavior on invalid inputs
- `/report` to return whether a change actually occurred

## API
```
USAGE:
  sling data key value
  sling/path data path-block value
  sling/path/create data path-block value

PARAMETERS:
  data   [block! map! object! none!]  ; modified in place
  key    [any-word! integer! decimal! block!]
  value  [any-type!]

REFINEMENTS:
  /path     ; Treat key as a path (a block of steps)
  /create   ; Create missing keys/containers on the path
  /report   ; Return logic! changed? instead of data
```

- Without `/report`, returns the (possibly modified) `data` you passed in; modifies it in place.
- With `/report`, returns a `logic!` indicating whether the operation made a change (`true`) or was a no-op (`false`).
- Never raises errors; invalid operations become no-ops.

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

Security note: Because `/path` may evaluate expressions found immediately after `set-word!`s in blocks, avoid traversing untrusted source blocks. A future `/secure` may restrict evaluation.

## Quick start examples

### Single-level updates
```rebol
; Block by index
blk: [a b c]
sling blk 2 "X"             ; => blk is [a "X" c]

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
  ```

- Targeted post-condition check (without copying the whole structure)
  - Check the specific cell/path you intended to mutate.
  ```rebol
; Single-level
ok?: equal? select mp 'age 31

; Path
ok?: equal? grab/path data ['config 'database 'host] "db.example.com"
  ```

- Optional preflight checks (fast guards)
  - Validate the target exists or `/create` is used before calling `sling`.
  ```rebol
can-block-index?: all [block? blk integer? idx idx >= 1 idx <= length? blk]
can-block-key?:   any [find blk to-set-word 'age create]
can-map?:         any [find mp 'host create]
can-object?:      in obj 'age
  ```

## Behavior reference and nuances
- **In-place modification**: All mutations occur on the original container; without `/report`, the return value is the same reference you passed. With `/report`, a `logic!` is returned.
- **Safe failure**: Invalid container types, unsupported key types, or missing keys without `/create` result in no-ops rather than errors.
- **Blocks with set-words**: If a `set-word!` is present, `sling` will either descend into the literal block that follows, or evaluate the value expression and replace it in place. Best practice: keep these expressions side-effect free.
- **Map traversal**: Creation must happen at the parent. `sling` maintains a parent reference and inserts a new `map!` into the parent when `/create` is used and an intermediate step is missing or not a container.
- **Object traversal**: Only traverses existing fields via `in`/`get`. It does not add fields. To add new fields, construct a new `object!` or extend your type ahead of time.
- **Indices**: Block indices are 1-based. Out-of-bounds, zero, or negative are no-ops.
- **Decimals**: Decimal keys/indices are ignored (no-ops) for blocks/paths.

## Troubleshooting
- **Nothing changed**: Use `/report` to detect a no-op, or verify with a targeted read via `grab`/`grab/path`. Ensure you used `/create` when adding keys/containers.
- **Unexpected results with expressions**: If a `set-word!` is followed by an expression (e.g., `make map! [...]`), it will be evaluated once and replaced. Ensure expressions are idempotent and safe to evaluate.
- **Object fields not created**: This is by design. Create or extend the object’s fields before using `sling`.

## Best practices
- **Prefer words as map keys** for consistency in examples and readability.
- **Be explicit with `/create`** when you expect to add keys or intermediate containers.
- **Use `/report`** if you need to branch logic based on success/failure.
- **Keep traversal expressions simple** behind `set-word!`s to avoid side effects during evaluation.
- **Use `grab` to verify results** after a `sling` operation:
```rebol
grab/path data ['config 'database 'host]
```

## Compatibility and versioning
- Version: `sling` v0.2.1
- Interpreter: Rebol/Bulk 3.19.0
- The QA suite validates the behaviors described above, including nested map creation and block expression handling.