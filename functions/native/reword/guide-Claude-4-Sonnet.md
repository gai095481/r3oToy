# The Complete User's Guide to Rebol 3 `reword` Function


## Overview

The `reword` function is Rebol's powerful string templating system that substitutes placeholders in templates with actual values.
Think of it as a sophisticated "find and replace" that can work with various data sources and output formats.

**Primary Purpose:** Transform template strings containing `$placeholder` markers into final strings with actual values substituted.

**Key Strengths:**

* Works with strings, binary data, maps, objects, and blocks
* Supports custom escape characters and delimiters
* Can prevent or allow expression evaluation
* Handles complex data types including functions
* Memory-efficient with optional buffer insertion

---

## Basic Usage

### Simplest Form

```rebol
template: "Hello $name, welcome to $place!"
values: [name "Alice" place "Rebol"]
result: reword template values
;; Result: "Hello Alice, welcome to Rebol!"
```

### With Numeric Values

```rebol
template: "The answer is $number and the year is $year"
values: [number 42 year 2025]
result: reword template values
;; Result: "The answer is 42 and the year is 2025"
```

---

## Function Signature

```rebol
reword: function [
    template    [string! binary!]     ; Template with $placeholders
    values      [block! map! object!] ; Data source for substitutions
    /case                             ; Case-sensitive matching
    /only                             ; Don't evaluate blocks
    /escape     [char! string! block!] ; Custom escape character(s)
    /into       [string! binary!]     ; Insert into existing buffer
]
```

**Returns:**`string!` or `binary!` (matches template type) or position after insertion (with `/into`)

---

## Core Concepts

### 1. Placeholder Syntax

* **Default:**`$word` format (dollar sign + word)
* **Case-insensitive by default:**`$name` matches both `name` and `Name` in values
* **Word boundaries:**`$name` in `"$name-suffix"` only matches the word part

### 2. Value Lookup Process

1. Extract word from placeholder (remove `$`)
2. Look up word in values source (block, map, or object)
3. Process the found value according to refinements
4. Insert the result into the template

### 3. Value Processing Rules

* **Blocks:** Evaluated by default (like `do`), use `/only` to prevent
* **Functions:** Called automatically, result is inserted
* **Other types:** Converted to string using `form`

---

## Refinements Guide

### `/case` - Case-Sensitive Matching

**Default behavior (case-insensitive):**

```rebol
template: "Hello $name and $Name"
values: [name "alice" Name "ALICE"]
result: reword template values
;; Result: "Hello alice and ALICE"
```

**With `/case` (case-sensitive):**

```rebol
result: reword/case template values
;; Result: "Hello alice and ALICE" (same in this case)
```

**Practical use:** When you have similarly named variables that differ only in case.

### `/only` - Prevent Block Evaluation

**⚠️ CRITICAL NUANCE:**`/only` does NOT preserve block brackets `[]` in output!

**Default behavior (blocks are evaluated):**

```rebol
template: "Result: $calculation"
values: [calculation [1 + 2 + 3]]
result: reword template values
;; Result: "Result: 6"
```

**With `/only` (blocks are NOT evaluated):**

```rebol
result: reword/only template values
;; Result: "Result: 1+2+3" (no brackets, no spaces)
```

**Common Mistake:**

```rebol
;; WRONG EXPECTATION:
values: [items [a b c]]
result: reword/only "List: $items" values
;; People expect: "List: [a b c]"
;; Actually get: "List: abc" (and possible errors if a, b, c are unbound)
```

**Solution for preserving block appearance:**

```rebol
;; Convert block to string manually:
values: [items mold [a b c]]  ; "items" now contains "[a b c]"
result: reword "List: $items" values
;; Result: "List: [a b c]"
```

### `/escape` - Custom Escape Characters

**Single character:**

```rebol
template: "Hello #name, welcome to #place!"
values: [name "Carol" place "Testing"]
result: reword/escape template values #"#"
;; Result: "Hello Carol, welcome to Testing!"
```

**String escape (multi-character):**

```rebol
template: "Hello %%name%%, welcome to %%place%%!"
result: reword/escape template values "%%"
;; Result: "Hello Carol%%, welcome to Testing%%!"
;; NOTE: Closing delimiter not fully consumed!
```

**Begin/End delimiters:**

```rebol
template: "Hello <name>, welcome to <place>!"
escape-delimiters: ["<" ">"]
result: reword/escape template values escape-delimiters
;; Result: "Hello Carol, welcome to Testing!"
```

### `/into` - Buffer Insertion

**Memory-efficient for large outputs:**

```rebol
template: "Hello $name!"
values: [name "David"]
buffer: make string! 1000  ; Pre-allocated buffer
position: reword/into template values buffer
;; buffer now contains: "Hello David!"
;; position points to the end of the inserted text
```

---

## Data Source Types

### Block Format

