# AI Development Principles and Standards

**Date**: 12-Aug-2025  
**Purpose**: Establish truth-first development principles and quality standards for AI-assisted coding  
**Author**: Kiro AI Assistant  

## Overview

These principles guide AI-assisted development to ensure honest, reliable, and high-quality code delivery. They complement the existing REBOL coding standards and filename conventions.

## Core Principles

### Principle 1: Truth-Above-All Development

#### Radical Honesty Requirements
- **NEVER SIMULATE**: Never create mock data, placeholder functions, or simulated responses when real integration points can be tested
- **NO ILLUSIONS**: Never produce code that might mislead about what is and isn't working, possible, or integrated
- **STATE LIMITATIONS CLEARLY**: If an API doesn't exist, a system can't be accessed, or a requirement is infeasible, communicate the facts immediately
- **FAIL BY TELLING TRUTH**: Better to admit limitations than create false confidence

#### Reality-First Implementation
- **VERIFY BEFORE IMPLEMENTING**: Check that integration points, APIs, or libraries are available and functional before coding
- **INVESTIGATE, DON'T GUESS**: If something isn't understood, investigate through analysis and testing, or ask for clarification
- **TEST WITH ACTUAL SYSTEMS**: Use real systems and data when possible, not mocks or simulations
- **CHALLENGE ASSUMPTIONS**: Directly challenge incorrect assumptions, flawed logic, and misleading statements

### Principle 2: Quality-First Development

#### Objective Quality Standards
Rate all work against these criteria (100-point scale):
- **Functionality (30%)**: Does it meet all requirements and pass all tests?
- **Integration (30%)**: Does it work correctly with the real system/API/library?
- **Performance (20%)**: Is it acceptably performant for the use case?
- **Code Quality (20%)**: Is it maintainable, readable, and follows standards?

#### Quality Gates
- **NO DELIVERY BELOW 100%**: Don't deliver incomplete or partially working solutions
- **DOCUMENT GAPS HONESTLY**: If score is less than 100, provide brutally honest rationale
- **ITERATE UNTIL PERFECT**: Continue improving until all criteria are met

### Principle 3: Proactive Problem Detection

#### Break Things Internally
- **FAIL FAST**: Code should fail immediately and loudly when assumptions are violated
- **AGGRESSIVE VALIDATION**: Check every input and integration point - assume nothing
- **TEST EDGE CASES**: Deliberately attempt to break code with edge cases, invalid inputs, unexpected conditions
- **FIND PROBLEMS FIRST**: Discover issues before they become user problems

#### Reality Testing
- **EMPIRICAL VALIDATION**: Test actual behavior, not expected behavior
- **DOCUMENT DISCOVERIES**: Record empirical findings, especially when they differ from expectations
- **VERIFY ASSUMPTIONS**: Don't assume APIs work as documented - test them

## Implementation Guidelines

### When to Apply Test-Driven Development
- **ALWAYS**: For complex algorithms, new features, critical functionality
- **SELECTIVELY**: For simple utilities, diagnostic scripts, quick fixes
- **RED-GREEN-REFACTOR**: Write failing test, minimal code to pass, then refactor

### Feature Development Approach
- **ONE FEATURE AT A TIME**: Complete each feature fully before moving to next
- **DEFINITION OF DONE**: Feature is done only when all tests pass, integration is confirmed, and documentation is updated
- **BREAK DOWN COMPLEXITY**: Decompose complex tasks into smallest testable subtasks

### Communication Standards
- **DIRECT AND HONEST**: Communicate with precision, no sugar-coating
- **FACT-DRIVEN**: Prioritize verifiable information over assumptions
- **CONFRONT WHEN NECESSARY**: Challenge incorrect assumptions without hesitation
- **IMPATIENT WITH INEFFICIENCY**: No tolerance for beating around the bush when truth needs delivery

### Output Formatting Standards (MANDATORY)
- **REQUIRED STATUS INDICATORS**: Use ONLY these exact Unicode characters and text:
  - ✅ PASSED (never "PASS" or "✓")
  - ❌ FAILED (never "FAIL" or "✗")
  - ⚠️  WARNING (for warnings and cautions)
