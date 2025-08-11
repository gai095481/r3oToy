REBOL [
    Title: "Common Library"
    Purpose: "A collection of common, reusable functions."
]

grab: function [
    data [any-type!] "The data structure to access (`block!`, `map!` or `none!`)."
    key [any-word! string! integer! decimal! block!] "The index, key or path to retrieve."
    /path "Treat the `key` as a path (a block of keys/indices)."
    /default "Provide a default value if the retrieval fails."
    default-value [any-type!] "The value to return on failure."
][
    {Safely retrieve a value from a `block!` or `map!`, with optional path traversal.
    RETURNS: [any-type!] "The retrieved value, default value or `none`"
    ERRORS: None. This function is designed to never error, return a default value on failure.}

    if path [
        if any [not block? key empty? key] [
            return either default [default-value] [none]
        ]

        current: data

        foreach step key [
            if not any [block? :current map? :current] [
                current: none
                break
            ]

            current: grab current step

            if none? :current [break]
        ]

        return either all [none? :current default] [default-value] [current]
    ]

    if not any [block? data map? data none? data] [return either default [default-value] [none]]
    if none? data [return either default [default-value] [none]]

    if block? data [
        if integer? key [
            ;; For integers, we must normalize the result of `pick`:
            value: pick data key

            if none? value [return either default [default-value] [none]]
            case [
                all [word? value value = 'none] [return none]
                all [word? value value = 'true] [return true]
                all [word? value value = 'false] [return false]
            ]

            return value
        ]

        if decimal? key [
            ;; Decimal keys are not valid for block indexing - return default/none:
            return either default [default-value] [none]
        ]

        ;; Block keys in non-path mode are invalid - return default or none
        if block? key [
            return either default [default-value] [none]
        ]

        ;; This is the sophisticated parsing and evaluation logic for word/string keys:
        position: find data to-set-word key

        if position [
            value-expression: copy next position
            next-setword-pos: none
            foreach item value-expression [
                if set-word? item [
                    next-setword-pos: find value-expression item
                    break
                ]
            ]

            if next-setword-pos [
                value-expression: copy/part value-expression next-setword-pos
            ]

            if not empty? value-expression [
                ;; This is the "Try / Fallback" pattern:
                ;; First, ATTEMPT to evaluate the expression.
                result: try [do value-expression]

                ;; Check if the attempt failed (e.g., context error on an alias):
                if error? result [
                    ;; The 'do' failed.  Fall back to the safe 'select' logic, to get the next literal value:
                    return select data to-set-word key
                ]

                ;; The 'do' succeeded. Return the evaluated result:
                return result
            ]
        ]

        return either default [default-value] [none]
    ]

    if map? data [
        if find data key [
            value: select data key
            case [
                all [word? value value = 'none] [return none]
                all [word? value value = 'true] [return true]
                all [word? value value = 'false] [return false]
            ]

            return value
        ]

        return either default [default-value] [none]
    ]
]
