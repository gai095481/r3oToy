### PROJECT SNAPSHOT: 2025-08-09

**COMPLETED THIS SESSION:**
*   Implemented `object!` support in `sling` for single-level sets and `/path` traversal (existing fields only).
*   Fixed `/path` traversal for `map!` containers by preserving the parent reference and creating intermediate maps at the parent when `/create` is active.
*   Stabilized block key traversal by evaluating value expressions after set-words and replacing the expression span in-place using `change/part`.
*   Simplified final map setting logic to create when `/create` is present without value-shape heuristics.
*   Ensured version consistency: `sling.r3` header now matches `v0.2.1` test banner and docs.
*   Installed and verified Rebol/Bulk 3.19.0 and executed the full QA suite successfully.

**KEY DECISIONS:**
*   Do not use `grab` as a setter helper during `/path` traversal due to copy/normalization semantics; directly work with containers and parent references.
*   When traversing block set-words, evaluate expressions up to the next top-level set-word and replace the full span with the evaluated result to avoid duplicated entries.
*   Treat object field updates as “existing fields only” (no auto-creation) to keep semantics predictable.
*   Remove special-case creation heuristics for maps and rely on explicit `/create`.

**OPEN ISSUES/BLOCKERS:**
*   None blocking. Potential future cleanup: remove `'else` literals in `case` branches; standardize on `append reduce` vs `repend` for portability; consider explicit handling or removal of `decimal!` keys in `sling`.

**NEXT STEPS:**
1.  Add targeted tests for `object!` `/path` traversal and negative cases (no `/create`).
2.  Documentation tidy-up and release notes; tag `v0.2.1` for the writer script.
3.  Evaluate adding a `/secure` refinement post-stabilization.

**CONTEXT NOTES:**
*   Architecture favors explicit returns and non-erroring behavior for getters/setters.
*   Evidence-driven development via REPL diagnostics and focused debug prints was critical to solving map path creation semantics.

---
```
=== Starting QA tests for `sling` v0.2.2 ===

--- `grab` Integrity Test (for sling) ---
✅ PASSED: grab Integrity: Should retrieve the container block correctly.
✅ PASSED: grab Integrity: Should return a LOGIC! true, not the word! 'true, when picking by index.

--- Phase 1: Simple Set Tests ---
✅ PASSED: Block/Int: Should set value at a valid index.
✅ PASSED: Block/Int: Should do nothing for an out-of-bounds index.
✅ PASSED: Block/Word: Should set value for an existing key.
✅ PASSED: Block/Word: Should do nothing for a missing key.
✅ PASSED: Map/Word: Key 'age should still exist.
✅ PASSED: Map/Word: Should set value for an existing key.
✅ PASSED: Map/Word (no-create): Should NOT create a new key 'city'.
✅ PASSED: Block/Int (negative): -1 should set the last item.
✅ PASSED: Block/Int (negative): -2 should set second-to-last item.
✅ PASSED: Block/Int (negative): Out-of-bounds negative index should be a no-op.
✅ PASSED: Object: Should set existing field.
✅ PASSED: Object: Should not create missing field.

--- Phase 2: `/create` Refinement Tests ---
✅ PASSED: Block/create: Should create a new key-value pair.
✅ PASSED: Map/create: Should create a new key-value pair.
✅ PASSED: Map/no-create: Should not create a key without the refinement.

--- Phase 3: `/path` Refinement Tests ---
✅ PASSED: Path/Block: Should set value in a nested block.
✅ PASSED: Path/Map: Should set value in a nested map.
✅ PASSED: Path/Block (negative): -1 should set the last item.
✅ PASSED: Path/Create: Should create a key in a nested block.
✅ PASSED: Path/Create: Should create a key in a nested map.
✅ PASSED: Path/Create: Should create nested structures.
✅ PASSED: Path/Object: Should set existing nested field.
✅ PASSED: Path/Object: Should be no-op for missing field.
✅ PASSED: Path/Object: /create should not add object fields.
✅ PASSED: Sanity: set in on nested object should set value.

--- Phase 4: `/report` Refinement Tests ---
✅ PASSED: Report/Block: Should report true on successful set.
✅ PASSED: Report/Block: Should report false on out-of-bounds index.
✅ PASSED: Report/Map: Should report true on existing key.
✅ PASSED: Report/Map: Should report false without /create.
✅ PASSED: Report/Map: Should report true with /create on missing key.
✅ PASSED: Report/Object: Should report true on existing field.
✅ PASSED: Report/Object: Should report false on missing field.
✅ PASSED: Report/Path(Block): Should report true on in-range index.
✅ PASSED: Report/Path(Block): Should report false on out-of-range index.
✅ PASSED: Report/Path(Block): Should report true on negative index.
✅ PASSED: Report/Path(Map): Should report false without /create.
✅ PASSED: Report/Path(Map): Should report true with /create.
✅ PASSED: Report/Path(Object): Should report true on existing nested field.
✅ PASSED: Report/Path(Object): Should report false on missing nested field.

--- Phase 5: `/secure` Refinement Tests ---
✅ PASSED: Secure/Block: Non-word step should be rejected.
✅ PASSED: Secure/Block: Literal block path is allowed.
✅ PASSED: Secure/Map: Non-word step should be rejected.
✅ PASSED: Secure/Map: Word key allowed.
✅ PASSED: Secure/Object: Non-word step should be rejected.
✅ PASSED: Secure/Object: Word step allowed.

============================================
✅ ALL TESTS PASSED
============================================
```
