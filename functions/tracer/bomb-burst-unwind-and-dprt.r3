REBOL [
   Title: "Reusable Rebol 3 Error Handling Function Call Tracer"
   Date: 30-Jun-2025
   File: %bomb-burst-unwind-and-dprt.r3
   Version: 0.2.0
   Author: "team effort"
   Purpose: "Rebol 3 Oldes Error Handling Routines using detailed error objects and throw / catch methodology."
]

;; 0 = no debug output, 1 = success overview only, 2 = full debug output:
gblBlkTypCfgDbgPrt: object [dvue: 2]

;; Determine if all debugging output is disabled:
dvue0?: does [gblBlkTypCfgDbgPrt/dvue = 0]

;; Suppress all debugging output:
mkdvue0: does [gblBlkTypCfgDbgPrt/dvue: 0]

;; Determine if SuccessMsg summary overview output is enabled:
dvue1?: does [gblBlkTypCfgDbgPrt/dvue = 1]

;; Enable SuccessMsg summary overview output:
mkdvue1: does [gblBlkTypCfgDbgPrt/dvue: 1]

;; Determine if dprt "DEBUG: " output is enabled:
dvue2?: does [gblBlkTypCfgDbgPrt/dvue = 2]

;; Enable dprt "DEBUG: " output:
mkdvue2: does [gblBlkTypCfgDbgPrt/dvue: 2]

;; Output DEBUG lines when enabled (no ANSI color support):
;; Hey: Using the "^/" newline indicator in a string causes `dprt` to print the undesirable solo "DEBUG: " line.
;;      Use `dprt lf`  before a debug line that has content to output empty / blank lines.
dprt: function [
    any-dtype [any-type!]
    /nln "Output an extra newline character at the end of the output."
    /quoted "Surround debug output with single quotes to see leading and trailing whitespace."
][
    if dvue2? [
        d-label: "DEBUG: "
        can-use-empty?: false
        the-dtype: type? any-dtype
        output-debug-labeled-line: false

        ;; `empty!` bombs on the datatypes below:
        switch the-dtype [
            #(block!) [can-use-empty?: true]
            #(object!) [can-use-empty?: true]
            #(map!) [can-use-empty?: true]
            #(typeset!) [can-use-empty?: true]
            #(port!) [can-use-empty?: true]
            #(bitset!) [can-use-empty?: true]
            #(vector!) [can-use-empty?: true]
            #(gob!) [can-use-empty?: true]
        ]

        ;; prevent `empty?` from bombing on an unacceptable datatype:
        either can-use-empty? == true [
            either empty? any-dtype [
                prin lf			;; Do not output the "DEBUG: " line prefix for empty strings.
            ][
                output-debug-labeled-line: true
            ]
        ][
            either the-dtype == #(char!) [
                either any-dtype = lf [
                    print any-dtype     ;; lets you use `dprt lf` without printing a "DEBUG: " prefix.
                ][
                    output-debug-labeled-line: true
                ]
            ][
                output-debug-labeled-line: true
            ]
        ]

        if output-debug-labeled-line == true [
            prin d-label

            either quoted [print rejoin ["'" any-dtype "'"]][print any-dtype]
        ]

        if nln [prin lf]
    ]
]

ErrMsg: function [
	{Output a noticeable error message to stdout on a bright red background with bright white text.}
   any-dtype [any-type!]
   /nln
	/blank
	/fatal
	/plain
	/thrown
][
    strRect: ">>> ERROR <<<"

    case [
        blank [strRect: "             " ]
        fatal [strRect: ">>> FATAL <<<"]
        thrown [strRect: ">>> THROW <<<"]
    ]

    either plain [print rejoin [strRect " " any-dtype]][ print rejoin ["^[[97;101m" strRect "^[[0m" " " any-dtype]]

    if nln [prin lf]
]

SuccessMsg: function [
	{Output a noticeable success message on a bright green background.}
   any-dtype [any-type!]
   /nln
	/blank
	/dvue
	/plain
][
	strRect: ">> SUCCESS <<"

	if blank [ strRect: "             " ]

	bitPrt: false

	either dvue [
		if any [dvue1? dvue2?][bitPrt: true]
	][
		bitPrt: true
	]

    if bitPrt [
        either plain [print rejoin [strRect " " any-dtype]][print rejoin ["^[[96m" strRect "^[[0m" " " any-dtype]]

		if nln [prin lf]
	]
]

gblObjWarnCfg: make object! [
	disabled: false	;; Disable all warning checks globally.
	reason: none
	desc: none
	caller: none
]

ClrGblObjWarnForTypFncRng: does [
	;; Reset all global values to `none`:
	gblObjWarnCfg/reason: none
	gblObjWarnCfg/desc: none
	gblObjWarnCfg/caller: none
]

