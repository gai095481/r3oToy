# Rebol 3 Variable Assignment and Datatypes

This document summarizes the fundamental concepts of variable assignment datatypes and the nature of "words" in the Rebol 3 programming language based on provided source materials. Rebol is a lightweight language designed for cross-platform data exchange with a highly symbolic and human-readable approach.

## I. Words: The Foundation of Rebol

The single most important concept in Rebol is the **word**. Words are the key to Rebol's expressiveness and can be used to represent both code and data. A word's meaning is determined by four factors:

1.  **Symbol:** The name itself.
2.  **Notation:** Special characters (`:`, `'`, `/`) that modify its behavior.
3.  **Context:** Its association with a value (e.g. global or local scope).
4.  **Usage:** How it is used in code (e.g. as a function or as a literal symbol in a block).

## II. Variable Assignment and Special Word Notations

Rebol uses a unique notation system to define how words are treated by the interpreter.

### 2.1. Assignment with `word:` (The `set-word!`)

Unlike most languages that use `=`, Rebol uses a **colon (`:`)** to perform assignment. A word immediately followed by a colon is a distinct datatype called a **`set-word!`**.

-   **Syntax:** `variable: value`
-   **Mechanism:** When the interpreter sees a `set-word!` like `size:`, it knows its job is to assign the very next value to the word `size`.
-   **Crucial Rule:** A space is mandatory between the colon and the value. `size:12` is a syntax error; `size: 12` is correct.

### 2.2. Other Key Word Notations

| Notation | Name | Purpose | Example |
| :--- | :--- | :--- | :--- |
| `word` | **get-word** | "Get the natural value of the word." If it's a function it's evaluated; otherwise its value is returned. | `print "hello"` |
| `:word` | **lit-word** | "Get the value of a word without evaluating it." Returns the function value itself not its result. Crucial for passing functions as arguments. | `type? :print` |
| `'word` | **lit-word** | "Use the word as a literal symbol." It is not evaluated. This is essential for creating dialects (DSLs). | `draw ['circle 100]` |
| `/word` | **refinement** | "Specifies a variation, option, or clarification in meaning." Used for functions and paths. | `copy/part data 5` |

### 2.3. Variables and Context (Scope)

A variable is simply a "word with a value associated within a specific context." This context which is similar to "scope" in other languages can be global a function or an object. Rebol variable names are **case-insensitive**.

## III. A Rich Set of Native Datatypes

Rebol provides a large number of built-in datatypes allowing code to be more natural and self-documenting. Every value in Rebol has a specific datatype which defines its possible values and the operations that can be performed on it. By convention datatype names end with an exclamation mark (`!`).

### 3.1. The `type?` Function

The built-in `type?` function is used to inspect the datatype of any variable or value.

### 3.2. Key Datatypes

| Datatype | Description | Example |
| :--- | :--- | :--- |
| `integer!` | A whole number. | `num: 5` |
| `decimal!` | A floating-point number. | `pi: 3.14159` |
| `string!` | A series of characters delimited by double quotes. | `str: "hello"` |
| `tuple!` | A native datatype often used for RGB colors or version numbers. | `color: 255.0.0` |
| `url!` | A native datatype for web addresses. | `site: http://www.rebol.com` |
| `block!` | A fundamental series type holding code or data. | `b: [pi: 3.14159]` |
| `path!` | A series used to access nested values. | `system/options/home` |

## IV. The Malleable Nature of Rebol

A defining characteristic of Rebol is its extreme malleability.

### 4.1. No Reserved Keywords

There are **no keywords** in Rebol. Core functions like `print` `if` `do` and `type?` are not syntactically protected. They are simply variables in the default context that point to native functions. This means any of them can be redefined by the user:
> *"You can redefine `print`, you can redefine `type?`, everything is malleable."*

This malleability is what enables advanced features like **dialecting** where users can create their own small sub-languages for specific problem domains.

### 4.2. Code is Data: The `block!` and Series

The concept of a **series**—an ordered sequence of values—is fundamental. `string!`, `block!`, and `path!` are all types of series.

-   **Blocks as Unevaluated Data:** When a block is created `[...]` its contents are not executed. It is treated as a piece of data containing a sequence of words.
-   **Execution:** The `do` function is used to evaluate the contents of a block as code. This allows for powerful metaprogramming where code can be constructed as data in a block and then executed dynamically.

## V. Accessing Nested Data with Paths

Rebol uses a `path!` (`/`) to access nested data within objects and blocks. This syntax was chosen for its similarity to file paths and its power in complex expressions.

-   **Object Access:** `system/options/home` accesses the `home` value inside the `options` object inside the `system` object.
-   **Block Access:** `my-block/1` accesses the first element of `my-block`.
-   **Spacing is Critical:** Because `/` is used for paths `n/2` (a path) is different from `n / 2` (a division operation). All words and values must be separated by spaces.
