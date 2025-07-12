Jules AI did a scan of all "behavioral-diagnostic-probe-*.r3" files.

Here's a summary of potential false positives or tests that highlight surprising/specific behaviors which might be misinterpreted if you aren't aware of the exact R3 Oldes quirks:

Key Area of Conflicting Tests (Potential False Positive in one of them):

split function with block! and integer! value as delimiter:
File 1: functions/native/split/behavioral-diagnostic-probe-Claude-4-Sonnet.r3
Test: result: split [1 2 3 2 4] 2
Asserts: assert-equal [[1 2] [3 2] [4]] result
Implication: The integer delimiter 2 is included at the end of the segments it terminates (except possibly the last part of the original block).
File 2: functions/native/split/behavioral-diagnostic-probe-MiniMax-M1.r3
Test: split [1 2 3 4] 2 (Note: input data is slightly different)
Asserts: assert-equal [[1 2] [3 4]] result
Implication (Interpreted): If applied to [1 2 3 2 4] with 2 as delimiter, this logic would likely expect [[1] [3] [4]] (delimiter 2 is consumed and separates). The provided test split [1 2 3 4] 2 expecting [[1 2] [3 4]] is harder to directly compare but suggests a different grouping/consuming logic for the delimiter than Claude's version.
Conclusion: These two files show conflicting expectations for how split handles an integer value (not count) as a delimiter in a block. One of these assertions is likely incorrect for the actual R3 Oldes behavior, making the test a false positive if it passes with that incorrect expectation. This requires running these specific cases in R3 Oldes to determine the true behavior.
Tests Highlighting Specific/Surprising Behaviors (Passing test confirms the quirk, not a "false positive" in test logic itself):

ajoin returning file! type:

File: functions/native/ajoin/behavioral-diagnostic-probe-DeepSeek-R1.r3
Test (5.4c): assert-equal %home/user/file.txt ajoin [%home/user/ "file" %.txt] "File handling returns file! type"
Observation: ajoin typically returns a string!. If this test passes, it confirms a specific behavior where ajoin can return a file! if all elements can form a valid file path. This is more of ajoin having a potentially unexpected return type in some cases, rather than the test itself being flawed if it correctly captures this.
find with logic! values in blocks:

Files: functions/native/find/behavioral-diagnostic-probe-Lutra-AI.r3 (Sec 15.2, 15.3) and functions/native/find/behavioral-diagnostic-probe-best-coverage.r3 (Sec 15.2, 15.3).
Tests: assert-equal none find logic-block false and assert-equal none find logic-block true.
Observation: These tests suggest that find does not locate literal true or false values within a block (e.g., find [true false] true would return none). If these tests pass, they correctly document this specific (and potentially counter-intuitive) limitation of find.
put with integer! key on block! appends key-value pair:

Files: functions/native/put/behavioral-diagnostic-probe-Claude-4-Sonnet.r3 (e.g., Test for test-block3 and test-index-block), and implicitly supported by other put probes.
Test Example: test-block3: [10 20 30 40]; put test-block3 2 99 results in [10 20 30 40 2 99].
Observation: put does not treat an integer key as an index for replacement in a block; it appends the integer key and the new value. The tests correctly capture this specific behavior. This is important for you to know, as it differs from indexed assignment.
remove none and take none returning none without error:

Files: functions/native/remove/behavioral-diagnostic-probe-Lutra-AI.r3 (Test 16 for remove) and take probes like Claude-AI.r3, Jules-AI.r3, o1-mini.r3.
Tests: assert-equal none remove none and assert-equal none? take none.
Observation: Functions expecting series usually error if given none. If remove none and take none indeed return none without erroring in R3 Oldes, these tests correctly document this lenient behavior.
remove string_series_at_pos (no /part) removing to end of string:

File: functions/native/remove/behavioral-diagnostic-probe-Lutra-AI.r3 (Test 1 and its "CORRECTED" comment).
Test (Interpretation): If str1 is skip "Hello World" 5 (i.e., " World"), the test assert-equal "World" result1 where result1: remove str1.
Conflict/Clarification Needed: The comment states remove removes to end. If so, remove " World" (at the space) would make result1 be "" (empty string, as the rest of the series is now empty from that point). The expectation "World" seems to contradict the "removes to end" comment. If remove on a string at a position only removes one character (like it does for blocks), then result1 would be "World". This test needs clarification against the actual behavior of remove on strings at a specific position. If the comment is right, the expectation is wrong. If the expectation is right, the comment is wrong. This is a strong candidate for a false positive if the test passes as written but the underlying documented assumption (the comment) is the true R3 Oldes behavior.
replace with bitset! search value:

File: functions/native/replace/behavioral-diagnostic-probe-MiniMax-M1.r3
Test: replace "abc" charset [#"a" #"b"] "x" expects "xbc".
Observation: This implies replace (without /all) using a bitset as the search criteria only replaces the first character found that is present in the bitset. If this test passes, it correctly documents this specific interaction.
General Notes on the Probes:

Many of the diagnostic scripts are explicitly designed to uncover and document the precise, sometimes quirky or non-obvious, behaviors of Rebol 3 Oldes branch functions. When these tests pass, they are achieving their goal. They become "false positives" only if the expected value in the assertion is subtly wrong for the behavior the description claims to test, or if the behavior asserted as correct is known to be a bug that should ideally fail a "correctness" test.
The term "false positive" here is interpreted as "the test passes, but it might be misleading about general expectations or it asserts a subtly incorrect outcome as correct."
The most actionable item is the conflicting behavior of split block integer-value-delimiter between the Claude-4-Sonnet and MiniMax-M1 scripts for split. One of them has an incorrect expectation. The remove behavior on strings (Test 1 in Lutra-AI's remove probe) also warrants a close look at its return value versus the "removes to end" comment.
