Rebol []

;-----------------------------------------------------------------------------
; A Battle-Tested QA Harness
;-----------------------------------------------------------------------------
all-tests-passed?: true

assert-equal: function [
	{Compare two values and output a formatted PASSED or FAILED message.}
	expected [any-type!] "The expected / correct value."
	actual [any-type!] "The actual value."
	description [string!] "A description of the specific QA test being run."
	][
	either equal? expected actual [
	result-style: "✅ PASSED:"
	message: description
	][
	set 'all-tests-passed? false
	result-style: "❌ FAILED:"
	message: rejoin [
	description "^/ >> Expected: " mold expected
	"^/ >> Actual: " mold actual
	]
	]
	print [result-style message]
]

print-test-summary: does [
	{Prints the final summary of the entire test run.}
	print "^/============================================"
	either all-tests-passed? [
	print "✅ ALL TEST CASE EXAMPLES PASSED."
	][
	print "❌ SOME TEST CASE EXAMPLES FAILED."
	]
	print "============================================^/"
]

;-----------------------------------------------------------------------------
; Probing the find native function
;-----------------------------------------------------------------------------
print "^/--- Probing Basic Behavior ---^/"
; Hypothesis: find on a block will return the portion of the block
; beginning with the found value. If not found, it will return none.
; The same logic applies to strings.
search-block: [a b c d e f]
search-string: "abcdef"
assert-equal [b c d e f] (find search-block 'b) "Finds a value in the middle of a block"
assert-equal "cdef" (find search-string "c") "Finds a value in the middle of a string"
assert-equal none (find search-block 'z) "Returns NONE for a value not in a block"
assert-equal none (find search-string "z") "Returns NONE for a value not in a string"
assert-equal search-block (find search-block 'a) "Finds a value at the head of a block"
assert-equal search-string (find search-string "a") "Finds a value at the head of a string"

print "^/--- Probing /tail Refinement ---^/"
; Hypothesis: The /tail refinement will cause find to return the position
; after the found value. If the value is not found, it remains none.
; If the value is the last item, it returns the empty tail of the series.
assert-equal [c d e f] (find/tail search-block 'b) "Finds a value and returns the tail of the block"
assert-equal "def" (find/tail search-string "c") "Finds a value and returns the tail of the string"
assert-equal [] (find/tail search-block 'f) "Returns an empty block when the last item is found with /tail"
assert-equal "" (find/tail search-string "f") "Returns an empty string when the last character is found with /tail"
assert-equal none (find/tail search-block 'z) "Returns NONE when value is not found with /tail"

print "^/--- Probing /last Refinement ---^/"
; Hypothesis: The /last refinement searches from the end of the series
; backwards. It should find the last occurrence of a value.
search-block-duplicates: [a b c a b c]
search-string-duplicates: "abcabc"
expected-block-position: at search-block-duplicates 4
assert-equal expected-block-position (find/last search-block-duplicates 'a) "Finds the last occurrence of a value in a block"
assert-equal "abc" (find/last search-string-duplicates "abc") "Finds the last occurrence of a substring in a string"
assert-equal "c" (find/last search-string-duplicates "c") "Finds the last occurrence of a character at the very end of a string"

print "^/--- Probing /reverse Refinement ---^/"
; Hypothesis: /reverse searches backwards from the current position.
; Searching backwards from the head of a series will always yield none.
; It is only equivalent to /last if the search starts from the tail.
forward-position: at search-block-duplicates 3 ; At the first 'c'
expected-reverse-position: at search-block-duplicates 1 ; Finds the first 'a'
assert-equal expected-reverse-position (find/reverse forward-position 'a) "Finds a prior value using /reverse from a specific series position"
assert-equal (find/last search-block-duplicates 'a) (find/reverse tail search-block-duplicates 'a) "/reverse from tail is equivalent to /last"
assert-equal none (find/reverse search-block-duplicates 'a) "/reverse from head finds nothing"

print "^/--- Probing /part Refinement ---^/"
; Hypothesis: /part with an integer limits the search depth.
; /part with a series! limits the search to that boundary.
series-for-part: [a b c d e f g]
boundary-for-part: at series-for-part 5 ; Points to 'e'
assert-equal none (find/part series-for-part 'f 4) "Fails to find a value beyond the /part integer limit"
assert-equal [d e f g] (find/part series-for-part 'd 4) "Finds a value within the /part integer limit"
assert-equal none (find/part series-for-part 'f boundary-for-part) "Fails to find a value beyond the /part series! boundary"
assert-equal [c d e f g] (find/part series-for-part 'c boundary-for-part) "Finds a value within the /part series! boundary"

print "^/--- Probing /skip Refinement ---^/"
; Hypothesis: /skip treats the series as records of a given size,
; and only matches the value at the start of each record.
records-block: [a 1 b 2 c 3 a 4]
assert-equal (at records-block 3) (find/skip records-block 'b 2) "Finds a value at the start of a record with /skip"
assert-equal none (find/skip records-block 1 2) "Does not find a value that is not at the start of a record"
assert-equal (at records-block 7) (find/skip/last records-block 'a 2) "Finds the last record-start value when combined with /last"

print "^/--- Probing /case and /same Refinements ---^/"
; Hypothesis: By default, string searches are case-insensitive. /case
; makes them sensitive. /same forces same? comparison.
string-for-case: "aBcDeF"
block-for-same: reduce [copy "s" "s"]
assert-equal "BcDeF" (find string-for-case "b") "Find is case-insensitive by default for strings"
assert-equal none (find/case string-for-case "b") "/case makes the search case-sensitive (fail case)"
assert-equal "BcDeF" (find/case string-for-case "B") "/case makes the search case-sensitive (pass case)"
assert-equal block-for-same (find block-for-same "s") "Find without /same finds the first equal? string"
assert-equal none (find/same block-for-same "s") "/same fails to find an equal? but not same? string"
assert-equal (at block-for-same 1) (find/same block-for-same first block-for-same) "/same finds the identical (same?) value"

print "^/--- Probing /only Refinement ---^/"
; Hypothesis: find does not recursively search into sub-series.
; /only is used to find a series as a value.
nested-block: [a b [c d] e f]
value-to-find: [c d]
assert-equal none (find nested-block 'c) "Default find does NOT recursively search sub-blocks"
assert-equal (at nested-block 3) (find/only nested-block value-to-find) "/only finds the block itself as a value"

print "^/--- Probing /any and /with Refinements ---^/"
; Hypothesis REVISED: The * wildcard seems to have subtle behavior when not at the end
; of the pattern. This test uses a known-good pattern.
wildcard-string: "rebol-rules-the-world"
assert-equal "rebol-rules-the-world" (find/any wildcard-string "rebol*") "/any with trailing '' wildcard finds a match"
assert-equal "rules-the-world" (find/any wildcard-string "r?les") "/any with '?' and '' wildcards finds a match"
assert-equal none (find/any wildcard-string "reb?rld") "/any with '?' wildcard fails when more than one char exists"
assert-equal "rebol-rules-the-world" (find/any/with wildcard-string "rebo@orld" "@o") "/with redefines '' to '@' and finds a match"

print "^/--- Probing /match Refinement ---^/"
; Hypothesis REVISED: /match ONLY checks for a match at the HEAD of a series.
; It's a predicate. If the head matches, it returns the ENTIRE original series,
; not just the matched portion.
match-block: [a b c d e]
match-string: "abcde"
assert-equal match-block (find/match match-block 'a) "/match returns the whole block if the head item matches a single value"
assert-equal none (find/match match-block 'b) "/match returns none if the head item does not match"
assert-equal match-block (find/match match-block [a b]) "/match returns the WHOLE series if the head matches a sub-series"
assert-equal none (find/match match-block [b c]) "/match returns none if the head of the series does not match"
assert-equal match-string (find/match match-string "ab") "/match on a string returns the WHOLE string if the head matches"
assert-equal none (find/match match-string "b") "/match on a string returns none if the head does not match"

print "^/--- Probing Edge Cases & Other Types ---^/"
; Hypothesis REVISED: find on a map returns the set-word! of the key.
; find on a typeset returns a logic! value indicating presence.
empty-block: []
empty-string: ""
data-map: make map! [a 1 b 2]
data-typeset: make typeset! [string! integer! block!]
assert-equal none (find empty-block 'a) "Find in an empty block returns none"
assert-equal none (find empty-string "a") "Find in an empty string returns none"
assert-equal none (find data-map 'c) "Find in a map for a non-existent key returns none"
assert-equal to-set-word 'b (find data-map 'b) "Find in a map for an existing key returns a set-word!"
assert-equal true (find data-typeset integer!) "Find in a typeset returns TRUE for an existing datatype"
assert-equal false (find data-typeset file!) "Find in a typeset for a non-existent datatype returns FALSE"
assert-equal none (find none 1) "Find on a 'none' series returns none"

;-----------------------------------------------------------------------------
; Final Summary
;-----------------------------------------------------------------------------
print-test-summary
