# Rebol Coding Standards and Best Practices

## Function Definition Standards

### Use `funct` Instead of `func`
- **Rule**: Always use `funct` for function definitions to ensure proper automatic local variable scoping
- **Rationale**: `funct` automatically makes all variables local, preventing accidental global variable pollution
- **Example**:
  ```rebol
  ;; CORRECT
  my-function: funct [arg1 [string!] arg2 [integer!]] [
      local-var: arg1 + arg2
      return local-var
  ]
  
  ;; AVOID
  my-function: func [arg1 [string!] arg2 [integer!] /local local-var] [
      local-var: arg1 + arg2
      return local-var
  ]
  ```

### Parameter Passing for Global State
- **Rule**: Pass global variables as function arguments rather than accessing them directly
- **Rationale**: Ensures functions are pure, testable, and don't have hidden dependencies
- **Pattern**: Functions that need global state should accept parameters and return updated values
- **Example**:
  ```rebol
  ;; CORRECT - parameter passing
  update-counter: funct [
      current-count [integer!]
      increment [integer!]
      return: [integer!]
  ] [
      current-count + increment
  ]
  
  ;; AVOID - direct global access
  update-counter: funct [increment [integer!]] [
      global-count: global-count + increment
  ]
  ```

### Multiple Return Value Capture
- **Rule**: Use `set [var1 var2 var3 var4] function-call` pattern for capturing multiple return values
- **Rationale**: Clear, explicit handling of multiple return values
- **Example**:
  ```rebol
  set [test-count pass-count fail-count all-tests-passed] 
      assert-equal expected actual description test-count pass-count fail-count all-tests-passed
  ```

## Error Handling Standards

### Use Modern `try` Patterns
- **Rule**: Use proper `try` and `set/any` patterns instead of deprecated functions
- **Rationale**: `disarm` and similar functions are deprecated; modern patterns are more reliable
- **Example**:
  ```rebol
  ;; CORRECT
  result: none
  set/any 'result try [
      risky-operation
  ]
  either error? result [
      handle-error result
  ] [
      process-result result
  ]
  
  ;; AVOID - deprecated pattern
  if error? try [
      risky-operation
  ] [
      err: disarm error  ;; disarm is deprecated
  ]
  ```

## Output and Formatting Standards

### Idiomatic Newline Usage
- **Rule**: Use `print "^/text line"` instead of separate print statements for newlines
- **Rule**: When `^/` cannot be used and a newline is needed, use `prin lf` instead of `print ""`
- **Rationale**: More concise and idiomatic Rebol style
- **Example**:
  ```rebol
  ;; CORRECT
  print "^/Starting tests..."
  print "^/--- Section Header ---"
  
  ;; When ^/ cannot be used:
  prin lf
  print "Starting tests..."
  
  ;; AVOID
  print ""
  print "Starting tests..."
  print ""
  print "--- Section Header ---"
  ```

## Script Execution Standards

### Use `r3` Command
- **Rule**: Scripts should be executable with `r3` command instead of `rebol3`
- **Rationale**: `r3` is the standard command for Rebol 3 Oldes execution
- **Usage**: `r3 -s script-name.r`

## Variable Naming Standards

### Descriptive Variable Names
- **Rule**: Use descriptive variable names, avoid single letters except for very short-lived loop counters
- **Rule**: Avoid generic words like "data" - be specific about the type and purpose of data
- **Rule**: Variable names should be self-documenting and indicate both content type and usage context
- **Examples**:
  ```rebol
  ;; GOOD - specific and descriptive
  test-results: []
  user-input-string: ""
  file-content-blocks: []
  customer-records: []
  sensor-readings: [1.2 3.4 5.6]
  configuration-settings: make object! [...]
  
  ;; AVOID - too generic or unclear
  d: []        ;; too short
  data: ""     ;; too generic - what kind of data?
  x: []        ;; meaningless
  info: []     ;; vague - what information?
  stuff: []    ;; non-descriptive
  ```

