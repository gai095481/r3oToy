```
!                 Return the logical complement (NOT) of a value.
!=                Return TRUE if the values are not equal (case-sensitive for strings).
!==               Return TRUE if the values are not identical in both type and value.
%                 Return the remainder of first value divided by second (modulo operation).
&                 Perform a bitwise AND operation on two values.
*                 Multiply two values and return the result.
**                Raise the first number to the power of the second number (exponentiation).
+                 Add two values and return the sum.
++                Increment a value by 1 and return the original value (prefix or postfix).
-                 Subtract the second value from the first and return the difference.
--                Decrement a value by 1 and return the original value (prefix or postfix).
---               Placeholder for unused arguments in function calls.
/                 Divide the first value by the second and return the quotient.
//                Perform modulo division, handling errors and rounding negligible values to zero.
<                 Return TRUE if the first value is less than the second value.
<<                Perform a bitwise left shift on the first value by the number of bits specified in the second.
<=                Return TRUE if the first value is less than or equal to the second value.
<>                Return TRUE if the values are not equal (equivalent to !=).
=                 Return TRUE if the values are equal (case-sensitive for strings).
==                Return TRUE if the values are identical in both type and value.
=?                Return TRUE if the values are identical in memory (same object or series).
>                 Return TRUE if the first value is greater than the second value.
>=                Return TRUE if the first value is greater than or equal to the second value.
>>                Perform a bitwise right shift on the first value by the number of bits specified in the second.
?                 Output information about words and values (debugging tool).
??                Output debug information about a word, path or block, including its molded value.
about             Output information about the Rebol interpreter and environment.
abs               Return the absolute value of a number. (math)
absolute          Return the absolute value of a number (alias for `abs`). (math)
access-os         Provide access to various operating system functions (getuid, setuid, getpid, kill, etc.).
acos              Calculate the arccosine (inverse cosine) of a value in radians. (math)
action?           Return TRUE if the value is an action (native function).
add               Add two values and return the sum (alias for +). (math)
ajoin             Reduce and join a block of values into a string, ignoring NONE and unset values. (convert)
all               Evaluate expressions and return FALSE or NONE if any are false, otherwise the last value. (conditional)
all-of            Return TRUE if all values pass the given test, otherwise NONE. (conditional)
also              Evaluate both arguments and return the first value. (conditional)
alter             Append a value if not found in series, otherwise remove it. Return TRUE if added. (toggle)
and               Perform logical AND operation on two values. (conditional)
and~              Perform bitwise AND operation on two values. (conditional)
any               Evaluate expressions and return the first non-false value or FALSE if all are false. (conditional)
any-block?        Return TRUE if the value is any type of block (block, paren, path, lit-path).
any-function?     Return TRUE if the value is any type of function (native, action, op, function, routine).
any-object?       Return TRUE if the value is any type of object (object, module, port).
any-of            Return the first value for which the given test is not FALSE or NONE.
any-path?         Return TRUE if the value is any type of path (path, lit-path, set-path, get-path).
any-string?       Return TRUE if the value is any type of string (string, file, url, tag, email).
any-word?         Return TRUE if the value is any type of word (word, lit-word, set-word, get-word).
append            Concatenate element(s) to the tail of a series and return the series head.
apply             Apply a function to a reduced block of arguments.
arccosine         Calculate the arccosine (inverse cosine) of a value in degrees.
arcsine           Calculate the arcsine (inverse sine) of a value in degrees.
arctangent        Calculate the arctangent (inverse tangent) of a value in degrees.
arctangent2       Calculate the two-argument arctangent, returning angle in degrees (-180 to 180).
array             Create and initializes a series of a given size.
as                Coerce a series into a compatible datatype without copying it.
as-blue           Convert a value to a blue color tuple (alias for to-tuple).
as-cyan           Convert a value to a cyan color tuple (alias for to-tuple).
as-gray           Convert a value to a grayscale color tuple (alias for to-tuple).
as-green          Convert a value to a green color tuple (alias for to-tuple).
as-purple         Convert a value to a purple color tuple (alias for to-tuple).
as-red            Convert a value to a red color tuple (alias for to-tuple).
as-white          Convert a value to a white color tuple (alias for to-tuple).
as-yellow         Convert a value to a yellow color tuple (alias for to-tuple).
as-pair           Combine X and Y values into a pair.
ascii?            Return TRUE if value or all characters in string are in ASCII range (0-127).
asin              Calculate the arcsine (inverse sine) of a value in radians.
ask               Prompt the user for input and return the entered string.
assert            Raise an assertion error if the given condition is false.
at                Return the series at the specified index, relative to the current position.
atan              Calculate the arctangent (inverse tangent) of a value in radians.
atan2             Calculate the two-argument arctangent, returning angle in radians (-pi to pi).
attempt           Attempt to evaluate a block and return the result or NONE on error. (Use `try` or `try/with` instead)
atz               Return the series at the specified 0-based index, relative to the current position.
average           Calculate the arithmetic mean of all values in a block.
back              Move the series index back by one position and return the series.
binary            Initiate the binary DSL (Bincode) for working with binary data.
binary?           Return TRUE if the value is of type binary!.
bind              Bind words to the specified context.
bitset?           Return TRUE if the value is of type bitset!.
block?            Return TRUE if the value is of type block!.
blur              Apply a Gaussian blur effect to the given image.
body-of           Return a copy of the body of a function, object, map or struct.
break             Exit the current loop or iteration construct. (iterate)
browse            Open the default web browser to a specified URL or local file.
call              Execute an external program or command and return immediately. (exec)
case              Evaluate conditions and execute the block following the first true condition. (flow control, conditional)
catch             Catch a `throw` from a block and return its value. (exception handling)
cause-error       Raises an immediate error with the provided information. (Use `try` or `try/with` instead)
cd                Modify the current directory (shell shortcut function). (filesystem)
change            Replace element(s) in a series and return the index position just after the modification.
change-dir        Modify the current working directory. (filesystem)
char?             Return TRUE if the value is of type char!.
charset           Create a bitset of characters for use with the parse function.
check             Perform a temporary series debug check. (non-production code only)
checksum          Compute a checksum, CRC, hash or HMAC for the given data.
clean-path        Remove redundant path elements ("..", ".", "//") from a directory path. (filesystem)
clear             Remove all elements from the current position to the tail of a series. (discard)
clos              Define a closure function (alias for `closure`). (persistence)
close             Close an open port or file. (filesystem)
closure           Define a closure function with all set-words as local variables. (persistence)
closure?          Return TRUE if the value is of type closure!. (persistence)
collect           Evaluate a block, collecting values via the `keep` function and return the collected values.
collect-words     Collect unique words used in a block (used for context construction).
color-distance    Calculate the weighted Euclidean distance between two RGB colors.
combine           Combine a block of values, with options to ignore specific types.
command?          Return TRUE if the value is of type `command!`. (exec)
comment           Ignore its argument and return nothing (used for code comments/remarks).
complement        Return the one's complement (bitwise NOT) of a value. (math)
complement?       Return TRUE if the bitset is complemented (inverted). (math)
compose           Evaluate a block, only evaluating parens and return a new block.
compress          Compress data using ZLIB algorithm.  Return the compressed binary data.
confirm           Prompt the user for a yes/no confirmation and return a logic value.
construct         Create an object with limited (safe), evaluation of the spec block.  Safer than `make object!`.
context           Create a new object (context), from a block of words and values.
context?          Return the context in which a word is bound.
continue          Skip the rest of the current loop iteration and continues with the next. (iterate)
copy              Create a copy of a series, object or other value.
cos               Calculate the cosine of an angle in radians.
cosine            Calculate the cosine of an angle in degrees.
create            Send a create request to a port.
datatype?         Return TRUE if the value is of type datatype!.
date?             Return TRUE if the value is of type date!.
debase            Decode a binary-coded string (e.g., Base64) to a binary value.
decimal?          Return TRUE if the value is of type decimal!.
decloak           Decode a binary string previously scrambled by `encloak`.
decode            Decode a series of bytes into a related datatype (e.g., `image!`).
decode-url        Parse a URL string and return an object with its components.
decompress        Decompress data previously compressed with the `compress` function.
deduplicate       Remove duplicate values from a data set. (set operations, discard)
default           Set a word to a default value if it hasn't been set yet.
dehex             Convert URL-style hex-encoded (%xx) strings to their original form.
delect            Parse a dialect using common rules and return the updated input block.
delete            Send a delete request to a port or remove a file. (discard, filesystem)
delete-dir        Delete a directory and all its contents (files and subdirectories). (discard, filesystem)
deline            Convert string line terminators to a standard format (e.g., CRLF to LF). (EOL)
delta-profile     Provide a delta-profile of running a specific block of code. (benchmark)
delta-time        Measure the execution time of a block of code. (benchmark)
detab             Convert tabs to spaces in a string (default tab size is 4). (whitespace)
dh                Perform Diffie-Hellman key exchange operations.
dh-init           Generate a new Diffie-Hellman private/public key pair.
difference        Calculate the set difference between two data sets. (set operations)
dir               Output the contents of a directory (alias for list-dir). (filesystem)
dir?              Return TRUE if the value looks like a directory specification (ends with "/" or "\"). (filesystem)
dirize            Ensure a path ends with a directory separator (adds "/" if missing). (filesystem)
divide            Divide the first value by the second and return the result. (math)
do                Evaluate a block, file, URL, function, word or any other value.
do-callback       Internal function to process callback events.
do-codec          Evaluate a codec function to encode or decode media types.
do-commands       Evaluate a block of extension module command functions with special rules.
does              Define a function with no arguments or local variables.
dp                Alia for delta-profile function.
ds                Perform a temporary stack debug operation, output current stack information for debugging.
dt                Alias for delta-time function. (benchmark)
dump              Perform a temporary debug dump operation, outputting detailed internal state for debugging.
dump-obj          Return a string with detailed information about an object value. (probe, debug)
ecdh              Perform Elliptic Curve Diffie-Hellman key exchange operations.
ecdsa             Perform Elliptic Curve Digital Signature Algorithm operations.
echo              Copy the console output to a file. (filesystem)
eighth            Return the eighth value of a series.
either            Conditionally evaluate one of two expressions based on a condition. (conditional)
ellipsize         Truncate a string and adds an ellipsis if it exceeds the specified length. (abbreviate, summary)
email?            Return TRUE if the value is of type email!. (network)
empty?            Return TRUE if a series is empty or a value is NONE. (conditional)
enbase            Encode a binary value into a binary-coded string (e.g., Base64).
encloak           Scramble a binary string based on a key for simple encryption.
encode            Encode a datatype (e.g., image!) into a series of bytes.
encoding?         Identify the media codec for given binary data.
enhex             Convert a string to URL-style hex encoding (%xx) where needed.
enline            Convert string line terminators to the native OS format. (EOL)
entab             Convert spaces to tabs in a string (default tab size is 4). (whitespace)
enum              Create an enumeration object from a given specification.
equal?            Return TRUE if two values are equal (case-sensitive for strings). (conditional, letter case)
equiv?            Return TRUE if two values are equivalent (case-insensitive for strings). (conditional, letter case)
error?            Return TRUE if the value is of type `error!`. (error handling)
even?             Return TRUE if a number is even. (math)
event?            Return TRUE if the value is of type event!.
evoke             Perform special system operations (for advanced users).
exclude           Return the first data set with elements from the second set removed. (set operations, discard)
exists?           Determine if a file or URL exists. (filesystem, network)
exit              Exit a function, returning no value. (quit)
exp               Calculate e (base of natural logarithm) raised to the power of the given value.
extend            Extend an object, map or block with new word and value pairs.
extract           Extract values from a series at regular intervals.
fifth             Return the fifth value of a series.
file-checksum     Compute a checksum of a given file's content. (filesystem)
file-type?        Return the identifying word for a specific file type or NONE. (filesystem)
file?             Return TRUE if the value is of type file!. (filesystem)
filter            Apply PNG delta filtering to image data. (photo)
find              Search for a value in a series and return the position where found or NONE.
find-all          Find all occurrences of a value within a series.
find-max          Return the position of the largest value in a series or NONE if empty.
find-min          Return the position of the smallest value in a series or NONE if empty.
find-script       Find a script header within a binary string and return its starting position.
first             Return the first value of a series.
first+            Return the first value of a series and increments the series index.
flush             Flush the output stream buffer. (filesystem)
for               Evaluate a block over a range of values. (iterate)
forall            Evaluate a block for every value in a series. (iterate)
foreach           Evaluate a block for each value or set of values in a series. (iterate)
forever           Evaluate a block endlessly until explicitly broken. (iterate)
form              Convert a value to a human-readable string representation.
form-oid          Return the x.y.z... style numeric string for a given OID (Object Identifier).
format            Format a string according to a specification (similar to `printf`).
format-date-time  Format a date-time value using ISO 8601 abbreviations.
format-time       Convert a time value to a human-readable string.
forskip           Evaluate a block for periodic values in a series. (iterate)
fourth            Return the fourth value of a series.
frame?            Return TRUE if the value is of type `frame!`.
func              Define a user function with a given specification and body.
funco             Create a non-copying function (optimized for boot process).
funct             Defines a function with all set-words treated as local variables.
function          Defines a function with all set-words treated as local variables (alias for funct).
function?         Return TRUE if the value is any type of function.
gcd               Calculate the greatest common divisor of two or more integers.
generate          Generate a specified cryptographic key. (encrypt)
get               Retrieve the value of a word, path or values of an object.
get-env           Return the value of an OS environment variable for the current process.
get-path?         Return TRUE if the value is of type get-path!.
get-word?         Return TRUE if the value is of type get-word!.
gob?              Return TRUE if the value is of type gob! (graphical object). (photo)
greater-or-equal? Return TRUE if the first value is greater than or equal to the second value.
greater?          Return TRUE if the first value is greater than the second value.
halt              Stop evaluation and return to the input prompt.
handle?           Return TRUE if the value is of type handle!.
has               Define a function with local variables but no arguments.
hash              Compute a hash value for any Rebol value (may change between Rebol versions).
hash?             Return TRUE if the value is of type hash!.
head              Moves the series index to the beginning and return the series.
head?             Return TRUE if a series is at its beginning.
help              Output information about words and values (interactive help system).
hsv-to-rgb        Convert HSV (Hue, Saturation, Value) color values to RGB.
iconv             Convert binary data to text using a specified codepage or transcodes to new binary.
if                Conditionally evaluate an expression if the condition is TRUE.
image             Provide interface for basic image encoding/decoding (Windows and macOS only).
image-diff        Calculate the difference (using weighted RGB distance) between two images of the same size Return 0% if images are same and 100% if completely different.
image?            Return TRUE if the value is of type image!.
import            Import a module: locates, loads, makes and sets up its bindings.
in                Evaluate a word or block in the context of a specified object.
in-dir            Evaluate a block while temporarily changing the current directory.
index?            Return the current position (index) of a series.
indexz?           Return the current 0-based position (index) of a series.
input             Prompt for and return user input from the console.
insert            Insert element(s) into a series and return the position just after the insert.
integer?          Return TRUE if the value is of type integer!.
intern            Import words and their values from lib context into the user context.
intersect         Return the intersection of two data sets.
invalid-utf?      Check UTF encoding; returns NONE if correct, else position of error.
issue?            Return TRUE if the value is of type issue!.
join              Concatenate two values into a new series.
keys-of           Return a block of keys/words from an object, map, date, handle or struct.
last              Return the last value of a series.
last?             Return TRUE if a series contains only one element.
latin1?           Return TRUE if value or all string characters are in Latin-1 range (0-255).
launch            Run a script as a separate process and return immediately.
lcm               Calculate the least common multiple of two or more integers.
length?           Return the length of a series from the current position to its tail.
lesser-or-equal?  Return TRUE if the first value is less than or equal to the second value.
lesser?           Return TRUE if the first value is less than the second value.
library?          Return TRUE if the value is of type library! (loaded extension).
license           Output the REBOL/core license agreement.
limit-usage       Set a usage limit for SECURE operations (can only be set once).
list-dir          Output the contents of a directory (alias for dir).
list-env          Return a map of OS environment variables for the current process.
lit-path?         Return TRUE if the value is of type lit-path!.
lit-word?         Return TRUE if the value is of type lit-word!.
load              Load and evaluates code or data from a file, URL, string or binary.
load-json         Convert a JSON string (object or array) to Rebol data structures.
log-10            Calculate the base-10 logarithm of a number.
log-2             Calculate the base-2 logarithm of a number.
log-e             Calculate the natural logarithm (base-e) of a number.
logic?            Return TRUE if the value is of type logic!.
loop              Evaluate a block a specified number of times.
lowercase         Convert a string to lowercase.
ls                Output the contents of a directory (alias for dir).
make              Construct or allocate a value of the specified datatype.
make-banner       Build the startup banner for Rebol.
make-dir          Create a new directory. Does not error if it already exists.
map               Create a map value (hashed associative array).
map-each          Evaluate a block for each value in a series and return results as a block.
map-event         Map an event to the innermost graphical object and coordinate.
map-gob-offset    Translate a gob and offset to the deepest gob and offset within it.
map?              Return TRUE if the value is of type map!.
max               Return the greater of two values.
maximum           Return the greater of two values (alias for max).
min               Return the lesser of two values.
minimum           Return the lesser of two values (alias for min).
mkdir             Create a new directory. Does not error if it already exists (alias for make-dir).
mod               Compute the non-negative remainder of A divided by B.
modified?         Return the last modified date of a file.
modify            Modify mode or control settings for a port or file.
module            Create a new module (specialized object for code organization).
module?           Return TRUE if the value is of type module!.
modulo            Perform modulo division, handling errors and rounding negligible values to zero.
mold              Convert a value to a REBOL-readable string representation.
mold64            Temporarily mold binary data to base 64 encoding.
money?            Return TRUE if the value is of type money!.
more              Output the contents of a file (shell shortcut function).
move              Move a value or span of values within a series.
multiply          Multiply two values and return the result.
native?           Return TRUE if the value is of type native! (built-in function).
negate            Modify the sign of a number.
negative?         Return TRUE if a number is negative.
new-line          Sets or clears the new-line marker within a block or paren.
new-line?         Return the state of the new-line marker within a block or paren.
next              Moves the series index forward by one and return the series.
ninth             Return the ninth value of a series.
none?             Return TRUE if the value is of type none!.
not               Return the logical complement (NOT) of a value.
not-equal?        Return TRUE if two values are not equal.
not-equiv?        Return TRUE if two values are not equivalent (case-sensitive).
now               Return the current date and time.
number?           Return TRUE if the value is any type of number (excluding NaN).
object            Create a new object from a block of words and values.
object?           Return TRUE if the value is of type object!.
odd?              Return TRUE if a number is odd.
offset?           Return the offset between two series positions.
op?               Return TRUE if the value is of type op! (operator function).
open              Open a port or file; creates a new port from a specification if needed.
open?             Return TRUE if a port is open.
or                Perform a logical OR operation on two values.
or~               Perform a bitwise OR operation on two values.
pad               Pad a FORMed value on the right side with spaces to a specified length.
pair?             Return TRUE if the value is of type pair!.
paren?            Return TRUE if the value is of type paren!.
parse             Parse a series according to a grammar specification. Powerful tool for text and data processing.
past?             Return TRUE if a series index is past its end.
path?             Return TRUE if the value is of type path!.
percent?          Return TRUE if the value is of type percent!.
pick              Return the value at a specified position in a series.
pickz             Return the value at a specified 0-based position in a series.
poke              Replace a value at a specified position in a series.
pokez             Replace a value at a specified 0-based position in a series.
port?             Return TRUE if the value is of type port!.
positive?         Return TRUE if a number is positive.
power             Raise the first number to the power of the second number.
premultiply       Pre-multiply RGB channels with their alpha channel in an image.
prin              Output a value without a line break.
print             Output a value followed by a line break.
print-horizontal-line Output a horizontal line for text-based user interfaces.
print-table       Output a block of blocks as an ASCII table.
printf            Output formatted text (similar to C's printf).
probe             Output a molded value for debugging and return the original value.
profile           Profile code execution for performance analysis. Can be used on specific code blocks.
protect           Protect a series or variable from modification.
protect-system-object Protect the system object and selected sub-objects from modification.
protected?        Return TRUE if the immediate argument is protected from modification.
put               Replace the value following a key in an object or map.
pwd               Return the current working directory path.
q                 Stop evaluation and exits the interpreter (alias for quit).
query             Return information about a specified target (file, url, port, etc.).
quit              Stop evaluation and exits the interpreter.
quote             Return its argument without evaluation.
random            Generate a random value or shuffles a series.
rc4               Encrypt/decrypt data using the RC4 algorithm.
read              Read data from a file, URL or other port.
rebcode?          Return TRUE if the value is of type rebcode! (internal bytecode).
recycle           Recycle unused memory (garbage collection).
reduce            Evaluate expressions and return multiple results as a block.
ref?              Return TRUE if the value is of type `ref!`.
refinement?       Return TRUE if the value is of type `refinement!`.
reflect           Return specific details about a datatype.
reform            Reduce and forms a block of values into a string.
register-codec    Register a non-native codec in the system.
rejoin            Reduce and joins a block of values into a single value.
release           Release internal resources of a handle.  Return TRUE on success.
remainder         Calculate the remainder of dividing the first value by the second.
remold            Reduce and convert a value to a REBOL-readable string.
remove            Remove element(s) from a series and return the same position.
remove-each       Remove values from a series for each block that returns a truthy value.
rename            Rename a file.
repeat            Evaluate a block a specified number of times or over a series (iterate).
repend            Append a reduced value to a series and return the series head.
replace           Replace occurrences of a search value with a replace value in a target series.
request-dir       Prompt the user to select a directory and return the full path(s).
request-file      Prompt the user to select a file and return the full path(s).
request-password  Prompt for a password without echoing input or storing in command history.
resize            Resize an image to the specified dimensions.
resolve           Copy a context by setting values in the target from those in the source.
return            Return a value from a function.
reverse           Reverse the order of elements in a series.
reword            Create a string or binary based on a template and substitution values.
rgb-to-hsv        Convert RGB color values to HSV (Hue, Saturation, Value).
rm                Delete a file (alias for `delete`). (discard)
round             Round a numeric value to a specified precision. (math)
rsa               Perform RSA encryption, decryption, signing or verification operations.
rsa-init          Create a context for RSA encryption or decryption operations.
same?             Return TRUE if two values are identical (same object in memory).
save              Save a value, block or other data to a file, URL, binary or string (serialize).
scalar?           Return TRUE if the value is any scalar type (non-series, non-object).
script?           Ensure a file, URL or string contains a valid Rebol script header.
second            Return the second value of a series.
secure            Configure security policies for the Rebol environment.
select            Search for a value and return the value that follows it or NONE.
selfless?         Return TRUE if the context doesn't bind 'self' word.
series?           Return TRUE if the value is any type of series.
set               Assign a value to a word, path, block of words or object.
set-env           Set the value of an OS environment variable for the current process.
set-path?         Return TRUE if the value is of type set-path!.
set-scheme        Initialize a low-level port scheme actor.
set-user          Initialize the user's persistent data under system/user.
set-word?         Return TRUE if the value is of type set-word!.
seventh           Return the seventh value of a series.
shift             Perform a bitwise shift operation on an integer.
shift-left        Perform a bitwise left shift on an integer.
shift-right       Perform a bitwise right shift on an integer.
sign?             Return the sign of a number as 1, 0 or -1.
sin               Calculate the sine of an angle in radians.
sine              Calculate the sine of an angle in degrees.
single?           Return TRUE if a series contains exactly one element.
sixth             Return the sixth value of a series.
size?             Return the size of a file or the number of bits per value in a vector.
skip              Move the series index forward or backward by a specified amount.
sort              Sort a series in ascending or descending order.
source            Output the source code for a word (function, object, etc.).
spec-of           Return a copy of the specification of a function, object, vector, datatype or struct.
speed?            Return approximate speed benchmarks for various operations.
split             Split a series into pieces based on size, count or delimiters.
split-lines       Split a string series into lines based on CR-LF line endings.
split-path        Split a file path into directory and filename components.
sqrt              Calculate the square root of a number.
square-root       Calculate the square root of a number (alias for sqrt).
stack             Return stack back-trace or other debug information.
stats             Provides status and statistics information about the Rebol interpreter.
strict-equal?     Return TRUE if two values are strictly equal (type and value).
strict-not-equal? Return TRUE if two values are not strictly equal (type or value differs).
string?           Return TRUE if the value is of type `string!`.
struct?           Return TRUE if the value is of type `struct!`.
su                Initialize the user's persistent data under system/user (alias for `set-user`).
subtract          Subtract the second value from the first and return the result.
suffix?           Return the file suffix of a filename or URL or NONE if not found.
sum               Calculate the sum of all values in a block.
supplement        Append a value to a series if not already present.
swap              Exchange elements between two series or within the same series.
swap-endian       Reverse the byte order (endianness) of a binary value.
switch            Select and evaluates a block based on matching a value to cases (conditional, flow control).
tag?              Return TRUE if the value is of type tag!.
tail              Move the series index to just past its last element.
tail?             Return TRUE if a series index is at or past its end.
take              Remove and return one or more elements from a series.
tan               Calculate the tangent of an angle in radians.
tangent           Calculate the tangent of an angle in degrees.
task              Create a new task for concurrent processing.
task?             Return TRUE if the value is of type task!.
tenth             Return the tenth value of a series.
third             Return the third value of a series.
throw             Throw control back to a previous catch (exception handling).
time?             Return TRUE if the value is of type time!.
tint              Mix colors, adjusting tint and/or brightness.
title-of          Return a copy of the title of a function, datatype or module.
to                Convert a value to a specified datatype.
to-binary         Convert a value to type `binary!`.
to-bitset         Convert a value to type `bitset!`.
to-block          Convert a value to type `block!`.
to-char           Convert a value to type `char!`.
to-closure        Convert a value to type `closure!`.
to-command        Convert a value to type `command!`.
to-datatype       Convert a value to type `datatype!`.
to-date           Convert a value to type `date!`.
to-decimal        Convert a value to type `decimal!`.
to-degrees        Convert an angle from radians to degrees. (math)
to-email          Convert a value to type `email!`.
to-error          Convert a value to type `error!`.
to-event          Convert a value to type `event!`.
to-file           Convert a value to type `file!`.
to-function       Convert a value to type `function!`.
to-get-path       Convert a value to type `get-path!`.
to-get-word       Convert a value to type `get-word!`.
to-gob            Convert a value to type `gob!` (graphical object).
to-hash           Convert a value to type `hash!`.
to-hex            Convert a numeric value to a hexadecimal issue! (with leading # and 0's).
to-idate          Convert a value to a standard Internet date string format (e.g., "01-Jan-2024").
to-image          Convert a value to an image! datatype, creating a visual representation.
to-integer        Convert a value to an integer! datatype, rounding or truncating if necessary.
to-issue          Convert a value to an issue! datatype, typically used for version numbers or identifiers.
to-itime          Convert a value to a standard Internet time string with two digits for each segment (e.g., "14:30:00").
to-json           Convert Rebol data structures to a JSON-formatted string for interoperability.
to-lit-path       Convert a value to a lit-path! datatype, creating a literal path that isn't evaluated.
to-lit-word       Convert a value to a lit-word! datatype, creating a literal word that isn't evaluated.
to-local-file     Convert a Rebol file path to the local system file path format.
to-logic          Convert a value to a logic! datatype (true or false).
to-map            Convert a value (typically a block of key-value pairs) to a map! datatype.
to-module         Convert a context or object to a module! datatype, encapsulating code and data.
to-money          Convert a value to a money! datatype, representing currency amounts.
to-object         Convert a block of word-value pairs to an object! datatype.
to-pair           Convert a value to a pair! datatype, representing two-dimensional coordinates.
to-paren          Convert a value to a paren! datatype, creating a grouped expression.
to-path           Convert a value to a path! datatype, representing a series of values to be evaluated.
to-percent        Convert a value to a percent! datatype, representing a percentage.
to-port           Convert a value to a port! datatype, used for I/O operations.
to-radians        Convert an angle from degrees to radians.
to-real-file      Return the canonicalized absolute pathname, resolving symbolic links on POSIX systems. (filesystem)
to-rebol-file     Convert a local system file path to a Rebol file path format. (filesystem)
to-ref            Convert a value to a ref! datatype, representing a reference.
to-refinement     Convert a value to a refinement! datatype, used in function definitions.
to-relative-file  Return the relative portion of a file path if in a subdirectory or the original if not.
to-set-path       Convert a value to a set-path! datatype, used for setting values in paths.
to-set-word       Convert a value to a set-word! datatype, used for assigning values to words.
to-string         Convert a value to a string! datatype, creating a sequence of characters.
to-tag            Convert a value to a tag! datatype, representing XML-style tags.
to-time           Convert a value to a time! datatype, representing a time of day.
to-tuple          Convert a value to a tuple! datatype, often used for RGB color values.
to-typeset        Convert a value to a typeset! datatype, representing a set of datatypes.
to-url            Convert a value to a url! datatype, representing a Uniform Resource Locator.
to-value          Return the value if it is a value or NONE if unset. Useful for handling optional values.
to-vector         Convert a value to a vector! datatype, representing a fixed-length array of same-type values.
to-word           Convert a value to a word! datatype, representing a symbolic name.
trace             Enable or disable evaluation tracing and back-trace for debugging purposes.
transcode         Translate UTF-8 binary source to Rebol values, returning one or several values in a block.
trim              Remove whitespace from strings, null bytes from binary data or none values from blocks or objects.
true?             Return true if an expression can be used as a truthy value in conditional statements.
truncate          Remove all elements from a series' head to its current index position. (discard)
try               Attempt to evaluate a block and return its value or an error! if an exception occurs. (exception handling)
tuple?            Return TRUE if the value is of the tuple! datatype. (version)
type?             Return the datatype of a specified value.
types-of          Return a block containing the datatypes of the arguments for any function.
typeset?          Return TRUE if the value is of the `typeset!` datatype.
unbind            Remove the binding of words from their current context.
undirize          Return a copy of the path with any trailing "/" removed.
unfilter          Reverse PNG delta filtering, used in image processing. (photo)
union             Return a new series containing the union of two data sets, removing duplicates. (set operations)
unique            Return a new series with duplicate values removed, preserving the original order. (set operations)
unless            Evaluate a block if the condition is FALSE. Blocks are evaluated by default.
unprotect         Remove protection from a series or variable, allowing it to be modified again.
unset             Remove the value of a word in its current context, making it unset.
unset?            Return TRUE if the value is of the `unset!` datatype (has no value assigned).
until             Repeatedly evaluate a block until it returns a truthy value.
update            Update external and internal states, typically used after read or write operations.
uppercase         Convert a string of characters to uppercase.
url?              Return TRUE if the value is of the `url!` datatype.
usage             Output command-line arguments and their usage information.
use               Define words local to a block, creating a new context for evaluation.
user's            Resolve and return user-specific data values.
utf?              Return the UTF BOM (Byte Order Mark) encoding: + for Big Endian, - for Little Endian.
utype?            Return TRUE if the value is of the specified datatype (user-defined type check).
value?            Return TRUE if the word has a value (is not unset).
values-of         Return a block containing the values of any object, map or struct.
vector?           Return TRUE if the value is of the `vector!` datatype.
version           Return the current Rebol version string.
wait              Pause execution for a specified duration or until a port event occurs or both.
wait-for-key      Wait for a single key press and return the character or a word for control keys.
wake-up           Awaken a port and updates it with an event, typically used in event-driven programming.
what              Output a list of known functions, useful for interactive exploration.
what-dir          Return the current working directory path.
while             Repeatedly evaluate a block while a condition block returns TRUE.
wildcard          Return a block of absolute file paths filtered using wildcard patterns.
wildcard?         Return TRUE if a file path contains wildcard characters (* or ?).
with              Evaluate a block bound to the specified context, allowing temporary context changes.
word?             Return TRUE if the value is of the word! datatype.
words-of          Return a block containing the words (keys) of a function, object, map, date, handle or struct.
wrap              Evaluate a block, treating all set-words as locals, creating a new context.
write             Write data to a file, URL or port, automatically converting text strings if necessary.
xor               Return the bitwise exclusive OR of two values. (XOR)
xor~              Alias for `xor`, returns the bitwise exclusive OR of two values. (XOR)
xtest             Reserved for internal testing and debugging of the Rebol interpreter.  Not intended for general use.
zero?             Return TRUE if the value is zero, considering the value's datatype.
|                 Return the bitwise OR of two values.
```
