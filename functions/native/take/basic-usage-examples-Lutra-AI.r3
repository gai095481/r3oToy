REBOL []
;;=============================================================================
;; TAKE FUNCTION: HAPPY PATH EXAMPLES
;;=============================================================================
;; Purpose: Demonstrate the most common, simple and correct uses of TAKE
;; Audience: Rebol developers learning basic TAKE usage patterns
;; Evidence: Based on validated diagnostic probe results (all tests passed)
;;=============================================================================

print "=== TAKE FUNCTION: HAPPY PATH EXAMPLES ==="
print "=== Most common, simple and correct uses ==="
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 1: Basic element removal from block
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 1: Basic element removal from block ---"
print "The fundamental TAKE operation - removes from head of series"
print ""

my-data: [apple banana cherry date elderberry]
print ["Before TAKE:" mold my-data "Length:" length? my-data]

first-item: take my-data
print ["Took:" mold first-item]
print ["After TAKE:" mold my-data "Length:" length? my-data]
print ""
print "Key point: TAKE modifies the original series in-place"
print "Perfect for queue processing (FIFO - First In, First Out)"
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 2: Character extraction from string
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 2: Character extraction from string ---"
print "TAKE from string returns char! type, not string!"
print ""

message: "Hello World"
print ["Before TAKE:" mold message "Length:" length? message]

first-char: take message
print ["Took:" mold first-char "Type:" mold type? first-char]
print ["After TAKE:" mold message "Length:" length? message]
print ""
print "Important: Result is char! not string! - handle accordingly"
print "Useful for character-by-character string parsing"
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 3: Multiple element extraction with /PART
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 3: Multiple element extraction with /PART ---"
print "/PART takes specified number of elements in one operation"
print ""

numbers: [1 2 3 4 5 6 7 8 9 10]
print ["Before TAKE:" mold numbers "Length:" length? numbers]

first-three: take/part numbers 3
print ["Took:" mold first-three "Type:" mold type? first-three]
print ["After TAKE:" mold numbers "Length:" length? numbers]
print ""
print "/PART returns block! even when taking from block"
print "Perfect for batch processing and data chunking"
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 4: Stack operations with /LAST
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 4: Stack operations with /LAST ---"
print "/LAST enables LIFO (Last In, First Out) behavior"
print ""

task-stack: [initialize connect authenticate process cleanup]
print ["Before TAKE:" mold task-stack "Length:" length? task-stack]

last-task: take/last task-stack
print ["Took:" mold last-task]
print ["After TAKE:" mold task-stack "Length:" length? task-stack]
print ""
print "/LAST is essential for undo functionality and nested operations"
print "Simulates stack data structure behavior"
print ""

;;-----------------------------------------------------------------------------
;; EXAMPLE 5: Complete data transfer with /ALL
;;-----------------------------------------------------------------------------
print "--- EXAMPLE 5: Complete data transfer with /ALL ---"
print "/ALL copies all content AND clears the original series"
print ""

temp-data: [session-info user-prefs temp-cache]
print ["Before TAKE:" mold temp-data "Length:" length? temp-data]

backup: take/all temp-data
print ["Took:" mold backup "Type:" mold type? backup]
print ["After TAKE:" mold temp-data "Length:" length? temp-data]
print ""
print "/ALL performs two operations: copy all + clear original"
print "Ideal for data migration and cleanup scenarios"
print ""

print "=== HAPPY PATH EXAMPLES COMPLETE ==="
print "These five patterns cover the majority of TAKE usage scenarios"