### Test-Specific Naming Conventions
- **Rule**: Use descriptive suffixes for test collections: `-test-samples`, `-test-data`, `-test-cases`
- **Rule**: Use clear prefixes for test state variables: `current-`, `expected-`, `actual-`
- **Rule**: Avoid abbreviations in test function parameters (use `test-count` not `tc`)
- **Examples**:
  ```rebol
  ; GOOD - test data naming
  integer-test-samples: [0 1 -1 42 -42]
  string-test-data: ["" "hello" "multi^/line"]
  expected-result: "expected output"
  actual-result: function-under-test input
  current-test-count: 0
  
  ; AVOID - unclear test naming
  test-ints: [0 1 -1 42 -42]
  exp: "expected output"
  act: function-under-test input
  tc: 0
  ```

## Code Organization Standards

### Function Documentation
- **Rule**: All functions should have clear docstrings explaining purpose and parameters
- **Rule**: Include return type specifications where helpful
- **Example**:
  ```rebol
  process-test-data: funct [
      "Process test data and return formatted results"
      input-data [block!] "Raw test data to process"
      format-type [word!] "Output format: 'summary or 'detailed"
      return: [string!] "Formatted test results"
  ] [
      ;; function implementation
  ]
  ```

### Code Comments
- **Rule**: Use `;;` instead of single `;` to make comments stand out
- **Rule**: Remove space characters in comment divider lines (use `;;=======` not `;; =======`)
- **Rule**: Explain both WHAT and WHY in code comments
- **Rule**: Use section headers with consistent formatting
- **Example**:
  ```rebol
  ;;=============================================================================
  ;; TEST DATA SETUP SECTION
  ;;=============================================================================
  ;; This section defines comprehensive test data collections for all supported
  ;; data types that the function can operate on.
  ```

## Testing Standards

### Test Structure
- **Rule**: Group tests logically by functionality or data type
- **Rule**: Include hypothesis comments explaining expected behavior
- **Rule**: Use consistent test naming patterns

### Test Data
- **Rule**: Create comprehensive test data covering edge cases
- **Rule**: Use descriptive variable names for test data collections
- **Rule**: Include both positive and negative test cases

### Test Coverage Requirements
- **Rule**: Aim for systematic coverage of all refinement combinations for functions that support them
- **Rule**: Test edge cases including empty values, boundary conditions, and error scenarios
- **Rule**: Include both positive tests (expected success) and negative tests (expected errors)
- **Rule**: Document the total number of test cases and coverage metrics

### Test Execution and Reporting
- **Rule**: Provide comprehensive test summaries with statistics and success rates
- **Rule**: Include empirical findings and unexpected behaviors in test reports
- **Rule**: Use consistent test result formatting with MANDATORY status indicators:
  - ✅ PASSED (never "PASS" or "✓")
  - ❌ FAILED (never "FAIL" or "✗") 
  - ⚠️  WARNING (for warnings and cautions)
- **Rule**: NEVER use unprintable Unicode characters (party emoji, celebration characters, etc.)
- **Rule**: Always use long-form "PASSED" and "FAILED" for consistent search patterns

## Advanced Function Standards

### Zero-Argument Functions
- **Rule**: For functions accepting zero arguments, use the `does` keyword as a more concise and idiomatic constructor
- **Rule**: Use `funct` for functions with parameters, `does` for parameterless functions
- **Rationale**: `does` is specifically designed for zero-argument functions and is more readable
- **Example**:
  ```rebol
  ;; CORRECT - parameterless function
  initialize-system: does [
      setup-globals
      load-configuration
  ]
  
  ;; CORRECT - function with parameters
  process-user-input: funct [input-string [string!]] [
      parse input-string user-grammar
  ]
  
  ;; AVOID - use does for parameterless functions
  initialize-system: funct [] [
      setup-globals
      load-configuration
  ]
  ```

