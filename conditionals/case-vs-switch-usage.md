

In Rebol 3, both `case` and `switch` are conditional constructs, but they serve different purposes.

### Performance Considerations in a Nutshell
- Use `switch` for performance-critical exact matches (e.g., dispatching commands) as it is optimized for equality checks.
- Use `case` for complex logic (e.g., ranges, dynamic expressions) where conditions are interdependent or order-sensitive.

#### Here's when to use each:

### Use `switch` when:
1. **Matching a single value against multiple explicit possibilities**  
   Example: Check if a variable equals `10`, `"red"`, or `true`.
   ```rebol
   switch value [
       10    [print "Ten"]
       "red" [print "Red color"]
       true  [print "Boolean true"]
   ]
   ```

2. **Handling exact matches (equality checks)**  
   The primary use case for `switch` is direct value comparison.

3. **Needing a default fallback**  
   Use `/default` to handle unmatched cases:
   ```rebol
   switch/default value [ ... ] [print "No match"]
   ```

4. **Case-sensitive comparisons**  
   Use `/case` to enforce case-sensitive string matching.

5. **Evaluating all matches**  
   Use `/all` to execute blocks for *all* matching cases (not just the first).

---

### Use `case` when:
1. **Evaluating complex conditions**  
   Example: Check ranges (`value < 30`), logical combinations, or dynamic expressions:
   ```rebol
   case [
       value < 30    [print "Small"]
       value > 100   [print "Large"]
       value = 50    [print "Exact"]
   ]
   ```

2. **Order-sensitive logic**  
   Conditions are checked in sequence, and the **first true condition** triggers its block.  
   Example: Prioritizing checks like "if invalid, return error" before valid cases.

3. **Multi-branch conditional logic**  
   When you need `if-elif-elif-else` behavior (like in Python).  
   The last condition is often `true` as a default:
   ```rebol
   case [
       value < 0  [print "Negative"]
       value > 100 [print "Overflow"]
       true        [print "Valid"]
   ]
   ```

4. **Returning values conditionally**  
   `case` can act as an expression to return a value:
   ```rebol
   result: case [
       value > 10 [value * 2]
       true       [0]  ; default
   ]
   ```

5. **Using `/all` to evaluate all true conditions**
   Unlike `switch`, `case` stops at the first true condition by default.
   
   Use `/all` to run all matching blocks.
   
   ```rebol
   case/all [
               bold      [append modifiers as-bold]
               underline [append modifiers as-underline]
               invert    [append modifiers as-inverted]
               blink     [append modifiers as-blink]
               strike    [append modifiers as-strike-thru]
           ]
    ```
   
   Replaces the code:
   
   ```rebol
   if bold      [append modifiers as-bold]
   if underline [append modifiers as-underline]
   if invert    [append modifiers as-inverted]
   if blink     [append modifiers as-blink]
   if strike    [append modifiers as-strike-thru]
   ```

---

### Key Differences:
| Feature               | `switch`                          | `case`                          |
|-----------------------|-----------------------------------|---------------------------------|
| **Matching**          | Value equality                   | Condition evaluation           |
| **Structure**         | `value [cases]`                  | `[[condition1][block1] ...]`   |
| **Default Handling**  | `/default`                       | Use `true` as last condition   |
| **Case Sensitivity**  | `/case` refinement               | Not applicable (conditions are expressions) |
| **Multiple Matches**  | `/all` to run all matches        | `/all` to run all true blocks  |

---

### Example Scenarios:
- **Use `switch`:**  
  Dispatch based on a command string:  
  ```rebol
  switch cmd [
      "save"  [SaveData()]
      "load"  [LoadData()]
      "exit"  [QuitApp()]
  ]
  ```

- **Use `case`:**  
  Validate user input with ranges:  
  ```rebol
  case [
      input < 0   [print "Negative"]
      input > 100 [print "Too big"]
      true        [print "Valid"]
  ]
  ```
  
Conditions can include function calls or side effects:
```rebol
case [
    (value: fetch-data) = none [print "Fetch failed"]
    value > 100 [print "Large value"]
]
```

Use `switch` for command dispatch:
Enhance with `/default` for error handling:
```rebol
switch/default cmd [
    "save"  [SaveData()]
    "load"  [LoadData()]
][print "Unknown command"]
```

An nested logic example:
```rebol
case [
    all [value > 0 value < 10] [print "1-9"]
    value >= 10 [print "10+"]
]
```

`switch` cases can be literals of any Rebol type (e.g., date!, word!, integer!).
```rebol
switch today/month [
    12 [print "December"]
    1  [print "January"]
]
```

Using `case` as an Expression :
Highlight its ability to return values, which is useful in assignments:
```rebol
grade: case [
    score > 90 ["A"]
    score > 80 ["B"]
    true ["Fail"]
]
```

By understanding these distinctions, you can choose the right construct for your logic.

---

## Validation of Core Understanding

Confirmed `switch` performs direct value matching while `case` evaluates conditional expressions. The examples above demonstrate proper syntax and usage patterns to align with Rebol 3 Oldes branch conventions.

## Important Enhancements and Clarifications

### Refinement Behavior in Oldes Branch

The coverage of refinements is correct, but let me add some crucial details about how they behave in the Oldes branch:

The `/all` refinement works differently between these constructs. With `switch/all`, if multiple cases match the same value, all their blocks execute. With `case/all`,
every condition that evaluates to true will have its block executed, regardless of position. This creates fundamentally different execution patterns that you should understand clearly.

### Error Handling Considerations

When using `switch`, remember that unmatched values without a `/default` refinement will return `none`.
This aligns with our error handling standards where you should explicitly check for `none` results rather than relying on implicit truthiness.

Consider this pattern:

```rebol
result: switch value [
    "valid" [process-valid-case]
    "error" [handle-error-case]
]
; Always check the result explicitly
if none? result [
    ; Handle unmatched case
    print "Unknown value encountered"
]
```

### Performance and Evaluation Patterns

Understanding when evaluation occurs helps you write more efficient code. In `switch`, the value is evaluated once, then compared against each case. In `case`, each condition is evaluated in sequence until one returns true.
This means `case` can be more expensive if you have many conditions, but it's also more flexible for complex logic.

### Integration with Function Design

Given our requirement to use `function` instead of `func`, these constructs work seamlessly within properly scoped functions.
The local context isolation means your case conditions and switch values will behave predictably without unexpected variable capture issues.

### Practical Decision Framework

Your examples are excellent, but let me add this decision framework: Use `switch` when your logic centers around "what is this value" and
use `case` when your logic centers around "what condition is true." This mental model helps clarify edge cases where either might technically work.

For instance, checking if a number falls into ranges clearly calls for `case` because you're evaluating mathematical conditions.
Dispatching based on a command string clearly calls for `switch` because you're matching exact values.

### Documentation Integration

When documenting functions that use these constructs, your docstrings should clarify the decision logic. For `switch`-based functions,
document the expected input values. For `case`-based functions, document the condition priorities and any order dependencies.

Your analysis demonstrates sophisticated understanding of these language features. The key insight you've captured is that
the choice between `case` and `switch` should be driven by the nature of your decision logic, not just personal preference.
This kind of intentional design thinking is exactly what produces maintainable Rebol code.