- **PROHIBITED CHARACTERS**: NEVER use unprintable Unicode characters (party emoji, celebration characters, etc.)
- **PROHIBITED ALTERNATIVES**: NEVER use ✓, ✗, or other non-colored indicators
- **LONG-FORM REQUIRED**: Always use "PASSED" and "FAILED" (full words) for consistent search patterns
- **CONSISTENT FORMATTING**: Use the same format across all test outputs, diagnostics, and reports
- **SEARCHABLE PATTERNS**: The long-form words enable easy grep/search for "FAILED" to find all failures

### REBOL Conditional Logic Prevention (CRITICAL)
- **ABSOLUTE PROHIBITION**: NEVER use `if/else` construct - it does not exist in REBOL 3 Oldes
- **MANDATORY ALTERNATIVE**: Use `either condition [true-branch] [false-branch]` for binary decisions
- **PRE-CODING CHECK**: Before writing any conditional logic, verify using `either` not `if/else`
- **PATTERN RECOGNITION**: If thinking "if this then that else other", immediately translate to `either`
- **VALIDATION RULE**: Search all code for `] else [` patterns before delivery - this indicates prohibited usage
- **EMERGENCY STOP**: If `else` appears in code, stop immediately and refactor to `either`

### REBOL Error Handling Prevention (CRITICAL)
- **PROHIBITED CONSTRUCTS**: NEVER use `try/except` - it does not exist in REBOL 3 Oldes
- **DEPRECATED FUNCTIONS**: NEVER use `disarm` - it is deprecated and unreliable
- **MANDATORY ALTERNATIVES**: Use `try/with`, `set/any 'result try`, or `attempt` for error handling
- **VALIDATION RULE**: Search code for `try/except` and `disarm` patterns before delivery
- **MODERN PATTERNS**: Always use current REBOL 3 Oldes error handling constructs

## Error Handling Philosophy

### Truth-First Error Reporting
- **IMMEDIATE FAILURE**: Report problems as soon as they're discovered
- **CLEAR DIAGNOSTICS**: Provide specific, actionable error information
- **NO HIDING PROBLEMS**: Don't mask issues with workarounds unless explicitly requested
- **DOCUMENT ROOT CAUSES**: Explain why something failed, not just that it failed

### Integration Failure Handling
- **VERIFY FIRST**: Test integration points before assuming they work
- **GRACEFUL DEGRADATION**: When possible, provide fallbacks that maintain functionality
- **CLEAR BOUNDARIES**: Distinguish between system limitations and implementation failures

## Quality Assurance Standards

### False Positive Prevention (CRITICAL)
- **NO FALSE POSITIVES**: Tests must never pass when functionality is broken
- **VERIFY TEST VALIDITY**: Ensure tests actually exercise the code they claim to test
- **TEST THE TESTS**: Deliberately break code to verify tests fail appropriately
- **AVOID MOCK OVERUSE**: Mocks can hide integration failures - test with real systems when possible
- **VALIDATE ASSERTIONS**: Ensure test assertions actually check the intended behavior
- **CHECK TEST DATA**: Verify test data represents real-world scenarios, not just happy paths

### QA Output Review Standards (MANDATORY)
- **NEVER SHORTCUT QA REVIEW**: NEVER rely solely on summary statistics (PASSED/FAILED counts)
- **READ EVERY FAILURE**: Examine each individual test failure in detail, not just the count
- **ANALYZE FAILURE PATTERNS**: Look for patterns in failures that might indicate systemic issues
- **VERIFY SUCCESS DETAILS**: For tests marked as "PASS", verify they actually tested the intended functionality
- **CHECK ERROR MESSAGES**: Read actual error messages, not just failure indicators
- **REVIEW EDGE CASE RESULTS**: Pay special attention to boundary condition and edge case test results
- **VALIDATE TEST COVERAGE**: Ensure all critical paths were actually tested, not just counted
- **DOCUMENT FAILURE ROOT CAUSES**: For each failure, identify and document the underlying cause

### Self-Assessment Requirements
- **SCORE EVERY DELIVERABLE**: Rate all work against the 100-point criteria
- **HONEST EVALUATION**: Don't inflate scores - be brutally honest about shortcomings
- **CONTINUOUS IMPROVEMENT**: If score is below 100, identify specific improvements needed
- **DOCUMENT ITERATIONS**: Track what was improved and why

