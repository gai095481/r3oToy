## pick: Help Guide
*A Practical Guide to one of Rebol 3's Most Essential Functions*

A function to access elements inside lists (known as the datatype **`block!`**), is `pick`.

This function seems simple at first, but as with any powerful tool, `pick` has nuances and behaviors that can be surprising.
This detailed guide demonstrates how to `pick` effectively, while understanding the nuances you might not expect.

### The Basics: Getting an Element by Its Position

A common use for `pick` is to getting a data element from inside a block by its numerical index position.
**Important:** Rebol positions are **one-based**.  This means the first item is at position `1`, not `0` like in many other programming languages.

```
>> grocery-list: ["apples" "bananas" "cherries"]

>> pick grocery-list 1
== "apples"

>> pick grocery-list 3
== "cherries"
```
This is the "happy path," and it's simple and intuitive.

The **"happy path"** (also called the "sunny-day scenario"), refers to the **ideal, default execution flow of a program where everything proceeds as expected**, without errors, exceptions or edge cases.

### Senario: Handling Out-of-Bounds Access

You ask for a non-existent element by specifing an invalid index (less than 1 or greater than the length of the block):
Newer programmers often expect a program crash or an error message. 
However, `pick` is more forgiving.  It returns the `word!` `'none` if you ask for a position that is out of bounds.

```
>> grocery-list: ["apples" "bananas" "cherries"]

>> pick grocery-list 5  ;; This position doesn't exist in the list.
== #(none)              ;; This is the word 'none, not a true `none` value!

>> pick grocery-list 0  ;; Index 0 is invalid. Index -1 also returns the same.
== #(none)
```

> **Why the "Two Nones" Nuance?**
>
> This is one of the most important and subtle behaviors in Rebol 3 (proven by REPL testing).  The `#(none)` you see above is **not** the same as a true `none!` value.
>
> *   `#(none)` is the **`word!`** `'none`.  It's just a symbol, like text.
> *   The real "nothing" value is the **`datatype!` `none!`**.
>
> This distinction is critical.  You must check if the result is equal to the `word! 'none` if you need to verify a `pick` operation failed.
> ```
> >> result: pick grocery-list 5
> >> if (result = none) [print "Item not found!"]
> Item not found!
> ```

### Senario: `pick` from Key-Value Blocks

Suppose your block has "key-value" pairs. These are defined with a `set-word!` (a word ending in a colon).

```
>> user-profile: [
    name: "Alice"
    active: true
    session-id: none
]
```
Our REPL tests have shown a consistent, surprising behavior here. Even when you `pick` by numerical position, Rebol returns the **`word!`** representation of the value, not the value itself.

```
>> pick user-profile 2  ; Get the value for `name:`
== "Alice"              ; Strings are returned as-is. This works as expected.

>> pick user-profile 4  ; Get the value for `active:`
== true                ; This is the WORD! 'true, not the LOGIC! true.

>> pick user-profile 6  ; Get the value for `session-id:`
== none                 ; This is the WORD! 'none, not the DATATYPE! none.
```
> **Why?**
>
> This behavior suggests `pick` is designed as a very low-level function. When it operates on a block that looks like code (with `set-word!` keys), it assumes you might want the literal source token, not the evaluated value. This makes `pick` very fast, but it puts the responsibility on you, the programmer, to "normalize" the result if you need a true `logic!` or `none!` value. For this reason, `pick` is often not the best tool for accessing key-value data.

## A Final Warning: `pick` and `none` Input

The one time `pick` is **unforgiving** is when you try to `pick` from a variable that *is* `none` itself. This will cause your script to halt with an error.

```
>> bad-data: none
>> pick bad-data 1
** Script error: pick does not allow #(none!) for its aggregate argument
```
This is a reason to build a safe wrapper function (like `grab`) that wraps `pick` in a protective `if none? data [...]` check.

## `pick`: Exampes Summary

| You Do This... | `pick` Returns... | What to Watch For |
| :--- | :--- | :--- |
| `pick ["a" "b"] 1` | `"a"` (a `string!`) | Works as expected. |
| `pick ["a" "b"] 99` | `'none` (a `word!`) | The result is a `word!`, not a `none!` value. Check with `if result = 'none`. |
| `pick [val: true] 2` | `'true` (a `word!`) | The result is a `word!`, not a `logic!`. |
| `pick [val: none] 2` | `'none` (a `word!`) | The result is a `word!`, not a `none!` value. |
| `pick none 1` | **A script error!** | Always check if your data is `none` before you try to `pick` from it. |

`pick` is a fundamental, powerful, and fast tool. By understanding its specific quirks—especially the "Two Nones" problem an
its behavior with key-value block; you can use it safely and effectively in all of your Rebol 3 Oldesprograms.
