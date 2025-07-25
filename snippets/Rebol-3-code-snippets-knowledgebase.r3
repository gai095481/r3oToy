REBOL [
    Title: "Enhanced Rebol Snippet Database System"
    Version: 1.2.6
    Author: "Gemini Pro AI Assistant"
    Date: 12-Jul-2025
    File: %Rebol-3-code-snippets-knowledgebase.r3
    Purpose: "Load and search Rebol code snippets with flexible search modes."
]

;;-----------------------------------------------------------------------------
;; Sample Snippet Database (would normally be in %snippets-kdb.r3)
;;-----------------------------------------------------------------------------
;; Use `reduce` to evaluate the `make` expressions, creating a block of actual objects,
;; not a block of raw source code.
sample-snippets: reduce [
	make object! [
		code: {quit/return int-exit-code}
		tags: ['provide 'exit 'quit 'return 'leave 'close 'end 'halt 'code 'terminate 'kill 'stop 'abort 'error 'success 'failure 'shutdown]
		desc: "Exit the script with a specific integer exit code."
		category: "status"
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
		tags: ['security 'access 'read 'allow 'let 'import 'configure 'include 'file 'script]
		desc: "Configure a security policy to allow file read operations such as to import or include a script."
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
		category: "convert"
	]

	make object! [
		code: {needle: 'bye (either not none? find [quit q bye exit] needle ["found"]["absent"])}
		tags: ['haystack 'match 'any 'word 'letter 'case 'insensitive 'inclusive 'chose 'choice 'options 'search 'exist]
		desc: "Return `true` if needle matches (lettercase insensitive), any word in word choices list (haystack) otherwise return `false`."
		category: "search"
	]

	make object! [
		code: {needle: 'bye (either not none? find/case [quit q bye exit] needle ["found"]["absent"])}
		tags: ['haystack 'match 'any 'word 'letter 'case 'sensitive 'inclusive 'chose 'choice 'options 'search]
		desc: "Return `true` if needle matches (lettercase sensitive), any word in word choices list (haystack) otherwise return `false`."
		category: "search"
	]

	make object! [
		code: {prin lf}
		tags: ['output 'blank 'empty 'single 'file 'line 'newline 'prin 'print 'stdout 'lf]
		desc: "Output / print a blank line to standard output."
		category: "output"
	]

	make object! [
		code: {unless block? value-or-block [value-or-block: to-block value-or-block]}
		tags: ['normalize 'standardize 'block! 'convert 'wrap 'ensure 'guard 'argument 'parameter 'flexible 'input 'validation 'coerce 'unless]
		desc: "Normalize a variable to ensure it is always a block, wrapping a single item (e.g., a `word!` or `string!`), in a block if it isn't one already."
		category: "handle-data"
	]

	make object! [
		code: {access-os 'uid}
		tags: ['access-os 'uid 'OS 'UID 'user-ID 'user 'ID 'owner 'process 'identify 'access 'retrieve 'task 'manage 'number 'active 'current 'permission 'privilege 'security 'rights]
		desc: "Retrieve the user ID (UID), of the current running process."
		category: "process-information"
	]

	make object! [
		code: {access-os 'euid}
		tags: ['access-os 'euid 'OS 'EUID 'effective 'user-ID 'user 'ID 'owner 'process 'identify 'access 'retrieve 'task 'manage 'number 'active 'current 'permission 'privilege 'security 'rights]
		desc: "Retrieve the effective user ID (euid) of the current running process."
		category: "process-information"
	]

	make object! [
		code: {access-os 'gid}
		tags: ['access-os 'OS 'gid 'GID 'group-ID 'group 'ID 'owner 'process 'identify 'access 'retrieve 'task 'manage 'number 'active 'current 'permission 'security 'rights]
		desc: "Retrieve the group ID (GID), of the current running process."
		category: "process-information"
	]

	make object! [
		code: {access-os 'egid}
		tags: ['access-os 'OS 'egid 'EGID 'effective 'group-ID 'group 'ID 'owner 'process 'identify 'access 'retrieve 'task 'manage 'number 'active 'current 'permission 'privilege 'security 'rights]
		desc: "Retrieve the effective group ID (EGID), of the current running process."
		category: "process-information"
	]

	make object! [
		code: {access-os 'pid}
		tags: ['access-os 'OS 'pid 'PID 'process-ID 'process 'ID 'owner 'task 'identify 'access 'retrieve 'manage 'number 'active 'current]
		desc: "Retrieve the process ID (PID), of the current running process."
		category: "process-information"
	]

	make object! [
		code: {access-os/set 'uid NEW-USER-ID}
		tags: ['access-os 'set 'uid 'OS 'UID 'user-ID 'user 'ID 'owner 'process 'modify 'change 'configure 'assign 'manage 'permission 'privilege 'security 'rights 'root 'sudo 'administrator 'elevated]
		desc: "Assign a new user ID (UID), to the current running process.  Requires elevated (root/administrator) permissions."
		category: "process-management"
	]

	make object! [
		code: {access-os/set 'gid NEW-GROUP-ID}
		tags: ['access-os 'set 'gid 'OS 'GID 'group-ID 'group 'ID 'owner 'process 'modify 'change 'configure 'assign 'manage 'permission 'privilege 'security 'rights 'root 'sudo 'administrator 'elevated]
		desc: "Assign a new group ID (GID), to the current running process.  Requires elevated (root/administrator) permissions."
		category: "process-management"
	]

	make object! [
		code: {access-os/set 'pid [PID-TO-TARGET 15]}
		tags: ['access-os 'set 'pid 'OS 'PID 'kill 'terminate 'stop 'end 'signal 'send 'soft-kill 'SIGTERM #15 'blockable 'graceful 'process 'task 'manage 'permission 'privilege 'security 'rights 'root 'sudo 'administrator 'elevated 'owner]
		desc: "Kill a process by sending a soft termination signal (SIGTERM / 15), to a specific Process ID (PID). Appropriate permissions based on user login required."
		category: "process-management"
	]

	make object! [
		code: {access-os/set 'pid [PID-TO-TARGET 9]}
		tags: ['access-os 'set 'pid 'OS 'PID 'kill 'terminate 'stop 'end 'signal 'send 'hard-kill 'force 'SIGKILL #9 'unblockable 'undesirable 'immediate 'process 'task 'manage 'permission 'privilege 'security 'rights 'root 'sudo 'administrator 'elevated]
		desc: "Forcibly kill a process immediately as a last resort by sending an unblockable termination signal (SIGKILL / 9), to a specific Process ID (PID).  Appropriate permissions based on user login required."
		category: "process-management"
	]

	make object! [
		code: {access-os/set 'euid NEW-EFFECTIVE-UID}
		tags: ['access-os 'set 'euid 'OS 'EUID 'effective 'user-ID 'user 'ID 'owner 'process 'modify 'change 'assign 'manage 'permission 'privilege 'security 'rights 'root 'sudo 'administrator 'elevated]
		desc: "Assign the effective user ID (EUID), of the current running process.  Used for modifying privilege levels.  Appropriate permissions based on user login required."
		category: "process-management"
	]

	make object! [
		code: {access-os/set 'egid NEW-EFFECTIVE-GID}
		tags: ['access-os 'set 'egid 'OS 'EGID 'effective 'group-ID 'group 'ID 'owner 'process 'modify 'change 'assign 'manage 'permission 'privilege 'security 'rights 'root 'sudo 'administrator 'elevated]
		desc: "Set the effective group ID (EGID), of the current running process.  Used for changing privilege levels.  Appropriate permissions based on user login required."
		category: "process-management"
	]

	make object! [
		code: {access-os/set 'pid [PID-TO-TARGET 1]}
		tags: ['access-os 'set 'pid 'OS 'PID 'signal 'send 'SIGHUP #1 'hang-up 'reload 'reconfigure 'configure 'daemon 'service 'server 'manage 'reinitialize 'administrate 'graceful]
		desc: "Send a hang-up signal (SIGHUP / 1), to a running process.  Typically used to instruct a daemon or service to gracefully reload its configuration files without downtime."
		category: "process-management"
	]

	make object! [
		code: {access-os/set 'pid [PID-TO-TARGET 2]}
		tags: ['access-os 'set 'pid 'OS 'PID 'signal 'send 'SIGINT #2 'interrupt 'stop 'terminate 'cancel 'ctrl-c 'Ctrl-c 'terminal 'console 'interactive 'manage]
		desc: "Send an interrupt signal (SIGINT / 2) to a process.  This is the programmatic equivalent of typing <Ctrl-c> in a terminal to request termination."
		category: "process-management"
	]

	make object! [
		code: {ajoin ["ABC" "DEF"]}
		tags: ['ajoin 'basic 'concatenate 'combine 'join 'simple 'string 'format 'merge 'strcat 'block!]
		desc: "Concatenate two strings into a single string.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {ajoin ["<H1>" "header text" "<\H1>"]}
		tags: ['ajoin 'basic 'concatenate 'combine 'join 'simple 'string 'format 'merge 'strcat 'HTML 'tag 'header 'block!]
		desc: "Concatenate tag strings into a single HTML header string.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {ajoin [0 " Date: " 2025-01-20  " Cost: " $4.50 " Tolerance: " 0.534]}
		tags: ['ajoin 'concatenate 'combine 'join 'mix 'datatype 'hybrid 'format 'merge 'string 'sprintf 'block!]
		desc: "Concatenate mixed datatypes into a single string.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {ajoin [1 + 2]}
		tags: ['ajoin 'reduce 'add 'math 'number 'expression 'formula 'calculate 'plus 'operator 'string 'convert 'sprintf 'block!]
		desc: "Add two numbers and output the result as a single string.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {ajoin/all ["[result> '" none "'"]}
		tags: ['ajoin 'concatenate 'combine 'join 'none! 'none 'debug 'format 'merge 'string 'sprintf 'block!]
		desc: "Concatenate output a text label to observe the `none` value as a combined string.  Any `none` values are included."
		category: "format-data"
	]

	make object! [
		code: {ajoin/with/all [1 none 2] "<|>"}
		tags: ['ajoin 'concatenate 'combine 'join 'delimiter 'separator 'none! 'none 'debug 'format 'merge 'string 'sprintf 'block!]
		desc: "Concatenate output a block to observe the `none` value as a combined string.  Any `none` values are included."
		category: "format-data"
	]

	make object! [
		code: {ajoin/with [1 2 3] "<|>"}
		tags: ['ajoin 'concatenate 'combine 'join 'delimiter 'separator 'field 'number 'format 'merge 'string 'sprintf 'block!]
		desc: "Concatenate numbers and output the result as a field delimited string.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {mold 2025-07-03}
		tags: ['mold 'convert 'transform 'date 'datatype 'to 'string 'format 'sprintf]
		desc: "Transform a date datatype to a string datatype."
		category: "format-data"
	]

	make object! [
		code: {mold 10:30}
		tags: ['mold 'convert 'transform 'time 'datatype 'to 'string 'format 'sprintf]
		desc: "Transform a time datatype to a string datatype."
		category: "format-data"
	]

	make object! [
		code: {ajoin/with ["x" "y"] reduce [tab]}
		tags: ['ajoin 'concatenate 'combine 'join 'delimiter 'separator 'field 'tab 'character 'sequence 'format 'merge 'string 'sprintf  'reduce 'block!]
		desc: "Concatenate a Rebol tab character sequence `^-`, delimited string with data fields.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {ajoin/with ["x" "y"] reduce [lf]}
		tags: ['ajoin 'concatenate 'combine 'join 'delimiter 'separator 'field 'lf 'newline 'character 'sequence 'format 'merge 'string 'sprintf  'reduce 'block!]
		desc: "Concatenate a Rebol newline character sequence `^-`, delimited string with data fields.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {either error? set/any 'tried try [ajoin [%/path/ %to/ %file]] [print :tried] [print "Success"]}
		tags: ['ajoin 'concatenate 'combine 'join 'delimiter 'separator 'field 'slash 'path 'file 'file! 'folder 'directory 'merge 'string 'sprintf  'reduce 'block!]
		desc: "Concatenate the individual components of a file path delimited by the forward slash character.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {error? set/any 'tried try [ajoin "string is an invalid input datatype, input must be a block."]}
		tags: ['ajoin 'try 'error? 'validate 'graceful ]
		desc: "Concatenate the individual components of a file path delimited by the forward slash character.  Any `none` values are excluded."
		category: "format-data"
	]

	make object! [
		code: {shy-get: funct [a-word [word!]] [if error? try [return get a-word] [return ""]]}
		tags: ['get 'try 'error? 'validate 'graceful 'safer 'shy 'unset 'word! 'string]
		desc: "A safer `get` function to gracefully handle unset Rebol words by returning an empty string instead of crashing the script."
		category: "format-data"
	]

	make object! [
		code: {to-integer #{7FFFFFFFFFFFFFFF}}
		tags: ['maximum 'signed 'integer 'value 'upper 'limit 'overflow 'number 'numeric 'ceiling 'max 'int 'integer! 'largest 'possible 'int64_t 'system 'size 'capacity 'range #9223372036854775807]
		desc: "The largest integer value possible without causing an overflow error is 9223372036854775807."
		category: "limits"
	]

	make object! [
		code: {to-integer #{8000000000000000}}
		tags: ['minimum 'signed 'integer 'value 'lower 'limit 'underflow 'number 'numeric 'floor 'min 'int 'integer! 'smallest 'possible 'int64_t 'system 'size 'capacity 'range #-9223372036854775807]
		desc: "The smallest integer value possible without causing an underflow error is -9223372036854775807."
		category: "limits"
	]

	make object! [
		code: {system/build/arch = 'x64}
		tags: ['OS 'architecture 'x64 #64 'integer 'range 'limit 'number 'numeric 'int 'integer! 'int64_t 'system 'word 'size 'capacity #9223372036854775807 #-9223372036854775807]
		desc: "Determine if the the script is running on a 64-bit operating system."
		category: "platform"
	]

    make object! [
        code: {DIGIT_CHARSET: protect charset {0123456789} protect 'DIGIT_CHARSET}
        tags: ['DIGIT_CHARSET 'charset 'digit 'character 'constant 'immutable 'read-only 'bitset 'protect 'isdigit?]
        desc: {Create an immutable constant for all standard digit characters.}
        category: "character"
    ]

	make object! [
		code: {isdigit?: funct [chr [char!]] [to-logic find/case DIGIT_CHARSET chr]}
		tags: ['isdigit? 'ask 'is 'single 'digit 'character 'charset 'charset! 'group 'type]
		desc: {Determine if a character is a digit.  Usage: `isdigit? #"1"`}
		category: "character"
	]

    make object! [
        code: {LETTER_CHARSET: protect charset {abcdefghijklmnopqrstuvwxyz} protect 'LETTER_CHARSET}
        tags: ['LETTER_CHARSET 'charset 'letter 'alphabet 'character 'constant 'immutable 'read-only 'bitset 'protect 'isalpha?]
        desc: {Create an immutable constant for all standard alphabetic letter characters.}
        category: "character"
    ]

	make object! [
		code: {isalpha?: funct [chr [char!]] [to-logic find LETTER_CHARSET chr]}
		tags: ['isalpha? 'ask 'is 'single 'alphabet 'letter 'case 'insensitive 'character 'group 'type 'LETTER_CHARSET]
		desc: {Determine if a character is an alphabetic letter.  Usage: `isalpha? #"a"`}
		category: "character"
	]

	make object! [
		code: {islower?: funct [chr [char!]] [to-logic find/case LETTER_CHARSET chr]}
		tags: ['islower? 'ask 'is 'single 'alphabet 'letter 'lower 'case 'lowercase 'sensitive 'character 'group 'type 'LETTER_CHARSET]
		desc: {Determine if a character is a lowercase alphabetic letter.  Usage: `islower? #"a"`}
		category: "character"
	]

    make object! [
        code: {PUNCT_CHARSET: protect charset {~`!@#$%&*()_+-={}[]|\:;'<>?,./^^"} protect 'PUNCT_CHARSET}
        tags: ['charset 'punctuation 'characters 'constant 'immutable 'read-only 'bitset 'protect 'ispunct? 'PUNCT_CHARSET]
        desc: {Create an immutable constant for all standard punctuation characters.}
        category: "character"
    ]

	make object! [
		code: {ispunct?: funct [chr [char!]] [to-logic find/case PUNCT_CHARSET chr]}
		tags: ['ispunct? 'ask 'is 'single 'punctuation 'charset 'charset! 'symbol 'character 'group 'type 'PUNCT_CHARSET]
		desc: "Determine if a character is a punctuation symbol. Usage: `ispunct? #";"`"
		category: "character"
	]

	make object! [
		code: {obj-has-word?: funct [an-obj [object!] a-word [word!]][return not none! find words-of an-obj a-word]}
		tags: ['object 'ask 'has 'exist 'Rebol 'word 'symbol 'validate 'function 'find 'words-of]
		desc: "Validate if a Rebol word exists in an object"
		category: "object"
	]
]

;print rejoin ["Success Rate: " round/to (pass-count * 100.0) / test-count 0.1 "%"]

comment {
    category: "character"
    category: "convert"
    category: "format-data"
    category: "handle-data"
    category: "header"
    category: "limits"
    category: "object"
    category: "output"
    category: "platform"
    category: "process-information"
    category: "process-management"
    category: "search"
    category: "security"
    category: "specification"
    category: "status"
    category: "string"
}

;;-----------------------------------------------------------------------------
;; Enhanced Search Functions
;;-----------------------------------------------------------------------------
match-snippets-any: function [
    {Match code snippets (lettercase sensitive), with ANY of the user's search tags (OR logic).}
    kdb [block!] "The loaded snippet knowledgebase."
    a-query [word! block!] "A single tag or block of tags to match."
][
	;; Let the function caller provide either a single tag (as a `word!`), or multiple tags as a block.
	;; Acts as a normalizer to ensure no matter which format the user provides, the rest of the
	;; function's logic can operate on the assumption that `a-query` is always a block.
	matches: copy []
	unless block? a-query [a-query: to-block a-query]

	foreach snippet kdb [
		if not empty? intersect/case a-query snippet/tags [
			append matches snippet
		]
	]

	return matches
]

;;----------------------------------------------------------
match-snippets-all: function [
    {Match code snippets (lettercase sensitive), with ALL of the user's search tags (AND logic).}
    kdb [block!] "The loaded snippet knowledgebase."
    a-query [word! block!] "A single tag or block of tags to match."
][
	;; Let the function caller provide either a single tag (as a `word!`), or multiple tags as a block.
	;; Acts as a normalizer to ensure no matter which format the user provides, the rest of the
	;; function's logic can operate on the assumption that `a-query` is always a block.
	matches: copy []
	unless block? a-query [a-query: to-block a-query]

	foreach snippet kdb [
		if (length? a-query) = (length? intersect/case a-query snippet/tags) [
			append matches snippet
		]
	]

	return matches
]

;;----------------------------------------------------------
match-snippets-category: function [
    {Match code snippets by category.}
    kdb [block!] "The loaded code snippets knowledgebase."
    category [string!] "The category to search for."
][
	matches: copy []

	foreach snippet kdb [
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
    {Match code snippets having text in the code or description (case-insensitive).}
    kdb [block!] "The loaded code snippets knowledgebase."
    search-text [string!] "Text to search for."
][
	matches: copy []

	foreach snippet kdb [
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
    kdb [block!] "The loaded code snippets knowledgebase."
][
	print "^/=== Rebol Snippet Search Interface ==="
	print "Commands:"
	print {  any [tag1 tag2 #num]  - Find snippets with ANY of these tags.}
	print {  all [tag1 tag2 #num]  - Find snippets with ALL of these tags.}
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

		if none? input [input: []]		;; Make a `none` type input an empty block.

		;; Convert `find` result to Boolean by checking if it's `not none`:
		if (word? input) and (not none? find [quit q bye exit] input) [quit/return 0]

		if not block? input [input: reduce [input]]	;; convert the various datatypes made by `load` into a block.
		if empty? input [continue]

		command: input/1

		case [
			command = 'help [
					print "^/Commands:"
					print {  any [tag1 tag2 #num] - Find snippets with ANY of these tags.}
					print {  all [tag1 tag2 #num] - Find snippets with ALL of these tags.}
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

					matches: match-snippets-any kdb input/2
					output-matches matches 1000
			]

			command = 'all [
					if any [(length? input) < 2 not block? input/2] [
						print "Usage: all [tag1 tag2 ...]"
						continue
					]

					matches: match-snippets-all kdb input/2
					output-matches matches 1000
			]

			command = 'cat [
					if any [(length? input) < 2 not string? input/2] [
						print "Usage: cat ""category-name"""
						continue
					]

					matches: match-snippets-category kdb input/2
					output-matches matches 1000
			]

			command = 'text [
					if any [(length? input) < 2 not string? input/2] [
						print "Usage: text ""search-phrase"""
						continue
					]

					matches: match-snippets-text kdb input/2
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
