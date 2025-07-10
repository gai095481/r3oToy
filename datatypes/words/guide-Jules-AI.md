## REBOL 3 Oldes Branch Concepts: Expressions & Words

Expressions in Rebol are built from values and words. Words are fundamental for representing meaning, ideas or specific values within the language.

## Word Evaluation

Rebol words are evaluated based on the context in which they appear and the value they hold.

* If a word is bound to a simple value (e.g., `zero: 0`), evaluating the word `zero` returns `0`.
* If a word is bound to a function (e.g., `p: :print`), simply stating the word `p` will return the function value itself.  To execute the function, it must be used in an applicative context, such as `p "hello"` or `do [p "hello"]`.  The Rebol interpreter reads ahead to satisfy function arguments.
  
  ```rebol
  zero: 0
  probe zero ;-- Output: 0
  
  my-print: :print
  probe my-print ;-- Output: make native! [[value]]
  my-print "Hello R3!" ;-- Output: Hello R3!
  ```

### Word Naming Rules and Restrictions

Word names are composed of alphabetic characters (a-z, A-Z), digits (0-9), and any of the following special characters:

```
? ! . ' + - \* & | = \_ \~
```
**Key Rules:**

* A word **cannot** begin with a digit.
* Words that can be interpreted as numbers are treated as such (e.g., `-1`, `+1.2` are numbers, not words).
* The end of a word is typically marked by a space, a newline or one of the following delimiter characters:
  
  ```
  [ ] ( ) { } " : ; /
  ```
  
  Thus, delimiters like brackets `[]` are not part of the word itself (e.g., in `[test]`, `test` is the word).
* The following characters are generally not used directly within word spellings as they have special meaning or can cause errors if not handled by the scanner as part of other datatypes:
  
  ```
  @ # $ % ^ ,
  ```
  
  However, `#` is an `issue!` prefix, `$` is a `char!` prefix, `%` is a `file!` prefix.
* Words can be of any practical length and can span lines if properly part of a multi-line string or block being loaded, but a single word token itself is typically on one line.
  
  ```rebol
  this-is-a-very-long-word-used-as-an-example
  ```

**Valid Word Examples:**

```rebol
copy print test
number? valid? to-date
image-files l'image ; (apostrophe is allowed)
++ -- == +- ; (often used as operator-like functions)
***** *new-line* ; (asterisks are allowed)
left&right left|right ; (ampersand and bar are allowed)
```

**Letter Case Sensitivity:**

Rebol is generally **not** lettercase sensitive for word ​*evaluation*​. The words `blue`, `Blue`, and `BLUE` all refer to the same underlying variable or symbol if bound.  However, Rebol **preserves** the original lettercase of a word when it is stored or printed.

```
myWord: 10
print MyWord ;-- Output: 10 (evaluates myWord)
probe 'myWord ;-- Output: myWord (shows original casing)
probe 'MyWord ;-- Output: MyWord
```

**Word Reusability (No Keywords):**

Rebol does not have reserved keywords in the traditional sense. All words, including system-defined "native" functions (like `if`, `print`, `loop`), can theoretically be redefined by you in a specific context. However, redefining core system words in the global user context is generally discouraged as it can lead to confusion. The meaning of a word is resolved based on its current context.

#### Choose Proper Words

Choose words carefully to convey clear meaning. Properly chosen words make scripts easier to understand and maintain for everyone.

### Word Usage: Symbols vs. Variables

Words function in two primary ways:

1. **As Symbols (Literal Words):** When a word is used literally, it represents itself; its own spelling.  This is common in blocks that are not yet evaluated or when explicitly marked as a literal.
   
   ```
   colors: [red green blue] ;; red, green, blue are currently symbols
   print second colors      ;;-- Output: green (the symbol 'green)
   ```
   
   In the `colors` block, `red`, `green`, and `blue` are `word!` types that act as symbols.
2. **As Variables (Evaluated Words):** When a word is evaluated, it acts as a variable.  The Rebol interpreter refernces the value bound to the word in the current context.
   
   ```
   print-value: :print  ;; print-value is a variable holding the print function
   color-name: 'red    ;; color-name is a variable holding the literal word 'red
   ```

### Word Notations and Datatypes

Words can be written and treated in several ways, corresponding to different `word!`-family datatypes:

| Notation    | R3 Datatype       | Definition                                                                     | Notes                                                                                                                                                |
| :------------ | :------------------ | :------------------------------------------------------------------------------- | :----------------------------------------------------------------------------------------------------------------------------------------------------- |
| `word`  | `word!`       | Represents the word itself. When evaluated, its bound value is retrieved.      | If bound to a function, evaluation (calling it) requires an applicative context (e.g., `word arg`) or `do`. Otherwise, returns the function. |
| `word:` | `set-word!`   | Sets the word (variable) to a subsequent value.                                | This is Rebol's primary assignment operator. `=` is for comparison.                                                                              |
| `:word` | `get-word!`   | Gets the value of the word without further evaluation if it's a function.      | Returns the raw value bound to the word. If `word` holds a function, `:word` returns the function itself.                                    |
| `'word` | `lit-word!`   | Treats the word as a literal symbol; its spelling is its value.                | The word is not evaluated to look up its bound value. `help lit-word!`                                                                           |
| `/word` | `refinement!` | Used as a refinement for functions, or as a symbolic segment in paths/objects. | `help refinement!`                                                                                                                               |
| `#word` | `issue!`      | An identifying marker or symbol, often used for unique keys or tags.           | `help issue!`                                                                                                                                    |

