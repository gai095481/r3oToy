### Product Requirements Document: The `sling` Super-Setter
**Version:** 0.2.1
**Date:** August 8, 2025  
**Status:** Implemented & QA Passed
### 1. Introduction & Project Vision

##### 1.1. Problem Statement
Modifying data within Rebol's aggregate data structures (`block!`, `map!`, `object!`) often requires developers to use multiple native functions (`poke`, `put`, `append`), and write verbose, repetitive boilerplate code to handle different data types, check for key existence and manage nested structures. There is no single, robust, fire-and-forget function for setting values in a safe, predictable and powerful manner.
##### 1.2. Proposed Solution: The `sling` Function
This project creates a single, powerful super-setter function named `sling` to provide a unified interface for modifying `block!`, `map!` and `object!` data structures in place. It intelligently selects the correct native functions, handles edge cases, and provides optional support for deep path traversal and on-the-fly key creation, dramatically increasing developer productivity and code robustness.
##### 1.3. Target Audience
Rebol 3 (Oldes Branch) programmers developing applications involving manipulation of configuration data, application state or any other structured data.
#### 2. Goals & Objectives
- **Primary Goal:** Create a single, reliable function that simplifies the process of setting or adding values within Rebol 3 data structures.
- **Secondary Goal:** Ensure the function is architecturally sound, thoroughly tested and adheres to the established project coding standards.
- **Overall Goal:** Create a high-value, reusable utility that can be a cornerstone of a shared Rebol library, reducing development time and bugs in future projects.
#### 3. Features & Functional Requirements
The `sling` project delivers a single Rebol 3 function with the following features:

|        |                                    |                                                                                                                      |              |
| ------ | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------ |
| **ID** | **Feature Name**                   | **Description**                                                                                                      | **Priority** |
| F-01   | **Destructive Modification**       | `sling` modifies the original data structure in place, consistent with the behavior of native actions like `put` and `poke`. | Must-Have    |
| F-02   | **Multi-Type Support**             | Supports `block!`, `map!`, and `object!` as the primary data argument.                                               | Must-Have    |
| F-03   | **Positional block! Setting**      | When `data` is a `block!` and `key` is an `integer!`, uses `poke` to set the value at that index.                     | Must-Have    |
| F-04   | **Key-Based block! Setting**       | When `data` is a `block!` and `key` is a `word!`, uses `put` to replace the value associated with the corresponding `set-word!`. | Must-Have    |
| F-05   | **Key-Based map! Setting**         | When `data` is a `map!`, uses `put` to set the value for the given key.                                              | Must-Have    |
| F-06   | **Path Traversal** (/path)         | `/path` refinement accepts a `block!` of keys/indices to navigate nested structures and set a value at a deep location. | Must-Have    |
| F-07   | **Conditional Creation** (/create) | `/create` refinement allows creation of keys/containers at missing path segments.                                     | Must-Have    |
| F-08   | **Safe Failure**                   | Never errors on a failed lookup (e.g., path not found without `/create`); fails silently as designed.                | Must-Have    |
| F-09   | **Object Field Setting**           | When `data` is an `object!`, uses `put` to set the value of an existing field (single-level and `/path`).             | Should-Have (Implemented) |

### 4. Technical Requirements & Constraints
- **Language:** Rebol/Bulk 3.19.0 (Oldes Branch)
- **Architecture:** A single `sling` router function with private logic for pathing and single-level operations; preserves parent references for map traversal.
- **Coding Standards:** Strict adherence to the project's ruleset, including the "Explicit Return Value Architecture".
- **Dependencies:** Self-contained; no external dependencies.
- **QA Result:** All tests pass under Rebol/Bulk 3.19.0.
### 5. Out of Scope
- **Non-Destructive Mode:** A version of `sling` that returns a modified copy instead of altering the original is out of scope for this project.
- **Advanced Features:** Planned improvements (e.g., `/secure`, `/pattern`, `/lazy`, `/cache`) are out of scope for this version.
- **Value Normalization:** Unlike `grab`, `sling` places the exact value provided by the user into the data structure without normalization.
### 6. Success Metrics
- The project is successful when the `sling` function passes a comprehensive QA test suite covering all specified features, data types, and edge cases.
- Final code passes a review for compliance with all architectural and style rules.
- Status achieved with `v0.2.1`: All tests passed under Rebol/Bulk 3.19.0.
