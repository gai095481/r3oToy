### Development History: `sling` Super-Setter (v0.2.1)

#### Timeline Highlights
- Initial architecture: single `sling` function, then briefly split into `sling` (path orchestrator) and `set-in` (single-level worker); reverted to a single function after complexity and instability.
- Early blockers: nested `/path` modification failed to maintain a live reference into containers, especially with `map!`.
- Stabilization phase: added comprehensive QA; installed Rebol/Bulk 3.19.0 and drove fixes via failing tests.

#### Key Problems Encountered and Resolutions
- Problem: Using `grab` as a traversal helper for a setter caused value copying/normalization and loss of references.
  - Resolution: Avoid `grab` during set operations. Traverse containers directly and maintain a `parent` reference when needed (especially for `map!`).

- Problem: Traversing block key-value pairs where a `set-word!` is followed by an expression (e.g., `database: make map! [...]`). Simply selecting the next value could yield literal blocks or alias expressions leading to duplication and stale values.
  - Resolution: If the immediate value after a `set-word!` is a literal `block!`, descend directly. Otherwise, evaluate the value expression up to the next top-level `set-word!` and replace the entire expression span in-place using `change/part`. Continue traversal using the evaluated result. This eliminated duplicate entries and ensured correct live containers.

- Problem: Map path traversal with `/create` attempted to mutate a selected child that did not exist or was not a container, resulting in no-ops or incorrect structures.
  - Resolution: Always keep a reference to the `parent` map, compute `selected: select parent step`, and when `/create` is active and `selected` is missing or not a container, `put` a new empty map into the parent at `step`. Then re-select and continue traversal.

- Problem: Object handling was unspecified and missing.
  - Resolution: Implemented `object!` support. For single-level sets, `put` existing fields; for `/path` steps on objects, use `in` to locate bound words and `get` to traverse into values. Field creation remains out of scope.

- Problem: Heuristic creation behavior in final map set linked to value shape (`[]`).
  - Resolution: Removed heuristics. Final map assignment now simply sets existing keys or creates the key when `/create` is active.

#### Testing and Tooling
- Adopted a QA-first approach, running the test suite via Rebol/Bulk 3.19.0 to validate changes end-to-end.
- Added targeted debug prints temporarily to inspect container types and structures, then removed once stabilized.

#### Post-Stabilization Updates (2025-08-08)
- Added `/report` refinement to `sling` that returns a `logic!` indicating whether a change occurred, preserving default behavior when not used.
- Updated documentation: user’s guide, PRD, project status; added development history.
- Repository hygiene: removed interpreter binary from version control and added ignore rules to prevent accidental inclusion in PRs.
- Re-ran the full QA suite on Rebol/Bulk 3.19.0 after these changes: all tests passed.
- Implemented negative indexing for `block!` (single-level and `/path`): `-1` last, `-2` second-to-last, etc. Negative indices do not trigger growth, preserving creation semantics.
- Added targeted QA for negative indexing and documented the behavior in the user’s guide.

#### Lessons Learned
- Maintain parent references when mutating nested associative structures; creation must occur at the parent, not the selected child.
- When parsing block layouts, replace entire expression spans after `set-word!` to avoid desynchronization and duplicate entries.
- Keep setters and getters separate; retrieval helpers that normalize values can be harmful in write paths.
- Favor explicit returns and non-erroring flows for robust library code.
- Expose an explicit status channel (e.g., `/report`) so callers can detect no-ops without comparing whole structures.

#### Future Improvements
- Add richer test coverage for `object!` traversal, negative cases, and edge datatypes.
- Remove remaining `'else` in `case` branches and standardize on preferred style.
- Consider explicit handling or removal of `decimal!` keys in `sling`’s spec.
- Explore `/secure` refinement once core functionality remains stable over time.
- Optional `/strict` refinement that errors on missing targets or invalid steps (opt-in), complementing the default no-op safety.
