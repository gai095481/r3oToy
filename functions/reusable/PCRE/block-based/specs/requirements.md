# Requirements Document

## Introduction

This specification addresses the fundamental architectural limitation of the current REBOL RegExp engine that uses string-based pattern processing, which creates meta-character conflicts (particularly with the `^` anchor character). The solution redesigns the engine to use BLOCK! datatype for internal pattern processing while providing a clean API that eliminates REBOL meta-character conflicts through function refinements and alternative syntax.

**Technical Context**: The current engine suffers from REBOL meta-character conflicts where `^` in strings creates control characters instead of regexp anchors. Our solution uses:

1. **`/caret` refinement** for start anchors (eliminates `^` character entirely)
2. **`[!...]` alternative syntax** for negated character classes (avoids `^` control character conflicts)
3. **BLOCK! datatype internally** for semantic token processing (eliminates all meta-character conflicts)

**Performance Rationale**: The `^` character in patterns like `[^0-9]` creates REBOL control characters (e.g., `^0` = ASCII 0), requiring expensive preprocessing to convert single control characters back to separate `^` + `0` characters. Our `[!0-9]` alternative syntax avoids this overhead entirely.

## Requirements

### Requirement 1: Clean API with Meta-Character Conflict Resolution

**User Story:** As a developer using the RegExp engine, I want to use start anchors and negated character classes without REBOL meta-character conflicts, so that I can write patterns efficiently without preprocessing overhead.

#### Acceptance Criteria

1. WHEN I need start anchor functionality THEN I SHALL use `RegExp/caret "hello world" "hello"` syntax (no `^` character needed)
2. WHEN I need negated character classes THEN I SHALL use `[!0-9]` syntax instead of `[^0-9]` (avoids control character conflicts)
3. WHEN I use standard patterns like `RegExp "123" "\d+"` THEN system SHALL return the same results as before
4. WHEN I use the new syntax THEN zero preprocessing overhead SHALL be incurred (direct tokenization)

### Requirement 2: Internal Block-Based Processing

**User Story:** As a system architect, I want the engine to process patterns as semantic blocks internally, so that meta-character conflicts are eliminated and performance is improved.

#### Acceptance Criteria

1. WHEN string pattern `"^hello"` is processed THEN system SHALL convert to block `[anchor-start "hello"]` internally
2. WHEN string pattern `"\d+"` is processed THEN system SHALL convert to block `[digit-class quantifier-plus]` internally
3. WHEN block processing occurs THEN no meta-character conflicts SHALL exist
4. WHEN pattern tokenization happens THEN semantic meaning SHALL be preserved

### Requirement 3: Meta-Character Conflict Resolution Through Alternative Syntax

**User Story:** As a developer using anchor patterns and negated character classes, I want clean syntax that avoids REBOL meta-character conflicts, so that I can create patterns without performance overhead or preprocessing complexity.

#### Acceptance Criteria

1. WHEN I use `/caret` refinement THEN start anchor functionality SHALL work without any `^` character in the pattern
2. WHEN I use `[!0-9]` syntax THEN negated character classes SHALL work without `^` control character conflicts
3. WHEN I use `RegExp/caret "test123" "[!0-9]+"` THEN both start anchor and negation SHALL work together perfectly
4. WHEN alternative syntax is processed THEN zero preprocessing overhead SHALL be incurred (direct semantic tokenization)

### Requirement 4: Performance Optimization Through Alternative Syntax

**User Story:** As a system administrator, I want the RegExp engine to avoid expensive preprocessing overhead, so that pattern matching is maximally efficient.

#### Acceptance Criteria

1. WHEN `/caret` refinement is used THEN zero preprocessing overhead SHALL be incurred (no string manipulation)
2. WHEN `[!0-9]` syntax is used THEN zero control character conversion SHALL be needed (direct tokenization)
3. WHEN `[^0-9]` syntax is avoided THEN expensive control character preprocessing SHALL be eliminated
4. WHEN performance benchmarks are run THEN alternative syntax SHALL show zero overhead compared to preprocessing approaches

### Requirement 5: Enhanced Error Handling

**User Story:** As a developer debugging patterns, I want better error messages and validation, so that I can identify and fix pattern issues more easily.

#### Acceptance Criteria

1. WHEN invalid patterns are submitted THEN semantic token validation SHALL provide clearer error messages
2. WHEN pattern conversion fails THEN specific token-level errors SHALL be reported
3. WHEN malformed patterns are detected THEN error handling SHALL be more precise than string-based validation
4. WHEN debugging is needed THEN block representation SHALL be more readable than string parsing

### Requirement 6: Modular Architecture Integration

**User Story:** As a developer maintaining the RegExp engine, I want the block-based architecture built on the proven modular design, so that I get both block-based benefits and modular maintainability.

#### Acceptance Criteria

