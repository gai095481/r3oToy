Project Rule:

Explicit Conditionals: All conditional checks must use explicit comparison functions or type-checking functions. Code should not rely on the implicit "truthiness" or "falsiness" of values like 0, empty strings "", or empty blocks [].

Here are some examples of how we will apply this rule:

Prohibited (Implicit)	Required (Explicit)	Reason

`if value [...]`	`if not none? value [...]` or `if value = true [...]`	;; Makes intent clear. Avoids bugs where value could be `false`, which is not `none`, but fails the implicit check.

`if find data key [...]`	`if not none? find data key [...]`	;; Explicitly check `find` did not return a `none` value.

`if empty? my-block [...]`	`if 0 = length? my-block [...]`

`if series? value [...]`	`if any [block? value string? value] [...]`	;; More specific and avoids relying on a general category word.

This is a great rule that aligns perfectly with our goal of creating clear, maintainable and correct program code.
---
In programming, a **truthy value** is any value that evaluates to `true` in a **boolean context** (e.g., conditionals, loops or logical operations), even if it isn't literally the boolean `true`.  Conversely, **falsy values** evaluate to `false`. 
### Key Concepts:
1. **Boolean Context**:  
   When a non-boolean value is used where a boolean is expected (e.g., `if (value) {...}`), the language implicitly converts it to `true` or `false`.

2. **Truthy vs. Literal `true`**:  
   Truthy values aren't necessarily equal to `true` but behave like `true` in conditional checks. For example:  
   ```javascript
   if ("hello") { }  // "hello" is truthy → block executes
   ```
---
### Why Truthy/Falsy Matters:
1. **Conciseness**: Simplifies code.  
   ```javascript
   // Instead of:
   if (name !== undefined && name !== "" && name !== null) { ... }
   // Use truthy check:
   if (name) { ... } // Only runs if `name` has a meaningful value.
   ```
2. **Flexibility**: Functions can accept diverse types and still work in conditionals.  
3. **Pitfalls**: Values you expect to be truthy might be falsy (e.g., `0` in JavaScript).  
   ```javascript
   let count = 0;
   if (count) { ... } // Block won't run (0 is falsy). May be unintended!
   ```

---
### Language-Specific Notes:
- **JavaScript**:  
  Empty arrays (`[]`) and empty objects (`{}`) are **truthy** (since they’re objects).  
- **Python**:  
  `bool(value)` explicitly checks truthiness. Empty collections (`[]`, `{}`, `()`, `""`) are falsy.  
- **Ruby**:  
  **Only `false` and `nil` are falsy.** Everything else (including `0`, `""`, `[]`) is truthy.  
- **PHP**:  
  The string `"0"` is falsy (unlike most languages).

---
### Best Practices:
1. **Explicit Checks** for clarity:  
   Prefer `if (array.length > 0)` over `if (array)` when checking for non-empty arrays.  
2. **Know Your Language**:  
   Memorize falsy values to avoid surprises.  
3. **Use Triple Equals (`===`)** in JavaScript to avoid type coercion quirks.

By understanding truthy/falsy values, you’ll write cleaner code and debug logical errors more effectively! 🚀
---
🔍 Truthy/Falsy Rules by Language
Language	Truthy Examples	Falsy Examples	Corrections & Caveats

JavaScript	Non-empty strings (e.g., "0", "false"), non-zero numbers, objects, arrays, Infinity	false, 0, -0, "", null, undefined, NaN, document.all	✅ Accurate, but note: [] and {} are truthy even if empty 36. "0" is truthy, unlike PHP.

Python	Non-empty strings/collections, non-zero numbers, True, non-None objects	False, 0, 0.0, "", [], (), {}, None, set(), range(0)	✅ Accurate, but note: Empty collections (e.g., [], {}) are falsy.

Ruby	Everything except false and nil: 0, "", [], {}, "false"	Only false and nil	✅ Accurate. Ruby is strict: only false/nil falsy; all else truthy.

PHP	Non-empty strings (except "0"), non-zero numbers, arrays with elements, true	false, 0, "0", "", null, undefined, empty arrays, NaN	⚠️ Incorrect for "0": The string "0" is falsy in PHP (unlike most languages).