### Setting Word Values (Variables)

A `set-word!` (a word followed immediately by a colon `:`) is used to assign a value to a variable:

```
age: 42
lunch-time: 12:30:00 ;; Assigning a time! value
birthday: 20-March-1990
town: "Dodge City"
image-file: %photo.jpg
```

Variables can hold any Rebol datatype, including blocks (runnable code,) or functions:

```
towns: ["Ukiah" "Willits" "Mendocino"]
code-block: [if age > 30 [print "Over 30"]]
say: func [item] [print item] ; In R3, 'func' is often preferred over 'funct'
```

**Why `:` for Assignment?**

Rebol uses `word: value` for assignment to make the set operation a single, atomic `set-word!` datatype.  This is powerful for Rebol's reflective capabilities (code that manipulates code).

```
probe [age: 42]        ;;-- Output: [age: 42] (length is 2: set-word! and value)
probe length? [age: 42] ;;-- Output: 2

;; Compare with a hypothetical '=' for assignment (not Rebol's way for setting):
;; probe length? [age = 42] ;; Would be 3: word, op, value
```

Remember, `=` and `==` are used for equality comparison, not assignment.

**Cascading Assignments:** Multiple words can be set to the same value in a single expression:

```
age: number: size: 42
print ["Age:" age "Number:" number "Size:" size]
;; Output: Age: 42 Number: 42 Size: 42
```

**Using the `set` Native:**

The `set` native provides programmatic control over assignment:

```
;; Set a single word (as lit-word!) to a value
set 'time-val 10:30:00
print time-val ;-- Output: 10:30:00

;; Set multiple words in a block to a single value
set [val1 val2 val3] 100
print [val1 val2 val3] ;-- Output: [100 100 100]

;; Set multiple words in a block to corresponding values from another block
set [one two three] [1 2 3]
print three ;-- Output: 3
print [one two three] ;-- Output: [1 2 3]
```

(Refer to `help set` for more details on its refinements such as `/any`, `/only`, `/some`.)

### Getting Word Values

**Using `get-word!` (`:word`)**

Prefixing a word with a colon (`:`) creates a `get-word!`.  This retrieves the value bound to the word. If that value is a function, the `get-word!` returns the function itself, without evaluating / calling it.

```
;; Create a function alias (drucken means "print" in German):
drucken: :print  ;; :print gets the actual print function value

drucken "Test with drucken" ;; Now 'drucken' can be used like 'print'
;; Output: Test with drucken

type? :print ;;-- Output: native! (or function! for user-defined ones)
```

**Using the Native `get` Function:**

The `get` native can also retrieve the value of a word.

