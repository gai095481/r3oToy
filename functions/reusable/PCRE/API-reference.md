# REBOL Lite RegExp Engine - API Reference

**Document Type**: API Reference and Usage Guide
**Version**: 3.0.0 (Consolidated Edition)
**Last Updated**: July 21, 2025

## Overview

This document provides comprehensive API reference for the REBOL RegExp engine, including function signatures, usage examples, return value semantics, and practical implementation guidance.

## Core Functions

### RegExp Function

The primary interface for regular expression matching.

#### Signature

```rebol
RegExp: funct [
    "Match a string against a regular expression with enhanced error handling"
    strHaystack [string!] "String to match against"
    strRegExp [string!] "Regular expression pattern"
    return: [string! logic! none!] "Matched string, false if no match, none if error"
]
```

#### Return Value Semantics

The RegExp function implements a three-value return system:

| Return Type | Meaning | Example |
|-------------|---------|---------|
| **String** | Successful match (returns matched portion) | `"123"` |
| **False** | Valid pattern with no match | `false` |
| **None** | Invalid pattern or translation error | `none` |

#### Usage Examples

##### Basic Pattern Matching

```rebol
;; Digit matching
RegExp "abc123def" "\d+"          ;; → "123"
RegExp "abcdef" "\d+"             ;; → false (no digits)

;; Word character matching  
RegExp "hello_world" "\w+"        ;; → "hello_world"
RegExp "123!@#" "\w+"             ;; → "123"

;; Whitespace matching
RegExp "hello world" "\s+"        ;; → " "
RegExp "helloworld" "\s+"         ;; → false (no whitespace)
```

##### Negated Character Classes

```rebol
;; Non-digit matching
RegExp "abc123" "\D+"             ;; → "abc"
RegExp "123456" "\D+"             ;; → false (all digits)

;; Non-word character matching
RegExp "hello@world" "\W+"        ;; → "@"
RegExp "hello_world" "\W+"        ;; → false (all word chars)

;; Non-whitespace matching
RegExp "hello world" "\S+"        ;; → "hello"
RegExp "   " "\S+"                ;; → false (all whitespace)
```

##### Quantifier Usage

```rebol
;; One or more (+)
RegExp "aaa" "a+"                 ;; → "aaa"
RegExp "bbb" "a+"                 ;; → false

;; Zero or more (*)
RegExp "aaa" "a*"                 ;; → "aaa"
RegExp "bbb" "a*"                 ;; → "" (matches zero occurrences)

;; Zero or one (?)
RegExp "a" "a?"                   ;; → "a"
RegExp "b" "a?"                   ;; → "" (matches zero occurrences)

;; Exact count {n}
RegExp "123" "\d{3}"              ;; → "123"
RegExp "1234" "\d{3}"             ;; → false (not exactly 3)
RegExp "12" "\d{3}"               ;; → false (not exactly 3)

;; Range count {n,m}
RegExp "123" "\d{2,4}"            ;; → "123"
RegExp "12345" "\d{2,4}"          ;; → "1234"
RegExp "1" "\d{2,4}"              ;; → false (below minimum)
```

##### Character Classes

```rebol
;; Basic character classes
RegExp "hello" "[a-z]+"           ;; → "hello"
RegExp "HELLO" "[a-z]+"           ;; → false (uppercase)
RegExp "123" "[0-9]+"             ;; → "123"

;; Negated character classes
RegExp "hello123" "[^0-9]+"       ;; → "hello"
RegExp "123abc" "[^0-9]+"         ;; → "abc"
```

##### Advanced Patterns

```rebol
;; Mixed patterns with backtracking
RegExp "abc123" "\w+\d+"          ;; → "abc123"
RegExp "123abc" "\d+\w+"          ;; → "123abc"
RegExp "test123 data" "\w+\d+\s\w+"  ;; → "test123 data"

;; Grouped quantifiers (preprocessed)
RegExp "a1 b2 c3 d4" "(\w\d\s){3}\w\d"  ;; → "a1 b2 c3 d4"
```

##### Error Handling

```rebol
;; Invalid quantifier syntax
RegExp "test" "\d{"               ;; → none (unclosed quantifier)
RegExp "test" "\d{}"              ;; → none (empty quantifier)
RegExp "test" "\d{abc}"           ;; → none (non-numeric quantifier)

;; Invalid character classes
RegExp "test" "[z-a]"             ;; → none (reverse range)
RegExp "test" "[abc"              ;; → none (unclosed class)

;; Invalid escape sequences (treated as literals)
RegExp "query" "\q"               ;; → "q" (treats as literal 'q')
RegExp "test" "\z"                ;; → false (no literal 'z' found)
```

