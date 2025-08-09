### Development History: `sling` Super-Setter (v0.2.2)

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
 
- Problem: Test Case Failing

    **The "Gotcha": `make` Does Not `reduce`!**
    
    The root of the entire problem was a misunderstanding of how Rebol's `make` constructor works with blocks.
    
    * **The Behavior:** When you use `make map! [...]` or `make object! [...]`, the constructor processes the block literally. It does **not** evaluate expressions within the block. It simply takes a key and then the *next literal value* as its corresponding value.
    * **The Buggy Code:** `sec-map: make map! [conf: make map! [port: 80]]`
      Here's what Rebol does:
      1. It sees the `set-word!` `conf:` and uses the `word!` `'conf` as the key.
      2. It then looks for the value, which is the **very next literal item** in the block: the `word!` `'make`.
      3. The rest of the block, `[map! [port: 80]]`, is ignored.
      4. The result was `make map! [conf 'make]`, which was completely wrong.
    * **The Solution (`reduce`):** To build structures from evaluated expressions, you must use `reduce`. `sec-map: make map! reduce ['conf make map! [port: 80]]`
      Here, `reduce` first evaluates the block `['conf make map! [port: 80]]`. The `make map!` expression is executed, and `reduce` produces a new block containing the literal word `'conf` followed by the actual inner map object. This new, reduced block is then passed to the outer `make map!`, which can now construct the map correctly.
    
    This is a critical distinction and a powerful feature, as it allows for very precise control over evaluation, but it is certainly an unintuitive quirk for the uninitiated. It underscores the Rebol philosophy that "code is data," but also highlights that you need to be explicit about when you want that data to be treated as code (by using `reduce`, `do`, etc.).
    
    The key fix was indeed in the **test data definition** for the `sec-map` test case:
    
    ```rebol
    sec-map: make map! reduce ['conf make map! [port: 80]]
    ```
    
    By using `reduce`, the key `'conf` is correctly evaluated and used as a word key when creating the `sec-map`. This ensures the subsequent `sling/path/secure/report` call can successfully find and operate on the nested map using the word key `'conf`, thus making the `Secure/Map: Word key allowed.` test case pass.
    
    The problem was simply the test data was not constructed in a way that matched the function's expectations for that specific test scenario.  The fix was purely in the test setup.
    
    The core problem was indeed the misunderstanding of how `make map! [...]` handles its argument block. As described:
    
    1. **The Gotcha:** `make` does *not* automatically `reduce` its argument. It takes the block literally.
    2. **The Buggy Code Analysis:** `sec-map: make map! [conf: make map! [port: 80]]`
        * `make map!` sees the key `conf:`.
        * It takes the *next item* in the block as the value, which is the word `'make`.
        * The subsequent `map! [port: 80]` is effectively ignored in the context of creating the value for `'conf`. This resulted in a map like `make map! [conf: make]`, which is clearly not the intended nested structure.
    3. **The Solution:** Using `reduce` forces the evaluation of the expression within the block *before* `make map!` processes it.
        * `reduce ['conf make map! [port: 80]]` first evaluates `'conf` (stays `'conf`) and `make map! [port: 80]` (creates the map object).
        * This results in a new block like `['conf <the-actual-map-object>]`.
        * `make map!` then correctly uses `'conf` as the key and the newly created map object as the value.
    
    This is a fundamental and often confusing aspect of Rebol for newcomers, highlighting the explicit control over evaluation (`reduce`, `do`, etc.) that the language provides. The successful resolution of the `❌ FAILED: Secure/Map: Word key allowed.` test by using `make map! reduce ['conf make map! [port: 80]]` confirms this understanding.

---

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
