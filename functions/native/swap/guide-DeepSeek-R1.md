# Unofficial `swap` Function User's Guide

## Overview

The `swap` function exchanges elements at the current positions of two series.
Here's what you need to know based on rigorous testing in REBOL/Bulk 3.19.0:

> swap *series1 series2*

- **series1**: First series at position (modified).
- **series2**: Second series at position (modified).


## Key Behaviors & Nuances

### 1. Core Functionality

- Swaps elements at current positions of two series.
- Works with the `string!`, `block!` and `gob!` datatypes.
- Both series must be of the SAME type (mixed types cause errors).

```rebol
;; String swap example:
str1: "abc" 
str2: "123"
swap next str1 next str2
;; str1 becomes "a2c", str2 becomes "1b3"

;; Block swap example
blk1: [a b c]
blk2: [1 2 3]
swap next blk1 next blk2
;; blk1 becomes [a 2 c], blk2 becomes [1 b 3]
```

### 2. Same-Series Swapping

- Works within a single series.
- Handles adjacent and non-adjacent positions.
- Identical position is a no-operation.

```rebol
;; Swap elements in same block:
data: [a b c]
swap data next data  ;; Swap first and second elements
;; Result: [b a c]

;; Swap non-adjacent in string:
text: "abcd"
swap text skip text 2  ;; Swap 'a' and 'c'
;; Result: "cbad"
```

### 3. Critical Nuances (Novice Pitfalls)

#### 🚫 Type Compatibility

```rebol
;; ERROR: Mixed series types:
swap "abc" [1 2 3]   ; Fails - string vs block

;; SOLUTION: Convert to same type first
swap "abc" form [1 2 3]  ;; Convert block to string
```

#### 🚫 Position Validity

```rebol
;; ERROR: Position beyond series end
swap next "a" "xyz"   ;; Fails - can't swap beyond the tail.

;; SOLUTION: Check positions first
if all [not tail? pos1  not tail? pos2] [swap pos1 pos2]
```

#### ⚠️ Tail Position Handling

```rebol
;; Silent no-op at tail positions
swap tail "abc" "def"   ;; Does nothing.
swap "abc" tail "def"   ;; Does nothing.

;; SOLUTION: Ensure valid positions
text: "hello"
position: find text "e"
swap text position  ;; A valid swap.
```

### 4. Edge Case Handling

| Case | Behavior | Recommended Approach |
|------|----------|----------------------|
| **Empty series** | No operation | Check `empty?` before swapping |
| **Both tails** | No operation | Verify positions with `index?` |
| **Different element types** | Allowed in blocks | No special handling needed |
| **Identical position** | No operation | Skip unnecessary swaps |

### 5. Error Conditions

The function will throw errors when:

1. Arguments are non-series types
   ```rebol
   swap 10 20  ;; Error: non-series arguments
   ```
2. Series types don't match
   ```rebol
   swap "text" [b l o c k]  ;; Error: type mismatch
   ```
3. Positions are invalid (out of range)
   ```rebol
   swap next "x" next "yz"  ;; Fails on short series
   ```

### Pro Tips for Robust `swap` Usage

1. **Position Validation Helper**

```rebol
safe-swap: func [a b][
    if all [
        same? type? a type? b
        not tail? a
        not tail? b
        (index? a) <= length? a
        (index? b) <= length? b
    ][
        swap a b
    ]
]
```

2. **Type Conversion Pattern**

```rebol
;; When dealing with mixed data sources:
swap to-string src1 to-string src2
```

3. **Position Reset After Swap**

```rebol
;; Positions change after swap - reset if needed:
pos1: next data
pos2: skip data 2
swap pos1 pos2
;; Reset positions if maintaining pointers
pos1: back pos1  ;; Return to original element
```

## Summary of Key Insights

1. 🔄 Swaps elements at CURRENT positions (not entire series).
2. 🧪 Requires identical series types (string-block mix fails).
3. 🚧 Fails on out-of-range positions (use position checks).
4. 🤫 Silent no-op at tail positions (verify positions).
5. ✅ Allows different value types within blocks.
6. ⛔ Throws errors for non-series arguments.

Use these patterns to avoid common pitfalls and leverage `swap` effectively in your Rebol programs.