### String Literal Standards
- **Rule**: To embed a double quote within a string, use two consecutive double quotes `""`
- **Rule**: Alternative for complex quotes: use curly braces `{}` for strings containing many quotes
- **Rule**: The `\"` sequence is invalid and prohibited in REBOL
- **Rule**: Backslashes in strings do NOT need escaping - use single backslash `\` not double `\\`
- **Rule**: In test descriptions and output strings, use single backslash for pattern sequences like `\d`, `\w`, `\s`
- **Important Distinction**: REBOL uses caret (`^`) for escape sequences, backslash (`\`) is for pattern sequences
- **Example**:
  ```rebol
  ;; CORRECT - quotes using double quote method
  message: "He said ""Hello"" to me"
  
  ;; CORRECT - quotes using curly brace method (cleaner for complex cases)
  message: {He said "Hello" to me}
  complex-message: {The command is: print "Hello ""World""!"}
  
  ;; CORRECT - backslashes (single backslash for pattern sequences)
  test-description: "\d matches single digit"
  pattern-info: "Use \w+ for word characters"
  
  ;; CORRECT - REBOL escape sequences use caret notation (NOT backslash)
  escape-example: "Newline is ^/ and tab is ^-"  ;; ^ is REBOL's escape character
  
  ;; INVALID - will cause syntax error
  message: "He said \"Hello\" to me"
  
  ;; INCORRECT - double backslashes (avoid this)
  test-description: "\\d matches single digit"  ;; Wrong!
  pattern-info: "Use \\w+ for word characters"  ;; Wrong!
  ```

## 🚨 CRITICAL: Backslash Prevention Standards

### The Double Backslash Problem
This is a **recurring, time-consuming issue** that must be prevented systematically. REBOL 3 Oldes handles backslashes differently from most programming languages.

### MANDATORY Backslash Prevention Rules

#### Rule 1: Single Backslash Only (CRITICAL)
- **NEVER**: Use double backslashes (`\\`) in REBOL 3 Oldes strings for pattern sequences or escape attempts
- **EXCEPTION**: Double backslashes are legitimate in URLs (`https:\\`) and Windows file paths (`C:\\path\\file`)
- **CLARIFICATION**: Backslash (`\`) is a LITERAL character in REBOL 3 Oldes, NOT an escape character
- **REBOL ESCAPE SEQUENCES**: Use caret notation (`^/` for newline, `^-` for tab, `^M` for carriage return)
- **RATIONALE**: REBOL 3 Oldes uses caret (^) for escape sequences, unlike C/Java/JavaScript which use backslash
- **COST**: Fixing this issue takes 2-4 hours; prevention takes 5 minutes

#### Rule 2: Pattern Sequence Standards (MANDATORY)
- **CORRECT**: `"\d"` (2 characters: backslash + d)
- **INCORRECT**: `"\\d"` (3 characters: backslash + backslash + d)
- **APPLIES TO**: All pattern escape sequences: `\d`, `\w`, `\s`, `\D`, `\W`, `\S`, `\.`, `\+`
- **VALIDATION**: Always test pattern length: `length? "\d"` should equal 2

#### Rule 3: Pre-Coding Validation (REQUIRED)
- **BEFORE CODING**: Test backslash behavior in REBOL 3 Oldes first
- **VALIDATION TEST**: 
  ```rebol
  test-pattern: "\d"
  print ["Length should be 2:" length? test-pattern]
  print ["Characters:" mold to-block test-pattern]
  ;; Expected: Length should be 2: true, Characters: ["\d"]
  ```

#### Rule 4: Code Review Checklist (MANDATORY)
- **SEARCH**: Always search code for `\\` patterns before committing
- **COMMAND**: Run `grepSearch` with query `\\` in all source files
- **VERIFY**: Ensure no double backslash patterns exist in pattern sequences (e.g., `\\d`, `\\w`)
- **EXCEPTION CHECK**: Verify double backslashes in URLs and file paths are legitimate
- **TEST**: Verify pattern sequences work with single backslashes

#### Rule 5: Documentation Standards (REQUIRED)
- **DESCRIPTIONS**: When describing backslash issues, use correct REBOL syntax
- **EXAMPLES**: Always show actual REBOL code, not pseudo-code from other languages
- **AVOID**: Using multiple backslashes in explanatory text or comments

### Prevention Strategies (IMPLEMENT IMMEDIATELY)

#### Strategy 1: Automated Validation
```rebol
;; Add to all pattern-related test suites:
validate-single-backslashes: funct [pattern [string!]] [
    ;; Check for prohibited double backslashes in pattern sequences
    if find pattern "\\d" [return "ERROR: Double backslash \\d found"]
    if find pattern "\\w" [return "ERROR: Double backslash \\w found"]  
    if find pattern "\\s" [return "ERROR: Double backslash \\s found"]
    if find pattern "\\D" [return "ERROR: Double backslash \\D found"]
    if find pattern "\\W" [return "ERROR: Double backslash \\W found"]  
    if find pattern "\\S" [return "ERROR: Double backslash \\S found"]
    
    ;; Allow legitimate double backslashes in URLs and file paths
    ;; Note: URLs like "https:\\" and paths like "C:\\path" are valid
    true
]
```

#### Strategy 2: Emergency Fix Protocol
When double backslash issues are discovered:
1. **STOP**: Halt all development immediately
2. **SCAN**: Search entire codebase for `\\` patterns  
3. **CATEGORIZE**: Separate critical (source) from cosmetic (docs)
4. **FIX**: Address critical source code issues first
5. **TEST**: Validate all fixes work correctly
6. **DOCUMENT**: Record incident and prevention measures

### Cost-Benefit Analysis
- **PREVENTION COST**: 5-10 minutes per coding session
- **FIXING COST**: 2-4 hours of debugging, testing, and validation
- **EFFICIENCY RATIO**: Prevention is 20x more efficient than fixing
- **RECOMMENDATION**: Always prevent rather than fix

### Advanced Error Handling
- **Rule**: For advanced error trapping within functions (catching specific error types), `try/with` should be used
- **Rule**: The `try/except` construct does not exist in REBOL 3 Oldes and should not be used
- **Example**:
  ```rebol
  ;; CORRECT - modern error handling with try/with
  result: try/with [
      risky-operation
  ] funct [error-obj] [
      either error-obj/type = 'access [
          handle-access-error error-obj
      ] [
          handle-general-error error-obj
      ]
  ]
  
  ;; AVOID - deprecated pattern with disarm
  if error? try [
      risky-operation
  ] [
      err: disarm error  ;; disarm is deprecated
  ]
  ```

## Program Flow Control Standards

### Conditional Logic Rules
- **Rule**: The `else` keyword does not exist in REBOL 3 Oldes and is strictly prohibited
- **Rule**: All conditional logic must use `either condition [true-branch] [false-branch]`, `case`, or `switch`
- **Rule**: Use `if` statement only for single-branch conditions (e.g., guard clauses)
- **Rule**: Use `either` for binary decisions, `case` for 3+ branches, and `switch` for value matching
- **Clarification**: `either` is REBOL's built-in if-else construct - it is not the same as the non-existent `else` keyword
- **Examples**:
  ```rebol
  ;; CORRECT - binary decision
  result: either condition [
      handle-true-case
  ] [
      handle-false-case
  ]
  
  ;; CORRECT - single branch guard clause
  if not valid-input? data [
      return error "Invalid input"
  ]
  
  ;; CORRECT - multiple branches
  action: case [
      score > 90 ["excellent"]
      score > 70 ["good"]
      score > 50 ["average"]
      true ["needs improvement"]
  ]
  
  ;; CORRECT - value matching
  result: switch data-type [
      'integer [process-integer data]
      'string [process-string data]
      'block [process-block data]
  ]
  
  ;; PROHIBITED - else keyword does not exist in REBOL
  if condition [
      do-something
  ] else [
      do-something-else  ;; This will cause a "else has no value" error
  ]
  ```

## Loop Construct Standards (ENHANCED)

### Complete Loop Coverage for REBOL 3 Oldes
- **Rule**: Use the most appropriate loop construct for the specific use case
- **Rule**: Be consistent with loop choice within each module
- **Note**: This section provides comprehensive coverage of all available REBOL loop constructs

#### Available Loop Constructs
```rebol
;; REPEAT - Counter-based repetition
repeat i 5 [print ["Count:" i]]

