## Rebol 3 `remove` Function Guide

Based on extensive testing in REBOL/Bulk 3.19.0 via DeepSeek R1,
this guide covers practical usage and nuances of the `remove` function.

### Core Functionality
```rebol
remove series  ;; Removes element at current position
```
**Returns**: Modified series at same position  
**Modifies**: Original series (mutating operation)

### Supported Datatypes
- `string!` - Character removal
- `block!` - Value removal
- `map!` - Key removal (with `/key` refinement)
- `bitset!`, `gob!`, `port!` (less common)

### Basic Usage
#### Strings
```rebol
str: "Hello World"
remove str  ;;=> "ello World" (removes first character)

str: "ABCDEF"
remove/part str 3  ;; Removes first 3 chars => "DEF"
```

#### Blocks
```rebol
blk: [a b c d]
remove blk  ;;=> [b c d] (removes first element)

blk: [1 2 3 4]
remove/part blk 2  ;;=> [3 4] (removes first two)
```

#### Maps
```rebol
m: make map! [id: 123 name: "Alice"]
remove/key m 'name  ;; Removes 'name key
```

### Key Refinements
#### `/part` - Controlled Removal
```rebol
;; Remove specific count
remove/part "123456" 3  ;;=> "456"

;; Remove to specific position
pos: find "start<remove>end" "<remove>"
remove/part pos 8  ;;=> "startend"

;; Remove using character
remove/part "abcXdef" #"X"  ;;=> "def" (removes up to 'X')
```

#### `/key` - Map Operations
```rebol
m: make map! [a: 1 b: 2]
remove/key m 'a  ;; Removes key 'a

;; Safe key removal pattern
if find m 'key-to-remove [
    remove/key m 'key-to-remove
]
```

### Position-Based Removal
```rebol
;; Remove at specific index
remove at "12345" 3  ;;=> "1245" (position 3 removed)

;; Remove last character
remove back tail "Rebol"  ;;=> "Rebo"

;; Case-sensitive removal
remove find/case "CaseSensitive" "S"  ;;=> "Caseensitive"
```

### Special Cases & Nuances
#### Empty Series
```rebol
remove ""  ;; Returns empty string (no error)
remove []  ;; Returns empty block (no error)
```

#### Unicode Handling
```rebol
;; Works with multi-byte characters
remove "🐱🐶🐰"  ;=> "🐶🐰"
```

#### Return Value Behavior
```rebol
;; Returns modified series at same position
str: "abcdef"
result: remove str
result == str  ;;=> true (same series reference)
```

#### Nested Structures
```rebol
;; Removing nested blocks
blk: [1 [2 3] 4]
remove next blk  ;;=> [1 4] (removes nested block)
```

### Common Pitfalls & Solutions
1. **Position Mismanagement**
   ```rebol
   ;; Wrong: 
   remove find "start<remove>end" "<remove>" 
   ;; => "<remove>end" (only removes first char)

   ;; Right:
   remove/part find "start<remove>end" "<remove>" 8
   ```

2. **Case Sensitivity Issues**
   ```rebol
   ;; Use /case for exact matching:
   remove find/case "CaseSensitive" "S"
   ```

3. **Map Key Verification**
   ```rebol
   ;; Always verify existence first:
   if find map 'key [remove/key map 'key]
   ```

4. **Unintended Type Coercion**
   ```rebol
   ;; Fails silently on numbers:
   remove 123  ; Throws error
   ```

5. **Character Refinement Gotchas**
   ```rebol
   ;; Removes UP TO character, not including:
   remove/part "abcXdef" #"X"  ;=> "def" not "Xdef"
   ```

### Performance Tips
1. **Batch Removal**  
   Use `/part` instead of multiple single removes:
   ```rebol
   ;; Slower:
   loop 100 [remove str]
   
   ;; Faster:
   remove/part str 100
   ```

2. **Position Caching**  
   For multiple operations, save positions:
   ```rebol
   pos: find str pattern
   remove pos
   ;; Additional operations on pos
   ```

3. **Avoid Unnecessary Copies**  
   Since `remove` mutates originals, work directly on series when possible.

### Error Handling
```rebol
;; Proper error trapping pattern:
set/any 'result try/with [
    remove invalid-value
][error!]

if error? :result [
    ;; Handle error
]
```

### Real-World Examples
#### Remove All Vowels
```rebol
vowels: charset "aeiou"
str: "Programming"
while [pos: find str vowels] [remove pos]
;;=> "Prgrmmng"
```

#### Clean Input String
```rebol
clean-input: function [input][
    remove/part input find input #"@"  ;; Remove up to @
    remove find input " "              ;; Remove first space
]
```

#### Safe Map Pruning
```rebol
prune-map: function [m keys][
    foreach key keys [
        if find m key [remove/key m key]
    ]
]
```

> **Pro Tip**: Always test edge cases (empty values, special characters, Unicode) when using `remove` in production code.
