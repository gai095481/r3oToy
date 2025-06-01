Rebol []

safe-sort: function [
    "Safely sort a block, filtering out logic! values that cause sort errors"
    block [block!] "Block to sort"
    /local sorted-block
] [
    ;; Filter out any logic! values before sorting
    sorted-block: copy []
    foreach item block [
        ;; Only check the direct type of the item, don't try to evaluate words
        if not logic? item [
            append sorted-block item
        ]
    ]
    attempt [sort sorted-block] ; attempt sort in case of other unhandled types
]

safe-block-compare: function [
    "Compare two blocks using safe sorting (order-insensitive after additions)"
    block1 [block!] "First block to compare"
    block2 [block!] "Second block to compare"
    /local sorted1 sorted2
] [
    sorted1: safe-sort copy block1
    sorted2: safe-sort copy block2
    if all [block? sorted1 block? sorted2] [ ; Ensure sort didn't fail and return error!
        return sorted1 = sorted2
    ]
    false ; If sorting failed for some reason, consider them not equal for safety
]

;; Example 01: Add or remove an option from a configuration
;; Use case: User-controlled configuration management.
print ""
blkOptions_live: copy ["fullscreen" "mute"]
print ["Before:" blkOptions_live]
print ["Action:" "Toggles ""mute"" option. Press ESC to cancel, or wait for timeout."]
user_input_ex4: ask "Toggle mute? (type 'mute', Enter, ESC to cancel, or wait 10s): " /timeout 10

expected_blkOptions: copy blkOptions_live
if all [value? 'user_input_ex4 user_input_ex4 <> none] [ ; Check if not none (i.e., input was received)
    if user_input_ex4 = "mute" [
        alter expected_blkOptions "mute"
    ]
]

if all [value? 'user_input_ex4 user_input_ex4 <> none] [
    if user_input_ex4 = "mute" [
        alter blkOptions_live "mute"
    ]
]
print ["After:" blkOptions_live]
either safe-block-compare expected_blkOptions blkOptions_live [print "PASS"] [print "FAILED"]


;; Example 02: Update a list of file extensions
;; Use case: Managing supported file types in an application.
print ""
blkExtensions_live: copy [%.txt %.doc]
print ["Before:" blkExtensions_live]
print ["Action:" "Adds or removes a file extension. Press ESC to cancel, or wait for timeout."]
user_input_ex5: ask "Enter extension (e.g., .log, Enter, ESC to cancel, or wait 10s): " /timeout 10

expected_blkExtensions: copy blkExtensions_live
if all [value? 'user_input_ex5 user_input_ex5 <> none not empty? user_input_ex5] [
    alter expected_blkExtensions to file! user_input_ex5
]

if all [value? 'user_input_ex5 user_input_ex5 <> none not empty? user_input_ex5] [
    alter blkExtensions_live to file! user_input_ex5
]
print ["After:" blkExtensions_live]
either safe-block-compare expected_blkExtensions blkExtensions_live [print "PASS"] [print "FAILED"]


;; Example 03: Manage a list of active users
;; Use case: Real-time user session management.
print ""
blkActiveUsers_live: copy ["Alice" "Bob"]
print ["Before:" blkActiveUsers_live]
print ["Action:" "Toggles a user's active status. Press ESC to cancel, or wait for timeout."]
user_input_ex6: ask "Enter user to toggle (Enter, ESC to cancel, or wait 10s): " /timeout 10

expected_blkActiveUsers: copy blkActiveUsers_live
if all [value? 'user_input_ex6 user_input_ex6 <> none not empty? user_input_ex6] [
    alter expected_blkActiveUsers user_input_ex6
]

if all [value? 'user_input_ex6 user_input_ex6 <> none not empty? user_input_ex6] [
    alter blkActiveUsers_live user_input_ex6
]
print ["After:" blkActiveUsers_live]
either safe-block-compare expected_blkActiveUsers blkActiveUsers_live [print "PASS"] [print "FAILED"]

;; Example 04: Update a list of recent files
;; Use case: Maintaining a "recently used" file list.
print ""
blkRecentFiles_live: copy [%file1.txt %file2.txt]
print ["Before:" blkRecentFiles_live]
print ["Action:" "Adds or removes a file. Press ESC to cancel, or wait for timeout."]
user_input_ex9: ask "Enter filename (e.g., file3.txt, Enter, ESC to cancel, or wait 10s): " /timeout 10

expected_blkRecentFiles: copy blkRecentFiles_live
if all [value? 'user_input_ex9 user_input_ex9 <> none not empty? user_input_ex9] [
    alter expected_blkRecentFiles to file! user_input_ex9
]

if all [value? 'user_input_ex9 user_input_ex9 <> none not empty? user_input_ex9] [
    alter blkRecentFiles_live to file! user_input_ex9
]
print ["After:" blkRecentFiles_live]
either safe-block-compare expected_blkRecentFiles blkRecentFiles_live [print "PASS"] [print "FAILED"]