```rebol
;; Standard key-value pairs
values: [name "Alice" age 30 city "New York"]

;; Mixed word types work:
values: [name: "Alice" 'age 30 city "New York"]  ; set-word! and lit-word!
```

### Map Format

```rebol
values: make map! [
    name "Alice"
    age 30
    city "New York"
]
```

### Object Format

```rebol
values: make object! [
    name: "Alice"
    age: 30
    city: "New York"
]
```

---

## Common Pitfalls & Solutions

### 1. The "Block Content Error" Problem

**Problem:**

```rebol
;; This will fail if a, b, c are unbound words
values: [items [a b c]]
result: reword/only "Items: $items" values
;; Error: "a has no value"
```

**Solutions:**

```rebol
;; Solution 1: Use bound words or values
values: [items [1 2 3]]
result: reword/only "Items: $items" values
;; Result: "Items: 123"

;; Solution 2: Convert to string first
values: [items mold [a b c]]
result: reword "Items: $items" values
;; Result: "Items: [a b c]"

;; Solution 3: Use quoted words
values: [items ['a 'b 'c]]
result: reword/only "Items: $items" values
;; Result: "Items: abc"
```

### 2. Missing Substitution Values

**Problem:**

```rebol
template: "Hello $name, missing $unknown"
values: [name "Bob"]
result: reword template values
;; Result: "Hello Bob, missing $unknown"  ; $unknown remains literal
```

**Solution - Defensive Programming:**

```rebol
ensure-value: function [values-block key default-value] [
    either find values-block key [
        values-block
    ][
        append copy values-block reduce [key default-value]
    ]
]

safe-values: ensure-value values 'unknown "[NOT SET]"
result: reword template safe-values
;; Result: "Hello Bob, missing [NOT SET]"
```

### 3. Function Value Handling

**Problem:**

```rebol
;; Functions are called, but timing matters
values: [time now/time]  ; Evaluated once at block creation
result: reword "Time: $time" values
;; Time is fixed at block creation time
```

**Solution:**

```rebol
;; Use function reference for dynamic values
get-time: does [now/time]
values: reduce ['time :get-time]  ; Note the colon prefix
result: reword "Time: $time" values
;; Time is evaluated each time reword runs
```

### 4. Special Characters in Templates

**Problem:**

```rebol
template: "Path: $path"
values: [path "C:\Users\John"]
result: reword template values
;; Backslashes might cause issues depending on context
```

**Solution:**

```rebol
;; Use raw strings or escape properly
template: {Path: $path}  ; Curly braces preserve literal content
values: [path {C:\Users\John}]
result: reword template values
;; Result: "Path: C:\Users\John"
```

---

## Advanced Techniques

### 1. Conditional Substitutions

```rebol
;; Using functions for conditional logic
make-greeting: function [user-data] [
    either user-data/vip [
        "Welcome, valued customer"
    ][
        "Welcome"
    ]
]

user: make object! [name: "Alice" vip: true]
values: reduce ['name user/name 'greeting make-greeting user]
result: reword "$greeting $name!" values
;; Result: "Welcome, valued customer Alice!"
```

### 2. Nested Templates

```rebol
;; Multi-pass templating
inner-template: "Hello $name"
outer-template: "Message: '$inner'"

values1: [name "Alice"]
inner-result: reword inner-template values1

values2: [inner inner-result]
final-result: reword outer-template values2
;; Result: "Message: 'Hello Alice'"
```

### 3. Binary Template Processing

```rebol
;; Working with binary data
binary-template: to binary! "Content-Type: $type^/Length: $length"
values: [type "application/json" length 1024]
result: reword binary-template values
;; Result is binary!: #{436F6E74656E742D547970653A206170706C69636174696F6E2F6A736F6E0A4C656E6774683A2031303234}
```

### 4. Custom Escape Pattern Builder

```rebol
build-template: function [
    content [string!]
    escape-style [word!]  ; 'dollar | 'hash | 'percent | 'angle
] [
    escape-char: case [
        escape-style = 'dollar  [#"$"]
        escape-style = 'hash    [#"#"]
        escape-style = 'percent ["%%"]
        escape-style = 'angle   [["<" ">"]]
        true [#"$"]  ; Default
    ]
    return reduce [content escape-char]
]

template-info: build-template "Hello #name!" 'hash
result: reword/escape template-info/1 [name "Alice"] template-info/2
;; Result: "Hello Alice!"
```

---

## Performance Tips

### 1. Pre-allocate Buffers for Large Output

```rebol
;; For large templates, pre-allocate buffer
large-template: "..." ; Assume this is very large
buffer: make string! 10000  ; Pre-allocate based on expected size
result-pos: reword/into large-template values buffer
;; More memory-efficient than automatic string growth
```

### 2. Reuse Value Blocks

```rebol
;; Reuse the same value block for multiple templates
common-values: [name "Alice" date now/date company "ACME Corp"]

header: reword "From: $name at $company" common-values
footer: reword "Generated: $date by $name" common-values
;; More efficient than recreating values each time
```

