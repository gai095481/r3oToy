# Comparison: `task!` vs `object!` vs `function!`

*Based on comprehensive diagnostic testing and analysis*

## Executive Summary Table

| Feature | task! | object! | function! |
|---------|-------|---------|-----------|
| **Primary Purpose** | Immutable specification containers | Flexible data containers | Executable code blocks |
| **Executability** | ❌ Not executable | ❌ Not executable | ✅ Executable |
| **Mutability** | ❌ Immutable | ✅ Mutable | ❌ Immutable* |
| **Copyability** | ❌ Cannot copy | ✅ Can copy/modify | ✅ Can copy |
| **Field Access** | ❌ No direct access | ✅ obj/field syntax | ✅ func/spec, func/body |
| **Equality Semantics** | ⚠️ All equal regardless of content | ✅ Content-based equality | ✅ Content-based equality |
| **Type Checking** | ✅ task? reliable | ✅ object? reliable | ✅ function? reliable |

*\*Function bodies are immutable, but you can create new functions*

---

## Detailed Feature Comparison

### 🔧 **Creation & Input Handling**

| Aspect | task! | object! | function! |
|--------|-------|---------|-----------|
| **Creation Syntax** | `task [spec] [body]` | `make object! [...]` | `function [spec] [body]` |
| **Input Validation** | ✅ Strict block! validation | ✅ Flexible input types | ✅ Strict block! validation |
| **Deep Copy Protection** | ✅ Automatic deep copy | ❌ Manual copy needed | ✅ Automatic deep copy |
| **Error Handling** | ✅ Clear error messages | ✅ Standard object errors | ✅ Clear error messages |

### 🔍 **Introspection & Reflection**

| Feature | task! | object! | function! |
|---------|-------|---------|-----------|
| **Field Access** | ❌ No `/spec` or `/body` | ✅ `obj/field` works | ✅ `func/spec`, `func/body` |
| **words-of** | ❌ Not supported | ✅ Returns field names | ✅ Returns internal words |
| **values-of** | ❌ Not supported | ✅ Returns field values | ✅ Returns internal values |
| **Internal Structure** | ✅ Fixed: [title header parent path args] | ✅ Flexible user-defined | ✅ Standard function structure |
| **probe/mold** | ✅ Shows internal structure | ✅ Shows content | ✅ Shows spec and body |

### 📋 **Type System Integration**

| Check | task! | object! | function! |
|-------|-------|---------|-----------|
| **Specific Type Check** | ✅ `task?` → true | ✅ `object?` → true | ✅ `function?` → true |
| **any-object?** | ✅ true | ✅ true | ❌ false |
| **any-function?** | ❌ false | ❌ false | ✅ true |
| **series?** | ❌ false | ❌ false | ❌ false |
| **Type Conversion** | ⚠️ to string! ✅, to block! inconsistent | ✅ Various conversions | ✅ to string!, to block! |

### 🔄 **Copy & Modification Operations**

| Operation | task! | object! | function! |
|-----------|-------|---------|-----------|
| **copy** | ❌ Error: not supported | ✅ Shallow copy works | ✅ Creates copy |
| **copy/deep** | ❌ Error: not supported | ✅ Deep copy works | ✅ Deep copy works |
| **copy/part** | ❌ Error: not supported | ✅ Partial copy works | ✅ Partial copy works |
| **Field Modification** | ❌ No accessible fields | ✅ `obj/field: value` | ❌ Immutable after creation |
| **Structure Changes** | ❌ Fixed structure | ✅ Can add/remove fields | ❌ Fixed structure |

### ⚖️ **Equality & Comparison**

| Comparison Type | task! | object! | function! |
|-----------------|-------|---------|-----------|
| **equal?** | ⚠️ ALL tasks equal (regardless of content) | ✅ Content-based equality | ✅ Content-based equality |
| **strict-equal?** | ⚠️ ALL tasks strictly equal | ✅ Content-based strict equality | ✅ Content-based strict equality |
| **same?** | ✅ Reference-based (works correctly) | ✅ Reference-based | ✅ Reference-based |
| **Practical Impact** | ❌ Cannot use for business logic | ✅ Reliable for comparisons | ✅ Reliable for comparisons |

---

## 🎯 **Use Case Recommendations**

### **Choose task! when you need:**

- ✅ Immutable specification containers
- ✅ Deep copy protection for input blocks
- ✅ Template/configuration storage that cannot be corrupted
- ✅ Standardized container structure
- ✅ Type-safe container identification
- ❌ **Avoid for:** Business logic comparisons, executable code, flexible data storage

### **Choose object! when you need:**

