# Unofficial `as` Function User's Guide

*Based on robust diagnostic testing and real-world behavior analysis*

## Overview

The `as` function performs **type coercion** within compatible type families without copying data when possible.
It's designed for efficient type conversions between related datatypes.

> as *type spec*

- **type**: Target datatype or example value.
- **spec**: Source series to convert.

## Compatible Type Families

### String Family

string! ↔ file! ↔ url! ↔ email! ↔ tag!


### Block Family

block! ↔ paren! ↔ path! (with 2-3 elements)


## Core Behaviors

### ✅ Identity Operations (Same Type)

When converting to the same type, `AS` returns the **exact same reference**:

```rebol
text: "Hello World"
same-text: as string! text
print same? text same-text  ;; true - same reference.
```

### ✅ Within-Family Conversions

`as` creates a new series of the target type:

```rebol
text: "example"
file-version: as file! text
print same? text file-version     ;; false - different references.
print equal? text file-version    ;; true - same content.
print file? file-version          ;; true - correct type.
```

### ❌ Cross-Family Rejections

`as` rejects incompatible conversions:

```rebol
;; This FAILS - cannot convert between families:
try [as block! "text"] catch [print "Error: incompatible types"]
try [as string! [block]] catch [print "Error: incompatible types"]
```

## Memory Behavior Patterns

### Pattern 1: Identity Operations Share Memory

```rebol
original: "test"
identical: as string! original
insert original "MODIFIED-"
print identical  ;; "MODIFIED-test" - reflects changes.
```

### Pattern 2: Type Conversions Create New Series

```rebol
original: "test"
converted: as file! original
insert original "MODIFIED-"
print converted  ;; %test - unaffected by original changes.
```

## Type Specification Methods

### Method 1: Using Datatype Values

```rebol
result: as file! "filename"    ;; Using `file!` datatype
result: as block! (content)    ;; Using `block!` datatype
```

### Method 2: Using Example Values

```rebol
example-file: %template
result: as example-file "filename"  ;; Using example file.

example-paren: first [(template)]
result: as example-paren [content]  ;; Using example paren.
```

## Practical Usage Patterns

### File Path Conversions

```rebol
;; Convert string paths to file paths:
text-path: "data/config.txt"
file-path: as file! text-path     ;; `%data/config.txt`
url-path: as url! text-path       ;; `http://data/config.txt` (if valid).
```

### Block Structure Conversions

```rebol
;; Convert between block structures:
data: [first second third]
paren-data: as paren! data        ;; (first second third).
path-data: as path! [obj method]  ;; obj/method
```

### Email and URL Processing

```rebol
;; Process email strings:
email-text: "user@domain.com"
email-value: as email! email-text ;; `user@domain.com`

;; Process URL strings  
url-text: "https://example.com"
url-value: as url! url-text       ;; `https://example.com` (`url!` datatype).
```

## Error Handling Best Practices

### Always Use Error Handling

```rebol
safe-convert: function [source target-type] [
    set/any 'result try [as target-type source]
    either error? get/any 'result [
        print ["Conversion failed for:" mold source]
        none
    ] [
        result
    ]
]
```

### Check Compatibility First

```rebol
convert-if-compatible: function [source target-type] [
    ;; Check if types are in same family:
    source-family: case [
        any-string? source ["string"]
        any-block? source ["block"]
        true ["other"]
    ]
    
    target-family: case [
        find [string! file! url! email! tag!] target-type ["string"]
        find [block! paren! path!] target-type ["block"] 
        true ["other"]
    ]
    
    either source-family = target-family [
        as target-type source
    ] [
        print "Incompatible type families!"
        none
    ]
]
```

## Common Pitfalls for Novice Programmers

### ❌ PITFALL 1: Expecting Memory Sharing Across Types

```rebol
;; WRONG ASSUMPTION
text: "original"
file-ver: as file! text
insert text "MODIFIED-"
;; `file-ver` will NOT reflect changes (it's a different series).
```

### ❌ PITFALL 2: Cross-Family Conversions

```rebol
;; THESE WILL FAIL:
try [as block! "string"]     ;; string→block not supported.
try [as string! [block]]     ;; block→string not supported.
try [as integer! "123"]      ;; string→integer not supported.
```

### ❌ PITFALL 3: Assuming All String Types Work the Same

```rebol
;; Some string types may have restrictions:
try [as refinement! "test"]  ;; might not be supported.
;; Always test compatibility first.
```

### ❌ PITFALL 4: Path Length Requirements

```rebol
;; Paths need 2-3 elements typically:
try [as path! [single]]       ;; May fail - too few elements.
try [as path! [a b c d e]]    ;; May fail - too many elements.
as path! [obj method]         ;; ✅ Works - 2 elements.
```

## Performance Considerations

### Fast Operations

- Identity conversions (same type): **Instant** - no work needed.
- Within-family conversions: **Fast** - minimal overhead.

### Memory Efficiency

- Same-type: **Zero memory overhead** - same reference.
- Different types: **Minimal overhead** - new series header only.

## Advanced Techniques

### Batch Conversions

```rebol
convert-files: function [string-paths [block!]] [
    collect [
        foreach path string-paths [
            if string? path [keep as file! path]
        ]
    ]
]
```

### Type-Safe Conversion Wrapper

```rebol
as-safe: function [target-type source] [
    case [
        ;; Identity check:
        target-type = type? source [source]
        
        ;; String family check:
        all [
            any-string? source
            find [string! file! url! email! tag!] target-type
        ] [as target-type source]
        
        ;; Block family check :
        all [
            any-block? source
            find [block! paren! path!] target-type
        ] [as target-type source]
        
        ;; Incompatible:
        true [
            throw make error! rejoin [
                "Cannot convert " type? source " to " target-type
            ]
        ]
    ]
]
```

## Summary

The `as` function is a powerful tool for **efficient type coercion** within compatible type families:

- ✅ **Use for**: Converting between related types (string↔file, block↔paren).
- ✅ **Benefits**: Minimal memory overhead, fast conversions.
- ❌ **Don't use for**: Cross-family conversions, data copying, type casting.
- ⚠️ **Remember**: Identity operations share memory, type conversions create new series.

Always wrap `as` function calls in error handling and verify type compatibility before conversion.