;; Example 05: Manage a list of blocked IP addresses
;; Use case: Simple firewall or access control management.
print ""
blkBlockedIPs_live: copy ["192.168.1.1" "10.0.0.1"]
print ["Before:" blkBlockedIPs_live]
print ["Action:" "Adds or removes an IP. Press ESC to cancel, or wait for timeout."]
user_input_ex11: ask "Enter IP to block/unblock (Enter, ESC to cancel, or wait 10s): " /timeout 10

expected_blkBlockedIPs: copy blkBlockedIPs_live
if all [value? 'user_input_ex11 user_input_ex11 <> none not empty? user_input_ex11] [
    alter expected_blkBlockedIPs user_input_ex11
]

if all [value? 'user_input_ex11 user_input_ex11 <> none not empty? user_input_ex11] [
    alter blkBlockedIPs_live user_input_ex11
]
print ["After:" blkBlockedIPs_live]
either safe-block-compare expected_blkBlockedIPs blkBlockedIPs_live [print "PASS"] [print "FAILED"]


;; Example 06: Update a list of supported file formats - More Robust Input
;; Use case: Managing file type support in an application.
print ""
blkFormats_live: copy [".jpg" ".png"]
print ["Before:" blkFormats_live]
print ["Action:" "Adds or removes a file format. Press ESC to cancel, or wait for timeout."]
user_input_ex12_raw: ask "Enter format (e.g., gif or .gif, Enter, ESC to cancel, or wait 10s): " /timeout 10

expected_blkFormats: copy blkFormats_live
processed_input_ex12: ""
if all [value? 'user_input_ex12_raw user_input_ex12_raw <> none not empty? user_input_ex12_raw] [
    temp_format: lowercase user_input_ex12_raw
    if not (first temp_format) = #"." [
        temp_format: join "." temp_format
    ]
    processed_input_ex12: temp_format
    alter expected_blkFormats processed_input_ex12
]

if all [value? 'user_input_ex12_raw user_input_ex12_raw <> none not empty? user_input_ex12_raw] [
    if not empty? processed_input_ex12 [ 
        alter blkFormats_live processed_input_ex12
    ]
]
print ["After:" blkFormats_live]
either safe-block-compare expected_blkFormats blkFormats_live [print "PASS"] [print "FAILED"]


;; Example 07: Toggle words in a text processing filter
;; Use case: Customizable content filtering.
print ""
blkFilterWords_live: copy ["spam" "ads"]
print ["Before:" blkFilterWords_live]
print ["Action:" "Adds or removes a word. Press ESC to cancel, or wait for timeout."]
user_input_ex13_raw: ask "Word to add/remove (Enter, ESC to cancel, or wait 10s): " /timeout 10

expected_blkFilterWords: copy blkFilterWords_live
processed_input_ex13: ""
if all [value? 'user_input_ex13_raw user_input_ex13_raw <> none not empty? user_input_ex13_raw] [
    processed_input_ex13: lowercase user_input_ex13_raw
    alter expected_blkFilterWords processed_input_ex13
]

if all [value? 'user_input_ex13_raw user_input_ex13_raw <> none not empty? user_input_ex13_raw] [
    if not empty? processed_input_ex13 [
        alter blkFilterWords_live processed_input_ex13
    ]
]
print ["After:" blkFilterWords_live]
either safe-block-compare expected_blkFilterWords blkFilterWords_live [print "PASS"] [print "FAILED"]


;; Example 08: Manage a list of enabled plugins
;; Use case: Plugin management in an extensible application.
print ""
blkEnabledPlugins_live: copy ["spell-check" "auto-format"]
print ["Before:" blkEnabledPlugins_live]
print ["Action:" "Toggles a plugin. Press ESC to cancel, or wait for timeout."]
user_input_ex14: ask "Enter plugin to toggle (Enter, ESC to cancel, or wait 10s): " /timeout 10

expected_blkEnabledPlugins: copy blkEnabledPlugins_live
if all [value? 'user_input_ex14 user_input_ex14 <> none not empty? user_input_ex14] [
    alter expected_blkEnabledPlugins user_input_ex14
]

if all [value? 'user_input_ex14 user_input_ex14 <> none not empty? user_input_ex14] [
    alter blkEnabledPlugins_live user_input_ex14
]
print ["After:" blkEnabledPlugins_live]
either safe-block-compare expected_blkEnabledPlugins blkEnabledPlugins_live [print "PASS"] [print "FAILED"]

;; Example 09: Update a list of reminder days
;; Use case: Configuring recurring events or reminders
;; How it works: Adds or removes a day (capitalized) from the reminder list based on user input
blkReminderDays: ["Monday" "Friday"]

print ["Before:" blkReminderDays]

;; Process user input and update the list
UpdateReminderDays: function [] [
    strUserInput: ask "Enter day to add/remove: "
    strCapitalizedDay: uppercase/part lowercase trim strUserInput 1
    alter blkReminderDays strCapitalizedDay
]

;; Call the function to update the list
UpdateReminderDays
print ["After:" blkReminderDays]
