# Design Document

## Overview

The REBOL 3 Regular Expressions Engine enhancement focuses on fixing escape sequence handling and improving the robustness of pattern matching. The current implementation has issues with escape sequences like `\d`, `\w`, and `\s` that cause parse-rule errors. This design addresses these issues while maintaining backward compatibility and following REBOL coding standards.

## Architecture

### Current Architecture Analysis

The existing engine follows a three-layer architecture:

1. **Translation Layer** (`TranslateRegExp`): Converts regex patterns to REBOL parse rules
2. **Execution Layer** (`RegExp`): Executes parse rules against input strings
3. **Testing Layer** (`TestRegExp`): Provides boolean test results

### Architecture Decision: Parse Rules vs Alternatives

**Current Approach**: Convert regex patterns to REBOL parse rules
**Evaluation**: This approach leverages REBOL's native parsing capabilities but has limitations:

**Pros of Parse Rules Approach**:

- Leverages REBOL's optimized native parse engine
- Natural integration with REBOL's syntax and semantics
- Good performance for simple patterns
- Direct access to REBOL's character set operations

**Cons of Parse Rules Approach**:

- Complex translation layer prone to bugs
- Limited regex feature support (no lookaheads, backreferences)
- Difficult to maintain feature parity with standard regex engines
- Translation errors can be hard to debug

**Alternative Approaches Considered**:

1. **Native State Machine**: Build a finite state automaton directly
   
   - Pros: Full control, can implement advanced features
   - Cons: Complex implementation, reinventing the wheel
2. **External Library Integration**: Use existing regex libraries
   
   - Pros: Full feature support, battle-tested
   - Cons: External dependencies, platform compatibility issues
3. **Hybrid Approach**: Parse rules for simple patterns, state machine for complex ones
   
   - Pros: Best of both worlds
   - Cons: Increased complexity, dual maintenance burden

**Recommended Approach**: Enhanced Parse Rules with Fallback

- Continue with parse rules for core functionality (better REBOL integration)
- Implement robust error handling and clear limitations documentation
- Focus on reliable implementation of commonly used features
- Provide clear error messages when unsupported features are used

### Enhanced Architecture

The enhanced architecture maintains the parse rules approach but improves error handling and escape sequence processing:

```

```

┌─────────────────────────────────────────────────────────────┐
│                    User Interface Layer                     │
│  RegExp(string, pattern) → matched-string | false | none   │
└─────────────────────────────────────────────────────────────┘
│
┌─────────────────────────────────────────────────────────────┐
│                   Error Handling Layer                     │
│     try/with blocks for graceful error management          │
└─────────────────────────────────────────────────────────────┘
│
┌─────────────────────────────────────────────────────────────┐
│                  Pattern Translation Layer                 │
│    TranslateRegExp(pattern) → parse-rules-block            │
│    • Escape sequence processing                            │
│    • Quantifier handling                                   │
│    • Character class generation                            │
└─────────────────────────────────────────────────────────────┘
│
┌─────────────────────────────────────────────────────────────┐
│                   Parse Execution Layer                    │
│         REBOL parse engine with generated rules            │
└─────────────────────────────────────────────────────────────┘