### TranslateRegExp Function

Converts regular expression patterns to REBOL parse rules.

#### Signature

```rebol
TranslateRegExp: funct [
    "Translate a regular expression to Rebol parse rules with comprehensive error handling"
    strRegExp [string!] "Regular expression pattern to translate"
    return: [block! none!] "Parse rules block or none if translation fails"
]
```

#### Usage Examples

```rebol
;; Basic escape sequences
TranslateRegExp "\d"              ;; → [make bitset! "0123456789"]
TranslateRegExp "\w"              ;; → [make bitset! "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz_"]
TranslateRegExp "\s"              ;; → [make bitset! " ^-^/"]

;; Quantified patterns
TranslateRegExp "\d+"             ;; → [some make bitset! "0123456789"]
TranslateRegExp "\w*"             ;; → [any make bitset! "..."]
TranslateRegExp "\s?"             ;; → [opt make bitset! " ^-^/"]

;; Exact quantifiers
TranslateRegExp "\d{3}"           ;; → [3 make bitset! "0123456789"]
TranslateRegExp "\w{2,4}"         ;; → [2 4 make bitset! "..."]

;; Character classes
TranslateRegExp "[a-z]"           ;; → [make bitset! "abcdefghijklmnopqrstuvwxyz"]
TranslateRegExp "[^0-9]"          ;; → [complement make bitset! "0123456789"]

;; Error cases
TranslateRegExp "\d{"             ;; → none (invalid quantifier)
TranslateRegExp "[z-a]"           ;; → none (reverse range)
```

### MakeCharSet Function

Creates character sets from string specifications with range support.

#### Signature

```rebol
MakeCharSet: function [
    "Create a character set from a string specification with range support"
    specStr [string!] "Character specification string (e.g., '0-9', 'a-zA-Z')"
    return: [bitset!] "Bitset representing the character set"
]
```

#### Usage Examples

```rebol
;; Basic character ranges
MakeCharSet "0-9"                 ;; → bitset for digits 0-9
MakeCharSet "a-z"                 ;; → bitset for lowercase letters
MakeCharSet "A-Z"                 ;; → bitset for uppercase letters

;; Combined ranges
MakeCharSet "0-9A-Za-z"           ;; → bitset for alphanumeric characters
MakeCharSet "0-9A-Za-z_"          ;; → bitset for word characters

;; Individual characters
MakeCharSet "abc"                 ;; → bitset for characters a, b, c
MakeCharSet " ^-^/"               ;; → bitset for whitespace characters

;; Mixed ranges and individuals
MakeCharSet "0-9!@#"              ;; → bitset for digits and punctuation
```

### Validation Functions

#### ValidateQuantifierRange Function

Validates quantifier range syntax and values.

##### Signature

```rebol
ValidateQuantifierRange: funct [
    "Validate quantifier range syntax and values with comprehensive error checking"
    quantifier-string [string!] "Quantifier specification like '3' or '2,5'"
    return: [logic!] "True if valid, false if invalid"
]
```

##### Usage Examples

```rebol
;; Valid exact quantifiers
ValidateQuantifierRange "3"       ;; → true
ValidateQuantifierRange "0"       ;; → true
ValidateQuantifierRange "999"     ;; → true

;; Valid range quantifiers
ValidateQuantifierRange "2,5"     ;; → true
ValidateQuantifierRange "0,10"    ;; → true
ValidateQuantifierRange "1,1"     ;; → true

;; Invalid quantifiers
ValidateQuantifierRange ""        ;; → false (empty)
ValidateQuantifierRange "abc"     ;; → false (non-numeric)
ValidateQuantifierRange "5,2"     ;; → false (reverse range)
ValidateQuantifierRange "10000"   ;; → false (too large)
ValidateQuantifierRange "-1"      ;; → false (negative)
```

#### ValidateCharacterClass Function

Validates character class specifications.

##### Signature

```rebol
ValidateCharacterClass: funct [
    "Validate character class specification with comprehensive error detection"
    char-spec [string!] "Character class specification"
    return: [logic!] "True if valid, false if invalid"
]
```

##### Usage Examples

