# Quick Reference Card - Critical Coding Standards

**Date**: 12-Aug-2025  
**Purpose**: One-page reference of the most critical rules from all steering documents  
**Author**: Kiro AI Assistant  

---

## 🚨 **CRITICAL REBOL 3 OLDES RULES**

### **Conditional Logic**
- ✅ **USE**: `either condition [true-branch] [false-branch]`
- ❌ **NEVER**: `if condition [...] else [...]` - `else` does not exist!

### **String Literals & Quotes**
- ✅ **USE**: `"He said ""Hello"" to me"` or `{He said "Hello" to me}`
- ❌ **NEVER**: `"He said \"Hello\" to me"` - `\"` is invalid!

### **Backslashes (CRITICAL)**
- ✅ **USE**: `"\d"` (single backslash for patterns)
- ❌ **NEVER**: `"\\d"` (double backslash) - except in URLs/file paths
- ✅ **ESCAPE SEQUENCES**: Use `^/` (newline), `^-` (tab), not `\n`, `\t`

### **Error Handling**
- ✅ **USE**: `try/with`, `set/any 'result try`, `attempt`
- ❌ **NEVER**: `try/except` (doesn't exist), `disarm` (deprecated)

### **Functions**
- ✅ **USE**: `funct` for functions with parameters, `does` for zero parameters
- ❌ **AVOID**: `func` (requires manual local variable management)

---

## 🎯 **STATUS INDICATORS (MANDATORY)**

### **Required Format**
- ✅ **PASSED** (never "PASS" or "✓")
- ❌ **FAILED** (never "FAIL" or "✗")
- ⚠️ **WARNING** (for warnings and cautions)

### **Prohibited**
- ❌ Unprintable Unicode (party emoji, celebration characters)
- ❌ Non-colored indicators (✓, ✗)
- ❌ Short forms ("PASS", "FAIL")

---

## 📁 **FILENAME PREFIXES**

| Prefix | Purpose | Folder |
|--------|---------|--------|
| `diagnose-` | Investigate/analyze behavior | `scratchpad/` |
| `qa-test-` | Formal testing with pass/fail | `QA/` |
| `validate-` | Requirements compliance | `QA/` |
| `analyze-` | Deep analysis/metrics | `scratchpad/` |
| `demo-` | Show functionality | `demos/` |
| `tool-` | Utility/automation | `tools/` |

**⚡ CRITICAL**: Create files in correct folders from start - never move later!

---

## 🔍 **PRE-DELIVERY VALIDATION CHECKLIST**

Search code for these **PROHIBITED PATTERNS**:

- [ ] `] else [` → Must use `either`
- [ ] `\\d`, `\\w`, `\\s` → Must use single backslashes
- [ ] `\"` → Must use `""` or `{}`
- [ ] `PASS:`, `FAIL:` → Must use `✅ PASSED:`, `❌ FAILED:`
- [ ] Single space after ⚠️ → Must use `⚠️  WARNING` (two spaces after warning icon)
- [ ] `try/except` → Must use `try/with`
- [ ] `disarm` → Must use modern error handling

---

## 📊 **QUALITY STANDARDS (100-POINT SCALE)**

- **Functionality (30%)**: Meets all requirements, passes tests
- **Integration (30%)**: Works with real systems/APIs
- **Performance (20%)**: Acceptably performant
- **Code Quality (20%)**: Maintainable, readable, follows standards

**🚫 NO DELIVERY BELOW 100%** - Iterate until perfect!

---

## 🧪 **QA TESTING RULES**

### **False Positive Prevention**
- **TEST THE TESTS**: Break code to verify tests fail
- **AVOID MOCK OVERUSE**: Test with real systems when possible
- **VALIDATE ASSERTIONS**: Ensure tests check intended behavior

### **QA Output Review**
- **READ EVERY FAILURE**: Never rely on summary stats alone
- **EXAMINE EACH FAILURE**: Investigate individually
- **VERIFY PASSED TESTS**: Confirm they tested intended functionality

---

## 🎯 **TRUTH-FIRST PRINCIPLES**

### **Radical Honesty**
- **NEVER SIMULATE**: No mock data when real integration possible
- **STATE LIMITATIONS**: Communicate facts immediately
- **NO ILLUSIONS**: Don't mislead about what works

### **Reality Testing**
- **VERIFY BEFORE IMPLEMENTING**: Check APIs/systems exist
- **TEST ACTUAL BEHAVIOR**: Not expected behavior
- **CHALLENGE ASSUMPTIONS**: Question everything

---

## 🔧 **COMMON PATTERNS**

### **Multiple Return Values**
```rebol
set [test-count passed-count failed-count all-passed] 
    function-call args...
```

### **Error Handling**
```rebol
set/any 'result try [risky-operation]
either error? result [
    handle-error result
] [
    process-result result
]
```

### **String with Quotes**
```rebol
;; Method 1: Double quotes
message: "He said ""Hello"" to me"

;; Method 2: Curly braces (cleaner)
message: {He said "Hello" to me}
```

---

## ⚡ **EMERGENCY PROTOCOLS**

### **If You Find Prohibited Patterns**
1. **STOP CODING** immediately
2. **SEARCH ENTIRE CODEBASE** for similar violations
3. **FIX ALL INSTANCES** before continuing
4. **TEST FIXES** work correctly
5. **DOCUMENT** what was fixed and why

### **Pattern Violation Cost**
- **Prevention**: 5-10 minutes
- **Fixing Later**: 2-4 hours
- **Efficiency Ratio**: Prevention is 20x more efficient!

---

## 📋 **IMPLEMENTATION CHECKLIST**

For every development task:
- [ ] Use `either` not `if/else`
- [ ] Single backslashes for patterns
- [ ] Proper status indicators (✅❌⚠️)
- [ ] Test with real systems when possible
- [ ] Read complete QA output
- [ ] Score against 100-point criteria
- [ ] Search for prohibited patterns
- [ ] Create files in correct folders

---

**💡 Remember**: These rules prevent hours of debugging and refactoring code. Follow them religiously!

**🔗 Full Documentation**: See individual steering documents for complete details and examples.