AllFncRft_Blk: function [
    {Return a block of the function's description and all declared refinements.}
    ptrFncThs [function!]
][
	;; Access the internal structure of the function:
	func_specs: spec-of :ptrFncThs

	;; Initialize an empty block to hold any function refinements:
	blkRtnFno: copy []
	intTypCntDox: 0		;; Get only the 1st Dox Lne For The Fnc.

	;; Loop thru the func_specs to get the function's refinements:
	foreach perItm func_specs [
		either refinement? perItm [
			append blkRtnFno perItm
		][
			if string? perItm [
				if 0 == intTypCntDox [
					gblObjWarnCfg/desc: perItm		;; Add the function's description.
					intTypCntDox: intTypCntDox + 1
				]
			]
		]

		comment {	;; HOW_TO: Get the data types for function arguments via a function pointer.
			if block? perItm [
				print rejoin ["Blk/TypArg: " perItm]
			]

			;; HOW_TO: Get the variable names used inside a function via a function pointer.
			if word? perItm [
				print rejoin ["Wrd/VarNme: " perItm]
			]
		}
	]

    return blkRtnFno
]

;; e.g. #1#
;; strFncGobSum: FabPerFncGob_Str "Snip" :ptrFncThs
FabPerFncGob_Str: function [
	{Combine a function's name it's current call refinements into a string.}
	strTypNmeFnc [string!]
	ptrFncThs [function!]
][
	blkTmp: sort AllFncRft_Blk :ptrFncThs
	remove find blkTmp /local	;; HOW_TO: Rmv a Fnc refinement from a Rebol block object (JusThe1stHit).

	either empty? blkTmp [
		return strTypNmeFnc
	][
		strTmp: to-string ajoin [blkTmp]
		insert strTmp #"/"
		replace strTmp #" " #"/"
		return join strTypNmeFnc strTmp
	]
]

;; e.g. #1# SeeNmeFnc `Snip` and `SpinAll`.
WarnForTypFncRng: function [
	strTypNmeFnc [string!]
	ptrFncThs [function!]
	aryFoo [series! none!]
	strTheArgNme [string!]
	intTypAmtRng [integer!]
	strThsRblScrFleNme [file! string!]
][
	if true == gblObjWarnCfg/disabled [return]

	strFncGobSum: FabPerFncGob_Str strTypNmeFnc :ptrFncThs
	WarnMsg rejoin ["Reason: " gblObjWarnCfg/reason]
	WarnMsg/blank rejoin ["Called: '" strFncGobSum "'"]
	WarnMsg/blank rejoin ["FnDesc: '" ellipsize gblObjWarnCfg/desc 70 "'"]
	WarnMsg/blank rejoin ["Script: '" strThsRblScrFleNme "'"]
	WarnMsg/blank rejoin ["Caller: '" system/options/script "'"]
	WarnMsg/blank rejoin ["Range: " intTypAmtRng]
	WarnMsg/blank rejoin ["Target's name: '" strTheArgNme "'"]
	WarnMsg/blank rejoin ["Target's data type: " type? aryFoo]

	if not none? aryFoo [	;; Only output target's length and data value if aryFoo is not `none`.
		intLenAryAim: length? aryFoo

		either (0 == intLenAryAim) [
			WarnMsg/blank rejoin ["Target's length: " intLenAryAim]		;; 2nd confirmation target is empty.
		][
			WarnMsg/blank rejoin ["Target's length: " intLenAryAim]
			WarnMsg/blank rejoin ["Target's data: '" ellipsize to-string aryFoo 70 "'"]
		]
	]

	ClrGblObjWarnForTypFncRng	;; Reset all global object values to `none`.
]

;; e.g. #1# SeeNmeFnc `Str_BlkPerChrPerItm`.
WarnForDryOreNulFncArgStr: function [
	strTypNmeFnc [string!]
	ptrFncThs [function!]
	anyChkThsArg [bitset! series! none!]
	strTheArgNme [string!]
	strThsRblScrFleNme [file! string!]
][
	if true == gblObjWarnCfg/disabled [return]

	case [
		(none? anyChkThsArg) [gblObjWarnCfg/reason: 'target-type_none]
		(0 == (length? anyChkThsArg)) [gblObjWarnCfg/reason: 'empty_source]
	]

	if not none? gblObjWarnCfg/reason [
		strFncGobSum: FabPerFncGob_Str strTypNmeFnc :ptrFncThs
		WarnMsg rejoin ["Reason: " gblObjWarnCfg/reason]
		WarnMsg/blank rejoin ["Called: '" strFncGobSum "'"]
		WarnMsg/blank rejoin ["FnDesc: '" ellipsize gblObjWarnCfg/desc 70 "'"]
		WarnMsg/blank rejoin ["Script: '" strThsRblScrFleNme "'"]
		WarnMsg/blank rejoin ["Caller: '" system/options/script "'"]
		WarnMsg/blank rejoin ["Target's name: '" strTheArgNme "'"]
		WarnMsg/blank rejoin ["Target's data type: " type? anyChkThsArg]

		if not none? anyChkThsArg [	;; Only output target's length and data value if anyChkThsArg is not `none`.
			intLenAryAim: length? anyChkThsArg

			either (0 == intLenAryAim) [
				WarnMsg/blank rejoin ["Target's length: " intLenAryAim]		;; 2nd confirmation target is empty.
			][
				WarnMsg/blank rejoin ["Target's length: " intLenAryAim]
			]
		]

		ClrGblObjWarnForTypFncRng	;; Reset all global object values to `none`.
	]
]

WarnMsg: function [
	{Output a noticeable yellow warning message to stdout.}
   any-dtype [any-type!]
	/blank
	/plain
	/nln
][
	strRect: ">> WARNING <<"

	if blank [ strRect: "             " ]

	either plain print rejoin [strRect " " any-dtype][][print rejoin ["^[[38;2;255;205;40m" strRect "^[[0m" " " any-dtype]]

	if nln [prin lf]
]

comment {
	'message: A general message (often used with 'user type).

	Error types and IDs are not arbitrarily combinable.
	Each error type has a specific set of valid IDs.
   These 'words are known as "literal words (lit-word!), in Rebol (think enum type).

	Here's a comprehensive list of valid type/ID combinations:

	For type: 'access the valid IDs are:
		'cannot-open, 'not-open, 'already-open, 'invalid-spec, 'no-script,
      'no-connect, 'not-connected, 'no-scheme-name,
		'no-scheme, 'bad-scheme, 'invalid-port, 'invalid-actor, 'bad-port-action, 'bad-port-arg,
		'no-port-action, 'expect-actor, 'check-failed, 'protocol, 'shield-protection, 'policy-protection

	For type: 'command the valid IDs are: 'no-arg, 'expect-arg, 'invalid-arg

	For type: 'math the valid IDs are: 'zero-divide, 'overflow, 'positive

	For type: 'note the valid IDs are: 'no-load, 'no-save, 'not-done

	For type: 'script the valid IDs are:
		'invalid-arg, 'no-value, 'invalid-data, 'out-of-range, invalid-type, 'past-end
      'size-limit, 'invalid-op, 'bad-path-set, 'not-in-context, 'bad-bad,
      'need-value, 'invalid-path, 'not-defined,
		'no-arg, 'expect-arg, 'expect-val, 'invalid-type-spec,
		'no-op-arg, 'not-same-type, 'not-same-class, 'not-related, 'bad-func-def, 'bad-func-arg,
      'bad-func-extern, 'no-refine, 'bad-refines, 'bad-refine,
		'bad-path-type, 'bad-field-set, 'dup-vars, 'missing-arg,
		'invalid-chars, 'invalid-compare, 'wrong-type, 'invalid-part, 'type-limit,
		'no-return, 'throw-usage, 'locked-word, 'protected, 'hidden, 'self-protected, 'bad-make-arg,
		'bad-decode, 'already-used, 'wrong-denom, 'bad-denom, 'invalid-obj, 'no-cycle, 'bad-sync, 'bad-compose,
		'bad-path-paren

	For type: 'internal the valid IDs are: 'bad-path, 'not-here, 'no-memory, 'stack-overflow, 'globals-full,
		'max-natives, 'bad-series, 'limit-hit, 'bad-sys-func, 'feature-na, 'not-done, 'invalid-error,
		'bad-eval-spec, 'bad-index, 'invalid-data-facet, 'busy-data, 'already-stopped
}

;; Usage example: throw ArgBomb 'no-value ["TheFncNme" "strHay"] "TisDry" {""} "1st"
;; SeeToo: `BombBurst_RunQac_1`
ArgBomb: function [
   {Fabricate a custom function parameter error object with detailed error information.}
	wrdTypIduErr [word!]
   strTypNmeFnc [block! string!]
   strTypNmeArgForFnc [string!]
   strArgVal [string!]
   strTypCueArg [string!]
][
   make error! [
      type: 'script              ;; restricted to predefined definitions only (see the table above).
      id: wrdTypIduErr           ;; restricted to predefined definitions only (see the table above).
      arg1: strTypNmeArgForFnc   ;; free-form field.
      arg2: strArgVal            ;; free-form field.
      arg3: strTypCueArg         ;; free-form field.
      near: strTypNmeFnc         ;; free-form field.
      where: now                 ;; free-form field.
   ]
]

;; Similar to `disarm` functionality in other Rebol platform versions:
;; SeeToo: `BombBurst_RunQac_1`
ArgBurst: function [
   {Output detailed information within an error object to stdout.}
   errObject [error!]
][
   ErrMsg/thrown rejoin ["Type: " errObject/type]
	ErrMsg rejoin ["ID: " errObject/id]
	ErrMsg/blank rejoin ["Why: " errObject/arg1]
   ErrMsg/blank rejoin ["WhcArg: " errObject/arg3]
   ErrMsg/blank rejoin ["Flow: " errObject/near]
	ErrMsg/blank rejoin ["When: " errObject/where]
]

;; Usage example: throw CmdBomb 'invalid-arg ["TheCmdNme" "strCmd"] "Command not found." {""} "1st"
CmdBomb: function [
   {Fabricate a custom command failure error object with detailed error information.}
	wrdTypIduErr [word!]
   strTypNmeCmd [block! string!]
   strTypNmeArgForCmd [string!]
   strArgVal [string!]
   strTypCueArg [string!]
][
   make error! [
      type: 'command             ;; restricted to predefined definitions only (see the table above).
      id: wrdTypIduErr           ;; restricted to predefined definitions only (see the table above).
      arg1: strTypNmeArgForCmd   ;; free-form field.
      arg2: strArgVal            ;; free-form field.
      arg3: strTypCueArg         ;; free-form field.
      near: strTypNmeCmd         ;; free-form field.
      where: now                 ;; free-form field.
   ]
]

CmdBurst: function [
   {Output detailed information within an error object to stdout.}
   errObject [error!]
][
   ErrMsg rejoin ["Type: " errObject/type]
	ErrMsg/blank rejoin ["ID: " errObject/id]
	ErrMsg/blank rejoin ["Why: " errObject/arg1]
   ErrMsg/blank rejoin ["WhcArg: " errObject/arg3]
   ErrMsg/blank rejoin ["Flow: " errObject/near]
	ErrMsgl/blank/nln rejoin ["When: " errObject/where]
]

FncSimCall_2: function [
   {Throw an error if the input string is empty.}
   strInp [string! none!]
][
   dprt "Entering FncSimCall_2."

   ;; the `if none?` must be put before the `if empty?` because `if empty?` returns `true` for `none`:
   if none? strInp [
      dprt "FUNCTION ARGUMENT EXCEPTION ERROR DETECTED: Throwing error..."
      throw ArgBomb 'need-value ["FncSimCall_2" "strInp"] "TisNul" {""} "1st"
   ]

   if empty? strInp [
      dprt "FUNCTION ARGUMENT EXCEPTION ERROR DETECTED: Throwing error..."
      throw ArgBomb 'no-value ["FncSimCall_2" "strInp"] "TisDry" {""} "1st"
   ]

   dprt "✅ Input string is populated (no error)."
   result: strInp
   dprt "Leaving FncSimCall_2."
   return result
]

FncSimCall_1: function [
   {Call FncSimCall_2 and handle / rethrow potential errors.}
   strInp [string! none!]
][
   dprt "Entering FncSimCall_1."

   theResult: catch [
      return FncSimCall_2 strInp
   ]

   if error? theResult [
      dprt "Error caught in FncSimCall_1.  Rethrowing..."
      theResult/near: rejoin [theResult/near " <- FncSimCall_1"]	;; Update the Fnc call tracing Err Fld.
      throw theResult
   ]

   dprt "Leaving FncSimCall_1."
]

BombBurst_RunQac_1: does [
    dprt "--- Running BombBurst_RunQac_1 exception handling simulation ---"
    strInp: ""
    theResult: catch [FncSimCall_1 strInp]

    either error? theResult [ArgBurst theResult][
        dprt "✅ Processing completed successfully (no errors)."
        dprt mold theResult
    ]

    dprt/quoted "Leaving BombBurst_RunQac_1."
]

BombBurst_RunQac_2: does [
    dprt lf
    dprt "--- Running BombBurst_RunQac_2 exception handling simulation ---"

    theResult: catch [FncSimCall_1 none]

    either error? theResult [ArgBurst theResult][
        dprt "✅ Processing completed successfully (no errors)."
        dprt mold theResult
    ]

    dprt/quoted "Leaving BombBurst_RunQac_2."
]


BombBurst_RunQac_3: does [
    dprt lf
    dprt "--- Running BombBurst_RunQac_3 exception handling simulation ---"

    strInp: " "
    theResult: catch [FncSimCall_1 strInp]

    either error? theResult [ArgBurst theResult][
        dprt "✅ Processing completed successfully (no errors)."
        dprt mold theResult
    ]

    dprt/quoted "Leaving BombBurst_RunQac_3."
]

;;; QA Test Run for thrown exceptions function stack trace:
BombBurst_RunQac_1
BombBurst_RunQac_2
BombBurst_RunQac_3
