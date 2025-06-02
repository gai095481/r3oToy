REBOL [
    Title: "Rebol Array Manipulation Library"
    Version: 0.1.0
    Author: "Trae AI Assistant"
    Date: 2024-01-17
    Purpose: "Robust library for advanced array operations in Rebol 3"
    Notes: {
        This library provides functions for creating and manipulating
        multi-dimensional arrays in Rebol 3, with a focus on reliability
        and proper error handling.
    }
]

; --- Array Creation Functions ---
function make-array [
    "Creates a multi-dimensional array with specified dimensions"
    dimensions [block!] "Block of dimensions for the array"
    /with "Initialize array with a specific value"
        value [any-type!] "Value to initialize array elements with"
] [
    ; Validate dimensions
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

    ; Create array recursively
    initial-value: either with [value] [none]

    make-nested: function [
        dims [block!]
        curr-value [any-type!]
    ] [
        either empty? next dims [
            ; Create 1D array for innermost dimension
            array/initial first dims curr-value
        ] [
            ; Create nested array for current dimension
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
function get-element [
    "Safely access an array element at specified indices"
    arr [block!] "Array to access"
    indices [block!] "Block of indices to access"
] [
    ; Validate input
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

function set-element [
    "Safely modify an array element at specified indices"
    arr [block!] "Array to modify"
    indices [block!] "Block of indices to access"
    value [any-type!] "New value to set"
] [
    ; Validate input
    if empty? indices [
        do make error! "Indices block cannot be empty"
    ]

    ; Navigate to parent block
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

    ; Set value at final index
    final-idx: last indices
    if any [final-idx <= 0 final-idx > length? parent] [
        do make error! rejoin ["Final index out of bounds: " final-idx]
    ]
    poke parent final-idx value
    arr
]

; --- Array Information Functions ---
function get-dimensions [
    "Get dimensions of a multi-dimensional array"
    arr [block!] "Array to analyze"
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
function valid-array? [
    "Check if array has consistent dimensions"
    arr [block!] "Array to validate"
] [
    expected-dims: get-dimensions arr
    if empty? expected-dims [return true]

    check-dims: function [
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