;; FOREACH - Iterate over series elements
foreach item [a b c] [print item]

;; WHILE - Conditional loop (test first)
counter: 1
while [counter <= 3] [
    print counter
    counter: counter + 1
]

;; UNTIL - Loop until condition becomes true
counter: 1
until [
    print counter
    counter: counter + 1
    counter > 3
]

;; FOR - Numeric range with step
for i 1 10 1 [print i]           ;; Count from 1 to 10 by 1
for i 10 1 -1 [print i]          ;; Count from 10 to 1 by -1
for i 0 100 5 [print i]          ;; Count from 0 to 100 by 5

;; FORALL - Iterate with series position
data: [a b c]
forall data [print ["Position:" index? data "Value:" first data]]

;; FORSKIP - Skip-based iteration
data: [1 2 3 4 5 6]
forskip data 2 [print ["Pair:" first data second data]]
```

#### Loop Selection Guidelines
- **Use `repeat`**: When you need a simple counter
- **Use `foreach`**: When iterating over series elements
- **Use `while`**: When condition is tested before each iteration
- **Use `until`**: When condition is tested after each iteration
- **Use `for`**: When you need numeric range with custom step
- **Use `forall`**: When you need both position and value
- **Use `forskip`**: When processing series in chunks

## Enhanced Error Handling Standards

### Complete Error Handling Coverage for REBOL 3 Oldes
- **Rule**: Choose the most appropriate error handling method for the specific use case
- **Rule**: Be consistent with error handling approach within each module
- **Note**: This section provides comprehensive coverage of all available REBOL error handling constructs

#### Available Error Handling Constructs
```rebol
;; TRY - Basic error catching
result: try [risky-operation]
if error? result [handle-error result]

