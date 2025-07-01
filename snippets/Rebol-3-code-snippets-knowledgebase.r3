REBOL [
    Title: "Enhanced Rebol Snippet Database System"
    Version: 1.2.1
    Author: "Gemini Pro AI Assistant"
    Date: 30-Jun-2025
    File: %Rebol-3-code-snippets-knowledgebase.r3
    Purpose: "Load and search Rebol code snippets with flexible search modes."
]

;;-----------------------------------------------------------------------------
;; Sample Snippet Database (would normally be in %snippets-db.r)
;;-----------------------------------------------------------------------------
;; FIX 1: Use `reduce` to evaluate the `make` expressions, creating a block
;; of actual objects, not a block of raw source code.
sample-snippets: reduce [
	make object! [
		code: {quit/return int-exit-code}
		tags: ['provide 'exit 'quit 'return 'leave 'close 'end 'halt 'code 'terminate 'kill 'stop 'abort 'error 'success 'failure 'shutdown]
		desc: "Exit the script with a specific integer exit code."
		category: "system"
	]

	make object! [
		code: {system/script/header/file}
		tags: ['retrieve 'filename 'header 'Rebol 'script 'file!]
		desc: "Retrieve the script's filename from its file header."
		category: "header"
	]

	make object! [
		code: {system/script/header/version}
		tags: ['retrieve 'version 'header 'Rebol 'file 'script 'tuple! 'specification]
		desc: "Retrieve the script's version tuple from its file header."
		category: "specification"
	]

	make object! [
		code: {system/platform = 'Linux}
		tags: ['Linux 'operating-system 'platform 'match 'compare 'specification 'OS 'ask]
		desc: "If the current operating system is Linux."
		category: "platform"
	]

	make object! [
		code: {system/platform = 'Windows}
		tags: ['Microsoft 'Windows 'operating-system 'match 'platform 'compare 'specification 'OS 'ask]
		desc: "If the current operating system is Microsoft Windows."
		category: "platform"
	]

make object! [
		code: {secure [file [allow read]]}
		tags: ['security 'access 'read 'allow 'let 'import 'configure]
		desc: "Configure a security policy to allow file read operations."
		category: "security"
	]

	make object! [
		code: {funct [a b] [a = b]}
		tags: ['haystack 'string 'strict 'equal 'match 'lettercase 'insensitive 'ignore 'compare 'function 'letter 'case 'ask]
		desc: "Compare two strings for equality lettercase-insensitive."
		category: "string"
	]

	make object! [
		code: {funct [a b] [a == b]}
		tags: ['haystack 'string 'relaxed 'equal 'match 'lettercase 'sensitive 'compare 'function 'letter 'case 'ask]
		desc: "Compare two strings for equality lettercase-sensitive."
		category: "string"
	]

	make object! [
		code: {none? find/case "search this string" complement charset " aceghinrst"}
		tags: ['haystack 'string 'needle 'charset 'find 'locate 'match 'all 'everything 'ask]
		desc: "If string haystack ONLY has the characters in the specified charset."
		category: "string"
	]

	make object! [
		code: {funct [target [string!]] [trim/head target]}
		tags: ['modify 'string 'trim 'whitespace 'leading 'leftmost 'tab 'character 'discard 'remove 'snip 'lop 'cut 'reformat 'subtract]
		desc: "Discard leading whitespace (spaces, tabs), within a string."
		category: "string"
	]

	make object! [
		code: {funct [target [string!]] [trim/tail target]}
		tags: ['modify 'trim 'whitespace 'trailing 'rightmost 'tab 'string 'character 'discard 'remove 'snip 'lop 'cut 'reformat 'subtract]
		desc: "Discard trailing whitespace (spaces, tabs) within a string."
		category: "string"
	]

	make object! [
		code: {funct [target [string!]] [trim/lines target]}
		tags: ['modify 'string 'trim 'compact 'reduce 'redundant 'sequential 'whitespace 'character 'tab 'discard 'remove 'reformat 'subtract]
		desc: "Reduce all sequential whitespace and line breaks within a string to a single space character."
		category: "string"
	]

	make object! [
		code: {funct [target [string!]] [trim target]}
		tags: ['modify 'string 'trim 'whitespace 'leading 'trailing 'leftmost 'rightmost 'tab 'character 'discard 'remove 'snip 'lop 'cut 'reformat 'subtract]
		desc: "Discard both leading and trailing whitespace characters from a string."
		category: "string"
	]

	make object! [
		code: {funct [target [string!]] [trim/all target]}
		tags: ['modify 'string 'trim 'all 'whitespace 'character 'tab 'discard 'remove 'reformat 'strip 'subtract]
		desc: "Discard ALL whitespace from a string, including internal line break characters."
		category: "string"
	]

	make object! [
		code: {afunc: funct [target [string!] chars-to-discard [bitset!]] [trim/with target (rejoin collect [repeat i 256 [c: to-char (i - 1) if find chars-to-discard c [keep c]]])]}
		tags: ['modify 'select 'charset 'character 'discard 'remove 'reformat 'strip 'subtract]
		desc: "Discard the specified charset from a string."
		category: "string"
	]

	make object! [
		code: {funct [haystack [string!]] [not none? find haystack needle]}
		tags: ['string 'haystack 'select 'needle 'charset 'character 'discard 'remove 'reformat 'strip 'subtract 'letter 'case 'insensitive 'ignore]
		desc: "Discard the specified charset from a string (lettercase insensitive)."
		category: "string"
	]

	make object! [
		code: {funct [haystack [string!]] [not none? find/case haystack needle]}
		tags: ['string 'haystack 'select 'needle 'charset 'character 'discard 'remove 'reformat 'strip 'subtract 'letter 'case 'sensitive]
		desc: "Discard the specified charset from a string (lettercase sensitive)."
		category: "string"
	]

	make object! [
			code: {not none? find "haystack" "needle"}
			tags: ['string 'haystack 'find 'locate 'needle 'contains 'substring 'search 'exists 'Boolean 'logic! 'found? 'stristr 'letter 'case 'insensitive 'ignore]
			desc: "Convert `find` result to a Boolean return value & return `true` if `haystack` contains `needle` (lettercase insensitive)."
			category: "string"
		]

	make object! [
			code: {not none? find/case "haystack" "needle"}
			tags: ['string 'haystack 'find 'locate 'needle 'contains 'substring 'search 'exists 'Boolean 'logic! 'found? 'strstr 'letter 'case 'sensitive]
			desc: "Convert `find` result to a Boolean return value & return `true` if `haystack` contains `needle` (lettercase sensitive)."
			category: "string"
		]

		make object! [
			code: {result: (does [count: 0 foreach char "haystack" [if find charset "AEIOU" char [count: count + 1]] count])}
			tags: ['string 'haystack 'charset 'needle 'count 'frequency 'occurrences 'subset 'find 'character 'case 'letter 'insensitive 'ignore]
			desc: "Count character frequency of the specified charset in a haystack string (lettercase insensitive)."
			category: "string"
		]

		make object! [
			code: {result: (does [count: 0 foreach char "haystack" [if find/case charset "aeiou" char [count: count + 1]] count])}
			tags: ['string 'haystack 'charset 'needle 'count 'frequency 'occurrences 'subset 'find 'character 'case 'letter 'sensitive]
			desc: "Count character frequency of the specified charset in a haystack string (lettercase sensitive)."
			category: "string"
		]

		make object! [
			;; set-to-convert: alphabet-charset: charset [#"A" - #"Z" #"a" - #"z"]
			code: {result: charset-to-string: (function [set-to-convert] [rejoin collect [repeat index 256 [char: to-char (index - 1) if find set-to-convert char [keep char]]]])}
			tags: ['convert 'charset 'bitset 'to 'human 'readable 'string 'representation 'ASCII 'character 'all 'set]
			desc: "Convert a `charset!` / `bitset!` to a human readable string representation with all of its member characters (ASCII 0-255)."
			category: "string"
		]
]


;;-----------------------------------------------------------------------------
;; Enhanced Search Functions
;;-----------------------------------------------------------------------------
match-snippets-any: function [
    {Match code snippets matching ANY of the provided tags (OR logic).}
    db [block!] "The loaded snippet knowledgebase."
    query [word! block!] "A single tag or block of tags to match."
][
	matches: copy []
	unless block? query [query: to-block query]

	foreach snippet db [
		if not empty? intersect query snippet/tags [
			append matches snippet
		]
	]

	return matches
]

;;----------------------------------------------------------
match-snippets-all: function [
    {Match code snippets matching ALL of the provided tags (AND logic).}
    db [block!] "The loaded snippet knowledgebase."
    query [word! block!] "A single tag or block of tags to match."
][
	matches: copy []
	unless block? query [query: to-block query]

	foreach snippet db [
		if (length? query) = (length? intersect query snippet/tags) [
			append matches snippet
		]
	]

	return matches
]

;;----------------------------------------------------------
match-snippets-category: function [
    {Match code snippets by category.}
    db [block!] "The loaded code snippets knowledgebase."
    category [string!] "The category to search for."
][
	matches: copy []

	foreach snippet db [
		if all [
			in snippet 'category
			equal? snippet/category category
		][
			append matches snippet
		]
	]

	return matches
]

;;----------------------------------------------------------
match-snippets-text: function [
    {Match code snippets having text in the code or description (Case-insensitive).}
    db [block!] "The loaded code snippets knowledgebase."
    search-text [string!] "Text to search for."
][
	matches: copy []

	foreach snippet db [
		if any [
			find snippet/code search-text
			find snippet/desc search-text
		][
			append matches snippet
		]
	]

	return matches
]

;;----------------------------------------------------------
output-matches: function [
    {Output search matches in a formatted way.}
    matches [block!] "Block of code snippet objects to output."
    max-results [integer!] "The maximum number of matches to output."
    /short-format
    /details
][
	either empty? matches [
		print "No code snippets matched your search criteria."
	][
		count: 0

		foreach snippet matches [
			count: count + 1

			if all [(count > max-results) short-format] [
				print ["... and" ((length? matches) - max-results) "more results."]
				break
			]

			print rejoin [";; " snippet/desc]
			print [snippet/code]

			if details [
					print ["Desc:" snippet/desc]

				if in snippet 'category [
					print ["Category:" snippet/category]
				]

				print ["Tags:" mold snippet/tags]
			]
		]

		print ["^/Total matches found:" (length? matches)]
	]
]

;;-----------------------------------------------------------------------------
;; Interactive Search Interface
;;-----------------------------------------------------------------------------
search-interface: function [
    {Interactive search interface for the snippets knowledgebase.}
    db [block!] "The loaded code snippets knowledgebase."
][
	print "^/=== Rebol Snippet Search Interface ==="
	print "Commands:"
	print {  any [tag1 tag2]       - Find snippets with ANY of these tags.}
	print {  all [tag1 tag2]       - Find snippets with ALL of these tags.}
	print {  cat "category"        - Find snippets by category (use quotes).}
	print {  text "search-phrase"  - Find snippets containing text (use quotes).}
	print "  help                  - Output this help."
	print "  quit or q             - Exit search the interface."
	print "^/Enter search command:"

	forever [
		prin "[search> "
		set/any 'input try [load ask ""]

		if error? input [
			print "Invalid input. Type 'help' for commands."
			continue
		]

		if none? input [input: []]		;; Make `none` input an empty block.

		;; Convert `find` result to Boolean by checking if it's `not none`:
		if (word? input) and (not none? find [quit q bye exit] input) [quit/return 0]

		if not block? input [input: reduce [input]]	;; convert the various datatypes made by `load` into a block.
		if empty? input [continue]

		command: input/1

		case [
			command = 'help [
					print "^/Commands:"
					print {  any [tag1 tag2]      - Find snippets with ANY of these tags.}
					print {  all [tag1 tag2]      - Find snippets with ALL of these tags.}
					print {  cat "category"       - Find snippets by category (use quotes).}
					print {  text "search-phrase" - Find snippets containing text (use quotes).}
					print "  help                 - Output this help."
					print "  quit or q            - Exit search the interface.^/"
			]

			command = 'any [
					if any [(length? input) < 2 not block? input/2] [
						print "Usage: any [tag1 tag2 ...]"
						continue
					]

					matches: match-snippets-any db input/2
					output-matches matches 1000
			]

			command = 'all [
					if any [(length? input) < 2 not block? input/2] [
						print "Usage: all [tag1 tag2 ...]"
						continue
					]

					matches: match-snippets-all db input/2
					output-matches matches 1000
			]

			command = 'cat [
					if any [(length? input) < 2 not string? input/2] [
						print "Usage: cat ""category-name"""
						continue
					]

					matches: match-snippets-category db input/2
					output-matches matches 1000
			]

			command = 'text [
					if any [(length? input) < 2 not string? input/2] [
						print "Usage: text ""search-phrase"""
						continue
					]

					matches: match-snippets-text db input/2
					output-matches matches 1000
			]

			true [print ["Unknown command:" command "Type 'help' for available commands."]
			]
		]
	]
]

;;-----------------------------------------------------------------------------
;; Main Program
;;-----------------------------------------------------------------------------
print "=== Rebol 3 Oldes Code Snippets Knowledgebase System ==="
print ["Loaded" (length? sample-snippets) "code snippets..."]

comment {
;; Non-interactively demonstrate different search modes:
print "--- Example: Find ANY snippet with 'trim OR 'string tags ---"
matches: match-snippets-any sample-snippets ['trim 'string]
output-matches matches 1000

print "^/--- Example: Find snippets with ALL 'string AND 'remove tags ---"
matches: match-snippets-all sample-snippets ['string 'remove]
output-matches matches 1000

print "^/--- Example: Find snippets in 'string' category ---"
matches: match-snippets-category sample-snippets "string"
output-matches matches 1000

print "^/--- Example: Text search for 'whitespace' ---"
matches: match-snippets-text sample-snippets "whitespace"
output-matches matches 1000
}

;; Use for interactive mode:
search-interface sample-snippets
