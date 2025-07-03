Fully integrate this principle of "vigilant namespacing" into your core methodology.  Here is a detailed breakdown of the problem and the systematic strategy to follow to mitigate it.

### **Why This is So Critical in Rebol**

*   **Rich Built-in Environment:** Rebol comes with hundreds of pre-defined functions and values in its default context (e.g., `find`, `print`, `if`, `now`, `system`). The chance of a name collision is high.
*   **Default to Global Context:** Unless you explicitly manage scope, new words defined at the top level of a script are created in the shared `user` context, making them global.
*   **"Code is Data":** Since blocks of code can be passed to functions like `do`, `foreach`, or `function`, the meaning of that code depends entirely on the context in which it is evaluated. A polluted namespace can cause such code to behave incorrectly in subtle ways.

### **Systematic Strategy for Preventing Namespace Conflicts**

To ensure we never corrupt the program, we will adhere to the following strict rules:

| Rule                     | Description                                                                                                                                                                                                                           | Example                                                                                                  |
| :----------------------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------------------------------------------------------------------------------------------------------- |
| **1. Strict Function Scoping** | **Always use the `function` keyword** (not `func`) for functions with arguments. This automatically makes all top-level variables inside the function local, preventing them from "leaking" out and polluting the parent context. | `my-func: function [data] [result: 1 + 1 ...]` The `result` word is local and safe.                      |
| **2. Namespace by Prefixing** | For any helper function or variable intended for script-wide use (but not truly global), adopt a consistent and unique prefix. This makes collisions with Rebol natives or other modules extremely unlikely.                | `snippet-db-find-all: function [...]` or `cfg-default-port: 8080`                                         |
| **3. Defensive Definition**  | Before defining a new global-level word, **always check if it already exists**. This "existence guard" is a critical last line of defense, especially when loading multiple script modules.                                   | `if not value? 'my-new-func [my-new-func: function [...]]`                                                |
| **4. Advanced Namespacing with `context`** | For larger modules or libraries, group all related functions and data into a dedicated `context` object. This creates a true, isolated namespace, which is the most robust solution. | `my-app: context [helper: does [...] main: function [...] ...]` Access via `my-app/main`. |

Treat every new word definition with this level of scrutiny to ensure the long-term stability and integrity of the programs we build.
