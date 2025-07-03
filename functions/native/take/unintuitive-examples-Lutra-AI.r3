REBOL []
;;=============================================================================
;; TAKE FUNCTION: UNINTUITIVE BEHAVIOR EXAMPLES
;;=============================================================================
;; Purpose: Document behaviors that might surprise developers
;; Audience: Rebol developers who need to avoid TAKE-related pitfalls
;; Evidence: Based on validated diagnostic probe results
;; Note: All tested behaviors were actually quite intuitive and predictable
;;=============================================================================

print "=== TAKE FUNCTION: UNINTUITIVE BEHAVIOR EXAMPLES ==="
print "=== Behaviors that might surprise developers ==="
print ""

;;-----------------------------------------------------------------------------
;; BEHAVIOR 1: Binary TAKE returns integers, not binary values
;;-----------------------------------------------------------------------------
print "--- BEHAVIOR 1: Binary bytes become integers ---"
print "Surprise: TAKE from binary returns decimal integer, not binary chunk"
print ""

hex-data: #{DEADBEEF}
print ["Binary data:" mold hex-data]
print ["Expected by newcomers: Maybe #{DE} or similar binary result"]

first-byte: take hex-data
print ["Actual result:" mold first-byte "(" mold type? first-byte ")"]
print ["Remaining binary:" mold hex-data]

print ""
print "Explanation: TAKE converts binary bytes to their decimal values"
print "DE hex = 14*16 + 14 = 224 + 14 = 238... wait, got 222"
print "Actually: DE hex = 13*16 + 14 = 208 + 14 = 222 ✓"
print ""
print "Practical impact: Always expect integer! when taking from binary"
print "If you need binary chunks, use COPY/PART instead"
print ""

;;-----------------------------------------------------------------------------
;; BEHAVIOR 2: Position references affect original series
;;-----------------------------------------------------------------------------
print "--- BEHAVIOR 2: Position references share data ---"
print "Surprise: TAKE from positioned series modifies the original"
print ""

original-data: [a b c d e f]
print ["Original series:" mold original-data]

; Create positioned reference
positioned: skip original-data 2  ; Points to 'c'
print ["Positioned reference:" mold positioned "(pointing to 'c')"]

; Take from positioned reference
result: take positioned
print ["Took from positioned:" mold result]
print ["Original after TAKE:" mold original-data]
print ["Positioned after TAKE:" mold positioned]

print ""
print "Explanation: Both variables reference the same underlying series"
print "TAKE modifies the series structure, affecting all references"
print ""
print "Practical impact: Be aware that positioned series share data"
print "Use COPY if you need independent series to work with"
print ""

;;-----------------------------------------------------------------------------
;; BEHAVIOR 3: /ALL is destructive to original
;;-----------------------------------------------------------------------------
print "--- BEHAVIOR 3: /ALL destroys original data ---"
print "Surprise: /ALL doesn't just copy, it also clears the source"
print ""

important-data: [config1 config2 config3]
print ["Important data:" mold important-data]
print ["Making 'backup' with take/all..."]

backup: take/all important-data
print ["Backup result:" mold backup]
print ["Original data after /ALL:" mold important-data]
print ["Original length now:" length? important-data]

print ""
print "Explanation: /ALL performs copy-then-clear in one operation"
print "It's not just 'take all', it's 'move all'"
print ""
print "Practical impact: Original data is destroyed, plan accordingly"
print "Use COPY/ALL if you want to preserve the original"
print ""

;;-----------------------------------------------------------------------------
;; BEHAVIOR 4: Empty series return NONE consistently
;;-----------------------------------------------------------------------------
print "--- BEHAVIOR 4: Empty series always return NONE ---"
print "Behavior: TAKE from empty series returns NONE, never errors"
print ""

empty-block: []
empty-string: ""
empty-binary: #{}

print "Testing all empty series types..."
result1: take empty-block
result2: take empty-string
result3: take empty-binary

print ["Empty block result:" mold result1 "(" mold type? result1 ")"]
print ["Empty string result:" mold result2 "(" mold type? result2 ")"]
print ["Empty binary result:" mold result3 "(" mold type? result3 ")"]

print ""
print "Explanation: TAKE gracefully handles empty series without errors"
print "This enables safe usage in loops without explicit empty? checks"
print ""
print "Practical impact: Always check for NONE before using results"
print "Pattern: while [item: take series][process item]"
print ""

;;-----------------------------------------------------------------------------
;; BEHAVIOR 5: /PART with zero returns appropriate empty type
;;-----------------------------------------------------------------------------
print "--- BEHAVIOR 5: /PART 0 returns typed empty containers ---"
print "Behavior: take/part series 0 returns empty but typed result"
print ""

test-block: [a b c]
test-string: "hello"

print ["Test block:" mold test-block]
print ["Test string:" mold test-string]

result1: take/part test-block 0
result2: take/part test-string 0

print ["take/part block 0:" mold result1 "(" mold type? result1 ")"]
print ["take/part string 0:" mold result2 "(" mold type? result2 ")"]
print ["Block unchanged:" mold test-block]
print ["String unchanged:" mold test-string]

print ""
print "Explanation: /PART 0 creates appropriately typed empty containers"
print "Useful for initializing containers of the right type"
print ""
print "Practical impact: Safe way to get empty containers matching series type"
print ""

print "=== UNINTUITIVE BEHAVIOR EXAMPLES COMPLETE ==="
print "Note: TAKE behavior is generally quite predictable and well-designed"
print "These 'surprises' are actually logical once you understand the patterns"