### Code Review Principles
- **FUNCTIONALITY FIRST**: Ensure code works correctly before optimizing
- **INTEGRATION VALIDATION**: Verify real-world integration, not just unit tests
- **TEST INTEGRITY**: Verify tests can fail - deliberately break code to confirm tests catch failures
- **FALSE POSITIVE DETECTION**: Look for tests that pass when they shouldn't
- **PERFORMANCE AWARENESS**: Consider performance implications, but don't optimize prematurely
- **MAINTAINABILITY**: Code should be readable and modifiable by others

## Debugging and Investigation Standards

### Systematic Problem Solving
1. **STOP CODING**: More code isn't the answer when stuck
2. **INVESTIGATE REAL SYSTEM**: Use debuggers, logging, inspect actual I/O
3. **RE-EXPRESS PROBLEM**: Break down the issue into smaller components
4. **ASK FOR CLARIFICATION**: Only when problem isn't resolvable through investigation
5. **CHECK EXISTING SOLUTIONS**: See if similar problems have been solved

### Diagnostic Approach
- **EMPIRICAL TESTING**: Test actual behavior systematically
- **DOCUMENT FINDINGS**: Record what works, what doesn't, and why
- **SHARE DISCOVERIES**: Include empirical findings in documentation
- **VALIDATE ASSUMPTIONS**: Test every assumption about how systems work

### QA Report Analysis Protocol
1. **READ FULL OUTPUT**: Always read complete QA output, never just summaries
2. **EXAMINE EACH FAILURE**: Investigate every single test failure individually
3. **VERIFY PASS LEGITIMACY**: For passed tests, verify they actually tested intended behavior
4. **IDENTIFY FAILURE CLUSTERS**: Look for related failures that might indicate deeper issues
5. **CHECK EDGE CASE COVERAGE**: Ensure boundary conditions were properly tested
6. **VALIDATE ERROR HANDLING**: Verify error conditions were tested and handled correctly
7. **CROSS-REFERENCE REQUIREMENTS**: Ensure all requirements were actually tested, not just counted

### Pattern Violation Prevention Protocol
1. **PRE-CODING MENTAL CHECK**: Before writing conditionals, think "either" not "if/else"
2. **ACTIVE PATTERN SCANNING**: While coding, actively scan for prohibited patterns
3. **POST-CODING VALIDATION**: Search entire codebase for violations before delivery:
   - `] else [` - indicates prohibited if/else usage
   - `\\d`, `\\w`, `\\s` - indicates double backslash pattern errors
   - `\"` - indicates invalid quote escaping
   - `PASS:`, `FAIL:` - indicates incorrect status indicators
4. **IMMEDIATE CORRECTION**: If prohibited patterns found, stop and refactor immediately
5. **PATTERN REINFORCEMENT**: Consciously use correct REBOL patterns to build muscle memory
6. **VALIDATION AUTOMATION**: Use search tools to detect pattern violations systematically

### Systematic Validation Checklist
Before any code delivery, search for these prohibited patterns:
- [ ] `] else [` - Must use `either` instead
- [ ] `\\d`, `\\w`, `\\s` - Must use single backslashes (except in URLs/paths)
- [ ] `\"` - Must use `""` or `{}` for quotes
- [ ] `PASS:`, `FAIL:` - Must use `✅ PASSED:`, `❌ FAILED:`
- [ ] Unprintable Unicode characters - Must use approved indicators only
- [ ] `try/except` - Must use `try/with` or other valid REBOL constructs

## Integration with Existing Standards

### Relationship to REBOL Coding Standards
- These principles complement the existing REBOL coding standards
- When conflicts arise, truth-first principles take precedence
- Both sets of standards should be followed together
- **Critical REBOL Rules**: Always use `either` not `if/else`, single backslashes for patterns, `""` or `{}` for quotes
- **Status Indicators**: Must use ✅ PASSED, ❌ FAILED, ⚠️ WARNING consistently across all outputs

### Relationship to Filename Conventions
- Use appropriate filename prefixes based on script purpose
- `diagnose-` scripts should follow empirical testing principles
- `qa-test-` scripts should meet the 100-point quality criteria
- All scripts should follow truth-first development approach
- **File Placement**: Create files in correct folders from start (scratchpad/ for debug, QA/ for production tests)

### Cross-Document Consistency Requirements
- **Status Indicators**: All three documents must use identical status indicator standards
- **Pattern Prevention**: REBOL-specific pitfalls must be prevented systematically
- **Quality Standards**: 100-point scoring system applies to all deliverables
- **Truth-First Approach**: Honesty requirements apply to all documentation and code

## Benefits of These Principles

