# Filename Prefix Convention

**Date**: 30-Jul-2025

**Purpose**: Establish clear, specific filename prefixes to differentiate script purposes

**Author**:  AI Assistant

## Overview

To maintain an organized codebase and immediately understand the purpose of each script, we use specific filename prefixes that clearly indicate the script's intended function.

## Filename Prefix Categories

### 🔍 **Diagnostic Scripts** (`diagnose-`)

- **Purpose**: Analyze, investigate, or verify specific code behavior
- **Use Case**: When you need to understand how code behaves in specific scenarios
- **Output**: Detailed analysis, behavior verification, investigation results
- **Examples**:
  - `diagnose-caret-character-handling.r3` - Investigate ^ character processing
  - `diagnose-quantifier-behavior.r3` - Analyze quantifier pattern matching
  - `diagnose-parse-rule-generation.r3` - Examine how parse rules are created
  - `diagnose-backtracking-logic.r3` - Investigate backtracking simulation

### ✅ **Quality Assurance Tests** (`qa-test-`)

- **Purpose**: Formal testing with pass/fail results and test harnesses
- **Use Case**: When you need structured testing with clear success/failure metrics
- **Output**: Test results with pass/fail counts, success rates, detailed reporting
- **Examples**:
  - `qa-test-comprehensive-regexp-suite.r3` - Full RegExp engine test suite
  - `qa-test-basic-functionality.r3` - Core functionality testing
  - `qa-test-error-handling.r3` - Error handling verification
  - `qa-test-performance-benchmarks.r3` - Performance testing

### ✔️ **Validation Scripts** (`validate-`)

- **Purpose**: Verify requirements compliance or feature completeness
- **Use Case**: When you need to confirm that requirements or specifications are met
- **Output**: Requirement compliance reports, feature completeness verification
- **Examples**:
  - `validate-basic-functionality.r3` - Verify basic feature requirements
  - `validate-consolidation-requirements.r3` - Check consolidation compliance
  - `validate-backward-compatibility.r3` - Ensure API compatibility
  - `validate-specification-compliance.r3` - Verify spec requirements

### 📊 **Analysis Tools** (`analyze-`)

- **Purpose**: Deep analysis of code structure, performance, or patterns
- **Use Case**: When you need comprehensive analysis or metrics gathering
- **Output**: Detailed analysis reports, metrics, structural insights
- **Examples**:
  - `analyze-pattern-complexity.r3` - Analyze RegExp pattern complexity
  - `analyze-performance-metrics.r3` - Performance analysis and profiling
  - `analyze-code-coverage.r3` - Code coverage analysis
  - `analyze-dependency-mapping.r3` - Dependency relationship analysis

### 🎯 **Demonstration Scripts** (`demo-`)

- **Purpose**: Show functionality or provide usage examples
- **Use Case**: When you need to demonstrate features or provide examples
- **Output**: Interactive demonstrations, usage examples, feature showcases
- **Examples**:
  - `demo-regexp-features.r3` - Demonstrate RegExp capabilities
  - `demo-advanced-patterns.r3` - Show complex pattern examples
  - `demo-error-handling.r3` - Demonstrate error handling features
  - `demo-api-usage.r3` - Show API usage examples

### 🛠️ **Utility Tools** (`tool-`)

- **Purpose**: Helper scripts for development or maintenance
- **Use Case**: When you need automation or helper functionality
- **Output**: Automated tasks, generated content, maintenance operations
- **Examples**:
  - `tool-generate-test-cases.r3` - Generate test case data
  - `tool-benchmark-performance.r3` - Performance benchmarking utility
  - `tool-cleanup-codebase.r3` - Codebase maintenance tool
  - `tool-extract-documentation.r3` - Documentation extraction utility

## Usage Guidelines

### When to Use Each Prefix

| Scenario | Recommended Prefix | Example |
|----------|-------------------|---------|
| "I need to understand why this code behaves this way" | `diagnose-` | `diagnose-parsing-failure.r3` |
| "I need to run formal tests with pass/fail results" | `qa-test-` | `qa-test-regexp-engine.r3` |
| "I need to verify requirements are met" | `validate-` | `validate-api-compliance.r3` |
| "I need detailed analysis or metrics" | `analyze-` | `analyze-memory-usage.r3` |
| "I need to show how something works" | `demo-` | `demo-new-features.r3` |
| "I need a helper script for automation" | `tool-` | `tool-generate-reports.r3` |

### Naming Best Practices

