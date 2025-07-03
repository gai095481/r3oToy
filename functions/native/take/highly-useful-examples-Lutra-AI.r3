REBOL []
;;=============================================================================
;; TAKE FUNCTION: HIGHLY USEFUL AND PRACTICAL EXAMPLES
;;=============================================================================
;; Purpose: Real-world problem solving with TAKE function
;; Audience: Rebol developers solving everyday programming problems
;; Evidence: Based on validated diagnostic probe results
;;=============================================================================

print "=== TAKE FUNCTION: HIGHLY USEFUL AND PRACTICAL EXAMPLES ==="
print "=== Real-world problem solving scenarios ==="
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 1: Job queue processing system
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 1: Job queue processing system ---"
print "Problem: Process work items in strict FIFO order"
print ""

work-queue: [backup-database send-notifications update-cache deploy-code cleanup-logs]
processed: 0
failed: 0

print ["Initial queue:" mold work-queue "(" length? work-queue "jobs)"]

while [not empty? work-queue] [
    current-job: take work-queue
    processed: processed + 1

    ; Simulate job processing with occasional failures
    either (random 10) > 8 [
        failed: failed + 1
        print ["Job" processed "FAILED:" mold current-job]
    ][
        print ["Job" processed "completed:" mold current-job]
    ]

    print ["  Remaining in queue:" length? work-queue]
]

print ["Summary: Processed" processed "jobs," failed "failed"]
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 2: Command-line argument parsing
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 2: Command-line argument parsing ---"
print "Problem: Parse user command with options and arguments"
print ""

; Simulate command line input
args: ["copy" "source.txt" "dest.txt" "--verbose" "--backup"]
command: none
files: []
options: []

print ["Command line args:" mold args]

; Extract command
if not empty? args [
    command: take args
    print ["Command:" mold command]
]

; Parse remaining arguments
while [not empty? args] [
    arg: take args
    either find arg "--" [
        append options arg
        print ["Option found:" mold arg]
    ][
        append files arg
        print ["File found:" mold arg]
    ]
]

print ["Final parsing result:"]
print ["  Command:" mold command]
print ["  Files:" mold files]
print ["  Options:" mold options]
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 3: Round-robin task distribution
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 3: Round-robin task distribution ---"
print "Problem: Distribute tasks evenly across multiple workers"
print ""

tasks: [task1 task2 task3 task4 task5 task6 task7 task8 task9]
workers: [worker-A worker-B worker-C]
assignments: []

print ["Tasks to distribute:" mold tasks]
print ["Available workers:" mold workers]

; Initialize worker assignments
foreach worker workers [
    repend assignments [worker []]
]

; Distribute tasks in round-robin fashion
worker-index: 1
while [not empty? tasks] [
    task: take tasks
    current-worker: workers/:worker-index

    ; Find worker in assignments and add task
    foreach [worker task-list] assignments [
        if worker = current-worker [
            append task-list task
            print ["Assigned" mold task "to" mold worker]
            break
        ]
    ]

    ; Move to next worker (round-robin)
    worker-index: worker-index + 1
    if worker-index > length? workers [worker-index: 1]
]

print ["Final assignments:"]
foreach [worker task-list] assignments [
    print ["  " mold worker ":" mold task-list]
]
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 4: Undo system implementation
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 4: Undo system implementation ---"
print "Problem: Implement undo functionality for user actions"
print ""

action-history: []
max-history: 5

; Helper function to add action to history
add-action: func [action] [
    append action-history action
    print ["Action recorded:" mold action]

    ; Limit history size using TAKE
    if (length? action-history) > max-history [
        oldest: take action-history
        print ["Removed oldest action:" mold oldest]
    ]

    print ["History:" mold action-history]
]

; Helper function to undo last action
undo-action: func [] [
    either empty? action-history [
        print "Nothing to undo"
    ][
        last-action: take/last action-history
        print ["Undoing:" mold last-action]
        print ["History after undo:" mold action-history]
    ]
]

; Simulate user actions
add-action "typed 'hello'"
add-action "made text bold"
add-action "inserted image"
add-action "changed font"
add-action "added border"
add-action "changed color"  ; This will remove oldest action

undo-action
undo-action
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 5: Binary data packet processing
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 5: Binary data packet processing ---"
print "Problem: Parse binary protocol packets"
print ""

; Simulate network packet: [length][type][data...]
packet: #{05414243444566}  ; length=5, type=65('A'), data="BCDE", extra=66
print ["Raw packet:" mold packet "(" length? packet "bytes)"]

; Parse packet structure
if not empty? packet [
    ; First byte is length
    payload-length: take packet
    print ["Payload length:" payload-length]

    if not empty? packet [
        ; Second byte is message type
        msg-type: take packet
        print ["Message type:" msg-type "(" to-char msg-type ")"]

        ; Remaining bytes are payload (limited by length)
        payload: take/part packet payload-length - 1  ; -1 because type byte counts
        print ["Payload:" mold payload]
        print ["Payload as string:" to-string payload]

        ; Any remaining bytes
        if not empty? packet [
            print ["Remaining bytes:" mold packet]
        ]
    ]
]
print ""

print "=== PRACTICAL EXAMPLES COMPLETE ==="
print "These examples demonstrate TAKE solving real programming challenges"