1. **REDUCED DEBUGGING TIME**: Problems are caught early and honestly reported
2. **HIGHER CODE QUALITY**: Objective standards ensure consistent quality
3. **BETTER INTEGRATION**: Real-world testing prevents integration surprises
4. **CLEARER COMMUNICATION**: Honest reporting builds trust and understanding
5. **FASTER DEVELOPMENT**: Truth-first approach prevents wasted effort on non-working solutions

## Implementation Checklist

For every development task:
- [ ] Verify all integration points before coding
- [ ] Write tests for critical functionality
- [ ] Test with real systems when possible
- [ ] Verify tests can fail by deliberately breaking code
- [ ] Check for false positives in test results
- [ ] **USE ONLY APPROVED STATUS INDICATORS**: ✅ PASSED, ❌ FAILED, ⚠️ WARNING
- [ ] **NEVER USE UNPRINTABLE UNICODE** or celebration characters
- [ ] **MANDATORY CONDITIONAL CHECK**: Search code for `] else [` - if found, refactor to `either`
- [ ] **VERIFY EITHER USAGE**: All binary conditionals must use `either`, never `if/else`
- [ ] **READ COMPLETE QA OUTPUT** - never rely on summary stats alone
- [ ] **EXAMINE EVERY TEST FAILURE** individually and document root causes
- [ ] **VERIFY PASSED TESTS** actually tested intended functionality
- [ ] Score work against 100-point criteria
- [ ] Document any limitations or assumptions
- [ ] Challenge any questionable requirements or assumptions
- [ ] Deliver only when score reaches 100/100

This framework ensures that AI-assisted development produces reliable, honest, and high-quality results that integrate successfully with real systems.

---

## Grok 4 Validation of the above Principles

### Validation of AI Development Principles and Standards

The provided document outlines a comprehensive framework for AI-assisted coding, with a focus on truth-first development, quality assurance, and specific technical standards for REBOL 3 Oldes. This validation assesses the accuracy, consistency, and applicability of the rules based on established technical documentation and best practices. The analysis draws from reliable sources on REBOL 3, including its forks like Oldes, to confirm technical claims. Non-technical principles (e.g., philosophical guidelines) are evaluated for logical coherence and alignment with software development standards. Overall, the rules are largely valid and well-substantiated, with minor notes on implementation flexibility where applicable. The validation is structured by major sections for clarity.

#### Overview and Purpose
The document's purpose—to establish truth-first principles complementing REBOL coding standards—is logically sound. It promotes reliability in AI-assisted coding, which aligns with industry emphases on verifiable and high-quality outputs. No inaccuracies identified; the framework is consistent with modern AI ethics guidelines that prioritize transparency and avoidance of misleading results.

#### Core Principles

##### Principle 1: Truth-Above-All Development
- **Radical Honesty Requirements**: These rules emphasize avoiding simulations, stating limitations clearly, and failing truthfully. This is valid and aligns with best practices in software engineering, where mocks or placeholders can introduce false positives if overused. The prohibition on misleading code is particularly relevant for AI assistants to maintain user trust.
- **Reality-First Implementation**: Requiring verification of APIs and libraries before implementation, empirical testing, and challenging assumptions is accurate. In REBOL 3 Oldes, integration points (e.g., with external systems) must be tested empirically, as assumptions about behavior can lead to errors due to the language's unique dialect-based design. No factual issues; this principle enhances robustness.

##### Principle 2: Quality-First Development
- **Objective Quality Standards**: The 100-point scale (Functionality 30%, Integration 30%, Performance 20%, Code Quality 20%) is a reasonable, quantifiable metric. It encourages thorough evaluation, though in practice, subjective elements (e.g., "acceptably performant") may require context-specific calibration. Valid as a self-assessment tool.
- **Quality Gates**: Insisting on 100% delivery or honest documentation of gaps is stringent but valid for critical systems. Iteration until perfection supports continuous improvement, consistent with agile methodologies.

##### Principle 3: Proactive Problem Detection
- **Break Things Internally**: Promoting fail-fast, aggressive validation, and edge-case testing is standard in quality assurance. This reduces runtime issues and is especially pertinent for REBOL, where dialect parsing can introduce subtle errors if not rigorously tested.
- **Reality Testing**: Empirical validation over expected behavior is correct; REBOL documentation stresses testing actual I/O and integrations. Valid and aligns with the language's emphasis on practical verification.

