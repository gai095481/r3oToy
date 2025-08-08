## PCRE-like Block-Based Engine (Overview)

- Directory: `functions/reusable/PCRE/block-based/src`
- Files:
  - `string-to-block-tokenizer.r3`
  - `block-pattern-processor.r3`
  - `block-regexp-core-utils.r3`
  - `block-regexp-engine.r3`
  - `block-regexp-matcher.r3`
  - `block-to-parse-rules-generator.r3`
  - `block-regexp-test-wrapper.r3`

This module family implements a PCRE-inspired matching engine using Rebol blocks instead of strings. It includes tokenization, pattern processing, a matching engine, utilities, and test wrappers.

Due to the breadth of the internal APIs and the exploratory nature of the code, this doc provides pointers rather than an exhaustive reference. Recommended approach:

1. Start at `block-regexp-test-wrapper.r3` to see how a pattern and subject are prepared and matched.
2. Inspect `string-to-block-tokenizer.r3` for the token structure the engine expects.
3. Review `block-regexp-engine.r3` and `block-regexp-matcher.r3` for the core matching logic and public entry points exposed by those scripts (e.g., top-level `function` values declared in each file).

Loading example:
```rebol
foreach f [
  %functions/reusable/PCRE/block-based/src/string-to-block-tokenizer.r3
  %functions/reusable/PCRE/block-based/src/block-pattern-processor.r3
  %functions/reusable/PCRE/block-based/src/block-regexp-core-utils.r3
  %functions/reusable/PCRE/block-based/src/block-regexp-engine.r3
  %functions/reusable/PCRE/block-based/src/block-regexp-matcher.r3
] [do f]
```

Future work:
- Extract a stable public API surface (e.g., `re-block/match`, `re-block/compile`) and document signatures and return conventions thoroughly.
- Generate examples for common patterns (literals, groups, alternation, quantifiers).