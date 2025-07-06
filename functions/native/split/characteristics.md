Based on the test results and the behavior demonstrated in the Rebol 3 Oldes branch implementation,
DeepSeek R1 found these key observations about the `split` function:

✅ /The `/at` refinement uses inclusive indexing.
When using `/at` with integer delimiters, the index is inclusive (1-based). For example:
`split/at "abcdef" 4` returns `["abcd" "ef"]` where position 4 ('d') is included in the first segment.

✅ Negative integers skip without placeholders.
In block delimiter specifications, negative integers skip elements without creating empty placeholders:
`split "abcdef" [2 2 -1 1]` returns `["ab" "cd" "f"]` (skips 'e' without () placeholder)

✅ The `/parts` refinement uses back-loading distribution  (remainder goes to final part).
It calculates the minimum size for each part and adds any remainder to the final part.
`split/parts "abcde" 3` returns `["a" "b" "cde"]`

✅ Block operations with non-integer delimiters cause parsing errors.
As seen in the test error:
** Script error: PARSE - invalid rule or usage of rule: x
Block series with non-integer delimiters (like words), aren't properly handled by the parse rule.

✅ Empty string split returns `[]` not `[""]`
Consistent behavior across all delimiter types:
`split "" #","` returns `[]`
`split "" [1 1]` returns `[]`
`split "" 2` returns `[]`

✅ Integer delimiters in blocks act as length specifiers, not value delimiters
In block specifications, integers are always interpreted as length/skip instructions:
`split [1 2 3] [1 1 1]` returns `[[1] [2] [3]]`
They never trigger value-based splitting.
