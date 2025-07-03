```
=== Testing Message Logger Function ===

✅ PASSED: Basic string message logging should succeed.
✅ PASSED: The default log file should now be created.
✅ PASSED: Block data logging should succeed.
✅ PASSED: Object logging should succeed.
✅ PASSED: Alternate file logging should succeed.
✅ PASSED: Alternate log file should be created.
❌ REJECT: Possibly unsafe wild log file path detected: ../invalid-path.log
✅ PASSED: Invalid path should be rejected for security reasons.
✅ PASSED: Map! data logging should succeed.

--- Testing additional Rebol 3 datatypes ---
✅ PASSED: `binary!` data logging should succeed.
✅ PASSED: `tuple!` data logging should succeed.
✅ PASSED: `date!` data logging should succeed.
✅ PASSED: `time!` data logging should succeed.
✅ PASSED: `logic!` data logging should succeed.
✅ PASSED: `decimal!` data logging should succeed.
✅ PASSED: `integer!` data logging should succeed.
✅ PASSED: `percent!` data logging should succeed.
✅ PASSED: `money!` data logging should succeed.
✅ PASSED: `pair!` data logging should succeed.
✅ PASSED: `file!` data logging should succeed.
✅ PASSED: `email!` data logging should succeed.
✅ PASSED: `url!` data logging should succeed.
✅ PASSED: `none!` data logging should succeed.

============================================
✅ PASSED: ALL MESSAGE LOGGER OPERATIONS ARE SUCCESSFUL.
============================================
```

```
$ cat std-messages.log
26-Jun-2025 18:07:29: This is a basic string test message.
26-Jun-2025 18:07:29: [1 2 3 "test"]
26-Jun-2025 18:07:29: make object! [
    name: "Error Object"
    code: 404
    reason: 'denied
]
26-Jun-2025 18:07:29: #[
    name: "Zaphod"
    species: "Betelgeusian"
    heads: 2
    towels: true
]
26-Jun-2025 18:07:29: Hello
26-Jun-2025 18:07:29: 0.2.1
26-Jun-2025 18:07:29: 24-Jun-2025
26-Jun-2025 18:07:29: 1:23:45.67
26-Jun-2025 18:07:29: #(true)
26-Jun-2025 18:07:29: 2.345
26-Jun-2025 18:07:29: 42
26-Jun-2025 18:07:29: 75%
26-Jun-2025 18:07:29: $19.99
26-Jun-2025 18:07:29: 1024x768
26-Jun-2025 18:07:29: %settings.cfg
26-Jun-2025 18:07:29: user@example.com
26-Jun-2025 18:07:29: https://example.com
26-Jun-2025 18:07:29: #(none)
```
```