1. **Be Specific**: Use descriptive names that clearly indicate the exact purpose
   
   - ✅ Good: `diagnose-caret-character-handling.r3`
   - ❌ Avoid: `diagnose-characters.r3`
2. **Use Hyphens**: Separate words with hyphens for readability
   
   - ✅ Good: `qa-test-error-handling.r3`
   - ❌ Avoid: `qatesterrorhandling.r3`
3. **Include Context**: Add context when the purpose might be ambiguous
   
   - ✅ Good: `validate-regexp-consolidation-requirements.r3`
   - ❌ Avoid: `validate-requirements.r3`
4. **Be Consistent**: Always use the established prefixes
   
   - ✅ Good: `diagnose-`, `qa-test-`, `validate-`
   - ❌ Avoid: `debug-`, `test-`, `check-`

## File Organization

### ⚡ **CRITICAL EFFICIENCY RULE: Always Create Files in Correct Folders**

**🚨 TIME-SAVING MANDATE**: Always create debug/diagnostic scripts directly in the `scratchpad/` folder from the beginning. **Never** create them in other folders and move them later.

**Why This Matters**:

- **Time Cost**: Moving files later wastes 15-20 minutes of file housekeeping
- **Cognitive Load**: Creates confusion about what belongs where
- **Risk**: Can miss files or create duplicates during moves
- **Inefficiency**: Multiple read/write/delete operations instead of single writes

**Correct Workflow**:

```

```

✅ CORRECT: Create scratchpad/diagnose-issue.r3 directly
❌ WRONG: Create QA/diagnose-issue.r3 then move to scratchpad/

```
### Directory Structure
```

project/
├── src/                          # Source code
├── QA/                           # Production QA test suites ONLY
│   ├── qa-test-*.r3             # Formal QA test scripts
│   └── test-patterns.txt        # Test data files
├── scratchpad/                   # Debug/diagnostic scripts ONLY
│   ├── diagnose-*.r3            # Diagnostic scripts
│   ├── analyze-*.r3             # Analysis scripts
│   ├── debug-*.r3               # Debug scripts
│   └── test-*.r3                # Experimental test scripts
├── tools/                        # Utility and production tools
│   └── tool-*.r3                # Utility tools
└── demos/                        # Demonstration scripts
└── demo-*.r3                # Demo scripts

```
### **Folder Purpose Guidelines**

| Folder | Purpose | What Goes Here | What NEVER Goes Here |
|--------|---------|----------------|---------------------|
| `QA/` | Production testing | `qa-test-*` suites, test data | Debug scripts, diagnostics |
| `scratchpad/` | Debug/analysis | `diagnose-*`, `analyze-*`, `debug-*` | Production tests |
| `src/` | Source code | Engine modules, core functionality | Any test scripts |
| `tools/` | Production utilities | Deployment tools, generators | Debug scripts |

### Header Template

Each script should include a clear header with type information:

```rebol
REBOL [
    Title: "Clear Descriptive Title"
    Date: DD-MMM-YYYY
    Author: "Author Name"
    Purpose: "Clear description of what this script does"
    Type: "Script Type (Diagnostic Script, QA Test, Validation Script, etc.)"
    Note: "Additional context or important information"
]
```

## Benefits of This Convention

1. **Immediate Purpose Recognition**: Know what a script does from its filename
2. **Better Organization**: Group related scripts together
3. **Reduced Confusion**: No ambiguity about script purpose
4. **Easier Maintenance**: Find the right script quickly
5. **Team Collaboration**: Clear communication about script purposes
6. **Automated Processing**: Scripts can be processed by type if needed
7. **⚡ Time Efficiency**: Proper folder placement from start eliminates file housekeeping

## ⚡ Efficiency Impact

### **Time Savings Analysis**

- **Correct Workflow**: 30 seconds to create file in right folder
- **Incorrect Workflow**: 15-20 minutes of file moving and housekeeping
- **Efficiency Gain**: 30x time savings by doing it right the first time

### **Real Example from Project**

```
❌ INEFFICIENT: Created 11 debug files in QA/, then spent 20 minutes moving them
✅ EFFICIENT: Create debug files directly in scratchpad/ (30 seconds each)
Result: 20 minutes saved, cleaner organization, no confusion
```

## Migration from Old Naming

### Old vs New Examples

- `test-caret-handling.r3` → `diagnose-caret-character-handling.r3`
- `comprehensive-test-suite.r3` → `qa-test-comprehensive-suite.r3`
- `basic-validation-test.r3` → `validate-basic-functionality.r3`

This convention ensures that every script's purpose is immediately clear, making the codebase more maintainable and easier to navigate.