```rebol
;; Valid character classes:
ValidateCharacterClass "a-z"      ;; → true
ValidateCharacterClass "0-9"      ;; → true
ValidateCharacterClass "^a-z"     ;; → true (negated)
ValidateCharacterClass "abc"      ;; → true (individual chars)

;; Invalid character classes:
ValidateCharacterClass ""         ;; → false (empty)
ValidateCharacterClass "z-a"      ;; → false (reverse range)
ValidateCharacterClass "a-"       ;; → false (trailing dash)
ValidateCharacterClass "-z"       ;; → false (leading dash)
```

## Supported Regular Expression Features

### Escape Sequences

| Sequence | Description | Character Set |
|----------|-------------|---------------|
| `\d` | Digits | `0-9` |
| `\D` | Non-digits | `^0-9` |
| `\w` | Word characters | `0-9A-Za-z_` |
| `\W` | Non-word characters | `^0-9A-Za-z_` |
| `\s` | Whitespace | ` \t\n` (space, tab, newline) |
| `\S` | Non-whitespace | `^ \t\n` |

### Quantifiers

| Quantifier | Description | Example |
|------------|-------------|---------|
| `+` | One or more | `\d+` matches "123" |
| `*` | Zero or more | `\d*` matches "" or "123" |
| `?` | Zero or one | `\d?` matches "" or "1" |
| `{n}` | Exactly n | `\d{3}` matches exactly "123" |
| `{n,m}` | Between n and m | `\d{2,4}` matches "12" to "1234" |

### Character Classes

| Syntax | Description | Example |
|--------|-------------|---------|
| `[abc]` | Any of a, b, or c | `[aeiou]` matches vowels |
| `[a-z]` | Character range | `[a-z]` matches lowercase |
| `[^abc]` | Not a, b, or c | `[^0-9]` matches non-digits |
| `[a-zA-Z0-9]` | Combined ranges | Alphanumeric characters |

### Special Characters

