# Unofficial `swap` User’s Guide  
*Diagnostically proven against REBOL/Bulk 3.19.0 via Kimi K2 AI*

## 1. Purpose  
`swap` exchanges **exactly one element** (or sub-series), between two positions in one or two series.  
It is **zero-copy**, **in-place** and **constant-time**.

---

## 2. Function Signature  

> swap *series1 series2*

| Argument | Type      | Description |
|----------|-----------|-------------|
| series1  | series!   | A series or a series position (modified). |
| series2  | series!   | Same as above. |

> **Not accepted**: `gob!`, `integer!`, `none` or any non-series value.

---

## 3. Core Behavior (Evidence-Based)

| Case | Before | After |
|------|--------|-------|
| **Two distinct blocks** | `[1 2 3]` `[a b c]` | `[a 2 3]` `[1 b c]` |
| **Same block**          | `[1 2 3 4 5]` | swap head next → `[2 1 3 4 5]` |
| **Empty series**        | `[] [x y z]` | `[]` and `[x y z]` unchanged |
| **Single element**      | `[42] [99]` | `[99] [42]` |
| **Offset positions**    | `skip [a b c d] 1`, `skip [x y z] 2` | `[a z c d]`, `[x y b]` |
| **Large series**        | 10 000 items | only **one** element swapped – O(1) |
| **Nested blocks**       | `[[1 2] [3 4]]`, `[[a b] [c d]]` | swap `at … 2` → `[[1 2] [c d]]`, `[[a b] [3 4]]` |

---

## 4. Common Pitfalls & How to Fix Them

| Pitfall | Symptom | Fix |
|---------|---------|-----|
| **Expecting whole-series swap** | Only first element changes | Remember `swap` is **single-element**. Use `change/part` if you need to move entire blocks. |
| **Passing integers or `none`** | `Script error: swap does not allow …` | Ensure both arguments are `series!` (use `to-block`, `to-string`, etc., if needed). |
| **Swapping inside nested values** | `Script error: swap does not allow #(integer!) …` | Swap **positions**, not individual numbers: `swap at block 2/1 at other 2/1` is wrong. Use `swap at block 2 at other 2`. |
| **Empty series** | Nothing happens | This is correct behaviour; `swap` is idempotent on empty series. |
| **GOB! objects** | Runtime error | Convert to a series representation (e.g., block of attributes) before swapping. |

---

## 5. Idiomatic Patterns

### 5.1 Move record to front  
```rebol
swap log-block at log-block record-idx   ; zero-copy promotion
```

### 5.2 Column pivot in a matrix  
```rebol
foreach row matrix [swap at row col-a at row col-b]
```

### 5.3 Rotate sliding window  
```rebol
swap sensor-window back tail sensor-window   ; oldest ↔ newest
```

### 5.4 In-place shuffle (Fisher-Yates)  
```rebol
for i (length? data) 1 -1 [
    j: random i
    swap at data i at data j
]
```

---

## 6. Performance Notes  
- **Time complexity**: Θ(1) – always one element moved.  
- **Memory**: No allocations; pointers exchanged only.  
- **Thread safety**: Not atomic; wrap in locks for concurrent use.

---

## 7. Quick Reference Card

| Goal | One-Liner |
|------|-----------|
| Swap first two items | `swap block next block` |
| Swap last two items  | `swap back tail block back back tail block` |
| Reverse byte order   | `repeat i (length? bin) / 2 [swap at bin i at bin (length? bin) - i + 1]` |
| Promote item `k`     | `swap block at block k` |

---

## 8. Final Checklist  
- [ ] Both arguments are **series!** and **not empty** when you care about data.  
- [ ] You are swapping **positions**, not raw values.  
- [ ] Expect **exactly one** element to change per invocation.  
- [ ] Use `error? try [swap …]` to handle non-series inputs gracefully in user code.
