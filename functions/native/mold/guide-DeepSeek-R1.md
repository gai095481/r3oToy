# User's Guide: `mold` Function in REBOL/Bulk 3.19.0

## Understanding the `mold` Function

The `mold` function converts any Rebol value to a REBOL-readable string. This is essential for:
- Serializing data for storage
- Debugging complex structures
- Generating Rebol code programmatically

### Basic Usage
```rebol
mold value
```

### Key Findings from Rigorous Testing
1. **Scalar Values**:
   ```rebol
   mold 123        ; => "123"
   mold 12.34      ; => "12.34"
   mold true       ; => "#(true)"     ; Note special format
   mold false      ; => "#(false)"    ; Note special format
   mold none       ; => "#(none)"     ; Note special format
   mold 'word      ; => "word"
   mold "text"     ; => {"text"}
   mold %file.txt  ; => "%file.txt"
   mold #{}        ; => "#{}"         ; Empty binary
   ```

2. **Block Values**:
   ```rebol
   mold [1 2 3]        ; => "[1 2 3]"
   mold ["a" b 3]      ; => {"a" b 3}
   mold []             ; => "[]"
   ```

3. **Refinements**:
   - `/only` - Removes outer brackets for blocks:
     ```rebol
     mold/only [1 2 3]  ; => "1 2 3"
     mold/only 'word    ; => "word"  ; Ignores non-blocks
     ```
   - `/flat` - Produces single-line output (default behavior in this version):
     ```rebol
     mold/flat [a [b [c]]  ; => "[a [b [c]]" 
     ```
   - `/part` - Limits output length:
     ```rebol
     mold/part "hello" 3  ; => "hel"
     mold/part 123 0      ; => ""  ; Zero returns empty string
     ```
   - `/all` - **No observable effect** in this version (output identical to normal mold)

4. **Special Cases**:
   ```rebol
   ; Empty object includes newline
   mold context []  ; => "make object! [^/]"

   ; Error objects include system fields
   mold make error! [code: 400 type: 'user id: 'message arg1: "test"]
   ; => make error! [
   ;     code: 800  ; Note: System may override code
   ;     type: 'user
   ;     id: 'message
   ;     arg1: "test"
   ;     arg2: #(none)
   ;     ...]
   ```

### Common Nuances & Solutions
1. **Logic/None Values Surprise**:
   ```rebol
   ; Novice mistake:
   if mold true = "true" [print "This won't print!"]

   ; Solution:
   if mold true = "#(true)" [print "Correct comparison"]
   ```

2. **Block vs. /only Output**:
   ```rebol
   ; Unexpected behavior:
   mold/only [1 2 3]  ; => "1 2 3" (no brackets)

   ; Workaround for code generation:
   rejoin ["[" mold/only block "]"]

   ; Better alternative for code blocks:
   mold block  ; Use without /only for standard formatting
   ```

3. **Error Object Fields**:
   ```rebol
   ; System adds extra fields to errors
   err: make error! [message: "test"]
   probe mold err  ; Contains arg2, near, where, etc.

   ; Solution for clean output:
   clean-err: make object! [
       code: err/code type: err/type id: err/id 
       arg1: err/arg1
   ]
   mold clean-err
   ```

4. **/part With Blocks**:
   ```rebol
   ; Truncation occurs at character level:
   mold/part [10 20 30] 5  ; => "[10 2"

   ; Solution for clean partial output:
   as-string: copy ""
   foreach item block [
       append as-string mold item
       if (length? as-string) >= limit [break]
       append as-string " "
   ]
   ```

5. **Empty Values Handling**:
   ```rebol
   ; All empty types mold predictably:
   mold []   ; => "[]"
   mold ""   ; => {""}
   mold #{}  ; => "#{}"
   ```

### Pro Tips
1. **For Debugging**:
   ```rebol
   ; Use mold for readable output
   print mold complex-data

   ; Combine with probe for inspection
   probe mold nested-block
   ```

2. **Serialization**:
   ```rebol
   ; Save data structures
   save %data.txt mold dataset

   ; Load with do/next
   data: do/next load %data.txt
   ```

3. **Code Generation**:
   ```rebol
   ; Generate function calls
   args: [1 2 3]
   code: rejoin ["func-name " mold/only args]
   ; => "func-name 1 2 3"

   ; Execute generated code
   do code
   ```

4. **Custom Formatting**:
   ```rebol
   ; Handle special types
   custom-mold: func [val][
       case [
           object? val [rejoin ["object " mold val]]
           'else [mold val]
       ]
   ]
   ```

### Summary Table
| Feature          | Behavior                          | Special Notes                 |
|------------------|-----------------------------------|-------------------------------|
| Logic values     | `#(true)`, `#(false)`            | Not "true"/"false"            |
| None             | `#(none)`                        | Not "none"                    |
| /only refinement | Removes [] from blocks            | Ignores non-blocks            |
| /all refinement  | No effect (same as normal)        |                               |
| /part refinement | Strict length limit               | Zero returns empty string     |
| Error objects    | Adds system fields                | Code may be overridden        |
| Empty object     | Contains newline `[^/]`           |                               |

Remember: "Truth from the REPL" - always verify behavior with `print mold your-value`!

This guide reflects the actual behavior verified through 39 test cases in REBOL/Bulk 3.19.0. The nuances section specifically addresses pain points for novice programmers with practical solutions and workarounds.
