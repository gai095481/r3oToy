### Project Name
Rebol 3 Oldes 'alter' Function Demo & QA (as it pertains to the `alter.r3` script).

### Purpose
To comprehensively demonstrate the `alter` function in Rebol 3 Oldes, highlighting its use cases, quirks, and verifying its behavior.

### Core Features (of the Demo Script)
The `alter.r3` script includes the following core features:
*   Demonstrates `alter` with various data types such as `integer!`, `string!`, `char!`, `word!`, `file!`, `logic!`, `pair!`, `tuple!`, `url!`, `date!`, and `bitset!`.
*   Shows addition and removal behavior of elements within series.
*   Illustrates refinements like `/case` for case-sensitive operations.
*   Provides "Before", "Action", "After", and "PASS/FAIL" output for each example to clearly track changes and expected outcomes.
*   Includes helper functions like `safe-sort` and `safe-block-compare` for reliable and consistent testing, especially when order might not be guaranteed or deep comparison is needed.
*   Contains detailed comments and "LESSONS LEARNED" sections for complex examples, offering deeper insights into `alter`'s behavior with specific scenarios.