```
## Components and Interfaces

### 1. Enhanced TranslateRegExp Function

**Purpose**: Convert regex patterns to REBOL parse rules with proper escape sequence handling

**Interface**:
```rebol
TranslateRegExp: funct [
    "Translate a regular expression to Rebol parse rules with enhanced error handling"
    regex-pattern [string!] "Regular expression pattern to translate"
    return: [block! none!] "Parse rules block or none if translation fails"
]
```

**Key Enhancements**:

- Fixed escape sequence parsing for `\d`, `\w`, `\s`
- Proper quantifier application to escape sequences
- Improved error handling for malformed patterns
- Consistent charset generation

### 2. Enhanced RegExp Function

**Purpose**: Main interface for regex matching with clear return value semantics

**Interface**:

```rebol
RegExp: funct [
    "Match a string against a regular expression with enhanced error handling"
    input-string [string!] "String to match against"
    regex-pattern [string!] "Regular expression pattern"
    return: [string! logic! none!] "Matched string, false if no match, none if error"
]
```

**Return Value Semantics**:

- **Matched string**: When pattern matches successfully
- **false**: When pattern is valid but doesn't match input
- **none**: When there's a parsing error or invalid pattern

### 3. Enhanced Character Set Generation

**Purpose**: Create proper character sets for escape sequences

**Interface**:

```rebol
MakeCharSet: funct [
    "Create a character set from a string specification with validation"
    char-spec [string!] "Character specification (e.g., '0-9', 'A-Za-z_')"
    return: [bitset! none!] "Character set bitset or none if invalid"
]
```

### 4. Escape Sequence Processor

**Purpose**: Handle escape sequences with proper quantifier support

**Design Pattern**:

```rebol
;; Escape sequence handling with quantifier support
escape-sequence-rules: [
    "\" [
        "d" [
            "+" (append rules [some charset "0-9"]) |
            "*" (append rules [any charset "0-9"]) |
            "?" (append rules [opt charset "0-9"]) |
            "{" copy count to "}" skip (handle-counted-quantifier charset "0-9" count) |
            (append rules charset "0-9")
        ] |
        "w" [
            ;; Similar pattern for word characters
        ] |
        "s" [
            ;; Similar pattern for whitespace
        ]
    ]
]
```

## Data Models

### 1. Parse Rules Structure

```rebol
;; Example parse rules generated for different patterns
parse-rules-examples: [
    ;; \d+ → [some charset "0-9"]
    ;; \w* → [any MakeCharSet "0-9A-Za-z_"]  
    ;; \s? → [opt charset " ^-^/"]
    ;; \d{3} → [3 charset "0-9"]
    ;; \w{2,5} → [2 5 MakeCharSet "0-9A-Za-z_"]
]
```

### 2. Character Set Specifications

```rebol
character-set-specs: [
    digits: "0-9"
    word-chars: "0-9A-Za-z_"
    whitespace: " ^-^/"  ;; space, tab, newline
    letters-lower: "a-z"
    letters-upper: "A-Z"
]
```

### 3. Error Handling States

```rebol
error-states: [
    translation-error: "Pattern translation failed"
    parse-error: "Parse execution failed"
    invalid-quantifier: "Invalid quantifier specification"
    malformed-pattern: "Malformed regex pattern"
]
```

## Error Handling

### 1. Translation Phase Error Handling

```rebol
TranslateRegExp: funct [regex-pattern [string!]] [
    translation-result: none
    set/any 'translation-result try [
        ;; Pattern translation logic here
        generate-parse-rules regex-pattern
    ]
    
    either error? translation-result [
        ;; Log error details for debugging
        none  ;; Return none to indicate translation failure
    ] [
        translation-result  ;; Return successful parse rules
    ]
]
```

### 2. Execution Phase Error Handling

```rebol
RegExp: funct [input-string [string!] regex-pattern [string!]] [
    ;; First, try to translate the pattern
    parse-rules: TranslateRegExp regex-pattern
    
    either none? parse-rules [
        none  ;; Translation failed, return none
    ] [
        ;; Try to execute the parse
        parse-result: none
        set/any 'parse-result try [
            parse input-string parse-rules
        ]
        
        either error? parse-result [
            none  ;; Parse execution failed, return none
        ] [
            either parse-result [
                input-string  ;; Match successful, return matched string
            ] [
                false  ;; No match, return false
            ]
        ]
    ]
]
```

### 3. Graceful Degradation

- Invalid escape sequences fall back to literal character matching
- Malformed quantifiers are treated as literal characters
- Empty patterns match empty strings
- Very large quantifiers are capped at reasonable limits

## Testing Strategy

### 1. Unit Testing Approach

**Escape Sequence Tests**:

```rebol
escape-sequence-test-cases: [
    ;; Basic escape sequences
    ["5" "\d" true]
    ["a" "\d" false]
    ["abc123" "\w+" true]
    ["!@#" "\w+" false]
    [" " "\s" true]
    ["a" "\s" false]
    
    ;; Quantified escape sequences
    ["123" "\d+" true]
    ["" "\d+" false]
    ["abc" "\w*" true]
    ["" "\w*" true]
    ["  " "\s?" true]
    ["ab" "\s?" true]
    
    ;; Counted quantifiers
    ["123" "\d{3}" true]
    ["12" "\d{3}" false]
    ["abcd" "\w{2,5}" true]
    ["a" "\w{2,5}" false]
]
```

**Error Handling Tests**:

```rebol
error-handling-test-cases: [
    ;; Malformed patterns should return none
    ["test" "[a-" none]
    ["test" "a{2,1}" none]
    ["test" "\\q" none]
    
    ;; Valid patterns with no match should return false
    ["abc" "\d+" false]
    ["123" "[a-z]+" false]
]
```

### 2. Integration Testing

**Complex Pattern Tests**:

```rebol
integration-test-cases: [
    ;; Mixed patterns
    ["abc123def" "[a-z]+\d+[a-z]+" true]
    ["hello world" "\w+\s\w+" true]
    ["user@domain.com" "\w+@\w+\.\w+" true]
    
    ;; Edge cases
    ["" "" true]
    ["a" "" false]
    ["" "a" false]
]
```

### 3. Performance Testing

- Test with very long strings (1000+ characters)
- Test with complex nested patterns
- Test with high-repetition quantifiers
- Memory usage monitoring during pattern compilation

### 4. Regression Testing

- Ensure all existing functionality continues to work
- Verify backward compatibility with current test suite
- Test against known problematic patterns from previous versions

## Implementation Phases

### Phase 1: Core Escape Sequence Fixes

- Fix `\d`, `\w`, `\s` parsing in TranslateRegExp
- Implement proper quantifier handling for escape sequences
- Add basic error handling

### Phase 2: Enhanced Error Handling

- Implement try/with error catching
- Add proper return value semantics (string/false/none)
- Create comprehensive error logging

### Phase 3: Testing and Validation

- Implement comprehensive test suite
- Add performance benchmarks
- Validate against edge cases

### Phase 4: Documentation and Optimization

- Update function documentation
- Optimize character set generation
- Add usage examples and best practices

## Performance Considerations

### 1. Character Set Caching

- Cache frequently used character sets (digits, word chars, whitespace)
- Avoid regenerating identical bitsets

### 2. Parse Rule Optimization

- Minimize rule complexity where possible
- Use efficient REBOL parse constructs
- Avoid unnecessary backtracking

### 3. Memory Management

- Reuse parse rule blocks when possible
- Clear temporary variables in long-running operations
- Monitor memory usage during pattern compilation

## Security Considerations

### 1. Pattern Validation

- Validate input patterns before processing
- Prevent infinite loops from malicious patterns
- Limit quantifier ranges to reasonable values

### 2. Resource Limits

- Cap maximum pattern length
- Limit recursion depth in nested patterns
- Timeout protection for long-running matches

### 3. Input Sanitization

- Validate input strings for proper encoding
- Handle special characters safely
- Prevent buffer overflow conditions
