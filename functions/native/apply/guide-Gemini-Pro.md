# Unofficial `apply` Function User's Guide

A robust overview of the `apply` function in Rebol 3 (Oldes branch), based on rigorous, evidence-based testing. It clarifies common misconceptions and provides practical advice for both new and experienced programmers.

## 1. Core Mission of `apply`

At its heart, `apply` answers the question: "**How do I call a function when its arguments are already collected in a block?**"

Normally, you call a function with arguments that are typed directly into the code:

```rebol
>> add 10 20
== 30
```

The `apply` function lets you to achieve the same result, but by providing the arguments in a `block!` instead:

```rebol
>> arg-block: [10 20]
>> apply :add arg-block
== 30
```

This capability is fundamental for meta-programming, creating Domain-Specific Languages (DSLs), and dynamic function execution.

## 2. Function Signature

> apply *func block*
> apply/only *func block*


* `func`: The function or operator (`op!`) you want to execute.
* `block`: A block containing the arguments for the function.
* `/only`: A refinement that dramatically changes how the argument `block` is handled.

---

## 3. Default Behavior: `apply` Reduces its Arguments

By default, `apply` **reduces** (evaluates), the argument block before passing the results to the function. This is the most intuitive behavior.

Think of it as a `do` operation happening to your argument block first.

### Example: Simple Reduction

```rebol
>> add-two: func [a [integer!] b [integer!]] [a + b]

>> arg-block: [5 + 5 10 * 2] ; A block of expressions

>> apply :add-two arg-block
== 30
```

**What happened here?**

1. `apply` received the argument block `[5 + 5 10 * 2]`.
2. It reduced this block, evaluating the expressions to get `[10 20]`.
3. It then called the `add-two` function with the *results*: `add-two 10 20`.

---

## 4. The `/only` Refinement: A Common Pitfall

The `/only` refinement is powerful but frequently misunderstood.

**Misconception:** `apply/only` passes the argument block itself as a single, literal argument.
**Truth:** `apply/only` passes the *elements* of the argument block as-is, without reducing them.

This distinction is critical.

### Example: The `/only` Pitfall

Let's try to pass a literal block `[1 + 2]` to a function that just returns its input.

```rebol
>> identity: func [value] [:value]

; What you might intuitively try:
>> apply/only :identity [1 + 2]
== 1
```

This is **not** `[1 + 2]`! Why? Because `/only` treated `1`, `+`, and `2` as three separate, literal arguments. Since `identity` only takes one argument, `apply` passed the first one (`1`) and silently ignored the `+` and `2`.

### The Correct Way to Pass a Literal Block

To pass an entire block as a single literal argument using `apply/only`, you must **nest it inside the argument block**.

```rebol
>> identity: func [value] [:value]

>> arg-block: [ [1 + 2] ] ; The block we want is now the first *element*

>> apply/only :identity arg-block
== [1 + 2]
```

This works because `/only` takes the first element of `arg-block`, which is the literal block `[1 + 2]`, and passes it to `identity` as a single argument.

---

## 5. Arity (Argument Count): The Silent Ignorer

How `apply` handles the number of arguments is another non-obvious behavior.

### Too Few Arguments: It Errors

This behaves as you would expect. If a function needs two arguments and you only provide one, `apply` will raise an error.

```rebol
>> add-two: func [a [integer!] b [integer!]] [a + b]
>> apply :add-two
** Script Error: add-two needs 2 values, but has 1
```

### Too Many Arguments: It Silently Ignores Them

This is a major "gotcha" for programmers. If you provide more arguments than the function needs, `apply` **does not complain**. It simply uses the arguments it needs and discards the rest.

```rebol
>> add-two: func [a [integer!] b [integer!]] [a + b]

;; Note the extra arguments "ignored" and 999
>> arg-block: [10 20 "ignored" 999]

>> apply :add-two arg-block
== 30
```

The function call was effectively `add-two 10 20`. The remaining items in the block were ignored.

**Advice for Novices:** This behavior can hide bugs. When your argument block is dynamically generated, be very careful to ensure it contains the exact number of arguments the target function expects.

---

## 6. Practical Use Cases

1. **Dynamic Dispatch:** Call functions based on data.
   
   ```rebol
   >> function-to-call: :add
   >> args: [100 200]
   >> apply function-to-call args
   == 300
   ```
2. **Building Interpreters:** `apply` is essential for evaluating function calls in a custom language.
   
   ```rebol
   ; ; Pseudo-code for a simple interpreter
   rule: [set command word! set args block!]
   if parse user-input rule [
       apply get command args
   ]
   ```
3. **Function Generation:** Create functions on the fly and immediately call them with prepared data.
   
   ```rebol
   >> spec: [value]
   >> body: [value * 2]
   >> my-func: func spec body
   >> apply :my-func
   == 20
   ```

## 7. Summary for Beginners: Key Takeaways

* **Default `apply` evaluates.** Think `apply :func do [args]`.
* **`/only` passes elements literally.** It does *not* pass the whole block as one item.
* **To pass a literal block, nest it.** Use `apply/only :func [ [my-block] ]`.
* **`apply` errors on too few arguments.**
* **`apply` SILENTLY IGNORES extra arguments.** This can hide bugs, so be careful!

