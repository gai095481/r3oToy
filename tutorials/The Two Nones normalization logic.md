In Rebol 3 Oldes branch, the **"Two Nones" normalization logic** resolves ambiguity between two distinct "empty" states: `none` (intentional absence) and **unset** (uninitialized state). Here's how it works:

---

### 🧩 The Two States
1. **`none`**  
   - Explicit "nothing" value (`none!` type)  
   - Falsy in conditionals  
   - Example: Function returns `none` for "no result"  

2. **Unset**  
   - Word has never been assigned a value  
   - Throws error when accessed  
   - Example: Uninitialized variable `x`  

---

### ⚙️ Normalization Rules
| Context                  | Input State | Normalized Output | Why                                                                 |
|--------------------------|-------------|-------------------|---------------------------------------------------------------------|
| **Function arguments**   | Unset       | `none`            | Unprovided arguments become safe falsy values .                     |
| **Block selections**     | Unset index | `none`            | `pick [a b] 5 → none` (out-of-bound) .                             |
| **Word fetching**        | Unset word  | **Error**         | `get 'unset-var` → error (prevents silent failures) .               |
| **Conditionals**         | Unset word  | **Error**         | `if unset-var [...]` → halts execution .                            |
| **Explicit fetch**       | Unset word  | `unset` marker    | `get/any 'unset-var → unset!` (special type) .                      |

---

### 🔍 Key Normalization Examples
#### 1. Function Argument Handling (Unset → `none`)
```rebol
foo: func [param][
    ; Unset 'param' becomes 'none'
    either param [print "Truthy"] [print "Falsy"]
]

>> foo  ; No argument
Falsy  ; param normalized to 'none'
```

#### 2. Block Selection (Missing → `none`)
```rebol
>> colors: ["red" "green"]
>> pick colors 3
== none  ; Out-of-bound → 'none'
```

#### 3. Safe Word Handling (Unset → Error)
```rebol
>> if unset-var [print "Danger"]  ; Not normalized!
** Script error: unset-var has no value  ; Explicit error
```

#### 4. Intentional Unset Retrieval
```rebol
>> unset 'x
>> type? get/any 'x
== unset!  ; Special type (use for meta-programming)

>> value: get/any 'x
>> if unset? value [print "Unset state detected"]
Unset state detected
```

---

### ⚖️ Design Philosophy
1. **Safety First**  
   Unset states throw immediate errors → Prevents subtle bugs from undefined values .

2. **Intentional Absence**  
   `none` is a *valid value* representing "nothing here" → Falsy and safe to use .

3. **Explicit Over Implicit**  
   - Normalize only in defined contexts (args, block picks)  
   - Require explicit handling of unset states elsewhere  

4. **Meta-Programming Support**  
   `unset!` type allows advanced code introspection .

---

### 💡 Practical Implications
```rebol
; Safe function with argument normalization
process: func [data [any-type!]][
    case [
        unset? get/any 'data [print "Unset! Shouldn't happen in args"]  
        none? data  [print "No data provided"]
        empty? data [print "Empty container"]
        'else       [print ["Processing:" data]]
    ]
]

>> process  ; Call without argument
No data provided  ; 'data' normalized to 'none'
```

---

### ✅ Why This Matters
| Approach          | C/Python/JS          | Rebol 3 Oldes             |
|-------------------|----------------------|---------------------------|
| **Unset variable** | `undefined`/`NameError` | **Throws immediate error** |
| **Null value**    | `null`/`None` falsy  | `none` falsy              |
| **Edge handling** | Implicit falsy       | Explicit normalization    |

Rebol's "Two Nones" logic provides **stronger correctness guarantees** by distinguishing between:  
- A value that exists and is empty (`none`)  
- A word that has no value at all (unset → error)  

This eliminates entire categories of null-pointer exceptions while maintaining clean data-flow semantics.
