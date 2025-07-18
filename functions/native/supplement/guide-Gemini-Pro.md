# Unoffical User's Guide: `supplement`

A comprehensive overview of the `supplement` function in REBOL/Bulk 3.19.0, based on rigorous, evidence-based testing. It is designed to help you use the function effectively and avoid common pitfalls.

### Function Signature

```rebol
supplement series value
supplement/case series value
```

| Argument | Type     | Description                                |
| :------- | :------- | :----------------------------------------- |
| `series` | `block!` | The block to modify.                       |
| `value`  | `any-type!` | The value to append if it's not found.     |

| Refinement | Description                     |
| :--------- | :------------------------------ |
| `/case`    | Forces a case-sensitive search. |

---

### 1. Core Concept: Add if Missing

The primary purpose of `supplement` is to add a value to a block, but only if that value doesn't already exist in the block. It modifies the original block directly (it is "destructive").

The default search is **case-insensitive**.

```rebol
>> numbers: [1 2 3]
>> supplement numbers 4 ;; 4 is not in the block, so it's added.
== [1 2 3 4]
>> probe numbers
[1 2 3 4]

>> supplement numbers 2 ;; 2 is already there, so the block is unchanged.
== [1 2 3 4]
>> probe numbers
[1 2 3 4]

>> words: ["cat" "dog"]
>> supplement words "CAT" ;; "CAT" is found (case-insensitive), block is unchanged.
== ["cat" "dog"]
>> probe words
["cat" "dog"]
```

---

### 2. The `/case` Refinement: Forcing Strictness

If you need a case-sensitive search, use the `/case` refinement. This is essential when the distinction between, for example, `"Apple"` and `"apple"` matters.

```rebol
>> fruits: ["Apple" "Orange"]

;; Default behavior: "apple" is found, so nothing is added.
>> supplement fruits "apple"
== ["Apple" "Orange"]

;; With /case: "apple" is NOT found, so it is appended.
>> supplement/case fruits "apple"
== ["Apple" "Orange" "apple"]

>> probe fruits
["Apple" "Orange" "apple"]
```

---

### 3. Return Value: It's All About Position

A crucial, and often misunderstood, feature of `supplement` is its return value.

**`supplement` returns the series at the exact position it was given.**

If you pass the head of a block, it returns the head. If you pass it a position midway through a block, it returns that exact position back to you.

```rebol
>> my-block: [10 20 30]
>> returned-val: supplement my-block 40
== [10 20 30 40]
>> same? my-block returned-val
== true

;; Let's try with a series not at its head
>> mid-point: next my-block ; mid-point is now [20 30 40]
>> returned-val: supplement mid-point 50
== [20 30 40 50]

>> probe my-block ;; The original block is still modified at its tail
[10 20 30 40 50]

>> same? mid-point returned-val ;; The return value is the same as what we passed in
== true
```

**Novice Tip:** Unless you are intentionally chaining operations, you can typically ignore the return value and just trust that your original block has been correctly modified.

---

### 4. Critical Nuance: Handling Block Values

This is the most significant "gotcha" for new users. `supplement` does **not** add a block as a single, nested item. Instead, it adds the **contents** of the block to your series.

This happens because `supplement` internally uses `find` and `append`, neither of which have the `/only` refinement by default. `find` will fail to locate the sub-block and `append` will then splice the contents of the value block into the series.

```rebol
>> data: [[a b] [c d]]

;; Our goal is to add the block [e f]
>> supplement data [e f]

;; This is the result:
>> probe data
[[a b] [c d] e f]  ; <-- NOT [[a b] [c d] [e f]]
```

#### **How to Correctly Supplement with a Block**

If you want to add a block as a single item *only if it's not present*, you must perform the logic manually. The most direct Rebol pattern is:

```rebol
my-series: [[a b] [c d]]
value-to-add: [e f]

;; If the value is not found...
if not find my-series value-to-add [
    ;; ...append it as a single item using /only
    append/only my-series value-to-add
]

probe my-series
;; >> [[a b] [c d] [e f]]
```

---

### 5. Error Handling: Know Your Limits

The `series` argument to `supplement` **must be a `block!`**.
Providing any other series type, such as a `string!` or `hash!`, will result in a script error.

```rebol
; CORRECT
>> supplement [1 2] 3

; INCORRECT - This will throw an error
>> supplement "a b c" "d"
** Script error: supplement does not allow string! for its series argument
```

### Summary of Key Takeaways

1. **In-Place Modification:** `supplement` changes your original block.
2. **Case-Insensitive Default:** Use `/case` when you need strict, case-sensitive comparisons.
3. **Positional Return Value:** It returns the series at the same position you passed to it, which is useful for chaining but can be surprising.
4. **Block Contents, Not the Block:** **BEWARE:** `supplement data [a b]` adds `a` and `b` to `data`, not the block `[a b]`. Use `if not find... [append/only ...]` to add a block as a single element.
5. **Block! Only:** The function is restricted to working on `block!` series.