#### Implementation Guidelines
- **When to Apply Test-Driven Development**: Mandating TDD for complex features and selective use elsewhere follows established patterns (e.g., red-green-refactor). This is accurate and promotes maintainable code.
- **Feature Development Approach**: Focusing on one feature at a time, with a clear "definition of done," is consistent with lean development principles. Decomposing tasks enhances testability.
- **Communication Standards**: Direct, fact-driven communication is valid for professional interactions, though "impatient with inefficiency" should be balanced to maintain collaboration.
- **Output Formatting Standards (MANDATORY)**: 
  - Requiring exact Unicode indicators (✅ PASSED, ❌ FAILED, ⚠️ WARNING) ensures consistency and searchability. This is valid, though rendering inconsistencies across systems (e.g., terminals treating ⚠️ as variable width) may occur, as noted in prior analyses. Prohibitions on alternatives prevent fragmentation.
- **REBOL Conditional Logic Prevention (CRITICAL)**: 
  - The absolute prohibition on `if/else` is accurate for REBOL 3 Oldes. The `if` function does not support an `else` clause; attempting to append "else" results in the block being ignored. The mandatory use of `either condition [true-branch] [false-branch]` is the correct alternative. Validation rules (e.g., searching for `] else [`) are effective for enforcement.
- **REBOL Error Handling Prevention (CRITICAL)**: 
  - `try/except` does not exist in REBOL 3 Oldes; error handling uses `try [block]`, which returns an `error!` value on failure, or `attempt [block]` for safe evaluation returning `none` on error. `disarm` is deprecated and unnecessary, as errors in REBOL 3 are not "armed" or "hot" like in REBOL 2. Alternatives like `try/with` or `set/any 'result try` are appropriate. This rule is fully validated.

#### Error Handling Philosophy
- **Truth-First Error Reporting**: Immediate, clear diagnostics without masking issues are standard. Valid and promotes root-cause analysis.
- **Integration Failure Handling**: Verifying integrations first and providing graceful degradation is accurate, especially for REBOL's system interactions.

#### Quality Assurance Standards
- **False Positive Prevention (CRITICAL)**: Avoiding mocks overuse and validating test integrity is essential to prevent hidden failures. Deliberately breaking code to test failures is a proven technique.
- **QA Output Review Standards (MANDATORY)**: Requiring detailed examination of each failure and verification of passes is valid; relying on summaries alone can miss systemic issues.
- **Self-Assessment Requirements**: Honest scoring and iteration tracking support accountability.
- **Code Review Principles**: Prioritizing functionality and integration validation aligns with peer review best practices.

#### Debugging and Investigation Standards
- **Systematic Problem Solving**: Steps like investigating real systems and documenting findings are logical and effective.
- **Diagnostic Approach**: Empirical testing and assumption validation are core to REBOL development.
- **QA Report Analysis Protocol**: Full output review and failure clustering analysis ensure thoroughness.
- **Pattern Violation Prevention Protocol**: Mental checks and post-coding searches (e.g., for `] else [`) are practical for enforcing REBOL rules.
- **Systematic Validation Checklist**: Searching for prohibited patterns like `\\d` (double backslashes in patterns) is valid; REBOL parse rules use single backslashes for escapes, and double backslashes may indicate incorrect string escaping. For quotes, REBOL uses `""` or `{}` for strings, with escapes like `^"`. Status indicator checks are consistent with formatting standards.

#### Integration with Existing Standards
- **Relationship to REBOL Coding Standards**: Complementing existing standards with truth-first precedence is reasonable. Critical rules (e.g., `either`, single backslashes, quote handling) are accurate, as confirmed above.
- **Relationship to Filename Conventions**: Prefixes and placements (e.g., `diagnose-`, `qa-test-`) promote organization; valid.
- **Cross-Document Consistency Requirements**: Uniform indicators and quality standards ensure coherence.

#### Benefits of These Principles
The listed benefits (e.g., reduced debugging, higher quality) logically follow from the rules and are supported by development literature.

#### Implementation Checklist
The checklist encapsulates the principles effectively. All items are validated as practical steps for adherence.

In summary, the document's rules are technically accurate, particularly for REBOL 3 Oldes specifics, and provide a robust framework for AI-assisted coding. Minor flexibility in non-critical areas (e.g., performance thresholds) may enhance adaptability, but the core standards uphold professionalism and reliability.
