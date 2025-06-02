REBOL [
    Title: "Rebol Array Manipulation Library"
    Version: 0.1.0
    Author: "Trae AI Assistant"
    Date: 2024-01-17
    Purpose: "Robust library for advanced array operations in Rebol 3"
    Notes: {
        This library provides `functions` for creating and manipulating
        multi-dimensional `arrays` in `Rebol 3`, with a focus on reliability
        and proper error handling.  
    }
]

; --- Array Creation Functions ---
make-array: function [
    {Creates a multi-dimensional `array`.  Specified by `dimensions`.
    dimensions [block!] "Block of `dimensions` for the `array`.  Each `element` must be a positive `integer!`."
    /with "Initialize `array` `elements` with a specific `value`."
        value [any-type!] "The `value` to initialize `array` `elements` with.  Defaults to `none` if not provided."
    Returns: [block!] The newly created multi-dimensional `array`.
    Notes: {
        Be cautious with very large `dimensions` as this can lead to significant memory allocation.  
        Callers should sanitize untrusted inputs for `dimensions` to prevent potential Denial of Service.  
    }
    }
] [
    ; Validate `dimensions`.
    if empty? dimensions [
        do make error! "Dimensions block cannot be empty"
    ]

    foreach dim dimensions [
        if not integer? dim [
            do make error! "All dimensions must be integers"
        ]
        if dim <= 0 [
            do make error! "All dimensions must be positive"
        ]
    ]

    ; Create `array` recursively.
    initial-value: either with [value] [none]

    make-nested: function [ ; Docstring for local functions is optional but good practice. Assuming none for now.
        dims [block!]
        curr-value [any-type!]
    ] [
        either empty? next dims [
            ; Create 1D `array` for innermost `dimension`.
            array/initial first dims curr-value
        ] [
            ; Create nested `array` for current `dimension`.
            result: make block! first dims
            loop first dims [
                append result make-nested next dims curr-value
            ]
            result
        ]
    ]

    make-nested dimensions initial-value
]

; --- Array Access Functions ---
get-element: function [
    {Safely access an `array` `element` at specified `indices`.
    arr [block!] "The `array` to access."
    indices [block!] "Block of `integer!` `indices` to access the `element`."
    Returns: [any-type!] The `value` of the `element`.
    Throws: [error!] If `indices` are invalid (e.g., out of bounds, wrong type).  
    }
] [
    ; Validate input.
    if empty? indices [
        do make error! "Indices block cannot be empty"
    ]

    result: arr
    foreach idx indices [
        if not integer? idx [
            do make error! "All indices must be integers"
        ]
        if any [idx <= 0 idx > length? result] [
            do make error! rejoin ["Index out of bounds: " idx]
        ]
        result: pick result idx
    ]
    result
]

set-element: function [
    {Safely modify an `array` `element` at specified `indices`.
    arr [block!] "The `array` to modify.  This `array` is modified in place."
    indices [block!] "Block of `integer!` `indices` to locate the `element`."
    value [any-type!] "New `value` to set for the `element`."
    Returns: [block!] The modified `arr`.
    Throws: [error!] If `indices` are invalid (e.g., out of bounds, wrong type).  
    }
] [
    ; Validate input.
    if empty? indices [
        do make error! "Indices block cannot be empty"
    ]

    ; Navigate to parent `block`.
    parent: arr
    for i 1 (length? indices) - 1 [
        idx: pick indices i
        if not integer? idx [
            do make error! "All indices must be integers"
        ]
        if any [idx <= 0 idx > length? parent] [
            do make error! rejoin ["Index out of bounds: " idx]
        ]
        parent: pick parent idx
    ]

    ; Set `value` at final `index`.
    final-idx: last indices
    if any [final-idx <= 0 final-idx > length? parent] [
        do make error! rejoin ["Final index out of bounds: " final-idx]
    ]
    poke parent final-idx value
    arr
]

; --- Array Information Functions ---
get-dimensions: function [
    {Get `dimensions` of a multi-dimensional `array`.
    arr [block!] "The `array` to analyze."
    Returns: [block!] A `block!` of `integer!`s representing the `dimensions`.
    Notes: {
        For irregular `arrays` (where sub-`block`s at the same level have different lengths),
        the reported `dimensions` are based on the path taken through the first `element` at each level.  
        Use `valid-array?` to check for regularity.  
        Returns `[]` if `arr` is not a `block!` or is an empty `block!`.  
        Be cautious with extremely large or deeply nested `array` structures, as this may lead to performance
        degradation or exhaust system limits.  Callers should sanitize untrusted inputs for `arr`.  
    }
    }
] [
    dims: copy []
    current: arr

    while [block? current] [
        append dims length? current
        if not empty? current [
            current: first current
        ]
    ]
    dims
]

; --- Array Validation Functions ---
valid-array?: function [
    {Check if an `array` has consistent `dimensions` (i.e., is regular).
    arr [block!] "The `array` to validate."
    Returns: [logic!] `true` if the `array` is regular, `false` otherwise.
    Notes: {
        A scalar input (non-`block!`) will return `false`.  
        An empty `block!` `[]` is considered a valid, regular `array`.  
        Be cautious with extremely large or deeply nested `array` structures, as this may lead to performance
        degradation or exhaust system limits.  Callers should sanitize untrusted inputs for `arr`.  
    }
    }
] [
    expected-dims: get-dimensions arr
    if empty? expected-dims [return true]

    check-dims: function [ ; Docstring for local functions is optional but good practice. Assuming none for now.
        current [block!]
        level [integer!]
    ] [
        if level > length? expected-dims [return false]
        if (length? current) <> pick expected-dims level [return false]

        if level < length? expected-dims [
            foreach item current [
                if not block? item [return false]
                if not check-dims item (level + 1) [return false]
            ]
        ]
        true
    ]

    check-dims arr 1
]
