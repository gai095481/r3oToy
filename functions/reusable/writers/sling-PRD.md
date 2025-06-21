### Product Requirements Document: The `sling` Super-Setter
**Version:** 0.1.0
**Date:** June 21, 2025  
**Status:** Design & Planning Stage
### 1. Introduction & Project Vision

##### 1.1. Problem Statement
Modifying data within Rebol's aggregate data structures (`block!`, `map!`, `object!`) often requires developers to use multiple native functions (`poke`, `put`, `append`), and write verbose, repetitive boilerplate code to handle different data types, check for key existence and manage nested structures.  There is no single, robust, *fire-and-forget* function for setting values in a safe, predictable and powerful manner.
##### 1.2. Proposed Solution: The `sling` Function
This project creates a single, powerful *super-setter* function named `sling` to provide a unified interface for modifying `block!`, `map!` and `object!` data structures in place.  It will intelligently select the correct native functions, handle edge cases, and provide optional support for deep path traversal and on-the-fly key creation to dramatically increasing developer productivity and code robustness.
##### 1.3. Target Audience
Rebol 3 (Oldes Branch) programmers developing applications involving manipulation of configuration data, application state or any other structured data.
#### 2. Goals & Objectives
- **Primary Goal:** Create a single, reliable function that simplifies the process of setting or adding values within Rebol 3 data structures.
- **Secondary Goal:** Ensure the function is architecturally sound, thoroughly tested and adheres to the established project coding standards.
- **Overall Goal:** Create a high-value, reusable utility that can be a cornerstone of a shared Rebol library, reducing development time and bugs in future projects.
#### 3. Features & Functional Requirements
The `sling` project will deliver a single Rebol 3 function with the following features:

|        |                                    |                                                                                                                                                          |              |
| ------ | ---------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------ |
| **ID** | **Feature Name**                   | **Description**                                                                                                                                          | **Priority** |
| F-01   | **Destructive Modification**       | `sling` will modify the original data structure in place, consistent with the behavior of native actions like put and poke.                              | Must-Have    |
| F-02   | **Multi-Type Support**             | sling must correctly handle block!, map!, and object! as the primary data argument.                                                                      | Must-Have    |
| F-03   | **Positional block! Setting**      | When data is a block! and key is an integer!, sling will use poke to set the value at that index.                                                        | Must-Have    |
| F-04   | **Key-Based block! Setting**       | When data is a block! and key is a word!, sling will use put to replace the value associated with the corresponding set-word!.                           | Must-Have    |
| F-05   | **Key-Based map! Setting**         | When data is a map!, sling will use put to set the value for the given key.                                                                              | Must-Have    |
| F-06   | **Path Traversal** (/path)         | Implement a /path refinement that accepts a block! of keys/indices to navigate nested structures and set a value at a deep location.                     | Must-Have    |
| F-07   | **Conditional Creation** (/create) | Implement a /create refinement. If a key does not exist, sling will only add the new key-value pair if /create is active. Otherwise, it will do nothing. | Must-Have    |
| F-08   | **Safe Failure**                   | sling must never error on a failed lookup (e.g., path not found without /create). It must fail silently, consistent with its design.                     | Must-Have    |
| F-09   | **Object Field Setting**           | When data is an object!, sling will use put to set the value of an existing field.                                                                       | Should-Have  |

### 4. Technical Requirements & Constraints
- **Language:** REBOL/Bulk 3.19.0 (Oldes Branch)
- **Architecture:** The implementation will be modular, likely consisting of a main sling router function and private helpers for pathing and simple setting logic.
- **Coding Standards:** All code must strictly adhere to the project's established ruleset, including the "Explicit Return Value Architecture".
- **Dependencies:** The final script must be self-contained with no external dependencies.
### 5. Out of Scope
- **Non-Destructive Mode:** A version of sling that returns a modified copy instead of altering the original is out of scope for this project.
- **Advanced Features:** All features listed in the "Planned Improvements" roadmap for grab (e.g., /secure, /pattern, /lazy, /cache) are out of scope for this initial version of sling.
- **Value Normalization:** Unlike grab, sling's job is to place the exact value provided by the user into the data structure. It will not perform any type conversion or normalization on the value argument.
### 6. Success Metrics
- The project will be considered successful when the sling function passes a comprehensive QA test suite covering all specified features, data types, and edge cases.
- The final code must pass a final review for compliance with all architectural and style rules.