;; TRY with SET/ANY - Capture error or result
set/any 'result try [risky-operation]
either error? result [
    handle-error result
] [
    process-result result
]

;; TRY/WITH - Advanced error handling with custom error handler
result: try/with [
    risky-operation
] funct [error-obj] [
    either error-obj/type = 'access [
        handle-access-error error-obj
    ] [
        handle-general-error error-obj
    ]
]

;; CATCH/THROW - Exception-style handling
result: catch [
    if error-condition [
        throw "Error occurred"
    ]
    if warning-condition [
        throw "Warning: proceeding with caution"
    ]
    "Success"
]
;; result will be "Error occurred", "Warning: proceeding with caution", or "Success"

;; ATTEMPT - Try with none on error
result: attempt [risky-operation]
either result [
    process-result result
] [
    print "Operation failed, got none"
]
```

#### Error Handling Selection Guidelines
- **Use `try`**: For basic error detection with manual checking
- **Use `try` with `set/any`**: When you need to capture both errors and results
- **Use `try/with`**: For advanced error handling with custom error processing
- **Use `catch/throw`**: For exception-style control flow with multiple exit points
- **Use `attempt`**: When you want none instead of error objects on failure

## Operator Precedence Standards

### Explicit Parentheses for Clarity
- **Rule**: Rebol's operator precedence can be non-obvious, especially with function calls
- **Rule**: All non-trivial conditional expressions must use explicit parentheses `()` to ensure correct order of evaluation
- **Examples**:
  ```rebol
  ;; CORRECT - explicit parentheses
  if (length? my-block) < 2 [
      handle-short-block
  ]
  
  if (type? value) = string! [
      process-string value
  ]
  
  result: (first my-block) + (last my-block)
  
  ;; FORBIDDEN - ambiguous precedence
  if length? my-block < 2 [
      handle-short-block
  ]
  
  if type? value = string! [
      process-string value
  ]
  ```

## Diagnostic and Testing Standards

### Comprehensive Test Data Organization
- **Rule**: Organize test data in descriptive collections with inline comments explaining each test case
- **Rule**: Use consistent naming patterns: `{type}-test-samples`, `{category}-test-data`
- **Rule**: Include edge cases, boundary values, and representative samples for each data type
- **Example**:
  ```rebol
  ;; CORRECT - comprehensive test data organization
  string-test-samples: [
      ""                   ;; empty string
      "hello"              ;; simple string
      "Hello World!"       ;; string with space and punctuation
      "multi^/line^/text"  ;; multi-line string with line feeds
      "tab^-separated"     ;; string with tab character
      "quote^"test^""      ;; string with embedded quotes
      "unicode: ñáéíóú"    ;; string with unicode characters
  ]
  
  ;; AVOID - unclear test data
  test-strings: ["" "hello" "Hello World!" "multi^/line^/text"]
  ```

### Empirical Testing Methodology
- **Rule**: Test actual behavior rather than assumed behavior, especially for edge cases
- **Rule**: Document empirical discoveries with clear expected vs actual comparisons
- **Rule**: Use descriptive comments to explain why specific test cases are included
- **Example**:
  ```rebol
  ;; CORRECT - empirical testing with documentation
  ;; EMPIRICAL DISCOVERY: negative limits return empty string instead of error
  expected-result: ""  ;; Discovered behavior: graceful handling
  actual-result: function-under-test/refinement data -5
  description: "negative limit should handle gracefully (empirical finding)"
  
  set [test-count pass-count fail-count all-tests-passed]
      assert-equal expected-result actual-result description test-count pass-count fail-count all-tests-passed
  ```

### Multi-Return Value State Management
- **Rule**: For functions that need to track multiple state values, pass all state as parameters and return updated state
- **Rule**: Use descriptive parameter names for state values (avoid abbreviations like `tc`, `pc`)
- **Rule**: Document the return value structure clearly
- **Example**:
  ```rebol
  ;; CORRECT - clear state management
  test-function: funct [
      "Test function with comprehensive state tracking"
      test-value [any-type!] "Value to test"
      current-test-count [integer!] "Current number of tests executed"
      current-pass-count [integer!] "Current number of tests passed"
      current-fail-count [integer!] "Current number of tests failed"
      all-tests-passing [logic!] "Whether all tests are currently passing"
      return: [block!] "Updated [test-count pass-count fail-count all-passing]"
  ] [
      ;; Function implementation
      ;; ... test logic here ...
      reduce [current-test-count current-pass-count current-fail-count all-tests-passing]
  ]
  ```

### Enhanced String Comparison for Testing
- **Rule**: For multi-line string comparisons in tests, implement line-by-line diff output
- **Rule**: Normalize line endings before comparison to handle cross-platform differences
- **Rule**: Provide detailed failure output showing exactly where differences occur
- **Example**:
  ```rebol
  ;; CORRECT - enhanced multi-line string comparison
  compare-multiline-strings: funct [
      "Compare multi-line strings with detailed diff output"
      expected [string!] "Expected string"
      actual [string!] "Actual string"
      description [string!] "Test description"
  ] [
      ;; Normalize line endings for consistent comparison
      expected-normalized: replace/all copy expected "^M^/" "^/"
      actual-normalized: replace/all copy actual "^M^/" "^/"
      
      either expected-normalized = actual-normalized [
          print ["  ✅ PASSED:" description]
      ] [
          print ["  ❌ FAILED:" description]
          print ["    Expected: " expected-normalized]
          print ["    Actual:   " actual-normalized]
          
          ;; For multi-line strings, show line-by-line diff
          if any [find expected-normalized "^/" find actual-normalized "^/"] [
              expected-lines: split expected-normalized "^/"
              actual-lines: split actual-normalized "^/"
              print "    Line-by-line comparison:"
              
              max-lines: max length? expected-lines length? actual-lines
              repeat line-num max-lines [
                  exp-line: either line-num <= length? expected-lines [
                      pick expected-lines line-num
                  ] ["<missing>"]
                  act-line: either line-num <= length? actual-lines [
                      pick actual-lines line-num  
                  ] ["<missing>"]
                  
                  if exp-line <> act-line [
                      print ["      Line" line-num "- Expected:" exp-line]
                      print ["      Line" line-num "- Actual:  " act-line]
                  ]
              ]
          ]
      ]
  ]
  ```

## Documentation Standards for Diagnostic Tools

### Empirical Findings Documentation
- **Rule**: Document all empirical discoveries with clear evidence and implications
- **Rule**: Distinguish between expected behavior and actual observed behavior
- **Rule**: Provide practical implications for each finding
- **Example**:
  ```rebol
  ;; CORRECT - empirical findings documentation
  ;; EMPIRICAL FINDING: Negative /part Limits - Graceful Error Tolerance
  ;; 
  ;; DISCOVERY: Negative values for /part limit are treated as zero, returning empty strings.
  ;; 
  ;; EVIDENCE:
  ;;   mold/part [1 2 3] -5    ;; => "" (empty string, not error)
  ;;   mold/part "hello" -10   ;; => "" (empty string, not error)
  ;; 
  ;; EXPECTED vs ACTUAL:
  ;;   Expected: Error condition for invalid negative limits
  ;;   Actual: Graceful handling, returns "" (empty string)
  ;; 
  ;; IMPLICATIONS:
  ;;   - Robust error tolerance in boundary conditions
  ;;   - Scripts won't crash on negative limit values
  ;;   - Defensive programming approach in implementation
  ```

### User Guide Creation
- **Rule**: Create comprehensive user guides based on empirical testing results
- **Rule**: Include practical examples for all major use cases and refinement combinations
- **Rule**: Provide troubleshooting guidance based on observed edge cases
- **Rule**: Structure guides with clear sections: basic usage, refinements, data types, edge cases, best practices

### Test Coverage Reporting
- **Rule**: Report comprehensive statistics including test counts, success rates, and coverage metrics
- **Rule**: Break down results by category (data types, refinements, edge cases)
- **Rule**: Include quality assessment indicators (completeness, coverage, reliability)
- **Example**:
  ```rebol
  ;; CORRECT - comprehensive test reporting
  print-diagnostic-summary: funct [
      "Display comprehensive diagnostic test summary"
      total-tests [integer!] "Total number of tests executed"
      passed-tests [integer!] "Number of tests that passed"
      failed-tests [integer!] "Number of tests that failed"
      categories-tested [integer!] "Number of test categories covered"
  ] [
      print "^/=========================================="
      print "DIAGNOSTIC PROBE - COMPREHENSIVE TEST SUMMARY"
      print "=========================================="
      
      print "--- CORE TEST STATISTICS ---"
      print ["Total Tests Executed:" total-tests]
      print ["Tests Passed:" passed-tests]
      print ["Tests Failed:" failed-tests]
      
      if total-tests > 0 [
          success-rate: to integer! (passed-tests * 100) / total-tests
          print ["Overall Success Rate:" success-rate "%"]
          
          reliability-score: either success-rate >= 95 ["EXCELLENT"] [
              either success-rate >= 90 ["VERY GOOD"] [
                  either success-rate >= 80 ["GOOD"] ["NEEDS IMPROVEMENT"]
              ]
          ]
          print ["Test Reliability:" reliability-score]
      ]
      
      print "^/--- COVERAGE METRICS ---"
      print ["Test Categories Covered:" categories-tested]
      print ["Quality Assessment: Based on empirical evidence"]
  ]
  ```

## Parse Standards for Pattern Matching Systems

### Case-Sensitive Parsing Requirements
- **Rule**: When implementing pattern matching systems that need to distinguish between uppercase and lowercase characters, always use `parse/case` for case-sensitive parsing
- **Rationale**: Rebol's default `parse` behavior is case-insensitive, which can cause critical bugs in pattern matching systems
- **Critical Discovery**: Pattern engines that handle escape sequences like `\d` (digits) vs `\D` (non-digits) will fail without case-sensitive parsing
- **Problem**: Case-insensitive parsing causes both `\d` and `\D` to match the same pattern, breaking negated character classes
- **Example**:
  ```rebol
  ;; INCORRECT - case-insensitive parsing (default)
  parse "\D" [
      "\" [
          "d" (print "Matches both \\d and \\D incorrectly!")
          |
          "D" (print "Never reached due to case-insensitive matching")
      ]
  ]
  
  ;; CORRECT - case-sensitive parsing
  parse/case "\D" [
      "\" [
          "d" (print "Matches only \d")
          |
          "D" (print "Matches only \D - correct!")
      ]
  ]
  ```

### Pattern Engine Implementation Standards
- **Rule**: All pattern translation functions must use `parse/case` to properly distinguish escape sequences
- **Rule**: Test suites for pattern engines must verify both positive (`\d`, `\w`, `\s`) and negated (`\D`, `\W`, `\S`) escape sequences
- **Rule**: Document case-sensitivity requirements clearly in pattern engine documentation
- **Empirical Finding**: The following escape sequence pairs require case-sensitive parsing:
  - `\d` (digits) vs `\D` (non-digits)
  - `\w` (word characters) vs `\W` (non-word characters)  
  - `\s` (whitespace) vs `\S` (non-whitespace)
- **Testing Requirement**: Comprehensive test suites should verify that negated character classes work independently of their positive counterparts

### Pattern Matching Debugging Standards
- **Rule**: When debugging pattern matching issues, always test case sensitivity as a potential root cause
- **Rule**: Use character-by-character analysis to verify string contents when patterns fail unexpectedly
- **Rule**: Test both `parse` and `parse/case` behavior when troubleshooting pattern recognition
- **Example Debug Process**:
  ```rebol
  ;; CORRECT - systematic case sensitivity debugging
  test-pattern: "\D"
  print ["Pattern content: " mold test-pattern]
  print ["Character codes: " mold to-block test-pattern]
  
  ;; Test case-insensitive behavior
  print "Case-insensitive parse:"
  parse test-pattern [
      "\" ["d" (print "  Matched 'd'") | "D" (print "  Matched 'D'")]
  ]
  
  ;; Test case-sensitive behavior  
  print "Case-sensitive parse:"
  parse/case test-pattern [
      "\" ["d" (print "  Matched 'd'") | "D" (print "  Matched 'D'")]
  ]
  ```

## Git and Version Control Standards

### Manual Confirmation Before Commits
- **Rule**: ALWAYS manually confirm that fixes and changes work before executing git add/commit operations
- **Rationale**: Prevents broken code from entering the repository and maintains code quality
- **Process**: 
  1. Make code changes
  2. Test changes thoroughly (run test suites, verify functionality)
  3. Manually confirm the fix works as expected
  4. Only then proceed with git add and git commit
- **Example Workflow**:
  ```bash
  # After making changes
  r3 -s tests/unified-comprehensive-test-suite.r3  # Test first
  r3 -s test-specific-fix.r3                       # Verify fix works
  # Only after manual confirmation:
  git add .
  git commit -m "Description of verified changes"
  ```

### Commit Message Standards
- **Rule**: Use descriptive commit messages that explain what was changed and why
- **Rule**: Include test results and success rates when applicable
- **Rule**: Reference issue numbers or requirements when relevant

These standards apply to all Rebol development work and should be followed consistently across all projects.