### 3. Optimize Function Calls

```rebol
;; Cache expensive function results
expensive-calc: does [
    ;; Assume this is computationally expensive
    result: 0
    loop 1000 [result: result + random 100]
    result
]

;; BAD: Function called every time
values: reduce ['result :expensive-calc]

;; GOOD: Cache the result
cached-result: expensive-calc
values: [result cached-result]
```

---

## Complete Examples

### Example 1: Email Template System

```rebol
;; Professional email template with error handling
create-email: function [
    template [string!]
    user-data [object!]
] [
    ;; Ensure required fields exist
    required-fields: [name email subject]
    foreach field required-fields [
        if not in user-data field [
            return make error! rejoin ["Missing required field: " field]
        ]
    ]
    
    ;; Build values with defaults
    values: reduce [
        'name user-data/name
        'email user-data/email
        'subject user-data/subject
        'date now/date
        'company either in user-data 'company [user-data/company] ["[Company]"]
    ]
    
    ;; Process template
    set/any 'result try [reword template values]
    either error? result [
        result  ; Return the error
    ][
        result  ; Return the processed template
    ]
]

;; Usage
email-template: {
Subject: $subject

Dear $name,

Thank you for your interest in $company.

Best regards,
The $company Team

---
Generated on $date
Contact: $email
}

user: make object! [
    name: "Alice Johnson"
    email: "alice@example.com"
    subject: "Welcome to Our Service"
    company: "TechCorp"
]

final-email: create-email email-template user
print final-email
```

### Example 2: Configuration File Generator

```rebol
;; Generate configuration files from templates
generate-config: function [
    template-file [file!]
    config-data [block!]
    output-file [file!]
    /custom-escape [char! string! block!]
] [
    ;; Read template
    template: read template-file
    
    ;; Process with optional custom escape
    result: either custom-escape [
        reword/escape template config-data custom-escape
    ][
        reword template config-data
    ]
    
    ;; Write output
    write output-file result
    
    ;; Return success info
    reduce ['success true 'bytes-written length? result]
]

;; Usage
config-values: [
    server-name "production-01"
    port 8080
    database-url "postgresql://localhost:5432/mydb"
    max-connections 100
    debug-mode false
]

;; Assume template.conf contains:
;; server.name=$server-name
;; server.port=$port
;; database.url=$database-url
;; connections.max=$max-connections
;; debug.enabled=$debug-mode

result: generate-config %template.conf config-values %production.conf
print ["Generated config file:" result/bytes-written "bytes"]
```

### Example 3: Web Template System with Conditionals

```rebol
;; Advanced web template with conditional content
render-page: function [
    template [string!]
    page-data [object!]
] [
    ;; Helper function for conditional content
    show-if: function [condition content] [
        either condition [content] [""]
    ]
    
    ;; Helper function for lists
    render-list: function [items format-string] [
        result: make string! 200
        foreach item items [
            item-html: reword format-string reduce ['item item]
            append result item-html
        ]
        result
    ]
    
    ;; Build comprehensive values
    values: reduce [
        'title page-data/title
        'content page-data/content
        'user-name either in page-data 'user [page-data/user/name] ["Guest"]
        'is-logged-in either in page-data 'user [true] [false]
        'login-link show-if (not in page-data 'user) {<a href="/login">Login</a>}
        'user-menu show-if (in page-data 'user) {<div class="user-menu">Welcome, $user-name!</div>}
        'nav-items either in page-data 'navigation [
            render-list page-data/navigation {<li><a href="$item/url">$item/text</a></li>}
        ] [""]
    ]
    
    ;; Process template
    reword template values
]

;; Usage
page-template: {
<!DOCTYPE html>
<html>
<head>
    <title>$title</title>
</head>
<body>
    <header>
        $user-menu
        $login-link
    </header>
    <nav>
        <ul>
            $nav-items
        </ul>
    </nav>
    <main>
        <h1>$title</h1>
        $content
    </main>
</body>
</html>
}

page-info: make object! [
    title: "Welcome to Our Site"
    content: "<p>This is the main content area.</p>"
    user: make object! [name: "Alice"]
    navigation: [
        make object! [url: "/home" text: "Home"]
        make object! [url: "/about" text: "About"]
        make object! [url: "/contact" text: "Contact"]
    ]
]

final-html: render-page page-template page-info
write %output.html final-html
```

---

## Summary

The `reword` function is a powerful and flexible templating system in Rebol 3. Key points to remember:

1. **Default behavior is intuitive** for simple substitutions
2. **The `/only` refinement has unique behavior** - it doesn't preserve block brackets
3. **Functions are called automatically** - use this for dynamic content
4. **Error handling is important** - always validate your templates and data
5. **Performance matters** - pre-allocate buffers for large outputs
6. **Multiple data source types** provide flexibility in how you structure your data

With these concepts and examples, you should be able to effectively use `reword` for everything from simple string substitution to complex templating systems.
