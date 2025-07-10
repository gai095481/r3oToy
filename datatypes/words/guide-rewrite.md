REBOL 3 Concepts: Expressions & Words
-------------------------------------

### **Updated for Rebol 3**

Expressions are built from values and words. Words are used to represent meaning.
A word can represent an idea or it can represent a specific value.

Rebol words are evaluated somewhat differently than directly expressed values.
When a word is evaluated, its value is referenced, evaluated and returned as a result.

If you type the following word:

```
zero
```

the value 0 is returned.  The word `zero` is predefined to be the number zero.
When the word is accessed, a zero value is found and returned.

When words such as `do` and `print` are accessed, their values are found to be functions, rather than simple values.
In such cases, the function is evaluated and the result of the function is returned.

Word Naming Rules and Restrictions
----------------------------------

Word names are composed of alphabetic characters, digits and any of the following characters:

```
? ! . ' + - * & | = _ ~
```

A word cannot begin with a number, and there are also some restrictions on words that could be interpreted as numbers.  For example, `-1` and `+1` are numbers, not words.

The end of a word is marked by a space, a newline or one of the following characters:

```
[ ] ( ) { } " : ; /
```

Thus, the brackets of a block are not part of a word.
For example, the following block contains the word test :

```
[test]
```

The following characters are illegal in words because words will be misinterpreted or generate an error:

```
@ # $ % ^ ,
```

Words can be of any length, but words cannot extend past the end of a line:

```
this-is-a-very-long-word-used-as-an-example
```

The following lines provide examples of valid words:

```
copy print test
number?  time?  date!
image-files  l'image
++ -- == +-
***** *new-line*
left&right left|right
```

REBOL is generally not lettercase sensitive.
The following words all refer to the same word:

```
blue
Blue
BLUE
```

However, the lettercase of a word is preserved when it is printed.

Words can be reused.  The meaning of a word is dependent on its context, so words can be reused in different contexts.
There are no keywords in REBOL.  The term **native words** can be used to refer to Rebol predefined words (commonly referred to as keywords in other programming languages).
You can reuse any word, even those that are predefined in REBOL.  For instance, you can use the word `if` in your code differently than the REBOL interpreter uses this word.

### Choose Proper Words

Choose the words you use carefully.  Words are used to associate meaning.  Properly chosen words are easier for you and others to understand your scripts.

Rebol Word Usage
----------------

Words are used in two ways: as **symbols** or as **variables**.
Words are used as symbols for colors in the following block.

```
[red green blue]
print second [red green blue]
green
```

These words have no meaning other than their use as names for colors.
All words used within blocks serve as symbols until they are evaluated.

A word is used as a variable when it is evaluated.  In the previous example, the words `print` and `second` are variables that hold native functions which perform the required processing.

A word can be written in four ways to indicate how it is to be treated:

| Notation | Definition | Notes |
| --- | --- | --- |
| word | Get the **natural value** of the word. | If the value is a function, evaluate it, otherwise return it. |
| word: | Set the word to a value. | We do not use = for assignment! |
| :word | Get the value of a word without evaluating it. | Useful for getting the value of a function. |
| 'word | Use the word as a symbol. | We treat it as is and do not evaluate it. |
| /word | Use the word as a refinement symbol. | For functions, objects, file-paths, special fields. |

Setting Rebol Words
-------------------

A word followed by a colon `:` is used to define or set its value:

```
age: 42
lunch-time: 12:32
birthday: 20-March-1990
town: "Dodge City"
test-file: %tmp.r3
```

You can set a word to be any type of value.  In the previous examples, words are defined to be integer, time, date, string and file values.
You can also set words to be complex datatypes including runnable code.  For example, the following words are set to block and function values:

```
towns: ["Ukiah" "Willits" "Mendocino"]
code: [if age > 32 [print town]]
say: funct [item] [print item]
```

Why are Rebol Words Set this Way?

In many programming languages words are set with an equal sign, such as:

```
age = 42
```

In REBOL, words are set with a colon.  The reason for this is important.
It makes the set operation on words into a single lexical value.
The representation for the set operation is **atomic**.

The difference between the two approaches can be seen in this example.

```
print length? [age: 42]
2
print length? [age = 42]
3
```

REBOL is a **reflective** language, it is able to manipulate its own code.
This method of setting values allows you to write code that easily manipulates `set-word!` operations as a single unit.

Remember, the equal sign `=` is used as a comparison operator instead of an assignment operator.

Multiple words can be set at one time by cascading the word definitions.
For example, each of the following words are set to 42:

