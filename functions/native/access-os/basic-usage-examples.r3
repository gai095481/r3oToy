REBOL []

;; `access-os` is a native function in Rebol 3 to provide access to various operating system functions such as
;; retrieving and setting user IDs, group IDs, and process IDs, as well as sending termination signals to processes.
;;
;; USAGE:
;;
;; `access-os` FIELD
;;
;; ARGUMENTS:
;;
;; FIELD         [word!]  Valid words: 'uid, 'euid, 'gid, 'egid, 'pid.
;;
;; REFINEMENTS:
;;
;; /set          To set or kill pid (signal 15)
;; VALUE        [integer! block!] Argument, such as 'uid, 'gid, or 'pid (in which case, it can be a block with the signal number).
;;
;; DESCRIPTION:
;; Provide access to OS-level identifiers and process control.  Retrieval operations are safe, but setting IDs or
;; killing processes requires elevated permissions.
;;
;; RETURNS:
;; [integer!] for ID retrieval; varies for /set operations.

;; Helper function to convert a decimal integer to its binary string representation
decimal-to-binary: function [
    "Converts an integer to its binary string representation (e.g., 10 -> '1010')"
    n [integer!] "The integer to convert"
][
    if n = 0 [return "0"]
    digits: copy []
    while [n > 0] [
        insert digits to-string mod n 2
        n: n / 2
    ]
    join "" reverse digits
]

;; Example 1: Retrieve the user ID of the current process.
user-ID: access-os 'uid
;; type? user-ID == #(integer!)
print ["User ID of the current process:" user-ID]

;; Example 2: Retrieve the effective user ID of the current process.
print ["Effective User ID of the current process:" access-os 'euid]

;; Example 3: Retrieve the group ID of the current process.
print ["Group ID of the current process:" access-os 'gid]

;; Example 4: Retrieve the effective group ID of the current process.
print ["Effective Group ID of the current process:" access-os 'egid]

;; Example 5: Retrieve the process ID of the current process.
print ["Process ID of the current process:" access-os 'pid]

;; Example 6: Set the user ID to a new value (requires appropriate permissions).
;; NOTE: Requires root or elevated permissions to execute.
;; print ["Set User ID to 1001:" access-os/set 'uid 1001]

;; Example 7: Set the group ID to a new value (requires appropriate permissions).
;; NOTE: Requires root or elevated permissions to execute.
;; print ["Set Group ID to 1001:" access-os/set 'gid 1001]

;; Example 8: Kill a process by its ID (using signal 15).
;; NOTE: Requires root or elevated permissions to execute.
;; print ["Kill Process with ID 1234:" access-os/set 'pid [1234 15]]

;; Example 10: Use SPLIT to split the effective group ID into digits.
;; Note: This might not split anything if EGID is a number without hyphens.
print ["Split Effective Group ID:" split to-string access-os 'egid "-"]

;; Example 11: Use PICK to retrieve the third digit from the process ID.
;; Note: Assumes PID has at least 3 digits; returns a single character.
print ["Third digit of Process ID:" pick to-string access-os 'pid 3]

;; Example 12: Combine `access-os` with TO-HEX to convert the user ID to hexadecimal.
print ["User ID in Hexadecimal:" to-hex access-os 'uid]

;; Example 13: Combine `access-os` with SYSTEM/TIME to log the current process ID with a timestamp.
print rejoin ["Process ID at " now/time ": " access-os 'pid]

;; Example 14: Use `access-os` with LENGTH? to count the number of digits in the group ID.
print ["Number of digits in Group ID:" length? to-string access-os 'gid]

;; Example 15: Check if the user ID is even by combining `access-os` with MOD.
print ["Is User ID even?" either even? access-os 'uid ["Yes"] ["No"]]

;; Example 17: Convert the process ID to binary using a helper function.
print ["Process ID in Binary:" to-binary to-integer access-os 'pid]

;; Example 18: Use `access-os` with FIND to search for a specific digit in the group ID.
print ["Does Group ID contain '5'?" either find to-string access-os 'gid "5" ["Yes"] ["No"]]

;; Example 19: Log the user ID and group ID together in a formatted string.
print rejoin ["User ID: " access-os 'uid " Group ID: " access-os 'gid]

;; Example 20: Use `access-os` with TRIM to remove leading and trailing whitespace from the user ID.
;; Note: Probably unnecessary since IDs are typically numbers without whitespace.
print ["Trimmed User ID:" trim to-string access-os 'uid]

;; Validation Suite
;; Verify the functionality of the examples:
test-access-os: function [] [
    tests: copy []
    append tests [
        "Retrieve UID" [integer? access-os 'uid]
        "Retrieve EUID" [integer? access-os 'euid]
        "Retrieve GID" [integer? access-os 'gid]
        "Retrieve EGID" [integer? access-os 'egid]
        "Retrieve PID" [integer? access-os 'pid]
        "Binary Conversion" [string? decimal-to-binary 10]
    ]
    foreach [name test] tests [
        print reform ["Test:" name either do test ["✅ PASSED"] ["❌ FAILED"]]
    ]
]

test-access-os
