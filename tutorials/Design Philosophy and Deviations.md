### Discussion: Rebol 3's Design Philosophy and Mainstream Programming Language Deviations

Rebol 3's design choices such as its extreme malleability stem from a core philosophy that prioritizes **human readability and direct data representation**. Instead of forcing all concepts into a few generic data types (like strings and arrays) Rebol provides a large number of specific native datatypes (`url!`, `tuple!` for colors `file!` etc.). This design is intentional.

The goal is to allow developers to write code that looks more like a natural description of the problem domain. A URL *is* a `url!`, not just a string that happens to contain "http://". This makes the code more self-documenting and less reliant on external context or comments to understand.

#### The Core Concept: Words and Malleability

The most significant deviation from traditional languages is Rebol's treatment of **"words"** and its lack of "keywords."

1.  **Why No Keywords?**
    In most languages `if` `for` `while` `return` etc. are reserved keywords that are a fixed part of the language's syntax. In Rebol there are no such keywords. Functions like `print` `do` `if` and even `type?` are simply words that in the default context are variables pointing to built-in native functions.

    This design choice is the source of Rebol's extreme malleability. Because `print` is just a variable you are free to redefine it:
    `print: "Hello"`
    After this the word `print` no longer refers to the printing function; it refers to the string "Hello".

2.  **Why Is This Malleability Useful? The Concept of Dialecting.**
    While redefining core functions can be dangerous it is also immensely powerful. This malleability is the foundation of one of Rebol's most advanced features: **Dialecting** (creating Domain-Specific Languages or DSLs).

    Because words are not fixed you can create a "dialect"—a small sub-language within Rebol—where words have a specific meaning only within that context. For example you could create a graphics dialect where the code looks like this:
    `draw [pen red circle 100 100 50]`
    Here `draw` `pen` `red` and `circle` are not global functions. They are words that are given a special meaning only inside the `draw` block. This is possible because Rebol treats the block `[pen red ...]` as pure data first. The `draw` function then processes that data according to its own rules. This code-as-data principle where a block is just a sequence of words until it is explicitly evaluated is fundamental to Rebol's design.

#### Deviations in Syntax and Their Rationale

1.  **Assignment with a Colon (`:`): The `set-word!`**
    The choice of `word:` for assignment instead of `=` is not arbitrary. In Rebol `word:` is a distinct datatype: `set-word!`. This makes assignment a regular part of the language's data structure not a special operator that lives outside the system. When the interpreter sees a `set-word!` it knows its one job is to assign the very next value to that word. This consistent data-oriented approach simplifies the interpreter's design.

2.  **Refinements with a Forward Slash (`/`)**
    Using `/` for refinements (e.g. `copy/part`) and paths (e.g. `system/options/home`) is a deliberate choice for consistency. It leverages the familiar mental model of file paths. This allows for a single powerful syntax to both modify a function's behavior and access nested data in objects. It's considered more powerful than a simple dot-selector (`.`) because it can be combined with other operations in complex expressions like:
    `load/header/only system/options/home/database.r`
    This attempts to load only the header of a file located at a path constructed from a nested object structure—a very dense and expressive statement.

3.  **The Importance of Spacing**
    The strict requirement for spaces between all words and values is a direct consequence of this design. Since `n/2` is a path (access element `2` from variable `n`) and `n / 2` is a mathematical operation (divide `n` by `2`) spacing is syntactically critical to remove ambiguity for the interpreter.

#### Series and Objects: Data-Centric Foundations

-   **Series:** The concept of a "series" (`string!` `block!` `path!` etc.) as an "ordered sequence of values" is central. By having a common abstraction for sequences Rebol can provide a consistent set of functions (`copy` `insert` `append` etc.) that work across many different data types.
-   **Objects and Copying:** Rebol's specific and nuanced rules for copying objects (`copy` is shallow `copy/deep` is deep `make` is mostly deep) are a pragmatic response to real-world programming needs. Sometimes you need a fully independent copy and sometimes you want to share data for efficiency. The language provides explicit tools for the developer to control this behavior rather than having one-size-fits-all copying rules.

In summary Rebol's design choices deviate from the mainstream because it is built on a different set of first principles: **everything is data (including code) words are flexible symbols and the language should provide specific native types for real-world concepts.** This results in a highly malleable expressive and data-oriented language.
