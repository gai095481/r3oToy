Rebol []

shy-ajoin: funct [
    "Join reduced block elements with safer predictable behavior."
    block [block!] "Values to join (reduced)"
    /with "Add delimiter between elements"
    delimiter [any-type!] "Delimiter value"
    /all "Include NONE and UNSET! values"
][
    shy-get: funct [word [word!]] [
        if error? try [return get word] [return ""]
    ]

    shy-sanitize: funct [item][
        case [
            unset? :item [either all ["unset"] [""]]
            none? :item [either all ["none"] [""]]
            true [item]
        ]
    ]

    shy-deep-process: funct [blk][
        collect [
            foreach item blk [
                item: shy-sanitize :item
                keep case [
                    block? :item [deep-process item]
                    word? :item [shy-get item]
                    path? :item [shy-get item]
                    true [item]
                ]
            ]
        ]
    ]

    processed: shy-deep-process reduce block

    ;; Handle file path magic safely:
    if all [
        not with
        not empty? processed
        all [file? first processed | file? last processed]
        path: attempt [to-file rejoin processed]
        exists? path
    ][
        return path
    ]

    ;; Convert all elements to strings:
    elements: collect [
        foreach item processed [
            keep form :item
        ]
    ]

    ;; Apply any delimiter:
    rejoin either with [
        delimiter-str: form :delimiter
        collect [
            keep first elements
            forskip elements 1 [
                keep delimiter-str
                keep first elements
            ]
        ]
    ][
        return elements
    ]
]