| Character | Description | Usage |
|-----------|-------------|-------|
| `.` | Any character (except newline) | `.+` matches any text |
| `^` | Start of string | `^\d+` matches digits at start |
| `$` | End of string | `\d+$` matches digits at end |
| `\` | Escape character | `\.` matches literal dot |

### Advanced Features

#### Mixed Patterns with Backtracking

```rebol
;; Supported mixed patterns:
RegExp "abc123" "\w+\d+"          ;; Word chars followed by digits
RegExp "123abc" "\d+\w+"          ;; Digits followed by word chars
RegExp "test123 data" "\w+\d+\s\w+"  ;; Complex multi-element pattern
```

#### Grouped Quantifiers (Preprocessed)

```rebol
;; Grouped quantifier expansion:
RegExp "a1 b2 c3 d4" "(\w\d\s){3}\w\d"  ;; Expands to \w\d\s\w\d\s\w\d\s\w\d
```

## Error Handling and Debugging

### Error Categories

#### Translation Errors (Return: none)

- **Invalid quantifier syntax**: `\d{`, `\d{}`, `\d{abc}`
- **Malformed character classes**: `[z-a]`, `[abc`, `]abc[`
- **Unclosed constructs**: `[abc`, `\d{`
- **Parse rule generation failures**: Internal translation errors

#### Execution Errors (Return: false)

- **Valid patterns with no match**: Pattern is valid but doesn't match input
- **Empty string matching**: Context-dependent behavior

#### Success Cases (Return: string)

- **Successful pattern matches**: Returns the matched portion
- **Partial matches**: When appropriate for the pattern type

### Debugging Techniques

#### Pattern Testing

```rebol
;; Test pattern validity
pattern: "\d{3}"
rules: TranslateRegExp pattern
either none? rules [
    print "Invalid pattern"
] [
    print ["Valid pattern, rules:" mold rules]
]
```

#### Step-by-Step Analysis

```rebol
;; Analyze pattern components
input: "abc123def"
pattern: "\d+"

;; 1. Check translation
rules: TranslateRegExp pattern
print ["Translation result:" mold rules]

;; 2. Test execution
result: RegExp input pattern
print ["Execution result:" mold result]

;; 3. Analyze return type
print ["Result type:" type? result]
```

#### Common Issues and Solutions

##### Issue: Pattern not matching expected text

```rebol
;; Problem: Expecting partial match for exact quantifier
RegExp "1234" "\d{3}"             ;; → false (not "123")

;; Solution: Use appropriate quantifier
RegExp "1234" "\d{1,3}"           ;; → "123" (up to 3 digits)
RegExp "1234" "\d+"               ;; → "1234" (one or more digits)
```

##### Issue: Case sensitivity confusion

```rebol
;; Problem: Expecting case-insensitive behavior
RegExp "ABC" "\w+"                ;; → "ABC" (works correctly)

;; Understanding: \d vs \D are case-sensitive
RegExp "123" "\d+"                ;; → "123" (digits)
RegExp "123" "\D+"                ;; → false (non-digits)
```

##### Issue: Invalid escape sequences

```rebol
;; Problem: Using invalid escape sequences
RegExp "query" "\q"               ;; → "q" (treated as literal)

;; Solution: Use valid escape sequences or expect literal behavior
RegExp "query" "q"                ;; → "q" (explicit literal)
RegExp "123" "\d"                 ;; → "1" (valid escape sequence)
```

## Performance Considerations

### Optimization Guidelines

#### Use Appropriate Quantifiers

```rebol
;; Efficient: Use specific quantifiers when possible
RegExp phone "\d{3}-\d{3}-\d{4}"  ;; Better than \d+-\d+-\d+

;; Efficient: Use character classes for multiple options
RegExp text "[aeiou]+"            ;; Better than (a|e|i|o|u)+
```

#### Avoid Excessive Quantifier Ranges

```rebol
;; Avoid: Very large quantifier ranges
RegExp text "\d{1,9999}"          ;; May cause performance issues

;; Prefer: Reasonable ranges or unlimited quantifiers
RegExp text "\d{1,10}"            ;; Reasonable range
RegExp text "\d+"                 ;; Unlimited (often more efficient)
```

#### Pattern Complexity Management

```rebol
;; Simple patterns are faster
RegExp text "\d+"                 ;; Fast
RegExp text "\w+\d+\s\w+"         ;; Slower (requires backtracking)

;; Consider breaking complex patterns into steps
first-match: RegExp text "\w+\d+"
if string? first-match [
    ;; Process first match, then continue with remaining pattern
]
```

### Performance Boundaries

The engine enforces performance boundaries to prevent degradation:

- **Quantifier Limit**: Maximum quantifier value < 10000
- **Pattern Complexity**: Automatic optimization for common patterns
- **Backtracking Depth**: Limited backtracking simulation for mixed patterns

## Integration Examples

### Input Validation

```rebol
validate-email: funct [
    "Validate email address format"
    email [string!] "Email address to validate"
    return: [logic!] "True if valid format"
] [
    ;; Simple email pattern (basic validation)
    email-pattern: "\w+@\w+\.\w+"
    result: RegExp email email-pattern
    string? result
]

;; Usage
validate-email "user@domain.com"      ;; → true
validate-email "invalid.email"       ;; → false
```

### Data Extraction

```rebol
extract-numbers: funct [
    "Extract all numbers from text"
    text [string!] "Text to search"
    return: [block!] "Block of found numbers"
] [
    numbers: copy []
    remaining: text
    
    while [not empty? remaining] [
        result: RegExp remaining "\d+"
        either string? result [
            append numbers result
            ;; Find position after match and continue:
            pos: find remaining result
            remaining: skip pos length? result
        ] [
            break  ;; No more numbers found
        ]
    ]
    
    numbers
]

;; Usage
extract-numbers "Call 123-456-7890 or 555-0123"  ;; → ["123" "456" "7890" "555" "0123"]
```

### Text Processing

```rebol
clean-whitespace: funct [
    "Clean excessive whitespace from text"
    text [string!] "Text to clean"
    return: [string!] "Cleaned text"
] [
    ;; Replace multiple whitespace with single space:
    cleaned: copy text
    
    ;; This is a simplified example - full implementation would need
    ;; more sophisticated replacement logic
    while [find cleaned "  "] [
        cleaned: replace cleaned "  " " "
    ]
    
    trim cleaned
]
```

### Pattern Matching Utilities

```rebol
match-pattern: funct [
    "Match text against pattern with detailed result"
    text [string!] "Text to match"
    pattern [string!] "Pattern to match against"
    return: [object!] "Result object with match details"
] [
    result: RegExp text pattern
    
    make object! [
        input: text
        pattern: pattern
        matched: result
        success: string? result
        error: none? result
        no-match: result = false
    ]
]

;; Usage
result: match-pattern "hello123" "\w+\d+"
print ["Success:" result/success]
print ["Matched:" result/matched]
```

## Best Practices and Recommendations

### Pattern Design

1. **Use Specific Patterns**: Prefer specific patterns over generic ones
   
   ```rebol
   ;; Good: Specific phone number pattern
   phone-pattern: "\d{3}-\d{3}-\d{4}"
   
   ;; Avoid: Overly generic pattern
   generic-pattern: ".+"
   ```
2. **Leverage Character Classes**: Use built-in escape sequences when possible
   
   ```rebol
   ;; Good: Use escape sequences
   word-pattern: "\w+"
   
   ;; Avoid: Manual character classes when escape sequences exist
   manual-pattern: "[a-zA-Z0-9_]+"
   ```
3. **Consider Performance**: Balance functionality with performance needs
   
   ```rebol
   ;; For simple validation: Use exact quantifiers
   zip-code: "\d{5}"
   
   ;; For flexible matching: Use range quantifiers
   flexible-digits: "\d{3,5}"
   ```

### Error Handling

1. **Always Check Return Values**: Handle all three return value types
   
   ```rebol
   result: RegExp input pattern
   case [
       none? result [handle-invalid-pattern]
       string? result [handle-successful-match result]
       result = false [handle-no-match]
   ]
   ```
2. **Validate Patterns Before Use**: Check pattern validity when possible
   
   ```rebol
   rules: TranslateRegExp pattern
   either none? rules [
       print "Invalid pattern - please check syntax"
   ] [
       result: RegExp input pattern
       ;; Process result...
   ]
   ```
3. **Provide User-Friendly Error Messages**: Translate technical errors
   
   ```rebol
   validate-input: funct [input pattern description] [
       result: RegExp input pattern
       case [
           none? result [
               rejoin ["Invalid " description " pattern"]
           ]
           result = false [
               rejoin [description " format is incorrect"]
           ]
           string? result [
               "Valid input"
           ]
       ]
   ]
   ```

### Testing and Validation

1. **Test Edge Cases**: Include boundary conditions in testing
   
   ```rebol
   ;; Test empty strings
   RegExp "" "\d*"                   ;; Should handle gracefully
   
   ;; Test boundary quantifiers
   RegExp "12" "\d{2}"               ;; Exact match
   RegExp "123" "\d{2}"              ;; Should not match (too many)
   ```
2. **Validate Against Known Good/Bad Inputs**: Use comprehensive test data
   
   ```rebol
   test-cases: [
       ["123-45-6789" "\d{3}-\d{2}-\d{4}" true]   ;; Valid SSN
       ["123-456-789" "\d{3}-\d{2}-\d{4}" false]  ;; Invalid SSN
       ["abc-45-6789" "\d{3}-\d{2}-\d{4}" false]  ;; Invalid SSN
   ]
   
   foreach [input pattern expected] test-cases [
       result: RegExp input pattern
       actual: string? result
       either actual = expected [
           print ["PASS:" input]
       ] [
           print ["FAIL:" input "expected:" expected "got:" actual]
       ]
   ]
   ```
3. **Document Pattern Behavior**: Clearly document expected behavior
   
   ```rebol
   ;; Email validation pattern (basic)
   ;; Matches: word characters, @, word characters, dot, word characters
   ;; Examples: "user@domain.com" → match, "invalid" → no match
   email-pattern: "\w+@\w+\.\w+"
   ```

## Conclusion

The REBOL 3 lite PCRE RegExp engine provides a robust, well-documented API for regular expression processing. The comprehensive error handling, clear return value semantics and extensive feature support make it suitable for production use in a wide variety of applications.

### Key API Features

- **Clear Return Value Semantics**: String/false/none pattern for unambiguous results
- **Comprehensive Error Handling**: Graceful degradation with informative error states
- **Rich Feature Set**: Full support for escape sequences, quantifiers, and character classes
- **Performance Optimization**: Built-in boundaries and efficient implementations
- **Extensive Documentation**: Complete usage examples and best practices

### Recommended Usage Patterns

1. Always check return values for proper error handling
2. Use specific patterns for better performance and clarity
3. Leverage built-in escape sequences and character classes
4. Test edge cases and boundary conditions thoroughly
5. Document pattern behavior for maintainability

The API is designed for both simple pattern matching tasks and complex text processing applications, providing the flexibility and reliability needed for production REBOL 3 applications.

**API Status**: ✅ **BETA READY** with comprehensive documentation and examples
