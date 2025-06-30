Rebol []

;; Purpose: Explore Rebol 3 Oldes System Objects and Words
;; Output all the Rebol words defined in the Rebol system object.
;; Purpose: Understand the built-in and native functions, variables and attributes.
print dump-obj/not-none system

print system/options/args
;; Returns: A block of command-line arguments or `none` if no args. Use for script parameterization.
;; Example Output (illustrative): ["input.txt" "--verbose"] or `none`

;; Rebol 3 Oldes detailed build info (OS, arch, compiler, date, git hash).
print system/build/os
;; Example Output (illustrative): ubuntu

print system/build/os-version
;; Example Output (illustrative): 20.04

print system/build/abi
;; Example Output (illustrative): elf

print system/build/sys
;; Example Output (illustrative): linux

print system/build/arch
;; Example Output (illustrative): x64

print system/build/libc
;; Example Output (illustrative): glibc_2.31

print system/build/target
;; Example Output: x64-pc-linux-elf

print system/build/vendor
;; Example Output (illustrative): pc

print system/build/date
;; Example Output (illustrative): 11-Apr-2025/11:19

print "^/--- Identify available Rebol actions ---"
print mold system/catalog/actions
;; Example Output (illustrative): [add subtract multiply divide remainder power and~ or~ xor~ negate complement absolute round random odd? even? head tail head? tail? past? next back skip at atz index? indexz? length? pick find select reflect make to copy take put insert append remove change poke clear trim swap reverse sort create delete open close read write open? query modify update rename flush]
help action!
help action?

;; Iterate the actions and print each word as a string:
;; The "actions" block has unbound words (symbols without context).
;; Direct printing tries to evaluate them, causing ** Script error: add word is not bound to a context.
;; `mold` or `form` bypasses evaluation by working on the literal names of the Rebol words.
print "^/--- foreach action system/catalog/actions ---"
foreach action system/catalog/actions [print form action]

;; Output all the Rebol 3 words defined in the system contexts (VERY LONG OUTPUT).
;; Contexts are namespaces to help organize variables and functions.
;; Understanding contexts is key for managing scope and preventing name collisions.
;print words-of system/contexts
print "^/--- dump-obj/not-none system/contexts ---"
print dump-obj/not-none system/contexts

print "^/--- dump-obj system/contexts/lib ---"
print dump-obj system/contexts/lib

print "^/--- dump-obj system/contexts/sys ---"
print dump-obj system/contexts/sys

print "^/--- dump-obj system/contexts/user ---"
print dump-obj system/contexts/user

print "^/--- dump-obj system/modules ---"
print dump-obj system/modules

print "^/--- dump-obj system/state/last-error ---"
print system/state/last-error

print "^/--- form system/state/last-result ---"
probe system/state/last-result
print form system/state/last-result

print "^/--- mold system/state/last-result ---"
print mold system/state/last-result