⚠️ Key Pitfalls & Edge Cases

JavaScript:

0 is falsy → Causes bugs in numeric checks (e.g., if (loyaltyPoints) fails for 0).

[] == false evaluates to true due to coercion, but [] is truthy.

Use === to avoid coercion surprises.

PHP:

"0" is falsy, but "00" and "0.0" are truthy → Highly inconsistent.

Empty arrays are falsy, unlike JavaScript/Ruby.

Cross-Language Inconsistencies:

0: Truthy in Ruby, falsy in JavaScript/Python/PHP 249.

Empty arrays: Truthy in JavaScript/Ruby, falsy in Python/PHP.

"false": Truthy in all languages except if parsed as a boolean (e.g., PHP's "false" ≠ false).

✅ Recommendations
Avoid truthy/falsy checks for critical logic (e.g., financial systems) due to unpredictability.

Explicit checks are safer:

JavaScript: `if (value !== undefined && value !== null)`

Python: `if value is not None and value != ""`

Ruby: `if !value.nil?`

Language-Specific Functions:

Python: Use `bool(value)` to test truthiness.

JavaScript: Use `!!value` or `Boolean(value)`.

💎 Conclusion
Always verify edge cases like zero, empty collections and the string "0"—these are common sources of bugs. For detailed references, consult MDN (JavaScript) or PHP's falsy rules.

**Q: How do explicit checks look in Rebol 3 Oldes branch?**

In Rebol 3 Oldes branch, explicit checks replace reliance on truthy/falsy behavior, prioritizing clarity and data integrity. Below are key patterns with practical examples:

🔍 1. Type-Specific Checks

Use datatype-testing functions to validate values before operations:

```
if integer? value [print "Valid integer"]  
if string? input [append output input]
```
Why: Avoids unintended truthy behavior (e.g., 0 or "" are truthy).

⚖️ 2. Explicit Conditionals
Replace `if` with `either` or `case` for granular control:

```
;; Check for zero (C-like falsy behavior)  
either value = 0 [  
    print "Falsy: zero"  
][  
    print "Non-zero truthy"  
]  

; Multi-condition logic  
case [  
    value = 0  [print "Zero"]  
    value < 0  [print "Negative"]  
    'else      [print "Positive"]  
]
``` 
Note: case evaluates conditions top-down.

🧩 3. Presence/Absence Guards
Handle none (Rebol's null equivalent) explicitly:

```
;; Check for unset/none values  
if not none? data [process data]  

;; Prevent errors with uninitialized vars  
if value? 'var [print var]  ; Errors if `var` doesn't exist
```
Critical: Uninitialized variables throw errors (e.g., `if unset-var [...]` fails).

🧠 4. Custom Assertions

Create helper functions for complex checks:

```
valid-number?: func [x][all [number? x x = x]]  ;; Rejects NaN.

if valid-number? value [print "Safe to calculate"]
```
Use Case: Validates data before numeric operations.

📦 5. Container Checks

Explicitly test emptiness for collections:

```
;; Empty block/string?  
if empty? block-data [print "No data in block"]  
if "" = input [print "Empty string"]  
```
Why: Empty collections ([], "") are truthy by default.

💡 Key Philosophy

Rebol 3 Oldes branch treats all data as meaningful, avoiding implicit coercion.

For example:

0 is a valid integer → Use = 0 checks for "falsy" intent

Uninitialized variables (NaN, missing values), throw errors → Forces explicit handling.

Real-World Example (HTTP Server)

```
On-Accept: func [info [object!]][  
    ; Explicit IP check (non-truthy)  
    either find [127.0.0.1] info/remote-ip [  
        true  ;; Allow connection  
    ][  
        false ;; Reject  
    ]  
]
```
Here, `find` returns a position (truthy), but the result is explicitly validated with `either`.

✅ Best Practices

Prefer `either` over `if` for dual branches.

Use case for `>2` conditions.

Combine guards: `if all [not none? data integer? data][...]`.

Leverage `value?` to avoid uninitialized variable errors.

Rebol's explicitness eliminates truthy/falsy ambiguity, making code resilient in data-centric workflow
---

> Nobody used the the terms "truthy" and "falsy" value in earlier programming eras.  Are these terms really needed to distinguish  themselves from other terms.  Why were these terms not used in prior eras?  They sound like words from a preschooler.
`

You've hit on a fascinating linguistic evolution in programming! The terms "truthy" and "falsy" *are* relatively modern inventions (popularized in the 2000 s), and their adoption reflects deeper shifts in programming paradigms. Here's why they emerged and why older terms fell short:
### Why Older Eras Didn’t Use These Terms:
1. **Strictly Typed Languages Dominated (Pre-2000 s):**  
   Languages like C, Pascal, or Java required **explicit boolean expressions** in conditionals.  You couldn’t write `if (5)` –- you had to use comparisons like `if (x != 0)`.  Implicit truthiness checks were rare or forbidden.

2. **Less Dynamic Coercion:**  
   Early languages avoided implicit type conversions. A string wasn’t silently treated as `true` / `false` – it threw an error.

3. **Formal Terminology Prevailed:**  
   Documentation used phrases like *"non-zero values evaluate to true"* or *"null is treated as false"*. Slang like "truthy" was seen as unprofessional.
---

### Why Modern Programming *Needed* New Terms:
| **Era**         | **Paradigm Shift**                                  | **Terminology Need**                          |
|------------------|----------------------------------------------------|----------------------------------------------|
| **Pre-2000 s**    | Rigid type systems                                 | "Boolean expression", "non-zero", "null"     |
| **Post-2000 s**   | Rise of dynamic scripting (JS, Python, Ruby, PHP) | **Truthy/Falsy** (to describe *implicit behavior*) |

1. **Dynamic Typing Explosion:**  
   JavaScript (1995), Python (1991) and Ruby (1995) made flexible type coercion central to their design. Suddenly, `if ("hello")` was valid – demanding a term for *"why does this non-boolean work here?"*.

2. **Complex Coercion Rules:**  
   JavaScript alone has [7 falsy values](https://developer.mozilla.org/en-US/docs/Glossary/Falsy), Python treats empty collections as `False`, and Ruby considers *only* `false` / `nil` falsy. "Truthy/falsy" became shorthand for this complexity.

3. **Community-Driven Culture:**  
   Web developers (especially in JavaScript) favored accessible, concise jargon. "Truthy" spread via blogs, conferences and docs like [MDN](https://developer.mozilla.org) – replacing mouthfuls like *"values that coerce to true in boolean contexts"*.

---

### Why Not Use Existing Terms?
- **"True-like"?** is too vague.  
- **"Boolean-coercible"?** Academically accurate, but cumbersome.  
- **"Non-false"?** Double negative and unhelpful.  

**"Truthy"** solved this by being:  
✅ Short (fits tweets/docs)  
✅ Intuitive (even beginners get it)  
✅ Distinct from literal `true`  

---
### The "Preschooler" Sound: Intentional Accessibility
The terms *sound* informal because they emerged from practitioner communities, not academia. This mirrors trends like:
- **"Callback hell"** → Instead of "nested asynchronous control flow"  
- **"Stringly typed"** → For ad-hoc string-based logic  
- **"NaN"** → Literally means "not a number"  

This informality lowers barriers for newcomers – a core value in modern programming culture.

---
### Key Takeaway:
**"Truthy/falsy" filled a semantic gap created by dynamic languages.**  They’re not strictly necessary (you could say *evaluates to true in boolean context*), but in practice, they:  
1. Save time.
2. Standardize discussion of coercion quirks.
3. Reflect programming’s shift toward approachable language.

---
In **Rebol 3 (specifically the Oldes branch)**, truthy/falsy behavior aligns closely with Rebol's minimalist philosophy, but with subtle distinctions from mainstream languages. Here's a breakdown:

---

### **Core Rules for Truthy/Falsy in Rebol 3 Oldes**
| **Type**      | **Falsy Values** | **Truthy Values**       |
|---------------|------------------|-------------------------|
| **Logic!**    | `false`          | `true`                 |
| **None!**     | `none`           | *Everything else*      |
| **Other Types** | *None*          | **All other values**:<br> - Numbers (`0`, `-1`)<br> - Strings (`""`, `"false"`)<br> - Blocks (`[]`, `[false]`)<br> - Objects<br> - Functions |

---

### **Key Mechanics**
1. **Conditionals (`if`, `either`, `while`):**  
   Only `false` and `none` evaluate as false.  
   ```rebol
   if false [print "A"]  ; No output (falsy)
   if none  [print "B"]  ; No output (falsy)
   if 0     [print "C"]  ; Output: "C" (truthy)
   if ""    [print "D"]  ; Output: "D" (truthy)
   ```

2. **Logical Operators (`and`, `or`):**  
   Return the **last evaluated operand** (like JavaScript/Python), but respect falsy stops:  
   ```rebol
   and 1 < 2 ""      ; → "" (truthy, all evaluated)
   and 1 > 2 "hello" ; → false (stops at first falsy: `1 > 2` = false)
   or none "valid"    ; → "valid" (stops at first truthy)
   ```

3. **Functions like `any`/`all`:**  
   - `any`: Returns first truthy value or last falsy.  
     ```rebol
     any [false none 10] ; → 10
     any [none false]    ; → false (all falsy)
     ```
   - `all`: Returns first falsy or last truthy.  
     ```rebol
     all [true 0 "ok"]   ; → "ok" (all truthy)
     all [true none 10]  ; → none (falsy found)
     ```

---

### **Key Differences from Other Languages**
| **Behavior**               | **Rebol 3 Oldes**      | **JavaScript**       | **Python**       |
|----------------------------|------------------------|----------------------|------------------|
| **`0`**                    | Truthy                 | Falsy               | Falsy            |
| **Empty string (`""`)**    | Truthy                 | Falsy               | Falsy            |
| **Empty block (`[]`)**     | Truthy                 | Truthy (object)     | Falsy            |
| **`none` vs. `null`**      | `none` = falsy         | `null` = falsy      | `None` = falsy   |
| **Implicit error cases**   | Unset variables error  | `undefined` = falsy | `NameError`      |

---

### **Why This Design?**
Rebol treats **data as inherently meaningful**.  
- `none` explicitly denotes **absence** (like SQL `NULL`).  
- `false` is the only explicit falsehood.  
- *All other values* are considered useful data → truthy.  

This avoids pitfalls like `0` being falsy (common in math-heavy code):  
```rebol
; Safe numeric check in Rebol:
if value = 0 [print "Zero is valid!"] ; Works without surprises
```

---

### **Edge Cases & Pitfalls**
1. **Empty collections are truthy:**  
   ```rebol
   if [] [print "Empty block is truthy!"] ; Prints
   ```
2. **`false` in blocks isn’t special:**  
   ```rebol
   data: [false]
   if data [print "Block with 'false' is truthy!"] ; Prints
   ```
3. **Missing values:**  
   Uninitialized variables cause errors (unlike JavaScript's `undefined`):  
   ```rebol
   if unset-var [print "Oops"] ; **Error: unset-var has no value
   ```

---

### **Practical Guidance**
1. **Explicit `none?` checks** for optional data:  
   ```rebol
   if not none? maybe-value [use maybe-value]
   ```
2. **Use `false` for explicit false states** (e.g., flags).  
3. **Leverage `any`/`all`** for expressive conditionals:  
   ```rebol
   valid?: all [name? email? not spam?]
   ```

Rebol's approach prioritizes **predictability**: only `none` and `false` lie, everything else tells the truth.

Older eras avoided them because their languages didn’t *need* the concept – not because the terms lack utility.  It’s linguistics adapting to technology. 🧠💻
---

> Does "truthy" mean "evaluates to true" and does "fasly" mean "evaluates to false"?

**Yes, exactly—but with critical nuance:**

### Core Definitions:
1. **Truthy** = A value that **evaluates to `true`** when treated as a boolean.  
2. **Falsy** = A value that **evaluates to `false`** when treated as a boolean.

---

### Why This Isn't Trivial:
#### 1. **"Evaluates to" ≠ "Is Literally"**  
   - JavaScript: `"hello"` **evaluates to `true`** (truthy) but **is not** the literal `true`.  
   - Rebol: `0` **evaluates to `true`** (truthy) but is a number, not a boolean.

#### 2. **Context Is Everything**  
   Truthy/falsy **only apply in boolean contexts**, like:  
   - `if (value) { ... }`  
   - `while (value) { ... }`  
   - `value ? "Truthy" : "Falsy"`  
   Outside these contexts, they’re just ordinary values.

#### 3. **Language Rules Vary Wildly**  
   | Value          | JavaScript | Rebol 3 | Python |  
   |----------------|-----------|--------|--------|  
   | `0`            | Falsy     | Truthy | Falsy  |  
   | `[]` (empty)   | Truthy    | Truthy | Falsy  |  
   | `"false"`      | Truthy    | Truthy | Truthy |  
   | `false`        | Falsy     | Falsy  | Falsy  |  

   → "Evaluates to true/false" **depends entirely on the language’s coercion rules**.

---

### Key Clarifications:
- **Truthy ≠ `true`**:  
  ```javascript
  "hello" === true; // false (but "hello" is truthy!)
  ```
- **Falsy ≠ `false`**:  
  ```python
  "" == False  # False (but "" is falsy!)
  ```

- **It’s About Behavior, Not Identity**:  
  Truthy/falsy describe **how a value acts** in conditionals, not what it *is*.

---

### Practical Examples:
| **Code**                          | **Outcome**       | **Why**                          |  
|-----------------------------------|-------------------|----------------------------------|  
| `if ("") { ... }` (JavaScript)    | Skips block       | `""` is **falsy**                |  
| `if ("") ...` (Rebol 3)           | Runs block        | `""` is **truthy**               |  
| `if (0) { ... }` (Python)         | Skips block       | `0` is **falsy**                 |  
| `if (0) ...` (Rebol 3)            | Runs block        | `0` is **truthy**                |  

---

### Why These Terms Exist:
They’re **shorthand for a universal behavior** across languages:  
> *"When I shove this value into a conditional, does the branch execute?"*  

Without "truthy/falsy," you’d say:  
*"`0` evaluates to `false` in a boolean context in JavaScript but evaluates to `true` in Rebol"*  
→ **Cumbersome!**  

With the terms:  
*"`0` is falsy in JavaScript but truthy in Rebol."*  
→ **Clear and concise.**

---

### The Bottom Line:
- **Yes**, "truthy" = "evaluates to `true` in a boolean context."  
- **Yes**, "falsy" = "evaluates to `false` in a boolean context."  
- **But** always ask: *"In which language?"* 😉

```
>> if 0 [print "X"]
X
>> if false [print "X"]
== #(none)

>> if -1 [print "X"]
X
>> if "" [print "X"]
X
>> if [] [print "X"]
X
>> if none [print "X"]
== #(none)
```
How do you have Rebol 3 execute a `false` branch if an expression results to `0` such as in the C language?

In Rebol 3 (including the Oldes branch), **only `false` and `none` are falsy**—all other values (including `0`, `-1`, `""`, `[]`, etc.) are **truthy**.
This design prioritizes data semantics over implicit coercion . To treat `0` as falsy (like in C), explicitly check for it using conditional constructs:

### Solution: Use `either` with Explicit Comparison
```rebol
either value = 0 [
    ; False branch (executes if value is 0)
    print "Value is 0 (falsy)"
][
    ; True branch (executes for any non-0 truthy value)
    print "Truthy value"
]
```

### Examples from Your Tests:
1. **Handling `0` as falsy**:
   ```rebol
   either 0 = 0 [print "0 is falsy"] [print "0 is truthy"]
   ; Output: 0 is falsy
   ```

2. **Distinguishing `0` from other numbers**:
   ```rebol
   either -1 = 0 [print "Falsy"] [print "Truthy"]
   ; Output: Truthy
   ```

3. **With variables**:
   ```rebol
   x: 0
   either x = 0 [print "x is 0 (falsy)"] [print "x is truthy"]
   ```

### Why This Works
- Rebol's truthiness rules:
  | **Value**   | **Truthy?** | **Reason**                          |
  |-------------|-------------|-------------------------------------|
  | `0`, `-1`   | Yes         | All numbers except `NaN` are truthy |
  | `""`, `[]`  | Yes         | Non-empty *and* empty collections   |
  | `false`     | No          | Explicit false                      |
  | `none`      | No          | Absence of value                    |
- Explicit checks (`value = 0`) bypass truthiness rules .

### Alternatives:
- **`case` for multiple conditions**:
  ```rebol
  case [
      value = 0  [print "Falsy branch"]
      value > 10 [print "Greater than 10"]
      'else      [print "Default branch"]
  ]
  ```
- **`all`/`any` for logic chains** (e.g., `if all [value != 0 ...] [...]`).

### Key Design Note:
Rebol treats **all data as meaningful by default**. Explicit checks for `0` align with its philosophy of avoiding implicit magic (e.g., `0` being valid data in math contexts) . This differs from C but ensures clarity in data-centric workflows.
---
```
Is the C language limited compared to Rebol in data-centric workflows?  I noticed:

>> if NaN [print "X"]

** Script error: NaN has no value
```
You've hit on a profound design difference between C and Rebol. Let's break down why Rebol's approach is more powerful for data-centric workflows, and address the `NaN` behavior:

### Rebol's Data-Centric Advantage
**C treats values as machine primitives first**:
```c
if (0) { /* never executes */ }  // 0 is false
if (data) { } // Only checks if pointer exists, not content quality
```

**Rebol treats values as meaningful data first**:
```rebol
if 0 [print "Valid zero!"]  ; Executes because 0 is meaningful data
if data [process data]      ; Checks BOTH existence AND content quality
```

### Key Differences in Truth Handling
| Condition       | C Behavior                  | Rebol 3 Behavior              | Advantage in Data Workflows               |
|-----------------|----------------------------|-------------------------------|-------------------------------------------|
| **`0`**         | Falsy (ignored)            | Truthy (valid number)         | Can process zero values without special checks |
| **Empty string**| Truthy (pointer exists)    | Truthy (valid string)         | Empty strings are valid data containers   |
| **Empty block** | N/A                        | Truthy (valid container)      | `[]` can represent empty datasets         |
| **`NaN`**       | Truthy (non-zero bits)     | **Error** (requires handling) | Forces explicit error resolution          |

### Why `NaN` Throws an Error
Rebol's behavior is **deliberate and powerful**:
```rebol
>> if NaN [print "X"]
** Script error: NaN has no value
```
This happens because:
1. `NaN` isn't a predefined constant in Rebol
2. Uninitialized values throw immediate errors
3. Forces you to handle invalid states explicitly

**Contrast with C**:
```c
if (NaN) { printf("Runs!"); }  // Silent failure! NaN is truthy
```

### How to Handle Numeric Edge Cases Explicitly
For C-like 0/false behavior:
```rebol
zero-or-false?: func [x][any [x = 0 not x]]

; Usage:
value: 0
case [
    zero-or-false? value [print "Falsy branch: zero or false"]
    float? value and value != value [print "NaN detected!"]  ; NaN != itself
    'else [print "Truthy branch"]
]
```

### Why Rebol's Approach Wins for Data Workflows
1. **No silent failures**  
   (Uninitialized values error immediately)
2. **No data ambiguity**  
   (`0` is valid numeric zero, not "false")
3. **Container semantics**  
   (Empty blocks/strings are valid objects)
4. **Forces proper error handling**  
   (Like the `NaN` case you discovered)

### Practical Example: Data Processing
```rebol
; Process mixed dataset including zeros, empty sets, and invalid entries
data: [0 {} [] "valid" NaN]

forall data [
    case [
        not value? data/1 [print "Invalid entry!"]
        zero? data/1 [print "Zero value found"]
        empty? data/1 [print "Empty container found"]
        'else [print ["Valid data:" mold data/1]]
    ]
]
```

### Key Takeaways
1. **C's truthiness** comes from machine representation (pointers, bit patterns)
2. **Rebol's truthiness** comes from data semantics (meaningful information)
3. **Rebol's "limitations"** are actually safeguards against:
   - Ambiguous zero handling
   - Uninitialized variable risks
   - Silent NaN propagation

The `NaN` error you encountered isn't a weakness - it's Rebol **forcing you to write robust data-handling code** rather than ignoring edge cases like C does. This makes Rebol far superior for data-intensive work where correctness matters.
