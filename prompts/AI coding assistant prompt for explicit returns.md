## CRITICAL CODING RULE: Explicit Return Value Architecture

### Core Principle
**NEVER rely on implicit return values from the last evaluated expression in functions.
ALWAYS use explicit return statements for every code path that should return a value.**

### Mandatory Checks Before Submitting Code

Before providing any function refactoring or new function implementation, you MUST verify:

1. **Every logical branch that should return a value has an explicit `return` statement**
2. **No code path relies on "falling through" to return the result of the last evaluated expression**
3. **Helper functions that compute return values are explicitly returned: `return helper-function args`**
4. **Complex conditional structures (`case`, `either`, `switch`) that compute values explicitly return those values**

### Red Flag Patterns to Avoid

#### ❌ FORBIDDEN: Implicit Return Pattern
```rebol
my-function: function [data] [
    case [
        condition1 [
            result: compute-something data
            helper-function result  ;; ← DANGEROUS: No explicit return
        ]
        condition2 [
            other-result: compute-other data
            another-helper other-result  ;; ← DANGEROUS: No explicit return
        ]
    ]
    ;; ← DANGEROUS: Function ends without explicit return
]
```

#### ✅ REQUIRED: Explicit Return Pattern
```rebol
my-function: function [data] [
    case [
        condition1 [
            result: compute-something data
            return helper-function result  ;; ← SAFE: Explicit return.
        ]
        condition2 [
            other-result: compute-other data
            return another-helper other-result  ;; ← SAFE: Explicit return.
        ]
    ]
    return none  ;; ← SAFE: Explicit fallback return.
]
```

### Specific Scenarios to Guard Against

#### Debug Statement Trap
Adding ANY statement after a computed value will break implicit returns:
```rebol
;; This will break if someone adds a debug print:
case [
    map? data [
        value: select data key
        normalize-value value  ;; ← Adding "print 'debug" after this breaks everything.
    ]
]
```

#### Refactoring Trap
Wrapping computed values in new helper functions breaks implicit returns:
```rebol
;; This will break when someone wraps the computation:
case [
    block? data [
        result: pick data key
        validate-and-normalize result  ;; ← The result is computed but not returned.
    ]
]
```

#### Interpreter Evolution Trap
Relying on interpreter behavior for implicit returns creates fragile code that can break with language updates.

### Enforcement Strategy

When refactoring functions:

1. **Count the return statements**: If reducing return statements, ensure every logical path still has explicit returns
2. **Trace every code path**: Follow each conditional branch to verify it ends with `return`
3. **Test the "debug statement" scenario**: Mentally add a `print` statement after computed values - would it break?
4. **Apply the "helper function" test**: If any computation were wrapped in a helper function, would the result still be returned?

### Exception Handling

This rule applies to ALL functions that should return meaningful values. The only acceptable implicit returns are:
- Functions that should return `none` (and this should be made explicit with `return none`)
- Functions where the final statement is clearly intended as the return value AND is not a helper function call

### Summary

**Explicit returns are not just good style - they are architectural requirements for maintainable, robust code. Always choose explicit returns over clever implicit evaluation, even if it means more return statements.**