print "^/--- dump-obj system/catalog/errors ---"
print dump-obj system/catalog/errors
comment {
  Throw           object!    [code type break return throw continue ha...
  Note            object!    [code type no-load exited deprecated]
  Syntax          object!    [code type invalid missing no-header bad-...
  Script          object!    [code type no-value need-value not-define...
  Math            object!    [code type zero-divide overflow positive]
  Access          object!    [code type cannot-open not-open already-o...
  Command         object!    [code type command-fail]
  resv700         object!    [code type]
  User            object!    [code type message]
  Internal        object!    [code type bad-path not-here no-memory st...
}

print "^/--- dump-obj system/catalog/errors/Throw ---"
print dump-obj system/catalog/errors/Throw
comment {
  code            integer!   0
  type            string!    "throw error"
  break           string!    "no loop to break"
  return          string!    "return or exit not in function"
  throw           block!     length: 4 ["no catch for throw:" :arg2 "w...
  continue        string!    "no loop to continue"
  halt            block!     length: 1 ["halted by user or script"]
  quit            block!     length: 1 ["user script quit"]
}

print "^/--- dump-obj system/catalog/errors/Note ---"
print dump-obj system/catalog/errors/Note
comment {
  code            integer!   100
  type            string!    "note"
  no-load         block!     length: 2 ["cannot load: " :arg1]
  exited          block!     length: 1 ["exit occurred"]
  deprecated      string!    "deprecated function not allowed"
}

print "^/--- dump-obj system/catalog/errors/Syntax ---"
print dump-obj system/catalog/errors/Syntax
comment {
  code            integer!   200
  type            string!    "syntax error"
  invalid         block!     length: 4 ["invalid" :arg1 "--" :arg2]
  missing         block!     length: 4 ["missing" :arg2 "at" :arg1]
  no-header       block!     length: 2 ["script is missing a REBOL hea...
  bad-header      block!     length: 2 ["script header is not valid:" ...
  bad-checksum    block!     length: 2 ["script checksum failed:" :arg1]
  malconstruct    block!     length: 2 ["invalid construction spec:" :...
  bad-char        block!     length: 2 ["invalid character in:" :arg1]
  needs           block!     length: 4 ["this script needs" :arg1 :arg...
}

print "^/--- dump-obj system/catalog/errors/Script ---"
print dump-obj system/catalog/errors/Script
comment {
  code            integer!   300
  type            string!    "script error"
  no-value        block!     length: 2 [:arg1 "has no value"]
  need-value      block!     length: 2 [:arg1 "needs a value"]
  not-defined     block!     length: 2 [:arg1 "word is not bound to a ...
  not-in-context  block!     length: 2 [:arg1 "is not in the specified...
  no-arg          block!     length: 4 [:arg1 "is missing its" :arg2 "...
  expect-arg      block!     length: 6 [:arg1 "does not allow" :arg3 "...
  expect-val      block!     length: 4 ["expected" :arg1 "not" :arg2]
  expect-type     block!     length: 4 [:arg1 :arg2 "field must be of ...
  cannot-use      block!     length: 5 ["cannot use" :arg1 "on" :arg2 ...
  invalid-arg     block!     length: 2 ["invalid argument:" :arg1]
  invalid-type    block!     length: 2 [:arg1 "type is not allowed here"]
  invalid-op      block!     length: 2 ["invalid operator:" :arg1]
  no-op-arg       block!     length: 2 [:arg1 "operator is missing an ...
  invalid-data    block!     length: 2 ["data not in correct format:" ...
  not-same-type   string!    "values must be of the same type"
  not-same-class  block!     length: 4 ["cannot coerce" :arg1 "to" :arg2]
  not-related     block!     length: 4 ["incompatible argument for" :a...
  bad-func-def    block!     length: 2 ["invalid function definition:"...
  bad-func-arg    block!     length: 3 ["function argument" :arg1 "is ...
  no-refine       block!     length: 3 [:arg1 "has no refinement calle...
  bad-refines     string!    "incompatible or invalid refinements"
  bad-refine      block!     length: 2 ["incompatible refinement:" :arg1]
  invalid-path    block!     length: 4 ["cannot access" :arg2 "in path...
  bad-path-type   block!     length: 5 ["path" :arg1 "is not valid for...
  bad-path-set    block!     length: 4 ["cannot set" :arg2 "in path" :...
  bad-field-set   block!     length: 5 ["cannot set" :arg1 "field to" ...
  dup-vars        block!     length: 2 ["duplicate variable specified:...
  past-end        string!    "out of range or past end"
  missing-arg     string!    "missing a required argument or refinement"
  out-of-range    block!     length: 2 ["value out of range:" :arg1]
  too-short       string!    "content too short (or just whitespace)"
  too-long        string!    "content too long"
  invalid-chars   string!    "contains invalid characters"
  invalid-compare block!     length: 4 ["cannot compare" :arg1 "with" ...
  assert-failed   block!     length: 2 ["assertion failed for:" :arg1]
  wrong-type      block!     length: 2 ["datatype assertion failed for...
  invalid-part    block!     length: 2 ["invalid /part count:" :arg1]
  type-limit      block!     length: 2 [:arg1 "overflow/underflow"]
  size-limit      block!     length: 2 ["maximum limit reached:" :arg1]
  no-return       string!    "block did not return a value"
  block-lines     string!    "expected block of lines"
  throw-usage     string!    "invalid use of a thrown error value"
  locked-word     block!     length: 2 ["protected variable - cannot m...
  protected       string!    "protected value or series - cannot modify"
  hidden          string!    "not allowed - would expose or modify hid...
  self-protected  string!    "cannot set/unset self - it is protected"
  bad-bad         block!     length: 3 [:arg1 "error:" :arg2]
  bad-make-arg    block!     length: 4 ["cannot MAKE" :arg1 "from:" :a...
  bad-decode      string!    "missing or unsupported encoding marker"
  already-used    block!     length: 2 ["alias word is already in use:...
  wrong-denom     block!     length: 3 [:arg1 "not same denomination a...
  bad-press       block!     length: 2 ["invalid compressed data - pro...
  dialect         block!     length: 4 ["incorrect" :arg1 "dialect usa...
  bad-command     string!    "invalid command format (extension functi...
  parse-rule      block!     length: 2 ["PARSE - invalid rule or usage...
  parse-end       block!     length: 2 ["PARSE - unexpected end of rul...
  parse-variable  block!     length: 2 ["PARSE - expected a variable, ...
  parse-command   block!     length: 2 ["PARSE - command cannot be use...
  parse-series    block!     length: 2 ["PARSE - input must be a serie...
  parse-no-collect string!    "PARSE - KEEP is used without a wrapping ...
  parse-into-bad  string!    "PARSE - COLLECT INTO/AFTER expects a ser...
  parse-into-type string!    "PARSE - COLLECT INTO/AFTER expects a ser...
  invalid-handle  string!    "invalid handle"
  invalid-value-for block!     length: 4 ["invalid value" :arg1 "for:" :...
  handle-exists   block!     length: 3 ["handle already exists under i...
}

print "^/--- dump-obj system/catalog/errors/Access ---"
print dump-obj system/catalog/errors/Access
comment {
  code            integer!   500
  type            string!    "access error"
  cannot-open     block!     length: 4 ["cannot open:" :arg1 "reason:"...
  not-open        block!     length: 2 ["port is not open:" :arg1]
  already-open    block!     length: 2 ["port is already open:" :arg1]
  no-connect      block!     length: 4 ["cannot connect:" :arg1 "reaso...
  not-connected   block!     length: 2 ["port is not connected:" :arg1]
  not-ready       block!     length: 2 ["port is not ready:" :arg1]
  no-script       block!     length: 2 ["script not found:" :arg1]
  no-scheme-name  block!     length: 2 ["new scheme must have a name:"...
  no-scheme       block!     length: 2 ["missing port scheme:" :arg1]
  invalid-spec    block!     length: 2 ["invalid spec or options:" :arg1]
  invalid-port    block!     length: 1 ["invalid port object (invalid ...
  invalid-actor   block!     length: 1 ["invalid port actor (must be n...
  invalid-port-arg block!     length: 2 ["invalid port argument:" arg1]
  no-port-action  block!     length: 2 ["this port does not support:" ...
  protocol        block!     length: 2 ["protocol error:" :arg1]
  invalid-check   block!     length: 2 ["invalid checksum (tampered fi...
  write-error     block!     length: 4 ["write failed:" :arg1 "reason:...
  read-error      block!     length: 4 ["read failed:" :arg1 "reason:"...
  read-only       block!     length: 2 ["read-only - write not allowed...
  no-buffer       block!     length: 2 ["port has no data buffer:" :arg1]
  timeout         block!     length: 2 ["port action timed out:" :arg1]
  cannot-close    block!     length: 4 ["cannot close port" :arg1 "rea...
  no-create       block!     length: 2 ["cannot create:" :arg1]
  no-delete       block!     length: 2 ["cannot delete:" :arg1]
  no-rename       block!     length: 2 ["cannot rename:" :arg1]
  bad-file-path   block!     length: 2 ["bad file path:" :arg1]
  bad-file-mode   block!     length: 2 ["bad file mode:" :arg1]
  security        block!     length: 3 ["security violation:" :arg1 " ...
  security-level  block!     length: 2 ["attempt to lower security to"...
  security-error  block!     length: 4 ["invalid" :arg1 "security poli...
  no-codec        block!     length: 2 ["cannot decode or encode (no c...
  bad-media       block!     length: 1 ["bad media data (corrupt image...
  no-extension    block!     length: 4 ["cannot open extension:" :arg1...
  bad-extension   block!     length: 2 ["invalid extension format:" :a...
  extension-init  block!     length: 2 ["extension cannot be initializ...
  call-fail       block!     length: 2 ["external process failed:" :arg1]
  permission-denied block!     length: 1 ["permission denied"]
  process-not-found block!     length: 2 ["process not found:" :arg1]
}

print "^/--- system/locale/months ---"
print system/locale/months
;; Output: January February March April May June July August September October November December

print dump-obj system/schemes
comment {
  system          object!    [name title spec info actor awake init]
  console         object!    [name title spec info actor awake]
  callback        object!    [name title spec info actor awake]
  file            object!    [name title spec info actor awake init]
  dir             object!    [name title spec info actor awake init]
  event           object!    [name title spec info actor awake]
  dns             object!    [name title spec info actor awake]
  tcp             object!    [name title spec info actor awake]
  udp             object!    [name title spec info actor awake]
  checksum        object!    [name title spec info actor awake init]
  crypt           object!    [name title spec info actor awake init]
  clipboard       object!    [name title spec info actor awake]
  serial          object!    [name title spec info actor awake init]
  safe            object!    [name title spec info actor awake]
  tls             object!    [name title spec info actor awake set-ver...
  smtp            object!    [name title spec info actor awake]
  smtps           object!    [name title spec info actor awake]
  http            object!    [name title spec info actor awake headers]
  https           object!    [name title spec info actor awake headers]
  whois           object!    [name title spec info actor awake]
}

;; Output all available options in the Rebol 3 system object.
;; System options control various settings and behaviors of the REBOL 3 environment.
;; Useful for developers to customize their REBOL experience.
print "^/--- dump-obj/not-none system/options ---"
print dump-obj/not-none system/options

;; Output the path to the REBOL interpreter binary executable:
;; The complete path to the running Rebol executable.
print "^/--- system/options/boot ---"
boot: system/options/boot
print type? boot
print boot
;; Example Output (illustrative): /usr/local/bin/rebol3-bulk

;; Output the home directory for the current user:
print "^/--- system/options/home ---"
print system/options/home
;; Example Output (illustrative): /home/Foo/

;; Output the path where system options are stored:
print "^/--- system/options/path ---"
print system/options/path
;; Example Output (illustrative): /mnt/c/Users/Foo/

;; Output all the datatypes recognized by Rebol 3 Oldes.
;; Return: The `typeset!` of all recognized Rebol data types.  For type system introspection.
print "^/--- system/options/result-types ---"
r3-datatypes: system/options/result-types
print type? r3-datatypes
print system/options/result-types
;; Example Output (illustrative): none! logic! integer! decimal!, ...

print "^/--- system/options/script ---"
print system/options/script
;; The path to the currently executing script. `none` if in the REPL interactive mode.
;; Essential for the running script's self-location.
;; Example Output (illustrative): /scripts/my-tool.r3 or `none`

print "^/--- what-dir ---"
what-dir
;; Output: The current working directory (CWD), path.

print "^/--- system/platform ---"
print system/platform
;; Example Output (illustrative): Linux
;; The Rebol word `platform` alone doesn't exist natively.

;; Output the details of all system ports (used for I/O operations).
;; Ports represent files, network or other I/O channels.
;; Use:To see the ports that are currently open and their configuration information.
print "^/--- print dump-obj/not-none system/ports ---"
print dump-obj/not-none system/ports

print "^/--- print system/product ---"
print system/product
;; Example Output (illustrative): Bulk or Core

print "^/--- print system/version ---"
print system/version
;; Example Output (illustrative): 3.19.0
;; Differs from `version` output.

;; Output the version of the currently running REBOL interpreter:
;; The version is important for operational compatibility and debugging purposes.
print "^/--- print version ---"
print type? version
print version
;; Example Output (illustrative):
;; Rebol/Bulk 3.19.0 (11-Apr-2025/11:19 UTC)
;; Copyright (c) 2012 REBOL Technologies
;; Copyright (c) 2012-2025 Rebol Open Source Contributors
;; Source:       https://github.com/Oldes/Rebol3

print "^/--- print now/time ---"
epoch: now/time
print epoch
;; Example Output (illustrative): 11:07:52

print "^/--- print now/time/precise ---"
;; Purpose: Precise timing applications.
epoch: now/time/precise
print epoch
;; Example Output (illustrative): 11:07:52.49009