* `get 'word-name` (with a `lit-word!`) behaves like `:word-name`, returning the direct value (e.g., the function itself if it's a function).
* `get actual-word-name` (with a `word!`) will first evaluate `actual-word-name`, and then `get` operates on the result.

```
stampa: get 'print ;; 'print is a lit-word!, get returns the print function
stampa "Test with stampa"
;; Output: Test with stampa

;; Example for checking function type:
print native? :if       ;;-- Output: true (using get-word!)
print native? get 'if  ;;-- Output: true (using get with lit-word!)

;; When 'if' is not prefixed with : or quoted for 'get', it tries to evaluate 'if':
;; print native? if ;-- Error: if is missing its arguments
```

(Refer to `help get` for refinements like `/any`.)

### Literal Words (`lit-word!`)

A `lit-word!` (literal word) is a word that represents its own spelling, rather than the value it might be bound to.  It's the symbol itself.

**Creating Literal Words:**

1. **Prefix with a tick (apostrophe):** `'my-word`
2. **Naturally within an unevaluated block:** In `data: [name age city]`, `name`, `age`, and `city` are `lit-word!`s until the block `data` is evaluated by `do`, `reduce`, etc.

```
test-word: 'this   ;; test-word now holds the literal word 'this'
print test-word    ;;-- Output: this
probe test-word    ;;-- Output: 'this

block-of-words: [this and that]
test-word-from-block: first block-of-words
print test-word-from-block ;;-- Output: this
probe test-word-from-block ;;-- Output: 'this
```

Literal words don't need to be bound to any value:

```
undefined-word-as-literal: 'here
print undefined-word-as-literal ;;-- Output: here

known-word-as-literal: 'print
print known-word-as-literal     ;;-- Output: print
```

**Usage Example (e.g., with `select`):** `select` is often used with `lit-word!`s to find keys in blocks or objects.

```
video-info: [
    title "Independence Day"
    length 2:25:24
    release-date 4-Jul-1996 ; R3 date format
]
print select video-info 'title
;; Output: Independence Day
```

If `'title` was just `title` (and `title` was unbound), an error would occur.  If `title` was bound (e.g., `title: "another movie"`), `select` would use that *value* for searching, which is usually not the intent when using it as a key.

### Unset Words and the `unset!` Datatype

A word that has not been assigned a value in the current context is ​**unbound**​.  Attempting to evaluate an unbound word results in an error:

```
probe new-unbound-word
;; ** Script Error: new-unbound-word has no value
;; ** Where: probe new-unbound-word
```

This is different from a word being bound to `none` (which is a valid value representing "no value") or the `unset!` datatype.

**`unset!` Datatype:** Rebol 3 has an `unset!` datatype.  A word can be explicitly bound to this `unset!` value.  This is often used to indicate that a variable is intentionally without a usable value. The global word `_` (underscore) is commonly pre-bound to an `unset!` value.

```
my-variable: _  ;; Assigning the unset! value
probe my-variable ;;-- Output: _ (or unset if _ is not molded specially)
print unset? my-variable ;;-- Output: true

none-variable: none
probe none-variable ;;-- Output: none
print none? none-variable ;;-- Output: true
print unset? none-variable ;;-- Output: false
```

**Making a Word Unbound (Clearing its value):** R2 had an `unset 'word-name` function to make a word unbound. R3 handles this differently:

* There isn't a direct global `unset function-name` for this purpose.
* To make a word in the current (e.g. user), context unbound, you can use `clear 'word-name`.   The `clear` function removes the binding.
  ```
  foo: 10
  print bound? 'foo  ;;-- Output: true
  clear 'foo
  print bound? 'foo  ;;-- Output: false
  ; probe foo ;;-- Error: foo has no value
  ```
* Alternatively, a word simply not being defined in a context makes it unbound in that context.

**Setting a Word to the `unset!` value:** Use `set/any` or direct assignment to `_`:

```
set/any 'my-var _
print unset? my-var ;;-- true
```

**Determine if a Word is Bound:** Use `bound?` (or its common alias `exists?`) with a `lit-word!`:

```
data-val: 123
print bound? 'data-val  ;;-- Output: true
print bound? 'not-set-yet ;;-- Output: false

if not bound? 'config-option [
    config-option: "default"
    print "config-option was not bound, set to default."
]
;; Output: config-option was not bound, set to default.
```

Determine if a word is bound AND its value is not `none` or `unset`:

```
if all [bound? 'maybe-val not none? get 'maybe-val not unset? get 'maybe-val] [
    print ["Value is present:", get 'maybe-val]
]
```

### Protecting Words and Series (immutable)

Rebol 3 Oldes provides `protect` and `unprotect` natives to control modification of series and variables.

**`protect`:** Prevents a series (like a block or string), or a variable from being modified.

```
my-block: [1 2 3]
protect my-block
;; attempt: append my-block 4 ;;-- This causes an error.

data: "Confidential"
protect 'data ;; Protects the variable 'data' (its binding to the value)
;; data: "New" ;;-- This would cause an error if 'data' variable itself is protected.
              ;; Note: 'protect' behavior on words can be nuanced.
              ;; 'protect :data' or 'protect value-of data' might be needed
              ;; depending on if you want to protect the series data points to,
              ;; or the variable 'data' from being reassigned.
              ;; The R2 example 'protect 'word' is closer to 'protect/words ['word]
              ;; or protecting the word binding if possible.

;; To protect the word 'config' from being reassigned:
config: [setting: true]
protect 'config ;; This aims to protect the binding of 'config'.
                ;; (Behavior may vary slightly based on R3 version details)
;; config: none  ; Should error if 'config' binding is protected.

;; Typically, to protect specific words from reassignment:
protect/words ['important-var1 'important-var2]
important-var1: 10
;; important-var1: 20 ;;-- Error: important-var1 is protected.
```

See `help protect` for refinements like `/deep`, `/words`, `/values`, `/hide`, `/lock`.

**`unprotect`:** Remove protection, allowing modification again (mutable).

```
important-var1: 100
protect/words ['important-var1]
;; important-var1: 200 ;-- Error

unprotect/words ['important-var1]
important-var1: 200 ;;-- OK now
print important-var1 ;;-- Output: 200
```

See `help unprotect` for refinements like `/deep`, `/words`, `/values`.

**`protect-system-object`:** This function is used to protect the main `system` object and some of its sub-objects/contexts, preventing accidental modification of core system functionalities.

```
;; Use with caution, typically unneeded in your scripts unless for specific system hardening
protect-system-object
```

The `protect-system-object` function in R3 Oldes for targeting system internals. General variable protection uses `protect`.