```
age: number: size: 42
```

Words can also be set with the `set` function:
In this example, the line sets the word `time!` to 10:30.
The word `time!` is written as a literal (using a single quote), so that it will not be evaluated.

```
set 'time 10:30
```

The `set` function can also set multiple words.
Notice that the words do not need to be quoted because they are within a block, which is not evaluated.
The `print` function shows that each word is set to the integer 10.

```
set [number num ten] 10
print [number num ten]
10 10 10
```

Each of the individual values are set to the words when `set` is provided a block of values.

Below, one, two, and three are set to 1, 2, and 3 respectively:

```
set [one two three] [1 2 3]
print three
3
print [one two three]
1 2 3
```

Get Rebol Word Values
---------------------

Put a colon `:` at the front of the word to get the value of a previously defined word.
A word prefixed with a colon obtains the value of the word, but does not evaluate it further when it is a function.
For example, the following line:

```
;; Create a function alias (function pointer):
drucken: :print
```

This defines a new word, `drucken` (German for print), to refer to the function `print`.
This is possible because the get-word `:` returns the function for `print`, but does not evaluate it.

Now, `drucken` performs the same function as `print` :

```
drucken "test"
test
```

The `get` function returns its value, but does not evaluate it when given a literal word:

```
stampa: get 'print

stampa "test"
test
```

The ability to get the value of a word is also important if you want to determine what the value is without evaluating it.
For example, to determine if a word is a native function using the following line:

```
print native? :if
true
```

Here `get` returns the function for `if`.  The `if` function is not evaluated,
but rather it is passed to the `native?` function which determines if it is a native datatype.
The `if` function would be evaluated and an error occurs because it has no arguments without the colon.

Literal Words (lit words)
-------------------------

The ability to deal with a word as a literal is useful.  Both `set` and `get`,
as well as other functions such as `value?`, `unset`, `protect` and `unprotect` expect a literal value.

Literal words can be written in one of two ways:

- by prefixing the word with a single quotation mark, also known as a tick, '`'
- by placing the word in a block.

Use the tick character in front of a word that is evaluated.
In this example, the `word!` variable is set to the literal word `this`, not to the value of `this`.
The `word!` variable just uses the name symbolically.

```
test-word: 'this
```

This example shows that if you print the value of the word, you will see the `this` word:

```
print test-word
this
```

Obtain literal words from an unevaluated block.
In the following example, the `first` function fetches the first word from the block.
This word is then set to the word variable.

```
test-word: first [this and that]
```

Any word can be used as a literal.  It might or might not refer to a value.
For example, in the example below the word `here` has no value.
The word `print` does have a value, but it can still be used as a literal because literal words are not evaluated.

```
test-word: 'here
print test-word
here
test-word: 'print
print test-word
print
```

The next example illustrates the importance of literal values:

```
video: [
  title "Independence Day"
  length 2:25:24
  date   4/July/1996
]
print select video 'title
Independence Day
```

In this example, the word title is searched for in a block.  If the tick was missing from title,
then its natural value would be used.  If title has no natural value, an error is displayed.

Unset Words
-----------

A word that has no value (uninitialized), is type `unset!`.  An error occurs when an unset word is evaluated:

```
outlook
 ** Script Error: outlook has no value.
 ** Where: outlook
```

The error message in the previous example indicates that the word has not been set to a value.

The word is unset.  Do not confuse this with a word that has been set to `none!`, which is a valid value.

A previously defined word can be unset at any time using `unset!` :

```
unset 'word
```

A word's data value is lost when a word is unset and becomes uninitialized.

Use the `value?` function to determine if a word has been set (initialized) .
The `value?` predicate takes a literal word as its argument:

```
if not value? 'word [print "word is not set"]
word is not set
```

Determining whether a word is set can be useful in scripts that call other scripts.
For instance, a script may set a default parameter that was not previously set:

```
if not value? 'test-mode [test-mode: on]
```

Protecting Words
----------------

Prevent a word from being set with the `protect`  function:

```
protect 'word
```

Attempting to redefine a protected word causes an error:

```
word: "here"
** Script Error: Word word is protected, cannot modify.
** Where: word: "here"
```

Unprotect a word using `unprotect` :

```
unprotect 'word
word: "here"
```

The `protect` and `unprotect` functions also accept a block of words:

```
protect [this that other]
```

Important function and system words can be protected using the `protect-system` function.
Protecting function and system words is especially useful for beginners who might accidentally set important words.