- ✅ Flexible data containers with custom fields
- ✅ Mutable data structures
- ✅ Object-oriented programming patterns
- ✅ Content-based equality comparisons
- ✅ Runtime field addition/modification
- ❌ **Avoid for:** Immutable specifications, executable code

### **Choose function! when you need:**

- ✅ Executable code blocks
- ✅ Parameterized operations
- ✅ Reusable business logic
- ✅ Function composition and higher-order functions
- ✅ Local variables and refinements
- ❌ **Avoid for:** Data storage, mutable containers

---

## ⚠️ **Critical Gotchas & Pitfalls**

### **task! Pitfalls:**

1. **All Equal Trap:** `equal? task-a task-b` is ALWAYS true
2. **No Execution:** Cannot call tasks like functions
3. **No Field Access:** Cannot retrieve original spec/body
4. **Copy Protection:** Cannot duplicate or modify
5. **Block Conversion:** Inconsistent `to block!` behavior

### **object! Pitfalls:**

1. **No Deep Copy by Default:** Must explicitly use `copy/deep`
2. **Case Sensitivity:** Field names are case-sensitive
3. **No Type Validation:** Fields can be any type
4. **Memory Overhead:** More memory usage than simple data types

### **function! Pitfalls:**

1. **Immutable After Creation:** Cannot modify function body
2. **Scope Complexity:** Local variables and context can be tricky
3. **Performance:** Function calls have overhead
4. **Argument Validation:** Need manual type checking in body

---

## 🔬 **Performance & Memory Characteristics**

| Aspect | task! | object! | function! |
|--------|-------|---------|-----------|
| **Creation Cost** | Low (standardized structure) | Medium (flexible allocation) | Medium (spec/body processing) |
| **Memory Usage** | Low (fixed fields) | Variable (depends on content) | Medium (code storage) |
| **Access Speed** | Fast (type checking only) | Fast (direct field access) | N/A (execution speed varies) |
| **Comparison Speed** | Very Fast (always equal) | Medium (content comparison) | Medium (content comparison) |

---

## 📊 **Real-World Application Matrix**

| Use Case | task! | object! | function! | Recommendation |
|----------|-------|---------|-----------|----------------|
| **Database Schema** | ✅ Excellent | ✅ Good | ❌ Poor | Use task! for immutable schemas |
| **User Data** | ❌ Poor | ✅ Excellent | ❌ Poor | Use object! for flexible user data |
| **Business Logic** | ❌ Poor | ❌ Poor | ✅ Excellent | Use function! for executable logic |
| **Configuration** | ✅ Excellent | ✅ Good | ❌ Poor | Use task! for immutable config |
| **API Endpoints** | ✅ Good | ✅ Excellent | ❌ Poor | Use object! for flexible endpoints |
| **Data Processing** | ✅ Good | ✅ Good | ✅ Excellent | Use function! for processing logic |
| **Templates** | ✅ Excellent | ✅ Good | ❌ Poor | Use task! for immutable templates |
| **Cache Keys** | ⚠️ Problematic | ✅ Good | ✅ Good | Avoid task! (all equal), use object! |

---

## 🏗️ **Integration Patterns**

### **Hybrid Pattern: Tasks + Functions**

```rebol
;; Use task for specification, function for execution
api-spec: task [endpoint [url!] method [word!] data [block!]] [
    send-request endpoint method data
]

api-executor: function [spec-task [task!] runtime-data [block!]] [
    ;; Use task as immutable specification reference
    ;; Execute actual logic here
    execute-api-call spec-task runtime-data
]
```

### **Object + Function Pattern**

```rebol
;; Use object for flexible data, function for operations
user-data: make object! [
    name: "John"
    email: "john@example.com"
    process-user: function [action] [
        switch action [
            "validate" [validate-email email]
            "save" [save-user-data self]
        ]
    ]
]
```

### **Task + Object Pattern**

```rebol
;; Use task for immutable spec, object for runtime state
processor-spec: task [input [file!] output [file!]] [
    load-file input
    transform-data
    save-file output
]

processor-state: make object! [
    spec: processor-spec
    status: "ready"
    progress: 0
    last-error: none
]
```

---

## 📝 **Summary & Best Practices**

### **The Golden Rules:**

1. **task!** = Immutable containers for specifications and templates
2. **object!** = Flexible containers for mutable data and state
3. **function!** = Executable code blocks for business logic

### **When in Doubt:**

- Need to store configuration? → **task!**
- Need to store changing data? → **object!**
- Need to execute operations? → **function!**

### **Never Do This:**

- ❌ Use task equality for business logic
- ❌ Try to execute tasks directly
- ❌ Assume you can copy tasks
- ❌ Use tasks when you need field access

This comparison is based on extensive diagnostic testing and real-world usage patterns in Rebol 3 Oldes environments.
