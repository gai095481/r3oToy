# Unofficial `access-os` Function User Guide

This guide explains the `access-os` native function based on its help text, source and practical examples for Rebol/Bulk 3.19.0. It provides access to core operating system identifiers and basic process control mechanisms.

## Core Concept

`access-os field`

The primary purpose is to retrieve or, in specific cases with the `/set` refinement, modify operating system-level identifiers associated with the current process or interact with other processes.

## Arguments

* `field` [word!]: Specifies the identifier to retrieve or modify. Valid words are:
    * `'uid`: User ID of the current process.
    * `'euid`: Effective User ID of the current process.
    * `'gid`: Group ID of the current process.
    * `'egid`: Effective Group ID of the current process.
    * `'pid`: Process ID of the current process.

## Refinements

### `/set`

`access-os/set field value`

* **Purpose**: Used to set User/Group IDs or send signals to processes.
* `value` [integer! block!]:
  * For `'uid`, `'euid`, `'gid`, `'egid`: An integer representing the new ID.
  * For `'pid`: An integer (target PID, sends SIGTERM 15) or a block `[target-pid signal-number]`.

**Important:** Operations using `/set` typically require elevated privileges (like running as `root` on Unix-like systems), and can have significant consequences.  Always use them carefully.

## Basic Retrieval Examples

These operations are generally safe and do not require special permissions:

```rebol
;; Get the current User ID
user-id: access-os 'uid
print ["My User ID is:" user-id]

;; Get the current Effective User ID
effective-user-id: access-os 'euid
print ["My Effective User ID is:" effective-user-id]

;; Get the current Group ID
group-id: access-os 'gid
print ["My Group ID is:" group-id]

;; Get the current Effective Group ID
effective-group-id: access-os 'egid
print ["My Effective Group ID is:" effective-group-id]

;; Get the current Process ID
process-id: access-os 'pid
print ["My Process ID is:" process-id]
```

## `/set` Refinement Examples (Require Privileges)

**Warning:** These examples will likely fail or produce errors if not run with appropriate permissions (e.g., as `root`).

### Setting IDs

```rebol
;; --- Attempt to Set IDs (Example, will likely fail without root) ---
;; Common UID for 'nobody' user (check your system)
nobody-uid: 65534
set-euid-result: try [access-os/set 'euid nobody-uid]
either error? set-euid-result [
    print "Setting EUID failed (expected without root privileges)."
] [
    print ["EUID set result:" set-euid-result]
]

;; Similarly for GID (replace with a valid GID if testing with privileges)
;; set-gid-result: try [access-os/set 'gid 65534]
```

### Sending Signals to Processes

Signals are a form of inter-process communication (IPC).

Common signals include:

* `15` (SIGTERM): Request process termination (gracefully).
* `9` (SIGKILL): Forcefully kill the process.
* `10`/`30`/`31` (SIGUSR1/SIGUSR2): User-defined signals.

```rebol
;; --- Sending Signals ---

;; Send SIGTERM (15) to the current process (this script)
;; WARNING: This might terminate the script!
current-pid: access-os 'pid
print ["Attempting to send SIGTERM (15) to myself (PID: " current-pid ")..."]
send-signal-result: try [access-os/set 'pid current-pid] ; Default signal is 15
either error? send-signal-result [
    print "Sending signal failed (permissions?)."
] [
    print "SIGTERM signal sent (script might terminate or handle it)."
]

;; Send a specific signal (e.g., SIGUSR1 = 10 on Linux) to another process
;; Replace 9999 with a real PID you have permission to signal
target-pid: 9999
signal-number: 10
print ["Attempting to send signal" signal-number "to PID" target-pid "..."]
send-specific-signal-result: try [access-os/set 'pid reduce [target-pid signal-number]]
either error? send-specific-signal-result [
    print ["Sending signal to PID" target-pid "failed (doesn't exist/permissions?)."]
] [
    print ["Signal" signal-number "sent to PID" target-pid "."]
]

;; Send SIGKILL (9) to another process (Forcefully kills it)
;; Replace 8888 with a real PID you have permission to kill
target-pid-to-kill: 8888
print ["Attempting to send SIGKILL (9) to PID" target-pid-to-kill "..."]
kill-result: try [access-os/set 'pid reduce [target-pid-to-kill 9]]
either error? kill-result [
    print ["Killing PID" target-pid-to-kill "failed (doesn't exist/permissions?)."]
] [
    print ["SIGKILL sent to PID" target-pid-to-kill "."]
]
```

## Common Pitfalls & Nuances for Novices

1. **Permission Errors with `/set`**: The most common issue is attempting to use `/set` for IDs or sending signals without the necessary operating system privileges. Always check permissions and understand the implications.
2. **Misunderstanding Signal Sending Syntax**:
    * `access-os/set 'pid <integer>` sends signal `15` (SIGTERM) to the process with that `<integer>` PID.
    * `access-os/set 'pid [<pid> <signal>]` sends the specified `<signal>` number to the process with `<pid>`.
3. **Assuming `access-os` Works with Arbitrary OS Calls**: `access-os` is limited to the specific `field` words (`uid`, `euid`, `gid`, `egid`, `pid`). It's not a general-purpose OS command executor.
4. **Error Handling**: Operations, especially with `/set`, can fail. Always wrap them in `try` and check for `error?` to handle failures gracefully in scripts.
    ```rebol
    ; Robust way to get UID
    get-uid-result: try [my-uid: access-os 'uid]
    either error? get-uid-result [
        print "Error: Could not retrieve UID."
        my-uid: -1 ; Set a default/error value
    ] [
        print ["Retrieved UID:" my-uid]
    ]
    ```
5. **Checking for Root**: A common check is seeing if the UID is 0.
    ```rebol
    is-root?: (access-os 'uid) = 0
    print ["Am I running as root? " either is-root? ["Yes"] ["No"]]
    ```
6. **Signal Availability**: Signal numbers can vary slightly between operating systems (e.g., SIGUSR1 might be 10 on Linux, 30 on macOS). Consult your OS documentation if needed.

By understanding these identifiers, the `/set` refinement's capabilities and limitations, and the importance of permissions and error handling, novice programmers can effectively use `access-os` for system-level tasks within their Rebol scripts.