1. WHEN the block-based engine is implemented THEN it SHALL use the proven 5-module architecture (Core Utilities, Pattern Processor, Matcher, Main Orchestrator, Test Wrapper)
2. WHEN modules are created THEN each module SHALL contain no more than 500 lines of code (updated constraint from modularization project)
3. WHEN the block-based engine is developed THEN it SHALL maintain clean dependency hierarchy with no circular dependencies
4. WHEN syntax errors occur THEN they SHALL be isolated to individual modules without affecting the entire system

### Requirement 7: Function Refinement API Design

**User Story:** As a developer using the RegExp engine, I want a clean function refinement API that clearly indicates when start anchor functionality is needed, so that my code is self-documenting and efficient.

#### Acceptance Criteria

1. WHEN I need start anchor functionality THEN I SHALL use `RegExp/caret haystack pattern` syntax
2. WHEN I use `/caret` refinement THEN the pattern SHALL be treated as if it has an implicit `^` at the beginning
3. WHEN I use standard `RegExp haystack pattern` THEN no anchor functionality SHALL be applied
4. WHEN I combine `/caret` with `[!...]` syntax THEN both start anchor and negation SHALL work together seamlessly

### Requirement 8: Extensibility and Maintainability

**User Story:** As a developer maintaining the RegExp engine, I want the block-based architecture to be more maintainable and extensible, so that adding new features is easier.

#### Acceptance Criteria

1. WHEN new pattern types are added THEN block-based architecture SHALL accommodate them more easily
2. WHEN pattern processing logic is modified THEN semantic tokens SHALL make changes more straightforward
3. WHEN debugging engine issues THEN block representation SHALL provide better visibility into processing
4. WHEN code maintenance is needed THEN block-based approach SHALL be more modular and testable

## Implementation Status (July 29, 2025)

### Requirements Update for Alternative Syntax Strategy

The requirements have been updated to reflect the agreed strategy of using `/caret` refinement and `[!...]` alternative syntax to eliminate REBOL meta-character conflicts while maintaining optimal performance.

### Updated Requirements Summary

**🔄 Requirement 1: Clean API with Meta-Character Conflict Resolution** - REQUIRES IMPLEMENTATION

- `/caret` refinement syntax for start anchors needs implementation
- `[!...]` alternative syntax for negated character classes needs implementation
- Zero preprocessing overhead requirement needs validation
- Direct tokenization approach needs implementation

**✅ Requirement 2: Internal Block-Based Processing** - COMPLETED

- String patterns converted to semantic blocks internally
- Meta-character conflicts eliminated through semantic token processing
- Pattern tokenization preserves semantic meaning
- Block processing architecture fully implemented

**🔄 Requirement 3: Meta-Character Conflict Resolution Through Alternative Syntax** - REQUIRES IMPLEMENTATION

- `/caret` refinement functionality needs implementation
- `[!0-9]` syntax support needs implementation
- Combined usage (`RegExp/caret "test" "[!0-9]+"`) needs implementation
- Zero preprocessing overhead needs validation

**🔄 Requirement 4: Performance Optimization Through Alternative Syntax** - REQUIRES IMPLEMENTATION

- `/caret` refinement zero overhead needs implementation
- `[!0-9]` direct tokenization needs implementation
- Control character preprocessing elimination needs validation
- Performance benchmarks for alternative syntax needed

**✅ Requirement 5: Enhanced Error Handling** - COMPLETED

- Semantic token validation provides clearer error messages
- Token-level error reporting implemented
- More precise error handling than string-based validation
- Block representation more readable for debugging

**✅ Requirement 6: Modular Architecture Integration** - COMPLETED

- 6-module architecture successfully implemented
- All modules under 500-line constraint
- Clean dependency hierarchy with no circular dependencies
- Syntax errors isolated to individual modules

**🔄 Requirement 7: Function Refinement API Design** - REQUIRES IMPLEMENTATION

- `RegExp/caret haystack pattern` syntax needs implementation
- Implicit start anchor functionality needs implementation
- Standard `RegExp` vs `/caret` behavior distinction needs implementation
- Combined refinement and alternative syntax needs implementation

**✅ Requirement 8: Extensibility and Maintainability** - COMPLETED

- Block-based architecture accommodates new pattern types easily
- Semantic tokens make modifications more straightforward
- Block representation provides better debugging visibility
- Modular approach enhances testability and maintenance

### Implementation Priority

**CRITICAL UPDATES NEEDED:**

1. **Function Signature Update**: Add `/caret` refinement to `RegExp` function
2. **Tokenizer Update**: Add support for `[!...]` syntax (replace `[^...]` processing)
3. **Matcher Update**: Implement start anchor functionality for `/caret` refinement
4. **Testing Update**: Create test cases for new syntax and refinement combinations

### Current Status

**Status**: 🔄 **REQUIRES IMPLEMENTATION UPDATES**
**Priority**: **HIGH** - Core functionality changes needed
**Scope**: Clean break from previous `^` character approach
**Timeline**: Implementation updates needed before production deployment

The specification has been updated to reflect the strategic decision to use `/caret` refinement and `[!...]` alternative syntax for optimal performance and clean meta-character conflict resolution.
